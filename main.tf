data "vsphere_datacenter" "dc" {
  name = "dc1"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "cluster1/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "provision_network" {
  name          = "public"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "masters" {
    count = 2
    name = "${format("master-%03d", count.index + 1)}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    num_cpus = 2
    memory = 2048
    guest_id = "something"
    network_interface = {
        network_id = "${data.vsphere_network.provision_network.id}"
    }
    disk {
        label = "disk0"
        size = 20
        unit_number = 1
    }
    disk {
        label = "disk1"
        size = 10
        unit_number = 2
    }
}