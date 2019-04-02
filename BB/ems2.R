rm(list=ls())

install.packages('elastic')
install.packages('scales')
install.packages('data.table')
install.packages('lawstat')
install.packages("rJava")
install.packages("DBI")
install.packages("RJDBC")
library('elastic')
library('dplyr')
library('ggplot2')
library('scales')
library('data.table')
library('lawstat')
# DB 접속
library('rJava')
library('DBI')
library('RJDBC')
drv <- JDBC("oracle.jdbc.driver.OracleDriver",classPath ="driver/ojdbc6-11.2.0.4.0.jar")
drv <- JDBC("com.tmax.tibero.jdbc.TbDriver",classPath ="driver/tibero-jdbc-5.0.jar")
drv <- JDBC("org.postgresql.Driver",classPath ="driver/postgresql-42.2.5.jar")
conn <- dbConnect(drv, "jdbc:oracle:thin:@:1521:", "test", "test")
conn <- dbConnect(drv, "jdbc:tibero:thin:@:8629:", "test", "test")
conn <- dbConnect(drv, "jdbc:postgresql://:5432/", "test", "test")

node_list <- dbGetQuery(conn, "select ID,hostname  from cmm_resource where resource_type ='server.Server' and DTIME IS NULL")
def_list <- dbGetQuery(conn, "select ID,displayname,resource_type  from cmm_measurement_def where resource_type like '%polestar.ElasticsearchCluster%'")
node_list <- dbGetQuery(conn, "select ID,hostname  from cmm_resource where resource_type ='polestar.Ap' and DTIME IS NULL")
def_list <- dbGetQuery(conn, "select ID,displayname,resource_type  from cmm_measurement_def where resource_type like '%server.%'")
def_list

#특정노드
node_list
node_list = node_list[grep("HKCC-TREC236|HKCC-TREC231|HKCC-TREC235|HKCC-TREC234|HKCC-TREC232|HKCC-TREC233|ygdr1|HF_DLP_LOG", node_list$HOSTNAME),]
def_list

#ES
def_list = def_list[-c(1,2),]
#AP
def_list = def_list[-c(1,36,35,34,33,32,31),]

#ES커넥션
conn <- function(es_url,es_port) {
  connect(es_base = es_url, es_port =es_port)
}
#metic_id
metric_id = subset(def_list,select=c(1,2))
metric_id = subset(def_list,select=c(1,2),RESOURCE_TYPE=="server.Disks" & DISPLAYNAME=="Top I/O 처리율")
metric_id = metric_id$id
metric_id = paste('"',metric_id,'"',sep="")
metric_id


#node_id
node_id = paste('"',node_id,'"',sep="")
for (node_id in node_list[c(1)]) {
  node_id = paste('"',node_id,'"',sep="")
}
metric_id

#커넥션
conn = conn("http://192.168.233.95",19200)


query_list = list()
for (i in node_id) {
  body = paste('{
               "query": {
               "bool": {
               "must": [
               {
               "term": {
               "METRIC_PLATFORM_ID":',i,'  }
               }
               ,
               {
               "term": {
               "METRIC_DEFINITION_ID":',metric_id,'}
               }
               ],
               "must_not": [ ],
               "should": [ ]
               }
               },
               "sort": [ ],
               "aggs": { }
}')
    query_list = append(query_list, list(body))
    }








#쿼리
query_list = list()
  for (i in metric_id) {
    body = paste('{
              "query": {
                 "bool": {
                 "must": [
                 {
                 "term": {
                 "METRIC_RESOURCE_ID":',node_id[1],'  }
                 }
                 ,
                 {
                 "term": {
                 "METRIC_DEFINITION_ID":',i,'}
                 }
                 ],
                 "must_not": [ ],
                 "should": [ ]
                 }
  },
                 "sort": [ ],
                 "aggs": { }
                 }')
    query_list = append(query_list, list(body))
  }

