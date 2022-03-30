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

######POSTGIS SECTION

# # Setup build env for PROJ
# RUN apk add --no-cache clang llvm tar gzip wget curl unzip -q make libtool autoconf automake pkgconfig g++ sqlite sqlite-dev \
#     linux-headers \
#     curl-dev tiff-dev \
#     zlib-dev zstd-dev \
#     libjpeg-turbo-dev libpng-dev openjpeg-dev libwebp-dev expat-dev \
#     py3-numpy-dev python3-dev py3-numpy \
#     openexr-dev \
#     # For spatialite (and GDAL)
#     libxml2-dev \
#     && mkdir -p /build_thirdparty/usr/lib

# RUN \
#     mkdir -p /build_projgrids/usr/share/proj \
#     && curl -LOs http://download.osgeo.org/proj/proj-datumgrid-latest.zip \
#     && unzip -q -j -u -o proj-datumgrid-latest.zip  -d /build_projgrids/usr/share/proj \
#     && rm -f *.zip


# #Build PROJ
# ENV PROJ_VERSION ${PROJ_VERSION}
# RUN set -ex \
#     &&	mkdir proj\
#     && wget -q https://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz -O - \
#         | tar xz -C proj --strip-components=1 \
#     && cd proj\
#     && ./configure --prefix=/usr --disable-static --enable-lto \
#     && make -j$(nproc) \
#     && make install \
#     && make install DESTDIR="/build_proj" \
#     && if test "${RSYNC_REMOTE}" != ""; then \
#         ccache -s; \
#         echo "Uploading cache..."; \
#         rsync -ra --delete $HOME/.ccache ${RSYNC_REMOTE}/proj/; \
#         echo "Finished"; \
#         rm -rf $HOME/.ccache; \
#         unset CC; \
#         unset CXX; \
#     fi \
#     && cd .. \
#     && rm -rf proj \
#     && for i in /build_proj/usr/lib/*; do strip -s $i 2>/dev/null || /bin/true; done \
#     && for i in /build_proj/usr/bin/*; do strip -s $i 2>/dev/null || /bin/true; done



# #Build GDAL
# ENV GDALVERSION ${GDAL_VERSION}
# RUN set -ex && \
#   apk update && \
#   apk add --virtual build-dependencies \
#     # to reach GitHub's https
#     openssl ca-certificates \
#     build-base cmake musl-dev linux-headers \
#     # for libkml compilation
#     zlib-dev minizip-dev expat-dev uriparser-dev boost-dev && \
#   apk add \
#     # libkml runtime
#     zlib minizip expat uriparser boost && \
#   update-ca-certificates 
# ENV GDAL_VERSION ${GDAL_VERSION}
# RUN set -ex \ && \
# 	mkdir gdal && cd gdal &&\
# 	wget -O gdal.tar.gz "http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz" &&\
#   tar --extract --file gdal.tar.gz --strip-components 1 && \
#   ./configure --prefix=/usr \
#     --with-libkml \
#     --without-bsb \
#     --without-dwgdirect \
#     --without-ecw \
#     --without-fme \
#     --without-gnm \
#     --without-grass \
#     --without-grib \
#     --without-hdf4 \
#     --without-hdf5 \
#     --without-idb \
#     --without-ingress \
#     --without-jasper \
#     --without-mrf \
#     --without-mrsid \
#     --without-netcdf \
#     --without-pcdisk \
#     --without-pcraster \
#     --without-webp \
#    # --with-proj=/usr/local \
#   && make && make install \
#   && cd .. && rm -rf gdal

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
# libressl \
# libcrypto1.1

# RUN set -ex \
#     && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main \
#                 #libressl2.7-libcrypto \
#                 libressl \
#                 libcrypto1.1
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
# && apk del .fetch-deps .build-deps
# Build docker-agensgraph-extension-alpine
RUN cd /tmp \
    && git clone -b 'release/0.7.0' https://github.com/apache/incubator-age /tmp/age \
    && cd /tmp/age \
    && make install \
    && cd / \
    && rm -rf /tmp/age


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

#COPY docker-entrypoint-initdb.d/create-extension-age.sql /docker-entrypoint-initdb.d/00-create-extension-age.sql
#COPY docker-entrypoint-initdb.d/create-extension-jieba.sql /docker-entrypoint-initdb.d/00-create-extension-jieba.sql
COPY docker-entrypoint-initdb.d/create-extension-postgis.sql /docker-entrypoint-initdb.d/00-create-extension-postgis.sql

RUN set -ex \
    && apk add --no-cache \
    snappy-dev \
    python3-dev \
    py3-pip \
    cython \
    py3-numpy \
    py3-pandas \
    cargo

RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir wheel
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir requests
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir python-snappy
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir crc32c
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir lz4
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir kafka-python
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir redis
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir clickhouse_driver
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir pika
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir cramjam
RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir fastparquet==0.8.0

RUN mkdir /tmp/stat_temporary
RUN chmod 777 -R /tmp/stat_temporary
# ENTRYPOINT ["postgres", "-c", "shared_preload_libraries=age"]
CMD ["postgres", "-c", "shared_preload_libraries=age,timescaledb,pg_jieba","-c", "stats_temp_directory=/tmp/stat_temporary"]