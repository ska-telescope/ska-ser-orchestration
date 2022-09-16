# SKAO Orchestration

This repository contains **Terraform** modules used to create base units of infrastructure that we can later configure to create a complex cloud environment.

# Getting started

Terraform is the state-of-the-art infrastructure as a code software, with a huge community and support for most public and private clouds. Official documentation can be found here: https://www.terraform.io/language.

As it is a language, it has functions. Documentation for the built-in functions can be found here: https://www.terraform.io/language/functions.

To perform tasks within the language, Terraform uses **providers**. These are libraries to communicate with the provider's system, or API. These provide **resources** that can be created and **data** sources that can be read. Each provider has its own documentation and are usually very extensive and well presented. Here are some useful documentations:

* OpenStack -> https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
* AWS -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* Azure -> https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
* Vault -> https://registry.terraform.io/providers/hashicorp/vault/latest/docs
* Kubernetes -> https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs 

To compose multiple provider's resources into logical units, we use modules. Terraform modules work similarily to a function - given an input, does some work and produces an output (or not). Before any resource can be managed, we need a persistent state.

## Creating the Terraform state

The Terraform state is where we store (managed by Terraform) all the information on the infrastructure we are managing. The state file can be local, stored in GitLab, AWS S3, etc. Please look into https://www.terraform.io/language/settings/backends/configuration and see the available backends.

*Terraform backend configuration*
```
terraform {
  backend "<backend type>" {
    <backend configuration>
  }
}
```

## Declaring Providers

Providers blocks are used to configure access to a third-party APIs. More information on providers can be found here: https://www.terraform.io/language/providers.

The same way we need a clouds.yaml, environment variables or CLI arguments for the OpenStack CLI, the OpenStack provider requires proper configuration in order do the API calls to the correct endpoint, with proper authentication. 

> **_NOTE:_** As a **rule** always declare the providers at the top-most level possible and pass it down to the modules, to avoid missing provider definitions.

*Example provider declarations*
```
provider "openstack" {
  cloud     = <cloud name in clouds.yaml>
  tenant_id = <project/tenant id of OpenStack>
}

provider "aws" {
  region = "us-east-1"
}
```

Providers, like AWS, also use built-in configuration mechanisms (like AWS credentials), to avoid having sensitive information written in the modules. Provider configuration **support** variables for versatility and reusability of the code.

## Putting the state together

Terraform state and providers should be added in **.tf** files, which are Terraform **code** files. Usually, state and providers are added into a single file - *terraform.tfvars*.

*Example of a state file with a Gitlab Backend*
```
# ---------------------- Config ---------------------- #
# Requires the following to be changed for each configuration:
# * PROJECT_ID and STATE_ID, used in the http backend's address, lock_address and unlock_address (ie, projects/<PROJECT_ID>/terraform/<STATE_ID>

terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>1.48.0"
    }
  }

  # Requires the following environment variables:
  # export ENVIRONMENT="<environment name>"
  # export GITLAB_PROJECT_ID="<gitlab project id>"
  # export TF_HTTP_USERNAME="<gitlab username>"
  # export TF_HTTP_PASSWORD="<gitlab user access token>"
  # export TF_HTTP_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state"
  # export TF_HTTP_LOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state/lock"
  # export TF_HTTP_UNLOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state/lock"

  backend "http" {
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
    retry_wait_max = 30
  }
}
# --------------------------------------------------- #

# -------------------- Providers -------------------- #
provider "openstack" {
  cloud     = var.openstack.cloud
  tenant_id = var.openstack.project_id
}
# --------------------------------------------------- #
```

Backend configurations do not support Terraform variables, but support **environment variables**. 


Note that for the provider, we are using variables. As such, these variables need to be declared. Terraform supports weak-typed variables (with the type **any** or by not describing the type at all) and strong-typed variables. Usually, variables go into a **variables.tf** file:

```
variable "openstack" {
  type = object({
    cloud      = string
    project_id = string
  })
}
```

In our infrastructure definition, we can create individual **resources** from providers, or use modules that bundle multiple resources into a single unit.

# Modules

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

