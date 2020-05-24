"""
This script reflects all content passing through the proxy.
"""
import xmlrpc.client

from mitmproxy import http

def QueryAgent(contents):
    proxy = xmlrpc.client.ServerProxy('http://localhost:10000')
    response = proxy.QueryAgent([contents.decode('utf-8')])
    return response[0].encode('utf-8')

def response(flow: http.HTTPFlow) -> None:
    flow.response.content = QueryAgent(flow.response.content)
