#!/bin/bash

# Step 1. Create GCP VM Instance
gcloud compute instances create reddit-app \
--image-family reddit-base \
--machine-type=g1-small \
--boot-disk-size=10GB \
--tags puma-server \
--restart-on-failure

# Step 2. Create firewall rule
gcloud compute firewall-rules create default-puma-server \
--allow tcp:9292 \
--target-tags=puma-server \
--source-ranges 0.0.0.0/0
