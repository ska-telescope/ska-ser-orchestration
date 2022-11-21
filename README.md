# SKAO Orchestration

This repository contains custom SKA **Terraform** modules used to create base units of infrastructure that we use to create complex cloud environments. This repository **shouldn't** be used to create infrastructure, except when playing around with the **examples**. For infrastructure creation in environments, we should use https://gitlab.com/ska-telescope/sdi/ska-ser-infra-machinery.

## Prerequisites

| Collection            | Version            |
| --------------------- | -------------------|
| [**Terraform**](https://learn.hashicorp.com/tutorials/terraform/install-cli) | 1.2.x |
| [**TFLint**](https://github.com/terraform-linters/tflint#installation) | 0.40.1 |
| [**Python**](https://www.python.org/downloads/) | 3.x |
| [**Poetry**](https://python-poetry.org/docs/#installation) | 3.x |


> :warning: Terraform version is not the latest
> 
> You need to install a fix version (1.2.X -> latest version of v1.2). 
> 
> Installation steps depend on host's Operating System.

## Application Security

The modules used to create instances enforce the creation of a separate security group. This is so to avoid having too-permissive security groups. To use this, simply add the variable **applications** - a list of strings - to your **instance** or **instance-group** containing one or more of the supported applications:


<table>
    <thead>
        <tr>
            <th>Application</th>
            <th>Service</th>
            <th>Port Number</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=3>elasticsearch</td>
            <td>api</td>
            <td>9200</td>
        </tr>        
        <tr>
            <td>transport</td>
            <td>9300</td>
        </tr>        
        <tr>
            <td>elasticsearch_exporter</td>
            <td>9114</td>
        </tr>
        <tr>
            <td>kibana</td>
            <td>frontend</td>
            <td>5601</td>
        </tr>          
        <tr>
            <td>node_exporter</td>
            <td>api</td>
            <td>9100</td>
        </tr>          
        <tr>
            <td rowspan=2>prometheus</td>
            <td>api</td>
            <td>9090</td>
        </tr>  
        <tr>
            <td>alert manager</td>
            <td>9093</td>
        </tr>
          <tr>
            <td>thanos_sidecar</td>
            <td>api</td>
            <td>10901</td>
        </tr>  
        <tr>
            <td rowspan=2>thanos</td>
            <td>querier</td>
            <td>9091</td>
        </tr>  
        <tr>
            <td>frontend</td>
            <td>9095</td>
        </tr>
        <tr>
            <td rowspan=2>thanos</td>
            <td>http</td>
            <td>8081</td>
        </tr>
        <tr>
            <td>docker</td>
            <td>9080-9084</td>
        </tr>  
    </tbody>
</table>

# Make Targets

Currently, the following make targets are supplied:

| Target | Description |
| ------ | ----------- | 
| format | Formats Python and Terraform code |
| lint | Lints Python and Terraform code |
| init | Initializes the modules in the target directory |
| plan | Plans the convergence operations in the target directory |
| apply | Applies the configuration in the target directory |
| destroy | Destroys the configuration in the target directory |
| generate-inventory | Generates the ansible inventory and ssh config of the current Terraform state |

## Modules

Currently, the following modules are provided in this repository:


<table>
    <thead>
        <tr>
            <th> Module </th>
            <th> Description </th>
            <th> Input & Output </th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td> openstack-instance </td>
            <td> Creates an OpenStack instance and required volumes, attaching them to the instance. If enabled, also
                creates a security group for the instance </td>
            <td><a href="./openstack-instance/variables.tf">Inputs</a><br><br><a
                    href="./openstack-instance/outputs.tf">Outputs</a></td>
        </tr>
        <tr>
            <td> openstack-instance-group </td>
            <td> Creates a group of equally configured OpenStack instances and volumes, attaching volumes to the
                respective
                instances. Creats a security group shared by all instances of the group</td> 
            <td><a href="./openstack-instance-group/variables.tf">Inputs</a><br><br><a
                    href="./openstack-instance-group/outputs.tf">Outputs</a></td>
            </td>
        </tr>
        <tr>
            <td> openstack-elasticsearch-cluster </td>
            <td> Creates an Elasticsearch cluster (elasticsearch & kibana) using OpenStack instances. All instances are
                created with an instance group to facilitate up and down scaling </td>
            <td><a href="./openstack-elasticsearch-cluster/variables.tf">Inputs</a><br><br><a
                    href="./openstack-elasticsearch-cluster/outputs.tf">Outputs</a></td>
            </td>
        </tr>
        <tr>
            <td> application-ruleset </td>
            <td>Provides a mapping between a set of applications to be ran on a particular instance. and the security
                group rules required</td>
            <td><a href="./application-ruleset/variables.tf">Inputs</a><br><br><a
                    href="./application-ruleset/outputs.tf">Outputs</a></td>
    </tbody>
</table>

## Getting started

To get started, we need to install Terraform as shown here: https://learn.hashicorp.com/tutorials/terraform/install-cli. To execute Terraform code, the following is required:
* **terraform.tf**
  * Contains the **terraform** block object with the **state** configuration and required **providers** and their configurations;
  * see [Terraform Settings](https://www.terraform.io/language/settings) and [Providers](https://www.terraform.io/language/providers).
* **variables.tf** 
  * Declaration of the input variables to use in our code;
  * see [Terraform Variables](https://www.terraform.io/language/values/variables).
* **terraform.tfvars** 
  * Definition of the input variables declared above;
  * see [Terraform Variables](https://www.terraform.io/language/values/variables).
* Terraform code with the intended configuration, written in **.tf** files
  * see [Terraform Syntax](https://www.terraform.io/language/syntax).

To make it simpler, we've created an example for each module we provide. They contain full definitions for the files described above.

To deploy the examples, you need:
* Gitlab access token, generated with the **api** permission
* OpenStack clouds.yaml configured, with a cloud named **engage** (see [Openstack CLI Configuration](https://docs.openstack.org/python-openstackclient/pike/configuration/index.html))

> **_NOTE:_** You can use any other cloud other than **engage**. For that, you need to adjust all **terraform.tfvars** files in the examples accordingly

### Creating an instance: **openstack-instance** module

This module creates an OpenStack instance on a given network, creating and attaching a set of volumes to it. We can leverage the usage of default values to only change what we really need and keep our configurations DRY. These defaults are passed using the variable **defaults**, which is an input to the module, as shown in the modules section above.

*instance.tf from examples/instance*
```
module "instance" {
  source   = "../../openstack-instance"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name = local.instance_name
    flavor = "m1.large"
    metadata = {
      mykey = "blah"
    }
    volumes = [
      {
        mount_point = "/home"
        name = "home"
        size = 30
      }
    ]
  }
}
```

In this particular configuration, an instance of flavor "m1.large" will be created, along with a volume of 30Gb that should be mounted to "/home". Also, for single instances, a security group is created. Configuration and mounting of volumes should be performed with Ansible.

To deploy this example, do:

```
cd examples/instance
export GITLAB_PROJECT_ID="39438691" # ska-ser-orchestration repository
export TF_HTTP_USERNAME="<gitlab username>"
export TF_HTTP_PASSWORD="<gitlab user access token with api access>"
export TF_HTTP_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-instance-tfstate"
export TF_HTTP_LOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-instance-tfstate/lock"
export TF_HTTP_UNLOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-instance-tfstate/lock"
export OS_CLOUD=engage # if you changed cloud name in terraform.tfvars, change it here as well
terraform init --upgrade
terraform apply
```

Take your time to inspect what resources are ought to be created by Terraform, and then apply your configuration. We now need to generate an ansible inventory from our infrastructure, so that we can run Ansible commands on it.  The following script will generate an inventory from *all* the available TF state files associated with the nominated GitLab project.  This list can be reduced by setting the `${ENVIRONMENT}` value (or using the switch `-e`):

```
sh -c "../../scripts/tfstate_to_ansible_inventory.py -o inventory"
mkdir -p keys && cp <path to ska-techops.pem> keys
ansible all -m ping
```

Your state file can be found at https://gitlab.com/ska-telescope/sdi/ska-ser-orchestration/-/terraform.

To cleanup, do:
```
terraform destroy
curl --header "Private-Token: $TF_HTTP_PASSWORD" --request DELETE "$TF_HTTP_ADDRESS"
```

## Creating a single-configuration cluster: **openstack-instance-group** module

An instance group is merely a set of instances that are configured/sized the same way and are meant scaled up and down with ease. This is the basic building block for a cluster. We can, in the case of Kubernetes or Elasticsearch, have a cluster composed of multiple different instance groups, to achieve a complex topology.

*instance-group.tf from examples/instance-group*
```
module "instance_group" {
  source   = "../../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name = local.instance_group_name
    size = 2
  }
}
```

In this case, two instances with the default configuration (remember the **defaults** variable mentioned earlier) will be created. As for the instance module, we can set a flavor, image, etc. This instance_group module also creates a **security group** that is shared by all instances in the instance group.

To deploy this example, do:

```
cd examples/instance-group
export GITLAB_PROJECT_ID="39438691" # ska-ser-orchestration repository
export TF_HTTP_USERNAME="<gitlab username>"
export TF_HTTP_PASSWORD="<gitlab user access token with api access>"
export TF_HTTP_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-instance-group-tfstate"
export TF_HTTP_LOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-instance-group-tfstate/lock"
export TF_HTTP_UNLOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-instance-group-tfstate/lock"
export OS_CLOUD=engage # if you changed cloud name in terraform.tfvars, change it here as well
terraform init --upgrade
terraform apply
```

We can now try to perform a change to the instance group, by changing flavors:

*instance-group.tf from examples/instance-group*
```
module "instance_group" {
  source   = "../../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name = local.instance_group_name
    flavor = "m1.large"
    size = 2
  }
}
```

Now, run:
```
terraform apply
```

In this particular API, we are allowed to change this property - flavor - without recreating the resource, being done in place. While the code is running, you can see the instances being resized in OpenStack. When it completes, we can run generate the ansible inventory:

```
sh -c "../../scripts/tfstate_to_ansible_inventory.py -o inventory"
mkdir -p keys && cp <path to ska-techops.pem> keys
ansible all -m ping
```

Again, your state file can be found at https://gitlab.com/ska-telescope/sdi/ska-ser-orchestration/-/terraform.

To cleanup, do:
```
terraform destroy
curl --header "Private-Token: $TF_HTTP_PASSWORD" --request DELETE "$TF_HTTP_ADDRESS"
```

## Creating multi-configuration cluster: **openstack-elasticsearch** module

This module is a wrapper for a set of instance groups we use to create an elasticsearch cluster. This cluster usually is composed by Elasticsearch (backend) nodes (eg, master, data, coordinating) and by Kibana node(s) (frontend). To simplify and streamline the creation of complex sets of infrastructure, we can bundle everything in its own module and add default variables (like volume definitions).

*elasticsearch.tf from examples/elasticsearch*
```
module "elasticsearch" {
  source   = "../../openstack-elasticsearch-cluster"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  elasticsearch = {
    name = local.elasticsearch_name
    master = {
      size = 1
      data_volume_size = 10
    }
    data = {
      flavor = "m1.large"
      size = 3
      data_volume_size = 20
    }
    kibana = {}
  }
}
```

This would in turn, create three instance groups. A set of one master nodes, three data nodes and one kibana node. Note that the data node has a particular flavor, that is be different from the default one (m1.small).

To deploy this example, do:

```
cd examples/elasticsearch
export GITLAB_PROJECT_ID="39438691" # ska-ser-orchestration repository
export TF_HTTP_USERNAME="<gitlab username>"
export TF_HTTP_PASSWORD="<gitlab user access token with api access>"
export TF_HTTP_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-elasticsearch-tfstate"
export TF_HTTP_LOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-elasticsearch-tfstate/lock"
export TF_HTTP_UNLOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_HTTP_USERNAME}-elasticsearch-tfstate/lock"
export OS_CLOUD=engage # if you changed cloud name in terraform.tfvars, change it here as well
terraform init --upgrade
terraform apply
```

Again, we can generate the ansible inventory and run commands against our instances:

```
sh -c "../../scripts/tfstate_to_ansible_inventory.py -o inventory"
mkdir -p keys && cp <path to ska-techops.pem> keys
ansible all -m ping
```

We can now bump our master instance group within the cluster to three nodes:

*elasticsearch.tf from examples/elasticsearch*
```
module "elasticsearch" {
  source   = "../../openstack-elasticsearch-cluster"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  elasticsearch = {
    name = local.elasticsearch_name
    master = {
      size = 3
      data_volume_size = 10
    }
    data = {
      flavor = "m1.large"
      size = 3
      data_volume_size = 20
    }
    kibana = {}
  }
}
```

Now, run:
```
terraform apply
```

This will create two more nodes. Reducing the size of the group, does the opposite. Currently, the scaling down procedure is done sequencially, from higher instance id to lower. We simply need to re-generate the inventory:

```
sh -c "../../scripts/tfstate_to_ansible_inventory.py -o inventory"
ansible all -m ping
```

To cleanup, do:
```
terraform destroy
curl --header "Private-Token: $TF_HTTP_PASSWORD" --request DELETE "$TF_HTTP_ADDRESS"
```

## Instance SSH access configuration

For security reasons, we should not have the SSH port (22) opened to the public, regardless of having a secure access through PKI. Currently we can configure an instance's access using two settings:

* **jump_host** - Jump host instance in OpenStack
* **vpn_cidr_blocks** - List of cidr blocks that are allowed

The setup really depends on what one wants to accomplish and the underlying network structure. If we want to force all access to go through a jump host (funnels traffic, has pros and cons), we should just set **jump_host** because that automatically checks for all instance's addresses. In the case jump host is not an OpenStack instance, we can set it CIDR block via **vpn_cidr_blocks**.

When allowing VPN access, we should set the VPN's CIDR blocks in via **vpn_cidr_blocks**. In some cases (e.g, STFC) the VPN is configured in a way that the traffic appears as coming from the VPN Gateway, not the client. In that case, it is possible to set the **jump_host** as the gateway's IP, or set it via **vpn_cidr_blocks**.

## References

Terraform is the state-of-the-art infrastructure as a code tool, with a huge community and support for most public and private clouds. Extensive documentation is available at https://www.terraform.io. Below, you can find a list of key concepts and pieces of documentation:

* Terraform's quick start guide at https://www.terraform.io/intro
* Terraform state (backend) configuration at https://www.terraform.io/language/settings/backends/configuration
* Terraform's syntax at https://www.terraform.io/language/syntax
* Terraform's built-in functions at https://www.terraform.io/language/functions
* Terraform variables at https://www.terraform.io/language/values/variables
* Terraform modules at https://www.terraform.io/language/modules
* Terraform providers at https://www.terraform.io/language/providers and some useful providers:
  * OpenStack: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
  * AWS: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  * Azure: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
  * Vault: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
  * Kubernetes: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

Also, there is a multitude of tutorials online, like https://www.youtube.com/watch?v=l5k1ai_GBDE&ab_channel=TechWorldwithNana. Most of the tutorials use AWS/GCP/Azure resources, although the same logic and strategies apply to our and new use cases. Use our examples as a study case for OpenStack.

## License

BSD-3.
