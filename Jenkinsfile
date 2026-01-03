pipeline {
    agent any
    
    environment {
        // Docker Hub credentials (ID from Jenkins credentials)
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        
        // Docker image name (CHANGE THIS to your Docker Hub username!)
        DOCKER_IMAGE = 'YOUR_DOCKERHUB_USERNAME/my-app'
        
        // Image tag using build number
        IMAGE_TAG = "${BUILD_NUMBER}"
        
        // Full image name with tag
        DOCKER_IMAGE_FULL = "${DOCKER_IMAGE}:${IMAGE_TAG}"
        DOCKER_IMAGE_LATEST = "${DOCKER_IMAGE}:latest"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build Info') {
            steps {
                echo '📊 Build Information:'
                sh '''
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Docker Image: ${DOCKER_IMAGE_FULL}"
                    echo "Git Branch: ${GIT_BRANCH}"
                    echo "Git Commit: ${GIT_COMMIT}"
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
                    # Run container in background
                    docker run -d --name test-container -p 8888:3000 ${DOCKER_IMAGE_FULL}
                    
                    # Wait for container to start
                    sleep 5
                    
                    # Test health endpoint
                    curl -f http://localhost:8888/health || exit 1
                    
                    # Stop and remove test container
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
                echo '📝 Updating Kubernetes deployment with new image tag...'
                sh '''
                    # Update deployment.yaml with new image tag
                    sed -i "s|image: .*|image: ${DOCKER_IMAGE_FULL}|g" k8s/deployment.yaml
                    sed -i "s|value: \"PLACEHOLDER\"|value: \"${BUILD_NUMBER}\"|g" k8s/deployment.yaml
                    
                    # Show updated deployment
                    echo "Updated deployment.yaml:"
                    cat k8s/deployment.yaml | grep -A 2 "image:"
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Deploying to Kubernetes...'
                sh '''
                    # Apply Kubernetes manifests
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    
                    # Wait for rollout to complete
                    kubectl rollout status deployment/my-app --timeout=120s
                    
                    echo "✅ Deployment successful!"
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '✅ Verifying deployment...'
                sh '''
                    echo "Deployment Status:"
                    kubectl get deployment my-app
                    
                    echo ""
                    echo "Pods:"
                    kubectl get pods -l app=my-app
                    
                    echo ""
                    echo "Service:"
                    kubectl get svc my-app-service
                    
                    echo ""
                    echo "Application is accessible at:"
                    echo "http://$(curl -s http://checkip.amazonaws.com):30100"
                '''
            }
        }
        
        stage('Cleanup Local Images') {
            steps {
                echo '🧹 Cleaning up local Docker images...'
                sh '''
                    # Remove old images (keep last 3 builds)
                    docker images ${DOCKER_IMAGE} --format "{{.Tag}}" | tail -n +4 | xargs -r docker rmi ${DOCKER_IMAGE}: 2>/dev/null || true
                    
                    echo "✅ Cleanup complete!"
                '''
            }
        }
    }
    
    post {
        always {
            echo '🔒 Logging out from Docker Hub...'
            sh 'docker logout'
        }
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Application URL: http://$(curl -s http://checkip.amazonaws.com):30100"
        }
        failure {
            echo '❌ Pipeline failed!'
            echo 'Check the logs above for errors.'
        }
    }
}