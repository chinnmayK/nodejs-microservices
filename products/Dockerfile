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

# default port for products service
ENV PORT=8002

EXPOSE 8002

CMD ["node", "src/index.js"]
