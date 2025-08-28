pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                script {
                    sh 'docker build -t my-web-app:latest .'
                    sh 'docker tag my-web-app:latest image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest' // Ganti URL
                    sh 'docker push image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                }
            }
        }
        stage('Deploy to OCP') {
            steps {
                sh 'oc apply -f deployment.yaml'
            }
        }
    }
}