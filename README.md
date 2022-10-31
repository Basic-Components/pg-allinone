# pg-allinone

+ author: hsz
+ version: pg12-0.0.4

安装了各种实用插件的pg镜像.该项目针对oltp场景,只考虑单节点和主备高可用部署场景

## 对应镜像分支

+ hsz1273327/pg-allinone:pg12_latest
+ hsz1273327/pg-allinone:pg12_0.0.4

## 环境介绍

+ 操作系统: alpine
+ 平台: arm64/amd64
+ 基镜像: timescale/timescaledb:2.3.1-pg11

收录实用插件包括:

+ `pg_trgm`(自带)用于模糊查询
+ [timescaledb](https://github.com/timescale/timescaledb)用于作为时序数据库(自带)-2.3.1
+ [apache-age](https://age.apache.org/docs/master/intro/operators.html)用于作为图数据库-0.7.0
+ [postgis](https://github.com/postgis/postgis)用于做地理空间数据计算(自带)-3.1.0
+ [pg_jeba](https://github.com/jaiminpan/pg_jieba)用于中文分词
+ 支持python作为过程处理脚本语言,同时提供如下三方库的支持:
    + numpy
    + pandas
    + cython
    + requests
    + python-snappy
    + crc32c
    + lz4
    + kafka-python
    + redis
    + clickhouse_driver
    + pika
    + pyarrow
