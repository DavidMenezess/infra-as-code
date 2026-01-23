sudo su
apt-get update -y
apt-get install -y docker
service docker start
usermod -a -G docker ubuntu