pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE = 'hzdevops52/my-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE_FULL = "${DOCKER_IMAGE}:${IMAGE_TAG}"
        DOCKER_IMAGE_LATEST = "${DOCKER_IMAGE}:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Checking out repository...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/hzdevops52/jenkins-cicd.git'
                    ]]
                ])
            }
        }

        stage('Build Info') {
            steps {
                echo '📊 Build Information:'
                sh '''
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Docker Image: ${DOCKER_IMAGE_FULL}"
                    git rev-parse --is-inside-work-tree
                    git branch
                    git log -1 --oneline
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐋 Building Docker image...'
                sh '''
                    docker build -t ${DOCKER_IMAGE_FULL} .
                    docker tag ${DOCKER_IMAGE_FULL} ${DOCKER_IMAGE_LATEST}
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                echo '🔐 Logging into Docker Hub...'
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | \
                    docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing image to Docker Hub...'
                sh '''
                    docker push ${DOCKER_IMAGE_FULL}
                    docker push ${DOCKER_IMAGE_LATEST}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Deploying to Kubernetes...'
                sh '''
                    echo "===== SHOWING MANIFESTS ====="
                    cat k8s/deployment.yml
                    cat k8s/service.yml

                    kubectl apply -f k8s/
                    kubectl rollout status deployment/my-app --timeout=120s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '✅ Verifying deployment...'
                sh '''
                    kubectl get deployment my-app
                    kubectl get pods -l app=my-app
                    kubectl get svc my-app-service
                '''
            }
        }

        stage('Cleanup Local Images') {
            steps {
                echo '🧹 Cleaning up old Docker images...'
                sh '''
                    OLD_IMAGES=$(docker images ${DOCKER_IMAGE} --format "{{.Tag}}" | tail -n +4)
                    for tag in $OLD_IMAGES; do
                        docker rmi ${DOCKER_IMAGE}:$tag 2>/dev/null || true
                    done
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }

        success {
            echo '✅ Pipeline completed successfully!'
        }

        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
