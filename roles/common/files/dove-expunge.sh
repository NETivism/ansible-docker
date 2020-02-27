#!/bin/bash

RUNNING=$(docker ps -q -f name=dovecot)
if [ -n "$RUNNING"  ]; then
  docker exec -i dovecot bash -c "doveadm expunge -A mailbox inbox before 30d"
  docker exec -i dovecot bash -c "doveadm expunge -A mailbox INBOX.CiviMail.processed before 30d"
  docker exec -i dovecot bash -c "doveadm expunge -A mailbox INBOX.CiviMail.ignored before 30d"
fi
