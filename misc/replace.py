"""
This script reflects all content passing through the proxy.
"""
from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    flow.response.content = flow.response.content.replace(b"FRDCSA", b"FINAL")
