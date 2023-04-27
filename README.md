# terraform-google-netapp-poc

This is a POC (proof-of-concept) for adding instances dynamically to an instance group.

Since Terraform is declarative language, imperative commands such as adding or deleting resources ad-hoc is not supported. In fact, to add or delete a resource from a collection of resources, the entire configuration must be formed that defines the final state of a parent resource with the child resources added or deleted. 

However, for certain valid use cases, we can make use of data sources in combination with GCP resources to simulate imperative events. This POC is an effort at that simulation.

## Artifacts

Artifacts for this POC are organized as follows:

```
├── 1 - ig
│   ├── 1.1 - main.tf
│   ├── 1.2 - stg_instance.tf
│   ├── 1.3 - cvo_instance_01.tf
│   ├── 1.4 - ...
│   ├── 1.5 - cvo_instance_n.tf
│   └── 1.6 - variables.tf
├── 2 - main.tf
└── 3 - variables.tf
```

The root module [main.tf](main.tf) is used for setting up a GCP Instance Group, Backend Service and Health check. This module is expected to be called from configuration with the [ig](ig/) folder. 

The [ig](ig/) folder has:
1. [main.tf](ig/main.tf) that calls the root module and accesses two data sources. Data source `google_compute_image` is used to access the image for the instances while data source `google_compute_instance_group` is used to access the current list of instances for the instance group.
1. [stg_instance.tf](ig/stg_instance.tf) that holds configuration for wiring up the instance group initially with one instance.
1. a list of _cvo\_instance\_*.tf_ files that hold configuration for the CVO instances to be added to the instance group.

## Initializing the setup
1. Remove all _cvo\_instance\_*.tf_ from the [ig](ig/) folder.
2. Replace the locals block in [1.1 - main.tf](ig/main.tf) as:
```
locals {
  new_instance_id = google_compute_instance.staging_vm.self_link
}
```
3. Plan and apply the configuration in [ig](ig/)

## Adding a new instance to the instance group
1. Create a new file similar to _cvo\_instance\_*.tf_ e.g. _cvo\_instance\_01.tf_ and add a `google_compute_instance` resource to it.
2. Replace the locals block in [1.1 - main.tf](ig/main.tf) as:
```
locals {
  # this should point to the new resource added in cvo_instance_01.tf
  new_instance_id = google_compute_instance.cvo_instance_01.self_link 
}
```
3. Plan and apply the configuration in [ig](ig/)

## Conclusion
As mentioned above even though the intention is imperative, Terraform expects a complete declaration of the resources in play to achieve the intended state. The usage of data source `google_compute_instance_group` allows us to get all existing instances running in the instance group and append a newly added instance to it as demonstrated in the [adding a new instance](#adding-a-new-instance-to-the-instance-group) section above with updating the local variable.

The process for adding instances can possibly automated (tbd) by creating a Golang package that uses the [hcl](https://pkg.go.dev/github.com/hashicorp/hcl/v2) package for dynamically generating and manipulating Terraform resources. 

The steps would be:
1. Create a new terraform file using the [NewFile](https://pkg.go.dev/github.com/hashicorp/hcl/v2/hclwrite#NewFile) function for the new instance.
1. Insert a compute instance resource configuration using the [NewBlock](https://pkg.go.dev/github.com/hashicorp/hcl/v2/hclwrite#NewBlock) function.
1. Modify the [1.1 - main.tf](ig/main.tf) locals block with the self_link reference for the newly added instance using the [Attribute](https://pkg.go.dev/github.com/hashicorp/hcl/v2/hclwrite#Attribute) type.
1. Plan and apply the configuration.
