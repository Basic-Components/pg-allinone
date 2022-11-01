CREATE OR REPLACE FUNCTION pub_2_redis() RETURNS text
AS 
$$
  import redis
  import json
  r = redis.Redis(host='redis', port=6379, db=0)
  rv = plpy.execute("select 1 as result")
  rows = []
  for row in rv:
    rows.append(row)
  r.publish("msg",json.dumps(rows))
  return "ok"
$$ LANGUAGE plpython3u;


select pub_2_redis();

