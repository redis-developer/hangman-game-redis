#!/bin/bash

terraform destroy -auto-approve

if [ -f "deploy-build.json" ]; then
    rm deploy-build.json
fi
