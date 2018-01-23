IPv4 Routed-Forwarding
======================

Following sections include Throughput Speedup Analysis for VPP multi-
core multi-thread configurations with no Hyper-Threading, specifically
for tested 2t2c (2threads, 2cores) and 4t4c scenarios. 1t1c throughput
results are used as a reference for reported speedup ratio. Input data
used for the graphs comes from Phy-to-Phy 64B performance tests with VPP
IPv4 Routed-Forwarding, including NDR throughput (zero packet loss) and
PDR throughput (<0.5% packet loss).

NDR Throughput
--------------

VPP NDR 64B packet throughput speedup ratio is presented in the graphs
below for 10ge2p1x520 and 40ge2p1xl710 network interface cards.

NIC 10ge2p1x520
~~~~~~~~~~~~~~~

.. raw:: html

    <iframe width="700" height="1000" frameborder="0" scrolling="no" src="../../_static/vpp/10ge2p1x520-64B-ip4-tsa-ndrdisc.html"></iframe>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 8cm 5cm 0cm, width=0.70\textwidth]{10ge2p1x520-64B-ip4-tsa-ndrdisc}
            \label{fig:10ge2p1x520-64B-ip4-tsa-ndrdisc}
    \end{figure}

CSIT source code for the test cases used for above plots can be found in CSIT
git repository:

.. only:: html

   .. program-output:: cd ../../../../../ && set +x && cd tests/vpp/perf/ip4 && grep -E '64B-(1t1c|2t2c|4t4c)-ethip4-ip4(base|scale[a-z0-9]*)*-ndrdisc' 10ge2p1x520*
      :shell:

.. only:: latex

   .. code-block:: bash

      $ cd tests/vpp/perf/ip4
      $ grep -E '64B-(1t1c|2t2c|4t4c)-ethip4-ip4(base|scale[a-z0-9]*)*-ndrdisc' 10ge2p1x520*

*Figure 1. Throughput Speedup Analysis - Multi-Core Speedup Ratio - Normalized
NDR Throughput for Phy-to-Phy IPv4 Routed-Forwarding.*

NIC 40ge2p1xl710
~~~~~~~~~~~~~~~~

.. raw:: html

    <iframe width="700" height="1000" frameborder="0" scrolling="no" src="../../_static/vpp/40ge2p1xl710-64B-ip4-tsa-ndrdisc.html"></iframe>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 8cm 5cm 0cm, width=0.70\textwidth]{40ge2p1xl710-64B-ip4-tsa-ndrdisc}
            \label{fig:40ge2p1xl710-64B-ip4-tsa-ndrdisc}
    \end{figure}

CSIT source code for the test cases used for above plots can be found in CSIT
git repository:

.. only:: html

   .. program-output:: cd ../../../../../ && set +x && cd tests/vpp/perf/ip4 && grep -P '64B-(1t1c|2t2c|4t4c)-ethip4-ip4(base|scale[a-z0-9]*)*-ndrdisc' 40ge2p1xl710*
      :shell:

.. only:: latex

   .. code-block:: bash

      $ cd tests/vpp/perf/ip4
      $ grep -P '64B-(1t1c|2t2c|4t4c)-ethip4-ip4(base|scale[a-z0-9]*)*-ndrdisc' 40ge2p1xl710*

*Figure 2. Throughput Speedup Analysis - Multi-Core Speedup Ratio - Normalized
NDR Throughput for Phy-to-Phy IPv4 Routed-Forwarding.*

PDR Throughput
--------------

VPP PDR 64B packet throughput speedup ratio is presented in the graphs
below for 10ge2p1x520 and 40ge2p1xl710 network interface cards. PDR
measured for 0.5% packet loss ratio.

NIC 10ge2p1x520
~~~~~~~~~~~~~~~

.. raw:: html

    <iframe width="700" height="1000" frameborder="0" scrolling="no" src="../../_static/vpp/10ge2p1x520-64B-ip4-tsa-pdrdisc.html"></iframe>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 8cm 5cm 0cm, width=0.70\textwidth]{10ge2p1x520-64B-ip4-tsa-pdrdisc}
            \label{fig:10ge2p1x520-64B-ip4-tsa-pdrdisc}
    \end{figure}

CSIT source code for the test cases used for above plots can be found in CSIT
git repository:

.. only:: html

   .. program-output:: cd ../../../../../ && set +x && cd tests/vpp/perf/ip4 && grep -E '64B-(1t1c|2t2c|4t4c)-ethip4-ip4(base|scale[a-z0-9]*)*-ndrdisc' 10ge2p1x520*
      :shell:

.. only:: latex

   .. code-block:: bash

      $ cd tests/vpp/perf/ip4
      $ grep -E '64B-(1t1c|2t2c|4t4c)-ethip4-ip4(base|scale[a-z0-9]*)*-ndrdisc' 10ge2p1x520*

*Figure 3. Throughput Speedup Analysis - Multi-Core Speedup Ratio - Normalized
PDR Throughput for Phy-to-Phy IPv4 Routed-Forwarding.*