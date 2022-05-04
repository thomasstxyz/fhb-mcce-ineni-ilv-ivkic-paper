# INENI-ILV / Ivkic - scientific paper

The task is to write a scientific paper about a
topic in the realm of cloud computing.

## facts

group E

  - Klaus Thüringer
  - Thomas Stadler

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

## Deployment

- Set the name of your EC2 key pair name

Windows PowerShell:

    $env:TF_VAR_ssh_key = "my_key_pair"

Linux/MacOS:

    export TF_VAR_ssh_key = "my_key_pair"

- Apply Terraform

```
cd terraform
terraform apply
```

This will create EC2 instances and write their public ip addresses into the file `ansible/inventory`.

- Run Ansible Playbook

```
cd ansible
ansible-playbook -i inventory main.yml
```
