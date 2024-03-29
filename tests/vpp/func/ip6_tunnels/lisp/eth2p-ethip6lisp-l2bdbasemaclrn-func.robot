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
| Library | resources.libraries.python.IPUtil
| Library | resources.libraries.python.L2Util
| Library | resources.libraries.python.LispUtil
| Library | resources.libraries.python.NodePath
| Library | resources.libraries.python.topology.Topology
| Library | resources.libraries.python.Trace
| ...
| Resource | resources/libraries/robot/ip/ip4.robot
| Resource | resources/libraries/robot/overlay/l2lisp.robot
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/shared/interfaces.robot
| Resource | resources/libraries/robot/shared/traffic.robot
| Resource | resources/libraries/robot/shared/testing_path.robot
| ...
# Import configuration and test data:
| Variables | resources/test_data/lisp/l2/l2_ipv6.py
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | VM_ENV | LISP
| ...
| Test Setup | Set up functional test
| ...
| Test Teardown | Tear down functional test
| ...
| Documentation | *l2-lispgpe-ip6 encapsulation test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IP6-ICMPv6-LISPGpe-IP6
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 bridge\
| ... | domains and neighbors. LISPoIPv6 tunnel is configured between\
| ... | DUT1 and DUT2.
| ... | *[Ver] TG verification:* Test ICMPv6 Echo Request packets are sent in\
| ... | both directions by TG on links to DUT1 and DUT2; on receive\
| ... | TG verifies packets for correctness and their IPv6 src-addr, dst-addr\
| ... | and MAC addresses.
| ... | *[Ref] Applicable standard specifications:* RFC6830.

*** Test Cases ***
| TC01: Route IPv6 packet through LISP with Bridge Domain setup.
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG.
| | ... | [Enc] Eth-IP6-ICMPv6-LISPGpe-IP6
| | ... | [Cfg] Configure IPv6 LISP static adjacencies on DUT1 and DUT2. Also\
| | ... | configure BD and assign it to LISP VNI.
| | ... | [Ver] Make TG send ICMPv6 Echo Req between its interfaces across both\
| | ... | DUTs and LISP tunnel between them; verify IPv6, Ether headers on\
| | ... | received packets are correct.
| | ... | [Ref] RFC6830.
| | ...
| | Given Configure path in 3-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['DUT2']} | ${nodes['TG']}
| | And Set interfaces in 3-node circular topology up
| | And Configure IP addresses on interfaces
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_to_dut2_ip6} | ${prefix6}
| | ... | ${dut1_node} | ${dut1_to_tg} | ${dut1_to_tg_ip6} | ${prefix6}
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_to_dut1_ip6} | ${prefix6}
| | ... | ${dut2_node} | ${dut2_to_tg} | ${dut2_to_tg_ip6} | ${prefix6}
| | VPP Add IP Neighbor
| | ... | ${dut2_node} | ${dut2_to_tg} | ${tg2_ip6} | ${tg_to_dut2_mac}
| | VPP Add IP Neighbor
| | ... | ${dut1_node} | ${dut1_to_tg} | ${tg1_ip6} | ${tg_to_dut1_mac}
| | VPP Add IP Neighbor | ${dut1_node}
| | ... | ${dut1_to_dut2} | ${dut2_to_dut1_ip6} | ${dut2_to_dut1_mac}
| | VPP Add IP Neighbor | ${dut2_node}
| | ... | ${dut2_to_dut1} | ${dut1_to_dut2_ip6} | ${dut1_to_dut2_mac}
| | And Vpp All RA Suppress Link Layer | ${nodes}
| | When Create L2 BD | ${dut1_node} | ${vpp_bd_id}
| | And Add Interface To L2 BD | ${dut1_node} | ${dut1_to_tg} | ${vpp_bd_id}
| | And Create L2 BD | ${dut2_node} | ${vpp_bd_id}
| | And Add Interface To L2 BD | ${dut2_node} | ${dut2_to_tg} | ${vpp_bd_id}
| | And Configure L2 LISP on DUT | ${dut1_node}
| | ... | ${dut1_to_dut2_ip6_static_adjacency}
| | ... | ${lisp_dut_settings}
| | And Configure L2 LISP on DUT | ${dut2_node}
| | ... | ${dut2_to_dut1_ip6_static_adjacency}
| | ... | ${lisp_dut_settings}
| | Then Send packet and verify headers
| | ... | ${tg_node} | ${tg1_ip6} | ${tg2_ip6}
| | ... | ${tg_to_dut1} | ${tg_if1_mac} | ${tg_if2_mac}
| | ... | ${tg_to_dut2} | ${tg_if1_mac} | ${tg_if2_mac}
| | And Send packet and verify headers
| | ... | ${tg_node} | ${tg2_ip6} | ${tg1_ip6}
| | ... | ${tg_to_dut2} | ${tg_if2_mac} | ${tg_if1_mac}
| | ... | ${tg_to_dut1} | ${tg_if2_mac} | ${tg_if1_mac}
