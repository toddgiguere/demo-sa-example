#!/bin/bash
set -e

ibmcloud login

ibmcloud schematics policy create --name "demo-sa-secret-manager-policy" --kind "agent_assignment_policy" --location "us-south" --resource-group "demo-sa-resource-group" --target-file ./agent-policy.json --description "For schematics agent demo, will directly assign the SM example workspace to the demo agent"
