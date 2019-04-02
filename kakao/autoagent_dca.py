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

#설정파일 Read

def config_read():
	print("# Loading Config File...")
	config = ConfigParser.RawConfigParser()
	config.read('./conf/autoagent.conf')
	c = config.items('Autoagent Config')
	UPLOAD_DIR = c[0][1]
	AGENT_FILE_32 = c[1][1]
	AGENT_FILE_64 = c[2][1]
	if UPLOAD_DIR == "" or AGENT_FILE_32 == "" or AGENT_FILE_64 == "":
		print("[ERROR] Please Check Config File...")
		exit()

timestamp = datetime.datetime.now()
timestamp = timestamp.strftime("%y%m%d_%H%M%S")

f = open("./conf/server_info_dca.csv", 'r')
#f = open("C:/autoagent/server.txt", 'r')
w = open("./logs/autoagent_"+timestamp+"_dca.log", 'a')
c = open("./logs/server_info_dca_"+timestamp+"_fail.csv", 'a')
#파일 라인수 Read
for line in open('./conf/server_info_dca.csv'): numlines += 1
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
	ssh.exec_command('mkdir -p /sw/nkia/agent' ,timeout=20)
	sftp = ssh.open_sftp()
	sftp.put('./shell/autoagent_dca.sh', '/sw/nkia/agent/autoagent_dca.sh')
	stdin, stdout, stderr = ssh.exec_command('uname -a' ,timeout=20)
	uname = stdout.readlines()
	uname_os = uname[0].find("Linux")
	uname_bit = uname[0].find("x86_64")
	if uname_os >= 0 and uname_bit >= 0:
		sftp.put('./file/PolestarDCA_Linux64_3.4_2.3.1.2_kakao.tar.gz', '/sw/nkia/agent/PolestarDCA_Linux64_3.4_2.3.1.2_kakao.tar.gz')
	elif uname_os >= 0 and uname_bit <= 0:
		sftp.put('./file/PolestarDCA_Linux_3.4_2.3.1.2_kakao.tar.gz', '/sw/nkia/agent/PolestarDCA_Linux_3.4_2.3.1.2_kakao.tar.gz')
	sftp.close()
	ssh.exec_command('chmod 755 /sw/nkia/agent/autoagent_dca.sh' ,timeout=20)
	stdin, stdout, stderr = ssh.exec_command('cd /sw/nkia/agent; ./autoagent_dca.sh' ,timeout=50)
	a = stdout.readlines()
	print("-"*50)
	print("[Install Start]")
	time()
	print("[Install IP : "+server_ip+"]")

	for cmd_line in a:
		cmd_lines.append(cmd_line[:-1])

	if cmd_lines[-1] == '0002':
		print("[STATUS : Install Success]")
		succ_servers.append(server_ip)
	else:
		print("[STATUS : Install Fail]")
	time()
	print("[Install End]")
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
		w.write(">> Install Log [ "+server_ip+" ]\n")
		for agent_log in cmd_lines:
			w.write(agent_log+"\n")
	except Exception:
		w.write(">> Install Log [ "+server_ip+" ]\n[ERROR] "+server_ip+" Connection Failed\n")
		c.write(server_ip+","+server_id+","+server_pw+"\n")
		print("-"*50)
		print("[ERROR] "+server_ip+" Connection Failed")
		print("*"*50+"\n")
		pass
	cnt += 1
suc_cnt = len(succ_servers)
print("*"*50)
print("Total Agent Install Success Count : "+str(suc_cnt))
w.write("Total Agent Install Success Count : "+str(suc_cnt))
w.close()
c.close()
