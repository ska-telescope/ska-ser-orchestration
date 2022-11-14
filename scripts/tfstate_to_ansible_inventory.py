#!/usr/bin/env -S python3 -u
"""This script converts a Terraform state file (pulled from GitLab) into
an ansible-inventory file, in YAML format.
"""

import base64
import json
import logging
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
GRAPHQL_URL = "https://gitlab.com/api/graphql"
LOGGING_LEVEL = os.environ.get("LOGGING_LEVEL", "INFO")
LOGGING_FORMAT = (
    "%(asctime)s [level=%(levelname)s] "
    "[module=%(module)s] [line=%(lineno)d]: %(message)s"
)
logging.basicConfig(level=LOGGING_LEVEL, format=LOGGING_FORMAT)
log = logging.getLogger("tfstate")
log.debug("Logging level is: %s", LOGGING_LEVEL)


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


def get_inventory(this_tf_state, inventory_type):
    """
    Gets all the inventories of a given type
    """
    result = {}
    for resource in this_tf_state:
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
    "-i",
    dest="local_state",
    required=False,
    default=None,
    help="local state file",
)
parser.add_argument(
    "-e",
    dest="environment",
    required=False,
    default=None,
    help="target environment",
)
parser.add_argument(
    "-d",
    dest="datacentre",
    required=False,
    default=None,
    help="target datacentre",
)
parser.add_argument(
    "-s",
    dest="service",
    required=False,
    default=None,
    help="target service",
)
parser.add_argument(
    "--no-jumphost",
    default=False,
    action="store_true",
    help="disable jumphost (connection through VPN)",
)
parser.add_argument(
    "--prefer-floating-ip",
    default=False,
    action="store_true",
    help="prefer floating ips when setting up jumphost",
)
parser.add_argument(
    "--display",
    default=False,
    action="store_true",
    help="set to output the generated inventory",
)
args = parser.parse_args()
if args.no_jumphost:
    log.info("** ---------- Jumphost DISABLED ---------- **")
    log.info("** Make sure you connect to a suitable VPN **")
    log.info("** ---------- Jumphost DISABLED ---------- **")

# Create output directory
output = os.path.abspath(args.output)
pathlib.Path(output).mkdir(parents=True, exist_ok=True)

if args.local_state is None:
    # Get state using HTTP
    url = get_env(["TF_STATE_ADDRESS", "TF_HTTP_ADDRESS"])
    username = get_env(["TF_STATE_USERNAME", "TF_HTTP_USERNAME"])
    password = get_env(["TF_STATE_PASSWORD", "TF_HTTP_PASSWORD"])

    # TO DO: switch to using full path name instead of project id
    project_id = get_env(["GITLAB_PROJECT_ID", "TF_HTTP_PASSWORD"])
    STATE_BASE_URL = (
        f"https://gitlab.com/api/v4/projects/{project_id}/terraform/state/"
    )

    # common headers for API calls
    headers = {
        "Content-type": "application/json",
        "Accept": "*/*",
        "PRIVATE-TOKEN": password,
        "Authorization": f"Bearer {password}",
    }

    # get the full path name for the project id
    api_query = f"https://gitlab.com/api/v4/projects/{project_id}/"
    log.debug("Project URI: %s", api_query)
    try:
        project_request = requests.get(api_query, headers=headers, timeout=60)
        if project_request.status_code != 200:
            content = json.dumps(project_request.json(), indent=4)
            log.critical(
                "** ERROR get project [%s]:\n%s",
                project_request.status_code,
                content,
            )
            sys.exit(project_request.status_code)
    except requests.exceptions.RequestException as err:
        log.critical("** error getting project path_with_namespace: %s", err)
        sys.exit(-1)

    # get list of tfstates using graphql API
    # select by path: project(fullPath:
    #                 "ska-telescope/sdi/ska-ser-infra-machinery")
    try:
        path_with_namespace = project_request.json().get(
            "path_with_namespace", ""
        )
        log.debug(
            "Project path_with_namespace %s:%s",
            project_id,
            path_with_namespace,
        )
        gql_query = {
            "query": (
                "query { project("
                f'fullPath: "{path_with_namespace}") '
                " { name id terraformStates { nodes {name}}}}"
            )
        }

        tf_all_states_request = requests.post(
            GRAPHQL_URL, json=gql_query, headers=headers, timeout=60
        )
        if tf_all_states_request.status_code != 200:
            log.critical(
                "** ERROR get tfstates [%s]:\n%s",
                tf_all_states_request.status_code,
                tf_all_states_request.content(),
            )
            sys.exit(tf_all_states_request.status_code)
    except requests.exceptions.RequestException as err:
        log.critical("** error getting tfstates: %s", err)
        sys.exit(-1)

    # extract the tfstates
    states = tf_all_states_request.json().get("data", {})
else:
    states = {
        "project": {
            "terraformStates": {
                "nodes": ["local"],
            }
        }
    }

