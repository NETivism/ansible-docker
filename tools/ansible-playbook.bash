#!/bin/env bash

_ansible_playbook() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    local previous_word=${COMP_WORDS[COMP_CWORD - 1]}

    if [[ "$current_word" == -* ]]; then
        _ansible_complete_options "$current_word"
    elif [[ "$current_word" == @* ]]; then
        _ansible_target "$current_word"
    else
        _ansible_playbook_yml "$current_word"
    fi
}

# Compute completion for the generics options
_ansible_complete_options() {
    local current_word=$1
    local options="--ask-become-pass -k --ask-pass --ask-su-pass
                   -K --ask-sudo-pass --ask-vault-pass -b --become
                   --become-method --become-user -C --check -c
                   --connection -D --diff -e --extra-vars --flush-cache
                   --force-handlers -f --forks -h --help -i
                   --inventory-file -l --limit --list-hosts
                   --list-tags --list-tasks -M --module-path
                   --private-key --skip-tags --start-at-task
                   --step -S --su -R --su-user -s --sudo -U --sudo-user
                   --syntax-check -t --tags -T --timeout -u --user
                   --vault-password-file -v --verbose --version"

    COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
}

_ansible_playbook_yml(){
   local word=`echo $1 | sed -e 's/\/etc\/ansible\/playbooks\///g'`
   COMPREPLY=( $(
     cd /etc/ansible/playbooks && \
     compgen -f -X '!*.yml' -- "$word" | awk '{print "/etc/ansible/playbooks/"$word}'
   ) )
}

_ansible_target(){
   local word=`echo $1 | sed -e 's/^@//g'`
   word=`echo $word | sed -e 's/\/etc\/ansible\/target\///g'`
   COMPREPLY=( $(
     cd /etc/ansible/target && \
     compgen -o plusdirs  -f -X '!*' -- "$word" | awk '{print "@/etc/ansible/target/"$1}'
   ) )
}

complete -F _ansible_playbook ansible-playbook
