#!/usr/bin/env python3

import sys
import os

try:
    import gitlab
except ImportError as ex:
    print(f"Please install hvac module in a virtualenv and try again. {ex}")
    print("python3 -m venv venv")
    print("source venv/bin/activate")
    print("pip install python-gitlab")
    sys.exit(1)

private_token = os.environ.get("GL_PROD_API_KEY", None)
if private_token is None:
    print("Please set GL_PROD_API_KEY")
    sys.exit(1)

project_id = input("Enter project id: ")

print(f"Project id is {project_id}")

gl = gitlab.Gitlab(private_token=private_token)
project = gl.projects.get(project_id)
while True:
    pipelines = project.pipelines.list(iterator=True, per_page=5)
    if len(pipelines) == 0:
        break
    for pipeline in pipelines:
        print(f"Deleting pipeline f{pipeline}")
        pipeline.delete()
