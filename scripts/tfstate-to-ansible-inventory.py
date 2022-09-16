#!/usr/bin/env -S python3 -u

import yaml, sys, os, requests, pathlib


def get_env(keys, default=None):
    for k in keys:
        v = os.environ.get(k, None)
        if v is not None:
            return v

    return default


def merge(data):
    map = {}
    for d in data:
        for k in d:
            map[k] = d[k]
    return dict(map)


def extract(var, parent_key, key, value=None):
    if isinstance(var, dict):
        v = var.get(key, None)
        if value is not None and v == value:
            yield {parent_key: var}
        if value is None and v is not None:
            yield {parent_key: var}
        for (k, v) in var.items():
            if isinstance(v, (dict, list)):
                yield from extract(v, k, key, value)


def get_inventory(state, key="inventory_type", value=None):
    return merge(list(extract(state, None, key, value)))


# Keys
ALL_KEY = "all"
CHILDREN_KEY = "children"
HOSTS_KEY = "hosts"

# Get state using HTTP
url = get_env(["TF_STATE_ADDRESS", "TF_HTTP_ADDRESS"])
username = get_env(["TF_STATE_USERNAME", "TF_HTTP_USERNAME"])
password = get_env(["TF_STATE_PASSWORD", "TF_HTTP_PASSWORD"])

print("Getting state from %s" % url, file=sys.stderr)
state_request = requests.get(url, auth=(username, password))
if state_request.status_code != 200:
    print(
        "Error getting state. %s: %s" % (state_request.status_code, state_request.raw),
        file=sys.stderr,
    )

state = state_request.json()

# Curate output given actual resources, as the output of a destroyed resource remains in state
# if we run apply/destroy with -target
expected_output_blocks = []
for created_components in state["resources"]:
    expected_output_blocks.append(created_components["module"].split(".")[1])
    
expected_output_blocks = [*set(expected_output_blocks)]
state = state["outputs"]

for expected_output in expected_output_blocks:
    if expected_output not in state.keys():
        print("** ERROR: Expected to have an output block for module '%s'" % expected_output, file=sys.stderr)

for output in state.keys():
    if output not in expected_output_blocks:
        print("** WARNING: Output for '%s' in state but no resources were found" % output, file=sys.stderr)

for output in state:
    if output not in expected_output_blocks:
        state[output] = None

# Get class inventories
cis = get_inventory(state, value="cluster")
igis = get_inventory(state, value="instance_group")
iis = get_inventory(state, key="ansible_host")

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
                i_id: i for (i_id, i) in iis.items() if i_id not in is_with_parent
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
        ig_id: {HOSTS_KEY: ig[HOSTS_KEY]}
        for (ig_id, ig) in igis.items()
    },
}

# Output inventory
output = sys.stdout
if len(sys.argv) > 1 and sys.argv[1] is not None:
    path = os.path.abspath(sys.argv[1])
    pathlib.Path(os.path.dirname(path)).mkdir(parents=True, exist_ok=True)
    output = open(path, "w+")
    print("Inventory at %s" % path, file=sys.stderr)

yaml.safe_dump(inventory, indent=2, stream=output)
