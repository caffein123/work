#패키지 설치

pkgFilenames <- read.csv("packages/pkgFilenames.csv", stringsAsFactors = FALSE)[, 1]
install.packages(pkgFilenames, repos = NULL, type = "win.binary")

library('ggplot2')
library('dplyr')

a1 = read.csv('../alarm/alarm.csv')
a2 = read.csv('../alarm/alarm2.csv')
a3 = read.csv('../alarm/alarm3.csv')
a4 = read.csv('../alarm/alarm4.csv')
a5 = read.csv('../alarm/alarm5.csv')
a6 = read.csv('../alarm/alarm6.csv')
a7 = read.csv('../alarm/alarm7.csv')
a8 = read.csv('../alarm/alarm8.csv')
data  = rbind(a1,a2,a3,a4,a5,a6,a7,a8)

data$심각도 = factor(data$심각도, levels = c("심각", "경고", "주의"))
node = table(data$시스템명)
node = sort(node,decreasing = T)
write.csv(names(node),file = "node.csv")
names(node)[1]
data[grep(i, data$시스템명),]
for (i in names(node)) {
  = data[grep(i, data$시스템명),]
}
#컨디션 로그
alarm_condition_df = data[grep("이벤트 탐지", data$컨디션.로그),]
alarm_condition = table(alarm_condition_df$컨디션.로그)
alarm_condition = sort(alarm_condition,decreasing = T)
head(alarm_condition,5)

summary(data)
alarm_name = table(data$알람.이름)
# 그룹별 알람
group_table = table(data$그룹경로)

group_table
group_table = sort(group_table,decreasing = T)
length(group_table)
head(group_table)
write.csv(group_table, file='group_table2.csv')
group_detail_df = read.csv('group_table.csv')
group_detail_list = group_detail_df[c(2)]
N = nrow(group_detail_df)
group_name
rm(test_list)
test_list = list()
test_list_all = test_list
test_list_all
for (i in 1:N) {
  group_name = group_detail_list[i,]
  group_df = data[grep(group_name, data$그룹),]
  group_alarm_table = table(group_df$알람.이름)
  top_group_alram_detail = head(sort(group_alarm_table,decreasing = T),1)
  test_list= append(top_group_alram_detail,test_list)
}

help(grep)
length(test_list)
test_list[1]
testtest22
test_list
write.csv(test_list, file='test_list2.csv')
group_name = group_detail_list[3,]
rm(test_list)
test_list=list()
group_detail_list[3,]
for (i in 1:N) {
  group_name = group_detail_list[i,]
  select_table = subset(data, select = c(1:6), data$그룹==group_name)
  alarm_group_cnt= nrow(subset(data, select = c(1:6), data$그룹==group_name))
  group_alarm_table = table(select_table$알람.이름)
  top_group_alram_detail = head(sort(group_alarm_table,decreasing = T),1)
  test_list= append(top_group_alram_detail,test_list)
}
alarm_group_cnt
test_list

group_df = data[grep("흥국화재>서버>장기TM", data$그룹, fixed=TRUE),]
subset(data, select = c(1:6), data$그룹=="흥국생명>서버>부채 Cash flow 산출시스템(모세스 서버)")
select_table = subset(data, select = c(1:6), data$그룹=="흥국생명>서버>부채 Cash flow 산출시스템(모세스 서버)")
group_alarm_table = table(select_table$알람.이름)
group_alarm_table
head(sort(group_alarm_table,decreasing = T),1)
#알람 이름별 발생 건수 -------

sort_alarm_name = sort(alarm_name,decreasing = T)
sort_alarm_name
write.csv(sort_alarm_name, file='sort_alarm_name.csv')
sort_alarm_name.df = read.csv(file='sort_alarm_name.csv')



barplot(sort_alarm_name, ylim = c(0,90000), col='lightblue',main="알람 종류 별 건 수")
abline(h=mean(sort_alarm_name.df$Freq), col = "red")

