#!/usr/bin/env python

import urllib2
import json
import base64
import ConfigParser

conf_file = "config.cfg"
alias_name = "A1"

config = ConfigParser.ConfigParser()
config.read(conf_file)
server = config.get(alias_name,"server")
id = config.get(alias_name,"id")
pwd = config.get(alias_name,"pwd")
result_file_dir = config.get(alias_name,"result_file_dir")

encode_data = id + ":" + pwd
encode_data = "Basic "+ base64.b64encode(encode_data)

headers = {
    "Authorization": encode_data
}

data = {
  "jeusadmin": {
        "command": "server-info",
        "options":[
            "-state"
            ]
    }
}

url = "http://" + server + "/jsonCommand/command.json"
f = open(str(result_file_dir), 'w')
#data = urllib.urlencode(data)
data = json.dumps(data)

def req_url(url):
    req = urllib2.Request(url, headers=headers ,data=data )
    result = urllib2.urlopen(req)
    result = result.read()
    return result

def parse_data(result):
    result = json.loads(result)
    column_names = result['jeusadmin-result']['data'][0]['column-names']
    raw_data = result['jeusadmin-result']['data'][0]['rows']
    for i in raw_data:
        raw_data = i['values']
        totals.append(raw_data)

def wirte_data():
    cnt = 0
    while cnt < len(totals):
        total = totals[cnt]
        server_name = total[0]
        server_name = server_name.replace("*", "")
        server_name = server_name.replace("(", "")
        server_name = server_name.replace(")", "")
	server_name = server_name.replace(" ", "")
        server_name = server_name.strip()
	node_name = total[2]
        status = total[1]
	status_code = status.find('RUNNING')
	if status_code == 0:
		status = status.split('(')
        	uptime = status[1].split(')')
        	result_data = node_name + "\t" + server_name + "\t" + status[0] + "\t" + uptime[0] +"\n"
	else:
		result_data = node_name + "\t" + server_name + "\t" + status +"\n"
        f.write(result_data)
        cnt += 1

totals = []

result = req_url(url)
parse_data(result)
wirte_data()

f.close()
