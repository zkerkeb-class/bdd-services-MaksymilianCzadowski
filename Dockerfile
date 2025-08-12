# Build stage
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Development stage
FROM node:20-alpine AS development

WORKDIR /usr/src/app

# Install all dependencies (including dev dependencies)
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3001

# Start application in development mode
CMD ["npm", "run", "start:dev"]

# Production stage
FROM node:20-alpine AS production

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set environment variables
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV} \
    PORT=3001

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy built application from builder
COPY --from=builder /usr/src/app/dist ./dist

# Set permissions
RUN chown -R appuser:appgroup /usr/src/app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/api/v1/health || exit 1

# Start application
CMD ["node", "dist/main"] 