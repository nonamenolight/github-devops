# github-devops

## DevOps Project Phase 1

### 1 阶段目标

建立一个最小可用的生产级 CI/CD 闭环：

Git Push → GitHub Actions → Docker Image → Tencent TCR → Production Deployment → Health Check → Monitoring

最终实现：

Developer
    │
    │ git push
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├── Test
    ├── Build
    └── Push Image
           │
           ▼
      Tencent TCR
           │
           ▼
    Tencent Cloud VM
           │
       Docker
           │
       Demo App
           │
       Health Check
           │
       Monitoring

### 2 技术栈

| 模块 | 技术 |
| --- | --- |
| Code Repository | GitHub |
| CI/CD | GitHub Actions |
| Container | Docker |
| Image Registry | Tencent Cloud TCR
| Production | Tencent Cloud CVM
| Reverse Proxy | Nginx
| Application | 简单 Web API
| Deployment | SSH + Shell
| Monitoring | HTTP Health Check
| Alert | 基础告警
| Webhook | GitHub Webhook（可选）

### 3 应用设计

构建一个非常简单的 devops-demo Web 服务。

核心接口：

GET /
GET /health

示例：

{
  "service": "devops-demo",
  "version": "v1.0.0"
}

/health：

{
  "status": "ok"
}

应用版本通过 Docker Image Tag / Git Commit SHA 标识。

例如：

devops-demo:git-a83f91c

### 4 CI Pipeline

每次代码 Push 后自动执行：

Push
 ↓
Checkout
 ↓
Test
 ↓
Docker Build
 ↓
Tag Image
 ↓
Push Tencent TCR

镜像原则：

不依赖 latest 作为唯一生产版本，使用 Git Commit SHA 等不可变版本标识。

### 5 CD Pipeline

CI 成功后自动部署到腾讯云生产 VM：

GitHub Actions
      │
      ▼
SSH Production VM
      │
      ▼
deploy.sh
      │
      ├── Pull Image
      ├── Stop Old Container
      ├── Start New Container
      └── Health Check

部署失败时：

Health Check Failed
        ↓
Deployment Failed
        ↓
Rollback

### 6 Production Architecture

                    Internet
                       │
                    HTTPS
                       │
                       ▼
                ┌─────────────┐
                │    Nginx    │
                └──────┬──────┘
                       │
                       ▼
                ┌─────────────┐
                │ Docker      │
                │             │
                │ devops-demo │
                └─────────────┘
                       │
                    /health
                       │
                       ▼
                  Monitoring

生产服务器只开放必要的网络端口，并通过 Secrets 管理 CI/CD 所需凭据。

### 7 Monitoring

第一阶段暂不引入 Prometheus/Grafana。

实现最小健康监测：

HTTP /health
     │
     ├── 200 → Healthy
     ├── 5xx → Unhealthy
     └── Timeout → Unreachable

需要能够发现：

* 应用进程异常
* Docker Container 停止
* HTTP 服务异常
* 部署后健康检查失败

并进行基础告警。

### 8. 故障演练

至少完成以下实验：

Container Crash

docker stop devops-demo
        ↓
Monitoring
        ↓
发现服务异常
        ↓
告警

Bad Deployment

部署错误版本
      ↓
Health Check Failed
      ↓
Deployment Failed
      ↓
Rollback

Application Error

/health → HTTP 500
      ↓
Monitoring Detect
      ↓
Alert

通过这些实验验证：

系统不仅能部署，还能够发现故障、定位问题并恢复服务。

### 9 Webhook

Webhook 作为第一阶段的扩展项：

GitHub
   │
   │ Webhook
   ▼
Tencent Cloud Public IP
   │
   ▼
Webhook Receiver
   │
   ▼
Trigger Deployment

要求验证：

* Webhook 请求接收
* Secret 验证
* Event 判断
* 触发部署

如果不影响主链路，则纳入 Phase 1；否则延期到后续阶段。

### 10 Definition of Done

第一阶段完成的最终标准：

git push
   ↓
GitHub Actions ✓
   ↓
Test ✓
   ↓
Docker Build ✓
   ↓
Push TCR ✓
   ↓
Deploy Production ✓
   ↓
Health Check ✓
   ↓
Monitoring ✓

并且能够：

故障发生
   ↓
监控发现
   ↓
告警
   ↓
排查
   ↓
恢复 / Rollback

最终目标不是“把几个工具搭起来”，而是跑通一个真正完整的 DevOps 生产闭环。
