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
                    // Use withCredentials to securely inject the token
                    withCredentials([string(credentialsId: 'OCP_TOKEN', variable: 'OCP_TOKEN')]) {
                        // The 'admin' user is the username, the token is the password
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
                 // Use withCredentials to securely inject the token
                    withCredentials([string(credentialsId: 'OCP_TOKEN', variable: 'OCP_TOKEN')]) {
                        // The 'admin' user is the username, the token is the password
                        sh 'oc login -u admin -p ${OCP_TOKEN} https://api.cluster-vk4bt.dynamic.redhatworkshops.io:6443'
                        sh 'oc apply -f deployment.yaml -n web-uat'
                }
            }
        }
    }
}