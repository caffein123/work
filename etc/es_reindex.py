import rawes
import datetime
import sys
import logging
import logging.handlers

#es_url='http://192.168.233.14:19200'
#remote_url ='http://192.168.233.14:19200'
old_es = 'http://'+str(sys.argv[1])
new_es = 'http://'+str(sys.argv[2])
timeout = int(sys.argv[3])

file_path='./index_list.txt'

#Logging
logger = logging.getLogger('reindex')
logger.setLevel(logging.INFO)

formatter = logging.Formatter('[%(asctime)s] [%(levelname)s|%(filename)s:%(lineno)s] %(message)s')
fileHandler = logging.FileHandler('reindex.log')
streamHandler = logging.StreamHandler()

fileHandler.setFormatter(formatter)
streamHandler.setFormatter(formatter)

logger.addHandler(fileHandler)
logger.addHandler(streamHandler)


def read_file():
    with open(str(file_path), "r") as fd:
        lines = fd.read().splitlines()
    return lines

def timestamp():
    now = datetime.datetime.now()
    return now

def reindex(index):
    query = {
      "source": {
        "remote": {
          "host": str(old_es)
        },
        "index": str(index)
      },
      "dest": {
        "index": str(index)
      }
    }
    result = es.post('/_reindex', data=query)
    return result


lines = read_file()
es = rawes.Elastic(new_es, timeout=timeout)

for index in lines:
    start = timestamp()
    logger.info('{} reindex start'.format(index))
    try:
        result = reindex(index)
    except Exception as e:
        logger.error('{} reindex fail'.format(index))
        logger.error(str(e))
        continue
    end = timestamp()
    diff = end - start
    logger.info(str(result))
    logger.info('{} reindex end'.format(index))
    logger.info("{0} has finished to reindex. elpased time is {1} sec.".format(index,diff))
