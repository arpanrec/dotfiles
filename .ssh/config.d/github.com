Host github.com
    User git
    HostName github.com
    PreferredAuthentications publickey
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/config.d/github.com_known_hosts
    IdentityFile ~/.ssh/github.com
