select a.name, 
sum(case when c.resource_type = 'server.ProcessMonitor' then 1 else 0 end) as PROCESS_CNT, 
sum(case when c.resource_type = 'server.LogMonitor' then 1 else 0 end) as LOG_CNT, 
sum(case when (c.resource_type != 'server.ProcessMonitor' and c.resource_type != 'server.LogMonitor') then 1 else 0 end) as ETC_CNT
from 
(select * from cmm_resource
where (resource_type in ('server.ProcessMonitor','server.LogMonitor','server.FileMonitor','server.ConnectTimeMonitorProvider','weburl.WebURLMonitor','server.PingMonitorProvider','server.EventLogMonitor','server.NetstatMonitor','server.RegexLogMonitor') 
or resource_type like '%ScriptCustomMonitor%' 
or resource_type like '%SnmpCustomMonitor%')
and DTIME is null )  c join
(select id, name from cmm_resource where resource_type = 'management.Group' and DTIME is null and parent_resource_id = ( select id from cmm_resource where resource_type = 'management.Group' and parent_resource_id is null)) a
on c.id_ancestry like '%>'||a.id||'>%'
group by a.name;