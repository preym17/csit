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
| Library | resources.libraries.python.InterfaceUtil
| Library | resources.libraries.python.honeycomb.HcAPIKwInterfaces.InterfaceKeywords

*** Variables ***
# Translation table used to convert values received from Honeycomb to values
# received from VAT.
| &{protocols}=
| ... | -=0
| ... | ipv4=1
| ... | ipv6=2
| ... | ethernet=3
| ... | nsh=4

*** Keywords ***
| Honeycomb creates VxLAN GPE interface
| | [Documentation] | Uses Honeycomb API to configure a VxLAN tunnel.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ... | - interface - name of an interface to be created. Type: string
| | ... | - base_settings - configuration data common for all interfaces.\
| | ... | Type: dictionary
| | ... | - vxlan_gpe_settings - VxLAN GPE specific parameters. Type: dictionary
| | ...
| | ... | *Example:*
| | ... | \| Honeycomb creates VxLAN GPE interface \
| | ... | \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \| ${base_params} \
| | ... | \| ${vxlan_gpe_params} \|
| | ...
| | [Arguments] | ${node} | ${interface}
| | ... | ${base_settings} | ${vxlan_gpe_settings}
| | ...
| | Create VxLAN GPE interface
| | ... | ${node} | ${interface} | &{base_settings} | &{vxlan_gpe_settings}

| Honeycomb removes VxLAN GPE interface
| | [Documentation] | Uses Honeycomb API to remove VxLAN GPE interface from\
| | ... | node.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ... | - interface - name of the interface to be removed. Type: string
| | ...
| | ... | *Example:*
| | ...
| | ... | \| Honeycomb removes VxLAN GPE interface \
| | ... | \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \|
| | ...
| | [Arguments] | ${node} | ${interface}
| | ...
| | Delete interface | ${node} | ${interface}

| VxLAN GPE Operational Data From Honeycomb Should Be
| | [Documentation] | Uses Honeycomb API to get operational data about the\
| | ... | given interface and compares them to the values provided as arguments.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ... | - interface - name of an interface to be checked. Type: string
| | ... | - base_settings - configuration data common for all interfaces.\
| | ... | Type: dictionary
| | ... | - vxlan_gpe_settings - VxLAN GPE specific parameters. Type: dictionary
| | ...
| | ... | *Example:*
| | ... | \| VxLAN GPE Operational Data From Honeycomb Should Be \
| | ... | \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \| ${base_params} \
| | ... | \| ${vxlan_gpe_params} \|
| | ...
| | [Arguments] | ${node} | ${interface}
| | ... | ${base_settings} | ${vxlan_gpe_settings}
| | ...
| | ${api_data}= | Get interface oper data | ${node} | ${interface}
| | Should be equal as strings
| | ... | ${api_data['name']} | ${base_settings['name']}
| | Should be equal as strings
| | ... | ${api_data['type']} | v3po:vxlan-gpe-tunnel
| | Run keyword if | $base_settings['enabled'] == True
| | ... | Run keywords
| | ... | Should be equal as strings | ${api_data['admin-status']} | up
| | ... | AND
| | ... | Should be equal as strings | ${api_data['oper-status']} | up
| | ... | ELSE
| | ... | Run keywords
| | ... | Should be equal as strings | ${api_data['admin-status']} | down
| | ... | AND
| | ... | Should be equal as strings | ${api_data['oper-status']} | down

