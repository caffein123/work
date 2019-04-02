#!/usr/bin/env python
#-*- coding: utf-8 -*-
import re
import datetime
import glob

now = datetime.datetime.now()
now = now.strftime("%Y%m%d%H%M")


###CHANGE CONF
filepath = "C:/test/elasticsearch_client*"
###

inputfile_list = glob.glob(filepath)

cnt = 0
print "Start"
while len(inputfile_list) > cnt:
    inputfile_path = inputfile_list[cnt]
    inputfile = open(inputfile_path)
    if cnt == 0:
        outputfile = open('C:/test/result_' + now +'.txt', 'w')
    else:
        outputfile = open('C:/test/result_' + now + '.txt', 'a')
    for line in inputfile:
        r = re.compile('TOTAL_SUM|CURRENT_QUEUE_SIZE|BULK_REQUEST_CNT', re.IGNORECASE)
        match = bool(r.search(line))
        if match is True:
            split =line.split(" ")
            split_2 = split[5].split(":")
            date = str(split[0] + " " + split[1])
            date = date.replace("[", '')
            date = date.replace("]", '')

            name = str(split_2[0])
            name = name.replace("[RECEIVED_DATE_REPORT]", '')
            name = name.replace("[", '')
            name = name.replace("]", '')

            value = str(split_2[1])
            value = value.replace("[", '')
            value = value.replace("]", '')

            result = date +"\t"+ name + "\t" + value
            outputfile.write(result)
    cnt += 1
    inputfile.close()
    outputfile.close()

print "End"