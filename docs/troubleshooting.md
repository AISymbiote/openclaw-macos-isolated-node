# 故障排查（现象 -> 原因 -> 处理）

## 1) 服务不启动
- 现象：`launchctl print` 显示未运行。
- 原因：启动命令错误、配置缺失、依赖未安装。
- 处理：先看 `stderr.log` 首条阻断错误，再修配置并重启。

## 2) 端口被占用
- 现象：日志提示 `address already in use`。
- 原因：其他进程占用同端口。
- 处理：调整端口并重启，复查监听。

## 3) 权限错误
- 现象：`permission denied` / watcher `EACCES`。
- 原因：配置文件属主或权限不正确。
- 处理：
```bash
sudo chown svc_openclaw:staff /Users/svc_openclaw/.openclaw/openclaw.json
sudo chmod 600 /Users/svc_openclaw/.openclaw/openclaw.json
sudo launchctl kickstart -k system/com.openclaw.service
```

## 4) `Unknown model: anthropic/...`
- 现象：模型找不到，且错误里出现 `anthropic/<你的模型>`。
- 原因：`primary` 未写 provider，触发默认回退。
- 处理：把 `agents.defaults.model.primary` 改成 `openai/<model>`。

## 5) `baseURL` 无效
- 现象：`Unrecognized key: "baseURL"` 或 `baseUrl expected string`。
- 原因：字段名写错（`baseURL`）。
- 处理：改为 `baseUrl`，并补全 `models.providers.openai.models[]`。

## 6) `No pending feishu pairing requests`
- 现象：`openclaw pairing list feishu` 为空。
- 原因：
  - `dmPolicy` 不是 `pairing`；
  - 未给机器人发送私聊触发事件；
  - 飞书事件订阅/权限/发布未生效。
- 处理：按 `docs/config-reference.md` 的飞书顺序逐项核对。

## 7) `access not configured` + Pairing code
- 现象：机器人返回 pairing code。
- 原因：账号尚未授权。
- 处理：
```bash
sudo -u svc_openclaw zsh -lc 'cd /Users/svc_openclaw && export HOME=/Users/svc_openclaw PATH=/Users/svc_openclaw/.local/npm/bin:$PATH; openclaw pairing approve feishu <CODE>'
```

## 8) `uv_cwd EACCES`
- 现象：`Error: EACCES: process.cwd failed`。
- 原因：`sudo -u svc_openclaw` 在服务用户无权限目录执行。
- 处理：先 `cd /Users/svc_openclaw` 再执行 OpenClaw CLI，或使用 `scripts/safe-openclaw-cli.sh`。

## 9) `pyenv: cannot rehash` 噪音
- 现象：运行前出现 `pyenv` 提示。
- 原因：当前 shell 初始化脚本副作用。
- 处理：一般不影响 OpenClaw 运行，可先忽略；若要消除，修用户 shell 初始化配置。

## 10) 渠道消息收不到
- 现象：机器人不回消息。
- 原因：平台权限未开、事件未生效、版本未发布、allowlist 未放行。
- 处理：
  1. `openclaw channels status --probe`
  2. 检查飞书权限与发布
  3. 校验 `dmPolicy/allowFrom`

## 11) 重启后未自动拉起
- 现象：开机后服务未运行。
- 原因：LaunchDaemon 未正确 bootstrap/enable。
- 处理：重新 bootstrap + enable，检查 plist 权限（`root:wheel 644`）。

## 12) 升级后异常
- 现象：升级后启动失败或行为异常。
- 原因：版本变更引入配置不兼容。
- 处理：回滚到上一版本 + 恢复配置备份，再做差异比对。
