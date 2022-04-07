---
title:  "Kubernetes Bare Metal Setup Using Debian"
excerpt: "Setting up Debian on Bare Metal for Kubernetes"
tags: "kubernetes, bare metal, k8s"
---

## Notes

### Adjust BIOS settings

    1. Turn off powersaving features
    1. Allow boot from USB
    1. etc.

### Install Debian

    1. Text-based install
    1. Deselect Gnome, don't need it 

### Debian Config

1. Add user to sudoers:
    ```bash
    % su
    % apt install sudo
    % /usr/sbin/usermod -aG sudo <username>
    % systemctl reboot 
    ```
1. Turn off powersaving features (sleep, suspend, hibernate):
    ```bash
    % sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    % sudo systemctl restart systemd-logind.service
    
    # Verify it's off (inactive):
    % systemctl status sleep.target suspend.target hibernate.target hybrid-sleep.target
    ```
1. Turn off swap:
    ```bash 
    % sudo swapoff -a

    # Make sure swap is 0:
    % free -h 

    # Comment out swap partition from fstab so it doesn't come back on a restart, then save it:
    % sudo vi /etc/fstab

    # Reboot:
    % sudo systemctl reboot
    ```

### Load br_netfilter

```bash
% sudo modprobe br_netfilter

# Check it loaded:
% lsmod | grep br_netfilter

# Create config files:
% cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

% cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply the configs using sysctl:
% sudo sysctl --system
```

### Install containerd 

It's preferred to use containerd instead of a full Docker install.

```bash
# First, install curl, gnupg, gnupg2 and gnupg1:
% sudo apt-get update
% sudo apt install curl && sudo apt install gnupg && sudo apt install gnupg2 && sudo apt install gnupg1

# Add Docker's apt-key:
% curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# Add docker to apt:
% echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" |sudo tee /etc/apt/sources.list.d/docker.list

# Update apt, then install containerd:
% sudo apt update
% sudo apt install containerd

# Create containerd config:
% sudo mkdir -p /etc/containerd
% sudo su -
% containerd config default  /etc/containerd/config.toml

# Edit config.toml, you need to comment out "disabled_plugins = ["cri"]" by adding a # at the start of the line:
% sudo vi /etc/containerd/config.toml

# Turn on IP forwarding:
% echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Restart containerd:
% sudo systemctl restart containerd

# Logout out of su:
% exit
```

### Install Kubernetes

1. Install Kubernetes
    ```bash
    # Add Google's apt-key:
    % curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    # Add kubernetes to apt:
    % cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF

    % sudo apt-get update

    # Install kubelet, kubeadm, and kubectl:
    % sudo apt-get install -y kubelet kubeadm kubectl

    # Set a hold on kubelet, kubeadm, and kubectl:
    % sudo apt-mark hold kubelet kubeadm kubectl

    # Make sure swap is off:
    % sudo swapoff -a

    # reboot:
    % sudo systemctl reboot
    ```
1. On the control-plane, initialize kubeadm:
    ```bash
    # Initialize kubeadm, the output will include the join command you'll need for worker nodes, make sure to copy this down:
    % sudo kubeadm init

    # Copy the config file (running as a regular user):
    % mkdir -p $HOME/.kube
    % sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    % sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install weave-net:
    % kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

    # deploy nginx ingress:
    % kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/baremetal/deploy.yaml

    # Verify ingress:
    % kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch
    ```
1. On the worker nodes, initialize kubeadm using the 'join' command given in the previous step:
    ```bash

    # Where 'ip/host given', 'token given', 'hash given' are based on your install, this entire command with the correct values were provided in the previous step when you initialized kubeadmin

    % kubeadm join <ip/host given>:6443 --token <token given>  --discovery-token-ca-cert-hash <hash given> 
    ```

### Install a load balancer

1. For metallb, see: [this youtube video](https://www.youtube.com/watch?v=xYiYIjlAgHY)