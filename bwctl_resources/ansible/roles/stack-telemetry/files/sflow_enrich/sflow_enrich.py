#!/usr/bin/env python3
"""
sFlow enrichment
~~~~~~~~~~~~~~~~

Fetch latest sFlow measurements from InfluxDB and enrich it with host names.

InfluxDB API documentation https://docs.influxdata.com/influxdb/v1.7/tools/api
"""
import sys
from datetime import datetime
from enum import Enum
from functools import reduce
from json.decoder import JSONDecodeError
from time import sleep
from typing import Tuple, Optional, Any, Dict, Union, List

import requests

INTERVAL: int = 20
INFLUXDB_READ_URL: str = "http://influxdb:8086/query"
INFLUXDB_WRITE_URL: str = "http://influxdb:8086/write"
INFLUXDB_DBNAME: str = "telegraf"
INFLUXDB_ORIGINAL_MEASUREMENT: str = "flow_ipv6"
INFLUXDB_CGA_MEASUREMENT: str = "flow_cga_value"
INFLUXDB_ENRICHED_MEASUREMENT: str = "flow_ipv6_enriched"
INFLUXDB_SFLOW_V6_PAYLOAD: dict = {
    "db": INFLUXDB_DBNAME,
    "q": 'SELECT * FROM "{}" WHERE "time" > now() - {}s'.format(
        INFLUXDB_ORIGINAL_MEASUREMENT, INTERVAL
    ),
}
# Debugging (prints any status information)
DEBUG: bool = False


class OperationStatus(Enum):
    """Operation status"""

    SUCCESS = 1
    FAILURE = 2


class Status:
    """Status with operation success indicator, informational message and optional return value"""

    def __init__(
            self,
            status: OperationStatus,
            message: Union[str, bytes, int],
            value: Optional[Any],
    ):
        self.status = status
        self.message = message
        self.value = value

    def as_string(self):
        """Class string representation"""
        return u'{}("status": {}, "message": "{}", "value": "{}")'.format(
            self.__class__.__name__,
            self.status,
            self.message,
            self.value.decode("utf-8") if isinstance(self.value, bytes) else self.value,
        )

    def __repr__(self):
        return self.as_string()

    def __str__(self):
        return self.as_string()


def fail(msg: str, status: int = 1) -> None:
    """Print message and exit with status code"""
    print(msg, flush=True)
    sys.exit(status)


def deep_get(dictionary: Dict, *keys: List) -> Optional[Any]:
    """Get values from nested dictionaries"""
    return reduce(
        lambda d, key: d.get(key, None) if isinstance(d, dict) else None,
        keys,
        dictionary,
    )


def expand_ipv6_address(hostname: str) -> str:
    """Expand IPv6 address to full representation"""
    return ":".join(e.zfill(4) for e in hostname.split(":"))


def influxdb_sflow_cga_hostname(hostname: str) -> Dict:
    """Return InfluxDB sFlow hostname retrieval query"""
    return {
        "db": INFLUXDB_DBNAME,
        "q": 'SELECT hostname FROM "{}" WHERE "cga" = \'{}\' ORDER BY DESC LIMIT 1'.format(
            INFLUXDB_CGA_MEASUREMENT, hostname
        ),
    }


def influxdb_sflow_cga_role(flow_label: int, hostname: str) -> Dict:
    """Return InfluxDB sFlow role retrieval query"""
    return {
        "db": INFLUXDB_DBNAME,
        "q": 'SELECT hostname FROM "{}" WHERE "cga" = \'{}:{}\' ORDER BY DESC LIMIT 1'.format(
            INFLUXDB_CGA_MEASUREMENT, flow_label, hostname
        ),
    }


def http_request(
        url: str,
        method: str = "GET",
        params: Optional[Union[Dict, Tuple, bytes]] = None,
        headers: Optional[Dict] = None,
        payload: Optional[Union[Dict, str]] = None,
) -> Status:
    """Make HTTP request, handle errors gracefully. Return Response object, exit if any failure."""
    if not url:
        raise ValueError("'url' should be set.")
    if not params:
        params = dict()
    method = method.lower()
    # Make HTTP request
    try:
        # Calling a function based on a string with the function's name
        if method in ["delete", "get"]:
            resp = getattr(requests, method)(url, params=params)
        elif method in ["post", "put", "patch"]:
            resp = getattr(requests, method)(url, data=payload, headers=headers)
        else:
            raise ValueError("http_request(): Unknown method {0!r}".format(method))
    except (
            requests.ConnectionError,
            requests.ConnectionError,
            requests.HTTPError,
            requests.URLRequired,
            requests.TooManyRedirects,
            requests.Timeout,
    ) as err:
        return Status(
            OperationStatus.FAILURE,
            "Caught exception while querying {0!r} with method {1!r}: {2!r}".format(
                url, method, err
            ),
            None,
        )
    # Return response
    try:
        ret_data = resp.json()
    except JSONDecodeError:
        ret_data = resp.text
    return Status(OperationStatus.SUCCESS, resp.status_code, ret_data)


def get_influx_result_first_value(status: Status) -> Status:
    """Get first result from InfluxDB returned result if it is successful"""
    if (
            status.status == OperationStatus.SUCCESS
            and status.message == 200
            and status.value
    ):
        try:
            sflow_v6_role = status.value["results"][0]["series"][0]["values"][0][1]
        except (IndexError, TypeError, ValueError, AttributeError, KeyError) as err:
            return Status(
                OperationStatus.FAILURE,
                "Cannot extract hostname - {} from: {}".format(err, status),
                None,
            )
        # Return
        return Status(OperationStatus.SUCCESS, "OK", sflow_v6_role)
    # If cannot extract, return failure and original status as string
    return Status(OperationStatus.FAILURE, "{}".format(status), None)


