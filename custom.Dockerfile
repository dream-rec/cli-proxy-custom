# 使用轻量级基础镜像
FROM alpine:latest

# 安装基础依赖 (ca-certificates 用于 HTTPS 请求)
RUN apk --no-cache add ca-certificates tzdata

# 设置工作目录
WORKDIR /app

# 复制编译好的 Linux 二进制文件 (将在构建脚本中生成)
COPY cli-proxy-linux /app/CLIProxyAPI

# 复制静态资源 (包含修复版 management.html)
COPY static /app/static

# 创建数据目录
RUN mkdir -p /data/auths

# 暴露端口
EXPOSE 8317

# 设置环境变量，告诉程序配置文件在外部挂载
ENV CONFIG_FILE=/data/config.yaml

# 启动命令
ENTRYPOINT ["/app/CLIProxyAPI"]
CMD ["--config", "/data/config.yaml"]
