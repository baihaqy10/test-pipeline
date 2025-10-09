pipeline {
    agent any

    environment {
        PROJECT_NAME = "first-project"
        SERVICE_NAME = "first-service"
        OCP_PASSWORD = credentials('admin-cres')
        API_OCP = credentials('ocp-api')
        OCP_REG = "image-registry.openshift-image-registry.svc:5000"
        OCP_TOKEN = credentials('ocp-token')
    }
    
     stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('login') {
            steps {
                sh """
                oc login ${API_OCP} --token=${OCP_TOKEN} --insecure-skip-tls-verify=true
                if ! oc get project ${PROJECT_NAME} >/dev/null 2>&1; then
                    oc new-project ${PROJECT_NAME} --description="Project for ${SERVICE_NAME}"
                fi
                """
            }
        }

        stage('buildconfig') {
            steps {
                sh """
                if ! oc get bc ${SERVICE_NAME} -n ${PROJECT_NAME}; then
                  oc new-build --name=${SERVICE_NAME} --binary --strategy=docker -n ${PROJECT_NAME}
                fi
                """
            }
        }

        stage('build openshift') {
            steps {
                sh """
                oc start-build ${SERVICE_NAME} --from-dir=. --follow -n ${PROJECT_NAME}
                """
            }
        }

        stage('install helm bogo') {
            steps {
                sh """
                curl -sSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz
                tar -xzf helm.tar.gz
                mkdir -p \$WORKSPACE/bin
                mv linux-amd64/helm \$WORKSPACE/bin/helm
                export PATH=\$WORKSPACE/bin:\$PATH
                \$WORKSPACE/bin/helm version
                """
            }
        }

        stage('deploy') {
            steps {
                sh """
                export PATH=\$WORKSPACE/bin:\$PATH
                helm upgrade --install ${SERVICE_NAME} ./helm-chart \\
                  --set image.repository=image-registry.openshift-image-registry.svc:5000/${PROJECT_NAME}/${SERVICE_NAME} \\
                  --set image.tag=latest \\
                  -n ${PROJECT_NAME} --create-namespace
                """
            }
        }

        stage('rollout') {
            steps {
                script {
                    sh """
                    oc rollout restart deployment ${SERVICE_NAME} -n ${PROJECT_NAME}
                    """
                }
            }
        }
    }
}


