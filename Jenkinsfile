pipeline {

    agent any

    environment {
        IMAGE_NAME="tanay25/jenkins-security-demo"
        IMAGE_TAG="${BUILD_NUMBER}"
    }
    stages {

        stage('checkout'){
            steps {
                checkout scm
            }
        }
        stage("Install Dependencies"){
            steps {
                sh '''
            python3 --version

            python3 -m venv venv
            . venv/bin/activate

            pip install --upgrade pip
            pip install -r requirements.txt
        '''
            }
        }
        stage("Unit Testing"){
            steps{
                sh '''
                    . venv/bin/activate
                    bandit -r . -x ./venv -f txt

                '''
            }
        }
        stage('Dependency Security Scan'){
            steps {
                sh '''
                    ./venv/bin/activate
                    pip-audit

                '''
            }
        }
        stage('SonarQube Analysis'){
            steps {
                withSonarQubeEnv('sonarqube'){
                    sh '''
                        sonal-scanner -Dsonar.projectKey=jenkins-security -Dsonar.sources=.

                    '''
                }
            }
        }
        stage('Docker Build'){
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }
        stage('Trivy Image Scan'){
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL --exit-code=1 ${IMAGE_NAME}:${IMAGE_TAG}

                '''
            }
        }
        stage('Docker Login'){
            steps{
                withCredentials([usernamePassword(credentialId:'dockerhub',usernameVariable:'DOCKER_USER',passwordVariable:'DOCKER_PASSWORD')]){
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }
        stage('Docker Push'){
            steps {
                sh '''
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}

                '''
            }
        }
        stage('Deploy'){
            steps {
                sh '''
                    docker stop flask-security-app || true
                    docker rm flask-security-app || true
                    docker run -d --name flask-security-app -p 5000:5000 ${IMAGE_NAME}:${IMAGE_TAG}

                '''
            }
        }
    }
}