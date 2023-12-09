#!/usr/bin/env python

import os

import geni.portal as portal
import geni.rspec.pg as rspec
import geni.rspec.igext as IG
import geni.rspec.emulab.pnext as PN
import geni.rspec.emulab.spectrum as spectrum


tourDescription = """
### srsRAN 5G using the POWDER Indoor OTA Lab

This profile instantiates an experiment for running srsRAN_Project 5G with COTS
UEs in standalone mode using resources in the POWDER indoor over-the-air (OTA)
lab. The indoor OTA lab includes:

- 4x NI X310 SDRs, each with a UBX-160 daughter card occupying channel 0. The
  TX/RX and RX2 ports on this channel are connected to broadband antennas. The
  SDRs are connected via fiber to near-edge compute resources.
- 4x Intel NUC compute nodes, each equipped with a Quectel RM500Q-GL 5G module
  that has been provisioned with a SIM card. The NUCs are also equipped with NI
  B210 SDRs.

You can find a diagram of the lab layout here: [OTA Lab
Diagram](https://gitlab.flux.utah.edu/powderrenewpublic/powder-deployment/-/raw/master/diagrams/ota-lab.png)

The following will be deployed:

- Server-class compute node (d430) with running the Open5GS 5G core network
- Server-class compute node (d740) with GnuRadio and a fiber connection to an X310 for observing spectrum use
- Intel NUC compute node with a B210 and srsRAN_Project for use as a gNodeB
- Up to three other NUC compute nodes, each with a COTS 5G module and supporting tools

Note: This profile currently defaults to using the 3430-3470 MHz spectrum
range and you need an approved reservation for this spectrum in order to use it.
It's also strongly recommended that you include the following necessary
resources in your reservation to gaurantee their availability at the time of
your experiment:

- A d430 compute node to host the core network
- A d740 compute node for the spectrum observation node
- `ota-nuc1` and at least one of the other indoor OTA NUCs (e.g. `ota-nuc2`)

"""

tourInstructions = """

Startup scripts will still be running when your experiment becomes ready.
Watch the "Startup" column on the "List View" tab for your experiment and wait
until all of the compute nodes show "Finished" before proceeding.

After all startup scripts have finished...

On `cn`:

After your experiment becomes ready, the Open5GS core network services will be
running as system services. You can check their status with `systemctl status
open5gs-*`.

If you'd like to monitor traffic between the various network
functions and the gNodeB, start tshark in a session:

```
NGIF=`ip r | awk '/192\.168\.1\.0/{print $3}'`
sudo tshark -i $NGIF \
  -f "not arp and not llc and not port 53 and not host archive.ubuntu.com and not host security.ubuntu.com"
```

Note: you should stop tshark before you generate heavy traffic across the
network (e.g., with iperf3), as it will start generating too much output to be
useful.

In another session, start following the logs for the AMF. This way you can
see when the UE attaches to the network.

```
sudo tail -f /var/log/open5gs/amf.log
```

In a session on `ota-nuc1-gnb-comp` do the following to start the srsRAN gNodeB:

```
sudo /var/tmp/srsRAN_Project/build/apps/gnb/gnb \
  -c /var/tmp/etc/srsran/gnb_rf_b200_tdd_n78_20mhz.yml \
  -c /var/tmp/etc/srsran/slicing.yml \
  -c /var/tmp/srsRAN_Project/configs/qam256.yml

```

Have a look at these files to see how the gNodeB is configured.

On `ota-nucX-cots-ue`:

After you've started the gNodeB, you can bring the COTS UE online. First, start
the Quectel connection manager (this manages the network interface associated
with the 5G UE):

```
sudo quectel-CM -s internet -4
```

In another session on the same node, bring the UE online:

```
# turn modem on
sudo sh -c "chat -t 1 -sv '' AT OK 'AT+CFUN=1' OK < /dev/ttyUSB2 > /dev/ttyUSB2"
```

The UE should attach to the network and pick up an IP address on the wwan
interface associated with the module. You'll see the wwan interface name and the
IP address in the stdout of the quectel-CM process.

You should now be able to generate traffic in either direction:

```
# from UE to CN traffic gen node (in session on ota-nucX-cots-ue)
ping 10.45.0.1

# from CN traffic generation service to UE (in session on CN5G node)
ping <IP address from quectel-CM>
```

This process may be repeated on the indoor OTA NUCs in order to attach multiple
modules to the network.

If the module doesn't attach to the network or pick up an IP address on the
first try, put the module into airplane mode with `sudo sh -c "chat -t 1 -sv ''
AT OK 'AT+CFUN=4' OK < /dev/ttyUSB2 > /dev/ttyUSB2"`, kill and restart
quectel-CM, then bring the module back online. If the module still fails to
associate and/or pick up an IP, try putting the module into airplane mode,
rebooting the associated NUC, and bringing the module back online again.
`chat` may return an error. If so, just run the command again.

If you would like to monitor the spectrum of your network, and you are logging
into these nodes from a machine capable of X11 forwarding, you can start an
X-forwarded session to `ota-x310-1-gnuradio-comp` by passing `-X` to your SSH
command, then doing:

```
uhd_fft -f3450e6 -g30 -s40e6
```

The spectrum occupancy will change as you attach UEs and pass traffic.

"""

