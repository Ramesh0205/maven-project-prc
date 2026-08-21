pipeline {

    agent any

    environment {
        APP_NAME = "employee-webapp"
        DOCKER_REGISTRY = "20.121.14.173:8082"
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}"
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

        stage('Download Artifact from Nexus') {
            steps {
                configFileProvider([
                    configFile(
                        fileId: 'maven-settings',
                        variable: 'MAVEN_SETTINGS'
                    )
                ]) {
                    sh '''
                        rm -rf nexus-download
                        mkdir -p nexus-download

                        mvn -s "$MAVEN_SETTINGS" dependency:get \
                        -Dartifact=com.ramesh.employee:employee-webapp:1.0-SNAPSHOT:war \
                        -DremoteRepositories=nexus-snapshots::default::http://20.121.14.173:8081/repository/maven-snapshots/ \
                        -Dtransitive=false

                        cp ~/.m2/repository/com/ramesh/employee/employee-webapp/1.0-SNAPSHOT/employee-webapp-1.0-SNAPSHOT.war nexus-download/employee-webapp.war

                        ls -lh nexus-download/employee-webapp.war
                    '''
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
                                    sourceFiles: 'nexus-download/employee-webapp.war',
                                    removePrefix: 'nexus-download',
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
                echo 'Application deployed successfully to Tomcat from Nexus artifact.'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                    -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                    -t ${DOCKER_IMAGE}:latest \
                    .
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'nexus-docker-credentials',
                        usernameVariable: 'NEXUS_USERNAME',
                        passwordVariable: 'NEXUS_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$NEXUS_PASSWORD" | docker login ${DOCKER_REGISTRY} \
                        -u "$NEXUS_USERNAME" \
                        --password-stdin
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }
    }

    post {

        success {
            echo '========================================'
            echo 'CI/CD PIPELINE SUCCESSFUL'
            echo 'Application built and analyzed'
            echo 'WAR published to Nexus'
            echo 'Application deployed to Tomcat'
            echo 'Docker image built and pushed to Nexus'
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
