############################
# build jieba
############################
FROM --platform=$TARGETPLATFORM timescale/timescaledb:2.3.1-pg11 as build_jieba
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
RUN git clone https://github.com/jaiminpan/pg_jieba
WORKDIR /plugins/pg_jieba
RUN git submodule update --init --recursive
RUN mkdir build
WORKDIR /plugins/pg_jieba/build
RUN cmake ..
RUN make
RUN make install



############################
# Now build image and copy in tools
############################
FROM --platform=$TARGETPLATFORM timescale/timescaledb:2.3.1-pg11

ARG POSTGIS_VERSION=3.1.0
ARG GDAL_VERSION=3.2.1
ARG PROJ_VERSION=7.2.1

#Build POSTGIS
ENV POSTGIS_VERSION ${POSTGIS_VERSION}
RUN set -ex \
    && apk add --no-cache \
    ca-certificates \
    openssl \
    tar \
    bison \
    flex \
    clang \
    git \
    llvm \
    python3 \
    curl-dev \
    zlib-dev \
    openssl-dev \
    nghttp2-static \
    boost-dev \
    cmake

RUN set -ex \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main \
    postgresql-dev

RUN set -ex \
    && apk add --no-cache --repository http://nl.alpinelinux.org/alpine/v3.14/main \
    geos \
    gdal \
    proj \
    protobuf-c \
    perl \
    file \
    geos-dev \
    libxml2-dev \
    gdal-dev \
    proj-dev \
    protobuf-c-dev \
    json-c-dev \
    gcc g++ \
    make

RUN git config --global http.version HTTP/1.1

RUN cd /tmp \
    && wget http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz -O - | tar -xz \
    && chown root:root -R postgis-${POSTGIS_VERSION} \
    && cd /tmp/postgis-${POSTGIS_VERSION} \
    && ./configure \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis/Makefile \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis_topology/Makefile \
    && make -s \
    && make -s install \
    && apk add --no-cache --virtual .postgis-rundeps \
    json-c \
    && cd / \
    && rm -rf /tmp/postgis-${POSTGIS_VERSION}

RUN cd /tmp \
    && git clone -b 'v1.1.0-rc0' https://github.com/apache/age.git /tmp/age \
    && cd /tmp/age \
    && make install
RUN cd / && rm -rf /tmp/age

RUN cd /tmp \
    && git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp.git /tmp/aws-sdk-cpp \
    && cd /tmp/aws-sdk-cpp \
    && mkdir build && cd build \
    && cmake .. \
        -DBUILD_ONLY="core;s3" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCUSTOM_MEMORY_MANAGEMENT=OFF \
        -DCMAKE_INSTALL_PREFIX=/musl \
        -DENABLE_UNITY_BUILD=ON && \
    make && make install

RUN cd / && rm -rf /tmp/aws-sdk-cpp
RUN cd /tmp \
    && git clone  -b 'v0.3.0' https://github.com/pgspider/parquet_s3_fdw.git /tmp/parquet_s3_fdw \
    && cd /tmp/parquet_s3_fdw \
    make install
RUN cd / && rm -rf /tmp/parquet_s3_fdw

RUN set -ex \
    && apk add --no-cache \
    librdkafka-dev
RUN cd /tmp \
    && git clone  https://github.com/adjust/kafka_fdw.git /tmp/kafka_fdw \
    && cd /tmp/kafka_fdw \
    make && make install
RUN cd / && rm -rf /tmp/kafka_fdw
    
