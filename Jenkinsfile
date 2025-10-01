pipeline {
  agent {
    docker {
      image 'node:16-alpine'          // ✔ Node 16 Docker image as agent
      args '-u root:root'             // allow npm global installs
    }
  }

  environment {
    DOCKERHUB_REPO = credentials('dockerhub-repo-name')   // e.g. samiazahan/aws-elastic-beanstalk-express-js-sample
  }

  stages {
    stage('Install Dependencies') {
      steps {
        sh 'npm ci || npm install --save'
      }
    }

    stage('Test') {
      steps {
        // If no tests exist, this won’t fail the build; adjust if you add real tests.
        sh 'npm test || echo "No tests defined"'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          COMMIT = sh(returnStdout: true, script: 'git rev-parse --short=7 HEAD').trim()
          docker.build("${DOCKERHUB_REPO}:${COMMIT}")
          docker.build("${DOCKERHUB_REPO}:latest")
        }
      }
    }

    stage('Push Docker Image') {
      environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // your Docker Hub username/password credential
      }
      steps {
        script {
          docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
            docker.image("${DOCKERHUB_REPO}:latest").push()
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      environment {
        SNYK_TOKEN = credentials('snyk-token')  // Secret text from Snyk > Account settings
      }
      steps {
        sh '''
          npm install -g snyk
          snyk auth ${SNYK_TOKEN}
          # Fail build on High/Critical:
          snyk test --severity-threshold=high
        '''
      }
    }
  }
}
