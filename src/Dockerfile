# --- Build Stage ---
FROM node:20-slim AS builder

WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# --- Production Stage ---
FROM node:20-slim

WORKDIR /usr/src/app

# Copy dependencies from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
# Copy the application code from the builder stage
COPY --from=builder /usr/src/app .

EXPOSE 8080

CMD [ "node", "index.js" ]