#서치
search_perf = function() {
  metric_numeric_val = function(cnt){
    search[[cnt]]$`_source`$METRIC_NUMERIC_VAL
  }
  
  metric_time = function(cnt){
    search[[cnt]]$`_source`$METRIC_TIME
  }
  
  metric_numeric_val_v =c()
  metric_time_v = c()
  
  cnt = 1
  while (cnt < length(search)) {
    metric_numeric_val_v = c(metric_numeric_val_v,metric_numeric_val(cnt))
    cnt = cnt + 1
  }
  
  cnt = 1
  while (cnt < length(search)) {
    metric_time_v = c(metric_time_v,metric_time(cnt))
    cnt = cnt + 1
  }
  metric_time_v=metric_time_v/1000
  metric_time_v = as.POSIXct(metric_time_v, origin="1970-01-01")
  metric_time_v = as.POSIXlt(metric_time_v)
  metric_time_v$sec = 0
  test = data.frame(time=metric_time_v, value=metric_numeric_val_v)
  test = arrange(test, time)
}

#metric_recent_20180827*
#metric_day_201807*
#metric_week_201807*
#metric_month_201804*
rm(search,search_list)
search_list = list()
for (jquery in query_list) {
  Sys.sleep(1)
  search = Search(index ="metric_recent_20181026*" ,body=jquery, size=100000)$hits$hits
  if (is.null(unlist(search)) == TRUE) {
    perf_result = NULL
  }else{
    perf_result = search_perf()
  }
  search_list = append(search_list,list(perf_result))
}
search_list_AP2[3]
search_list_ES = search_list 
def_list
search_list[[1]]
names(search_list)
names(search_list) = c(def_list$displayname)
names(search_list_AP1)[6]
search_list_AP1[[24]]
boxplot(search_list_AP1[[3]]$value,outline=FALSE,horizontal=TRUE)
help("boxplot")
max(search_list_AP1[[1]]$value)
par(mar=c(2,1,2,1))
par(mfcol = c(2,2))
par(mfcol = c(1,1))
par(mfcol = c(10,10))
cnt = 1
for (j in search_list_AP1) {
  if (is.null(j$value) == TRUE) {
  }else{
    boxplot(search_list_AP1[[cnt]]$value,outline=FALSE,horizontal=TRUE)
    title(names(search_list_AP1)[cnt], line=-1,adj=0.1)
  }
  cnt = cnt + 1
}
names(search_list_AP1)
#####################################
install.packages('TSrepr')
install.packages('devtools')

library(TSrepr)
library(ggplot2)
devtools::install_github("PetoLau/TSrepr")
search_list[3]$`Cygnus-QA-DB`$value
data_ts

data_ts <- as.numeric(search_list[3]$`Cygnus-QA-DB`$value) # electricity load consumption data
# Comparison of PAA and PLA
# Dimensionality of the time series will be reduced 8 times
data_paa <- repr_paa(data_ts, q = 12, func = mean)
data_pla <- repr_pla(data_ts, times = 55, return = "both") # returns both extracted places and values

data_plot <- data.frame(value = c(data_ts, data_paa, data_pla$points),
                        time = c(1:length(data_ts), seq(6, length(data_ts), by = 12), data_pla$places),
                        type = factor(c(rep("Original", length(data_ts)), rep(c("PAA", "PLA"), each = 56))))

ggplot(data_plot, aes(time, value, color = type, size = type)) +
  geom_line(alpha = 0.8) +
  scale_size_manual(values = c(0.6, 0.8, 0.8)) +
  theme_bw()

search_list[3]

# 패턴 비교(plot)
par(mar=c(0.2,0,0,0))
par(mfcol = c(4,4))
par(mfcol = c(5,5))
cnt = 1
for (j in search_list) {
  if (is.null(j$value) == TRUE) {
  }else{
  plot(j$value[1:1400],type="l",xaxt="n", yaxt="n", xlab="",ylab="")
  title(node_list[,2][cnt], line=-1,adj=0.1)
  }
  cnt = cnt + 1
}



