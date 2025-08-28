pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // Langkah build Anda
                sh 'echo Building...'
            }
        }
        stage('Deploy') {
            steps {
                // Langkah deploy ke OpenShift
                sh 'oc apply -f deployment.yaml'
            }
        }
    }
}
