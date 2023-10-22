# the image used Node which contains version 14 of Node and NPM
FROM node:14

WORKDIR /app

# this file holds declaration for packages
COPY package*.json ./

# Install npm packages
RUN npm install

# Copy application files into the container
COPY . .

# Expose the port 3000 for node app to work
ENV WEBport 3000

# Set MongoDB user, password, and hosts
ENV DBuser test
ENV DBpass test123
ENV DBhosts mongo-0.mongo:27017

# Start your application
CMD ["node", "index.js"]
