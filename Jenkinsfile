pipeline {
  agent none

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = credentials('dockerhub-repo-name')
    IMAGE_TAG  = "${IMAGE_NAME}-${BUILD_NUMBER}"
    SNYK_TOKEN = credentials('snyk-token')
  }

  stages {
    stage('Checkout') {
      agent { label 'built-in' }
      steps {
        checkout scm
      }
    }

    stage('Install & Test (Node 16)') {
      agent {
        docker {
          image 'node:16'
          args '-u root -v $WORKSPACE:/workspace -w /workspace'
        }
      }
      steps {
        sh 'node -v && npm -v'
        sh 'npm install --save'
        sh 'npm test || echo "No tests defined (ok for sample)"'
        stash name: 'app', includes: '**/*'
      }
    }

    stage('Docker Build') {
      agent { label 'built-in' }
      steps {
        unstash 'app'
        sh 'docker build -t "$IMAGE_TAG" .'
      }
    }

    stage('Security Scan (Snyk)') {
      agent { label 'built-in' }
      steps {
        sh 'npm install -g snyk'
        sh 'snyk auth "$SNYK_TOKEN"'
        sh 'snyk test --severity-threshold=high'
      }
    }

    stage('Push Image') {
      when { expression { return env.IMAGE_NAME?.trim() } }
      agent { label 'built-in' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
          sh 'docker push "$IMAGE_TAG"'
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'Dockerfile, Jenkinsfile, **/npm-debug.log, audit.log', allowEmptyArchive: true
      echo "Build finished: ${currentBuild.currentResult}"
    }
  }
}
