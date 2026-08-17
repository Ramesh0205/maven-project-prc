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

        stage('Deploy') {
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
                                    execCommand: 'rm -rf /opt/tomcat/webapps/employee-webapp && /opt/tomcat/bin/shutdown.sh && sleep 5 && /opt/tomcat/bin/startup.sh',
                                    execTimeout: 120000,
                                    verbose: true
                                )
                            ],
                            verbose: true
                        )
                    ]
                )
            }
        }
    }

    post {

        success {
            echo '======================================'
            echo 'CI/CD PIPELINE SUCCESSFUL'
            echo 'Application deployed to Tomcat'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'CI/CD PIPELINE FAILED'
            echo 'Check the Console Output'
            echo '======================================'
        }
    }
}