BIN_PATH = "/local/repository/bin"
ETC_PATH = "/local/repository/etc"
UBUNTU_IMG = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD"
COTS_UE_IMG = "urn:publicid:IDN+emulab.net+image+PowderTeam:cots-jammy-image"
COMP_MANAGER_ID = "urn:publicid:IDN+emulab.net+authority+cm"
DEFAULT_SRSRAN_HASH = "55c984b55736d0dd2d2ee328f1ae8d9de97e3e19"
OPEN5GS_DEPLOY_SCRIPT = os.path.join(BIN_PATH, "deploy-open5gs.sh")
SRSRAN_DEPLOY_SCRIPT = os.path.join(BIN_PATH, "deploy-srsran.sh")


def x310_node_pair(idx, x310_radio):
    node = request.RawPC("{}-gnuradio-comp".format(x310_radio))
    node.component_manager_id = COMP_MANAGER_ID
    node.hardware_type = params.sdr_nodetype

    if params.sdr_compute_image:
        node.disk_image = params.sdr_compute_image
    else:
        node.disk_image = UBUNTU_IMG

    node_radio_if = node.addInterface("usrp_if")
    node_radio_if.addAddress(rspec.IPv4Address("192.168.40.1",
                                               "255.255.255.0"))

    radio_link = request.Link("radio-link-{}".format(idx))
    radio_link.bandwidth = 10*1000*1000
    radio_link.addInterface(node_radio_if)

    radio = request.RawPC("{}-gnb-sdr".format(x310_radio))
    radio.component_id = x310_radio
    radio.component_manager_id = COMP_MANAGER_ID
    radio_link.addNode(radio)

    nodeb_cn_if = node.addInterface("nodeb-cn-if")
    nodeb_cn_if.addAddress(rspec.IPv4Address("192.168.1.{}".format(idx + 2), "255.255.255.0"))
    cn_link.addInterface(nodeb_cn_if)

    if params.srsran_commit_hash:
        srsran_hash = params.srsran_commit_hash
    else:
        srsran_hash = DEFAULT_SRSRAN_HASH

    cmd = "{} '{}'".format(SRSRAN_DEPLOY_SCRIPT, srsran_hash)
    node.addService(rspec.Execute(shell="bash", command=cmd))
    node.addService(rspec.Execute(shell="bash", command="/local/repository/bin/tune-cpu.sh"))
    node.addService(rspec.Execute(shell="bash", command="/local/repository/bin/tune-sdr-iface.sh"))

def b210_nuc_pair(b210_node):
    node = request.RawPC("{}-cots-ue".format(b210_node))
    node.component_manager_id = COMP_MANAGER_ID
    node.component_id = b210_node
    node.disk_image = COTS_UE_IMG
    node.addService(rspec.Execute(shell="bash", command="/local/repository/bin/module-off.sh"))

pc = portal.Context()

node_types = [
    ("d430", "Emulab, d430"),
    ("d740", "Emulab, d740"),
]
pc.defineParameter(
    name="sdr_nodetype",
    description="Type of compute node paired with the SDRs",
    typ=portal.ParameterType.STRING,
    defaultValue=node_types[1],
    legalValues=node_types
)

pc.defineParameter(
    name="cn_nodetype",
    description="Type of compute node to use for CN node (if included)",
    typ=portal.ParameterType.STRING,
    defaultValue=node_types[0],
    legalValues=node_types
)

pc.defineParameter(
    name="sdr_compute_image",
    description="Image to use for compute connected to SDRs",
    typ=portal.ParameterType.STRING,
    defaultValue="",
    advanced=True
)

pc.defineParameter(
    name="srsran_commit_hash",
    description="Commit hash for srsRAN",
    typ=portal.ParameterType.STRING,
    defaultValue="",
    advanced=True
)

pc.defineParameter(
    name="ru_compute_id",
    description="Component ID for compute node connected to RU",
    typ=portal.ParameterType.STRING,
    defaultValue="pc19-meb",
)

