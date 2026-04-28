pipeline {
    agent any

    options {
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "webapp"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        NEXUS_DOCKER_HOST = "nexus:8082"
        NEXUS_DOCKER_REPO = "devsecops-webapp"
        NEXUS_CREDENTIALS_ID = "nexus-credentials"
    }

    stages {
        stage('Build Docker image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Run tests') {
            steps {
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test"
            }
        }

        stage('Dependency scan (npm audit)') {
            steps {
                sh '''
                docker run --rm \
                  -v "$WORKSPACE:/workspace" \
                  -w /workspace \
                  node:20-alpine \
                  sh -c "npm ci && npm audit --audit-level=critical"
                '''
            }
        }

        stage('Image scan (Trivy)') {
            steps {
                sh '''
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  aquasec/trivy:latest image \
                  --no-progress \
                  --severity CRITICAL \
                  --exit-code 1 \
                  ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Tag image for Nexus') {
            steps {
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${NEXUS_DOCKER_HOST}/${NEXUS_DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push image to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS_ID}", usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                    sh '''
                    echo "$NEXUS_PASSWORD" | docker login ${NEXUS_DOCKER_HOST} -u "$NEXUS_USERNAME" --password-stdin
                    docker push ${NEXUS_DOCKER_HOST}/${NEXUS_DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker logout ${NEXUS_DOCKER_HOST} || true
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
            docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
            docker rmi ${NEXUS_DOCKER_HOST}/${NEXUS_DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} || true
            '''
        }
    }
}