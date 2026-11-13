pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'dockervijay1998'
        EC2_HOST       = 'REPLACE_WITH_CURRENT_EC2_PUBLIC_IP'
    }

    stages {
        stage('Select image repository') {
            steps {
                script {
                    def repoName = (env.BRANCH_NAME in ['master', 'main']) ? 'prod' : 'dev'
                    env.IMAGE_REPO = "${env.DOCKERHUB_USER}/${repoName}"
                    echo "Branch ${env.BRANCH_NAME} will publish ${env.IMAGE_REPO}"
                }
            }
        }

        stage('Build image') {
            steps {
                powershell '''
                    $repo = $env:IMAGE_REPO
                    $tag = $env:BUILD_NUMBER

                    docker build --pull `
                        --tag "${repo}:latest" `
                        --tag "${repo}:${tag}" .

                    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                '''
            }
        }

        stage('Push image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_TOKEN'
                )]) {
                    powershell '''
                        $token = $env:DH_TOKEN.Trim()
                        $token | docker login --username $env:DH_USER --password-stdin
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

                        docker push "$($env:IMAGE_REPO):latest"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

                        docker push "$($env:IMAGE_REPO):$($env:BUILD_NUMBER)"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
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
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    ),
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'EC2_KEY',
                        usernameVariable: 'EC2_USER'
                    )
                ]) {
                    powershell '''
                        $token = $env:DH_TOKEN.Trim()
                        $image = "$($env:IMAGE_REPO):latest"

                        $remoteCommand = "sudo docker rm -f devops-build-app >/dev/null 2>&1 || true; sudo docker login --username $($env:DH_USER) --password-stdin && sudo docker pull $image && sudo docker run -d --name devops-build-app --restart unless-stopped -p 80:80 $image"

                        $token | & ssh.exe `
                            -i $env:EC2_KEY `
                            -o StrictHostKeyChecking=accept-new `
                            "$($env:EC2_USER)@$($env:EC2_HOST)" `
                            $remoteCommand

                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded for ${env.BRANCH_NAME}: ${env:IMAGE_REPO}:latest"
        }
        failure {
            echo "Pipeline failed. Check the stage console output."
        }
    }
}