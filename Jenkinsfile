pipeline {
    agent any

    options {
        timeout(time: 5, unit: 'MINUTES')
    }

    environment {
        DOCKER_API_VERSION = "1.42" // Para solucionar el error de versión
        NEXUS_URL = "http://nexus:8083"
        NEXUS_HOST = "nexus:8083"
        CREDENTIALS_ID = "nexus-cred" // Revisa que este ID exista en Jenkins -> Credentials
        IMAGE_NAME = "sumador"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        NEXUS_REPO = "repository/docker-hosted" 
        FULL_IMAGE = "${NEXUS_HOST}/${NEXUS_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Run tests') {
            steps {
                // Ejecuta los tests dentro del contenedor recién creado
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test"
            }
        }
        
        stage('Tag & Deploy') {
            steps {
                script {
                    // Taggeo manual para asegurar que use el nombre correcto
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}"
                    
                    withCredentials([usernamePassword(credentialsId: CREDENTIALS_ID, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh """
                        docker login ${NEXUS_URL} -u ${USER} -p ${PASS}
                        docker push ${FULL_IMAGE}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE} || true"
        }
    }
}