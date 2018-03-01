# cira-terraform
CIRA Terraform sample plan for vcenter VM builds plus hopefully Satellite provisioning

Prerequisites are as follows

## Satellite

 * Sync Atomic RPMs, OSTree, and Kickstarts
 * Build Content View called cv-atomic ... and place the Atomic RPM and OSTree repos in there
 * Create Activation Key called ak-atomic ... and add the cv-atomic repo and subscriptions accordingly (likely nothing for now with VDC)
 * Create 3 Custom Partition Tables for Master, Infra, and App - templates are in the satellite/partition_tables folder
 * Create 1 Custom Provisioning Template - template is in satellite/provisioning_templates folder
 * Ensure the Atomic kickstart media is associated with the proper Orgs and Locations (through Installation Media dropdown)
 * Associate an Atomic Operating System (in the Satellite dropdown) to use the new partition tables (all 3) and the provisioning template
 * Create 3 Hostgroups ... 1 for OCP-MASTER, 1 for OCP-INFRA, and 1 for OCP-APP.  Associate all the correct elements in the hostgroup, especially partition table and OS

 ## Terraform Setup

 * Modify the network, and datastore attributes in `main.tf` according to the environment
 * ensure you export the following environment variables VSPHERE_USER, VSPHERE_PASSWORD, and TF_VAR_sat_password accordingly
 * Modify the ip address for the provisioning subnet in `main.tf` for each of the null_resource definitions (currently 10.110.111.x)

# Running the build

 * `terraform init`
 * `terraform plan -out cira.plan`
 * `terraform apply cira.plan`