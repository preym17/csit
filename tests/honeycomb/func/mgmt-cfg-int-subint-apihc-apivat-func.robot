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
| Resource | resources/libraries/robot/honeycomb/honeycomb.robot
| Resource | resources/libraries/robot/honeycomb/sub_interface.robot
| Resource | resources/libraries/robot/honeycomb/bridge_domain.robot
| Resource | resources/libraries/robot/honeycomb/interfaces.robot
| Library | resources.libraries.python.InterfaceUtil
| Variables | resources/test_data/honeycomb/sub_interfaces.py
| ...
| Suite Setup | Set Up Honeycomb Functional Test Suite | ${node}
| ...
| Suite Teardown | Tear Down Honeycomb Functional Test Suite | ${node}
| ...
| Force Tags | HC_FUNC
| ...
| Documentation | *Honeycomb sub-interface management test suite.*

*** Variables ***
# Test interfaces and their sub-interface parameters:
| ${super_if}= | ${node['interfaces']['port1']['name']}
| ${super_if2}= | ${node['interfaces']['port3']['name']}
| ${sub_if_id}= | ${sub_if_1_settings['identifier']}
| ${sub_if_name}= | ${super_if}.${sub_if_id}
| ${sub_if2_name}= | ${super_if2}.${sub_if_id}

*** Test Cases ***
| TC01: Honeycomb creates sub-interface
| | [Documentation] | Check if Honeycomb creates a sub-interface.
| | ...
| | Given Honeycomb configures interface state | ${node} | ${super_if} | down
| | And sub-interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${sub_if_name}
| | When Honeycomb creates sub-interface | ${node} | ${super_if}
| | ... | ${sub_if_1_match} | ${sub_if_1_tags} | ${sub_if_1_settings}
| | Then Sub-interface Operational Data From Honeycomb Should Be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${sub_if_1_oper}
| | And Sub-interface Operational Data From VAT Should Be
| | ... | ${node} | ${sub_if_name} | ${sub_if_1_oper}
| | And sub-interface indices from Honeycomb and VAT should correspond
| | ... | ${node} | ${super_if} | ${sub_if_id}

| TC02: Honeycomb sets interface and sub-interface up
| | [Documentation] | Honeycomb changes the state of interface\
| | ... | and of its sub-interface to up.
| | ...
| | Given interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | down
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | down
| | Sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | down | down
| | Sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | down | down
| | When Honeycomb configures interface state
| | ... | ${node} | ${super_if} | up
| | Then interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | up
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | up
| | When Honeycomb sets the sub-interface up
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | Vpp Node Interfaces Ready Wait | ${node}
| | Then Sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | up | up
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | up | up

| TC03: Honeycomb sets sub-interface down while its super-interface is up
| | [Documentation] | Honeycomb sets the sub-interface down while its \
| | ... | super-interface is up. It must be possible.
| | ...
| | [Teardown] | Set super and sub interfaces up
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | up | up
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | up | up
| | And interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | up
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | up
| | When Honeycomb sets the sub-interface down
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | Then interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | up
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | up
| | And sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | down | up
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | down | up

| TC04: Honeycomb sets interface and sub-interface down
| | [Documentation] | Honeycomb changes the state of interface down and then \
| | ... | changes the state of its sub-interface down, in this order.
| | ...
| | [Teardown] | Set super and sub interfaces down
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | up
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | up
| | When Honeycomb configures interface state
| | ... | ${node} | ${super_if} | down
| | Then interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | down
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | down
| | Given sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | up | down
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | up | down
| | When Honeycomb sets the sub-interface down
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | Then sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | down | down
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | down | down

| TC05: Honeycomb fails to set sub-interface up while its super-interface is down
| | [Documentation] | Honeycomb tries to set the sub-interface up while its \
| | ... | super-interface is down. It must not be possible.
| | ...
| | Given interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | down
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | down
| | And sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | down | down
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | down | down
| | When Honeycomb fails to set sub-interface up
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | Then interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | down
| | And interface state from VAT should be
| | ... | ${node} | ${super_if} | down
| | And sub-interface state from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | down | down
| | And sub-interface state from VAT should be
| | ... | ${node} | ${sub_if_name} | down | down

