#!/bin/bash -xe

HEAT_NETWORK_COUNT=$(openstack network list | grep -c heat-net)
MICRO_FLAVOR_COUNT=$(openstack flavor list | grep -c m1.heat_micro)
TINY_FLAVOR_COUNT=$(openstack flavor list | grep -c m1.heat_int)
CIRROS_IMAGE_COUNT=$(openstack image list | grep -c cirros-0.3.5-x86_64-disk)
if [ "$CIRROS_IMAGE_COUNT" -lt 1 ]; then
  wget -O cirros-0.3.5-x86_64-disk.img http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
  openstack image create "cirros-0.3.5-x86_64-disk" --file cirros-0.3.5-x86_64-disk.img --disk-format qcow2 --container-format bare --public
else
  echo "Cirros image already founded in OpenStack, skipping.."
fi

if [ "$TINY_FLAVOR_COUNT" -lt 1 ]; then
  openstack flavor create "m1.heat_int" --disk 1
else
  echo "Flavor m1.heat_int already founded in Openstack, skiping.."
fi

if [ "$MICRO_FLAVOR_COUNT" -lt 1 ]; then
  openstack flavor create "m1.heat_micro" --disk 1
else
  echo "Flavor m1.heat_micro already founded in Openstack, skiping.."
fi

if [ "$HEAT_NETWORK_COUNT" -lt 1 ]; then
  openstack network create "heat-net"
  openstack subnet create heat_subnet --subnet-range 10.20.30.0/24 --network "heat-net"
  echo "Network heat-net already founded in Openstack, skiping.."
fi

