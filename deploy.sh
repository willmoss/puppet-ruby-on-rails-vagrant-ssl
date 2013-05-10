#!/bin/bash 

#http://wildlyinaccurate.com/deploying-a-git-repository-to-a-remote-server

git archive --format=tar origin/master | gzip -9c | ssh root@5.79.22.251 "tar --directory=/etc/puppet -xvzf -"
