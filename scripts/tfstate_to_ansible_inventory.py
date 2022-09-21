#!/usr/bin/env -S python3 -u
"""This script converts a Terraform state file (pulled from GitLab) into
an ansible-inventory file, in YAML format.
"""

import base64
import json
import os
import pathlib
import sys
from argparse import ArgumentParser

import requests
import yaml

# Keys
ALL_KEY = "all"
CHILDREN_KEY = "children"
HOSTS_KEY = "hosts"
SSH_KEY_LOCATIONS = [
    "../resources/keys",
    "./keys",
    "~/.ssh",
    ".",
    "..",
]


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


def get_inventory(state, inventory_type):
    """
    Gets all the inventories of a given type
    """
    result = {}
    for resource in state:
        if (
            resource["mode"] == "managed"
            and resource["type"] == "null_resource"
            and resource["name"] == "inventory"
        ):
            inventory_info = resource["instances"][0]["attributes"]["triggers"]
            inventories = json.loads(
                base64.b64decode(inventory_info["inventory"]).decode("utf-8")
            )
            if inventory_info["type"] == inventory_type:
                for (inventory_id, inventory_value) in inventories.items():
                    result[inventory_id] = inventory_value

    return result


def get_ssh_config(host_name, user, host_ip, keypair, jump_host=None):
    """
    Creates an SSH host entry for an host, to be added to an ssh
    config file
    """
    identities = "\n".join(
        [
            f"    IdentityFile {location}/{keypair}.pem"
            for location in SSH_KEY_LOCATIONS
        ]
    )

    return f"""
Host {host_name}
    Hostname {host_ip}
    User {user}
{identities}
    {f"ProxyJump {jump_host}" if jump_host is not None else ""}
"""


parser = ArgumentParser(
    description="Terraform State to Ansible Inventory Conversion Tool"
)
parser.add_argument(
    "-o",
    dest="output",
    required=False,
    default="inventory",
    help="output directory",
)
parser.add_argument(
    "--display",
    default=False,
    action="store_true",
    help="set to output the generated inventory",
)
args = parser.parse_args()

# Create output directory
output = os.path.abspath(args.output)
pathlib.Path(output).mkdir(parents=True, exist_ok=True)

# Get state using HTTP
url = get_env(["TF_STATE_ADDRESS", "TF_HTTP_ADDRESS"])
username = get_env(["TF_STATE_USERNAME", "TF_HTTP_USERNAME"])
password = get_env(["TF_STATE_PASSWORD", "TF_HTTP_PASSWORD"])

print(f"Getting state from {url}")
tf_state_request = requests.get(url, auth=(username, password), timeout=60)
if tf_state_request.status_code != 200:
    content = json.dumps(tf_state_request.json(), indent=4)
    print(f"** ERROR [{tf_state_request.status_code}]:\n{content}")
    sys.exit(tf_state_request.status_code)

tf_state = tf_state_request.json().get("resources", [])

# Get class inventories
cis = get_inventory(tf_state, "cluster")
igis = get_inventory(tf_state, "instance_group")
iis = get_inventory(tf_state, "instance")

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
    **{  # all with groups and single hosts
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
inventory_path = os.path.join(output, "inventory.yml")
with open(inventory_path, "w+", encoding="utf-8") as f:
    yaml.safe_dump(inventory, indent=2, stream=f)
    print(f"Inventory at {inventory_path}")

# Create ssh config
ssh_config = ["BatchMode yes", "StrictHostKeyChecking no", "LogLevel QUIET"]

# Add jump hosts
jump_hosts = {}
for (ii_id, ii) in iis.items():
    jump_hosts[ii["jump_host"]["hostname"]] = ii["jump_host"]
    ssh_config.append(
        get_ssh_config(
            host_name=ii_id,
            user=ii["ansible_user"],
            host_ip=ii["ip"],
            keypair=ii["keypair"],
            jump_host=ii["jump_host"]["hostname"],
        )
    )

for (host, config) in jump_hosts.items():
    ssh_config.append(
        get_ssh_config(
            host_name=host,
            user=config["user"],
            host_ip=config["ip"],
            keypair=config["keypair"],
        )
    )

# Output ssh config
ssh_config_path = os.path.join(output, "ssh.config")
with open(ssh_config_path, "w+", encoding="utf-8") as f:
    f.write("\r\n".join(ssh_config))
    print(f"SSH Config at {ssh_config_path}")
