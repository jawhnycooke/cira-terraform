data "vsphere_datacenter" "dc" {
  name = "cdcug-toronto-dc1"
}

data "vsphere_datastore" "datastore" {
  name          = "CDCUG_VMware_OCP_LAB"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "resource_pool1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "primary_network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "provision_network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "masters" {
    count = 3
    name = "${format("dev-osm-%02d", count.index + 1)}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    num_cpus = 2
    memory = 16384
    guest_id = "rhel7_64Guest"
    network_interface = {
        network_id = "${data.vsphere_network.primary_network.id}"
    }
    network_interface = {
        network_id = "${data.vsphere_network.provision_network.id}"
    }
    disk {
        label = "disk0"
        size = 70
        unit_number = 0
    }
    disk {
        label = "docker"
        size = 25
        unit_number = 1
    }
    wait_for_guest_net_timeout = 0
    boot_delay = 20000
}

resource "null_resource" "masters" {
  count = 3
  triggers {
    vm_ids = "${element(vsphere_virtual_machine.masters.*.id, count.index)}"
  }
  provisioner "remote-exec" {
        connection {
        host = "cdcug-satellite.cdcug.local"
        type = "ssh"
        user = "root"
        password = "${var.sat_password}"
        timeout = "30s"
        }
        inline = ["hammer host create --hostgroup-id=28 --name='${element(vsphere_virtual_machine.masters.*.name, count.index)}' --location-id=2 --organization-id=1 --ip=10.6.235.2${count.index + 1} --mac=${element(vsphere_virtual_machine.masters.*.network_interface.0.mac_address, count.index)} --subnet-id=9 --interface 'ip=10.6.235.2${count.index + 1},mac=${element(vsphere_virtual_machine.masters.*.network_interface.0.mac_address, count.index)},subnet-id=9,managed=true,primary=true' --interface 'ip=10.110.111.6${count.index + 1},mac=${element(vsphere_virtual_machine.masters.*.network_interface.1.mac_address, count.index)},subnet-id=7,managed=true,provision=true'"]
    }
}

resource "vsphere_virtual_machine" "infra" {
    count = 3
    name = "${format("dev-osi-%02d", count.index + 1)}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    num_cpus = 2
    memory = 16384
    guest_id = "rhel7_64Guest"
    network_interface = {
        network_id = "${data.vsphere_network.primary_network.id}"
    }
    network_interface = {
        network_id = "${data.vsphere_network.provision_network.id}"
    }
    disk {
        label = "disk0"
        size = 55
        unit_number = 0
    }
    disk {
        label = "docker"
        size = 25
        unit_number = 1
    }
    disk {
        label = "es"
        size = 50
        unit_number = 2
    }
    disk {
        label = "metrics"
        size = 25
        unit_number = 3
    }
    wait_for_guest_net_timeout = 0
    boot_delay = 20000
}

resource "null_resource" "infra" {
  count = 3
  triggers {
    vm_ids = "${element(vsphere_virtual_machine.infra.*.id, count.index)}"
  }
  provisioner "remote-exec" {
        connection {
        host = "cdcug-satellite.cdcug.local"
        type = "ssh"
        user = "root"
        password = "${var.sat_password}"
        timeout = "30s"
        }
        inline = ["hammer host create --hostgroup-id=28 --name='${element(vsphere_virtual_machine.infra.*.name, count.index)}' --location-id=2 --organization-id=1 --ip=10.6.235.3${count.index + 1} --mac=${element(vsphere_virtual_machine.infra.*.network_interface.0.mac_address, count.index)} --subnet-id=9 --interface 'ip=10.6.235.3${count.index + 1},mac=${element(vsphere_virtual_machine.infra.*.network_interface.0.mac_address, count.index)},subnet-id=9,managed=true,primary=true' --interface 'ip=10.110.111.6${count.index + 1},mac=${element(vsphere_virtual_machine.infra.*.network_interface.1.mac_address, count.index)},subnet-id=7,managed=true,provision=true'"]
    }
}

