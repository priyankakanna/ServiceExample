Steps to secure connections between your application and MongoDB/Redis/NATS:

##  **Secure Connections Implementation Steps**

### **1. MongoDB Secure Connection**
```bash
# Generate MongoDB TLS certificates
openssl req -newkey rsa:2048 -nodes -keyout mongo-key.pem -x509 -days 365 -out mongo-cert.pem

# Create Kubernetes secret for MongoDB TLS
kubectl create secret generic mongo-tls --from-file=mongo-cert.pem --from-file=mongo-key.pem

# Update MongoDB deployment to use TLS
# Add to MongoDB container args:
# - --tlsMode=requireTLS
# - --tlsCertificateKeyFile=/etc/mongo-tls/mongo-key.pem
# - --tlsCAFile=/etc/mongo-tls/mongo-cert.pem
```

### **2. Redis Secure Connection**
```bash
# Generate Redis TLS certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout redis-tls.key -out redis-tls.crt

# Create Kubernetes secret for Redis TLS
kubectl create secret tls redis-tls --cert=redis-tls.crt --key=redis-tls.key

# Update Redis deployment to use TLS
# Add to Redis configuration:
# port 0
# tls-port 6379
# tls-cert-file /etc/redis/tls/redis-tls.crt
# tls-key-file /etc/redis/tls/redis-tls.key
# tls-ca-cert-file /etc/redis/tls/redis-tls.crt
```

### **3. NATS Secure Connection**
```bash
# Generate NATS TLS certificates
openssl req -newkey rsa:2048 -nodes -keyout nats-key.pem -x509 -days 365 -out nats-cert.pem

# Create Kubernetes secret for NATS TLS
kubectl create secret generic nats-tls --from-file=nats-cert.pem --from-file=nats-key.pem

# Update NATS deployment to use TLS
# Add to NATS configuration:
# tls {
#   cert_file: "/etc/nats/tls/nats-cert.pem"
#   key_file: "/etc/nats/tls/nats-key.pem"
# }
```

### **4. Application Configuration Updates**
```yaml
# Update application deployment to use secure connections:
env:
  - name: MONGODB_URL
    value: "mongodb://username:password@mongo:27017/db?tls=true&tlsCAFile=/etc/app-tls/mongo-cert.pem"
  - name: REDIS_URL
    value: "rediss://redis:6379"
  - name: NATS_URL
    value: "tls://nats:4222"
```

### **5. Create Application TLS Secrets**
```bash
# Create secrets for application to trust the certificates
kubectl create secret generic app-tls \
  --from-file=mongo-cert.pem \
  --from-file=redis-tls.crt \
  --from-file=nats-cert.pem
```

### **6. Update Services**
```yaml
# Update services to use TLS ports:
ports:
  - name: tls
    port: 443
    targetPort: tls-port
```

### **7. Network Policies**
```yaml
# Implement network policies to restrict access
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-db-access
spec:
  podSelector:
    matchLabels:
      app: mongodb
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: serviceexample
    ports:
    - protocol: TCP
      port: 27017
```

### **8. Update Helm Charts**
- Add TLS configuration options to values.yaml
- Update templates to conditionally enable TLS
- Add certificate mounting to deployments

### **9. Verification Steps**
```bash
# Test MongoDB TLS connection
kubectl exec -it deployment/serviceexample -- mongosh --tls --tlsCAFile /etc/app-tls/mongo-cert.pem

# Test Redis TLS connection  
kubectl exec -it deployment/serviceexample -- redis-cli --tls --cacert /etc/app-tls/redis-tls.crt

# Verify certificates are mounted
kubectl exec deployment/serviceexample -- ls -la /etc/app-tls/
```


## Option 2:


## **Simplified Steps (Self-Signed Certificates)**

### **1. Generate Self-Signed Certificates**
```bash
# Generate CA and certificates for all services
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 3650 -out ca-cert.pem

# Generate certs for MongoDB, Redis, NATS using the same CA
openssl genrsa -out mongo-key.pem 2048
openssl req -new -key mongo-key.pem -out mongo.csr
openssl x509 -req -in mongo.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out mongo-cert.pem -days 365
```

### **2. Create Kubernetes Secrets**
```bash
# Create TLS secrets for each service
kubectl create secret tls mongo-tls --cert=mongo-cert.pem --key=mongo-key.pem
kubectl create secret tls redis-tls --cert=redis-tls.crt --key=redis-tls.key  
kubectl create secret tls nats-tls --cert=nats-cert.pem --key=nats-key.pem

# Create secret for application to trust the CA
kubectl create secret generic app-ca --from-file=ca-cert.pem
```

### **3. Update Deployments**
- Mount certificates to each service
- Configure services to use TLS with self-signed certs
- Update application to trust CA


