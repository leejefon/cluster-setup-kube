source ./env.sh
cd certs

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml << EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

scp encryption-config.yaml ${CONTROLLER0_USER}@${CONTROLLER0_IP}:~
scp encryption-config.yaml ${CONTROLLER1_USER}@${CONTROLLER1_IP}:~
