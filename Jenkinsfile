pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        DOCKERHUB_NAMESPACE = 'dockervijay1998'
        IMAGE_REPO = ''
        IMAGE_NAME = ''
    }

    stages {
        stage('Select image repository') {
            steps {
                script {
                    if (env.BRANCH_NAME in ['master', 'main']) {
                        env.IMAGE_REPO = 'prod'
                    } else {
                        env.IMAGE_REPO = 'dev'
                    }

                    env.IMAGE_NAME = "${env.DOCKERHUB_NAMESPACE}/${env.IMAGE_REPO}"
                    echo "Branch ${env.BRANCH_NAME} will publish ${env.IMAGE_NAME}"
                }
            }
        }

        stage('Build image') {
            steps {
                sh '''
                    set -eu
                    docker build \
                      --pull \
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
                        set -eu
                        set +x
                        printf '%s' "$DH_TOKEN" |
                          docker login --username "$DH_USER" --password-stdin
                        docker push "${IMAGE_NAME}:${BUILD_NUMBER}"
                        docker push "${IMAGE_NAME}:latest"
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy production to EC2') {
            when {
                expression {
                    env.BRANCH_NAME in ['master', 'main']
                }
            }
            steps {
                script {
                    if (!env.APP_EC2_HOST?.trim()) {
                        error('Set APP_EC2_HOST in Jenkins global environment properties to the application EC2 public IP or DNS name.')
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
                            set -eu
                            set +x

                            printf '%s' "$DH_TOKEN" |
                              ssh -o StrictHostKeyChecking=accept-new \
                                "ubuntu@$APP_EC2_HOST" \
                                "sudo docker login --username '$DH_USER' --password-stdin"

                            ssh -o StrictHostKeyChecking=accept-new \
                              "ubuntu@$APP_EC2_HOST" \
                              "sudo docker pull '${IMAGE_NAME}:latest' && \
                               (sudo docker rm --force trend-app || true) && \
                               sudo docker run --detach \
                                 --name trend-app \
                                 --restart unless-stopped \
                                 --publish 80:80 \
                                 '${IMAGE_NAME}:latest'"

                            curl --fail --retry 10 --retry-all-errors --retry-delay 3 \
                              "http://${APP_EC2_HOST}/healthz"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for ${BRANCH_NAME}."
        }
        failure {
            echo "Pipeline failed. Check the stage console output."
        }
    }
}