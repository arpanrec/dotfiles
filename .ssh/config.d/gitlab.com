Host gitlab.com
    User git
    HostName gitlab.com
    PreferredAuthentications publickey
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/config.d/gitlab.com_known_hosts
    IdentityFile ~/.ssh/id_rsa_gitlab
