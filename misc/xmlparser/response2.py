#!/usr/bin/python3

import xml.etree.ElementTree as ET

# root = ET.fromstring(country_data_as_string)
tree = ET.parse('response.xml')
root = tree.getroot()
for child in root:
    print(child)
    if child.tag == "contents":
        print(child.text)
    

