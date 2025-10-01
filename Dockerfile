# Simple container for the Express sample app
FROM node:16-alpine

WORKDIR /app

# Install deps
COPY package*.json ./
RUN npm ci --only=production

# Copy app
COPY . .

# The sample usually uses PORT env or 8081 by default
EXPOSE 8081

# Start the app
CMD ["node", "app.js"]
