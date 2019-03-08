# Copyright (c) 2019 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Settings ***
| Resource | resources/libraries/robot/performance/performance_setup.robot
| ...
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-X710 | ETH | L2BDMACLRN | BASE | VHOST | VM
| ... | VHOST_1024 | NF_DENSITY | NF_L3FWDIP4 | CHAIN | 2R4C
| ...
| Suite Setup | Set up 2-node performance topology with DUT's NIC model
| ... | L3 | Intel-X710
| Suite Teardown | Tear down 2-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance mrr test with vhost and VM with dpdk-testpmd
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ...
| Test Template | Local Template
| ...
| Documentation | *Raw results L2BD test cases with 16 vhost 2 chains 8 VMs*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with L2 bridge-
| ... | domain and MAC learning enabled. Qemu VNFs are connected to VPP via
| ... | vhost-user interfaces. Guest is running DPDK l3fwd IPv4
| ... | interconnecting vhost-user interfaces, forwarding mode is
| ... | set to io, rxd/txd=1024. DUT1 is tested with 2p10GE NIC X710 by Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate test TG sends traffic
| ... | at line rate and reports total received/sent packets over trial period.
| ... | Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 254 flows per flow-group) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static
| ... | payload. MAC addresses are matching MAC addresses of NFs nodes
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X710 bandwidth limit
| ${s_limit}= | ${10000000000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-2n3n-ethip4-ip4src254-2c4n

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config.
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure MaxReceivedRate for ${framesize}B frames using single\
| | ... | trial throughput test.
| | ...
| | ... | *Arguments:*
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | ${dut1_vm_refs}= | Create Dictionary
| | Set Test Variable | ${dut1_vm_refs}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo And Handle Multi Seg
| | ... | ${s_limit} | ${framesize}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 bridge domains for multiple chains with Vhost-User
| | ... | nf_chains=${2} | nf_nodes=${4}
| | And Configure chains of NFs with dpdk-testpmd-mac connected via vhost-user
| | ... | nf_chains=${2} | nf_nodes=${4} | jumbo=${jumbo}
| | ... | perf_qemu_qsz=${1024} | use_tuned_cfs=${False}
| | Then Traffic should pass with maximum rate
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-64B-1c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 64B | 1C
| | framesize=${64} | phy_cores=${1}

| tc02-64B-2c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 64B | 2C
| | framesize=${64} | phy_cores=${2}

| tc03-64B-4c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 64B | 4C
| | framesize=${64} | phy_cores=${4}

| tc04-1518B-1c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc05-1518B-2c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc06-1518B-4c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc07-9000B-1c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 9000B | 1C
| | framesize=${9000} | phy_cores=${1}

| tc08-9000B-2c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 9000B | 2C
| | framesize=${9000} | phy_cores=${2}

| tc09-9000B-4c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | 9000B | 4C
| | framesize=${9000} | phy_cores=${4}

| tc10-IMIX-1c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-eth-l2bd-16vhost-2chain-8vm-l3fwdip4-mrr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
