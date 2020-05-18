# Purpose
This is a repository for all the files necessary to have a complete production Django system for blogging - deployed via Docker Swarm.

Directory | Usage 
------------ | -------------
build | Docker build directories
deploy | Docker Swarm deployment descriptors
persistance | Docker unamed volume folders
system | Server deployment scripts


# Example Site

Below are some screenshots of the general look of this project.
Bootstrap 4 and the Bootstrap template Clean Blog is used as the base styling, but Clean Blog has been tweaked alot.

![Content Page](https://github.com/gavin-hutchinson/wagtail-docker-deployment/blob/master/app-pics/home.jpg)

![Blog Index Page](https://github.com/gavin-hutchinson/wagtail-docker-deployment/blob/master/app-pics/blog.jpg)

![Info Index Page](https://github.com/gavin-hutchinson/wagtail-docker-deployment/blob/master/app-pics/info.jpg)

![Contact Page](https://github.com/gavin-hutchinson/wagtail-docker-deployment/blob/master/app-pics/contact.jpg)

# Docker Images

Image | Base | Usage
------------ | ------------- | ------------- 
fe-custom | nginx:1.17.9 | frontend reverse proxy for Django
wagtail-custom | python:3.8-slim | Django with the Wagtail CMS
postgres-custom | postgres:12.0 | database instance for Django
redis-custom | redis:5.0.8 | cache for Django
smtp-custom | alpine:3.10 | mail relay for Django

- To follow best practive each image is built to run as a **non-root** user.
- To follow best practice each image supports Docker secrets.
- The **wagtail-custom** image is split into 2 Dockerfiles in case you would like to tweak and test the application code to suite your needs.
  - Dockerfile 1, application requirements which takes some time to build
  - Dockerfile 2, application code which has a quick build time


# Instructions
Assuming you have Docker installed, Docker Swarm initialized and you're not using Windows to host Docker - do the following.

### Prepare the Docker Images

Edit the Dockerfile of each image to match the `uid` and `gid` of server user deploying the Docker Stack.
As in - Who runs `docker stack deploy blog -c docker-compose.yml`? This is done so the docker volume mounts files have the correct permissions on the Docker host server(s).
```sh
vi build/fe/Dockerfile
vi build/db/Dockerfile
vi build/cache/Dockerfile
vi build/mail/Dockerfile
vi build/app/Dockerfile
```

Build each image.
```sh
cd build/fe
./build-image.sh
```
```sh
cd build/db
./build-image.sh
```
```sh
cd build/cache 
./build-image.sh
```
```sh
cd build/mail
./build-image.sh
```
```sh
cd build/app/code-base
./build-image.sh
```
```sh
cd build/app
./build-image.sh
```

### Prepare Server Files

On your deployment server create the directory location for your Docker Stack files.
This repository assumes your location is `/opt/docker-stacks/blog/`.
If you want to change this location do a search and replace on the entire repository. For instance:
```sh
find . -type f -print0 | xargs -0 sed -i 's^/opt/docker-stacks/blog^/your/new/location^g'
```

Ensure the following folders are transfered to your server's folder above.
```
deploy
persistance
system
```

### Create Certificates

For local testing, just use self-signed certificates.

For production, create the certificates for Nginx and Django. A script has been provided here `system/scripts/` for the intial registering of a certificate with LetsEncrypt by using certbot.

Edit the script to place your **domain name in the top section** and run it. As a precaution you may want to add the option `--staging` to the `docker run` command.
This will test if your domain can be issued a certificate. For it to work you need to ensure the proper DNS records are present for your site, see the LetsEncrypt documentation for details.
Once issued the certificates do not need to be transformed they are fine in pem format.
```
./system/scripts/exec-certbot-register.sh
```

### Create Docker Secrets

Edit `deploy/create-secrets.sh` to replace the dummy variables with your own real values. Then run the script - `./deploy/create-secrets.sh`.
The most important secrets are below, all the others will remain the same if the general docker deployment is not edited (for example service names and internal Docker Stack ports).
For `DJANGO_DOCKER_HOSTS` set this to your domain name or local hostname but not localhost.
```bash
#set docker secrets - app
########################################################################

#-------------------------------------------------------------------
echo -n "3" | docker secret create HTTP_WORKER_THREADS -
#-------------------------------------------------------------------
#set like this - domainname1,domainname2
echo -n "yourdomainname" | docker secret create DJANGO_DOCKER_HOSTS -
#-------------------------------------------------------------------
echo -n "Asia/Qatar" | docker secret create DJANGO_TIMEZONE -
echo -n "specialkeyhere" | docker secret create DJANGO_SEC_KEY -
#-------------------------------------------------------------------
echo -n "youremailhere@gmail.com" | docker secret create DJANGO_EMAIL_USER -
#-------------------------------------------------------------------
echo -n "app" | docker secret create DJANGO_DB_USER -
echo -n "apps-R-not4-EATS" | docker secret create DJANGO_DB_PASS -
echo -n "appdb" | docker secret create DJANGO_DB_NAME -
#-------------------------------------------------------------------

#set docker secrets - db
########################################################################

#-------------------------------------------------------------------
echo -n "root" | docker secret create POSTGRES_USER -
echo -n "r00t5-dont-GROW_here" | docker secret create POSTGRES_PASSWORD -
echo -n "rootdb" | docker secret create POSTGRES_DB -
echo -n "app" | docker secret create APP_USER -
echo -n "apps-R-not4-EATS" | docker secret create APP_USER_PASSWORD -
echo -n "appdb" | docker secret create APP_DB -
#-------------------------------------------------------------------

#set docker secrets - mail
########################################################################

#-------------------------------------------------------------------
echo -n "emailpassword" | docker secret create SMTP_PASSWORD -
#-------------------------------------------------------------------
```

### Edit Compose File

This variable controls whether the Nginx logs will be preserved across container restarts.
```yaml
x-fe-environment: &fe-environment
  LOG_RETENTION: "false"
```

This section refers to application settings. Instead of using a menu management pacakge and templatetags, I have implemented search and replace in the startup of the **wagtail-custom** container for these values.
```yaml
x-app-environment: &app-environment
  SITE_TITLE: "My Site"
  SITE_FOOTER: 'Thanks for checking out My Site. Maybe consider visiting some of my social media accounts for more good stuff.'
  A_SITE_NAV_SLUG: "home"
  A_SITE_NAV_TITLE: "Home"
  B_SITE_NAV_SLUG: "blog"
  B_SITE_NAV_TITLE: "Blog"
  C_SITE_NAV_SLUG: "archive"
  C_SITE_NAV_TITLE: "Archive"
  D_SITE_NAV_SLUG: "resume"
  D_SITE_NAV_TITLE: "Resume"
  E_SITE_NAV_SLUG: "contact"
  E_SITE_NAV_TITLE: "Contact"
  LINK_GITHUB: "https://github.com"
  LINK_TELEGRAM: "https://telegram.org/"
  LINK_YOUTUBE: "https://youtube.com"
```

This group of variables is for the mail relay service.
Below is an example of how it can be used with Gmail, but **beware** you will need to configure Gmail to accept connections from apps that do not use **oauth2**.

As of writing this, for Gmail to receive relay messages with this service, you need to:
1. enable less secure apps
2. disable unlock captcha
3. disable 2 factor authentication
4. get an app password (use this in your Docker Secret email password)

```yaml
x-mail-environment: &mail-environment
  SMTP_USERNAME: "youremailhere@gmail.com"
  RELAY_TO_USERS: "youremailhere@gmail.com"
  RELAY_TO_HOSTS: "smtp.gmail.com"
  RELAY_FROM_HOSTS: "10.0.0.0/8"
  SMARTHOST: "smtp.gmail.com::587"
```

Edit the file paths in the `fe-custom` and `wagtail-custom` service descriptions to match what you have. Below is the configuration example if LetsEncrypt was utilized.
```yaml
fe:
  image: nginx-custom:latest
  volumes:
    - "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc/live/domain.ext/fullchain.pem:/etc/nginx/ssl/app.crt"
    - "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc/live/domain.ext/privkey.pem:/etc/nginx/ssl/app.key"
    - "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc/live/domain.ext/chain.pem:/etc/nginx/ssl/ca.crt"
```
```yaml
  app:
    image: wagtail-custom:latest
    volumes:
      - "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc/live/domain.ext/fullchain.pem:/app/security/app.crt"
      - "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc/live/domain.ext/privkey.pem:/app/security/app.key"
      - "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc/live/domain.ext/chain.pem:/app/security/ca.crt"
```

Adjust the resource allocation on each service as you require.
```yaml
resources:
  limits:
    memory: 256M
```

Ensure the following files are in place. Every other unamed volume is an empty folder for logs or data.
```sh
persistance/app/img/error-page.jpg #this is displaying 403,404,500,etc
persistance/app/img/favicon.ico #this is the icon displayed in the browser tab
```

### Deploy the Docker Stack

Deploy with whatever stack name you want.
```sh
docker stack deploy blog -c deploy/docker-compose.yml
```

Create the administration user for Django by opening an interactive shell with the Docker Container for `wagtail-custom`. For example:
```
docker exec -it blog_app.1.1mzk3shd7a3k6twmo9c3r2dnf bash
cd /app/service-init
./create-user.sh
```

Go here to see your resulting web application - **https://hostname/admin**
Follow the Wagtail documentation if you are not familiar with using the admin interface.


### Ensuring Email works as expected on the Contact Form

In Wagtail when you create the Contact page, make sure to name your fields as the following or else the CSS styling will not look very good.
- Name
- Email Address
- Message


# Optional Instruction - Automatic Renewal of LetsEncrypt Certificates

LetsEncrypt certificates expire after 90 days, but due to certbot's built-in mechanism one can always check for renewal.
If the certificate is close to expire, as of this writing it's 60 days or older, the certificate can be renewed.

A script has been provided to do this renewal process with a cronjob, `system/exec-certbot-renew.sh`. If you are to install certbot directly on a server, a cronjob will be configured for everyday checks as recommended by LetsEncrypt.

Depending on the setting, Certbot running in standalone mode uses port 80 or 443 to request a new certificate - so in this case I configured my job to run less frequently, only 1 time a week.

This is becasue the running Docker Stack for the system also uses these ports, which means it needs to be down for certbot to run a check or renew. In any use case it's a cronjob that can be easily changed to your liking.

The script is simple and does the following:
1. stop blog stack
1. sleep 60s
1. run renewal check
1. sleep 60s
1. start blog stack

The cronjob command is below, adjust the timing and user, copy it and then add the cronjob by running `crontab -e`. Notice a log has been specified.
```
0 4 * * 0 source /home/user/.profile; /opt/docker-stacks/blog/system/scripts/exec-certbot-renew.sh >> /opt/docker-stacks/blog/system/logs/certbot.log 2>&1
```
For the first run of the script you can edit the command to add `--dry-run` to confirm renewal will be okay.

# Optional Instruction - Automatic System Backups

You may want to configure backups of the configuration and persistant files of your Docker Stack.
To do so you can use the 2 scripts provided. One is for copying files to a location of your choosing and the other is for maintaining a set number of backups per your choosing.

Edit both `system/exec-system.backup.sh` and `system/exec-system.backup-cleaning.sh` for the location of your backups.
Edit `exec-system.backup-cleaning.sh` to specify how many backups to choose. It is currently set a 1 week of backups - `BACKUP_RETENTION=7`

To go along with these two scripts there are two cronjobs. Adjust the timing and user as necessary.
```
30 2 * * * source /home/user/.profile; /opt/docker-stacks/blog/system/scripts/exec-system-backup.sh 2> /dev/null
30 3 * * * source /home/user/.profile; /opt/docker-stacks/blog/system/scripts/exec-system-backup-cleaning.sh 2> /dev/null
```

# Optional Instruction - Customizing the Footer and Menu

You can edit 4 files to add/remove menu items and footer items.
1. Add or remove an environment variable from `deploy/docker-compose.yml` for either the menu or footer.
1. Add or remove replacement commands from `build/app/code/service-init/run.sh` and rebuild the app image.
1. Add or remove a navigation or footer chunk from `build/app/code/service/base/templates/base.html` and `build/app/code/service/base/templates/base-default.html`

Look into glyphcons to find the right icons for your needs.

# Additional Notes

* Port 80 is exposed becaused nginx redirects http to https.
* `persistance/fe/conf/nginx.conf` can be edited to suite your needs but the default state will get an A+ on SSL Labs.
  * Build the `fe-custom` image with your edited conf file or map it in by adding a volume entry under **fe** service in the compose file.
    `- "/home/gavin/Desktop/projects/blog/persistance/fe/conf/nginx.conf:/etc/nginx/nginx.conf"`
* To have the best cropping of your images these are the ideal dimensions
  * headers - **width 1000px / height 700px**
  * image streamfield blocks - **width 878px / height 590px**
