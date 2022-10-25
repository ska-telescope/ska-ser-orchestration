#!/usr/bin/env -S python3 -u
"""
Script to get a information about an instance, including the name
and all associated network addresses. This script is required because
the Terraform OpenStack providerdoes not support this functionality.

Overrides:
OS_CLOUD environment variable to change target cloud is clouds.yaml

Input example:
{
    "id": "01a68010-cc61-4396-9690-cb7263d2412d"
}

Output example:
{
    "hostname": "terminus",
    "id": "01a68010-cc61-4396-9690-cb7263d2412d",
    "user": "ubuntu",
    "ip": "192.168.99.194",
    "floating_ip": "130.246.214.45",
    "keypair": "ska-techops",
    "addresses": ["130.246.214.45", "192.168.99.194"]
}
"""

import json
import os
import sys

import openstack


def output_and_exit(data):
    """
    Prints the output for the external data source and exits
    with success
    """
    print(json.dumps(data))
    sys.exit(0)


input_json = json.loads(sys.stdin.read())
instance_id = input_json.get("id", None)
if instance_id is None:
    output_and_exit(None)

cloud = openstack.connect(cloud=os.environ.get("OS_CLOUD", "openstack"))

# Get instance by id
server = cloud.get_server(name_or_id=instance_id, detailed=True)
if server is None:
    raise AttributeError(f"Instance with id '{instance_id}' not found")

# Get all addresses
addresses = []
for _, interfaces in server["addresses"].items():
    for interface in interfaces:
        addresses.append(interface["addr"])

output_and_exit(
    {
        "hostname": server["name"],
        "id": server["id"],
        "user": "ubuntu",  # pull from image metadata when available
        "ip": server["private_v4"],
        "floating_ip": server.get("public_v4", None),
        "keypair": server["key_name"],
        "addresses": ",".join(list(set(addresses))),
    }
)
