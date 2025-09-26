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
    image: 'docker:24-cli'
    securityContext:
      privileged: true
'''
        }
    }
    stages {
        stage('Build') {
            steps {
                container('dind') {
                    withCredentials([string(credentialsId: 'nexus-hosted', variable: 'NEXUS_HOSTED')])
                    withCredentials([string(credentialsId: 'nexus-secret', 
                    usernameVariable: "NEXUS_USERNAME",
                    passwordVariable: "NEXUS_PASSWORD")]) {
                        sh "docker login -u ${NEXUS_USERNAME} -p ${NEXUS_PASSWORD} ${NEXUS_HOSTED}"
                        sh 'docker build -t ${NEXUS_HOSTED}/${NEXUS_PROJECT}/${NEXUS_SERVICE}:latest .'
                        sh 'docker push ${NEXUS_HOSTED}/${NEXUS_PROJECT}/${NEXUS_SERVICE}:latest'
                    }
                }
            }
        }
        stage('Release') {
            steps {
                container()
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