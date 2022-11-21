# pg11-0.0.5

## 增加fdw

+ kafka_fdw

# pg11-0.0.4

## 增加python依赖

+ numpy
+ pandas
+ cython
+ boto3

## 版本变化

+ `incubator-age`0.7.0 -> v1.1.0-rc0

# v0.0.3

## 新增插件

+ lppython3
+ ltree_plpython3
+ jsonb_plpython3
+ hstore_plpython3

## 增加python依赖

+ requests
+ python-snappy
+ crc32c
+ lz4
+ kafka-python
+ redis
+ clickhouse_driver
+ pika

# v0.0.2

## 新增插件

+ `incubator-age 0.7.0`

## 版本变化

+ `pg`12->11.14
+ `timescaledb`2.3.0->2.3.1
+ `postgis`2.5.1->3.1.0

# v0.0.1

## 镜像优化

+ 使用多步构建减小镜像大小

# v0.0.0

构建了项目

## 基镜像信息

+ 基镜像: [timescale/timescaledb-postgis:2.3.0-pg12](https://hub.docker.com/layers/timescale/timescaledb-postgis/2.3.0-pg12/images/sha256-7758704d4a1482f64178b3ec545a2a12111087a6b5b50ae2b9a091c2d529888c?context=explore)

## 安装插件

+ [pg_jeba@2d1b06b0e74c06a6ad47f301ade81bdc49b5dcce](https://github.com/jaiminpan/pg_jieba/tree/2d1b06b0e74c06a6ad47f301ade81bdc49b5dcce)