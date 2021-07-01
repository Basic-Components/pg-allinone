FROM --platform=$TARGETPLATFORM timescale/timescaledb-postgis:2.3.0-pg12
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk update && \
    apk --no-cache add build-base \
    git \
    make \
    cmake \
    autoconf \
    rm -rf /var/cache/apk/* 
# 安装jieba分词
WORKDIR /plugins
RUN git clone -b 2d1b06b0e74c06a6ad47f301ade81bdc49b5dcce https://github.com/jaiminpan/pg_jieba
WORKDIR /plugins/pg_jieba
RUN git submodule update --init --recursive
RUN mkdir build
WORKDIR /plugins/pg_jieba/build
RUN cmake ..
RUN make
RUN make install

# 删除插件源码包
WORKDIR /
RUN rm -rf /plugins