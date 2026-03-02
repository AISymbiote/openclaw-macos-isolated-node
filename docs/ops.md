# 日常运维 Runbook

## 1) 重启后自检（30 秒）
```bash
sudo launchctl print system/com.openclaw.service | grep -E "state =|pid ="
lsof -nP -iTCP:3030 -sTCP:LISTEN
```

## 2) 常用命令
```bash
# 查看状态（用户执行 / Agent 代执行）
sudo launchctl print system/com.openclaw.service

# 重启服务（用户执行 / Agent 代执行）
sudo launchctl kickstart -k system/com.openclaw.service

# 停止服务（用户执行 / Agent 代执行）
sudo launchctl bootout system /Library/LaunchDaemons/com.openclaw.service.plist

# 启动服务（用户执行 / Agent 代执行）
sudo launchctl bootstrap system /Library/LaunchDaemons/com.openclaw.service.plist
sudo launchctl enable system/com.openclaw.service

# 以服务用户安全执行 openclaw 命令（避免 uv_cwd EACCES）
bash scripts/safe-openclaw-cli.sh channels status --probe
```

## 3) 改配置流程（备份 -> 修改 -> 校验 -> 重启 -> 验收）
```bash
# 1) 备份
cp /Users/svc_openclaw/.openclaw/openclaw.json /Users/svc_openclaw/.openclaw/openclaw.json.bak.$(date +%Y%m%d%H%M%S)

# 2) 修改
# vi /Users/svc_openclaw/.openclaw/openclaw.json

# 3) JSON 校验
python3 -m json.tool /Users/svc_openclaw/.openclaw/openclaw.json >/dev/null && echo OK

# 4) 权限修复
sudo chown svc_openclaw:staff /Users/svc_openclaw/.openclaw/openclaw.json
sudo chmod 600 /Users/svc_openclaw/.openclaw/openclaw.json

# 5) 重启
sudo launchctl kickstart -k system/com.openclaw.service

# 6) 验收
sudo launchctl print system/com.openclaw.service | grep -E "state =|pid ="
lsof -nP -iTCP:3030 -sTCP:LISTEN
```

## 4) 飞书专项检查
```bash
bash scripts/check-feishu.sh
```

## 5) 升级与回滚
- 升级前记录当前 commit/tag。
- 升级后先做最小验收（状态、端口、日志、一次对话）。
- 如失败，回退到上一版本并重启服务。
- 保留配置备份，避免参数丢失。

## 6) 日志阅读规范
1. 先看“本次重启后的最近日志”，不要先看历史噪音。
2. 优先看阻断错误：`Config invalid` / `Unknown model` / `No API key` / 权限拒绝。
3. `duplicate plugin id` 常见于插件重复来源，通常是非阻断警告。
