#!/usr/bin/env python3
"""
sFlow Agent
~~~~~~~~~

Consume and transform sflow samples to InfluxDB measurements.

Based on parsing 'ovs-dpctl dump-flows' command
"""
import re
import socket
import subprocess
import sys
import threading
from datetime import datetime
from typing import Iterator, Union, List, Dict

# Unix socket for the Telegraf process
TELEGRAF_UNIX_SOCKET: str = "/tmp/telegraf.sock"
# How ofter do we run external process
SPAWN_TIMER: int = 10
# How long do we wait for the process to finish
TERM_TIMER: int = 8
# InfluxDB measurement name
INFLUXDB_MEASUREMENT: str = "flow_ipv6"
# OVS dpctl binary location
OVS_DPCTL_CMD: List[str] = [
    "ovs-dpctl",
    "dump-flows"
]


def fail(msg: str, status: int = 1) -> None:
    """Print message and exit with status code"""
    print(msg, flush=True)
    sys.exit(status)


def parse_sflow_sample_element(element: str) -> List[str]:
    """Parse sflow element"""
    protocols: Dict = {
        "6": "tcp",
        "17": "udp"
    }
    re_pattern = re.compile(
        "^.*ipv6\\(src=(?P<src>[\\da-f:]+),dst=(?P<dst>[\\da-f:]+),label=(?P<label>0x[\\da-f]+)"
        ",proto=(?P<proto>\\d+).*\\), packets:(?P<packets>\\d+), bytes:(?P<bytes>\\d+),.*$",
        re.I
    )

    ret: List[str] = list()
    for elem in re_pattern.finditer(element):
        elem_upper = {k: v.upper() for k, v in elem.groupdict().items()}
        proto = protocols[elem_upper['proto']]
        ret.append(
            "{},proto={},src={},dst={},label={},src_port={},dst_port={} value={}".format(
                INFLUXDB_MEASUREMENT,
                proto, elem_upper['src'], elem_upper['dst'],
                elem_upper['label'], 0, 0, elem_upper['bytes'],  # 'src_port' and 'dst_port' are temporary not available
            )
        )

    if not ret:
        print("Nothing to return, is this a bug? (element={})".format(element))
    return ret


def parse_sflow_record(sock: socket.socket) -> None:
    """
    Parse sflow from external process, transform to InfluxDB measurement and send it to socket
    """
    threading.Timer(SPAWN_TIMER, parse_sflow_record, args=[sock]).start()
    print('--- {}'.format(datetime.now()))
    # Run sflowtool with JSON output, pipe output to 'lines' iterator
    lines: Iterator[Union[bytes]] = iter(())
    try:
        lines = subprocess.check_output(OVS_DPCTL_CMD, stderr=subprocess.STDOUT, timeout=TERM_TIMER).splitlines()
    except subprocess.SubprocessError as err:
        fail("Cannot run {}, error={}".format(OVS_DPCTL_CMD, err), 126)

    for line in lines:
        ln = line.decode("utf-8")
        if any(x in ln for x in ['proto=6', 'proto=17']):
            for measurement in parse_sflow_sample_element(ln):
                print(measurement)
                try:
                    sock.send(measurement.encode("utf-8"))
                except OSError as err:
                    fail("Error sending to socket {}".format(err))


def main() -> None:
    """Main function, start the ball"""
    # Connection to Telegraf, over a Unix socket
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        sock.connect(TELEGRAF_UNIX_SOCKET)
        parse_sflow_record(sock)
    except OSError as err:
        fail("Error connecting to socket {}".format(err))


if __name__ == "__main__":
    main()

# vim: set fileencoding=utf-8 ts=8 et sw=4 sts=4 :
# EOF
