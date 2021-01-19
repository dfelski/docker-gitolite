#!/bin/sh
if [[ "${1}" != '/usr/sbin/sshd' ]] || [[ "${2}" != '-D' ]] || [[ "${#}" -ne 2 ]]; then
  echo 'docker-entrypoint.sh NOT called with /usr/sbin/sshd -D'
  exit 1
fi

# generate SSH HostKeys if not provided
# and append them to sshd_config if not already added
for algorithm in dsa ecdsa ed25519 rsa
do
  keyfile="/etc/ssh/keys/ssh_host_${algorithm}_key"
  [[ -f ${keyfile} ]] || ssh-keygen -q -N '' -f ${keyfile} -t ${algorithm}
  grep -q "HostKey ${keyfile}" /etc/ssh/sshd_config || echo "HostKey ${keyfile}" >> /etc/ssh/sshd_config
done

# Fix permissions at every startup
chown -R git:git /var/lib/git

# Setup gitolite admin
if [ ! -f /var/lib/git/.ssh/authorized_keys ]; then
  if [ -n "$SSH_KEY" ]; then
    echo "$SSH_KEY" > "/tmp/git_admin.pub"
    su - git -c "gitolite setup -pk \"/tmp/git_admin.pub\""
    rm "/tmp/git_admin.pub"
  else
    echo "You need to specify SSH_KEY for admin on first run to setup gitolite"
    exit 1
  fi
# Check setup at every startup
else
  su - git -c "gitolite setup"
fi

exec "$@"
