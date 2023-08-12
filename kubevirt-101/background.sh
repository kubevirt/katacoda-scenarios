#!/bin/bash

apt-get install -y jq

curl -sfL https://get.k3s.io | sh -

mkdir -m 750 ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
