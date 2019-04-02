import rawes
import datetime
import sys



#es_url='http://192.168.233.14:19200'
#remote_url ='http://192.168.233.14:19200'
es_url = 'http://'+str(sys.argv[1])
remote_url = 'http://'+str(sys.argv[2])

file_path='./index_list.txt'

with open(str(file_path), "r") as fd:
    lines = fd.read().splitlines()

def timestamp():
    now = datetime.datetime.now()
    return now

def reindex(index):
    query = {
      "source": {
        "remote": {
          "host": str(remote_url)
        },
        "index": str(index)
      },
      "dest": {
        "index": str(index)
      }
    }
    es.post('/_reindex', data=query)

es = rawes.Elastic(es_url, timeout=100000)
for index in lines:
    with open('../reindex_logs', "a") as fw:
        start = timestamp()
        fw.write('[{0}] {1} reindex start'.format(start,index))
        #print('[{0}] {1} reindex start'.format(start,index))
        reindex(index)
        end = timestamp()
        diff = end - start
        fw.write('[{0}] {1} reindex end'.format(end,index))
        #print('[{0}] {1} reindex end'.format(end,index))
        fw.write("{0} has finished to reindex. elpased time is {1} sec.".format(index,diff))
        #print("{0} has finished to reindex. elpased time is {1} sec.".format(index,diff))

