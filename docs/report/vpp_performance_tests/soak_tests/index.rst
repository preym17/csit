
.. raw:: latex

    \clearpage

.. raw:: html

    <script type="text/javascript">

        function getDocHeight(doc) {
            doc = doc || document;
            var body = doc.body, html = doc.documentElement;
            var height = Math.max( body.scrollHeight, body.offsetHeight,
                html.clientHeight, html.scrollHeight, html.offsetHeight );
            return height;
        }

        function setIframeHeight(id) {
            var ifrm = document.getElementById(id);
            var doc = ifrm.contentDocument? ifrm.contentDocument:
                ifrm.contentWindow.document;
            ifrm.style.visibility = 'hidden';
            ifrm.style.height = "10px"; // reset to minimal height ...
            // IE opt. for bing/msn needs a bit added or scrollbar appears
            ifrm.style.height = getDocHeight( doc ) + 4 + "px";
            ifrm.style.visibility = 'visible';
        }

    </script>

.. _soak_tests:

Soak Tests
==========

Long duration (2 hours per test) soak tests are executed
using :ref:`plrsearch` algorithm. As the test take long time, only 10 test
were executed, two runs each.

Additional information about graph data:

#. **Graph Title**: describes type of tests and soak test duration.

#. **X-axis Labels**: indices of test suites.

#. **Y-axis Labels**: estimated lower bounds for critical rate value in [Mpps].

#. **Graph Legend**: list of X-axis indices with CSIT test suites.

#. **Hover Information**: in general lists minimum, first quartile, median,
   third quartile, and maximum. If either type of outlier is present the
   whisker on the appropriate side is taken to 1.5×IQR from the quartile
   (the "inner fence") rather than the max or min, and individual outlying
   data points are displayed as unfilled circles (for suspected outliers)
   or filled circles (for outliers). (The "outer fence" is 3×IQR from the
   quartile.)
   When number of samples is low, some values are not displayed.

.. note::

    Test results have been generated by
    `FD.io test executor vpp performance job 2n-skx`_ with RF
    result files csit-vpp-perf-|srelease|-\*.zip
    `archived here <../../_static/archive/>`_.

.. raw:: latex

    \clearpage

.. raw:: html

    <center>
    <iframe id="ifrm01" onload="setIframeHeight(this.id)" width="700" frameborder="0" scrolling="no" src="../../_static/vpp/soak-test-1.html"></iframe>
    <p><br></p>
    </center>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 0cm 5cm 0cm, width=0.70\textwidth]{soak-test-1}
            \label{fig:soak-test-1}
    \end{figure}

.. raw:: latex

    \clearpage

.. raw:: html

    <center>
    <iframe id="ifrm02" onload="setIframeHeight(this.id)" width="700" frameborder="0" scrolling="no" src="../../_static/vpp/soak-test-2.html"></iframe>
    <p><br></p>
    </center>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 0cm 5cm 0cm, width=0.70\textwidth]{soak-test-2}
            \label{fig:soak-test-2}
    \end{figure}
