### ansible-workshop

Install pre packages (CentOS_7.6_minimal):
```bash
yum install bash-completion -y
bash
```
In my case I changed the hostname:
```bash
hostnamectl set-hostname Ansible
```
Install the Ansible:
```bash
yum install epel-release -y
yum install -y ansible
```
Checkout:
```bash
ansible --version
#adhoc command:
ansible -m ping localhost
```
Your output will be:
```bash
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
Useful websites so far: [Ansible’s official hub for sharing Ansible content](https://galaxy.ansible.com/), [jsonformatter](https://jsonformatter.curiousconcept.com)

#### Sample project
We need this structure:
```bash
mkdir -p ansible/provision
mkdir -p ansible/provision/roles
mkdir -p ansible/provision/roles/myproject
mkdir -p ansible/provision/roles/myproject/vars
mkdir -p ansible/provision/roles/myproject/default
mkdir -p ansible/provision/roles/myproject/templates
mkdir -p ansible/provision/roles/myproject/handlers
mkdir -p ansible/provision/roles/myproject/files
mkdir -p ansible/provision/roles/myproject/meta
mkdir -p ansible/provision/roles/myproject/tasks
touch ansible/provision/roles/myproject/default/main.yaml
touch ansible/provision/roles/myproject/handlers/main.yaml
touch ansible/provision/roles/myproject/meta/main.yaml
touch ansible/provision/roles/myproject/tasks/main.yaml
touch ansible/provision/roles/myproject/vars/main.yaml
mkdir -p ansible/provision/inventory
touch ansible/provision/myproject.yaml
touch ansible/provision/inventory/hosts

```
Notice, the default inventory file be located in "/etc/ansible/hosts"
The default location for inventory is a file called /etc/ansible/hosts . You can specify a different inventory file at the command line using the -i <path> option

Now i'm going to create playbook for create these directories and files:
First:
```bash
vi ansible/provision/myproject.yaml
```
Fill it as below:
```bash
---
- hosts: localhost  #(List of Hosts in Inventory Directory)
  roles:            #(roles Dir)
        - myproject      #(Project Dir in roles)
```
And then:
```bash
vi ansible/provision/roles/myproject/tasks/main.yaml
```
Our taks:
```bash
- name: create directories for template playbook
  file:
       path: "{{ item }}"
       state: directory
       owner: root
       group: root
       mode: 0755
  loop:
    - ~/sampleTemplate/provision
    - ~/sampleTemplate/provision/roles
    - ~/sampleTemplate/provision/roles/myproject
    - ~/sampleTemplate/provision/roles/myproject/vars
    - ~/sampleTemplate/provision/roles/myproject/default
    - ~/sampleTemplate/provision/roles/myproject/templates
    - ~/sampleTemplate/provision/roles/myproject/handlers
    - ~/sampleTemplate/provision/roles/myproject/files
    - ~/sampleTemplate/provision/roles/myproject/meta
    - ~/sampleTemplate/provision/roles/myproject/tasks
    - ~/sampleTemplate/provision/inventory
  tags: template

- name: create yaml files for template playbook
  file:
       path: "{{ item }}"
       state: touch
       owner: root
       group: root
       mode: 0755
  loop:
    - ~/sampleTemplate/provision/roles/myproject/default/main.yaml
    - ~/sampleTemplate/provision/roles/myproject/handlers/main.yaml
    - ~/sampleTemplate/provision/roles/myproject/meta/main.yaml
    - ~/sampleTemplate/provision/roles/myproject/tasks/main.yaml
    - ~/sampleTemplate/provision/roles/myproject/vars/main.yaml
    - ~/sampleTemplate/provision/myproject.yaml
    - ~/sampleTemplate/provision/inventory/hosts
  tags: template
```
  

Now we have to define our Inventory in this case we are going to install our playbook locally:
```bash
vi ansible/provision/inventory/hosts
```
Fill it as below:
```bash
[localhost]
127.0.0.1  ansible_connection=local
```

Now you can install your local playbook:
```bash
ansible-playbook -i ~/ansible-workshop/playbookCreator/provision/inventory  ~/ansible-workshop/playbookCreator/provision/myproject.yaml
```
Take a look to our output:
```bash
tree sampleTemplate/
```
Result:
```bash
sampleTemplate/
└── provision
    ├── inventory
    │   └── anisahosts
    ├── myproject.yaml
    └── roles
        └── myproject
            ├── default
            │   └── main.yaml
            ├── files
            ├── handlers
            │   └── main.yaml
            ├── meta
            │   └── main.yaml
            ├── tasks
            │   └── main.yaml
            ├── templates
            └── vars
                └── main.yaml

11 directories, 7 files

```

Now I'm going to change new sampleTemplate, in my case I have created two other virtual machines and their IPs are as below:
```bash
cat <<EOF >>  ~/sampleTemplate/provision/inventory/hosts
[myservers]
192.168.56.103
192.168.56.102
EOF
```
Now lets define our provision:
```bash
cat <<EOF >> ~/sampleTemplate/provision/myproject.yaml
---
- hosts: localhost  #(List of Hosts in Inventory Directory)
  roles:            #(roles Dir)
        - myproject      #(Project Dir in roles)
		
EOF	
```


My tasks are similar to old playbook but in this case Im going to run task on remove servers:
```bash
cat <<EOF >>  ~/sampleTemplate/provision/roles/myproject/tasks/main.yaml
- name: create testdir in home
  file:
       path: /home/testdir
       state: directory
       owner: root
       group: root
       mode: 0755
  tags: create_dir
  

- name: create file1 in home/testdir
  file:
       path: /home/testdir/file1
       state: touch
       owner: root
       group: root
       mode: 0755
  tags: create_file
  
EOF
```

Now you can install your Servers playbook:
```bash
ansible-playbook -i ~/sampleTemplate/provision/inventory/  ~/sampleTemplate/provision/myproject.yaml
```
Now lets check our tasks:
```bash
ansible -i ~/sampleTemplate/provision/inventory/ -m shell -a "ls /home/testdir" myservers
```
Output:
```bash
192.168.56.103 | CHANGED | rc=0 >>
file1
192.168.56.102 | CHANGED | rc=0 >>
file1
```