plot(search_list$`HKCC-TREC232`$value[1:1400],type="l",xaxt="n", yaxt="n", xlab="",ylab="")
title("HKCC-TREC232", line=-1,adj=0.1)


# 패턴 비교(cor)
options(scipen = 999)
rm(res,res_list)
res_list = list()
for (j in search_list) {
  if (is.null(j$value) == TRUE) {
  res=NULL
  }else{
  res <- cor.test(search_list$`HKCC-TREC235`$value[1:1400], j$value[1:1400], method = "pearson")
  }
  res_list = append(res_list,list(as.numeric(res$estimate)))
}
names(res_list) = c(node_list$HOSTNAME)
help(cor.test)
cor_result = data.frame(
  hostname = rep(names(res_list), lapply(res_list, length)),
  value = unlist(res_list))

cor_result = cor_result[order(cor_result$value,decreasing =T),]
cor_result

# 비교 데이터로 plot
par(mar=c(0.2,0,0,0))
par(mfcol = c(4,4))

for (n in cor_result$hostname) {
  plot(search_list$n$value[1:1400],type="l",xaxt="n", yaxt="n", xlab="",ylab="")
  title(n, line=-1,adj=0.1)
}

plot(search_list$`HF_DLP_LOG`$value[1:1400],type="l",xaxt="n", yaxt="n", xlab="",ylab="")
title(cor_result$hostname[12], line=-1,adj=0.1)
cor_result$hostname

#패턴 확인
search_list[2]$windows2000$hostname = c("windows2000")
search_list[2]$windows2000

apt_data_by_gu_qrt <- aggregate(search_list[2]$windows2000$value, by=list(search_list[2]$windows2000$time,search_list[2]$windows2000$hostname), mean)
apt_data_by_gu_qrt
names(apt_data_by_gu_qrt) <- c("time","hostname","value")
tail(apt_data_seo_price,1000)
ggplot(apt_data_by_gu_qrt,aes(x=time,y=value,group=1))+
  geom_line() +
  xlab("년도")+
  ylab("평균매매가격")+
  theme(axis.text.x=element_text(angle=90))+
  stat_smooth(method='lm')

gu_meanprice <- as.data.table(aggregate(search_list[2]$windows2000$value,by=list(search_list[2]$windows2000$time,search_list[2]$windows2000$hostname),mean))
gu_meanprice
names(gu_meanprice)<- c('time','hostname','value')
#중복없이 구 추출
gu_list <- unique(gu_meanprice$hostname)
gu_list
head(gu_meanprice)
str(gu_meanprice)
gu_meanprice[value]
runs_p<-c()
runs_p <- c(runs_p, runs.test(gu_meanprice[value])$p.value)
for(g in gu_list){
  runs_p <- c(runs_p, runs.test(gu_meanprice[hostname %in% g,value])$p.value)
}
runs_p
options(scipen = 999)
ggplot(data.table(gu_list, runs_p), aes(x=gu_list, y=runs_p, group=2)) + geom_point()
ggplot(data.table(gu_list, runs_p), aes(x=gu_list, y=runs_p, group=2)) +
  geom_line() + geom_point() +
  ylab('P-value') + xlab('구') +
  theme(axis.text.x=element_text(angle=90))
perf_result3 = perf_result2
perf_result3[11,]$value = 100
perf_result3[11,]$value
res <- cor.test(perf_result2$value, perf_result3$value, method = "pearson")
res$estimate
#------
perf_result = perf_result[c(1,2)]
perf_result2 = search_perf()
plot(perf_result2)
perf_summary = c(min(perf_result$value), max(perf_result$value), mean(perf_result$value), fivenum(perf_result$value))
plot(perf_result$value,type="l")
perf_summary
perf_result


# 알람
a1 = read.csv('alarm_set.csv')
data = a1
data$심각도 = factor(data$심각도, levels = c("심각", "경고", "주의"))

