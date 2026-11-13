pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        DOCKERHUB_USER = 'dockervijay1998'
        APP_CONTAINER  = 'trend-app'
        APP_PORT       = '80'
    }

    stages {
        stage('Select image repository') {
            steps {
                script {
                    if (env.BRANCH_NAME in ['master', 'main']) {
                        env.IMAGE_REPO = 'prod'
                    } else if (env.BRANCH_NAME == 'dev') {
                        env.IMAGE_REPO = 'dev'
                    } else {
                        error "Unsupported branch: ${env.BRANCH_NAME}. Use dev, master, or main."
                    }

                    env.IMAGE_NAME = "${env.DOCKERHUB_USER}/${env.IMAGE_REPO}"

                    echo "Branch ${env.BRANCH_NAME} will publish ${env.IMAGE_NAME}"
                }
            }
        }

        stage('Build image') {
            steps {
                sh '''
                    set -eu
                    docker build \
                      --tag "${IMAGE_NAME}:${BUILD_NUMBER}" \
                      --tag "${IMAGE_NAME}:latest" \
                      .
                '''
            }
        }

        stage('Push image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x
                        printf '%s' "$DH_TOKEN" | docker login \
                          --username "$DH_USER" \
                          --password-stdin

                        docker push "${IMAGE_NAME}:${BUILD_NUMBER}"
                        docker push "${IMAGE_NAME}:latest"

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy production to EC2') {
            when {
                anyOf {
                    branch 'master'
                    branch 'main'
                }
            }

            steps {
                script {
                    if (!env.APP_EC2_HOST?.trim()) {
                        error 'APP_EC2_HOST is not set. Add the application EC2 public IP or DNS in Jenkins global environment variables.'
                    }
                }

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sshagent(credentials: ['ec2-ssh-key']) {
                        sh '''
                            set +x
                            set -eu

                            ssh -o StrictHostKeyChecking=no \
                                "ubuntu@${APP_EC2_HOST}" \
                                "echo '$DH_TOKEN' | sudo docker login \
                                  --username '$DH_USER' \
                                  --password-stdin"

                            ssh -o StrictHostKeyChecking=no \
                                "ubuntu@${APP_EC2_HOST}" \
                                "sudo docker pull ${IMAGE_NAME}:latest && \
                                 sudo docker rm -f ${APP_CONTAINER} >/dev/null 2>&1 || true; \
                                 sudo docker run -d \
                                   --name ${APP_CONTAINER} \
                                   --restart unless-stopped \
                                   -p ${APP_PORT}:80 \
                                   ${IMAGE_NAME}:latest"

                            ssh -o StrictHostKeyChecking=no \
                                "ubuntu@${APP_EC2_HOST}" \
                                "sudo docker logout"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded for branch ${env.BRANCH_NAME}."
        }
        failure {
            echo 'Pipeline failed. Check the first failing stage in the console output.'
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}