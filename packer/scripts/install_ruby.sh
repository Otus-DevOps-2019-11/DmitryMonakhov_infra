# !/ban/bash
set -e

# Install ruby & bundler
apt update
apt install -y ruby-full ruby-bundler build-essential
