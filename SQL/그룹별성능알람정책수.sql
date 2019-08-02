SELECT 그룹명 , count(*) AS 성능정책수 FROM(
SELECT DISTINCT
       GROUP1 AS 그룹명
     , GROUP2 AS 고객사2
     , GROUP3 AS 고객사3
     , CR.PALTFORM_NAME AS hostname
     ,  CASE WHEN CR.SERVICE_NAME = CR.PALTFORM_NAME THEN '' ELSE CR.SERVICE_NAME END AS 인스턴스 -- 서버 하위의  db 인 경우 db 명이 표시됨.
     , CR.RESOURCE_TYPE 리소스타입
     , CR.DISPLAYNAME AS 리소스타입이름
     , CR.NAME AS 하위지표
     , CASE CAD.DTYPE WHEN 'ProxyAlarmDefinition'
          then ( select displayname from CMM_MEASUREMENT_DEF where id = (select MEASUREMENTDEFINITION_ID||'' from CMM_ALARM_DEF where id=CAD.masterdefinition_id )  )
          else (select displayname from CMM_MEASUREMENT_DEF where id =  CAD.MEASUREMENTDEFINITION_ID ) end 관리지표
     , CASE CAD.DTYPE WHEN 'ProxyAlarmDefinition'
          then ( select name from CMM_MEASUREMENT_DEF where id = (select MEASUREMENTDEFINITION_ID||'' from CMM_ALARM_DEF where id=CAD.masterdefinition_id )  )
          else (select name from CMM_MEASUREMENT_DEF where id =  CAD.MEASUREMENTDEFINITION_ID ) end ATTRIBUTE_NAME
     , TH.CLEAR, TH.INFO, TH.MINOR, TH.MAJOR, TH.CRITICAL, TH.DOWN
  FROM CMM_ALARM_DEF CAD
       INNER JOIN (
       SELECT A.*
            , B.ASSETS_NAME
            , B.ASSETS_ID
         FROM (
              SELECT ID
                   , CASE WHEN  INSTR(GROUP_PATH, '>') = 0 THEN GROUP_PATH ELSE SUBSTR(GROUP_PATH, 1, INSTR (GROUP_PATH, '>', 1 ) -1) END AS GROUP1
                   , SUBSTR(GROUP_PATH, INSTR (GROUP_PATH, '>', 1, 1 ) +1, INSTR (GROUP_PATH, '>', 1, 2 ) - INSTR (GROUP_PATH, '>', 1, 1 ) -1) AS GROUP2
                   , SUBSTR(GROUP_PATH, INSTR (GROUP_PATH, '>', 1, 2 ) +1, INSTR (GROUP_PATH, '>', 1, 3 ) - INSTR (GROUP_PATH, '>', 1, 2 ) -1) AS GROUP3
                   , SUBSTR(GROUP_PATH, INSTR (GROUP_PATH, '>', 1, 3 ) +1, INSTR (GROUP_PATH, '>', 1, 4 ) - INSTR (GROUP_PATH, '>', 1, 3 ) -1) AS GROUP4
                   , GROUP_PATH
                   , (
                     SELECT NAME
                       FROM CMM_RESOURCE
                      WHERE Z.PLATFORM_RESOURCE_ID=ID
                   ) PALTFORM_NAME, (
                     SELECT NAME
                       FROM CMM_RESOURCE
                      WHERE Z.SERVICE_RESOURCE_ID=ID
                   ) SERVICE_NAME, Z.NAME, Z.PLATFORM_RESOURCE_ID, Z.DTIME, Z.DTYPE, Z.HOSTNAME, Z.RESOURCE_TYPE, Z.DISPLAYNAME
                FROM (
                      SELECT R.ID
                             ,RP.GROUPPATHNAME AS GROUP_PATH
                             ,R.PLATFORM_RESOURCE_ID
                             ,R.SERVICE_RESOURCE_ID
                             ,R.NAME
                             ,R.DTIME
                             ,R.DTYPE
                             ,R.HOSTNAME
                             ,R.RESOURCE_TYPE
                             ,RT.DISPLAYNAME
                      FROM CMM_RESOURCE R 
                      LEFT JOIN CMM_RESOURCE_TYPE RT ON R.RESOURCE_TYPE = RT.NAME 
                      LEFT JOIN CMM_RESOURCE_PATH RP ON R.RESOURCE_PATH_ID = RP.ID 
                      WHERE DTIME IS NULL
                      ORDER BY R.ID
                   ) Z
            ) A LEFT JOIN (
              SELECT CP.RESOURCE_ID
                   , MAX(CASE WHEN CD.NAME = '자산명' THEN CP.STRINGVALUE END) AS ASSETS_NAME
                   , MAX(CASE WHEN CD.NAME = '자산번호' THEN CP.STRINGVALUE END) AS ASSETS_ID
                FROM CUST_PROPERTY CP
                   , CUST_PROPERTY_DEF CD
               WHERE CD.ID = CP.DEFINITION_ID
                 AND CD.NAME IN ('자산명', '자산번호' )
                 AND CP.STRINGVALUE IS NOT NULL
               GROUP BY CP.RESOURCE_ID
            ) B ON A.PLATFORM_RESOURCE_ID = B.RESOURCE_ID
     ) CR ON CAD.RESOURCE_ID=CR.ID
     INNER JOIN (
       SELECT MAX(CASE WHEN SEVERITY = 0 THEN THRESHOLD_AVAIL||THRESHOLD_NUMERIC||CASE WHEN THRESHOLD_NUMERIC2 IS NOT NULL THEN '-'||THRESHOLD_NUMERIC2 END ||THRESHOLD_STRING END) clear
            , MAX(CASE WHEN SEVERITY = 1 THEN THRESHOLD_AVAIL||THRESHOLD_NUMERIC||CASE WHEN THRESHOLD_NUMERIC2 IS NOT NULL THEN '-'||THRESHOLD_NUMERIC2 END ||THRESHOLD_STRING END) info
            , MAX(CASE WHEN SEVERITY = 2 THEN THRESHOLD_AVAIL||THRESHOLD_NUMERIC||CASE WHEN THRESHOLD_NUMERIC2 IS NOT NULL THEN '-'||THRESHOLD_NUMERIC2 END||THRESHOLD_STRING END) minor
            , MAX(CASE WHEN SEVERITY = 3 THEN THRESHOLD_AVAIL||THRESHOLD_NUMERIC||CASE WHEN THRESHOLD_NUMERIC2 IS NOT NULL THEN '-'||THRESHOLD_NUMERIC2 END||THRESHOLD_STRING END) major
            , MAX(CASE WHEN SEVERITY = 4 THEN THRESHOLD_AVAIL||THRESHOLD_NUMERIC||CASE WHEN THRESHOLD_NUMERIC2 IS NOT NULL THEN '-'||THRESHOLD_NUMERIC2 END||THRESHOLD_STRING END) critical
            , MAX(CASE WHEN SEVERITY = 5 THEN THRESHOLD_AVAIL||THRESHOLD_NUMERIC||CASE WHEN THRESHOLD_NUMERIC2 IS NOT NULL THEN '-'||THRESHOLD_NUMERIC2 END||THRESHOLD_STRING END) down
            , DEFINITION_ID
         FROM CMM_ALARM_DEF_S_CON
        GROUP BY DEFINITION_ID
     ) TH ON CAD.ID=TH.DEFINITION_ID OR CAD.MASTERDEFINITION_ID=TH.DEFINITION_ID
 WHERE CAD.IS_DELETED=0
   AND CR.DTIME IS NULL
   AND CR.resource_type not in ('server.ProcessMonitor','server.LogMonitor','server.FileMonitor','server.ConnectTimeMonitorProvider','weburl.WebURLMonitor','server.PingMonitorProvider','server.EventLogMonitor','server.NetstatMonitor','server.RegexLogMonitor') 
   or resource_type not like '%ScriptCustomMonitor%' 
   or resource_type not like '%SnmpCustomMonitor%'
ORDER BY CR.GROUP1, CR.GROUP2, CR.GROUP3, hostname, 인스턴스, 리소스타입, 리소스타입이름, 하위지표 ASC)
WHERE 그룹명 is not null
GROUP BY 그룹명;