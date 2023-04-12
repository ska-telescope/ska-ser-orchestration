#!/usr/bin/env -S python3 -u
"""This script injects resource ids in a Terraform state file (pulled from GitLab) to
manually alter the state
"""

import json
import logging
import os
import collections
import sys
from argparse import ArgumentParser

LOGGING_LEVEL = os.environ.get("LOGGING_LEVEL", "INFO")
LOGGING_FORMAT = (
    "%(asctime)s [level=%(levelname)s] "
    "[module=%(module)s] [line=%(lineno)d]: %(message)s"
)
logging.basicConfig(level=LOGGING_LEVEL, format=LOGGING_FORMAT)
log = logging.getLogger("tfstate_inject_resources")
log.debug("Logging level is: %s", LOGGING_LEVEL)

def inject_ports(state: dict, ports_list: list[str]):
    for port in ports_list:
        module, port_uuid = port.split("=")
        for resource in state.get("resources", []):
            resource_module = resource.get("module", "")
            resource_mode = resource.get("mode", "")
            resource_type = resource.get("type", "")
            resource_name = resource.get("name", "")
            if resource_module == module and resource_mode == "managed" and resource_type == "openstack_compute_instance_v2" and resource_name == "instance":
                if "instances" in resource and len(resource["instances"]) == 1:
                    networks = resource["instances"][0]["attributes"].get("network", [])
                    target_network_id = 0
                    if len(networks) >= (target_network_id + 1):
                        networks[target_network_id]["port"] = port_uuid

if __name__ == "__main__":
    parser = ArgumentParser(
        description="Terraform State resource injection Tool"
    )
    parser.add_argument(
        "-s",
        "--state",
        dest="state",
        required=True,
        help="state file path for i/o",
    )
    parser.add_argument(
        "-p",
        "--ports",
        dest="ports",
        required=False,
        default="",
        help="comma separated list of instance module=port id mappings",
    )
    args = parser.parse_args()
    state_path = os.path.abspath(args.state)
    if not os.path.isfile(state_path):
        log.error("State file at '%s' not found", state_path)
        sys.exit(1)

    with open(state_path, 'r') as file:
        state = json.load(file, object_pairs_hook=collections.OrderedDict)

    inject_ports(state, [port_map for port_map in args.ports.split(",") if port_map != ""])

    state["serial"] = state["serial"] + 1
    
    with open(state_path, 'w+', encoding="utf-8") as file:
        json.dump(state, file, indent=2, ensure_ascii=False, sort_keys=False)
        file.write("\n")
