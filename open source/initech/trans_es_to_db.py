#!/usr/bin/env python
#-*- coding: utf-8 -*-

import time
import datetime
from datetime import date
import rawes
import json
import pyes
import cx_Oracle

#현재 날짜에서 과거 날짜 계산
now = datetime.datetime.now()
now = now.replace(hour=0,minute=0,second=0,microsecond=0)
#timestamp = now.strftime('%Y-%m-%dT%H:%M:%S.000Z')
utcnow = datetime.datetime.utcnow()
utcnow = utcnow.replace(minute=0,second=0,microsecond=0)
today = datetime.date.today()
year = today.strftime("%Y")

yesterday = now - datetime.timedelta(days=1)
lastday = yesterday.strftime("%Y-%m-%d %H:%M:%S")
lastday_to_day = yesterday.strftime("%Y%m%d")
lastdayy = now.strftime("%Y-%m-%d %H:%M:%S")

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
        "interval": "12h"
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
#print("Raw Entries Data: %s" %entries)

#DB 접속 및 SQL 수행

dsn = cx_Oracle.makedsn("123.123.123.123", 1521, "orcl")
db = cx_Oracle.connect("initech", "initech", dsn)
cursor = db.cursor()
table_name = "TRANS_LAST_"+year
cnt_schema = "select count(*) from tab where TNAME="+"'"+table_name+"'"+""
schema = "CREATE TABLE TRANS_LAST_"+year+"(TRANS_DATE VARCHAR2(100) CONSTRAINTS TRANS_TRANS_DATE_PK PRIMARY KEY, TRANS_CNT number(20) default 0)"
sqlquery ="INSERT INTO TRANS_LAST_"+year+"(TRANS_DATE, TRANS_CNT) VALUES ('"+lastday_to_day+"', '"+str(sumtotals)+"')"
print("SQL: %s" %sqlquery)

cursor.execute(cnt_schema)
for schema_result in cursor:
	pass
print("Table Cnt : "+str(schema_result[0]))

if schema_result[0] == 1:
	pass
else:
	cursor.execute(schema)
	print("Excute Schema")

cursor.execute(sqlquery)
db.commit()
#for result in cursor:
#	print result



