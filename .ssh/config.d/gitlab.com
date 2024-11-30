Host gitlab.com
    User git
    HostName gitlab.com
    PreferredAuthentications publickey
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts.d/gitlab.com
    IdentityFile ~/.ssh/gitlab.com
