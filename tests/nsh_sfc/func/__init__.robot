# Copyright (c) 2017 Cisco and/or its affiliates.
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
| Resource | resources/libraries/robot/shared/interfaces.robot
| Library | resources.libraries.python.SFC.SetupSFCTest
| Suite Setup | Run Keywords | Setup NSH SFC test | ${nodes} | AND
| ... | Restart Vpp Service On All Duts | ${nodes} | AND
| ... | Verify Vpp On All Duts | ${nodes} | AND
| ... | VPP Enable Traces On All Duts | ${nodes} | AND
| ... | Update All Interface Data On All Nodes | ${nodes}
