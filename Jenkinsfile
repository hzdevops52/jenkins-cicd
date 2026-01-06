pipeline {
    agent any

    environment {
        // Docker Hub credentials (ID from Jenkins credentials)
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')

        // Docker image name
        DOCKER_IMAGE = 'hzdevops52/my-app'

        // Image tag using build number
        IMAGE_TAG = "${BUILD_NUMBER}"

        // Full image names
        DOCKER_IMAGE_FULL = "${DOCKER_IMAGE}:${IMAGE_TAG}"
        DOCKER_IMAGE_LATEST = "${DOCKER_IMAGE}:latest"
    }

    stages {

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

        stage('Test Docker Image') {
            steps {
                echo '🧪 Testing Docker image...'
                sh '''
                    docker rm -f test-container 2>/dev/null || true

                    docker run -d --name test-container -p 8888:3000 ${DOCKER_IMAGE_FULL}

                    sleep 5

                    curl -f http://localhost:8888/health || exit 1

                    docker stop test-container
                    docker rm test-container

                    echo "✅ Docker image test passed!"
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                echo '🔐 Logging into Docker Hub...'
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing image to Docker Hub...'
                sh '''
                    docker push ${DOCKER_IMAGE_FULL}
                    docker push ${DOCKER_IMAGE_LATEST}
                    echo "✅ Image pushed successfully!"
                '''
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                echo '📝 Updating Kubernetes deployment...'
                sh '''
                    sed -i "s|image: .*my-app.*|image: ${DOCKER_IMAGE_FULL}|g" k8s/deployment.yml
                    sed -i "s|value: \\"PLACEHOLDER\\"|value: \\"${BUILD_NUMBER}\\"|g" k8s/deployment.yml

                    echo "Updated deployment.yml:"
                    cat k8s/deployment.yml | grep -A 5 image:
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Deploying to Kubernetes...'
                sh '''
                    kubectl apply -f k8s/
                    kubectl rollout status deployment/my-app --timeout=120s
                    echo "✅ Deployment successful!"
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

                    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
                    echo "Application URL: http://${PUBLIC_IP}:30100"
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
            echo '🔒 Cleanup...'
            sh 'docker logout'
            sh 'docker rm -f test-container 2>/dev/null || true'
        }

        success {
            echo '✅ Pipeline completed successfully!'
            sh '''
                PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
                echo "Application URL: http://${PUBLIC_IP}:30100"
            '''
        }

        failure {
            echo '❌ Pipeline failed!'
            sh '''
                kubectl get pods -l app=my-app -o name 2>/dev/null | head -1 | \
                xargs kubectl logs --tail=20 2>/dev/null || echo "No pods found"
            '''
        }
    }
}
