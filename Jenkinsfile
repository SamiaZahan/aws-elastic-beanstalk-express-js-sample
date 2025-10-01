pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    DOCKERHUB_REPO        = credentials('dockerhub-repo-name')
    SNYK_TOKEN            = credentials('snyk-token')
  }

  stages {
    stage('Install Dependencies') {
      steps {
        nodejs('Node16') {
          sh 'npm ci || npm install --save'
        }
      }
    }

    stage('Test') {
      steps {
        nodejs('Node16') {
          sh 'npm test || true'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // build in current workspace; DOCKER_HOST points to DinD
          docker.build("${DOCKERHUB_REPO}")
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
            docker.image("${DOCKERHUB_REPO}").push('latest')
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      steps {
        nodejs('Node16') {
          sh '''
            npm install -g snyk
            snyk auth ${SNYK_TOKEN} || true
            snyk test --severity-threshold=high || true
          '''
        }
      }
    }
  }
}
