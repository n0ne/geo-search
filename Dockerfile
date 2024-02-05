#
# 🧑‍💻 Development
#
FROM node:18-alpine as dev
# add the missing shared libraries from alpine base image
# RUN apk add --no-cache libc6-compat
# Create app folder
WORKDIR /app

COPY tsconfig*.json ./
COPY package*.json ./

RUN npm ci

# Set to dev environment
ENV NODE_ENV dev

# Create non-root user for Docker
# RUN addgroup --system --gid 1001 node
# RUN adduser --system --uid 1001 node

# Copy source code into app folder
COPY --chown=node:node . .

# COPY src/auth/pb/auth.proto /app/src/auth/pb/
COPY --chown=node:node src/auth/pb/auth.proto /app/src/auth/pb/auth.proto

# RUN touch /app/testfile && ls /app

RUN npx prisma generate && npm install

# Install dependencies
# RUN yarn --frozen-lockfile
# RUN npm install

# Set Docker as a non-root user
USER node

#
# 🏡 Production Build
#
FROM node:18-alpine as build

WORKDIR /app
# RUN apk add --no-cache libc6-compat

# Set to production environment
ENV NODE_ENV production

# Re-create non-root user for Docker
# RUN addgroup --system --gid 1001 node
# RUN adduser --system --uid 1001 node

# In order to run `yarn build` we need access to the Nest CLI.
# Nest CLI is a dev dependency.
COPY --chown=node:node --from=dev /app/node_modules ./node_modules
# Copy source code
COPY --chown=node:node . .

COPY --chown=node:node src/auth/pb/auth.proto /app/src/auth/pb/auth.proto

# Generate the production build. The build script runs "nest build" to compile the application.
# RUN yarn build
RUN npm run build

# Install only the production dependencies and clean cache to optimize image size.
# RUN yarn --frozen-lockfile --production && yarn cache clean
RUN npm ci --only=production --omit=dev && npm cache clean --force

# Set Docker as a non-root user
USER node

#
# 🚀 Production Server
#
FROM node:18-alpine as prod

WORKDIR /app
# RUN apk add --no-cache libc6-compat

# Set to production environment
ENV NODE_ENV production

# Re-create non-root user for Docker
# RUN addgroup --system --gid 1001 node
# RUN adduser --system --uid 1001 node

# Copy only the necessary files
COPY --chown=node:node --from=build /app/dist dist
COPY --chown=node:node --from=build /app/node_modules node_modules
COPY --chown=node:node --from=build /app/src/auth/pb/auth.proto /app/src/auth/pb/auth.proto

# Set Docker as non-root user
USER node

EXPOSE 50051

CMD ["node", "dist/main.js"]


# # Building layer
# FROM node:18-alpine as development

# # Optional NPM automation (auth) token build argument
# # ARG NPM_TOKEN

# # Optionally authenticate NPM registry
# # RUN npm set //registry.npmjs.org/:_authToken ${NPM_TOKEN}

# WORKDIR /app

# # Copy configuration files
# COPY tsconfig*.json ./
# COPY package*.json ./

# # Install dependencies from package-lock.json, see https://docs.npmjs.com/cli/v7/commands/npm-ci
# RUN npm ci

# # Copy application sources (.ts, .tsx, js)
# COPY src/ src/
# COPY prisma/ prisma/

# # Build application (produces dist/ folder)
# RUN npm run build

# # Runtime (production) layer
# FROM node:18-alpine as production

# # Optional NPM automation (auth) token build argument
# # ARG NPM_TOKEN

# # Optionally authenticate NPM registry
# # RUN npm set //registry.npmjs.org/:_authToken ${NPM_TOKEN}

# WORKDIR /app

# # Copy dependencies files
# COPY package*.json ./

# # Install runtime dependecies (without dev/test dependecies)
# RUN npm ci --omit=dev

# # Copy production build
# COPY --from=development /app/dist/ ./dist/

# # Expose application port
# EXPOSE 3000

# # Start application
# CMD [ "node", "dist/main.js" ]
