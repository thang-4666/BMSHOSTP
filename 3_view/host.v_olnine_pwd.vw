SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_OLNINE_PWD
(USERNAME, LOGINPWD, TRADINGPWD)
BEQUEATH DEFINER
AS 
SELECT substr(datasource, INSTR(UPPER(DATASOURCE),'USERNAME')-12,10) USERNAME,
            substr(datasource,INSTR(UPPER(DATASOURCE),'LOGINPWD')-8,6) LOGINPWD,
            substr(datasource,INSTR(UPPER(DATASOURCE),'TRADINGPWD')-8,6) TRADINGPWD
            FROM emaillog em
            WHERE em.templateid IN( '304A','0212','304B','213B')
            AND AUTOID IN (SELECT distinct AUTOID FROM
                                  (select MAX(CREATETIME) CREATETIME,substr(datasource, INSTR(UPPER(DATASOURCE),'USERNAME')-8,6) CUST
                            from emaillog
                            where templateid IN ( '304A','0212','304B','213B')
                            GROUP BY substr(datasource, INSTR(UPPER(DATASOURCE),'USERNAME')-8,6)
                                  ) EM ,
                            EMAILLOG IM
                             WHERE EM.CUST=substr(IM.datasource, INSTR(UPPER(IM.DATASOURCE),'USERNAME')-8,6)
                             AND EM.CREATETIME=IM.CREATETIME and im.templateid IN ( '304A','0212','304B','213B')
                   /*           AND AUTOID IN(select MAX(AUTOID) AUTOID
                            from emaillog
                            where templateid IN ( '304A','0212')
                            GROUP BY substr(datasource, INSTR(UPPER(DATASOURCE),'USERNAME')-8,6)*/
                           )
/
