import rawes
import datetime
import sys
import logging
import logging.handlers
import json

es_url = 'http://'+str(sys.argv[1])
timeout = int(sys.argv[2])
file_path='./query_lists.txt'

#Logging
logger = logging.getLogger('reindex')
logger.setLevel(logging.INFO)

formatter = logging.Formatter('[%(asctime)s] [%(levelname)s|%(filename)s:%(lineno)s] %(message)s')
fileHandler = logging.FileHandler('reindex_create.log')
streamHandler = logging.StreamHandler()

fileHandler.setFormatter(formatter)
streamHandler.setFormatter(formatter)

logger.addHandler(fileHandler)
logger.addHandler(streamHandler)


def read_file():
    with open(str(file_path), "r") as fd:
        lines = json.loads(fd.read())
    return lines

def timestamp():
    now = datetime.datetime.now()
    return now

def reindex(query):
    result = es.post('/_reindex', data=query)
    return result

query_lists = read_file()

for query in query_lists:
    es = rawes.Elastic(es_url, timeout=timeout)
    start = timestamp()
    logger.info('from : {0} to : {1} reindex start'.format(query['source']['index'],query['dest']['index']))
    try:
        result = reindex(query)
    except Exception as e:
        logger.error(str(e))
        logger.error('from : {0} to : {1} reindex Fail'.format(query['source']['index'],query['dest']['index']))
        continue
    end = timestamp()
    diff = end - start
    logger.info(str(result))
    logger.info('from : {0} to : {1} reindex end'.format(query['source']['index'],query['dest']['index']))
    logger.info("Finished to reindex. elpased time is {} sec.".format(diff))
