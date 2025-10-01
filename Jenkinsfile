pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = credentials('dockerhub-repo-name')
        SNYK_TOKEN = credentials('snyk-token')
    }


    stages {
        stage('Install Dependencies') {
            steps {
                nodejs(nodeJSInstallationName: 'Node16') {
                    sh 'npm install --save'
                }
            }
        }

        stage('Test') {
            steps {
                nodejs(nodeJSInstallationName: 'Node16') {
                    sh 'npm test || true'
                }
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
                    docker.withRegistry('', 'dockerhub-creds') {
                        docker.image("${DOCKERHUB_REPO}").push("latest")
                    }
                }
            }
        }



        stage('Snyk Security Scan') {
            steps {
                nodejs(nodeJSInstallationName: 'Node16') {
                    sh '''
                    npm install -g snyk
                    snyk auth ${SNYK_TOKEN}
                    snyk test --severity-threshold=high || true
                    '''
                }
            }
        }
        stage('Archive Artifacts') {
          steps {
            archiveArtifacts artifacts: 'package.json, package-lock.json, **/npm-debug.log, .snyk, snyk-result.json', allowEmptyArchive: true
          }
        }

    }

}
