FROM --platform=$TARGETPLATFORM timescale/timescaledb-postgis:2.3.1-pg12 as build_jieba
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

# # 删除插件源码包
# WORKDIR /
# RUN rm -rf /plugins

FROM --platform=$TARGETPLATFORM timescale/timescaledb-postgis:2.3.0-pg12
COPY --from=build_jieba /usr/local/lib/postgresql/pg_jieba.so /usr/local/lib/postgresql/pg_jieba.so 
COPY --from=build_jieba /usr/local/share/postgresql/extension/pg_jieba.control /usr/local/share/postgresql/extension/pg_jieba.control
COPY --from=build_jieba /usr/local/share/postgresql/extension/pg_jieba--1.1.1.sql /usr/local/share/postgresql/extension/pg_jieba--1.1.1.sql
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba.idf /usr/local/share/postgresql/tsearch_data/jieba.idf
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba.stop /usr/local/share/postgresql/tsearch_data/jieba.stop
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_base.dict /usr/local/share/postgresql/tsearch_data/jieba_base.dict
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_hmm.model /usr/local/share/postgresql/tsearch_data/jieba_hmm.model
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_user.dict /usr/local/share/postgresql/tsearch_data/jieba_user.dict