#!/bin/bash

set -x

sudo apt-get update -y

sudo usermod -aG docker ubuntu

systemctl enable --now docker