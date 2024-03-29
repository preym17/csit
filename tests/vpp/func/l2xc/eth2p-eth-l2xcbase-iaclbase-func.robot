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
| Resource | resources/libraries/robot/shared/counters.robot
| Resource | resources/libraries/robot/shared/interfaces.robot
| Resource | resources/libraries/robot/shared/testing_path.robot
| Resource | resources/libraries/robot/l2/l2_xconnect.robot
| Resource | resources/libraries/robot/l2/l2_traffic.robot
| Library | resources.libraries.python.Classify.Classify
| Library | resources.libraries.python.Trace
| Force Tags | HW_ENV | VM_ENV | 3_NODE_SINGLE_LINK_TOPO | SKIP_VPP_PATCH
| Test Setup | Set up functional test
| Test Teardown | Tear down functional test
| Documentation | *Ingress ACL test cases*
| ...
| ... | *[Top] Network Topologies:* TG - DUT1 - DUT2 - TG
| ... |        with one link between the nodes.
| ... | *[Cfg] DUT configuration:* DUT2 is configured with L2 Cross connect.
| ... |        DUT1 is configured with iACL classification on link to TG,
| ... | *[Ver] TG verification:* Test ICMPv4 Echo Request packets are sent
| ... |        in one direction by TG on link to DUT1 and received on TG link
| ... |        to DUT2. On receive TG verifies if packets are accepted.

*** Variables ***
| ${l2_table}= | l2

*** Test Cases ***
| TC01: DUT with iACL MAC src-addr accepts matching pkts
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG.
| | ... | [Cfg] On DUT1 add source MAC address to classify table with 'permit'.
| | Given Configure path in 3-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['DUT2']} | ${nodes['TG']}
| | And Set interfaces in 3-node circular topology up
| | And Configure L2XC
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_to_tg}
| | And Configure L2XC
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_to_tg}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}
| | ${table_index} | ${skip_n} | ${match_n}=
| | ... | When Vpp Creates Classify Table L2 | ${dut1_node}
| | ... | src | ${tg_to_dut1_mac}
| | And Vpp Configures Classify Session L2
| | ... | ${dut1_node} | permit | ${table_index} | src | ${tg_to_dut1_mac}
| | And Vpp Enable Input ACL Interface
| | ... | ${dut1_node} | ${dut1_to_tg} | ${l2_table} | ${table_index}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}

| TC02: DUT with iACL MAC dst-addr accepts matching pkts
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG.
| | ... | [Cfg] On DUT1 add destination MAC address to classify
| | ... | table with 'permit'.
| | ... | [Ver] Make TG verify matching packets are accepted.
| | Given Configure path in 3-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['DUT2']} | ${nodes['TG']}
| | And Set interfaces in 3-node circular topology up
| | And Configure L2XC
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_to_tg}
| | And Configure L2XC
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_to_tg}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}
| | ${table_index} | ${skip_n} | ${match_n}=
| | ... | When Vpp Creates Classify Table L2 | ${dut1_node}
| | ... | dst | ${tg_to_dut2_mac}
| | And Vpp Configures Classify Session L2
| | ... | ${dut1_node} | permit | ${table_index} | dst | ${tg_to_dut2_mac}
| | And Vpp Enable Input ACL Interface
| | ... | ${dut1_node} | ${dut1_to_tg} | ${l2_table} | ${table_index}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}

| TC03: DUT with iACL MAC src-addr and dst-addr accepts matching pkts
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG.
| | ... | [Cfg] On DUT1 add source and destination MAC address to classify
| | ... | table with 'permit'.
| | ... | [Ver] Make TG verify matching packets are accepted.
| | Given Configure path in 3-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['DUT2']} | ${nodes['TG']}
| | And Set interfaces in 3-node circular topology up
| | And Configure L2XC
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_to_tg}
| | And Configure L2XC
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_to_tg}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}
| | ${table_index_1} | ${skip_n_1} | ${match_n_1}=
| | ... | When Vpp Creates Classify Table L2 | ${dut1_node}
| | ... | src | ${tg_to_dut1_mac}
| | And Vpp Configures Classify Session L2
| | ... | ${dut1_node} | permit | ${table_index_1} | src | ${tg_to_dut1_mac}
| | ${table_index_2} | ${skip_n_2} | ${match_n_2}=
| | ... | When Vpp Creates Classify Table L2 | ${dut1_node}
| | ... | dst | ${tg_to_dut1_mac}
| | And Vpp Configures Classify Session L2
| | ... | ${dut1_node} | permit | ${table_index_2} | dst | ${tg_to_dut1_mac}
| | And Vpp Enable Input ACL Interface
| | ... | ${dut1_node} | ${dut1_to_tg} | ${l2_table} | ${table_index_1}
| | And Vpp Enable Input ACL Interface
| | ... | ${dut1_node} | ${dut1_to_tg} | ${l2_table} | ${table_index_2}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}

| TC04: DUT with iACL EtherType accepts matching pkts
| | [Documentation]
| | ... | [Top] TG-DUT1-DUT2-TG.
| | ... | [Cfg] On DUT1 add EtherType IPv4(0x0800) to classify table with
| | ... | 'permit'.
| | ... | [Ver] Make TG verify matching packets are accepted.
| | Given Configure path in 3-node circular topology
| | ... | ${nodes['TG']} | ${nodes['DUT1']} | ${nodes['DUT2']} | ${nodes['TG']}
| | And Set interfaces in 3-node circular topology up
| | And Configure L2XC
| | ... | ${dut1_node} | ${dut1_to_dut2} | ${dut1_to_tg}
| | And Configure L2XC
| | ... | ${dut2_node} | ${dut2_to_dut1} | ${dut2_to_tg}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}
| | ${table_index} | ${skip_n} | ${match_n}=
| | ... | When Vpp Creates Classify Table Hex
| | ... | ${dut1_node} | 000000000000000000000000ffff
| | And Vpp Configures Classify Session Hex
| | ... | ${dut1_node} | permit | ${table_index} | 0000000000000000000000000800
| | And Vpp Enable Input ACL Interface
| | ... | ${dut1_node} | ${dut1_to_tg} | ${l2_table} | ${table_index}
| | Then Send ICMP packet and verify received packet
| | ... | ${tg_node} | ${tg_to_dut1} | ${tg_to_dut2}
