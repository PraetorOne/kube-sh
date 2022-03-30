
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