COPY --from=build_jieba /usr/local/lib/postgresql/pg_jieba.so /usr/local/lib/postgresql/pg_jieba.so 
COPY --from=build_jieba /usr/local/share/postgresql/extension/pg_jieba.control /usr/local/share/postgresql/extension/pg_jieba.control
COPY --from=build_jieba /usr/local/share/postgresql/extension/pg_jieba--1.1.1.sql /usr/local/share/postgresql/extension/pg_jieba--1.1.1.sql
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba.idf /usr/local/share/postgresql/tsearch_data/jieba.idf
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba.stop /usr/local/share/postgresql/tsearch_data/jieba.stop
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_base.dict /usr/local/share/postgresql/tsearch_data/jieba_base.dict
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_hmm.model /usr/local/share/postgresql/tsearch_data/jieba_hmm.model
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_user.dict /usr/local/share/postgresql/tsearch_data/jieba_user.dict

COPY  --from=postgres:11-alpine /usr/local/lib/postgresql/hstore_plpython3.so /usr/local/lib/postgresql/hstore_plpython3.so
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/hstore_plpython3u--1.0.sql  /usr/local/share/postgresql/extension/hstore_plpython3u--1.0.sql
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/hstore_plpython3u.control  /usr/local/share/postgresql/extension/hstore_plpython3u.control

COPY  --from=postgres:11-alpine /usr/local/lib/postgresql/jsonb_plpython3.so /usr/local/lib/postgresql/jsonb_plpython3.so
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/jsonb_plpython3u--1.0.sql  /usr/local/share/postgresql/extension/jsonb_plpython3u--1.0.sql
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/jsonb_plpython3u.control  /usr/local/share/postgresql/extension/jsonb_plpython3u.control

COPY  --from=postgres:11-alpine /usr/local/lib/postgresql/ltree_plpython3.so /usr/local/lib/postgresql/ltree_plpython3.so
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/ltree_plpython3u--1.0.sql  /usr/local/share/postgresql/extension/ltree_plpython3u--1.0.sql
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/ltree_plpython3u.control /usr/local/share/postgresql/extension/ltree_plpython3u.control

COPY  --from=postgres:11-alpine /usr/local/lib/postgresql/plpython3.so /usr/local/lib/postgresql/plpython3.so
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/plpython3u--1.0.sql  /usr/local/share/postgresql/extension/plpython3u--1.0.sql
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/plpython3u--unpackaged--1.0.sql  /usr/local/share/postgresql/extension/plpython3u--unpackaged--1.0.sql
COPY  --from=postgres:11-alpine /usr/local/share/postgresql/extension/plpython3u.control  /usr/local/share/postgresql/extension/plpython3u.control

# 提前加载
COPY docker-entrypoint-initdb.d.src/create-extension-postgis.sql /docker-entrypoint-initdb.d/00-create-extension-postgis.sql
COPY docker-entrypoint-initdb.d.src/create-extension-age.sql /docker-entrypoint-initdb.d/00-create-extension-age.sql
COPY docker-entrypoint-initdb.d.src/create-extension-jieba.sql /docker-entrypoint-initdb.d/00-create-extension-jieba.sql
COPY docker-entrypoint-initdb.d.src/create-extension-py.sql  /docker-entrypoint-initdb.d/00-create-extension-py.sql
COPY docker-entrypoint-initdb.d.src/create-extension-parquet_s3_fdw.sql  /docker-entrypoint-initdb.d/00-create-extension-parquet_s3_fdw.sql
COPY docker-entrypoint-initdb.d.src/create-extension-kafka_fdw.sql  /docker-entrypoint-initdb.d/00-create-extension-kafka_fdw.sql

RUN set -ex \
    && apk add --no-cache \
    snappy-dev \
    python3-dev \
    py3-pip \
    cython \
    py3-numpy \
    py3-pandas

RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir wheel
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir requests
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir python-snappy
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir crc32c
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir lz4
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir kafka-python
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir redis
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir clickhouse_driver
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir pika
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir boto3

RUN mkdir /tmp/stat_temporary
RUN chmod 777 -R /tmp/stat_temporary
CMD ["postgres", "-c", "shared_preload_libraries=age,timescaledb,pg_jieba","-c", "stats_temp_directory=/tmp/stat_temporary"]