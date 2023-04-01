# Stagit docker

Available on [dockerhub](https://hub.docker.com/r/caaallum/stagit-server)

## Run
```bash
$ docker run -d -p 222:22 -p 8080:80 -e GIT_OWNER=owner -e GIT_URL=url -v /path/to/ssh/keys:/keys -v html:/html -v repos:/repos caaallum/stagit-server
```

## Example localhost
Create ssh key
```bash
$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/stagit
```

Start server
```bash
$ docker run -d -p 222:22 -p 8080:80 -e GIT_OWNER=caaallum -e GIT_URL=localhost -v ~/.ssh:/keys -v html:/html -v repos:/repos caaallum/stagit-server
```

Add git to ssh config
```
~/.ssh/config
Host localhost
    User git
    Hostname localhost
    Port 222
    IdentityFile ~/.ssh/stagit
    PreferredAuthentications publickey
```

Create a repo
```bash
$ ssh localhost init test test
```

Clone repo and update repo
```bash
$ git clone git@localhost:22/repos/test.git
$ cd test
$ echo "# test" > README.md
$ git add README.md
$ git commit -m "Added readme"
$ git push origin master
```

Head to localhost:8080
