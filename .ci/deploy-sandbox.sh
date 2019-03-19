mkdir -p ~/.ssh
chmod 700 ~/.ssh

eval "$(ssh-agent -s)" #start the ssh agent

echo "$DEPLOYMENT_KEY" | tr -d '\r' | ssh-add - > /dev/null

ssh-keyscan corepoint.chromatin.ca >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts

git remote add deploy dokku@corepoint.chromatin.ca:prison-rideshare-api-sandbox
git config --global push.default simple
# FIXME change branch
git push deploy HEAD:primary

ssh -t dokku@corepoint.chromatin.ca -- run prison-rideshare-api-sandbox mix reset_sandbox
