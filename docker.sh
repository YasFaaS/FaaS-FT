apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 18.03 | head -1 | awk '{print $3}')

