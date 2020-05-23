"""
This script reflects all content passing through the proxy.
"""
from mitmproxy import http
import sys

def response(flow: http.HTTPFlow) -> None:
    tmp = flow.response.content.replace(b"FRDCSA", b"FINAL")
    sys.stderr.write(repr(tmp))
    flow.response.content = tmp
