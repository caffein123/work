#!/usr/bin/env python
#-*- coding: utf-8 -*-

import time
import datetime
from datetime import date
import rawes
import json
import pyes

#현재 날짜에서 과거 날짜 계산
now = datetime.datetime.now()
now = now.replace(minute=0,second=0,microsecond=0)
#timestamp = now.strftime('%Y-%m-%dT%H:%M:%S.000Z')
utcnow = datetime.datetime.utcnow()
utcnow = utcnow.replace(minute=0,second=0,microsecond=0)
timestamp = utcnow.strftime('%Y-%m-%dT%H:%M:%S.000Z')
today = datetime.date.today()
today = today.strftime("%Y.%m.%d")

lastday = now - datetime.timedelta(days=2)
lastdayy = lastday + datetime.timedelta(hours=1)
lastday = lastday.strftime("%Y-%m-%d %H:%M:%S")
lastdayy = lastdayy.strftime("%Y-%m-%d %H:%M:%S")
#UNIX 시간으로 계산
uxtend = time.mktime(datetime.datetime.strptime(lastdayy, "%Y-%m-%d %H:%M:%S").timetuple())*1000
#uxtend = time.mktime(datetime.datetime.strptime('2016-09-14 21:00:00', "%Y-%m-%d %H:%M:%S").timetuple())*1000
uxtstart = time.mktime(datetime.datetime.strptime(lastday, "%Y-%m-%d %H:%M:%S").timetuple())*1000
#uxtstart = time.mktime(datetime.datetime.strptime('2016-09-14 20:00:00', "%Y-%m-%d %H:%M:%S").timetuple())*1000

print("Search Start: "+lastday)
print("Search End  : "+lastdayy)
print("UnixTime Start : %d" %uxtstart)
print("UnixTime End   : %d" %uxtend)

#Elastic 접속 및 쿼리 수행
es = rawes.Elastic('123.123.123.123:9200',timeout=10)
query ={
  "facets": {
    "0": {
      "date_histogram": {
        "key_field": "거래시간",
        "value_field": "총거래",
        "interval": "1h"
      },
      "facet_filter": {
        "fquery": {
          "query": {
            "filtered": {
              "query": {
                "query_string": {
                  "query": "은행명: *"
                }
              },
              "filter": {
                "bool": {
                  "must": [
                    {
                      "range": {
                        "거래시간": {
                        "from": uxtstart,
                          "to": uxtend
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      }
    }
    },
"size": 0
}
#print(query)

#쿼리 결과 값 변환
result = es.get('/_search', data=query)
facets = result['facets']
parsed_data = json.dumps(facets)
json_object = json.loads(parsed_data)
entries = json_object['0']['entries']
totals = []
for i in entries:
	total = i['total']
	totals.append(total)
print("List : %s" %totals)
sumtotals = sum(totals)
#dic = entries[0]
#total = dic['total']

print("Total: %d" %sumtotals)
print("Raw Entries Data: %s" %entries)

qqueryinit ={
'@timestamp': timestamp,
'거래시간': timestamp,
'총거래' : 0,
'test' : 'last'
}

qquery ={
'@timestamp': timestamp,
'거래시간': timestamp,
'총거래' : sumtotals,
'test' : 'last'
}

#인덱싱할 최근 인덱스 검색
es2 = pyes.ES('123.123.123.123:9200', timeout=10)
schema = es2.indices.get_indices()
indices_full_list = schema.keys()
just_indices = [index for index in indices_full_list if not index.startswith(".")]
just_indices.sort()
index = just_indices[-1]


print("index : %s" %index)
print("Raw Query Data: %s" %qquery)
puturl='%s/last' %index
print(puturl)
#puturl='initech-2016.09.16/last'

#Elasticsearch 데이터 인덱싱
#es.post(puturl, data=qqueryinit)
#es.post(puturl, data=qquery)

