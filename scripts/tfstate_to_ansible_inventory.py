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
cluster_inventories = get_inventory(tf_state, "cluster")
instance_group_inventories = get_inventory(tf_state, "instance_group")
instance_inventories = get_inventory(tf_state, "instance")

# Parse groupings
instance_groups = {}
instance_groups_in_clusters = []
instances_with_parent = []

for (cluster_id, cluster) in cluster_inventories.items():
    for instance_group_id in cluster[CHILDREN_KEY]:
        instance_groups_in_clusters.append(instance_group_id)
    for instance_id in cluster[HOSTS_KEY]:
        instances_with_parent.append(instance_id)

for (instance_group_id, instance_group) in instance_group_inventories.items():
    instance_groups[instance_group_id] = {HOSTS_KEY: instance_group[HOSTS_KEY]}
    for instance_id in instance_group[HOSTS_KEY]:
        instances_with_parent.append(instance_id)

# Create inventory
inventory = {
    **{  # all with groups and single hosts
        ALL_KEY: {
            CHILDREN_KEY: {
                **{cluster: None for cluster in cluster_inventories},
                **{
                    instance_group: None
                    for instance_group in instance_group_inventories
                    if instance_group not in instance_groups_in_clusters
                },
            },
            HOSTS_KEY: {
                instance_id: instance
                for (instance_id, instance) in instance_inventories.items()
                if instance_id not in instances_with_parent
            },
        }
    },
    **{  # cluster with instance groups and hosts
        cluster_id: {
            CHILDREN_KEY: {
                instance_group_id: None
                for instance_group_id in cluster[CHILDREN_KEY]
            },
            HOSTS_KEY: cluster[HOSTS_KEY],
        }
        for (cluster_id, cluster) in cluster_inventories.items()
    },
    **{  # instance groups
        instance_group_id: {HOSTS_KEY: instance_group[HOSTS_KEY]}
        for (
            instance_group_id,
            instance_group,
        ) in instance_group_inventories.items()
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
for (instance_id, instance) in instance_inventories.items():
    jump_hosts[instance["jump_host"]["hostname"]] = instance["jump_host"]
    ssh_config.append(
        get_ssh_config(
            host_name=instance_id,
            user=instance["ansible_user"],
            host_ip=instance["ip"],
            keypair=instance["keypair"],
            jump_host=instance["jump_host"]["hostname"],
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
