pipeline {
    agent any

    stages {
        stage('Build and push image') {
            steps {
                script {
                    def imageRepo = (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'main')
                        ? 'dockervijay1998/prod'
                        : 'dockervijay1998/dev'

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )]) {
                        bat 'echo %DH_TOKEN% | docker login -u %DH_USER% --password-stdin'
                        bat "docker build -t ${imageRepo}:latest -t ${imageRepo}:${env.BUILD_NUMBER} ."
                        bat "docker push ${imageRepo}:latest"
                        bat "docker push ${imageRepo}:${env.BUILD_NUMBER}"
                        bat 'docker logout'
                    }
                }
            }
        }
    }
}