def get_sflow_hostname(ipv6_ip: str) -> Status:
    """Get hostname from sFlow CGA measurement"""
    # Query InfluxDB
    ret = http_request(
        INFLUXDB_READ_URL,
        params=influxdb_sflow_cga_hostname(expand_ipv6_address(ipv6_ip)),
    )
    return get_influx_result_first_value(ret)


def get_sflow_role(flow_label_hex: str, ipv6_ip: str) -> Status:
    """Get role name from sFlow CGA measurement based on 'flow_label:ipv6_ip'"""
    # Query InfluxDB
    ret = http_request(
        INFLUXDB_READ_URL,
        params=influxdb_sflow_cga_role(
            int(flow_label_hex, 16), expand_ipv6_address(ipv6_ip)
        ),
    )
    return get_influx_result_first_value(ret)


def main() -> None:
    """Enrich InfluxDB measurements"""
    # Get sFlow data for the period
    print("Query InfluxDB")
    # Query InfluxDB
    influx_response = http_request(INFLUXDB_READ_URL, params=INFLUXDB_SFLOW_V6_PAYLOAD)
    if (
            influx_response.status == OperationStatus.SUCCESS
            and influx_response.message == 200
            and influx_response.value
    ):
        # TODO: Refactor this!
        # Get measurements
        if DEBUG:
            print(
                "InfluxDB response={}".format(influx_response),
                flush=True,
            )
        sflow_measurements = influx_response.value["results"][0]
        sflow_measurements_series = sflow_measurements.get("series", dict())
        for row in sflow_measurements_series:
            # Get measurement names
            sflow_columns = row["columns"]
            print("sFlow columns={!r}".format(sflow_columns), flush=True)
            # Get measurement list
            sflow_values = row["values"]
            # Successful operations list
            for idx, sflow_value in enumerate(sflow_values):
                success_list: List = list()
                print("row={}, values={}".format(idx, sflow_value), flush=True)
                # Destination hostname (tag: destination (1))
                sflow_v6_destination_hostname = get_sflow_hostname(sflow_value[1])
                success_list.append(sflow_v6_destination_hostname.status)
                if DEBUG:
                    print(
                        "sflow_v6_destination_hostname={}".format(sflow_v6_destination_hostname),
                        flush=True,
                    )
                # Source hostname (tag: source (6))
                sflow_v6_source_hostname = get_sflow_hostname(sflow_value[6])
                success_list.append(sflow_v6_source_hostname.status)
                if DEBUG:
                    print(
                        "sflow_v6_source_hostname={}".format(sflow_v6_source_hostname),
                        flush=True,
                    )
                # Role (tags: ip6flowlabel (4), source (6))
                sflow_v6_source_role = get_sflow_role(sflow_value[4], sflow_value[6])
                success_list.append(sflow_v6_source_role.status)
                if DEBUG:
                    print(
                        "sflow_v6_source_role={}".format(sflow_v6_source_role),
                        flush=True,
                    )
                if all(x == OperationStatus.SUCCESS for x in success_list):
                    # Generate enriched data
                    # TODO: Especially refactor this!
                    enriched_v6_data = \
                        "{},{}={},{}={},{}={},{}={},{}={},{}={},{}={},{}={},{}={},{}={} {}={}".format(
                            INFLUXDB_ENRICHED_MEASUREMENT,
                            sflow_columns[1], sflow_value[1],
                            "source_hostname", sflow_v6_source_hostname.value,
                            "source_role", sflow_v6_source_role.value,
                            "destination_hostname", sflow_v6_destination_hostname.value,
                            sflow_columns[2], sflow_value[2],
                            sflow_columns[3], sflow_value[3],
                            sflow_columns[4], sflow_value[4],
                            sflow_columns[5], sflow_value[5],
                            sflow_columns[6], sflow_value[6],
                            sflow_columns[7], sflow_value[7],
                            sflow_columns[8], sflow_value[8],
                        )
                    print(
                        "time={} Posting enriched data={}".format(datetime.now(), enriched_v6_data),
                        flush=True,
                    )
                    # Post enriched data to InfluxDB
                    ret = http_request(
                        "{}?db={}".format(INFLUXDB_WRITE_URL, INFLUXDB_DBNAME),
                        method="POST",
                        payload=enriched_v6_data,
                    )
                    if ret.status != OperationStatus.SUCCESS or ret.message != 204:
                        print(
                            "Failed to post enriched data to InfluxDB: {}".format(ret),
                            flush=True,
                        )
                else:
                    print(
                        "Missing defined value(s). sflow_v6_destination_hostname={}, "
                        "sflow_v6_source_hostname={}, sflow_v6_source_role={}".format(
                            sflow_v6_destination_hostname,
                            sflow_v6_source_hostname,
                            sflow_v6_source_role,
                        ),
                        flush=True,
                    )
    else:
        print(
            "Got error from InfluxDB: {}".format(influx_response),
            flush=True,
        )

    print(
        "Sleeping...",
        flush=True,
    )
    sleep(INTERVAL)


if __name__ == "__main__":
    while True:
        # Run forever
        main()

# EOF
