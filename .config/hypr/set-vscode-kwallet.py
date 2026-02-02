#!/usr/bin/env python3

import os
import json

home = os.environ.get("HOME")
vscode_dir = os.path.join(home, ".vscode")
argv_path = os.path.join(vscode_dir, "argv.json")

os.makedirs(vscode_dir, exist_ok=True)

data = {}

if os.path.isfile(argv_path):
    with open(argv_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        if not isinstance(data, dict):
            raise TypeError("argv.json must contain a JSON object")

# data["password-store"] = "kwallet5"
if "password-store" not in data:
    data["password-store"] = "kwallet5"

    with open(argv_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)
        f.write("\n")
