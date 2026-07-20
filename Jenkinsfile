pipeline {

    agent any

    environment {
        APP_NAME = "employee-webapp"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Source code downloaded from GitHub."
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

        stage('Deploy') {
            steps {
                echo "Deploying application..."
            }
        }
    }

    post {
        success {
            echo "Build Successful"
        }
        failure {
            echo "Build Failed"
        }
    }
}
