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

"""Test variables for ACL-plugin test suite."""


def get_variables(test_case, name):
    """Create and return a dictionary of test variables for the specified
    test case.

    :param test_case: Determines which test variables to return.
    :param name: Name for the classify chain used in test.
    :type test_case: str
    :type name: str

    :returns: Dictionary of test variables - settings for Honeycomb's
    ietf-acl node and packet fields to use in verification.
    :rtype: dict
    :raises KeyError: If the test_case parameter is incorrect.
    """

    test_case = test_case.lower()
    variables = {
        # Variables for control packet
        "src_ip": "16.0.0.1",
        "dst_ip": "16.0.1.1",
        "src_net": "16.0.0.0",
        "dst_net": "16.0.1.0",
        "src_port": "1234",
        "dst_port": "1234",
        "src_mac": "01:02:03:04:05:06",
        "dst_mac": "10:20:30:40:50:60"}

    test_vars = {
        "macip": {
            # MACs classified directly
            "classify_src": "12:23:34:45:56:67",
            "classify_dst": "89:9A:AB:BC:CD:DE",
            # MACs classified through mask
            "classify_src2": "01:02:03:04:56:67",
            "classify_dst2": "89:9A:AB:BC:50:60",
            "src_mask": "00:00:00:00:FF:FF",
            "dst_mask": "FF:FF:FF:FF:00:00"
        },
        "l3_ip4": {
            # IPs for DUT interface setup
            "dut_to_tg_if1_ip": "16.0.0.2",
            "dut_to_tg_if2_ip": "192.168.0.2",
            "prefix_length": 24,
            "gateway": "192.168.0.1",
            # classified networks
            "classify_src_net": "16.0.2.0",
            "classify_dst_net": "16.0.3.0",
            # IPs in classified networks
            "classify_src": "16.0.2.1",
            "classify_dst": "16.0.3.1",
        },
        "l3_ip6": {
            # Override control packet addresses with IPv6
            "src_ip": "10::1",
            "dst_ip": "11::1",
            "dst_net": "11::",
            # IPs for DUT interface setup
            "dut_to_tg_if1_ip": "10::2",
            "dut_to_tg_if2_ip": "20::2",
            "prefix_length": 64,
            "gateway": "20::1",
            # classified networks
            "classify_src_net": "12::",
            "classify_dst_net": "13::",
            # IPs in classified networks
            "classify_src": "12::1",
            "classify_dst": "13::1",
        },
        "l4": {
            # IPs for DUT interface and route setup
            "dut_to_tg_if1_ip": "16.0.0.2",
            "dut_to_tg_if2_ip": "192.168.0.2",
            "prefix_length": 24,
            "gateway": "192.168.0.1",
            "classify_dst_net": "16.0.3.0",
            # Ports in classified ranges
            "classify_src": 60000,
            "classify_dst": 61000,
        },
        "mixed": {
            # IPs for DUT interface and route setup
            "dut_to_tg_if1_ip": "16.0.0.2",
            "dut_to_tg_if2_ip": "192.168.0.2",
            "prefix_length": 24,
            "gateway": "192.168.0.1",
            "classify_dst_net": "16.0.3.0",
            # IPs in classified networks
            "classify_src_ip": "16.0.2.1",
            "classify_dst_ip": "16.0.3.1",
            # Ports in classified ranges
            "classify_src_port": 60000,
            "classify_dst_port": 61000,
        },
        "icmp": {
            # ICMP code and type for control packet
            "icmp_type": 0,
            "icmp_code": 0,
            # classified ICMP code and type
            "classify_type": 3,
            "classify_code": 3

        },
        "icmpv6": {
            # Override control packet addresses with IPv6
            "src_ip": "10::1",
            "dst_ip": "11::1",
            "dst_net": "11::",
            # IPs for DUT interface setup
            "dut_to_tg_if1_ip": "10::2",
            "dut_to_tg_if2_ip": "20::2",
            "prefix_length": 64,
            "gateway": "20::1",
            # classified networks
            "classify_src_net": "12::",
            "classify_dst_net": "13::",
            # ICMP code and type for control packet
            "icmp_type": 1,
            "icmp_code": 0,
            # classified ICMP code and type
            "classify_type": 4,
            "classify_code": 2

        },
        "reflex": {
            # IPs for DUT interface setup
            "dut_to_tg_if1_ip": "16.0.0.2",
            "dut_to_tg_if2_ip": "192.168.0.2",
            "prefix_length": 24,
            "gateway": "192.168.0.1",
            "gateway2": "192.168.0.1",
            # classified networks
            "classify_src_net": "16.0.2.0",
            "classify_dst_net": "16.0.3.0",
            # IPs in classified networks
            "classify_src": "16.0.2.1",
            "classify_dst": "16.0.3.1",
        },
        "block_all": {}
    }
    acl_data = {
        # ACL configuration for L2 tests

        "macip": {
            "acl": [{
                "name": name,
                "type": "vpp-acl:vpp-macip-acl",
                "aces": {
                    "ace": [
                        {
                            "name": "rule1",
                            "matches": {

                                "eth": {
                                    "source-mac-address": test_vars["macip"]["classify_src"],
                                    "source-mac-address-mask": test_vars["macip"]["src_mask"]
                                },
                                "ipv4": {

                                    "source-ipv4-network": "16.0.0.0/24"
                                }
                            },

                            "actions": {
                                "forwarding": "ietf-access-control-list:drop"
                            }
                        },
                        {
                            "name": "rule_all",
                            "matches": {

                                "eth": {
                                    "source-mac-address": test_vars["macip"]["classify_src"],
                                    "source-mac-address-mask": "00:00:00:00:00:00"
                                },

                                "ipv4": {
                                    "source-ipv4-network": "0.0.0.0/0"
                                }
                            },
                            "actions": {
                                "forwarding": "ietf-access-control-list:accept"
                            }
                        }
                    ]}
                }
            ]
        },
        # ACL configuration for L3 IPv4 tests
        "l3_ip4": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule1",
                                "matches": {
                                    "ipv4": {
                                        "destination-ipv4-network": "{0}/{1}".format(
                                            test_vars["l3_ip4"]["classify_dst_net"],
                                            test_vars["l3_ip4"]["prefix_length"]),
                                        "source-ipv4-network": "{0}/{1}".format(
                                            test_vars["l3_ip4"]["classify_src_net"],
                                            test_vars["l3_ip4"]["prefix_length"])
                                    },
                                    "udp":{
                                        "source-port": {
                                            "lower-port": "0",
                                            "upper-port": "65535"
                                        },
                                        "destination-port": {
                                            "lower-port": "0",
                                            "upper-port": "65535"
                                        }
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            },
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv4": {
                                        "destination-ipv4-network": "0.0.0.0/0",
                                        "source-ipv4-network": "0.0.0.0/0"
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:accept"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        # ACL settings for L3 IPv6 tests
        "l3_ip6": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule1",
                                "matches": {
                                    "ipv6": {
                                        "destination-ipv6-network": "{0}/{1}".format(
                                            test_vars["l3_ip6"]["classify_dst_net"],
                                            test_vars["l3_ip6"]["prefix_length"]),
                                        "source-ipv6-network": "{0}/{1}".format(
                                            test_vars["l3_ip6"]["classify_src_net"],
                                            test_vars["l3_ip6"]["prefix_length"])
                                    },
                                    "udp":{
                                        "source-port": {
                                            "lower-port": "0",
                                            "upper-port": "65535"
                                        },
                                        "destination-port": {
                                            "lower-port": "0",
                                            "upper-port": "65535"
                                        }
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            },
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv6": {
                                        "destination-ipv6-network": "0::0/0",
                                        "source-ipv6-network": "0::0/0"
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:accept"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        # ACL configuration for L4 tests
        "l4": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule1",
                                "matches": {
                                    "ipv4": {
                                        "source-ipv4-network": "0.0.0.0/0"
                                    },
                                    "tcp": {
                                        "source-port": {
                                            "lower-port": test_vars["l4"]["classify_src"],
                                            "upper-port": test_vars["l4"]["classify_src"] + 10
                                        },
                                        "destination-port":{
                                            "lower-port": test_vars["l4"]["classify_dst"],
                                            "upper-port": test_vars["l4"]["classify_dst"] + 10
                                        }
                                    }
                                },
                                "actions":{
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            },
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv4": {
                                        "source-ipv4-network": "0.0.0.0/0",
                                        "destination-ipv4-network": "0.0.0.0/0"
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:accept"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        "mixed": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "ports",
                                "matches": {
                                    "ipv4": {
                                        "source-ipv4-network": "0.0.0.0/0"
                                    },
                                    "tcp": {
                                        "source-port": {
                                            "lower-port": test_vars["l4"]["classify_src"],
                                            "upper-port": test_vars["l4"]["classify_src"] + 10
                                        },
                                        "destination-port":{
                                            "lower-port": test_vars["l4"]["classify_dst"],
                                            "upper-port": test_vars["l4"]["classify_dst"] + 10
                                        }
                                    }
                                },
                                "actions":{
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            },
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv4": {
                                        "destination-ipv4-network": "0.0.0.0/0",
                                        "source-ipv4-network": "0.0.0.0/0"
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:accept"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        "icmp": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule1",
                                "matches": {
                                    "ipv4": {
                                        "source-ipv4-network": "0.0.0.0/0"
                                    },
                                    "icmp": {
                                        "vpp-acl:vpp-icmp-ace": {
                                            "vpp-acl:icmp-type-range": {
                                                "first": "1",
                                                "last": "5"
                                            },
                                            "vpp-acl:icmp-code-range": {
                                                "first": "1",
                                                "last": "5"
                                            }
                                        }
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            },
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv4": {
                                        "source-ipv4-network": "0.0.0.0/0",
                                        "destination-ipv4-network": "0.0.0.0/0"
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:accept"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        "icmpv6": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule1",
                                "matches": {
                                    "ipv6": {
                                        "source-ipv6-network": "::/0",
                                    },
                                    "icmp": {
                                        "vpp-acl:vpp-icmp-ace": {
                                            "vpp-acl:icmp-type-range": {
                                                "first": "1",
                                                "last": "5"
                                            },
                                            "vpp-acl:icmp-code-range": {
                                                "first": "1",
                                                "last": "5"
                                            }
                                        }
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            },
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv6": {
                                        "destination-ipv6-network": "0::0/0",
                                        "source-ipv6-network": "::/0",
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:accept"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        "reflex": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule1",
                                "matches": {
                                    "ipv4": {
                                        "destination-ipv4-network": "{0}/{1}".format(
                                            test_vars["reflex"]["classify_src_net"],
                                            test_vars["reflex"]["prefix_length"]),
                                        "source-ipv4-network": "{0}/{1}".format(
                                            test_vars["reflex"]["classify_dst_net"],
                                            test_vars["reflex"]["prefix_length"])
                                    }
                                },
                                "actions": {
                                    "forwarding": "vpp-acl:accept-and-reflect"
                                }
                            }
                        ]
                    }
                }
            ]
        },
        "block_all": {
            "acl": [
                {
                    "name": name,
                    "type": "vpp-acl:vpp-acl",
                    "aces": {
                        "ace": [
                            {
                                "name": "rule_all",
                                "matches": {
                                    "ipv4": {
                                        "destination-ipv4-network": "0.0.0.0/0",
                                        "source-ipv4-network": "0.0.0.0/0"
                                    }
                                },
                                "actions": {
                                    "forwarding": "ietf-access-control-list:drop"
                                }
                            }
                        ]
                    }
                }
            ]
        },
    }

    try:
        ret_vars = {}
        ret_vars.update(variables)
        ret_vars.update(test_vars[test_case])
        ret_vars.update(
            {"acl_settings": acl_data[test_case]}
        )
    except KeyError:
        raise KeyError(
            "Unrecognized test case {0}. Valid options are: {1}".format(
                test_case, acl_data.keys()))
    return ret_vars
