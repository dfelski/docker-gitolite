FROM alpine:3.13

# Install OpenSSH server and Gitolite
# Unlock the automatically-created git user
RUN set -x \
 && apk add --no-cache gitolite openssh \
 && passwd -u git

# Volume used to store SSH host keys, generated on first run
VOLUME /etc/ssh/keys

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME /var/lib/git

COPY sshd_config /etc/sshd/sshd_config

# Entrypoint responsible for SSH host keys generation, and Gitolite data initialization
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose port 22 to access SSH
EXPOSE 22

# Default command is to run the SSH setrver
CMD ["/usr/sbin/sshd", "-D"]
