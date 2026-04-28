FROM jenkins/jenkins:lts-jdk17

USER root

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# Agregar repo oficial Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  bookworm stable" \
  > /etc/apt/sources.list.d/docker.list

# Instalar versión moderna
RUN apt-get update && \
    apt-get install -y docker-ce-cli

USER jenkins