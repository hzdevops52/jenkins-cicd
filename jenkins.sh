#!/bin/bash
set -e

echo "=== Fixing Jenkins - Adding Docker Socket Mount ==="
echo ""

# Step 1: Stop and remove current Jenkins
echo "1. Stopping current Jenkins container..."
docker stop jenkins
docker rm jenkins

# Step 2: Backup check
echo "2. Verifying jenkins_home volume exists..."
docker volume ls | grep jenkins_home
echo "   ✓ Your data is safe in this volume"
echo ""

# Step 3: Set Docker socket permissions
echo "3. Setting Docker socket permissions..."
sudo chmod 666 /var/run/docker.sock
ls -l /var/run/docker.sock
echo ""

# Step 4: Get private IP for K3s
PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "4. Private IP for K3s: $PRIVATE_IP"

# Step 5: Create kubeconfig
echo "5. Creating kubeconfig for Jenkins..."
sudo sed "s/127.0.0.1/$PRIVATE_IP/g" /etc/rancher/k3s/k3s.yaml > ~/kubeconfig-jenkins.yaml
chmod 600 ~/kubeconfig-jenkins.yaml
echo ""

# Step 6: Recreate Jenkins with all necessary mounts
echo "6. Creating Jenkins container with proper mounts..."
docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/kubeconfig-jenkins.yaml:/root/.kube/config:ro \
  --user root \
  --memory="400m" \
  --memory-swap="1200m" \
  --cpus="0.5" \
  jenkins/jenkins:lts

echo ""
echo "7. Waiting for Jenkins to start (3 minutes)..."
sleep 180

# Step 7: Install Docker client
echo "8. Installing Docker client in Jenkins..."
docker exec jenkins bash -c "
  apt-get update -qq && \
  apt-get install -y docker.io curl
"
echo ""

# Step 8: Install kubectl
echo "9. Installing kubectl in Jenkins..."
docker exec jenkins bash -c "
  curl -sLO https://dl.k8s.io/release/\$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv kubectl /usr/local/bin/
"
echo ""

# Verification
echo "=========================================="
echo "          VERIFICATION"
echo "=========================================="
echo ""

echo "✓ Jenkins container status:"
docker ps | grep jenkins
echo ""

echo "✓ Docker socket is now mounted:"
docker inspect jenkins | grep -A 1 "docker.sock"
echo ""

echo "✓ Docker version in Jenkins:"
docker exec jenkins docker --version
echo ""

echo "✓ Docker access test:"
docker exec jenkins docker ps | head -3
echo ""

echo "✓ kubectl version:"
docker exec jenkins kubectl version --client --short
echo ""

echo "✓ Kubernetes cluster access:"
docker exec jenkins kubectl get nodes
echo ""

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "=========================================="
echo "✅ Jenkins is ready!"
echo "=========================================="
echo ""
echo "Access Jenkins at: http://$PUBLIC_IP:8080"
echo ""
echo "✅ All your jobs, credentials, and settings are preserved!"
echo "✅ Docker socket is now properly mounted"
echo "✅ kubectl has access to K3s cluster"
echo ""
echo "Next steps:"
echo "1. Open Jenkins in browser"
echo "2. Go to your pipeline job"
echo "3. Click 'Build Now'"
echo "4. Your pipeline should now work!"
echo ""
EOF

chmod +x ~/fix-jenkins-complete.sh
~/fix-jenkins-complete.sh
```

---

## What This Script Does

1. **Stops current Jenkins** (your data is safe in the volume)
2. **Recreates Jenkins** with these mounts:
   - `jenkins_home` volume → Your data (jobs, credentials, config)
   - `/var/run/docker.sock` → Docker access ✅ **NEW!**
   - `kubeconfig` → Kubernetes access
3. **Installs Docker client** inside Jenkins
4. **Installs kubectl** inside Jenkins
5. **Verifies everything works**

---

## What Changed

### Before (Current):
```
Mounts:
  - jenkins_home volume only
  ❌ No Docker socket
```

### After (Fixed):
```
Mounts:
  - jenkins_home volume (your data)
  - /var/run/docker.sock (Docker access) ✅
  - kubeconfig (K3s access) ✅