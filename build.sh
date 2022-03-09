docker buildx build --push --platform=linux/amd64,linux/arm64 \
-t hsz1273327/pg-allinone:0.0.3 \
-t hsz1273327/pg-allinone:latest \
-t hsz1273327/pg-allinone:pg11 \
-t hsz1273327/pg-allinone:pg11-ts2.3.1-age0.7.0-postgis3.1.0 .