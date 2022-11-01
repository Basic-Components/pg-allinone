CREATE OR REPLACE FUNCTION save2oss() RETURNS text
AS 
$$
  import json 
  import boto3
  rv = plpy.execute("select 1 as result")
  rows = []
  for row in rv:
    rows.append(row)
  s3_target = boto3.resource('s3', 
    endpoint_url='http://minio:9000',
    aws_access_key_id='hsz',
    aws_secret_access_key='hsz881224',
    aws_session_token=None,
    config=boto3.session.Config(signature_version='s3v4'),
    verify=False
  )
  s3_target.Bucket('test01').put_object(Key='test.json', Body=json.dumps(rows))
  return "ok"
$$ LANGUAGE plpython3u;


select save2oss();