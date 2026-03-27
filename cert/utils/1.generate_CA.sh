mkdir mirror-certs
cd mirror-certs

# Clé privée de la CA
openssl genrsa -out ca.key 4096

# Certificat de la CA (valide 10 ans pour une démo)
openssl req -x509 -new -nodes \
  -key ca.key \
  -sha256 -days 3650 \
  -out ca.pem \
  -subj "/C=FR/ST=Demo/L=Paris/O=Training/OU=IRIS/CN=IRIS-Mirror-CA"