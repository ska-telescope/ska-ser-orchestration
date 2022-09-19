#!/usr/bin/env -S python3 -u
"""This script converts a Terraform state file (pulled from GitLab) into
an ansible-inventory file, in YAML format.
"""

import json
import os
import pathlib
import sys

import requests
import yaml


def get_env(variables, default=None):
    """
    Returns the first defined environment variable value for a set of
    variables. If none of the variables are found, returns a default.
    """
    for k in variables:
        value = os.environ.get(k, None)
        if value is not None:
            return value

    return default


def merge(data):
    """
    Merges a set of maps, inside a list, into a single map.
    """
    result = {}
    for obj in data:
        for (key, value) in obj.items():
            result[key] = value
    return dict(result)


def extract(var, parent_key, key, value=None):
    """
    Extracts from a dictionary the all objects that contains
    a match between the required key and value.
    """
    if isinstance(var, dict):
        _value = var.get(key, None)
        if value is not None and _value == value:
            yield {parent_key: var}
        if value is None and _value is not None:
            yield {parent_key: var}
        for (_key, _value) in var.items():
            if isinstance(_value, (dict, list)):
                yield from extract(_value, _key, key, value)


def get_inventory(state, key="inventory_type", value=None):
    """
    Gets all the inventories of a given type. To get instance
    inventories we should look for variables present in the
    instance's inventory.
    """
    return merge(list(extract(state, None, key, value)))


# Keys
ALL_KEY = "all"
CHILDREN_KEY = "children"
HOSTS_KEY = "hosts"

# Get state using HTTP
url = get_env(["TF_STATE_ADDRESS", "TF_HTTP_ADDRESS"])
username = get_env(["TF_STATE_USERNAME", "TF_HTTP_USERNAME"])
password = get_env(["TF_STATE_PASSWORD", "TF_HTTP_PASSWORD"])

print(f"Getting state from {url}", file=sys.stderr)
tf_state_request = requests.get(url, auth=(username, password), timeout=60)
if tf_state_request.status_code != 200:
    content = json.dumps(tf_state_request.json(), indent=4)
    print(
        f"** ERROR [{tf_state_request.status_code}]:\n{content}",
        file=sys.stderr,
    )
    sys.exit(tf_state_request.status_code)

tf_state = tf_state_request.json()

# Curate output given actual resources
# The output of a destroyed resource remains in state
# if we run apply/destroy with -target
expected_output_blocks = []
for created_components in tf_state["resources"]:
    expected_output_blocks.append(created_components["module"].split(".")[1])

expected_output_blocks = [*set(expected_output_blocks)]
tf_state = tf_state["outputs"]

for expected_output in expected_output_blocks:
    if expected_output not in tf_state.keys():
        print(
            f"** ERROR: Expected to have an output block\
                for module '{expected_output}'",
            file=sys.stderr,
        )

for output in tf_state.keys():
    if output not in expected_output_blocks:
        print(
            "** WARNING: Output for '{output}' in state but\
                 no resources were found",
            file=sys.stderr,
        )

for output in tf_state:
    if output not in expected_output_blocks:
        tf_state[output] = None

# Get class inventories
cis = get_inventory(tf_state, value="cluster")
igis = get_inventory(tf_state, value="instance_group")
iis = get_inventory(tf_state, key="ansible_host")

# Parse groupings
igs = {}
igs_in_c = []
is_with_parent = []

for (ci_id, ci) in cis.items():
    for (ig_id, ig) in ci[CHILDREN_KEY].items():
        igs_in_c.append(ig_id)
    for (i_id, i) in ci[HOSTS_KEY].items():
        is_with_parent.append(i_id)

for (ig_id, ig) in igis.items():
    igs[ig_id] = {HOSTS_KEY: ig[HOSTS_KEY]}
    for (i_id, i) in ig[HOSTS_KEY].items():
        is_with_parent.append(i_id)

# Create inventory
inventory = {
    **{  # all with groups and loose hosts
        ALL_KEY: {
            CHILDREN_KEY: {
                **{c: None for c in cis},
                **{ig: None for ig in igis if ig not in igs_in_c},
            },
            HOSTS_KEY: {
                i_id: i
                for (i_id, i) in iis.items()
                if i_id not in is_with_parent
            },
        }
    },
    **{  # cluster with instance groups and hosts
        c_id: {
            CHILDREN_KEY: {ig_id: None for ig_id in c[CHILDREN_KEY]},
            HOSTS_KEY: c[HOSTS_KEY],
        }
        for (c_id, c) in cis.items()
    },
    **{  # instance groups
        ig_id: {HOSTS_KEY: ig[HOSTS_KEY]} for (ig_id, ig) in igis.items()
    },
}

# Output inventory
if len(sys.argv) > 1 and sys.argv[1] is not None:
    path = os.path.abspath(sys.argv[1])
    pathlib.Path(os.path.dirname(path)).mkdir(parents=True, exist_ok=True)
    with open(path, "w+", encoding="utf-8") as f:
        yaml.safe_dump(inventory, indent=2, stream=f)
        print(f"Inventory at {path}", file=sys.stderr)
else:
    yaml.safe_dump(inventory, indent=2, stream=sys.stdout)
