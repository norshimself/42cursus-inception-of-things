

vagrant up

vagrant ssh zoukaddoS -c "ip addr show eth1"
vagrant ssh zoukaddoSW -c "ip addr show eth1"

vagrant ssh zoukaddoSW -c "hostname"
vagrant ssh zoukaddoS -c "hostname"



vagrant ssh zoukaddoS -c "k3s --version"
vagrant ssh zoukaddoSW -c "k3s --version"



vagrant ssh zoukaddoS -c "sudo kubectl get nodes -o wide"


