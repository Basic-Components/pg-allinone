CREATE SERVER kafka_server
FOREIGN DATA WRAPPER kafka_fdw
OPTIONS (brokers '192.168.56.13:9092');

CREATE USER MAPPING FOR PUBLIC SERVER kafka_server;

CREATE FOREIGN TABLE kafka_test_json (
    part int OPTIONS (partition 'true'),
    offs bigint OPTIONS (offset 'true'),
    some_int int OPTIONS (json 'int_val'),
    some_text text OPTIONS (json 'text_val'),
    some_date date OPTIONS (json 'date_val'),
    some_time timestamp OPTIONS (json 'time_val')
)
SERVER kafka_server OPTIONS
    (format 'json', topic 'contrib_regress_json', batch_size '3', buffer_delay '100');

INSERT INTO kafka_test_json(some_int, some_text)
VALUES
    (5464565, 'some text goes into partition selected by kafka0'),
    (5464566, 'some text goes into partition selected by kafka1'),
    (5464567, 'some text goes into partition selected by kafka2'),
    (5464568, 'some text goes into partition selected by kafka3'),
    (5464569, 'some text goes into partition selected by kafka4'),
    (5464570, 'some text goes into partition selected by kafka5')
RETURNING *;


SELECT * FROM kafka_test_json WHERE part = 0 AND offs > 0 LIMIT 3;