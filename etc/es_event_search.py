#!/usr/bin/env python
#-*- coding: utf-8 -*-
import rawes
import datetime
import time


start_time = '2015-04-15 12:23:38'
end_time = '2017-05-31 12:23:38'
type = 'logMessage'
#type = 'syslog'


start_time_str = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_str = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')

'''
now = datetime.datetime.now()
yesterday = now - datetime.timedelta(days=1)

today = now.strftime("%Y-%m-%d %H:%M:%S")
yesterday = yesterday.strftime("%Y-%m-%d %H:%M:%S")
'''
uxtstart = time.mktime(datetime.datetime.strptime(str(start_time_str), "%Y-%m-%d %H:%M:%S").timetuple())*1000
uxtend = time.mktime(datetime.datetime.strptime(str(end_time_str), "%Y-%m-%d %H:%M:%S").timetuple())*1000

def install(package):
    pip.main(['install', package])

def es_connection(ipaddr,tmout):
    es = rawes.Elastic(ipaddr, timeout=tmout)
    return es

def return_query():
        query = {
            "size": 0,
            "query": {
                "filtered": {
                    "filter": {
                        "bool": {
                            "must": [
                                {"term": {"EVENT_TYPE": type}},
                                {"range": {"EVENT_TIME": {"from": uxtstart, "to": uxtend}}}
                            ]
                        }
                    }
                }
            },
            "aggregations": {
                "es_result": {
                    "terms": {
                        #"field": "EVENT_PLATFORM_RESOURCE_ID",
                        "field": "EVENT_RESOURCE_ID",
                        "size": 20000
                    }
                }
            }
        }
        result = es.get('/_search', data=query)
        facets = result['aggregations']['es_result']['buckets']
        total = result['hits']['total']
        print "-" * 40
        print "RESOURCE_ID" + "\t" + "COUNT"
        print "-" * 40
        for kv in facets:
            platform_id = kv['key']
            count = kv['doc_count']
            print str(platform_id) + "\t\t" + str(count)
        print "-"*40
        print "Total"+ "\t" + str(total)

        '''
        parsed_data = json.dumps(facets[int(cnt)])
        json_object = json.loads(parsed_data)
        result_all = json_object['fields']
        '''


def return_query2():
    query = {
        "size": 0,
        "query": {
            "filtered": {
                "filter": {
                    "bool": {
                        "must": [
                            {"range": {"EVENT_TIME": {"from": uxtstart, "to": uxtend}}}
                        ]
                    }
                }
            }
        },
        "aggregations": {
            "es_result": {
                "terms": {
                    "field": "EVENT_TYPE",
                    "size": 20000
                }
            }
        }
    }
    result = es.get('/_search', data=query)
    facets = result['aggregations']['es_result']['buckets']
    total = result['hits']['total']
    print "\n"
    print "-" * 40
    print "EVENT_TYPE" + "\t" + "COUNT"
    print "-" * 40
    for kv in facets:
        event_type = kv['key']
        count = kv['doc_count']
        print str(event_type) + "\t" + str(count)
    print "-" * 40
    print "Total" + "\t" + str(total)


# Main
# ES 접속
print "Search Time : "+ str(start_time) + " ~ " + str(end_time)
print "Search Type : "+ str(type)
es = es_connection('http://192.168.232.11',10)
return_query()
return_query2()

