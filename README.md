# SKAO Orchestration

This repository contains custom SKA **Terraform** modules used to create base units of infrastructure that we use to create complex cloud environments. This repository **shouldn't** be used to create infrastructure, except when playing around with the **examples**. For infrastructure creation in environments, we should use https://gitlab.com/ska-telescope/sdi/ska-ser-infra-machinery.

## Modules

Currently, the following modules are provided in this repository:

<table>
<tr>
<td> Module </td> <td> Description </td> <td> Input & Output </td>
</tr>
<tr>
<td> openstack_instance </td>
<td> Creates an OpenStack instance and required volumes, attaching them to the instance. If enabled, also creates a security group for the instance </td>
<td>
    
```
configuration = {
  type = object({
    name                  = string
    flavor                = optional(string)
    image                 = optional(string)
    availability_zone     = optional(string)
    network               = optional(string)
    create_security_group = optional(bool)
    security_groups       = optional(list(string))
    keypair               = optional(string)
    jump_host             = optional(string)
    volumes = optional(list(object({
      name        = string
      size        = number
      mount_point = string
    })))
  })
  description = "Instance configuration"
}

defaults = {
  type = object({
    availability_zone = string
    flavor            = string
    jump_host         = string
    image             = string
    keypair           = string
    network           = string
  })
  description = "Set of default values used when creating OpenStack instances"
}
```

```
output "instance" {
  description = "Instance state"
}

output "inventory" {
  description = "Instance ansible inventory"
}
```

</td>
<tr></tr>
<td> openstack_instance_group </td>
<td> Creates a group of equally configured OpenStack instances and volumes, attaching volumes to the respective instances. Creats a security group shared by all instances of the group</td>
<td>
    
```
configuration = {
  type = object({
    name              = string
    size              = optional(number)
    flavor            = optional(string)
    image             = optional(string)
    availability_zone = optional(string)
    network           = optional(string)
    security_groups   = optional(list(string))
    keypair           = optional(string)
    jump_host         = optional(string)
    volumes = optional(list(object({
      name        = string
      size        = number
      mount_point = string
    })))
  })
  description = "Instance group configuration"
}

defaults = {
  type = object({
    availability_zone = string
    flavor            = string
    jump_host         = string
    image             = string
    keypair           = string
    network           = string
  })
  description = "Set of default values used when creating OpenStack instances"
}
```

```
output "instance_group" {
  description = "Instance group instances state"
}

output "inventory" {
  description = "Instance group ansible inventory"
}
```

</td>
<tr></tr>
<td> openstack_elasticsearch_cluster </td>
<td> Creates an Elasticsearch cluster (elasticsearch & kibana) using OpenStack instances. All instances are created with an instance group to facilitate up and down scaling </td>
<td>
    
```
"applications" = {
  type        = list(string)
  default     = []
  description = "Set of application names to get the security group rules"
}

"networks" = {
  type        = list(string)
  default     = []
  description = "List of networks to use as target (source or destination)"
}
```

```
output "ruleset" {
  description = "Set of security group rules to support the required applications"
}
```

</td>
<tr></tr>
<td> application-ruleset </td>
<td> Provides a mapping between a set of applications to be ran on a particular instance. and the security group rules required </td>
<td>
    
```
"elasticsearch" = {
  type = object({
    name = optional(string)
    master = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number)
    }))
    data = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number)
    }))
    kibana = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
    }))
  })
  description = "Elasticsearch cluster configuration"
}

defaults = {
  type = object({
    availability_zone = string
    flavor            = string
    jump_host         = string
    image             = string
    keypair           = string
    network           = string
  })
  description = "Set of default values used when creating OpenStack instances"
}
```

```
output "cluster" {
  description = "Cluster instance groups states"
}

output "inventory" {
  description = "Cluster ansible inventory"
}
```

</td>
</table>

## Getting started

To get started, we need to install Terraform as shown here: https://learn.hashicorp.com/tutorials/terraform/install-cli. To execute Terraform code, the following is required:
* terraform.tf - Contains the **terraform** block object with the **state** configuration and required **providers** and their configurations (see https://www.terraform.io/language/settings and https://www.terraform.io/language/providers)
* variables.tf - Declaration of the input variables to use in our code (see https://www.terraform.io/language/values/variables)
* terraform.tfvars - Definition of the input variables declared above (see https://www.terraform.io/language/values/variables)
* Terraform code with the intended configuration, written in **.tf** files (see https://www.terraform.io/language/syntax)

To make it simpler, we've created an example for each module we provide. They contain full definitions for the files described above.

To deploy the examples, you need:
* Gitlab access token, generated with the **api** permission
* OpenStack clouds.yaml configured, with a cloud named **engage** (see https://docs.openstack.org/python-openstackclient/pike/configuration/index.html)

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
terraform init --upgrade
terraform apply
```

Take your time to inspect what resources are ought to be created by Terraform, and then apply your configuration. We now need to generate an ansible inventory from our infrastructure, so that we can run Ansible commands on it.

```
sh -c "../../scripts/tfstate_to_ansible_inventory.py inventory/inventory.yml"
mkdir -p keys && cp <path to ska-techops.pem> keys
ansible all -m ping -i inventory/inventory.yml
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
sh -c "../../scripts/tfstate_to_ansible_inventory.py inventory/inventory.yml"
mkdir -p keys && cp <path to ska-techops.pem> keys
ansible all -m ping -i inventory/inventory.yml
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
terraform init --upgrade
terraform apply
```

Again, we can generate the ansible inventory and run commands against our instances:

```
sh -c "../../scripts/tfstate_to_ansible_inventory.py inventory/inventory.yml"
mkdir -p keys && cp <path to ska-techops.pem> keys
ansible all -m ping -i inventory/inventory.yml
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
sh -c "../../scripts/tfstate_to_ansible_inventory.py inventory/inventory.yml"
ansible all -m ping -i inventory/inventory.yml
```

To cleanup, do:
```
terraform destroy
curl --header "Private-Token: $TF_HTTP_PASSWORD" --request DELETE "$TF_HTTP_ADDRESS"
```

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
