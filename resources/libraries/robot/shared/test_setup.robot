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

"""Keywords used in test setups."""

*** Settings ***
| Library | resources.libraries.python.PapiHistory
| ...
| Documentation | Test Setup keywords.

*** Keywords ***
| Setup test
| | [Documentation]
| | ... | Common test setup for tests.
| | ...
| | ... | *Arguments:*
| | ... | - ${actions} - Additional setup action. Type: list
| | ...
| | [Arguments] | @{actions}
| | ...
| | Reset PAPI History On All DUTs | ${nodes}
| | Create base startup configuration of VPP on all DUTs
| | :FOR | ${action} | IN | @{actions}
| | | Run Keyword | Additional Test Setup Action For ${action}

| Additional Test Setup Action For namespace
| | [Documentation]
| | ... | Additional Setup for tests which uses namespace.
| | ...
| | :FOR | ${dut} | IN | @{duts}
| | | Clean Up Namespaces | ${nodes['${dut}']}

| Additional Test Setup Action For ligato
| | [Documentation]
| | ... | Additional Setup for tests which uses Ligato Kubernetes.
| | ...
| | Apply Kubernetes resource on all duts | ${nodes} | namespaces/csit.yaml
| | Apply Kubernetes resource on all duts | ${nodes} | pods/kafka.yaml
| | Apply Kubernetes resource on all duts | ${nodes} | pods/etcdv3.yaml
| | Apply Kubernetes resource on all duts | ${nodes}
| | ... | configmaps/vswitch-agent-cfg.yaml
| | Apply Kubernetes resource on all duts | ${nodes}
| | ... | configmaps/vnf-agent-cfg.yaml
| | Apply Kubernetes resource on all duts | ${nodes}
| | ... | pods/contiv-sfc-controller.yaml
| | Apply Kubernetes resource on all duts | ${nodes}
| | ... | pods/contiv-vswitch.yaml
