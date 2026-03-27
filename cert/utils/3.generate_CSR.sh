openssl req -new \
  -key ./mirror-certs/iris1.key \
  -out ./mirror-certs/iris1.csr \
  -subj "/C=FR/ST=Demo/L=Paris/O=Training/OU=IRIS/CN=iris-prod-1"