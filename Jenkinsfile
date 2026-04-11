// Zomato Clone - Jenkins Declarative Pipeline
// This pipeline automates the build, test, and deployment of the Zomato Clone application
// Triggered by GitHub webhook on code push to main branch

pipeline {
    agent { label "vinod" }
    stages {

        stage("Code") {
            steps {
                echo "This is Cloning the Code"
                git url: "https://github.com/himanshu1029g/Zomato-Clone.git", branch: "main"
                echo "Code clone successfully"
            }
        }

        stage("Build") {
            steps {
                echo "This is Building the Code"
                sh "docker build -t zomato_clone:latest ."
            }
        }

        stage("Test") {
            steps {
                echo "This is Testing the Code"
            }
        }

        stage("Push to DockerHub") {
            steps {
                echo "This is pushing the img to docker hub"
                withCredentials([usernamePassword(
                    credentialsId: "dockerhubcred",
                    passwordVariable: "dockerHubPass",
                    usernameVariable: "dockerHubUser"
                )]) {
                    sh "docker login -u ${dockerHubUser} -p ${dockerHubPass}"
                    sh "docker image tag zomato_clone:latest him1029g/zomato_clone:latest"
                    sh "docker push him1029g/zomato_clone:latest"
                }
            }
        }

        stage("Deployment") {
            steps {
                echo "This is Deploying the Code"
                sh "docker compose down --remove-orphans || true"
                sh "docker compose up -d"
            }
        }

    }
}