indoor_ota_x310s = [
    ("ota-x310-1",
     "USRP X310 #1"),
    ("ota-x310-2",
     "USRP X310 #2"),
    ("ota-x310-3",
     "USRP X310 #3"),
    ("ota-x310-4",
     "USRP X310 #4"),
]
pc.defineParameter(
    name="x310_radio",
    description="X310 Radio (for OAI gNodeB)",
    typ=portal.ParameterType.STRING,
    defaultValue=indoor_ota_x310s[0],
    legalValues=indoor_ota_x310s
)

indoor_ota_nucs = [
    ("ota-nuc%d" % (i,), "Indoor OTA nuc#%d with B210 and COTS UE" % (i,)) for i in range(2, 5) ]
pc.defineStructParameter(
    name="b210_nodes",
    description="Indoor OTA NUC with B210 and COTS UE",
    defaultValue=[ { "node_id": "ota-nuc2" } ],
    multiValue=True,
    min=1,
    max=len(indoor_ota_nucs),
    members=[
        portal.Parameter(
            "node_id", "Indoor OTA NUC", portal.ParameterType.STRING,
            indoor_ota_nucs[0], indoor_ota_nucs)])

portal.context.defineStructParameter(
    "freq_ranges", "Frequency Ranges To Transmit In",
    defaultValue=[{"freq_min": 3550.0, "freq_max": 3600.0}],
    multiValue=True,
    min=0,
    multiValueTitle="Frequency ranges to be used for transmission.",
    members=[
        portal.Parameter(
            "freq_min",
            "Frequency Range Min",
            portal.ParameterType.BANDWIDTH,
            3550.0,
            longDescription="Values are rounded to the nearest kilohertz."
        ),
        portal.Parameter(
            "freq_max",
            "Frequency Range Max",
            portal.ParameterType.BANDWIDTH,
            3600.0,
            longDescription="Values are rounded to the nearest kilohertz."
        ),
    ]
)

params = pc.bindParameters()
pc.verifyParameters()
request = pc.makeRequestRSpec()

role = "cn"
cn_node = request.RawPC("cn5g")
cn_node.component_manager_id = COMP_MANAGER_ID
cn_node.hardware_type = params.cn_nodetype
cn_node.disk_image = UBUNTU_IMG
cn_if = cn_node.addInterface("cn-if")
cn_if.addAddress(rspec.IPv4Address("192.168.1.1", "255.255.255.0"))
cn_link = request.Link("cn-link")
cn_link.setNoBandwidthShaping()
cn_link.addInterface(cn_if)
cn_node.addService(rspec.Execute(shell="bash", command=OPEN5GS_DEPLOY_SCRIPT))

# single x310 for for observation or another gNodeB
x310_node_pair(0, params.x310_radio)

# using nuc1 as a gNodeB for now
if params.srsran_commit_hash:
    srsran_hash = params.srsran_commit_hash
else:
    srsran_hash = DEFAULT_SRSRAN_HASH

nuc_nodeb = request.RawPC("ota-nuc1-gnb-comp")
nuc_nodeb.component_manager_id = COMP_MANAGER_ID
nuc_nodeb.component_id = "ota-nuc1"
nuc_nodeb.image = COTS_UE_IMG
node_cn_if = nuc_nodeb.addInterface("nuc-nodeb-cn-if")
node_cn_if.addAddress(rspec.IPv4Address("192.168.1.3", "255.255.255.0"))
cn_link.addInterface(node_cn_if)
cmd = "{} '{}'".format(SRSRAN_DEPLOY_SCRIPT, srsran_hash)
nuc_nodeb.addService(rspec.Execute(shell="bash", command=cmd))
nuc_nodeb.addService(rspec.Execute(shell="bash", command="/local/repository/bin/module-off.sh"))

ru_nodeb = request.RawPC("ru-gnb-comp")
ru_nodeb.component_manager_id = COMP_MANAGER_ID
ru_nodeb.component_id = params.ru_compute_id
ru_nodeb.image = UBUNTU_IMG
ru_node_cn_if = ru_nodeb.addInterface("ru-nodeb-cn-if")
ru_node_cn_if.addAddress(rspec.IPv4Address("192.168.1.4", "255.255.255.0"))
cn_link.addInterface(ru_node_cn_if)
cmd = "{} '{}'".format(SRSRAN_DEPLOY_SCRIPT, srsran_hash)
ru_nodeb.addService(rspec.Execute(shell="bash", command=cmd))

# require the rest of the indoor OTA nucs for now
for b210_node in params.b210_nodes:
    b210_nuc_pair(b210_node.node_id)

for frange in params.freq_ranges:
    request.requestSpectrum(frange.freq_min, frange.freq_max, 0)

tour = IG.Tour()
tour.Description(IG.Tour.MARKDOWN, tourDescription)
tour.Instructions(IG.Tour.MARKDOWN, tourInstructions)
request.addTour(tour)

pc.printRequestRSpec(request)
