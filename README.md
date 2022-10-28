# pg-allinone

+ author: hsz
+ version: 0.0.4

安装了各种实用插件的pg镜像.该项目针对oltp场景,只考虑单节点和主备高可用部署场景

## 对应镜像分支

+ hsz1273327/pg-allinone:0.0.4
+ hsz1273327/pg-allinone:latest
+ hsz1273327/pg-allinone:pg11-ts
+ hsz1273327/pg-allinone:pg11-ts2.3.1-age0.7.0-postgis3.1.0

+ hsz1273327/pg-allinone:pg11-latest
+ hsz1273327/pg-allinone:pg11-0.0.4

## 环境介绍

+ 操作系统: alpine
+ 基镜像: timescale/timescaledb:2.3.1-pg11

收录实用插件包括:

+ `pg_trgm`(自带)用于模糊查询
+ [timescaledb](https://github.com/timescale/timescaledb)用于作为时序数据库(自带)
+ [apache-age](https://age.apache.org/docs/master/intro/operators.html)用于作为图数据库
+ [postgis](https://github.com/postgis/postgis)用于做地理空间数据计算(自带)
+ [pg_jeba](https://github.com/jaiminpan/pg_jieba)用于中文分词
+ 支持python作为过程处理脚本语言,同时提供如下三方库的支持:
    + numpy
    + pandas
    + pyarrow
    + cython
    + fastparquet
    + requests
    + python-snappy
    + crc32c
    + lz4
    + kafka-python
    + redis
    + clickhouse_driver
    + pika
