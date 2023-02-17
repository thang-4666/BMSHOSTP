SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0012" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_GRPID       IN       VARCHAR2

 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (10);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (10);        -- USED WHEN V_NUMOPTION > 0
   V_STRGRPID              VARCHAR2 (10);


BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF(PV_GRPID <> 'ALL')
   THEN
        V_STRGRPID  := '%' || PV_GRPID||'%';
   ELSE
        V_STRGRPID  := '%%';
   END IF;



OPEN PV_REFCURSOR
  FOR
/*
        select DISTINCT FN_GET_GROUPNAME(CHG.GRPID) GRPNAME, PV_GRPID PV_GRPID, CHG.* from (
                select  (regexp_substr(newvalue,'[^,.]+',1, level)) GRPID,fn_get_username(A.CHGTLID)CHGTLID,
                A.CHGTIME,A.BUSDATE, '' oldvalue, fn_get_username(A.GRPID) NEWVALUE,
                (CASE WHEN A.OLDVALUE IS NOT NULL  THEN 'EN' ELSE 'A' END ) CHG_TYPE,'U' PERS
                FROM (SELECT * FROM  rightassign_log where  logtable='TLGRPUSERS' and authtype='U'
                AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                and newvalue is not null ) a
                connect by  regexp_substr(newvalue, '[^,.]+', 1, level) is not NULL
                UNION ALL
                select  (regexp_substr(oldvalue,'[^,.]+',1, level)) GRPID,fn_get_username(A.CHGTLID)CHGTLID,A.CHGTIME,A.BUSDATE,
                 fn_get_username(A.GRPID) oldvalue,'' newvalue,
                (CASE WHEN A.newvalue IS NOT NULL  THEN 'EO' ELSE 'D' END ) CHG_TYPE,'U' PERS
                FROM (SELECT * FROM  rightassign_log where  logtable='TLGRPUSERS' and authtype='U'
                 AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                 and oldvalue is not null ) a
                connect by  regexp_substr(oldvalue, '[^,.]+', 1, level) is not NULL
                union all
                select GRPID,fn_get_username(CHGTLID)CHGTLID,CHGTIME,BUSDATE,fn_get_username(oldvalue) oldvalue,'' newvalue,
                (CASE WHEN newvalue IS NOT NULL  THEN 'EO' ELSE 'D' END ) CHG_TYPE,'G' PERS
                from rightassign_log
                where  logtable='TLGRPUSERS' and authtype='G'
                 AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                and  oldvalue is not null
                union all
                select GRPID,fn_get_username(CHGTLID)CHGTLID,CHGTIME,BUSDATE,'' oldvalue,fn_get_username(newvalue) newvalue,
                (CASE WHEN oldvalue IS NOT NULL  THEN 'EN' ELSE 'A' END ) CHG_TYPE,'G' PERS
                from rightassign_log
                where  logtable='TLGRPUSERS' and authtype='G'
                 AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                and  newvalue is not null
                ) CHG, TLGROUPS TL
        WHERE TO_CHAR(CHG.GRPID) LIKE V_STRGRPID
        AND TRIM(CHG.GRPID)=TL.GRPID AND TL.GRPTYPE='1'
        ORDER BY CHG.GRPID, CHG.BUSDATE,chg.CHGTIME
        ;

*/

        select /*DISTINCT FN_GET_GROUPNAME(CHG.GRPID)*/ CHG.grpid || ': ' || TL.grpname  GRPNAME, PV_GRPID PV_GRPID, CHG.* from (
               select  (regexp_substr(newvalue,'[^,.]+',1, level)) GRPID,fn_get_username(A.CHGTLID)CHGTLID,
                A.CHGTIME,A.BUSDATE, '' oldvalue, fn_get_username(A.GRPID) NEWVALUE,
                (CASE WHEN A.OLDVALUE IS NOT NULL  THEN 'EN' ELSE 'A' END ) CHG_TYPE,'U' PERS
                FROM (SELECT * FROM  rightassign_log where  logtable='TLGRPUSERS' and authtype='U'
                AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                and newvalue is not null ) a
                connect by  regexp_substr(newvalue, '[^,.]+', 1, level) is not NULL
                UNION ALL
                select  (regexp_substr(oldvalue,'[^,.]+',1, level)) GRPID,fn_get_username(A.CHGTLID)CHGTLID,A.CHGTIME,A.BUSDATE,
                 fn_get_username(A.GRPID) oldvalue,'' newvalue,
                (CASE WHEN A.newvalue IS NOT NULL  THEN 'EO' ELSE 'D' END ) CHG_TYPE,'U' PERS
                FROM (SELECT * FROM  rightassign_log where  logtable='TLGRPUSERS' and authtype='U'
                 AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                 and oldvalue is not null ) a
                connect by  regexp_substr(oldvalue, '[^,.]+', 1, level) is not NULL
                union all
                select GRPID,fn_get_username(CHGTLID)CHGTLID,CHGTIME,BUSDATE,fn_get_username(oldvalue) oldvalue,'' newvalue,
                (CASE WHEN newvalue IS NOT NULL  THEN 'EO' ELSE 'D' END ) CHG_TYPE,'G' PERS
                from rightassign_log
                where  logtable='TLGRPUSERS' and authtype='G'
                 AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                and  oldvalue is not null
                union all
                select GRPID,fn_get_username(CHGTLID)CHGTLID,CHGTIME,BUSDATE,'' oldvalue,fn_get_username(newvalue) newvalue,
                (CASE WHEN oldvalue IS NOT NULL  THEN 'EN' ELSE 'A' END ) CHG_TYPE,'G' PERS
                from rightassign_log
                where  logtable='TLGRPUSERS' and authtype='G'
                 AND BUSDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                and  newvalue is not null
                ) CHG, TLGROUPS TL
        WHERE TO_CHAR(CHG.GRPID) LIKE V_STRGRPID
        AND TRIM(CHG.GRPID)=TL.GRPID AND TL.GRPTYPE='1'
        ORDER BY CHG.GRPID, CHG.BUSDATE,chg.CHGTIME
        ;

 EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
