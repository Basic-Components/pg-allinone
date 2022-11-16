# pg-allinone

+ author: hsz
+ version: pg12-0.0.5

安装了各种实用插件的pg镜像.该项目针对oltp场景,只考虑单节点和主备高可用部署场景

## 对应镜像分支

+ hsz1273327/pg-allinone:pg12-latest
+ hsz1273327/pg-allinone:pg12-0.0.4

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
    + boto3

+ [parquet_s3_fdw](https://github.com/pgspider/parquet_s3_fdw)用于作为s3上的parquet文件的只读sql引擎
+ [kafka_fdw](https://github.com/adjust/kafka_fdw)用于将kafka中的数据作为源使用,主要用于调试

## 测试特性

tests文件夹提供了供测试使用的SQL脚本和进入容器的语句.

## 使用与场景

本项目构造的镜像是以在本地而非云端使用为前提的.如果在云端要用pg建议还是直接购买服务商的对应服务.

请在不同的场景下使用不同的配置单独使用,不要所有场景混在一起使用,很容易因为无法兼顾各种要求拖累业务需求.pg只是适用场景丰富,不是银弹.

### OLTP

OLTP场景下推荐的面向业务,根据需要使用对应的特性.也不要盲目追求集群化.多数时候业务量不够时集群化是鸡肋

#### 单节点

1. age用于支持图数据
2. postgis用于支持地理数据
3. pg_jeba用于中文分词
4. 使用python3配合timescaledb的User-defined actions通过clickhouse_driver定时落库数据到clickhouse
5. 使用python3配合timescaledb的User-defined actions通过pyarrow,pandas,csv,json,等配合boto3向s3接口(包括minio)中写入文件落库.

### 集群

暂无

## HTAP

HTAP场景下依然建议悠着点使用,不用盲目上集群.HTAP场景下更多的是计算密集型任务,不要直接对接业务,起码中间要有个缓存层避免让pg负载过重

### 单节点

1. timescaledb用于支持时序数据
2. 使用python3配合timescaledb的User-defined actions通过kafka-python,向kafka中定时发送事件
3. 使用python3配合timescaledb的User-defined actions通过redis-py,向redis中定时写入缓存或者publish消息
4. 使用python3配合timescaledb的User-defined actions通过pika,向rabbitmq中定时发送消息

### 集群

1. 可用于组timescaledb集群

## OLAP

1. 使用parquet_s3_fdw可以用于读取存放在s3接口中的数据并进行并行化处理

## 数据调试

+ 使用kafka_fdw可以用于kafka中数据的调试