| TC06: Honeycomb fails to delete sub-interface
| | [Documentation] | Check if Honeycomb can delete an existing sub-interface.
| | ...
| | [Setup] | Set super and sub interfaces down
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given sub-interface Operational Data From Honeycomb Should Be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${sub_if_1_oper}
| | And sub-interface Operational Data From VAT Should Be
| | ... | ${node} | ${sub_if_name} | ${sub_if_1_oper}
| | When Honeycomb fails to remove all sub-interfaces
| | ... | ${node} | ${super_if}
| | Then sub-interface Operational Data From Honeycomb Should Be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${sub_if_1_oper}
| | And sub-interface Operational Data From VAT Should Be
| | ... | ${node} | ${sub_if_name} | ${sub_if_1_oper}

| TC07: Honeycomb adds sub-interface to new bridge domain
| | [Documentation] | Check if Honeycomb adds a sub-interface to bridge domain.
| | ...
| | [Setup] | Set super and sub interfaces down
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given sub-interface Operational Data From Honeycomb Should Be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${sub_if_1_oper}
| | And sub-interface Operational Data From VAT Should Be
| | ... | ${node} | ${sub_if_name} | ${sub_if_1_oper}
| | When Honeycomb creates first L2 bridge domain
| | ... | ${node} | ${bd_name} | ${bd_settings}
| | Then bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${bd_name} | ${bd_settings}
| | When Honeycomb adds sub-interface to bridge domain
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${sub_bd_settings}
| | Then sub-interface bridge domain Operational Data From Honeycomb Should Be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${sub_bd_settings}
| | And Sub-interface bridge domain Operational Data From PAPI Should Be
| | ... | ${node} | ${sub_if_name} | ${sub_bd_settings}
| | And sub-interface Operational Data From VAT Should Be
| | ... | ${node} | ${sub_if_name} | ${sub_if_1_oper}

| TC08: Honeycomb enables tag-rewrite pop 1
| | [Documentation] | Check if Honeycomb enables tag-rewrite and sets its \
| | ... | parameters correctly. Case: pop 1.
| | ...
| | [Teardown] | Honeycomb disables tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_pop_1_VAT}

| TC09: Honeycomb enables tag-rewrite push
| | [Documentation] | Check if Honeycomb enables tag-rewrite and sets its \
| | ... | parameters correctly. Case: push.
| | ...
| | [Teardown] | Honeycomb disables tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_push}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_push_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_push_VAT}

| TC10: Honeycomb enables tag-rewrite translate 1-2
| | [Documentation] | Check if Honeycomb enables tag-rewrite and sets its \
| | ... | parameters correctly. Case: translate 1-2.
| | ...
| | [Teardown] | Honeycomb disables tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_translate_1_2}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${tag_rewrite_translate_1_2_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_translate_1_2_VAT}

| TC11: Honeycomb disables tag-rewrite
| | [Documentation] | Check if Honeycomb disables the tag-rewrite.
| | ...
| | [Teardown] | Honeycomb disables tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1_oper}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_disabled}
| | Then rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_disabled_VAT}

| TC12: Honeycomb enables tag-rewrite pop 1 again
| | [Documentation] | Check if Honeycomb can enable tag-rewrite again, once it \
| | ... | was disabled by Honeycomb.
| | ...
| | [Teardown] | Honeycomb disables tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_pop_1_VAT}

