pipeline {
    agent {
        environment {
            PROJECT_NAME = "first-project"
            SERVICE_NAME = "first-app"
        }
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
                        sh "docker login -u admin -p ${OCP_TOKEN} ${NEXUS_URL}"
                        sh 'docker build -t ${NEXUS_URL_HOSTED}/${NEXUS_PROJECT}/${NEXUS_SERVICE}:latest .'
                        sh 'docker tag my-web-app:latest ${NEXUS_URL}/web-uat/my-web-app:latest'
                        sh 'docker push ${NEXUS_URL}/web-uat/my-web-app:latest'
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                container('builder') {
                    withCredentials([string(credentialsId: 'OCP_TOKEN', variable: 'OCP_TOKEN')]) {
                        sh 'oc login --token=${OCP_TOKEN} --server=${API_OCP} --insecure-skip-tls-verify'
                        sh 'oc project web-uat'
                        sh 'oc apply -f deployment.yaml'
                    }
                }
            }
        }
    }
}