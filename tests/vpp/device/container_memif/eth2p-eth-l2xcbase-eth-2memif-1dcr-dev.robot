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
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/l2/l2_xconnect.robot
| Resource | resources/libraries/robot/l2/l2_traffic.robot
| Resource | resources/libraries/robot/shared/testing_path.robot
| ...
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | DEVICETEST | HW_ENV | DCR_ENV
| ... | FUNCTEST | L2XCFWD | BASE | ETH | MEMIF | DOCKER
| ...
| Suite Setup | Setup suite single link
| Test Setup | Setup test
| Test Teardown | Tear down test | packet_trace | container
| ...
| Documentation | *L2 cross-connect test cases with memif interface*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology with \
| ... | single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4-ICMPv4 for L2 switching of \
| ... | IPv4; Eth-IPv6-ICMPv6 for L2 switching of IPv6.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with L2 cross-connect \
| ... | (L2XC) switching. Container is connected to VPP via Memif interface. \
| ... | Container is running same VPP version as running on DUT.
| ... | *[Ver] TG verification:* Test ICMPv4 (or ICMPv6) Echo Request packets \
| ... | are sent in both directions by TG on links to DUT1 and via container; \
| ... | on receive TG verifies packets for correctness and their IPv4 (IPv6) \
| ... | src-addr, dst-addr and MAC addresses.
| ... | *[Ref] Applicable standard specifications:* RFC792

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | memif_plugin.so
| ${nic_name}= | virtual
# Memif
| ${sock_base}= | memif-DUT1_CNF
# Container
| ${container_engine}= | Docker
| ${container_chain_topology}= | chain_functional

*** Test Cases ***
| tc01-eth2p-ethip4-l2xcbase-eth-2memif-1dcr-device
| | [Documentation]
| | ... | [Top] TG=DUT=DCR. [Enc] Eth-IPv4-ICMPv4. [Cfg] On DUT configure \
| | ... | two L2 cross-connects (L2XC), each with one untagged interface \
| | ... | to TG and untagged i/f to docker over memif. [Ver] Make \
| | ... | TG send ICMPv4 Echo Reqs in both directions between two of its \
| | ... | i/fs to be switched by DUT to and from docker; verify all packets \
| | ... | are received. [Ref]
| | ...
| | Given Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP Enable Traces On All Duts | ${nodes}
| | When Configure path in 2-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['TG']}
| | And Start containers for device test
| | And Configure interfaces in path up
| | When Set up memif interfaces on DUT node | ${dut_node} | ${sock_base}
| | ... | ${sock_base} | dcr_uuid=${dcr_uuid}
| | ... | memif_if1=memif_if1 | memif_if2=memif_if2 | rxq=${0} | txq=${0}
| | And Configure L2XC | ${dut_node} | ${dut_to_tg_if1} | ${memif_if1}
| | And Configure L2XC | ${dut_node} | ${dut_to_tg_if2} | ${memif_if2}
| | Then Send ICMPv4 bidirectionally and verify received packets | ${tg_node}
| | ... | ${tg_to_dut_if1} | ${tg_to_dut_if2}

| tc02-eth2p-ethip6-l2xcbase-eth-2memif-1dcr-device
| | [Documentation]
| | ... | [Top] TG=DUT=DCR. [Enc] Eth-IPv6-ICMPv6. [Cfg] On DUT configure\
| | ... | two L2 cross-connects (L2XC), each with one untagged i/f to TG\
| | ... | and untagged i/f to docker over memif. [Ver] Make TG send\
| | ... | ICMPv6 Echo Reqs in both directions between two of its i/fs to\
| | ... | be switched by DUT to and from docker; verify all packets are\
| | ... | received. [Ref]
| | ...
| | Given Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And VPP Enable Traces On All Duts | ${nodes}
| | When Configure path in 2-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['TG']}
| | And Start containers for device test
| | And Configure interfaces in path up
| | When Set up memif interfaces on DUT node | ${dut_node} | ${sock_base}
| | ... | ${sock_base} | dcr_uuid=${dcr_uuid}
| | ... | memif_if1=memif_if1 | memif_if2=memif_if2 | rxq=${0} | txq=${0}
| | And Configure L2XC | ${dut_node} | ${dut_to_tg_if1} | ${memif_if1}
| | And Configure L2XC | ${dut_node} | ${dut_to_tg_if2} | ${memif_if2}
| | Then Send ICMPv6 bidirectionally and verify received packets | ${tg_node}
| | ... | ${tg_to_dut_if1} | ${tg_to_dut_if2}