| TC13: Honeycomb modifies the tag-rewrite
| | [Documentation] | Honeycomb sets the tag-rewrite:
| | ... | 1. pop 1, then
| | ... | 2. push, then
| | ... | 3. translate 1 - 2
| | ... | Then Honeycomb disables the tag-rewrite.
| | ...
| | [Teardown] | Honeycomb disables tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_pop_1_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_pop_1_VAT}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_push}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_push_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_push_VAT}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_translate_1_2}
| | Then rewrite tag from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${tag_rewrite_translate_1_2_oper}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_translate_1_2_VAT}
| | When Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_disabled}
| | Then rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_disabled_VAT}

| TC14: Honeycomb fails to set wrong vlan-type in tag-rewrite
| | [Documentation] | Check that Honeycomb does not accept wrong values of \
| | ... | vlan-type in tag-rewrite.
| | ...
| | Given rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | When Honeycomb fails to set wrong rewrite tag
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${tag_rewrite_translate_1_2_wrong}
| | Then rewrite tag from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And rewrite tag from VAT should be
| | ... | ${node} | ${sub_if_name} | ${tag_rewrite_disabled_VAT}

| TC15: Honeycomb configures sub-interface ipv4 address
| | [Documentation] | Check if Honeycomb can configure an ipv4 address on the\
| | ... | sub-interface.
| | ...
| | Given sub-interface ipv4 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv4 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}
| | When Honeycomb sets sub-interface ipv4 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | Then sub-interface ipv4 address from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And sub-interface ipv4 address from VAT should be
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}

| TC16: Honeycomb removes sub-interface ipv4 address
| | [Documentation] | Check if Honeycomb can remove configured ipv4 addresses\
| | ... | from the sub-interface.
| | ...
| | Given sub-interface ipv4 address from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | Run Keyword And Continue On Failure
| | ... | And sub-interface ipv4 address from VAT should be
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | When Honeycomb removes all sub-interface ipv4 addresses
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | Then sub-interface ipv4 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv4 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}

| TC17: Honeycomb modifies existing sub-interface ipv4 address
| | [Documentation] | Check if Honeycomb can modify an ipv4 address already\
| | ... | configured on the sub-interface.
| | ...
| | [Teardown] | Honeycomb removes all sub-interface ipv4 addresses
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given sub-interface ipv4 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv4 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}
| | When Honeycomb sets sub-interface ipv4 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And Honeycomb sets sub-interface ipv4 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4_2['address']} | ${ipv4_2['prefix-length']}
| | Then sub-interface ipv4 address from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4_2['address']} | ${ipv4_2['prefix-length']}
| | And sub-interface ipv4 address from VAT should be
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv4_2['address']} | ${ipv4_2['prefix-length']}

| TC18: Honeycomb modifies sub-interface exact tag match
| | [Documentation] | Check if Honeycomb can modify a sub-interface with exact\
| | ... | tag match.
| | ...
| | Given Honeycomb configures interface state | ${node} | ${super_if2} | down
| | And sub-interface Operational Data From Honeycomb Should Be empty
| | ... | ${node} | ${super_if2} | ${sub_if_id}
| | And interface Operational Data From VAT Should Be empty
| | ... | ${node} | ${sub_if2_name}
| | When Honeycomb creates sub-interface | ${node} | ${super_if2}
| | ... | ${sub_if_2_match} | ${sub_if_2_tags} | ${sub_if_2_settings}
| | Then Sub-interface Operational Data From Honeycomb Should Be
| | ... | ${node} | ${super_if2} | ${sub_if_id} | ${sub_if_2_oper}
| | And Sub-interface Operational Data From VAT Should Be
| | ... | ${node} | ${sub_if2_name} | ${sub_if_2_oper}
| | And sub-interface indices from Honeycomb and VAT should correspond
| | ... | ${node} | ${super_if2} | ${sub_if_id}

| TC19: Honeycomb configures sub-interface ipv6 address
| | [Documentation] | Check if Honeycomb can configure an ipv6 address on the\
| | ... | sub-interface.
| | ...
| | Given sub-interface ipv6 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv6 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}
| | When Honeycomb sets sub-interface ipv6 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv6['address']} | ${ipv6['prefix-length']}
| | Then sub-interface IPv6 address from Honeycomb should contain
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv6['address']} | ${ipv6['prefix-length']}
| | And sub-interface IPv6 address from VAT should contain
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv6['address']} | ${ipv6['prefix-length']}

