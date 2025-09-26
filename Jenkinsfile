pipeline {
    agent any
    environment {
        PROJECT_NAME = "first-project"
        SERVICE_NAME = "first-service"
        OCP_PASSWORD = credentials('admin-cres')
        API_OCP = credentials('ocp-api')
    }
    stages {
        stage('Build') {
            steps('Docker Build') {
                script {
                    sh 'docker build -t ${PROJECT_NAME}/${SERVICE_NAME}:latest .'
                }
            }
        }
        stage('App Manifest'){
            steps('Project Check'){
                script{
                    sh 'oc login -u admin -p ${OCP_PASSWORD} --server=${API_OCP} --insecure-skip-tls-verify'
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