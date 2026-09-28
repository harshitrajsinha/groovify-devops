# Seed service

This service is dedicated to seed songs to the database for groovify application so that frontend/backend do not need to store it locally to serve at application startup.

`songs/` contains songs and cover images that will be seeded to AWS S3 and metadata of these songs will be seeded into the database.

<!-- ```
sudo curl -fsSL \
  https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
  -o /opt/certs/global-bundle.pem

sudo chmod 444 /opt/certs/global-bundle.pem
``` -->