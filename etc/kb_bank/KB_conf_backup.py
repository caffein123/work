#!/usr/bin/env python
#-*- coding: utf-8 -*-

#oracle ip
import ibm_db
import datetime

def log_date():
    now = datetime.datetime.now()
    today = now.strftime("%Y%m%d%H%M%S")
    return today

def db2_connection():
    connection = ibm_db.connect('DATABASE=sample;'
                         'HOSTNAME=123.123.123.123;'
                         'PORT=50000;'
                         'PROTOCOL=TCPIP;'
                         'UID=test;'
                         'PWD=test;', '', '')

    sql = "SELECT L.HOST_IP,N.MODEL,N.VENDOR,C.CPU_NUM,OS.OS_TYPE,OS.OS_VERSION,C.CPU_TYPE,C.CPU_CLOCK,CS.SYSTEM_ID FROM LOCATION L, NODE N, OPERATING_SYSTEM OS, CPUS C, COMPUTER_SYSTEM CS WHERE N.NODE_ID = L.LOCATION_ID AND N.NODE_ID = OS.NODE_ID AND N.NODE_ID =  C.NODE_ID AND N.NODE_ID = CS.NODE_ID"
    stmt = ibm_db.exec_immediate(connection, sql)
    schema_result = ibm_db.fetch_tuple(stmt)
    while (schema_result):
        schema_result = ibm_db.fetch_tuple(stmt)
        try:
            result = str(schema_result[0])+','+str(schema_result[1])+','+str(schema_result[2])+','+str(schema_result[3])+','+str(schema_result[4])+','+str(schema_result[5])+','+str(schema_result[6])
        except:
            pass
        f.write(result+'\n')

# Main
# 오라클 접속
date = log_date()
f = open("./config_"+date+".txt", 'w')
db2_connection()
f.close()
