FROM public.ecr.aws/docker/library/node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

FROM public.ecr.aws/docker/library/node:18-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app /app

USER appuser

# set default port - can be overridden by environment
ENV PORT=8001

EXPOSE 8001

# start the service using the entry point in src
CMD ["node", "src/index.js"]
