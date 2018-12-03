source ./env.sh

./create-certs.sh
./create-kubeconfigs.sh
./create-encryptconfig.sh

scp env.sh master-setup.sh ${CONTROLLER0_USER}@${CONTROLLER0_IP}:~
scp env.sh master-setup.sh ${CONTROLLER1_USER}@${CONTROLLER1_IP}:~

scp env.sh worker-setup.sh ${WORKER1_USER}@${WORKER1_IP}:~
scp env.sh worker-setup.sh ${WORKER2_USER}@${WORKER2_IP}:~

scp loadbalancer-setup.sh ${LOADBALANCER_USER}@${KUBERNETES_ADDRESS}:~
