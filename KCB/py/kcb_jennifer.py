#!/usr/bin/env python
#-*- coding: utf-8 -*-

import datetime
import json
import rawes

###config###
name_field = 'name'
name_field2 = 'name.keyword'
value_field = 'cpu'
name_keyword = ['test1','test2']
search_time = '300d'
index_name = 'jennifer-'
date_prifix = '%Y.%m.%d'
############
now = datetime.datetime.now()
index_date = now.strftime(str(date_prifix))
index = str(index_name)+str(index_date)
print index

cnt = 0
keyword_cnt = len(name_keyword)

def return_query(cnt):
    query ={
    "_source": [str(name_field),str(value_field)],
    "sort" : [{ "@timestamp" : "desc"}],
    "query": {
        "bool": {
            "must": [
                        {"term": {str(name_field2) : str(name_keyword[cnt])}}],
        "filter": {
              "range": {
                "@timestamp": {
                  "gte": "now-"+str(search_time),
                  "lte": "now"
                }
              }
            }
        }
    },
    "size": 1
    }
    return query


#print query
es = rawes.Elastic('123.123.123.123:9200',timeout=10)

while cnt < keyword_cnt:
    query = return_query(cnt)
    result = es.get(str(index)+'/_search', headers={"Content-type": "Application/Json"},data=query)
    #print result
    facets = result['hits']['hits'][0]['_source']
    parsed_data = json.dumps(facets)
    json_object = json.loads(parsed_data)
    name = json_object[str(name_field)]
    value = json_object[str(value_field)]
    print str(name.encode('UTF8'))+"\t"+str(value)
    cnt += 1


'''
#현재 날짜에서 과거 날짜 계산
now = datetime.datetime.now()
now_start = now.replace(second=0,microsecond=0)
now_end_last = now - datetime.timedelta(days=2000)
now_end_last = now_end_last.replace(second=0,microsecond=0)

#print now_start
#print now_end_last

search_start = now_start.strftime("%Y-%m-%d"'T'"%H:%M:%S.000Z")
search_end_last = now_end_last.strftime("%Y-%m-%d"'T'"%H:%M:%S.000Z")
#print search_start
#print search_end_last
'''