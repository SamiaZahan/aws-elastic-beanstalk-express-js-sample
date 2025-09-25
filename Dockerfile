# Simple container for the Express sample app
FROM node:18-alpine

WORKDIR /app

# Install deps
COPY package*.json ./
RUN npm ci --omit=dev || npm install --omit=dev

# Copy app
COPY . .

# The sample usually uses PORT env or 8081 by default
EXPOSE 8081

# Start the app (uses "start" from package.json)
CMD ["npm","start"]
