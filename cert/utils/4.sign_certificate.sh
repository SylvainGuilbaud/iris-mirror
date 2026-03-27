openssl x509 -req \
  -in ./mirror-certs/iris1.csr \
  -CA ./mirror-certs/ca.pem \
  -CAkey ./mirror-certs/ca.key \
  -CAcreateserial \
  -out ./mirror-certs/iris1.pem \
  -days 825 \
  -sha256 \
  -extfile ./mirror-certs/iris1.ext