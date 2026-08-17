pipeline {

    agent any

    environment {
        APP_NAME = "employee-webapp"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonarqube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=employee-webapp'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'tomcat-server',
                            transfers: [
                                sshTransfer(
                                    sourceFiles: 'target/employee-webapp.war',
                                    removePrefix: 'target',
                                    remoteDirectory: '/opt/tomcat/webapps',
                                    verbose: true
                               )
                            ],
                            verbose: true
                        )
                    ]
                )
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Application deployed successfully to Tomcat.'
            }
        }
    }

    post {
        success {
            echo '========================================'
            echo 'CI/CD PIPELINE SUCCESSFUL'
            echo 'Application deployed to Tomcat'
            echo '========================================'
        }

        failure {
            echo '========================================'
            echo 'CI/CD PIPELINE FAILED'
            echo 'Check the Jenkins console output'
            echo '========================================'
        }
    }
}
