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

"""Packet trace library."""

from resources.libraries.python.PapiExecutor import PapiExecutor
from resources.libraries.python.topology import NodeType


class Trace(object):
    """This class provides methods to manipulate the VPP packet trace."""

    @staticmethod
    def show_packet_trace_on_all_duts(nodes, maximum=None):
        """Show VPP packet trace.

        :param nodes: Nodes from which the packet trace will be displayed.
        :param maximum: Maximum number of packet traces to be displayed.
        :type nodes: dict
        :type maximum: int
        """
        maximum = "max {count}".format(count=maximum) if maximum is not None\
            else ""

        for node in nodes.values():
            if node['type'] == NodeType.DUT:
                PapiExecutor.run_cli_cmd(node, cmd="show trace {max}".
                                         format(max=maximum))

    @staticmethod
    def clear_packet_trace_on_all_duts(nodes):
        """Clear VPP packet trace.

        :param nodes: Nodes where the packet trace will be cleared.
        :type nodes: dict
        """
        for node in nodes.values():
            if node['type'] == NodeType.DUT:
                PapiExecutor.run_cli_cmd(node, cmd="clear trace")
