# Vision Proxy - Usage Guide

## How It Works

```
OpenCode (paste image)
    ↓
Proxy (localhost:9901) - detects image_url parts
    ↓
Gemini Flash Vision - converts image -> descriptive text
    ↓
DeepSeek API - receives text-only, returns normal response
    ↓
OpenCode (displays response)
```

Paste images as usual, and the proxy will process them automatically. No workflow changes are required.

## Setup

### Step 1: Copy the folder to a fixed location

```bash
cp -r vision-proxy ~/vision-proxy
cd ~/vision-proxy
```

### Step 2: Set environment variables

Add this to `~/.zshrc` (or `~/.bashrc`):

```bash
export GEMINI_API_KEY="your_gemini_key"
export DEEPSEEK_API_KEY="your_deepseek_key"
export DEEPSEEK_BASE_URL="https://api.deepseek.com"  # or another URL if you use a different provider
```

Reload:
```bash
source ~/.zshrc
```

### Step 3: Run the proxy

```bash
cd ~/vision-proxy
node vision-proxy.mjs
```

You should see:
```
╔══════════════════════════════════════════════════════╗
║         Vision Proxy for OpenCode + DeepSeek         ║
║  Proxy:    http://localhost:9901/v1                   ║
║  Target:   https://api.deepseek.com                  ║
║  Vision:   Gemini gemini-2.0-flash                   ║
╚══════════════════════════════════════════════════════╝
```

### Step 4: Configure OpenCode

In `opencode.json`, add or update the DeepSeek provider to point to the proxy:

```jsonc
{
  "provider": {
    "deepseek": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:9901/v1",
        "apiKey": "your_deepseek_key"
      },
      "models": {
        "deepseek/deepseek-chat": {
          "name": "DeepSeek V4 (with Vision Proxy)",
          "modalities": {
            "input": ["text", "image"],
            "output": ["text"]
          }
        }
      }
    }
  }
}
```

IMPORTANT: set `"input": ["text", "image"]` so OpenCode sends image parts to the provider instead of rejecting them.

### Step 5: Test

Open OpenCode, switch to a DeepSeek model, and paste an image. The proxy should log:
```
[proxy] Detected images in request, processing with Gemini...
[proxy] Processing image (image/png, 245KB)...
[proxy] Image analyzed (1523 chars)
[proxy] Images converted to text, forwarding to DeepSeek
```

## Run the Proxy as a Background Service

### Using pm2:
```bash
npm install -g pm2
pm2 start ~/vision-proxy/vision-proxy.mjs --name vision-proxy
pm2 save
pm2 startup  # auto-start on boot
```

### Or using launchd (native macOS):

```bash
cat > ~/Library/LaunchAgents/com.vision-proxy.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.vision-proxy</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/node</string>
    <string>/Users/YOUR_USERNAME/vision-proxy/vision-proxy.mjs</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>GEMINI_API_KEY</key>
    <string>your_key</string>
    <key>DEEPSEEK_API_KEY</key>
    <string>your_key</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/vision-proxy.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/vision-proxy.log</string>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.vision-proxy.plist
```

## Troubleshooting

**"Cannot process images" still appears:**
- Check whether `modalities.input` includes `"image"` -> OpenCode needs to know the provider accepts images.
- Check that the proxy is running: `curl http://localhost:9901/v1/models`

**Proxy shows Gemini errors:**
- Check that `GEMINI_API_KEY` is valid.
- If rate-limited, try `GEMINI_MODEL=gemini-2.5-flash`.

**Response is slow:**
- Gemini takes around 1-3s to analyze images, plus DeepSeek response time.
- Large images are slower (resize first if needed).

## Full Config (Example)

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "deepseek-vision": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:9901/v1",
        "apiKey": "your_deepseek_key"
      },
      "models": {
        "deepseek-vision/deepseek-v4-flash": {
          "name": "DeepSeek V4 Flash + Vision",
          "modalities": {
            "input": ["text", "image"],
            "output": ["text"]
          }
        },
        "deepseek-vision/deepseek-v4-pro": {
          "name": "DeepSeek V4 Pro + Vision",
          "modalities": {
            "input": ["text", "image"],
            "output": ["text"]
          }
        }
      }
    }
  },
  "model": "deepseek-vision/deepseek-v4-pro"
}
```
