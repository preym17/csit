# Copyright (c) 2016 Cisco and/or its affiliates.
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
| Resource | resources/libraries/robot/shared/testing_path.robot
| Resource | resources/libraries/robot/overlay/vxlan.robot
| Resource | resources/libraries/robot/l2/l2_traffic.robot
| Resource | resources/libraries/robot/l2/l2_xconnect.robot
| Library  | resources.libraries.python.Trace
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | VM_ENV | HW_ENV
| Test Setup | Set up functional test
| Test Teardown | Tear down functional test
| Documentation | *RFC7348 VXLAN: L2 cross-connect with VXLAN test cases*
| ...
| ... | *[Top] Network topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet encapsulations:* Eth-IPv4-VXLAN-Eth-IPv4-ICMPv4 on
| ... | DUT1-DUT2, Eth-IPv4-ICMPv4 on TG-DUTn for L2 switching of IPv4.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2
| ... | cross-connect (L2XC) switching; VXLAN tunnels are configured between
| ... | L2XCs on DUT1 and DUT2.
| ... | *[Ver] TG verification:* Test ICMPv4 Echo Request packets
| ... | are sent in both directions by TG on links to DUT1 and DUT2; on receive
| ... | TG verifies packets for correctness and their IPv4 src-addr, dst-addr
| ... | and MAC addresses.
| ... | *[Ref] Applicable standard specifications:* RFC7348.

*** Variables ***
| ${VNI}= | 24

*** Test Cases ***
| TC01: DUT1 and DUT2 with L2XC and VXLANoIPv4 tunnels switch ICMPv4 between TG links
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG. [Enc] Eth-IPv4-VXLAN-Eth-IPv4-ICMPv4 on \
| | ... | [Ref] RFC7348.DUT1-DUT2, Eth-IPv4-ICMPv4 on TG-DUTn. [Cfg] On
| | ... | DUT1 and DUT2 configure L2 cross-connect (L2XC), each with one
| | ... | interface to TG and one VXLAN tunnel interface towards the other
| | ... | DUT. [Ver] Make TG send ICMPv4 Echo Req between two of its
| | ... | interfaces; verify all packets are received. [Ref] RFC7348.
| | Given Configure path in 3-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['DUT2']} | ${nodes['TG']}
| | And Set interfaces in 3-node circular topology up
| | ${dut1_to_dut2_name}= | Get interface name | ${dut1_node} | ${dut1_to_dut2}
| | ${dut2_to_dut1_name}= | Get interface name | ${dut2_node} | ${dut2_to_dut1}
| | And Configure IP addresses and neighbors on interfaces
| | ... | ${dut1_node} | ${dut1_to_dut2_name} | ${NONE}
| | ... | ${dut2_node} | ${dut2_to_dut1_name} | ${NONE}
| | ${dut1s_vxlan}= | When Create VXLAN interface | ${dut1_node} | ${VNI}
| | | ... | ${dut1s_ip_address} | ${dut2s_ip_address}
| | And Configure L2XC | ${dut1_node} | ${dut1_to_tg} | ${dut1s_vxlan}
| | ${dut2s_vxlan}= | And Create VXLAN interface | ${dut2_node} | ${VNI}
| | | ... | ${dut2s_ip_address} | ${dut1s_ip_address}
| | And Configure L2XC | ${dut2_node} | ${dut2_to_tg} | ${dut2s_vxlan}
| | Then Send ICMPv4 bidirectionally and verify received packets
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}
| | And Get VXLAN dump | ${dut1_node}
| | And Get VXLAN dump | ${dut1_node} | interface=vxlan_tunnel0
| | And Get VXLAN dump | ${dut2_node} | interface=${dut2s_vxlan}
