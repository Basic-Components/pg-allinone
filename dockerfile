############################
# build jieba
############################
FROM --platform=$TARGETPLATFORM timescale/timescaledb:2.8.1-pg12 as build_jieba
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
FROM --platform=$TARGETPLATFORM timescale/timescaledb:2.8.1-pg12

# ARG POSTGIS_VERSION=3.1.0
ARG POSTGIS_VERSION=3.3.1
# ARG GDAL_VERSION=3.2.1
# ARG PROJ_VERSION=7.2.1

######POSTGIS SECTION
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
    python3

RUN set -ex \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.12/main \
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

# Build docker-agensgraph-extension-alpine
RUN cd /tmp \
    && git clone -b 'PG12/v1.1.0-rc0' https://github.com/apache/age.git /tmp/age \
    && cd /tmp/age \
    && make install

RUN cd / && rm -rf /tmp/age

COPY --from=build_jieba /usr/local/lib/postgresql/pg_jieba.so /usr/local/lib/postgresql/pg_jieba.so 
COPY --from=build_jieba /usr/local/share/postgresql/extension/pg_jieba.control /usr/local/share/postgresql/extension/pg_jieba.control
COPY --from=build_jieba /usr/local/share/postgresql/extension/pg_jieba--1.1.1.sql /usr/local/share/postgresql/extension/pg_jieba--1.1.1.sql
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba.idf /usr/local/share/postgresql/tsearch_data/jieba.idf
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba.stop /usr/local/share/postgresql/tsearch_data/jieba.stop
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_base.dict /usr/local/share/postgresql/tsearch_data/jieba_base.dict
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_hmm.model /usr/local/share/postgresql/tsearch_data/jieba_hmm.model
COPY --from=build_jieba /usr/local/share/postgresql/tsearch_data/jieba_user.dict /usr/local/share/postgresql/tsearch_data/jieba_user.dict

COPY  --from=postgres:12-alpine /usr/local/lib/postgresql/hstore_plpython3.so /usr/local/lib/postgresql/hstore_plpython3.so
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/hstore_plpython3u--1.0.sql  /usr/local/share/postgresql/extension/hstore_plpython3u--1.0.sql
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/hstore_plpython3u.control  /usr/local/share/postgresql/extension/hstore_plpython3u.control

COPY  --from=postgres:12-alpine /usr/local/lib/postgresql/jsonb_plpython3.so /usr/local/lib/postgresql/jsonb_plpython3.so
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/jsonb_plpython3u--1.0.sql  /usr/local/share/postgresql/extension/jsonb_plpython3u--1.0.sql
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/jsonb_plpython3u.control  /usr/local/share/postgresql/extension/jsonb_plpython3u.control

COPY  --from=postgres:12-alpine /usr/local/lib/postgresql/ltree_plpython3.so /usr/local/lib/postgresql/ltree_plpython3.so
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/ltree_plpython3u--1.0.sql  /usr/local/share/postgresql/extension/ltree_plpython3u--1.0.sql
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/ltree_plpython3u.control /usr/local/share/postgresql/extension/ltree_plpython3u.control

COPY  --from=postgres:12-alpine /usr/local/lib/postgresql/plpython3.so /usr/local/lib/postgresql/plpython3.so
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/plpython3u--1.0.sql  /usr/local/share/postgresql/extension/plpython3u--1.0.sql
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/plpython3u--unpackaged--1.0.sql  /usr/local/share/postgresql/extension/plpython3u--unpackaged--1.0.sql
COPY  --from=postgres:12-alpine /usr/local/share/postgresql/extension/plpython3u.control  /usr/local/share/postgresql/extension/plpython3u.control

COPY docker-entrypoint-initdb.d.src/create-extension-postgis.sql /docker-entrypoint-initdb.d/00-create-extension-postgis.sql

RUN set -ex \
    && apk add --no-cache \
    snappy-dev \
    python3-dev \
    py3-pip \
    cython \
    py3-numpy \
    py3-pandas \
    py3-apache-arrow

RUN python3 -m pip install --no-cache-dir wheel
RUN python3 -m pip install --no-cache-dir requests
RUN python3 -m pip install --no-cache-dir python-snappy
RUN python3 -m pip install --no-cache-dir crc32c
RUN python3 -m pip install --no-cache-dir lz4
RUN python3 -m pip install --no-cache-dir kafka-python
RUN python3 -m pip install --no-cache-dir redis
RUN python3 -m pip install --no-cache-dir clickhouse_driver
RUN python3 -m pip install --no-cache-dir pika


RUN mkdir /tmp/stat_temporary
RUN chmod 777 -R /tmp/stat_temporary
CMD ["postgres", "-c", "shared_preload_libraries=age,timescaledb,pg_jieba","-c", "stats_temp_directory=/tmp/stat_temporary"]