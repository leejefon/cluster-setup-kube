source ./env.sh

mkdir -p certs
cd certs

# CA
{
cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json << EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}


# Admin Client Certificate
{
cat > admin-csr.json << EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "system:masters",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
}


# Kubelet Client Certificates
{
cat > ${WORKER1_NAME}-csr.json << EOF
{
  "CN": "system:node:${WORKER1_NAME}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "system:nodes",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WORKER1_IP} \
  -profile=kubernetes \
  ${WORKER1_NAME}-csr.json | cfssljson -bare ${WORKER1_NAME}

cat > ${WORKER2_NAME}-csr.json << EOF
{
  "CN": "system:node:${WORKER2_NAME}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "system:nodes",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WORKER2_IP} \
  -profile=kubernetes \
  ${WORKER2_NAME}-csr.json | cfssljson -bare ${WORKER2_NAME}
}


# Controller Manager Client Certificate
{
cat > kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "system:kube-controller-manager",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
}


# Kube Proxy Client Certificate
{
cat > kube-proxy-csr.json << EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "system:node-proxier",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
}


# Kube Scheduler Client Certificate
{

cat > kube-scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "system:kube-scheduler",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
}


# API Server Certificates
{
cat > kubernetes-csr.json << EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "Kubernetes",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${CERT_HOSTNAME} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
}


# Service Account Certificate
{
cat > service-account-csr.json << EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Santa Clara",
      "O": "Kubernetes",
      "OU": "Silver Peak",
      "ST": "California"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
}


# Move certs to workers
scp ca.pem ${WORKER1_NAME}-key.pem ${WORKER1_NAME}.pem ${WORKER1_USER}@${WORKER1_IP}:~
scp ca.pem ${WORKER2_NAME}-key.pem ${WORKER2_NAME}.pem ${WORKER2_USER}@${WORKER2_IP}:~


# Move certs to controllers
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${CONTROLLER0_USER}@${CONTROLLER0_IP}:~
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${CONTROLLER1_USER}@${CONTROLLER1_IP}:~
