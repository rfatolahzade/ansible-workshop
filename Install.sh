yum install bash-completion -y
bash
hostnamectl set-hostname Ansible
yum install epel-release -y
yum install -y ansible
ansible --version
#adhoc command:
ansible -m ping localhost