| TC20: Honeycomb removes sub-interface ipv6 address
| | [Documentation] | Check if Honeycomb can remove configured ipv6 addresses\
| | ... | from the sub-interface.
| | ...
| | Given sub-interface IPv6 address from Honeycomb should contain
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv6['address']} | ${ipv6['prefix-length']}
| | Run Keyword And Continue On Failure
| | ... | And sub-interface IPv6 address from VAT should contain
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv6['address']} | ${ipv6['prefix-length']}
| | When Honeycomb removes all sub-interface ipv6 addresses
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | Then sub-interface ipv6 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv6 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}

| TC21: Honeycomb modifies existing sub-interface ipv6 address
| | [Documentation] | Check if Honeycomb can modify an ipv6 address already\
| | ... | configured on the sub-interface.
| | ...
| | [Teardown] | Honeycomb removes all sub-interface ipv6 addresses
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Given sub-interface ipv6 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv6 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}
| | When Honeycomb sets sub-interface ipv6 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv6['address']} | ${ipv6['prefix-length']}
| | And Honeycomb sets sub-interface ipv6 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv6_2['address']} | ${ipv6_2['prefix-length']}
| | Then sub-interface IPv6 address from Honeycomb should contain
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv6_2['address']} | ${ipv6_2['prefix-length']}
| | And sub-interface IPv6 address from VAT should contain
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv6_2['address']} | ${ipv6_2['prefix-length']}

| TC22: Honeycomb can configure unnumbered sub-interface
| | [Documentation] | Check if Honeycomb can configure an unnumbered interface\
| | ... | on a sub-interface, borrowing the IP address of a physical interface.
| | ...
# CSIT-1210: Adapt HC unnumbered interface tests to VPP 18.07 api changes
| | [Tags] | EXPECTED_FAILING
| | ...
| | Given sub-interface ipv4 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv4 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}
| | And Honeycomb sets interface IPv4 address | ${node}
| | ... | ${super_if2} | ${ipv4['address']} | ${ipv4['prefix-length']}
| | When Honeycomb adds unnumbered configuration to interface
| | ... | ${node} | ${super_if}.${sub_if_id} | ${super_if2}
| | Then IPv4 address from Honeycomb should be
| | ... | ${node} | ${super_if2} | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And IPv4 address from VAT should be
| | ... | ${node} | ${super_if2}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']} | ${ipv4['netmask']}
| | And sub-interface ipv4 address from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And sub-interface ipv4 address from VAT should be
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}

| TC23: Honeycomb removes sub-interface unnumbered configuration
| | [Documentation] | Check if Honeycomb can remove unnumbered configuration\
| | ... | from a sub-interface.
| | ...
| | [Teardown] | Honeycomb removes interface IPv4 addresses | ${node}
| | ... | ${super_if2}
| | ...
# CSIT-1210: Adapt HC unnumbered interface tests to VPP 18.07 api changes
| | [Tags] | EXPECTED_FAILING
| | ...
| | Given IPv4 address from Honeycomb should be
| | ... | ${node} | ${super_if2} | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And IPv4 address from VAT should be
| | ... | ${node} | ${super_if2}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']} | ${ipv4['netmask']}
| | And sub-interface ipv4 address from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And sub-interface ipv4 address from VAT should be
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | When Honeycomb removes unnumbered configuration from interface
| | ... | ${node} | ${super_if}.${sub_if_id}
| | Then IPv4 address from Honeycomb should be
| | ... | ${node} | ${super_if2} | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And IPv4 address from VAT should be
| | ... | ${node} | ${super_if2}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']} | ${ipv4['netmask']}
| | And sub-interface ipv4 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv4 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}

