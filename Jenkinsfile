pipeline {
    // This agent directive is now more specific
    agent {
        kubernetes {
            // This is the Docker-in-Docker sidecar container
            // It allows 'docker' commands to run inside the agent pod
            containerTemplate {
                name 'dind'
                image 'docker:dind'
                privileged true
                args ''
            }
            // This is your main build container
            containerTemplate {
                name 'builder'
                image 'image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/jenkins/jenkins-builder:latest'
                command '/bin/cat'
                tty true
            }
        }
    }
    stages {
        stage('Build Image') {
            steps {
                container('dind') {
                    // Commands for building the Docker image
                    sh 'docker build -t my-web-app:latest .'
                    sh 'docker tag my-web-app:latest image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                    sh 'docker push image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                }
            }
        }
        stage('Deploy to OCP') {
            steps {
                container('builder') {
                    // Commands for deploying to OpenShift
                    sh 'oc apply -f deployment.yaml'
                }
            }
        }
    }
}