head(data)
node = data[grep("hlldonline>online_S101", data$대상),]
result = node[grep("CPU 사용률", node$알람.이름),]
result = node[grep("디스크", node$알람.이름),]
result = node[grep("JVM Heap 사용률", node$알람.이름),]
JVM.Heap.사용률
result
result = result[c(1,3,4)]
result[result == ""] = NA
colnames(result) = c("degree","time","recover_time")
#result$time = as.POSIXct(result$time, format = "%Y-%m-%d %H:%M:%S")
result$time = as.POSIXlt(result$time)
result$recover_time = as.POSIXlt(result$recover_time)
#result$time = as.POSIXct(result$time, origin="1970-01-01")
result$time$sec = 0
result$recover_time$sec = 0

#시간 선택
perf_result
perf_result = subset(perf_result,select=c(1,2), time>='2018-08-21 18:00:00')
result= subset(result,select=c(1,2,3), time>='2018-08-21')
result
perf_result$time = as.POSIXct(perf_result$time, format = "%Y-%m-%d %H:%M:%S")

result$time = as.POSIXct(result$time, format = "%Y-%m-%d %H:%M:%S")
result$recover_time = as.POSIXct(result$recover_time, format = "%Y-%m-%d %H:%M:%S")
tail(perf_result$time)
tail(result$time)
result_alarm = inner_join(perf_result,result)
inner_join(perf_result, result)
result_alarm$subtime=substr(result_alarm$time,12,16)
result_alarm$subretime=substr(result_alarm$recover_time,12,16)

write.csv(result_alarm,file='hlldonline.csv')

result_alarm

pc1 = ggplot(data=result_alarm, aes(x=time, y=value,group=1))
pc2 = pc1+geom_line(data=perf_result,aes(x=time, y=value,group=2),color="skyblue2")+geom_segment(aes(x=time, y=value,group=3,xend=recover_time,yend=value),size=0.5,arrow=arrow(length=unit(0.20,"cm"),ends='last',type = "closed"))+geom_point(aes(x=time, y=value,group=3),color="red",size=5,shape=18)
pc2
pc3 = pc2
pc3

pc1 = ggplot(data=result_alarm, aes(x=time, y=value,group=1))
pc2 = pc1+geom_line(data=perf_result,aes(x=time, y=value,group=2),color="skyblue2")+geom_segment(aes(x=time, y=value,group=3,xend=recover_time,yend=value),size=0.5,arrow=arrow(length=unit(0.20,"cm"),ends='last',type = "closed"))+geom_point(aes(x=time, y=value,group=3),color="red",size=5,shape=18)+geom_text(aes(label = subtime,group=3),hjust=0.5,vjust=-1,size=3)
pc3 = pc2 +geom_text(aes(label = subretime,group=4),hjust=0.5,vjust=2,size=3)
pc3


alarm_diff = function(node_name,am_name) {
  node = data[grep(node_name, data$대상),]
  result = node[grep(am_name, node$알람.이름),]
  result = result[c(1,3,4)]
  result[result == ""] = NA
  colnames(result) = c("degree","time","recover_time")
  result$time = as.POSIXlt(result$time)
  result$recover_time = as.POSIXlt(result$recover_time)
  result$time$sec = 0
  result$recover_time$sec = 0
  result$time = as.POSIXct(result$time, format = "%Y-%m-%d %H:%M:%S")
  result$recover_time = as.POSIXct(result$recover_time, format = "%Y-%m-%d %H:%M:%S")
  result$diff = result$recover_time - result$time
  result$diff = as.numeric(result$diff)
  diff = na.omit(result$diff)
  write.csv(result,file=paste(node_name, ".csv", sep=""))
  resultsa = list(c(min(diff), max(diff), mean(diff), fivenum(diff)))
  return(resultsa)
}
top_1 = read.csv("top1.csv")
top_1_list = top_1[c(2)]

top_2 = read.csv("top2.csv")
top_2_list = top_2[c(2)]

top_3 = read.csv("top3.csv")
top_3_list = top_3[c(2)]

