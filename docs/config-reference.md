# OpenClaw 配置参考（API + Feishu）

> 本文件是本项目的配置基线。优先以本文件字段为准。

## 1) 最小可用配置（示例）

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "api": "openai-responses",
        "models": [
          { "id": "gpt-5.1-codex", "name": "gpt-5.1-codex" }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/gpt-5.1-codex"
      }
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "domain": "feishu",
      "connectionMode": "websocket",
      "dmPolicy": "pairing",
      "groupPolicy": "open",
      "accounts": {
        "default": {
          "appId": "cli_xxx",
          "appSecret": "xxx"
        }
      }
    }
  }
}
```

## 2) 强校验规则
- `models.providers.openai.baseUrl`：必须是 `baseUrl`（小写 `l`），不是 `baseURL`。
- `models.providers.openai.models`：必须是数组，至少一个模型。
- `agents.defaults.model.primary`：必须写全限定名 `provider/model`，例如 `openai/glm-4.7`。
- `channels.feishu.connectionMode`：建议 `websocket`。
- 首次接入飞书：`dmPolicy` 先用 `pairing`，验收通过后改 `allowlist`。

## 3) 飞书接入顺序（关键）
1. 在飞书开放平台创建应用，拿到 `appId/appSecret`。
2. 先写入 OpenClaw 配置并重启服务。
3. 再回飞书配置长连接事件订阅（`im.message.receive_v1`）和权限，并发布版本。
4. 在飞书私聊机器人触发 pairing，服务侧 approve。
5. 稳定后切 `dmPolicy=allowlist`，填 `allowFrom`。

## 4) 错误对照与修复

| 现象 | 常见原因 | 修复命令 |
|---|---|---|
| `Unrecognized key: \"baseURL\"` | 字段名写成 `baseURL` | `sudo vi /Users/svc_openclaw/.openclaw/openclaw.json` 改为 `baseUrl` 后重启 |
| `models.providers.openai.models: expected array` | 漏填 `models[]` | 补齐 `models` 数组后重启 |
| `Unknown model: anthropic/<model>` | `primary` 未写 provider | 改为 `openai/<model>` 后重启 |
| `No pending feishu pairing requests` | 未触发私聊事件或 `dmPolicy` 非 pairing | 先确认 `dmPolicy=pairing`，再给机器人发消息 |
| `access not configured` + Pairing code | 账号未批准配对 | 执行 `openclaw pairing approve feishu <CODE>` |
| `EACCES: process.cwd failed` | 在不可访问目录运行 `sudo -u` | 先 `cd /Users/svc_openclaw` 再执行命令 |

## 5) 安全注意
- 密钥只存本机，不提交 Git。
- 修改配置后执行：JSON 校验 -> 权限修复 -> 重启 -> 验收。
- 若密钥泄露，立即轮换并重启服务。
