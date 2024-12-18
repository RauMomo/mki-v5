# FROM node:20-alpine

# # Install system dependencies
# RUN apk update && apk add --no-cache \
#     build-base \
#     gcc \
#     autoconf \
#     automake \
#     zlib-dev \
#     libpng-dev \
#     nasm \
#     bash \
#     vips-dev \
#     git

# # Set environment variables
# ARG NODE_ENV=development
# ENV NODE_ENV=${NODE_ENV}

# # Set working directory
# WORKDIR /opt/

# # Copy package files and install dependencies
# COPY ./package.json ./yarn.lock ./
# RUN npm install -g node-gyp
# RUN yarn config set network-timeout 600000 -g && yarn install

# # Update PATH to include node_modules/.bin
# ENV PATH /opt/node_modules/.bin:$PATH

# # Copy application code
# WORKDIR /opt/app
# COPY ./ .

# # Set correct ownership and switch to non-root user
# RUN chown -R node:node /opt/app
# USER node

# # Build the project
# RUN yarn build

# # Expose port
# EXPOSE 1337

# # Start the application
# CMD ["yarn", "develop"]


# Creating multi-stage build for production
FROM node:18-alpine as build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1
ENV NODE_ENV=development

WORKDIR /opt/app
COPY package.json package-lock.json ./
RUN npm install --production
ENV PATH /opt/node_modules/.bin:$PATH
COPY . .
RUN npx strapi build
# RUN yarn global add node-gyp
# RUN yarn config set network-timeout 600000 -g && yarn install --production --ignore-engines
# ENV PATH /opt/node_modules/.bin:$PATH
# WORKDIR /opt/app
# COPY . .
# RUN npx strapi build

# Creating final production image
FROM node:18-alpine
RUN apk add --no-cache vips-dev
ENV NODE_ENV=development
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV PATH /opt/node_modules/.bin:$PATH

RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
CMD ["npx", "strapi", "develop"]