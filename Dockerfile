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
# Le vite.config.ts a déjà root: 'playground', donc juste:
RUN npx vite build --base /vela/

# Build Vela PineTS  
WORKDIR /build/vela-pinets
RUN npm install
# Idem, vite.config.ts pointe déjà vers playground
RUN npx vite build --base /vela-pinets/

# Image finale Nginx
FROM nginx:alpine

# Copie les fichiers buildés
COPY --from=builder /build/vela-core/dist /usr/share/nginx/html/vela
COPY --from=builder /build/vela-pinets/dist /usr/share/nginx/html/vela-pinets

# Copie la config Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
