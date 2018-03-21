FROM alpine:3.5

ENV CONFIG "\
      --dso-tool-path=/usr/sbin/dso_tool \
      --pid-path=/var/run/tengine.pid \
      --lock-path=/var/run/lock/tengine.lock \
      --http-log-path=/var/log/tengine/access.log \
      --error-log-path=/var/log/tengine/error.log \
      --with-imap \
      --with-imap_ssl_module \
      --with-ipv6 \
      --with-pcre-jit \
      --with-http_dav_module \
      --with-http_geoip_module=shared \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_random_index_module \
      --with-http_memcached_module=shared \
      --with-http_realip_module \
      --with-http_secure_link_module=shared \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_stub_status_module \
      --with-http_addition_module \
      --with-http_degradation_module \
      --with-http_flv_module=shared \
      --with-http_mp4_module=shared\
      --with-http_sub_module=shared \
      --with-http_sysguard_module=shared \
      --with-http_reqstat_module=shared \
      --with-file-aio \
      --with-mail \
      --with-mail_ssl_module \
      --with-http_concat_module \
      --with-jemalloc"

ADD . /root

# you may need this if u live in China
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk add --update \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        jemalloc-dev \
        geoip-dev \
    && cd /root \
    && ./configure $CONFIG --with-debug \
    && make install \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/tengine/access.log \
    && ln -sf /dev/stderr /var/log/tengine/error.log

# Remove unneeded packages/files
RUN apk del gcc linux-headers make \
  && rm -rf ~/* ~/.git ~/.gitignore ~/.travis.yml ~/.ash_history \
  && rm -rf /var/cache/apk/*

EXPOSE 80 443

WORKDIR /usr/local/nginx
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
