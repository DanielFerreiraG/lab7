FROM jenkins/jenkins:lts

USER root

# instalar dependencias base
RUN apt-get update && apt-get install -y \
    ca-certificates curl gnupg lsb-release

# instalar Node.js (npm)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# instalar Docker CLI moderno
RUN mkdir -p /etc/apt/keyrings

RUN curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian bullseye stable" \
  > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y docker-ce-cli