| VxLAN GPE Operational Data From VAT Should Be
| | [Documentation] | Uses VAT to get operational data about the given\
| | ... | interface and compares them to the values provided as arguments.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ... | - interface - name of an interface to be checked. Type: string
| | ... | - vxlan_gpe_settings - VxLAN GPE specific parameters. Type: dictionary
| | ...
| | ... | *Example:*
| | ... | \| VxLAN GPE Operational Data From VAT Should Be \
| | ... | \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \| ${vxlan_gpe_params} \|
| | ...
| | [Arguments] | ${node} | ${interface} | ${vxlan_gpe_params}
| | ...
| | ${if1}= | Vpp Get Interface Sw Index | ${node} | ${interface}
| | ${vat_data}= | VxLAN GPE Dump | ${node} | ${if1}
| | Should be equal as strings
| | ... | ${vat_data['local']} | ${vxlan_gpe_params['local']}
| | Should be equal as strings
| | ... | ${vat_data['remote']} | ${vxlan_gpe_params['remote']}
| | Should be equal as strings
| | ... | ${vat_data['vni']} | ${vxlan_gpe_params['vni']}
| | Should be equal as strings
| | ... | ${vat_data['encap_vrf_id']} | ${vxlan_gpe_params['encap-vrf-id']}
| | Should be equal as strings
| | ... | ${vat_data['decap_vrf_id']} | ${vxlan_gpe_params['decap-vrf-id']}
| | Should be equal as strings | ${vat_data['protocol']}
| | ... | ${protocols['${vxlan_gpe_params['next-protocol']}']}

| VxLAN GPE Interface indices from Honeycomb and VAT should correspond
| | [Documentation] | Uses VAT and Honeycomb to get operational data about the \
| | ... | given VxLAN GPE interface and compares the interface indexes. The \
| | ... | VxLAN GPE interface index from Honeycomb should be greater than \
| | ... | index from VAT by one.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ... | - interface - name of the interface to be checked. Type: string
| | ...
| | ... | *Example:*
| | ...
| | ... | \| VxLAN GPE Interface indices from Honeycomb and VAT should \
| | ... | correspond \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \|
| | ...
| | [Arguments] | ${node} | ${interface}
| | ...
| | ${api_data}= | Get interface oper data | ${node} | ${interface}
| | ${if1}= | Vpp Get Interface Sw Index | ${node} | ${interface}
| | ${vat_data}= | VxLAN GPE Dump | ${node} | ${if1}
| | ${sw_if_index}= | EVALUATE | ${vat_data['sw_if_index']} + 1
| | Should be equal as strings
| | ... | ${api_data['if-index']} | ${sw_if_index}

| VxLAN GPE Operational Data From Honeycomb Should Be empty
| | [Documentation] | Uses Honeycomb API to get operational data about\
| | ... | the given interface and expects to fail.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ...
| | ... | *Example:*
| | ... | \| VxLAN GPE Operational Data From Honeycomb Should Be empty\
| | ... | \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \|
| | ...
| | [Arguments] | ${node} | ${interface}
| | ...
| | ${api_data}= | Get interface oper data | ${node} | ${interface}
| | Should be empty | ${api_data}

| VxLAN GPE Operational Data From VAT Should Be empty
| | [Documentation] | Uses VAT to get operational data about the given\
| | ... | interface and expects an empty dictionary.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ...
| | ... | *Example:*
| | ... | \| VxLAN GPE Operational Data From VAT Should Be empty\
| | ... | \| ${nodes['DUT1']} \|
| | ...
| | [Arguments] | ${node}
| | ${data}= | VxLAN Dump | ${node}
| | Should be empty | ${data}

| Honeycomb fails to create VxLAN GPE interface
| | [Documentation] | Uses Honeycomb API to configure a VxLAN tunnel with wrong\
| | ... | configuration data.
| | ...
| | ... | *Arguments:*
| | ... | - node - information about a DUT node. Type: dictionary
| | ... | - interface - name of an interface to be created. Type: string
| | ... | - base_settings - Configuration data common for all interfaces.\
| | ... | Type: dictionary
| | ... | - vxlan_gpe_settings - VxLAN GPE specific parameters. Type: dictionary
| | ...
| | ... | *Example:*
| | ... | \| Honeycomb fails to create VxLAN GPE interface \
| | ... | \| ${nodes['DUT1']} \| vxlan_gpe_tunnel0 \| ${wrong_base_params} \
| | ... | \| ${vxlan_gpe_params} \|
| | ...
| | [Arguments] | ${node} | ${interface}
| | ... | ${base_settings} | ${vxlan_gpe_settings}
| | ...
| | Run keyword and expect error | *HoneycombError*not successful. * code: *00.
| | ... | Create VxLAN GPE interface
| | ... | ${node} | ${interface} | &{base_settings} | &{vxlan_gpe_settings}
