#!/bin/bash 

############################
# Install ruby & puppet
############################

source config.sh

#http://wildlyinaccurate.com/deploying-a-git-repository-to-a-remote-server

ssh $DEPLOY_USER@$DEPLOY_SERVER << 'EOF'

# http://askubuntu.com/questions/41605/trouble-downloading-updates-due-to-hash-sum-mismatch-error
sudo rm -fR /var/lib/apt/lists/*

# download & install ruby
aptitude update -y;
aptitude -y install build-essential zlib1g-dev libssl-dev libreadline-dev git-core curl libyaml-dev libcurl4-dev libsqlite3-dev apache2-dev -y;
curl --remote-name http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz;
tar zxf ruby-1.9.3-p194.tar.gz;
cd ruby-1.9.3-p194/ ;
./configure;
make;
make install;

# install puppet & librarian
mkdir /etc/puppet;
gem install puppet --no-ri --no-rdoc;
mkdir -p ~/.puppet/var;
gem install librarian-puppet --no-ri --no-rdoc;

# now run ./deploy.sh

EOF
