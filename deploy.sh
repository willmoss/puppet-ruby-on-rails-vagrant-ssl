#!/bin/bash 

############################
# Deploy puppet scripts to remote server
############################

source config.sh

git archive --format=tar master | gzip -9c | ssh $DEPLOY_USER@$DEPLOY_SERVER "tar --directory=/etc/puppet -xvzf - && cd /etc/puppet && librarian-puppet install"

# copy in (config) files outside of git
# http://superuser.com/questions/82445/how-to-upload-a-file-from-the-command-line-with-ftp-or-ssh
scp "user-modules/user/manifests/webapp.pp" $DEPLOY_USER@$DEPLOY_SERVER:/etc/puppet/user-modules/user/manifests/webapp.pp

# now run sudo puppet apply --verbose manifests/site.pp