lbl = paste(names(sort_alarm_name), ", ", round(sort_alarm_name/sum(sort_alarm_name) * 
                                                  100), "%", sep = "")
pie(sort_alarm_name[1:10], labels = lbl)
head_alarm_name = sort_alarm_name[1:10]
head_alarm_name
max(head_alarm_name)
barplot(sort_alarm_name[1:5]/sum(sort_alarm_name), cex.names = 0.7, ylim =c(0,0.2),col = "lightblue",main="발생 알람 비율")
barplot(sort_alarm_name[1:5],cex.names = 0.7, ylim =c(0,35000),col ="lightblue")

#심각도 파이 -------
par(mfcol = c(1, 2))
alarm_degree_table = table(data$심각도)
alarm_degree_table = alarm_degree_table/sum(alarm_degree_table) * 100

lbl = paste(names(alarm_degree_table), ", ", round(alarm_degree_table/sum(alarm_degree_table) * 
                                                     100), "%", sep = "")
pie(alarm_degree_table, labels = lbl)

lbl = paste(names(alarm_degree_table), ", ", alarm_degree_table, "건", sep = "")
pie(alarm_degree_table, labels = lbl)

#NEW
write.csv(alarm_degree_table,file = "alarm_degree_table.csv")
alarm_degree_df = read.csv("alarm_degree_table.csv")
ggplot(alarm_degree_df) + geom_rect(aes(fill=version, ymax=ymax, ymin=ymin, xmax=4, xmin=3)) +
  coord_polar(theta="y") + xlim(c(0, 4))

#알람 이름별 심각도 -------
par(mfcol = c(1, 1))

name_degree = xtabs(~알람.이름 + 심각도,data)
#name_degree = xtabs(~심각도 + 알람.이름,data)
name_degree
barplot(name_degree)

write.csv(name_degree,file = "test1.csv")
#rm(list = ls())

name_degree = read.csv('test1.csv')
names(name_degree)[1] = "알람이름"


critical.m = mean(name_degree$심각)
critical.m
major.m= mean(name_degree$경고)
major.m
minor.m = mean(name_degree$주의)

critical_degree.df = data.frame(subset(name_degree,select=c("알람이름","심각"), 심각>critical.m))
major_degree.df = data.frame(subset(name_degree,select=c("알람이름","경고"), 경고>major.m))
minor_degree.df = data.frame(subset(name_degree,select=c("알람이름","주의"), 주의>minor.m))

critical_degree.o = head(critical_degree.df[order(critical_degree.df$심각,decreasing = TRUE),],5)
major_degree.o = head(major_degree.df[order(major_degree.df$경고,decreasing = TRUE),],5)
minor_degree.o = head(minor_degree.df[order(minor_degree.df$주의,decreasing = TRUE),],5)

head(critical_degree.o,10)
head(major_degree.o,20)
head(minor_degree.o,5)

par(mfcol = c(1, 3))
barplot(critical_degree.o$심각,names.arg=critical_degree.o$알람이름,main="심각 등급" ,ylim=c(0,38000),col="red",cex.names = 0.9,las=1)
abline(h=critical.m, col = "black")
barplot(major_degree.o$경고,names.arg=major_degree.o$알람이름,main="경고 등급", ylim=c(0,25000),col="orange",cex.names = 0.9,las=1)
abline(h=major.m, col = "red")
barplot(minor_degree.o$주의,names.arg=minor_degree.o$알람이름,main="주의 등급", ylim=c(0,40000),col="yellow",cex.names = 0.9,las=1)
abline(h=minor.m, col = "red")

# 일별 TOP5 심각도 -------

#날짜별 심각도 -------
par(mfcol = c(1, 1))


date_degree = table(data$발생.시간, data$심각도)
date_degree
#date_degree = xtabs(~발생.시간 + 심각도, data)
date_degree = cbind(date_degree, 총합 = rowSums(date_degree))
date_degree

date_degree
write.csv(date_degree,file = "test.csv")
#rm(list = ls())

