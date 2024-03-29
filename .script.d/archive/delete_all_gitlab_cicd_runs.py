#!/usr/bin/python3

import argparse
import gitlab

parser = argparse.ArgumentParser()
parser.add_argument("--private_token", type=str, help="Gitlab personal token")
parser.add_argument("--project_id", type=str, help="Project ID")
args = parser.parse_args()
private_token = args.private_token
project_id = args.project_id

gl = gitlab.Gitlab(private_token=private_token)
project = gl.projects.get(project_id)
while True:
    pipelines = project.pipelines.list(iterator=True, per_page=5)
    if len(pipelines) == 0:
        break
    for pipeline in pipelines:
        print(f"Deleting pipeline f{pipeline}")
        pipeline.delete()
