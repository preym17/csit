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

*** Variables ***
# Interfaces to run tests on.
| @{interfaces}= | ${node['interfaces']['port1']['name']}
| ... | ${node['interfaces']['port3']['name']}
# Configuration which will be set and verified during tests.
| ${bd1_name}= | bd-01
| ${bd2_name}= | bd-02
| &{bd_settings}= | flood=${True} | forward=${True} | learn=${True}
| ... | unknown-unicast-flood=${True} | arp-termination=${True}
| &{if_settings}= | split_horizon_group=${1} | bvi=${False}
| &{if_settings2}= | split_horizon_group=${2} | bvi=${True}

*** Settings ***
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/honeycomb/honeycomb.robot
| Resource | resources/libraries/robot/honeycomb/interfaces.robot
| Resource | resources/libraries/robot/honeycomb/bridge_domain.robot
| ...
| Suite Setup | Set Up Honeycomb Functional Test Suite | ${node}
| ...
| Suite Teardown | Tear Down Honeycomb Functional Test Suite | ${node}
| ...
| Force Tags | HC_FUNC
| ...
| Documentation | *Honeycomb bridge domain management test suite.*

*** Test Cases ***
| TC01: Honeycomb sets up l2 bridge domain
| | [Documentation] | Check if Honeycomb can create bridge domains on VPP node.
| | ...
| | When Honeycomb creates first l2 bridge domain
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | Then Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | And Bridge domain Operational Data From VAT Should Be
| | ... | ${node} | ${0} | ${bd_settings}

| TC02: Honeycomb manages multiple bridge domains on node
| | [Documentation] | Check if Honeycomb can manage multiple bridge domains on\
| | ... | a single node.
| | ...
| | Given Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | When Honeycomb creates l2 bridge domain
| | ... | ${node} | ${bd2_name} | ${bd_settings}
| | Then Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | And Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd2_name} | ${bd_settings}
| | And Bridge domain Operational Data From VAT Should Be
| | ... | ${node} | ${0} | ${bd_settings}
| | And Bridge domain Operational Data From VAT Should Be
| | ... | ${node} | ${1} | ${bd_settings}

| TC03: Honeycomb removes bridge domains
| | [Documentation] | Check if Honeycomb can remove bridge domains from a VPP\
| | ... | node.
| | ...
| | Given Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | When Honeycomb removes all bridge domains | ${node}
| | Then Honeycomb should show no bridge domains | ${node}
| | And PAPI should show no bridge domains | ${node}

| TC04: Honeycomb assigns interfaces to bridge domain
| | [Documentation] | Check if Honeycomb can assign VPP interfaces to an\
| | ... | existing bridge domain.
| | ...
| | Given Honeycomb creates first l2 bridge domain
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | When Honeycomb adds interfaces to bridge domain
| | ... | ${node} | @{interfaces} | ${bd1_name} | ${if_settings}
| | Then Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | And Bridge domain Operational Data From VAT Should Be
| | ... | ${node} | ${0} | ${bd_settings}
| | And Honeycomb should show interfaces assigned to bridge domain
| | ... | ${node} | @{interfaces} | ${bd1_name} | ${if_settings}
| | And PAPI should show interfaces assigned to bridge domain
| | ... | ${node} | ${0} | @{interfaces} | ${if_settings}

| TC05: Honeycomb cannot remove bridge domain with an interface assigned
| | [Documentation] | Check if Honeycomb can remove a bridge domain that has an\
| | ... | interface assigned to it. Expect to fail with code 500.
| | ...
| | Given Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | And Bridge domain Operational Data From VAT Should Be
| | ... | ${node} | ${0} | ${bd_settings}
| | And Honeycomb should show interfaces assigned to bridge domain
| | ... | ${node} | @{interfaces} | ${bd1_name} | ${if_settings}
| | And PAPI should show interfaces assigned to bridge domain
| | ... | ${node} | ${0} | @{interfaces} | ${if_settings}
| | When Run keyword and expect error | HoneycombError* Status code: 500.
| | ... | Honeycomb removes all bridge domains | ${node}
| | Then Bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd1_name} | ${bd_settings}
| | And Bridge domain Operational Data From VAT Should Be
| | ... | ${node} | ${0} | ${bd_settings}
| | And Honeycomb should show interfaces assigned to bridge domain
| | ... | ${node} | @{interfaces} | ${bd1_name} | ${if_settings}
| | And PAPI should show interfaces assigned to bridge domain
| | ... | ${node} | ${0} | @{interfaces} | ${if_settings}
