# narukozaka-tools

narukozaka-tools is a toolkit to help you create and setup Wakame-vdc/OpenVNet
environment with a simple web application on top of it. The runscripts are also
generated in order for ease to launch or discard your own Wakame-vdc/OpenVNet
environment whenever it is needed.

# Overview

narukozaka-tools is designed to launch the demo web application on top of both
AWS and bare metal servers. In this section the network architecture of the
demo web application will be explained at first. The underlying design of the
infrastructure will be shown at last.

### Demo Web Application

The demo web application consists of several virtual machines - 2 web servers,
1 load balancer, 1 database server and 1 backup db server - as an imitation
of web service existing in the real world. While a zabbix server which is
also deployed as a virtual machine constantly monitors those nodes of the demo
web application. All of the virtual machines including zabbix server participate
one or more virtual networks created by OpenVNet. The overall architecture of
the demo web application is shown in the following image.

![DemoWebApplication](https://www.dropbox.com/s/ew0q6gnz1k53o72/DemoSystem.png?dl=1)

### Infrastructure

The demo web application is build upon a hybrid environment of Wakame-vdc and OpenVNet.
See the following image for the brief overview of the underlying infrastructure.

![Infra](https://www.dropbox.com/s/0r6o3fv6f84ycud/infra.png?dl=1)

In the image there are 3 baremetal servers name as serve1, server2 and server3
respectively. Server1 is hva and vna node. Server2 is for vnmgr/webapi and
jenkins. Server3 is for dcmgr/collector. It assumes that the baremetal servers
can be reached from the Internet with global IP addresses. On server1 several
KVM instances will be launched by hva, which communicates with dcmgr and collector
over the management line. After hva launches the KVM instances, vna detects the
attachment of the VMs' interfaces to the datapath. vna then asks vnmgr about
the interfaces just attached. The communication between vna and vnmgr goes through
the Internet. vnet_edge is connected to server1 over GRE tunnels as well as
zabbix server and backup db server if those are launched as AWS instances.
All the network packets between the KVM instances and the AWS instances are
going through vnet_edge.


# Installation

```
$ git clone git@github.com:axsh/narukozaka-tools
```


# Configuration

### Box file

Download box files. By default `download_boxes.sh` downloads 2 box files in the
directory. The total size of the box files is around 2G bytes. Please make sure that
the platform has enough capacity.

```
$ cd boxes
$ ./download-boxes.sh
```

All the images of virtual machines are going to be created based on the box files
that have just been downloaded.

### AWS Region

Setup the region of AWS to launch instances. Edit `packer.conf` in config directory.

```
$ cd config
$ vi packer.conf
```

### Other

There are several files missing necessary configurations such as IP addresses.
Here are the list of files needed to be configured before going further.
Edit the following files according to your environment.

```
nodes/dcmgr/guestroot/etc/wakame-vdc/dcmgr.conf
nodes/dcmgr/metadata/ifcfg-eth0
nodes/narukins/metadata/ifcfg-eth1
nodes/vnet_edge/replace.sh
nodes/vnmgr/guestroot/etc/openvnet/vnmgr.conf
nodes/vnmgr/guestroot/etc/openvnet/webapi.conf
nodes/vnmgr/metadata/ifcfg-eth0
nodes/hva_vna/replace.sh
nodes/hva_vna/guestroot/etc/openvnet/common.conf
nodes/hva_vna/guestroot/etc/openvnet/vna.conf
```

# Usage

### Create Machine Images

`naruko` command allows you to create virtual machine images in raw format.
On those virtual machines the processes of Wakame-vdc and OpenVNet will be running.
Basically the syntax to create machine image is following.

```
naruko image build <node_name>
```

`naruko` command takes several arguments where the third parameter indicates the
name of the node. `<node_name>` must be corresponded to the directories' name in
`nodes` directory. The following command creates the virtual machine image of
dcmgr and collector.

```
$ ./naruko image build dcmgr
```

Likewise, the one with vnmgr and webapi is done by the following command.

```
$ ./naruko image build vnmgr
```

The machine image is named as `box-disk1.raw` in each `nodes/<node_name>` directory.


### Launch Wakame-vdc and OpenVNet

* dcmgr and vnmgr

dcmgr and vnmgr are supposed to be running on virtual machine.
In `nodes/dcmgr` (or `nodes/vnmgr`) there is a script named `run.sh` to launch the VM.

```
$ ./run.sh
```

* hva and vna

hva and vna are supposed to run on the same baremetal server. Go to the directory
named `hva_vna` then hit the following. (require root privilege)

```
# ./replace.sh
```

* vnet_edge

There is a vna supposed to run as vnet_edge. Launch one AWS instance, checkout
narukozaka-tools on it, then hit the following command in `nodes/hva_vna` directory.
(require root privilege)

```
# ./replace.sh
```

### Launch Demo Web Application

narukozaka-tools assumes that there are two environments where the demo web applicaion
will be running: baremetal servers and AWS. In this section it explains how to launch
the demo web applicaion on each environment.


* Baremetal Servers

In `nodes/hva_vna/guestroot/opt/axsh/wakame-vdc/client/mussel/test/experiment/v12.03/vnet`
there are two bash scripts: `t.vnet.destroy_instance.sh` and `t.vnet.launch_instance.sh`
In case to launch all the demo instances hit the following.

```
$ ./t.vnet.launch_instance.sh
```

In case of destroying the instances

```
$ ./t.vnet.destroy_instance.sh
```

It is also possible to launch/destroy a specific instance by adding `demo_instance_name=<name>`
before execute the script. The following is example of launching a lb instance.

```
$ demo_instance_name=lb ./t.vnet.launch_instance.sh
```

* AWS

In order to launch all the demo instances on AWS, use `start-all-aws.sh`

```
$ ./start-all-aws.sh
```

To launch a specifig instance

```
$ demo_instance_name=<name> ./start-aws.sh
```

In order to destroy the instances please use the AWS web interface.


# Architecture

```
narukozaka-tools/
├── bin
├── boxes
├── config
├── nodes
```

* bin

Executable scripts of `naruko-*` commands.

* boxes

Base box files used for machine image creation.

* config

Config files for narukozaka-tools.

* nodes

Executable scripts to generate machine images.


```
narukozaka-tools/nodes/
├── cc
├── common
├── dcmgr
├── demo-db
├── demo-db.aws
├── demo-db-backup
├── demo-lb
├── demo-lb.aws
├── demo-web
├── demo-web.aws
├── demo-zabbix
├── demo-zabbix.aws
├── narukins
├── vnet_edge
└── vnmgr
```

* cc

Empty. The executable scripts for CloudConductor.

* common

The executable scripts and several config files that are commonly used for machine
image creation.

* demo-*

Demo machine images for Wakame-vdc.

* demo-*.aws

Demo machine images for AWS.

* narukins

The scripts for jenkins.

* vnet_edge

Install vna running as vnet_edge.
