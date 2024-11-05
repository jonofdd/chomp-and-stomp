#!/bin/bash
cd /root/app
docker stack deploy -c docker-stack.yml hello-world-stack