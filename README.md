# Building a Server and deploying Application using Ansible Playbooks.

This repos will use Ansible to open docker based web site container on remote machine.
Remote machine will have nginx proxy in front of container

## Directory Layout

production                # inventory file for production servers
stage                     # inventory file for stage environment

group_vars/
   group1                 # here we assign variables to particular groups
   group2                 # ""
host_vars/
   hostname1              # if systems need specific variables, put them here
   hostname2              # ""

library/                  # if any custom modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

playbooks/                
   bootstrap.yml          # playbook for bootstrap a server
   docker.yml             # playbook for docker shell command, include start, stop...
   roles/
      docker/
         tasks/
            main.yml
      update/
         tasks/
            main.yml
      nginx/
         tasks/
            main.yml


roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""

## Command

1. Create a site
<pre>ansible-playbook -k -i {inventory} playbooks/docker.yml --user=gloomcheng --ask-sudo-pass --extra-vars "DOMAIN={example.com} PORT_WWW={8001} PORT_DB={10001} REPOS={netivism/docker-wheezy-php55} PASSWD={db1234}" --tags=start</pre>
<pre>ansible-playbook -k -i {inventory} playbooks/docker.yml --user=gloomcheng --ask-sudo-pass --extra-vars "DOMAIN={example.com}" --tags=restart</pre>

## Note

1. Add host to /etc/ansible/hosts
