"""
This script reflects all content passing through the proxy.
"""
import xmlrpc.client
import xml.etree.ElementTree as ET
import xml.sax.saxutils as saxutils

def QueryAgent(agent, contents):
    proxy = xmlrpc.client.ServerProxy('http://agi.frdcsa.org:10000')
    query = "<message>\n  <id>1</id>\n  <sender>Test</sender>\n  <receiver>" + agent + "</receiver>\n  <date>Fri Feb  3 02:14:29 CST 2017</date>\n  <contents>" + saxutils.escape(contents) + "</contents>\n  <data>$VAR1 = {\'_DoNotLog\' => 1};\n</data>\n</message>"
    response = proxy.QueryAgent([query])
    root = ET.fromstring(response[0])
    for child in root:
        if child.tag == "contents":
            return saxutils.unescape(child.text)

print(QueryAgent("Echo","hello"))
