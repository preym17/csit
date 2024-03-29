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
| Library | resources.libraries.python.Cop
| Library | resources.libraries.python.IPUtil
| Library | resources.libraries.python.Trace
| ...
| Resource | resources/libraries/robot/ip/ip6.robot
| Resource | resources/libraries/robot/l2/l2_xconnect.robot
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/shared/interfaces.robot
| Resource | resources/libraries/robot/shared/testing_path.robot
| Resource | resources/libraries/robot/shared/traffic.robot
| ...
| Force Tags | HW_ENV | VM_ENV | 3_NODE_SINGLE_LINK_TOPO
| ...
| Test Setup | Set up functional test
| ...
| Test Teardown | Tear down functional test
| ...
| Documentation | *COP Security IPv6 Whitelist Tests*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6-ICMPv6 on all links.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with IPv6 routing and
| ... | static routes. COP security white-lists are applied on DUT1 ingress
| ... | interface from TG. DUT2 is configured with L2XC.
| ... | *[Ver] TG verification:* Test ICMPv6 Echo Request packets are sent in
| ... | one direction by TG on link to DUT1; on receive TG verifies packets for
| ... | correctness and drops as applicable.
| ... | *[Ref] Applicable standard specifications:*

*** Variables ***
| ${tg_node}= | ${nodes['TG']}
| ${dut1_node}= | ${nodes['DUT1']}
| ${dut2_node}= | ${nodes['DUT2']}

| ${dut1_if1_ip}= | 3ffe:62::1
| ${dut1_if2_ip}= | 3ffe:63::1
| ${dut1_if1_ip_GW}= | 3ffe:62::2
| ${dut1_if2_ip_GW}= | 3ffe:63::2

| ${dut2_if1_ip}= | 3ffe:72::1
| ${dut2_if2_ip}= | 3ffe:73::1

| ${test_dst_ip}= | 3ffe:64::1
| ${test_src_ip}= | 3ffe:61::1

| ${cop_dut_ip}= | 3ffe:61::

| ${ip_prefix}= | 64

| ${fib_table_number}= | 1

*** Test Cases ***
| TC01: DUT permits IPv6 pkts with COP whitelist set with IPv6 src-addr
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG. [Enc] Eth-IPv6-ICMPv6. [Cfg] On DUT1 \
| | ... | configure interface IPv6 addresses and routes in the main
| | ... | routing domain, add COP whitelist on interface to TG with IPv6
| | ... | src-addr matching packets generated by TG; on DUT2 configure L2
| | ... | xconnect. [Ver] Make TG send ICMPv6 Echo Req on its interface to
| | ... | DUT1; verify received ICMPv6 Echo Req pkts are correct. [Ref]
| | Given Configure path in 3-node circular topology
| | ... | ${tg_node} | ${dut1_node} | ${dut2_node} | ${tg_node}
| | And Set interfaces in 3-node circular topology up
| | And Configure L2XC
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_to_tg}
| | And VPP Interface Set IP Address
| | ... | ${dut1_node} | ${dut1_to_tg} | ${dut1_if1_ip} | ${ip_prefix}
| | And VPP Interface Set IP Address
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_if2_ip} | ${ip_prefix}
| | And VPP Interface Set IP Address
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_if1_ip} | ${ip_prefix}
| | And VPP Interface Set IP Address
| | ... | ${dut2_node} | ${dut2_to_tg} | ${dut2_if2_ip} | ${ip_prefix}
| | And VPP Add IP Neighbor
| | ... | ${dut1_node} | ${dut1_to_tg} | ${dut1_if1_ip_GW} | ${tg_to_dut1_mac}
| | And VPP Add IP Neighbor
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_if2_ip_GW} | ${tg_to_dut2_mac}
| | And Vpp Route Add | ${dut1_node} | ${test_dst_ip} | ${ip_prefix}
| | ... | gateway=${dut1_if2_ip_GW} | interface=${dut1_to_dut2}
| | And Vpp All Ra Suppress Link Layer | ${nodes}
| | And Add fib table | ${dut1_node} | ${fib_table_number} | ipv6=${TRUE}
| | And Vpp Route Add | ${dut1_node} | ${cop_dut_ip} | ${ip_prefix}
| | ... | vrf=${fib_table_number} | local=${TRUE}
| | When COP Add whitelist Entry | ${dut1_node} | ${dut1_to_tg} | ip6 |
| | ... | ${fib_table_number}
| | And COP interface enable or disable | ${dut1_node} | ${dut1_to_tg} | enable
| | Then Send packet and verify headers | ${tg_node}
| | ... | ${test_src_ip} | ${test_dst_ip} | ${tg_to_dut1} | ${tg_to_dut1_mac}
| | ... | ${dut1_to_tg_mac} | ${tg_to_dut2} | ${dut1_to_dut2_mac}
| | ... | ${tg_to_dut2_mac}
