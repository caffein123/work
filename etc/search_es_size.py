#!/usr/bin/env python
#-*- coding: utf-8 -*-

import urllib
import json

def es_search(ipaddr):
    es_result = urllib.urlopen(str(ipaddr)+"/_cat/indices?bytes=b&h=index,store.size&format=json&pretty")
    es_data = es_result.read()
    data = json.loads(es_data)
    return data

def convert_dic(data):
    cnt = 0
    while cnt < len(data):
        total_values[str(data[cnt]['index'])] = str(data[cnt]['store.size'])
        cnt += 1
    return total_values

def search_index_name(index_name):
    size_value = []
    key_value = []
    for key in total_values:
        if key.startswith(index_name):
            value = total_values[key]
            key_value.append(key)
            size_value.append(int(value))
            total_size = sum(size_value)
    #print key_value
    #print size_value
    print "%s : %d" %(index_name, total_size)

# Main
cnt = 0
ipaddr = "http://192.168.232.11:9200"
index_name_list = ["event_raw", "tabular", "metric_day", "metric_month" , "metric_real" , "metric_recent" , "metric_week" , "metric_year"]
total_values = dict()
data = es_search(ipaddr)
total_values = convert_dic(data)
print "# Search Polestar7 indices Size Result(byte)"
while cnt < len(index_name_list):
    index_name = index_name_list[cnt]
    search_index_name(index_name)
    cnt += 1




