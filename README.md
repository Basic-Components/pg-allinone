# pg-allinone

+ author: hsz
+ version: 0.0.1

安装了各种实用插件的pg镜像.

## 环境介绍

+ 操作系统: alpine
+ 基镜像: [timescale/timescaledb-postgis:2.3.1-pg12](https://hub.docker.com/layers/timescale/timescaledb-postgis/2.3.0-pg12/images/sha256-7758704d4a1482f64178b3ec545a2a12111087a6b5b50ae2b9a091c2d529888c?context=explore)

收录实用插件包括:

+ `pg_trgm`(自带)用于模糊查询
+ [timescaledb](https://github.com/timescale/timescaledb)用于作为时序数据库(自带)
+ [apache-age](https://age.apache.org/docs/master/intro/operators.html)用于作为图数据库
+ [postgis](https://github.com/postgis/postgis)用于做地理空间数据计算(自带)
+ [pg_jeba](https://github.com/jaiminpan/pg_jieba)用于中文分词