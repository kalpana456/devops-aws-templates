FROM node:7.9-alpine
MAINTAINER Nauman Hafiz <name@host.com>

# Install dependencies
RUN apk update && apk add git

# Create app directory
RUN mkdir -p /opt/node/app
WORKDIR /opt/node/app

# Install app dependencies
COPY package.json /opt/node/app/
RUN npm install

# Bundle app source
COPY . /opt/node/app/

# Expose environment varibales
ENV BUILD_REGION na
ENV BUILD_VERSION na
ENV BUILD_DATE na
ENV ENVIRONMENT dev

EXPOSE 3000

CMD [ "node", "app.js" ]