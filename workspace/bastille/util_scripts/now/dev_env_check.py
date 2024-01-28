#!/usr/bin/env python
"""
    Check if the Development environment is set up properly.
"""
from shutil import which
import os
import sys
import pkg_resources

# Fail is running as root
if os.geteuid() == 0:
    sys.exit("This script should not run as root")

# Fail if running in virtual environment
get_base_prefix_compat = getattr(sys, "base_prefix", None) \
    or getattr(sys, "real_prefix", None) \
    or sys.prefix

if get_base_prefix_compat != sys.prefix:
    sys.exit("Deactivate the virtual env")

# Check for tools
list_tools: list[str] = ["jq", "git", "gcc", "curl", "tar", "wget", "bw",
                         "code"]

for tool in list_tools:
    if which(tool):
        print(f"{tool} Installed properly in {which(tool)}")
    else:
        sys.exit(f"{tool} is not installed")

for i in pkg_resources.working_set:
    print(f"{i.key} Installed properly")

# Get pip packages

pip_tools: list[str] = ["git-python", "konsave", "python-gnupg"]
for pip_pkg in pip_tools:
    if pip_pkg in list(pkg_resources.working_set):
        print(f"{pip_pkg} Installed properly")
    else:
        sys.exit(f"{pip_pkg} is not installed")
