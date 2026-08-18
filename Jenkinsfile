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
                configFileProvider([
                    configFile(
                        fileId: 'maven-settings',
                        variable: 'MAVEN_SETTINGS'
                    )
                ]) {
                    sh 'mvn -s "$MAVEN_SETTINGS" clean package'
                }
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

        stage('Publish to Nexus') {
            steps {
                configFileProvider([
                    configFile(
                        fileId: 'maven-settings',
                        variable: 'MAVEN_SETTINGS'
                    )
                ]) {
                    sh 'mvn -s "$MAVEN_SETTINGS" deploy -DskipTests'
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
                                    remoteDirectory: '.',
                                    execCommand: 'sudo cp /home/azureuser/employee-webapp.war /opt/tomcat/webapps/employee-webapp.war'
                                )
                            ]
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
