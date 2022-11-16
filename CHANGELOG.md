# pg12-0.0.5

## 增加fdw

+ parquet_s3_fdw
+ kafka_fdw

# pg12-0.0.4

1. 0.0.4版本的pg12版,相比pg11版多出对parquet的支持
2. 丰富了文档,统一了版本命名格式
3. 增加了特性测试,并提供了用于测试的docker-compose
4. 拆分了dockerfile和dockerfile.cn,前者用于release时借由github action打包,后者用于国内手工打包