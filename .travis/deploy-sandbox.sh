openssl aes-256-cbc -K $encrypted_efc605b46718_key -iv $encrypted_efc605b46718_iv -in .travis/deploy.key.enc -out .travis/deploy.key -d
chmod 600 .travis/deploy.key # this key should have push access

eval "$(ssh-agent -s)" #start the ssh agent
ssh-add .travis/deploy.key
ssh-keyscan corepoint.chromatin.ca >> ~/.ssh/known_hosts

git remote add deploy dokku@corepoint.chromatin.ca:prison-rideshare-api-sandbox
git config --global push.default simple
git push deploy dokku-sandbox:primary

ssh -t dokku@corepoint.chromatin.ca -- run prison-rideshare-api-sandbox mix reset_sandbox
