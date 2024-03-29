#!/bin/bash
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

set -x

cat /etc/hostname
cat /etc/hosts

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH=${SCRIPT_DIR}

OS_ID=$(grep '^ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
OS_VERSION_ID=$(grep '^VERSION_ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')

if [ "$OS_ID" == "centos" ]; then
    DISTRO="CENTOS"
    PACKAGE="rpm"
    sudo yum install -y python-devel python-virtualenv
elif [ "$OS_ID" == "ubuntu" ]; then
    DISTRO="UBUNTU"
    PACKAGE="deb"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y update
    sudo apt-get -y install libpython2.7-dev python-virtualenv
else
    echo "$OS_ID is not yet supported."
    exit 1
fi

# Temporarily download VPP and DPDK packages from nexus.fd.io
if [ "${#}" -ne "0" ]; then
    arr=(${@})
    echo ${arr[0]}
    SKIP_PATCH="skip_patchORskip_vpp_patch"
else
    VPP_VERSION=$(< ${SCRIPT_DIR}/VPP_STABLE_VER_${DISTRO})
    CSIT_DIR=${SCRIPT_DIR}
    source "${SCRIPT_DIR}/resources/libraries/bash/function/artifacts.sh"
    download_artifacts
    # Need to revert -euo as the rest of script is not optimized for this.
    set +euo pipefail
fi

VIRL_DIR_LOC="/tmp/"
VPP_PKGS=(*vpp*.$PACKAGE)
VPP_PKGS_FULL=("${VPP_PKGS[@]/#/${VIRL_DIR_LOC}}")
echo ${VPP_PKGS[@]}

VIRL_TOPOLOGY=$(cat ${SCRIPT_DIR}/VIRL_TOPOLOGY_${DISTRO})
VIRL_RELEASE=$(cat ${SCRIPT_DIR}/VIRL_RELEASE_${DISTRO})
VIRL_SERVERS=("10.30.51.28" "10.30.51.29" "10.30.51.30")
IPS_PER_VIRL=( "10.30.51.28:252"
               "10.30.51.29:252"
               "10.30.51.30:252" )
SIMS_PER_VIRL=( "10.30.51.28:13"
               "10.30.51.29:13"
               "10.30.51.30:13" )
IPS_PER_SIMULATION=5

function get_max_ip_nr() {
    virl_server=$1
    IP_VALUE="0"
    for item in "${IPS_PER_VIRL[@]}" ; do
        if [ "${item%%:*}" == "${virl_server}" ]
        then
            IP_VALUE=${item#*:}
            break
        fi
    done
    echo "$IP_VALUE"
}

function get_max_sim_nr() {
    virl_server=$1
    SIM_VALUE="0"
    for item in "${SIMS_PER_VIRL[@]}" ; do
        if [ "${item%%:*}" == "${virl_server}" ]
        then
            SIM_VALUE=${item#*:}
            break
        fi
    done
    echo "$SIM_VALUE"
}

VIRL_USERNAME=jenkins-in
VIRL_PKEY=priv_key
VIRL_SERVER_STATUS_FILE="status"
VIRL_SERVER_EXPECTED_STATUS="PRODUCTION"

SSH_OPTIONS="-i ${VIRL_PKEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes -o LogLevel=error"

TEST_GROUPS=("ip6,ip4_tunnels,l2bd" "ip4,ip6_tunnels,l2xc")
SUITE_PATH="tests.vpp.func"
SKIP_PATCH="SKIP_PATCH"

# Create tmp dir
mkdir ${SCRIPT_DIR}/tmp

# Use tmp dir to store log files
LOG_PATH="${SCRIPT_DIR}/tmp"

# Use tmp dir for tarballs
export TMPDIR="${SCRIPT_DIR}/tmp"

function ssh_do() {
    echo
    echo "### "  ssh $@
    ssh ${SSH_OPTIONS} $@
}

rm -f ${VIRL_PKEY}
cat > ${VIRL_PKEY} <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA+IHXq87GcqMR1C47rzx6Cbip5Ghq8pKrbqKrP5Nf41HcYrT6
GOXl9nFWKsMOzIlIn+8y7Il27eZh7csQGApbg8QLiHMtcYEmWNzKZpkqg4nuAPxX
VXwlKgnKX902SrET9Gp9TDayiHtCRWVfrlPPPSA0UEXW6BjLN/uHJ+W/Xzrrab+9
asBVa05vT2W6n0KJ66zfCaeDM912mQ6SttscAwFoWDmdHlegiVqrlIG2ABxOvxxz
L3dM3iSmlmQlzv9bThjo+nI4KFYh6m5wrZmAo5r/4q9CIJc21HVnTqkGOWJIZz6J
73lePJVSq5gYqaoGw3swFEA/MDkOx7baWKSoLQIDAQABAoIBAQCNBeolNp+JWJ76
gQ4fwLsknyXSV6sxYyhkDW4PEwwcTU06uqce0AAzXVffxne0fMe48x47+zqBgPbb
4huM+Pu8B9nfojUMr5TaYtl9Zbgpk3F8H7dT7LKOa6XrxvZTZrADSRc30+Z26zPN
e9zTaf42Gvt0/l0Zs1BHwbaOXqO+XuwJ3/F9Sf3PQYWXD3EOWjpHDP/X/1vAs6lV
SLkm6J/9KKE1m6I6LTYjIXuYt4SXybW6N2TSy54hhQtYcDUnIU2hR/PHVWKrGA0J
kELgrtTNTdbML27O5gFWU4PLUEYTZ9fN11D6qUZKxLcPOiPPHXkiILMRCCnG5DYI
ksBAU/YlAoGBAPxZO9VO18TYc8THV1nLKcvT2+1oSs1UcA2wNQMU55t910ZYinRa
MRwUhMOf8Mv5wOeiZaRICQB1PnVWtDVmGECgPpK6jUxqAwn8rgJcnoafLGL5YKMY
RVafTe6N5LXgCaOcJrk21wxs6v7ninEbUxxc575urOvZMBkymDw91dwbAoGBAPwa
YRhKhrzFKZzdK0RadVjnxKvolUllpoqqg3XuvmeAJHAOAnaOgVWq68NAcp5FZJv0
2D2Up7TX8pjf9MofP1SJbcraKBpK4NzfNkA0dSdEi+FhVofAJ9umB2o5LW1n7sab
UIrjsdzSJK/9Zb9yTTHPyibYzNEgaJV1HsbxfEFXAoGAYO2RmvRm0phll18OQVJV
IpKk9kLKAKZ/R/K32hAsikBC8SVPQTPniyaifFWx81diblalff2hX4ipTf7Yx24I
wMIMZuW7Im/R7QMef4+94G3Bad7p7JuE/qnAEHJ2OBnu+eYfxaK35XDsrq6XMazS
NqHE7hOq3giVfgg+C12hCKMCgYEAtu9dbYcG5owbehxzfRI2/OCRsjz/t1bv1seM
xVMND4XI6xb/apBWAZgZpIFrqrWoIBM3ptfsKipZe91ngBPUnL9s0Dolx452RVAj
yctHB8uRxWYgqDkjsxtzXf1HnZBBkBS8CUzYj+hdfuddoeKLaY3invXLCiV+PpXS
U4KAK9kCgYEAtSv0m5+Fg74BbAiFB6kCh11FYkW94YI6B/E2D/uVTD5dJhyEUFgZ
cWsudXjMki8734WSpMBqBp/J8wG3C9ZS6IpQD+U7UXA+roB7Qr+j4TqtWfM+87Rh
maOpG56uAyR0w5Z9BhwzA3VakibVk9KwDgZ29WtKFzuATLFnOtCS46E=
-----END RSA PRIVATE KEY-----
EOF
chmod 600 ${VIRL_PKEY}

#
# The server must be reachable and have a "status" file with
# the content "PRODUCTION" to be selected.
#
# If the server is not reachable or does not have the correct
# status remove it from the array and start again.
#
# Abort if there are no more servers left in the array.
#
VIRL_PROD_SERVERS=()
for index in "${!VIRL_SERVERS[@]}"; do
    virl_server_status=$(ssh ${SSH_OPTIONS} ${VIRL_USERNAME}@${VIRL_SERVERS[$index]} cat $VIRL_SERVER_STATUS_FILE 2>&1)
    echo VIRL HOST ${VIRL_SERVERS[$index]} status is \"$virl_server_status\"
    if [ "$virl_server_status" == "$VIRL_SERVER_EXPECTED_STATUS" ]
    then
        # Candidate is in good status. Add to array.
        VIRL_PROD_SERVERS+=(${VIRL_SERVERS[$index]})
    fi
done

VIRL_SERVERS=("${VIRL_PROD_SERVERS[@]}")
echo "VIRL servers in production: ${VIRL_SERVERS[@]}"
num_hosts=${#VIRL_SERVERS[@]}
if [ $num_hosts == 0 ]
then
    echo "No more VIRL candidate hosts available, failing."
    exit 127
fi

# Get the LOAD of each server based on number of active simulations (testcases)
VIRL_SERVER_LOAD=()
for index in "${!VIRL_SERVERS[@]}"; do
    VIRL_SERVER_LOAD[${index}]=$(ssh ${SSH_OPTIONS} ${VIRL_USERNAME}@${VIRL_SERVERS[$index]} "list-testcases | grep session | wc -l")
done

# Pick for each TEST_GROUP least loaded server
VIRL_SERVER=()
for index in "${!TEST_GROUPS[@]}"; do
    least_load_server_idx=$(echo "${VIRL_SERVER_LOAD[*]}" | tr -s ' ' '\n' | awk '{print($0" "NR)}' | sort -g -k1,1 | head -1 | cut -f2 -d' ')
    least_load_server=${VIRL_SERVERS[$least_load_server_idx-1]}
    VIRL_SERVER+=($least_load_server)
    # Adjusting load as we are not going run simulation immediately
    VIRL_SERVER_LOAD[$least_load_server_idx-1]=$((VIRL_SERVER_LOAD[$least_load_server_idx-1]+1))
done

echo "Selected VIRL servers: ${VIRL_SERVER[@]}"

cat ${VIRL_PKEY}

# Copy the files to VIRL hosts
DONE=""
for index in "${!VIRL_SERVER[@]}"; do
    # Do not copy files in case they have already been copied to the VIRL host
    [[ "${DONE[@]}" =~ "${VIRL_SERVER[${index}]}" ]] && copy=0 || copy=1

    if [ "${copy}" -eq "0" ]; then
        echo "VPP packages have already been copied to the VIRL host ${VIRL_SERVER[${index}]}"
    else
        scp ${SSH_OPTIONS} ${VPP_PKGS[@]} \
        ${VIRL_USERNAME}@${VIRL_SERVER[${index}]}:${VIRL_DIR_LOC}

        result=$?
        if [ "${result}" -ne "0" ]; then
            echo "Failed to copy VPP packages to VIRL host ${VIRL_SERVER[${index}]}"
            echo ${result}
            exit ${result}
        else
            echo "VPP packages successfully copied to the VIRL host ${VIRL_SERVER[${index}]}"
        fi
        DONE+=(${VIRL_SERVER[${index}]})
    fi
done

# Start a simulation on VIRL server

function stop_virl_simulation {
    for index in "${!VIRL_SERVER[@]}"; do
        ssh ${SSH_OPTIONS} ${VIRL_USERNAME}@${VIRL_SERVER[${index}]}\
            "stop-testcase ${VIRL_SID[${index}]}"
    done
}

# Upon script exit, cleanup the simulation execution
trap stop_virl_simulation EXIT

for index in "${!VIRL_SERVER[@]}"; do
    echo "Starting simulation nr. ${index} on VIRL server ${VIRL_SERVER[${index}]}"
    # Get given VIRL server limits for max. number of VMs and IPs
    max_ips=$(get_max_ip_nr ${VIRL_SERVER[${index}]})
    max_ips_from_sims=$(($(get_max_sim_nr ${VIRL_SERVER[${index}]})*IPS_PER_SIMULATION))
    # Set quota to lower value
    IP_QUOTA=$([ $max_ips -le $max_ips_from_sims ] && echo "$max_ips" || echo "$max_ips_from_sims")
    # Start the simulation
    VIRL_SID[${index}]=$(ssh ${SSH_OPTIONS} ${VIRL_USERNAME}@${VIRL_SERVER[${index}]} \
        "start-testcase -vv \
            --quota ${IP_QUOTA} \
            --copy ${VIRL_TOPOLOGY} \
            --expiry 180 \
            --release ${VIRL_RELEASE} \
            ${VPP_PKGS_FULL[@]}")
        # TODO: remove param ${VPP_PKGS_FULL[@]} when start-testcase script is
        # updated on all virl servers
    retval=$?
    if [ ${retval} -ne "0" ]; then
        echo "VIRL simulation start failed on ${VIRL_SERVER[${index}]}"
        exit ${retval}
    fi
    if [[ ! "${VIRL_SID[${index}]}" =~ session-[a-zA-Z0-9_]{6} ]]; then
        echo "No VIRL session ID reported."
        exit 127
    fi
    echo "VIRL simulation nr. ${index} started on ${VIRL_SERVER[${index}]}"

    ssh_do ${VIRL_USERNAME}@${VIRL_SERVER[${index}]}\
     cat /scratch/${VIRL_SID[${index}]}/topology.yaml

    # Download the topology file from VIRL session and rename it
    scp ${SSH_OPTIONS} \
        ${VIRL_USERNAME}@${VIRL_SERVER[${index}]}:/scratch/${VIRL_SID[${index}]}/topology.yaml \
        topologies/enabled/topology${index}.yaml

    retval=$?
    if [ ${retval} -ne "0" ]; then
        echo "Failed to copy topology file from VIRL simulation nr. ${index} on VIRL server ${VIRL_SERVER[${index}]}"
        exit ${retval}
    fi
done

echo ${VIRL_SID[@]}

virtualenv --system-site-packages env
. env/bin/activate

echo pip install
pip install -r ${SCRIPT_DIR}/requirements.txt

for index in "${!VIRL_SERVER[@]}"; do
    pykwalify -s ${SCRIPT_DIR}/resources/topology_schemas/3_node_topology.sch.yaml \
              -s ${SCRIPT_DIR}/resources/topology_schemas/topology.sch.yaml \
              -d ${SCRIPT_DIR}/topologies/enabled/topology${index}.yaml \
              -vvv
    if [ "$?" -ne "0" ]; then
        echo "Topology${index} schema validation failed."
        echo "However, the tests will start."
    fi
done

function run_test_set() {
    set +x
    OLDIFS=$IFS
    IFS=","
    nr=$(echo $1)
    rm -f ${LOG_PATH}/test_run${nr}.log
    exec &> >(while read line; do echo "$(date +'%H:%M:%S') $line" \
     >> ${LOG_PATH}/test_run${nr}.log; done;)
    suite_str=""
    for suite in ${TEST_GROUPS[${nr}]}; do
        suite_str="${suite_str} --suite ${SUITE_PATH}.${suite}"
    done
    IFS=$OLDIFS

    echo "PYTHONPATH=`pwd` pybot -L TRACE -W 136\
        -v TOPOLOGY_PATH:${SCRIPT_DIR}/topologies/enabled/topology${nr}.yaml \
        ${suite_str} \
        --include vm_envAND3_node_single_link_topo \
        --include vm_envAND3_node_double_link_topo \
        --exclude PERFTEST \
        --exclude SOFTWIRE \
        --exclude ${SKIP_PATCH} \
        --exclude SKIP_TEST \
        --noncritical EXPECTED_FAILING \
        --output ${LOG_PATH}/log_test_set_run${nr} \
        tests/"

    PYTHONPATH=`pwd` pybot -L TRACE -W 136\
        -v TOPOLOGY_PATH:${SCRIPT_DIR}/topologies/enabled/topology${nr}.yaml \
        ${suite_str} \
        --include vm_envAND3_node_single_link_topo \
        --include vm_envAND3_node_double_link_topo \
        --exclude PERFTEST \
        --exclude SOFTWIRE \
        --exclude ${SKIP_PATCH} \
        --exclude SKIP_TEST \
        --noncritical EXPECTED_FAILING \
        --output ${LOG_PATH}/log_test_set_run${nr} \
        tests/

    local local_run_rc=$?
    set -x
    echo ${local_run_rc} > ${LOG_PATH}/rc_test_run${nr}
}

set +x
# Send to background an instance of the run_test_set() function for each number,
# record the pid.
for index in "${!VIRL_SERVER[@]}"; do
    run_test_set ${index} &
    pid=$!
    echo "Sent to background: Test_set${index} (pid=$pid)"
    pids[$pid]=$index
done

echo
echo -n "Waiting..."

# Watch the stable of background processes.
# If a pid goes away, remove it from the array.
while [ -n "${pids[*]}" ]; do
    for i in $(seq 0 9); do
        sleep 1
        echo -n "."
    done
    for pid in "${!pids[@]}"; do
        if ! ps "$pid" >/dev/null; then
            echo -e "\n"
            echo "Test_set${pids[$pid]} with PID $pid finished."
            unset pids[$pid]
        fi
    done
    if [ -z "${!pids[*]}" ]; then
        break
    fi
    echo -n -e "\nStill waiting for test set(s): ${pids[*]} ..."
done

echo
echo "All test set runs finished."
echo

set -x

RC=0
for index in "${!VIRL_SERVER[@]}"; do
    echo "Test_set${index} log:"
    cat ${LOG_PATH}/test_run${index}.log
    RC_PARTIAL_RUN=$(cat ${LOG_PATH}/rc_test_run${index})
    if [ -z "$RC_PARTIAL_RUN" ]; then
        echo "Failed to retrieve return code from test run ${index}"
        exit 1
    fi
    RC=$((RC+RC_PARTIAL_RUN))
    rm -f ${LOG_PATH}/rc_test_run${index}
    rm -f ${LOG_PATH}/test_run${index}.log
    echo
done

# Log the final result
if [ "${RC}" -eq "0" ]; then
    set +x
    echo
    echo "========================================================================================================================================"
    echo "Final result of all test loops:                                                                                                 | PASS |"
    echo "All critical tests have passed."
    echo "========================================================================================================================================"
    echo
    set -x
else
    if [ "${RC}" -eq "1" ]; then
        HLP_STR="test has"
    else
        HLP_STR="tests have"
    fi
    set +x
    echo
    echo "========================================================================================================================================"
    echo "Final result of all test loops:                                                                                                 | FAIL |"
    echo "${RC} critical ${HLP_STR} failed."
    echo "========================================================================================================================================"
    echo
    set -x
fi

echo Post-processing test data...

partial_logs=""
for index in "${!VIRL_SERVER[@]}"; do
    partial_logs="${partial_logs} ${LOG_PATH}/log_test_set_run${index}.xml"
done

# Rebot output post-processing
rebot --noncritical EXPECTED_FAILING \
      --output output.xml ${partial_logs}

# Remove unnecessary log files
rm -f ${partial_logs}

echo Post-processing finished.

if [ ${RC} -eq 0 ]; then
    RETURN_STATUS=0
else
    RETURN_STATUS=1
fi

exit ${RETURN_STATUS}
