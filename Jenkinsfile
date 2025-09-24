pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKERHUB_REPO = credentials('dockerhub-repo-name')
        SNYK_TOKEN = credentials('snyk-token')
    }

    tools {
        nodejs 'Node16'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKERHUB_REPO}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        docker.image("${DOCKERHUB_REPO}").push("latest")
                    }
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                sh '''
                npm install -g snyk
                snyk auth ${SNYK_TOKEN}
                snyk test --severity-threshold=high || true
                '''
            }
        }
    }
}
