#!/usr/bin/env python
#-*- coding: utf-8 -*-

import time
import datetime
from datetime import date
import rawes
import json
import cx_Oracle

#현재 날짜에서 과거 날짜 계산
now = datetime.datetime.now()
now = now.replace(hour=0,minute=0,second=0,microsecond=0)
#timestamp = now.strftime('%Y-%m-%dT%H:%M:%S.000Z')
utcnow = datetime.datetime.utcnow()
utcnow = utcnow.replace(minute=0,second=0,microsecond=0)
today = datetime.date.today()
year = today.strftime("%Y")

search_end = now + datetime.timedelta(days=1)
lastday = now.strftime("%Y-%m-%d %H:%M:%S")
lastday_to_day = now.strftime("%Y%m%d")
lastdayy = search_end.strftime("%Y-%m-%d %H:%M:%S")


def test():
	lastday = now - datetime.timedelta(days=1)
	search_end = now.strftime("%Y-%m-%d %H:%M:%S")
	lastdayy = lastday.strftime("%Y-%m-%d %H:%M:%S")


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
db = cx_Oracle.connect("test", "test", dsn)
cursor = db.cursor()

table_name = "TRANS_"+year
cnt_schema = "select count(*) from tab where TNAME="+"'"+table_name+"'"+""
schema = "CREATE TABLE TRANS_"+year+"(TRANS_DATE VARCHAR2(100) , TRANS_CNT number(20) default 0)"
insert_query ="INSERT INTO TRANS_"+year+"(TRANS_DATE, TRANS_CNT) VALUES ('"+lastday_to_day+"', '"+str(sumtotals)+"')"
update_query ="UPDATE TRANS_"+year+" SET TRANS_CNT="+str(sumtotals)+" WHERE TRANS_DATE="+lastday_to_day+""
select_query ="select TRANS_DATE from(select TRANS_DATE from TRANS_"+year+" order by TRANS_DATE desc) where rownum <= 1"


#print(select_query)
#print(insert_query)
#print(update_query)
'''
cursor.execute(cnt_schema)
for schema_result in cursor:
	pass
print("Table Cnt : "+str(schema_result[0]))

if schema_result[0] == 1:
	pass
else:

	cursor.execute(schema)
	print("Excute Schema")

cursor.execute(select_query)
sql_result = '0'
for sql_result in cursor:
	pass
print("SQL Date : "+str(sql_result))

if sql_result[0] == lastday_to_day:
	cursor.execute(update_query)
	print("SQL :"+update_query)
else:
	cursor.execute(insert_query)
	print("SQL :"+insert_query)

db.commit()
db.close()
'''