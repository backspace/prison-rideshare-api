echo $DEPLOYMENT_KEY > .travis/deploy.key
chmod 600 .travis/deploy.key # this key should have push access

mkdir -p ~/.ssh
chmod 700 ~/.ssh

eval "$(ssh-agent -s)" #start the ssh agent
ssh-add .travis/deploy.key
ssh-keyscan corepoint.chromatin.ca >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts

git branch
git show-ref


git remote add deploy dokku@corepoint.chromatin.ca:prison-rideshare-api-sandbox
git config --global push.default simple
# FIXME change branch
git push deploy gitlab-ci:primary

ssh -t dokku@corepoint.chromatin.ca -- run prison-rideshare-api-sandbox mix reset_sandbox
