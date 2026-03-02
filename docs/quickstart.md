# 快速开始（小白版）

> 仓库只提供模板与流程。密钥、系统级安装、用户路径与权限变更都在用户本机由 Agent 经确认后执行，不写入 Git。

## 0) 先做预检（安装前）
```bash
bash scripts/preflight.sh
```

## 1) 安装前可以做什么
- 创建服务用户（建议：`svc_openclaw`）。
- 准备目录：`apps` / `etc` / `var/openclaw` / `logs/openclaw`。
- 准备模板：env、启动脚本、launchd plist、openclaw.json。

## 2) 安装后必须确认什么
- OpenClaw 实际可执行命令与路径。
- Provider 配置字段是否正确（见 `docs/config-reference.md`）。
- 聊天渠道（如飞书）是否按顺序完成。

## 3) 飞书机器人接入（强顺序）
1. 在飞书创建应用，拿 `appId/appSecret`。
2. 先写入 OpenClaw 配置并重启服务。
3. 再在飞书后台配置：长连接（WebSocket）+ `im.message.receive_v1` + 权限 + 发布版本。
4. 再执行 pairing：`list` -> `approve`。
5. 验收通过后把 `dmPolicy` 切为 `allowlist` 并配置 `allowFrom`。

> 如果顺序错了，常见现象是“事件订阅保存不了”或“没有 pending pairing 请求”。

## 4) 手动 vs 自动对照
| 项目 | 主用户手动 | Agent 自动 |
|---|---|---|
| 创建服务用户 | 是 | 否 |
| 提供密钥 | 是 | 否（仅按你输入写入） |
| 选择 Provider/渠道 | 是 | 否（Agent 提问） |
| 目录与模板初始化 | 否 | 是 |
| launchd 安装/重启/验收 | 否（仅确认 sudo） | 是 |

## 5) 最小验收
```bash
bash scripts/verify-service.sh
```

至少满足：
- 服务状态可读取且 `running`
- 目标端口在监听
- 进程属主是服务用户
- 关键日志没有阻断错误
- Feishu 通道状态（如启用）为 `running/works`
