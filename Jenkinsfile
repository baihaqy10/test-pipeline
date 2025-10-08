pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  nodeSelector:
    kubernetes.io/hostname: worker-cluster-5l9jh-1
  serviceAccount: 'jenkins'
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
        API_OCP = "https://api.cluster-5l9jh.dynamic.redhatworkshop.io:6443"
        OCP_REG = "image-registry.openshift-image-registry.svc:5000"
        OCP_TOKEN = "sha256~JJZ-ej4Bwn01RwtXmWI6IQ1LpUs-6aMPavk6JfhKl_Y"
        TLS_CERT = credentials('tls-cert')
    }
    stages { 
        stage('APP Manifest') {
            steps('Project Reserve'){
                container('builder') {
                    sh 'oc login -u admin --token=${OCP_TOKEN} --SERVER=${API_OCP} --insecure-skip-tls-verify=true'
                    sh 'if ! oc get project ${PROJECT_NAME} >/dev/null 2>&1; then oc new-project ${PROJECT_NAME} --description="Project for ${SERVICE_NAME}" fi'
                }
            }
        }

        stage('Build') {
            steps('Docker Build') {
                container('dind') {
                    sh 'docker build -t ${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest .'
                    sh 'mkdir -p /etc/docker/certs.d/${OCP_REG}'
                    //sh 'echo \'{"insecure-registries": ["image-registry.openshift-image-registry.svc:5000"]}\' >/etc/docker/daemon.json'
                    sh 'chmod 777 ca.crt'
                    sh 'cp ca.crt /etc/docker/certs.d/${OCP_REG}/ca.crt'
                    sh 'cat /etc/docker/certs.d/${OCP_REG}/ca.crt'
                    sh 'echo "${OCP_TOKEN}" | docker login -u admin --password-stdin ${OCP_REG}'
                    sh 'docker push ${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest'
                }
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
        stage('Deploy') {
            steps {
                sh """
                export PATH=\$WORKSPACE/bin:\$PATH
                helm upgrade --install ${APP_NAME} ./helm-chart \\
                  --set image.repository=${OCP_REG}/${PROJECT_NAME}/${SERVICE_NAME}:latest \\
                  --set image.tag=latest \\
                  -n ${NAMESPACE} --create-namespace
                """
            }
        }
    }
}