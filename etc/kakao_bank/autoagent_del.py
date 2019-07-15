#!/usr/bin/env python
#-*- coding: utf-8 -*-

import datetime
from datetime import date
import paramiko
from time import sleep
import ConfigParser

#서버 정보 파일 Read
data = []
succ_servers = []
numlines = 0

timestamp = datetime.datetime.now()
timestamp = timestamp.strftime("%y%m%d_%H%M%S")

f = open("./conf/server_info.csv", 'r')
#f = open("C:/autoagent/server.txt", 'r')
w = open("./logs/autoagent_"+timestamp+"_del.log", 'a')
c = open("./logs/server_info_del_"+timestamp+"_fail.csv", 'a')
#파일 라인수 Read
for line in open('./conf/server_info.csv'): numlines += 1
#for line in open('C:/test/autoagent/server.txt'): numlines += 1

for i in f:
    data.append(i[:-1])
f.close()

def server_info(cnt):
	raw_info = data[cnt]
	info = raw_info.split(',')
	#info = raw_info.split('\t')
	return info

# Date
def time():
	now = datetime.datetime.now()
	now = now.strftime("%Y-%m-%d %H:%M:%S")
	print("["+now+"]")
#AGENT 설치
def install():
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	ssh.connect(str(server_ip), username=str(server_id), password=str(server_pw), timeout=30)
	sftp = ssh.open_sftp()
	sftp.put('./shell/autoagent_sms_del.sh', '/sw/nkia/agent/autoagent_sms_del.sh')
	sftp.close()
	ssh.exec_command('chmod 755 /sw/nkia/agent/autoagent_sms_del.sh' ,timeout=20)
	stdin, stdout, stderr = ssh.exec_command('cd /sw/nkia/agent; ./autoagent_sms_del.sh' ,timeout=50)
	a = stdout.readlines()
	print("-"*50)
	print("[Delete Start]")
	time()
	print("[Delete IP : "+server_ip+"]")

	for cmd_line in a:
		cmd_lines.append(cmd_line[:-1])

	if cmd_lines[-1] == '0001':
		print("[STATUS : Delete Success]")
		succ_servers.append(server_ip)
	else:
		print("[STATUS : Delete Fail]")
	time()
	print("[Delete End]")
	print("*"*50+"\n")
	f.close()
	ssh.close()

#메인
config_read()
cnt = 0
while numlines > cnt:
	cmd_lines = []
	info = server_info(cnt)
	server_ip = info[0]
	server_id = info[1]
	server_pw = info[2]
	print("*"*5+"[CNT : "+str(cnt+1)+"]"+"*"*36)
	print(info)
	try:
		sleep(0.5)
		install()
		w.write(">> Delete Log [ "+server_ip+" ]\n")
		for agent_log in cmd_lines:
			w.write(agent_log+"\n")
	except Exception:
		w.write(">> Delete Log [ "+server_ip+" ]\n[ERROR] "+server_ip+" Connection Failed\n")
		c.write(server_ip+","+server_id+","+server_pw+"\n")
		print("-"*50)
		print("[ERROR] "+server_ip+" Connection Failed")
		print("*"*50+"\n")
		pass
	cnt += 1
suc_cnt = len(succ_servers)
print("*"*50)
print("Total Agent Delete Success Count : "+str(suc_cnt))
w.write("Total Agent Delete Success Count : "+str(suc_cnt))
w.close()
c.close()
