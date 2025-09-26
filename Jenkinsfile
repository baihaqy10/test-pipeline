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
        OCP_USERNAME = credentials('OCP-CRED')
        OCP_PASSWORD = credentials('OCP-CRED')
        API_OCP = credentials('ocp-api')
    }
    stages {
        stage('Build') {
            steps('Docker Build') {
                container('dind') {
                    sh 'docker build -t ${PROJECT_NAME}/${SERVICE_NAME}:latest .'
                }
            }
        }
        stage('App Manifest'){
            steps('Project Check'){
                container('builder'){
                    sh 'oc login -u ${OCP_USERNAME} -p ${OCP_PASSWORD} --server=${API_OCP} --insecure-skip-tls-verify'
                    sh 'oc create project ${PROJECT_NAME}'
                    sh 'oc project ${PROJECT_NAME}'
                }
            }
        }
        stage('Release'){
            steps('Push OCP Registry') {
                container('builder'){
                    sh 'oc get route -n openshift-image-registry'
                }
            }
        }
    }
}