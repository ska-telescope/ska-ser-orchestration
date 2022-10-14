#!/usr/bin/env -S python3 -u
"""
Script to get a floating ip associated with a particular ip address.
If no association exists, returns null. This script is required because
the Terraform OpenStack providerdoes not support this functionality.

Input example:
{
    "ip": "192.168.99.194"
}

Output example:
{
    "fixed_ip": "192.168.99.194",
    "fip_id": "77457340-869b-4cc3-a829-60da39510769",
    "fip_address": "130.246.214.45"
}
"""

import json
import sys

import openstack

input_json = json.loads(sys.stdin.read())

floating_ip_id = None  # pylint: disable=invalid-name
floating_ip_address = None  # pylint: disable=invalid-name
instance_ip = input_json.get("ip", None)
if instance_ip is not None:
    cloud = openstack.connect(cloud="openstack")
    for floating_ip in cloud.list_floating_ips():
        if (
            floating_ip["attached"]
            and floating_ip.get("fixed_ip_address", "") == input_json["ip"]
        ):
            floating_ip_id = floating_ip["id"]
            floating_ip_address = floating_ip["floating_ip_address"]
            break

print(
    json.dumps(
        {
            "fixed_ip": instance_ip,
            "fip_id": floating_ip_id,
            "fip_address": floating_ip_address,
        }
    )
)