date_degree = read.csv('test.csv')
names(date_degree)[1] = "날짜"

total.m = mean(date_degree$총합)
total.m
critical.m = mean(date_degree$심각)
major.m= mean(date_degree$경고)
minor.m = mean(date_degree$주의)

total_degree.df = data.frame(subset(date_degree,select=c("날짜","총합"), 총합>total.m))
critical_degree.df = data.frame(subset(date_degree,select=c("날짜","심각"), 심각>critical.m))
major_degree.df = data.frame(subset(date_degree,select=c("날짜","경고"), 경고>major.m))
minor_degree.df = data.frame(subset(date_degree,select=c("날짜","주의"), 주의>minor.m))

total_degree.o = head(total_degree.df[order(total_degree.df$총합,decreasing = TRUE),],100)
critical_degree.o = head(critical_degree.df[order(critical_degree.df$심각,decreasing = TRUE),])
major_degree.o = head(major_degree.df[order(major_degree.df$경고,decreasing = TRUE),])
minor_degree.o = head(minor_degree.df[order(minor_degree.df$주의,decreasing = TRUE),])

head(total_degree.o)
head(critical_degree.o)
head(major_degree.o)
head(minor_degree.o)

write.csv(head(total_degree.o),file = "date_total_degree.csv")
write.csv(head(critical_degree.o),file = "date_critical_degree.csv")
write.csv(head(major_degree.o),file = "date_major_degree.csv")
write.csv(head(minor_degree.o),file = "date_minor_degree.csv")


par(mfcol = c(1, 1))
barplot(total_degree.o$총합,names.arg=total_degree.o$날짜, ylim=c(0,100),main="전체 등급",col="lightblue",cex.names = 1,las=2)
abline(h=total.m, col = "red")
barplot(critical_degree.o$심각,names.arg=critical_degree.o$날짜, ylim=c(0,600),main="심각 등급",col="red",cex.names = 0.8,las=2)
abline(h=critical.m, col = "black")
barplot(major_degree.o$경고,names.arg=major_degree.o$날짜, ylim=c(0,6000),main="경고 등급",col="orange",cex.names = 0.8,las=2)
abline(h=major.m, col = "red")
barplot(minor_degree.o$주의,names.arg=minor_degree.o$날짜, ylim=c(0,600),main="주의 등급",col="yellow",cex.names = 0.8,las=2)
abline(h=minor.m, col = "red")

date_degree = xtabs(~심각도 + 발생.시간, data)
barplot(date_degree,col = "lightblue")
abline(h=total.m, col = "red")
#날짜별 알람이름 -------
#대상 별 발생 시간

date_alarmname2 = table(data$대상,data$발생.시간)
write.csv(date_alarmname2,file = "test5.csv")
date_alarmname2 = read.csv('test5.csv')
names(date_alarmname2)[1] = "대상"
date_alarmname2


#전체
alarm_Top1=data.frame(대상=date_alarmname2$대상,발생건수=date_alarmname2$X2017.06.21)
alarm_Top1
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$발생건수,decreasing = TRUE),],5)
alarm_Top1_head

alarm_Top2=data.frame(대상=date_alarmname2$대상,발생건수=date_alarmname2$X2017.06.22)
alarm_Top2
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$발생건수,decreasing = TRUE),],5)
alarm_Top2_head

alarm_Top3=data.frame(대상=date_alarmname2$대상,발생건수=date_alarmname2$X2017.06.19)
alarm_Top3
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$발생건수,decreasing = TRUE),],5)
alarm_Top3_head

alarm_Top4=data.frame(대상=date_alarmname2$대상,발생건수=date_alarmname2$X2017.06.20)
alarm_Top4
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$발생건수,decreasing = TRUE),],5)
alarm_Top4_head

alarm_Top5=data.frame(대상=date_alarmname2$대상,발생건수=date_alarmname2$X2017.06.17)
alarm_Top5
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$발생건수,decreasing = TRUE),],5)
alarm_Top5_head

