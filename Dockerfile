FROM node:20-alpine

WORKDIR /app

# Chỉ copy package.json trước để tận dụng cache layer
COPY package.json ./

# App không có dependency ngoài, nhưng giữ bước này cho tương lai
RUN npm install --omit=dev || true

COPY vision-proxy.mjs ./

ENV PROXY_PORT=9901
EXPOSE 9901

CMD ["node", "vision-proxy.mjs"]
