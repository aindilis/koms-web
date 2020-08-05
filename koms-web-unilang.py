"""
This script reflects all content passing through the proxy.
"""
import xmlrpc.client
import xml.etree.ElementTree as ET
import xml.sax.saxutils as saxutils
import sys
import re
import json

from mitmproxy import http

def QueryAgent(agent, contents):
    proxy = xmlrpc.client.ServerProxy('http://ai2.frdcsa.org:10000')
    query = "<message>\n  <id>1</id>\n  <sender>WS-Server-XMLRPC</sender>\n  <receiver>" + saxutils.escape(agent) + "</receiver>\n  <date>Fri Feb  3 02:14:29 CST 2017</date>\n  <contents></contents>\n  <data>" + "$VAR1 = {'_DoNotLog' => 1,'KOMSWebData' => " + json.dumps(saxutils.escape(contents.decode('utf-8'))) + "};\n"  + "</data>\n</message>"
    # sys.stderr.write("\n\nQUERY:\n" + query + "\n\n\n")
    response = proxy.QueryAgent([query])
    # sys.stderr.write("\n\nGOT RESPONSE:\n\n\n\n")
    root = ET.fromstring(response[0])
    for child in root: 
        if child.tag == "data":
            # sys.stderr.write("<<<Text:" + child.text + ">>>\n\n")
            # p = re.compile(r".*?\'KOMSWebData\' => (\'|\")(.*?)(\'|\")(,\n|\n\s+(\'|};)|\n\t};)",re.DOTALL)
            # p = re.compile(r".*?\'KOMSWebData\' => (\'|\")(.*?)(\'|\")(,\n\s+(\'_DoNotLog\'|};)|\n\s+(\'|};)|\n\t};)",re.DOTALL)
            p = re.compile(r".*?\'KOMSWebData\' => (\'|\")(.*?)(\'|\")(,\n\s+(\'_DoNotLog\'|};\s+$)|\n\s+(\'|};\s+$)|\n\t};\s+$)",re.DOTALL)
            m = p.match(child.text)
            # sys.stderr.write("<<<Matching>>>\n\n")
            res = m.group(2)
            # sys.stderr.write("<<<Match:" + res + ">>>\n\n")
            result = saxutils.unescape(res).encode('utf-8')
            # result = saxutils.unescape(json.load(res)).encode('utf-8')
            # sys.stderr.write("<<<Converted>>>\n\n")
            return result
    return contents.encode('utf-8')

def response(flow: http.HTTPFlow) -> None:
    flow.response.content = QueryAgent("KOMSWeb",flow.response.content)
 
