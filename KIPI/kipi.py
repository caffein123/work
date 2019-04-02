#!/usr/bin/env python
#-*- coding: utf-8 -*-

import datetime
import json
import rawes


#현재 날짜에서 과거 날짜 계산
now = datetime.datetime.now()
now_start = now.replace(hour=0,minute=0,second=0,microsecond=0)
now_end = now.replace(microsecond=0)
now_end_last = now - datetime.timedelta(minutes=10)


search_start = now_start.strftime("%Y-%m-%d"'T'"%H:%M:%S")
search_end = now_end.strftime("%Y-%m-%d"'T'"%H:%M:%S")
search_end_last = now_end_last.strftime("%Y-%m-%d"'T'"%H:%M:%S")
#print search_start
#print search_end
#print search_end_last

es = rawes.Elastic('123.123.123.123:9200',timeout=10)
query ={
 "query": {
  "bool": {
   "must": [
     {
      "range": {
       "TIME": {
        "gte": search_start,
         "lte": search_end
               }
               }
     }
   ]
}
},
  "size": 0,
  "aggs": {
    "group_by_app": {
      "terms": {
        "field": "app_name"
      },
  "aggs" : {
    "uniques" : {
        "cardinality" : {
            "field" : "client_id"
        }
    },
    "uniquesTerms": {
        "terms": {
            "field": "client_id"
        },
        "aggs": {
            "jobs": { "top_hits": { "_source": "title", "size": 1 }}
        }
    }
}
}
}
}

query2 ={
 "query": {
  "bool": {
   "must": [
     {
      "range": {
       "TIME": {
        "gte": search_start,
         "lte": search_end_last
               }
               }
     }
   ]
}
},
  "size": 0,
  "aggs": {
    "group_by_app": {
      "terms": {
        "field": "app_name"
      },
  "aggs" : {
    "uniques" : {
        "cardinality" : {
            "field" : "client_id"
        }
    },
    "uniquesTerms": {
        "terms": {
            "field": "client_id"
        },
        "aggs": {
            "jobs": { "top_hits": { "_source": "title", "size": 1 }}
        }
    }
}
}
}
}
#print query
#print query2
result = es.get('/_search', data=query)
facets = result['aggregations']['group_by_app']['buckets']
parsed_data = json.dumps(facets)
json_object = json.loads(parsed_data)
#print json_object

result_last = es.get('/_search', data=query2)
facets_last = result_last['aggregations']['group_by_app']['buckets']
parsed_data_last = json.dumps(facets_last)
json_object_last = json.loads(parsed_data_last)
#print json_object_last

cnt = 0
while cnt < len(json_object):
    app_key = json_object[cnt]['key']
    visit_sum_cnt = json_object[cnt]['uniques']['value']
    req_sum_cnt = json_object[cnt]['doc_count']
    visit_cnt_last = json_object_last[cnt]['uniques']['value']
    req_cnt_last = json_object_last[cnt]['doc_count']
    visit_cnt= int(visit_sum_cnt) - int(visit_cnt_last)
    req_cnt = int(req_sum_cnt) - int(req_cnt_last)
    app_key = app_key.upper()
    print str(app_key.encode('UTF8'))+"\t"+str(visit_sum_cnt)+"\t"+str(req_sum_cnt)+"\t"+str(visit_cnt)+"\t"+str(req_cnt)
    cnt +=1
