
CREATE SERVER parquet_s3_srv FOREIGN DATA WRAPPER parquet_s3_fdw OPTIONS (use_minio 'minio:9000');

CREATE USER MAPPING FOR public SERVER parquet_s3_srv OPTIONS (user 'admin', password 'admin1234');


CREATE FOREIGN TABLE driver_stats_1 (
    event_timestamp  TIMESTAMP,
    driver_id  INT8,
    conv_rate  FLOAT8,
    acc_rate  FLOAT8,
    avg_daily_trips INT8,    
    created TIMESTAMP
)
SERVER parquet_s3_srv
OPTIONS (
    filename 's3://test01/driver_stats.parquet'
);

SELECT * FROM  driver_stats_1 limit 10;

CREATE FOREIGN TABLE driver_stats_schemaless_1 (
    v jsonb
)
SERVER parquet_s3_srv
OPTIONS (
    filename 's3://test01/driver_stats.parquet', 
    schemaless 'true'
);

SELECT * FROM  driver_stats_schemaless limit 10;