write.csv(head(alarm_Top1_head),file = "alarm_Top1_head2.csv")
write.csv(head(alarm_Top2_head),file = "alarm_Top2_head.csv")
write.csv(head(alarm_Top3_head),file = "alarm_Top3_head.csv")
write.csv(head(alarm_Top4_head),file = "alarm_Top4_head.csv")
write.csv(head(alarm_Top4_head),file = "alarm_Top5_head.csv")

##
#대상별 컨디션 로그
date_alarmname3 = table(data$컨디션.로그,data$발생.시간)

write.csv(date_alarmname3,file = "test6.csv")
date_alarmname3 = read.csv('test6.csv')
names(date_alarmname3)[1] = "상세내용"
date_alarmname3


#전체
alarm_Top1=data.frame(상세내용=date_alarmname3$상세내용,발생건수=date_alarmname3$X2017.06.21)
#alarm_Top1
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$발생건수,decreasing = TRUE),],5)
alarm_Top1_head

alarm_Top2=data.frame(상세내용=date_alarmname3$상세내용,발생건수=date_alarmname3$X2017.06.22)
#alarm_Top2
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$발생건수,decreasing = TRUE),],5)
alarm_Top2_head

alarm_Top3=data.frame(상세내용=date_alarmname3$상세내용,발생건수=date_alarmname3$X2017.06.19)
#alarm_Top3
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$발생건수,decreasing = TRUE),],5)
alarm_Top3_head

alarm_Top4=data.frame(상세내용=date_alarmname3$상세내용,발생건수=date_alarmname3$X2017.06.20)
#alarm_Top4
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$발생건수,decreasing = TRUE),],5)
alarm_Top4_head

alarm_Top5=data.frame(상세내용=date_alarmname3$상세내용,발생건수=date_alarmname3$X2017.06.17)
#alarm_Top5
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$발생건수,decreasing = TRUE),],5)
alarm_Top5_head

write.csv(head(alarm_Top1_head),file = "alarm_Top1_head2.csv")
write.csv(head(alarm_Top2_head),file = "alarm_Top2_head2.csv")
write.csv(head(alarm_Top3_head),file = "alarm_Top3_head2.csv")
write.csv(head(alarm_Top4_head),file = "alarm_Top4_head2.csv")
write.csv(head(alarm_Top4_head),file = "alarm_Top5_head2.csv")

##
head(total_degree.o)
date_alarmname = table(data$알람.이름,data$발생.시간)

write.csv(date_alarmname,file = "test4.csv")
date_alarmname = read.csv('test4.csv')
names(date_alarmname)[1] = "알람이름"
date_alarmname

#전체
alarm_Top1=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.21)
alarm_Top1
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$발생건수,decreasing = TRUE),],5)
alarm_Top1_head

alarm_Top2=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.22)
alarm_Top2
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$발생건수,decreasing = TRUE),],5)
alarm_Top2_head

alarm_Top3=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.19)
alarm_Top3
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$발생건수,decreasing = TRUE),],5)
alarm_Top3_head

alarm_Top4=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.20)
alarm_Top4
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$발생건수,decreasing = TRUE),],5)
alarm_Top4_head

alarm_Top5=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.17)
alarm_Top5
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$발생건수,decreasing = TRUE),],5)
alarm_Top5_head

write.csv(head(alarm_Top1_head),file = "alarm_Top1_head.csv")
write.csv(head(alarm_Top2_head),file = "alarm_Top2_head.csv")
write.csv(head(alarm_Top3_head),file = "alarm_Top3_head.csv")
write.csv(head(alarm_Top4_head),file = "alarm_Top4_head.csv")
write.csv(head(alarm_Top4_head),file = "alarm_Top5_head.csv")

#심각

head(critical_degree.o)

alarm_Top1=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.05.23)
alarm_Top1
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$발생건수,decreasing = TRUE),],5)
alarm_Top1_head

