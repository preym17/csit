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
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-X520-DA2 | ETH | L2BDMACLRN | SCALE | L2BDBASE | FIB_10K
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L2 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance mrr test
| ...
| Documentation | *Raw results for L2BD test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 bridge-\
| ... | domain and MAC learning enabled. DUT1 and DUT2 tested with 2p10GE NI
| ... | X520 Niantic by Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate tests TG sends traffic\
| ... | at line rate and reports total received/sent packets over trial period.\
| ... | Test packets are generated by TG on\
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups\
| ... | (flow-group per direction, 5k flows per flow-group) with all packets\
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static\
| ... | payload. MAC addresses ranges are incremented as follows:
| ... | port01_src ca:fe:00:00:00:00 - port01_src ca:fe:00:00:13:87,\
| ... | port01_dst fa:ce:00:00:00:00 - port01_dst fa:ce:00:00:13:87,\
| ... | port02_src fa:ce:00:00:00:00 - port02_src fa:ce:00:00:13:87,\
| ... | port02_dst ca:fe:00:00:00:00 - port02_dst ca:fe:00:00:13:87,\
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X520-DA2 bandwidth limit
| ${s_limit} | ${10000000000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-macsrc5kdst5k

*** Keywords ***
| Check RR for L2BD eth-l2bdscale
| | [Arguments] | ${framesize} | ${wt} | ${rxq}
| | ...
| | # Test Variables required for test teardown
| | Set Test Variable | ${framesize}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${get_framesize}
| | ...
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 bridge domain in 3-node circular topology
| | Then Traffic should pass with maximum rate | ${perf_trial_duration}
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-64B-1t1c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 64B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${64} | wt=1 | rxq=1

| tc02-1518B-1t1c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${1518} | wt=1 | rxq=1

| tc03-9000B-1t1c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${9000} | wt=1 | rxq=1

| tc04-IMIX-1t1c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single trial\
| | ... | throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX_v4_1 | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=IMIX_v4_1 | wt=1 | rxq=1

| tc05-64B-2t2c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 64B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${64} | wt=2 | rxq=1

| tc06-1518B-2t2c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${1518} | wt=2 | rxq=1

| tc07-9000B-2t2c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${9000} | wt=2 | rxq=1

| tc08-IMIX-2t2c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single trial\
| | ... | throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX_v4_1 | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=IMIX_v4_1 | wt=2 | rxq=1

| tc09-64B-4t4c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 64B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${64} | wt=4 | rxq=2

| tc10-1518B-4t4c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${1518} | wt=4 | rxq=2

| tc11-9000B-4t4c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=${9000} | wt=4 | rxq=2

| tc12-IMIX-4t4c-eth-l2dbscale10kmaclrn-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single trial\
| | ... | throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | 9000B | IMIX_v4_1 | MTHREAD
| | ...
| | [Template] | Check RR for L2BD eth-l2bdscale
| | framesize=IMIX_v4_1 | wt=4 | rxq=2