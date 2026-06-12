#!/bin/bash
# Quick start script for Vision Proxy
# Run: ./start.sh

export GEMINI_API_KEY="${GEMINI_API_KEY:-}"
export DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY:-}"
export DEEPSEEK_BASE_URL="${DEEPSEEK_BASE_URL:-https://api.deepseek.com}"
export GEMINI_MODEL="${GEMINI_MODEL:-gemini-2.0-flash}"
export PROXY_PORT="${PROXY_PORT:-9901}"

if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: Set GEMINI_API_KEY first"
  echo "  export GEMINI_API_KEY=your_key"
  exit 1
fi

if [ -z "$DEEPSEEK_API_KEY" ]; then
  echo "ERROR: Set DEEPSEEK_API_KEY first"
  echo "  export DEEPSEEK_API_KEY=your_key"
  exit 1
fi

node "$(dirname "$0")/vision-proxy.mjs"
