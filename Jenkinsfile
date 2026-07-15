pipeline {

    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK21'
    }

    environment {
        APP_NAME = "employee-webapp"
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['DEV', 'QA', 'PROD'],
            description: 'Select Environment'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Source code downloaded from GitHub."
            }
        }

        stage('Build') {
            steps {
                echo "Building ${APP_NAME}"
                sh 'mvn clean package'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying ${APP_NAME} to ${params.ENVIRONMENT}"
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

        always {
            echo "Pipeline Finished"
        }

    }
}
