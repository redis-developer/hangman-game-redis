#!/bin/bash

if [ ! -f "deploy-build.json" ]; then
    mvn -f cloud.xml -Dsource.directory=../ -Dtarget.directory=../ clean package
    build_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"build_completed_at\": \"$build_timestamp\"}" > deploy-build.json
fi

terraform init
terraform apply -auto-approve
