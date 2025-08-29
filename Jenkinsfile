pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: builder
    image: 'image-registry.openshift-image-registry.svc:5000/openshift/cli'
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
        stage('Build') {
            steps {
                container('dind') {
                    withCredentials([string(credentialsId: 'OCP_TOKEN', variable: 'OCP_TOKEN')]) {
                        sh "docker login -u admin -p ${OCP_TOKEN} default-route-openshift-image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io"
                        sh 'docker build -t my-web-app:latest .'
                        sh 'docker tag my-web-app:latest default-route-openshift-image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                        sh 'docker push default-route-openshift-image-registry.apps.cluster-vk4bt.dynamic.redhatworkshops.io/web-uat/my-web-app:latest'
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                container('builder') {
                    withCredentials([string(credentialsId: 'OCP_TOKEN', variable: 'OCP_TOKEN')]) {
                        sh 'oc login --token=${OCP_TOKEN} --server=https://api.cluster-vk4bt.dynamic.redhatworkshops.io:6443 --insecure-skip-tls-verify'
                        sh 'oc project web-uat'
                        sh 'oc apply -f deployment.yaml'
                    }
                }
            }
        }
    }
}