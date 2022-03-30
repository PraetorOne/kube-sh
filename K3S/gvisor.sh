

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

