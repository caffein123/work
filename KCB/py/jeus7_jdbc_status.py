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
result_file_dir = config.get(alias_name,"jdbc_result_file_dir")

encode_data = id + ":" + pwd
encode_data = "Basic "+ base64.b64encode(encode_data)

headers = {
    "Authorization": encode_data
}

data = {
  "jeusadmin": {
        "command": "connection-pool-info",
        "options":[
            "-jdbc"
            ]
    }
}

url = "http://" + server + "/jsonCommand/command.json"
f = open(str(result_file_dir), 'w')
#data = urllib.urlencode(data)
data = json.dumps(data)

req = urllib2.Request(url, headers=headers ,data=data )
result = urllib2.urlopen(req)
result = result.read()
result = json.loads(result)
#print result

json_data = result['jeusadmin-result']['data']
#print len(json_data)
cnt =0
while cnt < len(json_data):
    cnt2 = 0
    totals = []
    server_name = result['jeusadmin-result']['data'][cnt]['title']
    server_name = server_name.split('[')
    server_name = server_name[1]
    server_name = server_name.split(']')
    server_name = server_name[0]
    #print server_name
    #column_names = result['jeusadmin-result']['data'][cnt]['column-names']
    raw_data = result['jeusadmin-result']['data'][cnt]['rows']
    for i in raw_data:
        raw_data = i['values']
        totals.append(raw_data)
    #print totals
    #print len(totals)
    while cnt2 < len(totals):
        total = totals[cnt2]
        jdbc_name = total[0]
        jdbc_name = jdbc_name.replace("*", "")
        jdbc_name = jdbc_name.replace("(", "")
        jdbc_name = jdbc_name.replace(")", "")
        jdbc_name = jdbc_name.replace(" ", "")
        jdbc_name = jdbc_name.strip()
        min = total[1]
        max = total[2]
        active = total[3]
        result_data =str(server_name) + "\t" + str(jdbc_name) + "\t" + str(min) + "\t" + str(max) + "\t" + str(active) + "\n"
        #print result_data
        f.write(result_data)
        cnt2 += 1
    cnt +=1
    #print cnt

f.close()

