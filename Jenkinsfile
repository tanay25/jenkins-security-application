pipeline {

    agent any

    environment {
        IMAGE_NAME = "tanay25/jenkins-security-demo"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }
    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    set -e

                    python3 --version

                    python3 -m venv venv

                    . venv/bin/activate

                    python -m pip install --upgrade pip
                    pip install -r requirements.txt

                    pip install bandit pip-audit
                '''
            }
        }

        
       

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

       

        stage('Docker Push') {
            steps {
                sh '''
                    set -e

                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    set -e

                    docker stop flask-security-app || true
                    docker rm flask-security-app || true

                    docker run -d \
                        --name flask-security-app \
                        -p 5000:5000 \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }
}