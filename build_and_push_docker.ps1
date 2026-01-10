# build_and_push_docker.ps1

# --- 配置部分 (请在此处修改您的 Docker Hub 用户名) ---
$DOCKER_USERNAME = "您的DockerHub用户名" 
$IMAGE_NAME = "cli-proxy-custom"
$TAG = "latest"

$FULL_IMAGE_NAME = "$DOCKER_USERNAME/$IMAGE_NAME:$TAG"

Write-Host ">>> 正在检查 Docker 环境..." -ForegroundColor Cyan
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Error "未检测到 Docker，请先安装 Docker Desktop 并启动！"
    exit 1
}

# 1. 交叉编译 Linux 版本
Write-Host "`n>>> 1. 正在编译 Linux 版本二进制文件..." -ForegroundColor Cyan
$env:GOOS = "linux"
$env:GOARCH = "amd64"
$env:CGO_ENABLED = "0"
go build -o cli-proxy-linux cmd/server/main.go
$env:GOOS = "windows" # 恢复环境变量

if (-not (Test-Path "cli-proxy-linux")) {
    Write-Error "编译失败，未找到 cli-proxy-linux 文件！"
    exit 1
}
Write-Host "编译成功！" -ForegroundColor Green

# 2. 构建 Docker 镜像
Write-Host "`n>>> 2. 正在构建 Docker 镜像: $FULL_IMAGE_NAME ..." -ForegroundColor Cyan
docker build -f custom.Dockerfile -t $FULL_IMAGE_NAME .
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker 镜像构建失败！"
    exit 1
}
Write-Host "镜像构建成功！" -ForegroundColor Green

# 3. 推送镜像 (可选，需要先登录)
Write-Host "`n>>> 3. 如果您已登录 Docker Hub，现在将开始推送镜像..." -ForegroundColor Cyan
Write-Host "提示: 如果推送失败，请先在新的终端窗口运行 'docker login' 登录您的账号。" -ForegroundColor Yellow

$pushConfirmation = Read-Host "确认推送? (y/n)"
if ($pushConfirmation -eq 'y') {
    docker push $FULL_IMAGE_NAME
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Push 成功！您的镜像地址是: $FULL_IMAGE_NAME" -ForegroundColor Green
        Write-Host "您现在可以在 ClawCloud Run 的 'Image Name' 中填入此地址了。" -ForegroundColor Cyan
    } else {
        Write-Error "Push 失败，由您自行处理上传或检查登录状态。"
    }
} else {
    Write-Host "已跳过推送。您稍后可以手动执行: docker push $FULL_IMAGE_NAME" -ForegroundColor Yellow
}
