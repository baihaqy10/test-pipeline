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
            steps('Docker Build') {
                container('dind') {
                    sh 'docker build -t ${PROJECT_NAME}/${SERVICE_NAME}:latest .'
                }
            }
        }
        stage('App Manifest'){
            steps('Project Check'){
                container('builder'){
                    withCredentials([string(credentialsId:'OCP-CRED',usernameVariable: "OCP_USERNAME", passwordVariable: "OCP_PASSWORD")]) {
                        withCredentials([string(credentialsId: 'ocp-api', variable: 'API_OCP')]) {
                            sh 'oc login -u ${OCP_USERNAME} -p ${OCP_PASSWORD} --server=${API_OCP} --insecure-skip-tls-verify'
                            sh 'oc create project ${PROJECT_NAME}'
                            sh 'oc project ${PROJECT_NAME}'
                        }
                    }
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