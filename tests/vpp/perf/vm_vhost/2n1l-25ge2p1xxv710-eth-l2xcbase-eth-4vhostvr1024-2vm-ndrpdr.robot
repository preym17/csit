# Copyright (c) 2018 Cisco and/or its affiliates.
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
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-XXV710 | ETH | L2XCFWD | BASE | VHOST | 2VM | VHOST_1024
| ...
| Suite Setup | Set up 2-node performance topology with DUT's NIC model
| ... | L2 | Intel-XXV710
| Suite Teardown | Tear down 2-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance test with vhost and VM with dpdk-testpmd
| ... | ${min_rate}pps | ${framesize} | ${traffic_profile}
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ...
| Test Template | Local Template
| ...
| Documentation | *RFC2544: Pkt throughput L2XC test cases with vhost*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4. 802.1q
| ... | tagging is applied on link between DUT1 and DUT2.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with L2 cross-
| ... | connect. Qemu Guest is connected to VPP via vhost-user interfaces.
| ... | Guest is running DPDK testpmd interconnecting vhost-user interfaces,
| ... | forwarding mode is set to io, rxd/txd=256. DUT1 is tested with 2p25GE
| ... | NIC XXV710 by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using MLRsearch library.
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 254 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv4 header
| ... | with IP protocol=61 and static payload. MAC addresses are matching MAC
| ... | addresses of the TG node interfaces.

*** Variables ***
# XXV710-DA2 bandwidth limit ~49Gbps/2=24.5Gbps
| ${s_24.5G}= | ${24500000000}
# XXV710-DA2 Mpps limit 37.5Mpps/2=18.75Mpps
| ${s_18.75Mpps}= | ${18750000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-2n-ethip4-ip4src254

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config.
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
| | ...
| | ... | *Arguments:*
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${min_rate} | ${10000}
| | ${dut1_vm_refs}= | Create Dictionary
| | Set Test Variable | ${dut1_vm_refs}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo And Handle Multi Seg
| | ... | ${s_24.5G} | ${framesize} | pps_limit=${s_18.75Mpps}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 xconnect with Vhost-User | vm_count=${2}
| | And Configure guest VMs with dpdk-testpmd connected via vhost-user
| | ... | vm_count=${2} | jumbo=${jumbo} | perf_qemu_qsz=${1024}
| | ... | use_tuned_cfs=${False}
| | Then Find NDR and PDR intervals using optimized search
| | ... | ${framesize} | ${traffic_profile} | ${min_rate} | ${max_rate}

*** Test Cases ***
| tc01-64B-1c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 64B | 1C
| | framesize=${64} | phy_cores=${1}

| tc02-64B-2c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 64B | 2C
| | framesize=${64} | phy_cores=${2}

| tc03-64B-4c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 64B | 4C
| | framesize=${64} | phy_cores=${4}

| tc04-1518B-1c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc05-1518B-2c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc06-1518B-4c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc07-9000B-1c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 9000B | 1C
| | framesize=${9000} | phy_cores=${1}

| tc08-9000B-2c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 9000B | 2C
| | framesize=${9000} | phy_cores=${2}

| tc09-9000B-4c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | 9000B | 4C
| | framesize=${9000} | phy_cores=${4}

| tc10-IMIX-1c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-eth-l2xcbase-eth-4vhostvr1024-2vm-ndrpdr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
