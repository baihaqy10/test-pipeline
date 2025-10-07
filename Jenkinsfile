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
        OCP_REG = "image-registry.openshift-image-registry.svc:5000"
    }
    stages {
        stage('Build') {
            steps('Docker Build') {
                container('dind') {
                    sh 'docker build -t ${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest .'
                }
            }
        }
        stage('APP Manifest') {
            steps {
                sh """
                oc login -u admin -p ${OCP_PASSWORD} --SERVER=${API_OCP} --insecure-skip-tls-verify=true
                if ! oc get project ${NAMESPACE} >/dev/null 2>&1; then
                    oc new-project ${NAMESPACE} --description="Project for ${APP_NAME}"
                fi
                """
            }
        }
        stage('Release'){
            steps('Push OCP Registry') {
                container('dind'){
                    sh 'docker login -u admin -p ${OCP_PASSWORD} ${OCP_REG} --insecure-skip-tls-verify'
                    sh 'docker push ${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest'
                }
            }
        }
        stage('deploy') {
            steps {
                sh """
                export PATH=\$WORKSPACE/bin:\$PATH
                helm upgrade --install ${APP_NAME} ./helm-chart \\
                  --set image.repository=image-registry.openshift-image-registry.svc:5000/${NAMESPACE}/${SERVICE_NAME} \\
                  --set image.tag=latest \\
                  -n ${NAMESPACE} --create-namespace
                """
            }
        }
    }
}