output "instance_inventory" {
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

output "instance_group_inventory" {
  description = "Instance group ansible inventory"
}
```

</td>
<tr></tr>
<td> openstack_elasticsearch_cluster </td>
<td> Creates an Elasticsearch cluster (elasticsearch & kibana) using OpenStack instances. All instances are created with an instance group to facilitate up and down scaling </td>
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

output "cluster_inventory" {
  description = "Cluster ansible inventory"
}
```

</td>
<tr></tr>
<td> ansible-inventory </td>
<td> Builds an ansible inventory based on the clusters, instance groups and instances present in the state </td>
<td>
    
```
"target_directory" = {
  type        = string
  description = "Directory where to store the inventory.yml"
}

inventories" = {
  type = object({
    clusters        = list(any)
    instance_groups = list(any)
    instances       = list(any)
  })
  description = "Set of inventories belonging to clusters, instance groups and instances"
}
```

```
Writes an YAML ansible inventory to ${target_directory}/inventory.yml
```

</td>
</table>

## Calling modules

After we have a state storage where we can track the state of our resources, we can call modules (ours, or built-in ones) to actually create infrastructure.

### openstack-instance

This module creates an OpenStack instance on a given network, creating and attaching a dynamic set of volumes to it. We can leverage the usage of default values to only change what we really need.

*Example instance*
```
module "bastion" {
  source   = "./ska-ser-orchestration/openstack-instance"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name = "bastion"
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

This would create an m1.large instance, named bastion, with a 30Gb volume that should be mounted at */home*. Note, that the OpenStack provider we will use within the module, is being passed to the module. This allows us to simply remove this declaration to destroy the component, cleanly.

### openstack-instance-group

An instance group is merely a set of instances that are configured/sized the same way and are meant to be stateless and scaled up and down. This is the perfect building block for a cluster.

*Example instance group*
```
module "load_balancers" {
  source   = "./ska-ser-orchestration/openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name = "load_balancer"
    size = 2
  }
}
```

This would create two instances (load_balancer_i00 and load_balancer_i01) in the same network, with the same flavor, image, etc.

### openstack-elasticsearch-cluster

This module is a wrapper for a set of instance groups we use to create an elasticsearch cluster. This cluster usually is composed by Elasticsearch (backend) nodes (eg, master, data, coordinating) and by Kibana (frontend). To simplify and streamline the creation of complex sets of infrastructure, we can bundle everything in its own module and add default variables (like volume definitions).

*Example cluster defined for elasticsearch*
```
module "elasticsearch" {
  source   = "./ska-ser-orchestration/openstack-elasticsearch-cluster"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  elasticsearch = {
    data = {
      flavor = "m1.large"
      size = 3
      data_volume_size = 20
    }
    kibana = {
    }
    master = {
      size = 1
      data_volume_size = 10
    }
  }
}
```

This would in turn, create three instance groups. A set of three data nodes, one master node and one kibana node. Note that the data node has a particular flavor, that might be different from the default one.

### Putting everything together

Now that we know how to setup a Terraform state and we know how to call modules, we can create Terraform files (.tf extension) and write our infrastructure definitions. Note that above, we are using a variable (denoted by **var.\<varname\>**) called **defaults**. This variable is used and required by our instance modules to simplify configurations. First, we need to declare it (again, using **variables.tf**):

```
variable "defaults" {
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

As we declared a variable, we need to provide values for it and that is done in **.tfvars** files. There is a multitude of ways to pass Terraform variables, and it is well described here: https://www.terraform.io/language/values/variables

*Example configuration can be found in resources/example.zip*
```
# OpenStack Cloud Configurations
openstack = {
  cloud      = "<name of a cloud in clouds.yaml>"
  project_id = "<project/tenant id>"
}

# OpenStack Instance defaults for the given OpenStack Cloud
defaults = {
  flavor            = "<default flavor name>"
  image             = "<default image name>"
  availability_zone = "<default az name>"
  network           = "<default network name>"
  keypair           = "<default keypair name>"
  jump_host         = "<default jump host id>"
}
```

> **_NOTE:_** Particularily with the OpenStack provider, we are using **clouds.yaml** as the source of configurations, not environment variables.

With all the definitions and values provided, we can create our infrastructure. The Terraform commands need to be executed from the root directory of the environment's **.tf** and **.tfvars** files. Below, you can find a practical example on how to glue everything together in order to create an elasticsearch cluster.

# Deploying an Elasticsearch cluster

As a proof-of-concept and practical learning tool, we've included boilerplate ![code](resources/example.zip) to create an elasticsearch instance, composed of three master nodes, five data nodes and a kibana node. To save resources, their volume sizes' were reduced. Bear in mind, this is using a **cloud** in clouds.yaml named **engage** (pointing to EngageSKA OpenStack), so you either modify **terraform.tfvars** or the clouds.yaml file to suit your needs. If you use another cloud, you will most likely have to change some of the defaults in **terraform.tf** as well.

Extract the zip file into the following structure:

```
.
├── ansible.cfg
├── ansible.tf
├── elasticsearch.tf
├── inventory -> It will be created after we run the Python script to generate it
│   └── inventory.yml
├── keys
│   └── ska-techops.pem -> Key we are using by default. Add other keys if needed
├── ska-ser-orchestration -> This repository
├── terraform.tf
├── terraform.tfvars
└── variables.tf
```

Then, give a custom name to your elasticsearch cluster, so that it doesn't collide with others:

*Changes to elasticsearch.tf*
```
module "elasticsearch" {
  source   = "./ska-ser-orchestration/openstack-elasticsearch-cluster"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  elasticsearch = {
    name   = "elasticsearch" -> Change this
    master = {
```

Then, do:

```
export ENVIRONMENT="<environment name>"
export GITLAB_PROJECT_ID="<gitlab project id>"
export TF_HTTP_USERNAME="<gitlab username>"
export TF_HTTP_PASSWORD="<gitlab user access token>"
export TF_HTTP_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state"
export TF_HTTP_LOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state/lock"
export TF_HTTP_UNLOCK_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state/lock"
terraform init --upgrade
terraform apply
```

You can now navigate to OpenStack and see the created resources.

> **_NOTE:_** You need to have ska-techops.pem in the top level directory to run ansible commands

## Generating the Ansible Inventory

To generate the ansible-inventory file, we've created a ![script](scripts/tfstate-to-ansible-inventory.py) that we can run after **apply or destroy** commands, that uses the state file directly. This was done to decouple the generation of the script from the Terraform code, although still uses Terraform (state). Also, it can be ran without having Terraform installed, just the appropriate environment variables need to be defined. This can be executed at **any** time. To generate it, do:

```
export ENVIRONMENT="<environment name>"
export GITLAB_PROJECT_ID="<gitlab project id>"
export TF_HTTP_USERNAME="<gitlab username>"
export TF_HTTP_PASSWORD="<gitlab user access token>"
export TF_HTTP_ADDRESS="https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${ENVIRONMENT}-terraform-state"
./ska-ser-orchestration/scripts/tfstate-to-ansible-inventory.py
```

```
# Ping all nodes in the cluster
ansible all -m ping

# Ping data nodes
ansible all -m ping -l elasticsearch_data
```

At any time, we can visualize the output of our code by doing:

```
terraform output
```

To get rid of the created resources, simply do:

```
terraform destroy
```

