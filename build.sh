docker buildx build --push --platform=linux/amd64,linux/arm64 \
-t hsz1273327/pg-allinone:pg11-0.0.4 \
-t hsz1273327/pg-allinone:pg11-latest \
-f dockerfile.cn.