alarm_Top2=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.01)
alarm_Top2
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$발생건수,decreasing = TRUE),],5)
alarm_Top2_head

alarm_Top3=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.04)
alarm_Top3
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$발생건수,decreasing = TRUE),],5)
alarm_Top3_head

alarm_Top4=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.02)
alarm_Top4
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$발생건수,decreasing = TRUE),],5)
alarm_Top4_head

alarm_Top5=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.03)
alarm_Top5
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$발생건수,decreasing = TRUE),],5)
alarm_Top5_head

head(major_degree.o)

alarm_Top1=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.21)
alarm_Top1
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$발생건수,decreasing = TRUE),],5)
alarm_Top1_head

alarm_Top2=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.22)
alarm_Top2
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$발생건수,decreasing = TRUE),],5)
alarm_Top2_head

alarm_Top3=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.19)
alarm_Top3
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$발생건수,decreasing = TRUE),],5)
alarm_Top3_head

alarm_Top4=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.20)
alarm_Top4
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$발생건수,decreasing = TRUE),],5)
alarm_Top4_head

alarm_Top5=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.06.17)
alarm_Top5
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$발생건수,decreasing = TRUE),],5)
alarm_Top5_head

#주의
head(minor_degree.o)

alarm_Top1=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.04.05)
alarm_Top1
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$발생건수,decreasing = TRUE),],5)
alarm_Top1_head

alarm_Top2=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.04.22)
alarm_Top2
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$발생건수,decreasing = TRUE),],5)
alarm_Top2_head

alarm_Top3=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.04.14)
alarm_Top3
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$발생건수,decreasing = TRUE),],5)
alarm_Top3_head

alarm_Top4=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.05.24)
alarm_Top4
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$발생건수,decreasing = TRUE),],5)
alarm_Top4_head

alarm_Top5=data.frame(알람이름=date_alarmname$알람이름,발생건수=date_alarmname$X2017.08.04)
alarm_Top5
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$발생건수,decreasing = TRUE),],5)
alarm_Top5_head

#대상별 심각도 ------
server_degree = table(data$심각도,data$대상)
barplot(server_degree,col = "lightblue", ylim = c(0,35000))
abline(h=total.m, col = "red")

date_degree = cbind(date_degree, 총합 = rowSums(date_degree))

server_degree = table(data$대상,data$심각도)
#server_degree = table(data$심각도,data$대상)
server_degree = cbind(server_degree, 총합 = rowSums(server_degree))
write.csv(server_degree,file = "test2.csv")
server_degree = read.csv('test2.csv')
names(server_degree)[1] = "대상"

total.m = mean(server_degree$총합)
critical.m = mean(server_degree$심각)
major.m= mean(server_degree$경고)
minor.m = mean(server_degree$주의)

total_degree.df = data.frame(subset(server_degree,select=c("대상","총합"), 총합>total.m))
critical_degree.df = data.frame(subset(server_degree,select=c("대상","심각"), 심각>critical.m))
major_degree.df = data.frame(subset(server_degree,select=c("대상","경고"), 경고>major.m))
minor_degree.df = data.frame(subset(server_degree,select=c("대상","주의"), 주의>minor.m))

total_degree.o = head(total_degree.df[order(total_degree.df$총합,decreasing = TRUE),],100)
critical_degree.o = head(critical_degree.df[order(critical_degree.df$심각,decreasing = TRUE),],100)
major_degree.o = head(major_degree.df[order(major_degree.df$경고,decreasing = TRUE),],100)
minor_degree.o = head(minor_degree.df[order(minor_degree.df$주의,decreasing = TRUE),],100)

head(total_degree.o,100)
head(critical_degree.o,100)
head(major_degree.o)
head(minor_degree.o)

write.csv(total_degree.o,file = "total_degree.csv")
write.csv(critical_degree.o,file = "critical.csv")
write.csv(major_degree.o,file = "major.csv")
write.csv(minor_degree.o,file = "minor.csv")


