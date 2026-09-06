FROM node:20-alpine AS builder

WORKDIR /build
RUN apk add --no-cache git

# Clone les deux repos côte à côte (requis)
RUN git clone https://github.com/LuxAlgo/Vela.git vela-core
RUN git clone https://github.com/LuxAlgo/vela-pinets.git vela-pinets

# Build Vela core
WORKDIR /build/vela-core
RUN npm install
RUN npm run build

# Build du playground Vela - on utilise la config inline
RUN npx vite build playground --outDir dist --base /vela/

# Build Vela PineTS
WORKDIR /build/vela-pinets
RUN npm install

# Build du playground PineTS
RUN npx vite build playground --outDir dist --base /vela-pinets/

# Image finale Nginx
FROM nginx:alpine

# Copie les fichiers buildés
COPY --from=builder /build/vela-core/dist /usr/share/nginx/html/vela
COPY --from=builder /build/vela-pinets/dist /usr/share/nginx/html/vela-pinets

# Copie la config Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
