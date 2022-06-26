# INENI-ILV / Ivkic - scientific paper

The task is to write a scientific paper about a
topic in the realm of cloud computing.

## facts

group E

  - Klaus Thüringer
  - Thomas Stadler
  - Stephan Pilwax

poster

  - due on 2022-04-22
  - 1 slide

position paper

  - due on 2022-05-19

final paper

  - due on 2022-07-01


chapters

  - introduction
  - related work
  - methodology
  - conclusion & future work

## Development environment with Vagrant/Virtualbox

Install [Oracle Virtualbox](https://www.virtualbox.org/wiki/Downloads) and
[Hashicorp Vagrant](https://www.vagrantup.com/downloads) on your machine.

Create your VM with Vagrant.

    vagrant up

Open a shell to your VM.

    vagrant ssh

Now, inside the VM, navigate to `/vagrant`, which is 
where the current directory is mapped.

    cd /vagrant

Before continuing with the deployment in the next section, 
setup your `~/.aws/credentials`
and your private SSH key.

## Deployment

### Terraform

- Set the name of your EC2 key pair name

for Windows PowerShell:

    $env:TF_VAR_ssh_key = "my_key_pair"

for Linux/MacOS:

    export TF_VAR_ssh_key="my_key_pair"

- Apply Terraform

```
cd terraform
terraform apply
```

This will create EC2 instances and write their public ip addresses into the file `ansible/inventory`.

### Ansible

- Run Ansible Playbook

```
cd ansible
ansible-playbook -i inventory main.yml
```

### Kubernetes

Create a Kubernetes deployment with `nginx` as the container image for pods.

    kubectl create deployment nginx-deployment --image nginx

Expose the service on a `NodePort`.

    kubectl expose deployment nginx-deployment --port 80 --type NodePort

Scale the pods by specifying the replica count.

    kubectl scale --replicas 2 deployment/nginx

Add a `nodeSelector` label `"kubernetes.io/arch": "arm64"` to the nginx-deployment.
This causes all affected pods to be rescheduled to the arm64 nodes.

    kubectl patch deployment nginx-deployment -p '{"spec": {"template": {"spec": {"nodeSelector": {"kubernetes.io/arch": "arm64"}}}}}'

