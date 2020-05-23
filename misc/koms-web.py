"""
This script reflects all content passing through the proxy.
"""
import xmlrpc.client
import xml.etree.ElementTree as ET
import xml.sax.saxutils as saxutils
import sys

from mitmproxy import http

def QueryAgent(agent, contents):
    proxy = xmlrpc.client.ServerProxy('http://agi.frdcsa.org:10000')
    query = "<message>\n  <id>1</id>\n  <sender>Test</sender>\n  <receiver>" + saxutils.escape(agent) + "</receiver>\n  <date>Fri Feb  3 02:14:29 CST 2017</date>\n  <contents>" + saxutils.escape(contents) + "</contents>\n  <data>" + "$VAR1 = {'_DoNotLog' => 1};" + "\n  </data>\n</message>"
    response = proxy.QueryAgent([query])
    root = ET.fromstring(response[0])
    for child in root:
    	if child.tag == "contents":
    		return saxutils.unescape(child.text)
    return contents;

def response(flow: http.HTTPFlow) -> None:
    sys.stderr.write("\n\nDOING IT\n")
    tmp = QueryAgent("Echo",repr(flow.response.content))
    sys.stderr.write("\n\nDONE\n\n\n")
    sys.stderr.write(tmp)
    flow.response.content = tmp
 