top_4 = read.csv("top4.csv")
top_4_list = top_4[c(2)]

top_5 = read.csv("top5.csv")
top_5_list = top_5[c(2)]

node_names = top_1_list[1:100,]

alarm_static_list = list()
for (i in 1:100) {
  node_name = top_1_list[i,]
  alarm_diff_result = alarm_diff(node_name,"디스크")
  alarm_static_list = append(alarm_static_list, list(alarm_diff_result))
}
alarm_static_list
write.csv(alarm_static_list,file="alarm_static_list.csv",row.names=FALSE)
names(alarm_static_list) = node_names
for (i in 1:5) {
  node_name = top_2_list[i,]
  alarm_diff_result = alarm_diff(node_name,"온도")
  write.csv(alarm_diff_result,file=paste(node_name, "_diff_result.csv", sep=""))
}

for (i in 1:5) {
  node_name = top_3_list[i,]
  alarm_diff_result = alarm_diff(node_name,"로그.감시")
  write.csv(alarm_diff_result,file=paste(node_name, "_diff_result.csv", sep=""))
}

for (i in 1:5) {
  node_name = top_4_list[i,]
  alarm_diff_result = alarm_diff(node_name,"CPU.사용률")
  write.csv(alarm_diff_result,file=paste(node_name, "_diff_result_top4.csv", sep=""))
}

for (i in 1:5) {
  node_name = top_5_list[i,]
  alarm_diff_result = alarm_diff(node_name,"JVM.Heap.사용률")
  write.csv(alarm_diff_result,file=paste(node_name, "_diff_result_top5.csv", sep=""))
}

result_alarm
alarm_diff_result = alarm_diff("hk-pcsec01","디스크")
alarm_diff_result



write.csv(result,'result2.csv')
result$diff = result$recover_time - result$time
result
result$diff = as.numeric(result$diff)
diff = na.omit(result$diff)
diff = as.numeric(diff)
str(diff)
mean(diff)
max(diff)
quantile(diff)
hist(diff)
boxplot(diff)
plot(result$diff)
median(diff)
result$time[2]
result
which(result$diff == max(diff))
subset(result,result$diff == 5975)
result[subset(result,result$diff == max(diff))]
result$diff[3758]
result_alarm

result_alarm
perf_result
perf_result
#1분
pc1 = ggplot(data=result_alarm, aes(x=time, y=value,group=1))
pc2 = pc1+geom_line(data=perf_result,aes(x=time, y=value,group=2),color="skyblue2")+geom_segment(aes(x=time, y=value,group=3,xend=recover_time,yend=value),size=0.5,arrow=arrow(length=unit(0.20,"cm"),ends='last',type = "closed"))+geom_point(aes(x=time, y=value,group=3),color="red",size=5,shape=18)+geom_text(aes(label = subtime,group=3),hjust=0.5,vjust=-1,size=3)
pc3 = pc2 +geom_text(aes(label = subretime,group=4),hjust=0.5,vjust=2,size=3)
pc3
#5분
pc1 = ggplot(data=result_alarm, aes(x=time, y=value,group=1))
pc2 = pc1+geom_line(data=test,aes(x=time, y=value,group=2),color="skyblue2")+geom_segment(aes(x=time, y=value,group=3,xend=recover_time,yend=value),size=0.5,arrow=arrow(length=unit(0.20,"cm"),ends='last',type = "closed"))+geom_point(aes(x=time, y=value,group=3),color="red",size=5,shape=5)
pc2








# 분/시간 알람 빈도수result$ct = as.POSIXct(result$time)
result
result$midnight = strptime(paste(strftime(result$ct, format = "%Y-%m-%d"), "00:00:00"), format = "%Y-%m-%d %H:%M:%S")
head(result)

result$seconds = as.numeric(result$ct) - as.numeric(result$midnight)
result$break1m = ceiling(result$seconds / (60))
result

break10 = result[,-c(2,6,7)] %>%
  group_by(break1m) %>%
  summarize(N=n())
plot(break10,type='l')