# Parse groupings
instance_groups = {}
instance_groups_in_clusters = []
instances_with_parent = []
total_cluster_inventories = {}
total_instance_group_inventories = {}
total_instance_inventories = {}

# iterate over tfstate names to get the actual states
for state in states["project"]["terraformStates"]["nodes"]:
    if state != "local":
        PREFIX = "-".join(
            list(
                filter(None, [args.datacentre, args.environment, args.service])
            )
        )
        if not state["name"].startswith(PREFIX):
            continue

        log.info("Getting state from %s%s", STATE_BASE_URL, state["name"])
        try:
            tf_state_request = requests.get(
                STATE_BASE_URL + state["name"],
                auth=(username, password),
                timeout=60,
            )
            if tf_state_request.status_code != 200:
                if tf_state_request.status_code == 204:
                    # no content
                    continue

                log.critical(
                    "** ERROR [%s]:\n%s",
                    tf_state_request.status_code,
                    tf_state_request.content.decode("utf-8"),
                )
                sys.exit(tf_state_request.status_code)
        except requests.exceptions.RequestException as err:
            log.critical(
                "** ERROR [%s] getting tfstate: %s", state["name"], err
            )
            sys.exit(-1)

        tf_state = tf_state_request.json().get("resources", [])

    else:
        with open(args.local_state, encoding="utf-8") as f:
            tf_state_json: dict = json.load(f)
            tf_state = tf_state_json.get("resources", [])

    # Get class inventories
    cluster_inventories = get_inventory(tf_state, "cluster")
    instance_group_inventories = get_inventory(tf_state, "instance_group")
    instance_inventories = get_inventory(tf_state, "instance")

    for (cluster_id, cluster) in cluster_inventories.items():
        for instance_group_id in cluster[CHILDREN_KEY]:
            instance_groups_in_clusters.append(instance_group_id)
        for instance_id in cluster[HOSTS_KEY]:
            instances_with_parent.append(instance_id)

    for (
        instance_group_id,
        instance_group,
    ) in instance_group_inventories.items():
        instance_groups[instance_group_id] = {
            HOSTS_KEY: instance_group[HOSTS_KEY]
        }
        for instance_id in instance_group[HOSTS_KEY]:
            instances_with_parent.append(instance_id)
    total_cluster_inventories = {
        **total_cluster_inventories,
        **cluster_inventories,
    }
    total_instance_group_inventories = {
        **total_instance_group_inventories,
        **instance_group_inventories,
    }

    total_instance_inventories = {
        **total_instance_inventories,
        **instance_inventories,
    }


# Create inventory
inventory = {
    **{  # all with groups and single hosts
        ALL_KEY: {
            CHILDREN_KEY: {
                **{cluster: None for cluster in total_cluster_inventories},
                **{
                    instance_group: None
                    for instance_group in total_instance_group_inventories
                    if instance_group not in instance_groups_in_clusters
                },
            },
            HOSTS_KEY: {
                instance_id: instance
                for (
                    instance_id,
                    instance,
                ) in total_instance_inventories.items()
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
        for (cluster_id, cluster) in total_cluster_inventories.items()
    },
    **{  # instance groups
        instance_group_id: {HOSTS_KEY: instance_group[HOSTS_KEY]}
        for (
            instance_group_id,
            instance_group,
        ) in total_instance_group_inventories.items()
    },
}

# Output inventory
inventory_path = os.path.join(output, "inventory.yml")
with open(inventory_path, "w+", encoding="utf-8") as f:
    yaml.safe_dump(inventory, indent=2, stream=f)
    log.info("Inventory at %s", inventory_path)

# Create ssh config
ssh_config = ["BatchMode yes", "StrictHostKeyChecking no", "LogLevel QUIET"]

# Add jump hosts
jump_hosts = {}
for (instance_id, instance) in total_instance_inventories.items():
    if instance["jump_host"] is not None:
        jump_hosts[instance["jump_host"]["hostname"]] = instance["jump_host"]

    instance_ip = instance["ip"]
    if (
        args.no_jumphost
        and args.prefer_floating_ip
        and instance["floating_ip"] is not None
    ):
        instance_ip = instance["floating_ip"]

    ssh_config.append(
        get_ssh_config(
            host_name=instance_id,
            user=instance["ansible_user"],
            host_ip=instance_ip,
            keypair=instance["keypair"],
            jump_host=None
            if (args.no_jumphost or instance["jump_host"] is None)
            else instance["jump_host"]["hostname"],
        )
    )

for (host, config) in jump_hosts.items():
    jumphost_ip = config["ip"]
    if args.prefer_floating_ip and config["floating_ip"] is not None:
        jumphost_ip = config["floating_ip"]
    ssh_config.append(
        get_ssh_config(
            host_name=host,
            user=config["user"],
            host_ip=jumphost_ip,
            keypair=config["keypair"],
        )
    )

# Output ssh config
ssh_config_path = os.path.join(output, "ssh.config")
with open(ssh_config_path, "w+", encoding="utf-8") as f:
    f.write("\n".join(ssh_config))
    log.info("SSH Config at %s", ssh_config_path)
