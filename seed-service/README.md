# Seed service

### Objective:

* To move seeding songs (pre-uploading songs onto database as the application starts) away from frontend and backend so that frontend do not require to store songs and cover images files, thereby reducing frontend docker image size.

* Implementation - Seed service would connect to database and AWS S3, loop through an array of objects containging metadata about songs as well as songs and cover images files. The loop will upload songs to database and S3. Finally, once the loop ends, this seed service will terminate.

<!-- ```
sudo curl -fsSL \
  https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
  -o /opt/certs/global-bundle.pem

sudo chmod 444 /opt/certs/global-bundle.pem
``` -->