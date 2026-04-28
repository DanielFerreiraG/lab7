pipeline {
    agent any

    environment {
        IMAGE_NAME = "sumador"
        IMAGE_TAG = "${BUILD_NUMBER}"
        // Usamos el nombre del servicio definido en docker-compose
        NEXUS_HOST = "nexus:8083" 
        NEXUS_REPO = "repository/docker-hosted"
        FULL_IMAGE = "${NEXUS_HOST}/${IMAGE_NAME}:${IMAGE_TAG}"
        CREDENTIALS_ID = "nexus-cred"
    }

    stages {
        stage('Install & Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }

        stage('Security - npm audit') {
            steps {
                // Falla si hay vulnerabilidades críticas en dependencias
                sh 'npm audit --audit-level=critical'
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Security - Trivy Scan') {
            steps {
                // Escaneamos la imagen local recién construida
                // --exit-code 1 hace que el pipeline falle si detecta CRITICAL
                sh """
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    aquasec/trivy image \
                    --severity CRITICAL \
                    --exit-code 1 \
                    ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Push to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${CREDENTIALS_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}
                    docker login http://${NEXUS_HOST} -u $USER -p $PASS
                    docker push ${FULL_IMAGE}
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Limpieza para que el laboratorio sea reproducible (Punto de restricciones)
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE} || true"
        }
    }
}