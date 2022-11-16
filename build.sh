docker buildx build --push --platform=linux/amd64,linux/arm64 \
-t hsz1273327/pg-allinone:pg12-perview \
-f dockerfile.cn .