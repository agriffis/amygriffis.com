# amygriffis.com

To get started developing this site, first clone from gitlab:

```
git clone git@gitlab.com:scampersand/amygriffis.com.git
```

If this doesn't work, then you might need to be added to the project, or you
might not have uploaded an ssh key. See https://gitlab.com/profile/keys

Once the project is cloned, you should be able to bring up the Vagrant VM:

```
cd amygriffis.com
vagrant up
```

## Dev server

When vagrant is running, you can launch the server. Note first the port you're
running on, for example mine is on port 2202:

```
--- 0 aron@gargan [master] [vagrant up 2202] ~/src/ss/amygriffis.com -----------
```

To launch your server:

```
vagrant ssh
cd src
make dev
```

Now you should be able to access gargan.jupiter on the port from above. Mine is
at http://gargan.jupiter:2202

## Deployment

To deploy to Dreamhost, first press ctrl-c to stop your dev server. Then inside
vagrant, in the src dir just like running the dev server, run the publish
target:

```
make publish
```
