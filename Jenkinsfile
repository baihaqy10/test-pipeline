pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: builder
    image: 'jenkins/jnlp-slave:latest' # Pulling from Docker Hub
    command: ['/bin/cat']
    tty: true
  - name: dind
    image: 'docker:dind'
    securityContext:
      privileged: true
'''
        }
    }
    stages {
        stage('Build Image') {
            steps {
                container('dind') {
                    sh 'docker build -t my-web-app:latest .'
                    sh 'docker tag my-web-app:latest default-route-openshift-image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                    sh 'docker login -u admin -p tVG0ohOeazwPmvsF default-route-openshift-image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io'
                    sh 'docker push default-route-openshift-image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                }
            }
        }
        stage('Deploy to OCP') {
            steps {
                container('builder') {
                    sh 'oc apply -f deployment.yaml'
                }
            }
        }
    }
}