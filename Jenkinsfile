pipeline {
    agent any

    options {
        timeout(time: 10, unit: 'MINUTES')
    }

    environment {
        IMAGE_NAME = "sumador"
        IMAGE_TAG = "${BUILD_NUMBER}"

        // nombre del servicio docker-compose
        NEXUS_HOST = "nexus:8083"

        // repo docker hosted creado en Nexus
        NEXUS_REPO = "repository/docker-hosted"

        FULL_IMAGE = "${NEXUS_HOST}/${NEXUS_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

        CREDENTIALS_ID = "nexus-cred"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Security - npm audit') {
            steps {
                sh 'npm audit --audit-level=critical || true'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}
                """
            }
        }

        stage('Security - Trivy Scan') {
            steps {
                sh """
                docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy image \
                --severity CRITICAL \
                --exit-code 0 \
                ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Push to Nexus') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${CREDENTIALS_ID}",
                        usernameVariable: 'admin',
                        passwordVariable: 'caracolesdemar2'
                    )
                ]) {
                    sh """
                    docker login http://${NEXUS_HOST} -u $USER -p $PASS
                    docker push ${FULL_IMAGE}
                    """
                }
            }
        }
    }

    post {
        always {
            sh """
            docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
            docker rmi ${FULL_IMAGE} || true
            """
        }

        success {
            echo "Pipeline OK"
        }

        failure {
            echo "Pipeline FAILED"
        }
    }
}