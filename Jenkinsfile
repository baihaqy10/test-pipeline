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
                    withCredentials([string(credentialsId: 'nexus-hosted', variable: 'NEXUS_HOSTED')]) {
                        withCredentials([string(credentialsId: 'nexus-group', variable: 'NEXUS_GROUP')]) {
                            withCredentials([usernamePassword(
                            credentialsId: 'nexus-secret', 
                            usernameVariable: "NEXUS_USERNAME",
                            passwordVariable: "NEXUS_PASSWORD")]) {
                                sh "docker login -u ${NEXUS_USERNAME} -p ${NEXUS_PASSWORD} ${NEXUS_GROUP}"
                                sh "docker login -u ${NEXUS_USERNAME} -p ${NEXUS_PASSWORD} ${NEXUS_HOSTED}"
                                sh "docker build -t ${NEXUS_HOSTED}/${PROJECT_NAME}/${SERVICE_NAME}:latest ."
                                sh "docker push ${NEXUS_HOSTED}/${PROJECT_NAME}/${SERVICE_NAME}:latest"
                            }
                        }
                    }
                }
            }
        }
        stage('Release') {
            steps {
                container('builde') {
                    withCredentials([string(credentialsId: 'OCP-CRED',
                    usernameVariable: "OCP_USERNAME",
                    passwordVariable: "OCP_PASSWORD")]) {
                        sh 'oc login --token=${OCP_TOKEN} --server=${API_OCP} --insecure-skip-tls-verify'
                        sh 'oc login --token=${OCP_TOKEN} --server=${API_OCP} --insecure-skip-tls-verify'
                        sh 'oc login --token=${OCP_TOKEN} --server=${API_OCP} --insecure-skip-tls-verify'
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