| TC24: Honeycomb can configure unnumbered interface using a sub-interface
| | [Documentation] | Check if Honeycomb can configure an unnumbered interface\
| | ... | on an interface, borrowing the IP address of a sub-interface.
| | ...
# CSIT-1210: Adapt HC unnumbered interface tests to VPP 18.07 api changes
| | [Tags] | EXPECTED_FAILING
| | ...
| | Given IPv4 address from Honeycomb should be empty | ${node} | ${super_if2}
| | And ipv4 address from VAT should be empty | ${node} | ${super_if2}
| | And sub-interface ipv4 address from Honeycomb should be empty
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | And sub-interface ipv4 address from VAT should be empty
| | ... | ${node} | ${sub_if_name}
| | And Honeycomb sets sub-interface ipv4 address
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | When Honeycomb adds unnumbered configuration to interface
| | ... | ${node} | ${super_if2} | ${super_if}.${sub_if_id}
| | Then IPv4 address from Honeycomb should be
| | ... | ${node} | ${super_if2} | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And IPv4 address from VAT should be
| | ... | ${node} | ${super_if2}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']} | ${ipv4['netmask']}
| | And sub-interface ipv4 address from Honeycomb should be
| | ... | ${node} | ${super_if} | ${sub_if_id}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}
| | And sub-interface ipv4 address from VAT should be
| | ... | ${node} | ${sub_if_name}
| | ... | ${ipv4['address']} | ${ipv4['prefix-length']}

*** Keywords ***
| Set super and sub interfaces up
| | [Documentation] | Honeycomb sets super-interface and sub-interface up, in \
| | ... | this order.
| | ...
| | ... | *Arguments:*
| | ... | - node - Information about a DUT node. Type: dictionary
| | ... | - super_interface - Super interface. Type: string
| | ... | - identifier - Sub-interface identifier. Type: integer or string
| | ...
| | ... | *Example:*
| | ... | \| Set super and sub interfaces up\
| | ... | \| ${nodes['DUT1']} \| GigabitEthernet0/8/0 \| 1 \|
| | ...
| | [Arguments] | ${node} | ${super_interface} | ${identifier}
| | ...
| | Honeycomb configures interface state
| | ... | ${node} | ${super_interface} | up
| | Honeycomb sets the sub-interface up
| | ... | ${node} | ${super_interface} | ${identifier}

| Set super and sub interfaces down
| | [Documentation] | Honeycomb sets super-interface and sub-interface down, in\
| | ... | this order.
| | ...
| | ... | *Arguments:*
| | ... | - node - Information about a DUT node. Type: dictionary
| | ... | - super_interface - Super interface. Type: string
| | ... | - identifier - Sub-interface identifier. Type: integer or string
| | ...
| | ... | *Example:*
| | ... | \| Set super and sub interfaces down\
| | ... | \| ${nodes['DUT1']} \| GigabitEthernet0/8/0 \| 1 \|
| | ...
| | [Arguments] | ${node} | ${super_interface} | ${identifier}
| | ...
| | Honeycomb configures interface state
| | ... | ${node} | ${super_interface} | down
| | Honeycomb sets the sub-interface down
| | ... | ${node} | ${super_interface} | ${identifier}

| Honeycomb disables tag rewrite
| | [Documentation] |
| | ...
| | ... | *Arguments:*
| | ... | - node - Information about a DUT node. Type: dictionary
| | ... | - super_if - Super-interface. Type: string
| | ... | - identifier - Sub-interface ID. Type: integer or string
| | ...
| | ... | *Example:*
| | ... | \| Honeycomb disables tag rewrite \
| | ... | \| ${nodes['DUT1']} \| GigabitEthernet0/8/0 \| 1 \|
| | ...
| | [Arguments] | ${node} | ${super_if} | ${sub_if_id}
| | ...
| | Honeycomb configures tag rewrite
| | ... | ${node} | ${super_if} | ${sub_if_id} | ${tag_rewrite_disabled}
