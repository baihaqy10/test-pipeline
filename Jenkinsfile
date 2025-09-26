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
    environment {
        PROJECT_NAME = "first-project"
        SERVICE_NAME = "first-service"
    }
    stages {
        stage('Build') {
            steps {
                container('dind') {
                    sh "docker build -t ${NEXUS_HOSTED}/${PROJECT_NAME}/${SERVICE_NAME}:latest ."
                        }
                    }
                }
            }
        }
        stage('Release') {
            steps {
                container('builder') {
                    withCredentials([string(credentialsId: 'OCP-CRED',
                    usernameVariable: "OCP_USERNAME",
                    passwordVariable: "OCP_PASSWORD")]) {
                        withCredentials([string(credentialsId: 'ocp-api', variable: 'API_OCP')]){
                            sh 'oc login -u ${OCP_USERNAME} -p ${OCP_PASSWORD} --server=${API_OCP} --insecure-skip-tls-verify'
                            SH 'oc get pod -n jenkins'
                        }
                    }                    
                }
            }
        }
        stage('Deploy') {
            steps {
                container('builder') {
                    withCredentials([string(credentialsId: 'OCP_TOKEN', variable: 'OCP_TOKEN')]) {
                        withCredentials([string(credentialsId: 'ocp-api', variable: 'API_OCP')]) {
                            sh 'oc login --token=${OCP_TOKEN} --server=${API_OCP} --insecure-skip-tls-verify'
                            sh 'oc project web-uat'
                            sh 'oc apply -f deployment.yaml'
                        }
                    }
                }
            }
        }
    }
}