barplot(total_degree.o$총합,names.arg=total_degree.o$대상, ylim=c(0,40000),main="전체 등급",col="lightblue",cex.names = 0.6,las=1)
abline(h=total.m, col = "red")
barplot(critical_degree.o$심각,names.arg=critical_degree.o$날짜, ylim=c(0,600),main="심각 등급",col="red",cex.names = 0.8,las=2)
abline(h=critical.m, col = "black")
barplot(major_degree.o$경고,names.arg=major_degree.o$날짜, ylim=c(0,6000),main="경고 등급",col="orange",cex.names = 0.8,las=2)
abline(h=major.m, col = "red")
barplot(minor_degree.o$주의,names.arg=minor_degree.o$날짜, ylim=c(0,600),main="주의 등급",col="yellow",cex.names = 0.8,las=2)
abline(h=minor.m, col = "red")


# 서버별 알람이름 -------

server_alarmname = table(data$시스템명,data$알람.이름)
head(server_alarmname)
write.csv(server_alarmname,file = "test3.csv")
server_alarmname = read.csv('test3.csv')
names(server_alarmname)[1] = "대상"

#알람이름 TOP5 확인
head_alarm_name

alarm_Top1=data.frame(대상=server_alarmname$대상,디스크.Top.I.O.처리율=server_alarmname$디스크.Top.I.O.처리율)
alarm_Top1_head = head(alarm_Top1[order(alarm_Top1$디스크.Top.I.O.처리율,decreasing = TRUE),],100)
alarm_Top1_head
alarm_Top2=data.frame(대상=server_alarmname$대상,현재.온도=server_alarmname$현재.온도)
alarm_Top2_head = head(alarm_Top2[order(alarm_Top2$현재.온도,decreasing = TRUE),],100)
alarm_Top2_head
alarm_Top3=data.frame(대상=server_alarmname$대상,로그.감시=server_alarmname$로그.감시)
alarm_Top3_head = head(alarm_Top3[order(alarm_Top3$로그.감시,decreasing = TRUE),],100)
alarm_Top3_head
alarm_Top4=data.frame(대상=server_alarmname$대상,CPU.사용률=server_alarmname$CPU.사용률)
alarm_Top4_head = head(alarm_Top4[order(alarm_Top4$CPU.사용률,decreasing = TRUE),],100)
alarm_Top4_head
alarm_Top5=data.frame(대상=server_alarmname$대상, JVM.Heap.사용률=server_alarmname$JVM.Heap.사용률)
alarm_Top5_head = head(alarm_Top5[order(alarm_Top5$JVM.Heap.사용률,decreasing = TRUE),],100)

write.csv(head_alarm_name,file = "total.csv")
write.csv(alarm_Top1_head,file = "top1.csv")
write.csv(alarm_Top2_head,file = "top2.csv")
write.csv(alarm_Top3_head,file = "top3.csv")
write.csv(alarm_Top4_head,file = "top4.csv")
write.csv(alarm_Top5_head,file = "top5.csv")

# 분/시간 알람 빈도수
data$time = strptime(data$발생.시간 , format = "%Y-%m-%d %H:%M:%S")
data$time
data$ct = as.POSIXct(data$time)
data$midnight = strptime(paste(strftime(data$ct, format = "%Y-%m-%d"), "00:00:00"), format = "%Y-%m-%d %H:%M:%S")

head(data)

data$seconds = as.numeric(data$ct) - as.numeric(data$midnight)
data$break1m = ceiling(data$seconds / (60))

data$break1m

install.packages('dplyr_0.7.5.zip' ,repos=NULL)
library('dplyr')

module = read.csv('ggplot2.csv')

module$x[cnt]

cnt =0
for (i in c(1:10)) {
  cnt = cnt+1
  module$x[cnt]
}

data

data[,-c(10,12)]

break1 = data[,-c(18,20)] %>%
  group_by(break1m) %>%
  summarize(N=n())
plot(break1)
write.csv(break1,file = "break1.csv")
break1
colnames(data)

colnames(data)
