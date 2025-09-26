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
        OCP_PASSWORD = credentials('admin-cres')
        API_OCP = credentials('ocp-api')
        OCP_REG = credentials('ocp-registry')
    }
    stages {
        stage('Build') {
            steps('Docker Build') {
                container('dind') {
                    sh 'docker build -t ${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest .'
                }
            }
        }
        stage('App Manifest'){
            steps {
                container('builder'){
                    sh 'oc login -u admin -p ${OCP_PASSWORD} --server=${API_OCP} --insecure-skip-tls-verify'
                    sh 'oc project ${PROJECT_NAME}'
                    def projectExist = sh(script: "oc get projects | grep -q ${PROJECT_NAME}", returnStdout: true).trim().isEmpty()
                    if (projectExist) {
                        sh 'oc create namespace ${PROJECT_NAME}'
                    }
                }
            }
        }
        stage('Release'){
            steps('Push OCP Registry') {
                container('dind'){
                    sh 'docker push ${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest'
                }
            }
        }
    }
}