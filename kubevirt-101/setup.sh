apt-get install -y jq

curl -sfL https://get.k3s.io | sh -

cp /etc/rancher/k3s/k3s.yaml ~/.kube/config