#!/bin/bash

# Simple simple script that creates a cluster
set -x
tim eksctl create cluster \
--name anotha-one \
--version 1.22 \
--region ap-southeast-1 \
--nodegroup-name eu-workers \
--node-type t3.medium \
-nodes 2 \
--nodes-min 1 \
--nodes-max 4 \
--managed