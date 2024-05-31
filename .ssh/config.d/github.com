Host github.com
  User git
  HostName github.com
  PreferredAuthentications publickey
  StrictHostKeyChecking yes
  UserKnownHostsFile ~/.ssh/known_hosts
  IdentityFile ~/.ssh/github.com
