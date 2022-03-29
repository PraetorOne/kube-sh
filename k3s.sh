#!/bin/bash

# Follow guide at https://github.com/PraetorOne/K3s-sh

function apt_depends() {
    apt-get update && apt-get upgrade -y
    apt-get install git -y
}

function yum_depends() {
    yum update -y
    yum install epel-release
    yum install -y git
}

OS_RELEASE=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
CENT_OS='"CentOS Linux"'
DEBIAN='"Debian GNU/Linux"'
UBUNTU='"Ubuntu"'
AMAZON='"Amazon Linux"'

if [ "$UBUNTU" = "$OS_RELEASE" ]; then
    apt_depends
elif [ "$CENT_OS" = "$OS_RELEASE" ]; then
    yum_depends
elif [ "$DEBIAN" = "$OS_RELEASE" ]; then
    apt_depends
elif [ "$AMAZON" = "$OS_RELEASE" ]; then
    yum_depends
fi


# Run K3S
curl -sfL https://get.k3s.io | sh -s - --node-name node1 --disable traefik
alias kubectl='k3s kubectl'

sleep 30

kubectl get nodes

echo "Making K3S Akash Ready.."

!/bin/bash

kubectl label nodes node1 akash.network/role=ingress

kubectl apply -f https://raw.githubusercontent.com/ovrclk/akash/v0.14.1/pkg/apis/akash.network/v1/crd.yaml
kubectl apply -f https://raw.githubusercontent.com/ovrclk/akash/v0.14.1/pkg/apis/akash.network/v1/provider_hosts_crd.yaml

kubectl get crd -n kube-system

kubectl apply -f https://raw.githubusercontent.com/ovrclk/akash/v0.14.1/_docs/kustomize/networking/network-policy-default-ns-deny.yaml

git clone --depth 1 -b v0.14.1 https://github.com/ovrclk/akash.git
cd akash
kubectl apply -f _docs/kustomize/networking/namespace.yaml
kubectl kustomize _docs/kustomize/akash-services/ | kubectl apply -f -

cat >> _docs/kustomize/akash-hostname-operator/kustomization.yaml <<'EOF'
images:
  - name: ghcr.io/ovrclk/akash:stable
    newName: ghcr.io/ovrclk/akash
    newTag: 0.14.1
EOF

kubectl kustomize _docs/kustomize/akash-hostname-operator | kubectl apply -f -

kubectl apply -f https://raw.githubusercontent.com/ovrclk/akash/v0.14.1/_run/ingress-nginx-class.yaml

kubectl apply -f https://raw.githubusercontent.com/ovrclk/akash/v0.14.1/_run/ingress-nginx.yaml

# check if ubuntu
apt-get install unzip

cd ..

AKASH_VERSION="0.14.1"

curl https://raw.githubusercontent.com/ovrclk/akash/master/godownloader.sh | sh -s -- "v$AKASH_VERSION"


sleep 20


echo "Enabling Gvisor..."


# Enable Gvisor
function install_gvisor() {
    set -e
    URL=https://storage.googleapis.com/gvisor/releases/release/latest
    wget ${URL}/runsc ${URL}/runsc.sha512 \
    ${URL}/gvisor-containerd-shim ${URL}/gvisor-containerd-shim.sha512 \
    ${URL}/containerd-shim-runsc-v1 ${URL}/containerd-shim-runsc-v1.sha512
    sha512sum -c runsc.sha512 \
    -c gvisor-containerd-shim.sha512 \
    -c containerd-shim-runsc-v1.sha512
    rm -f *.sha512
    chmod a+rx runsc gvisor-containerd-shim containerd-shim-runsc-v1
    sudo mv runsc gvisor-containerd-shim containerd-shim-runsc-v1 /usr/local/bin
}

install_gvisor


cp /var/lib/rancher/k3s/agent/etc/containerd/config.toml \
/var/lib/rancher/k3s/agent/etc/containerd/config.toml.back

cp /var/lib/rancher/k3s/agent/etc/containerd/config.toml.back \
/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl


cat <<EOT >> /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
disabled_plugins = ["restart"]

[plugins.linux]
  shim_debug = true

[plugins.cri.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
EOT


systemctl restart k3s


cat<<EOF | kubectl apply -f -
apiVersion: node.k8s.io/v1beta1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
EOF



# Copy config file
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config