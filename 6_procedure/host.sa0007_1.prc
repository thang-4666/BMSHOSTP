SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0007_1" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   OBJTYPE          IN      VARCHAR2,
   OBJID            IN      VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO THAY DOI QUYEN CUA CHI NHANH/ NHOM NSD/ NSD
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   27-FEB-13  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_OBJTYPE            VARCHAR2(1);
   V_OBJID              VARCHAR2(50);
   /*V_STRAUTHID         VARCHAR2 (6);
   V_STRGRPID              VARCHAR2 (6);
   V_STRGRPNAME            VARCHAR2 (500);
   V_STRACTIVE             VARCHAR2 (6);
   V_STRDESCRIPTION        VARCHAR2 (500);
   V_STRCOU                VARCHAR2 (6);
   V_STRGRPTYPE            VARCHAR2 (50);*/


BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
    V_OBJTYPE := OBJTYPE;
    IF (OBJID <> 'ALL')
    THEN
        V_OBJID := substr(OBJID,2);
    ELSE
        V_OBJID := '%%';
    END IF;
   -- END OF GETTING REPORT'S PARAMETERS

    IF V_OBJTYPE = 'B' THEN
        OPEN PV_REFCURSOR
        FOR
        SELECT * FROM(
         SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.brid authid, br.brname authname, '' cmdcode, '' cmdname, 'G' cmdtype,
          (CASE WHEN  FN_GET_GROUPNAME1(rl.oldvalue) IS NOT NULL AND FN_GET_GROUPNAME1(rl.newvalue) IS NULL THEN 'D'
          WHEN FN_GET_GROUPNAME1(rl.oldvalue) IS NULL AND FN_GET_GROUPNAME1(rl.newvalue) IS NOT NULL THEN 'A'
          ELSE 'E' END) chgtype,
                --rl.oldvalue, rl.newvalue,
                FN_GET_GROUPNAME1(rl.oldvalue) oldvalue, FN_GET_GROUPNAME1(rl.newvalue) newvalue,
                rl.chgtlid, TL2.TLNAME CHGTLNAME, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime,
                 '5' odrnum, to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,''BACK
            FROM rightassign_log rl, brgrp br, (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL) TL2
            WHERE rl.logtable in ('BRGRPPARAM')
                AND (FN_GET_GROUPNAME1(rl.oldvalue) IS NOT NULL OR FN_GET_GROUPNAME1(rl.newvalue) IS NOT null)
                AND rl.brid = br.brid
                AND RL.chgtlid = TL2.TLID
                --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                AND rl.brid LIKE V_OBJID)
          WHERE (oldvalue IS NOT NULL OR newvalue IS NOT null)
            ORDER BY brid, chgtime

        ;
    ELSIF V_OBJTYPE = 'G' THEN
        OPEN PV_REFCURSOR
        FOR
            SELECT rl.OBJTYPE, rl.OBJID, rl.AUTHID, TLG.GRPNAME authname, rl.cmdcode, rl.cmdname, rl.cmdtype, rl.chgtype,
                       rl.oldvalue, rl.newvalue, rl.chgtlid, TL2.TLNAME CHGTLNAME, rl.chgtime,rl.odrnum, rl.busdate,RL.AREA,RL.BACK
            FROM
                (
                    -- thay doi quyen cua nhom
                  --  SELECT TA.*,A.AREA,A.BACK
                  SELECT TA.OBJTYPE, TA.OBJID, TA.AUTHID,TA.cmdcode, TA.cmdname,TA.cmdtype, TA.chgtype,
                  fn_get_changtype( TA.oldvalue,TA.cmdtype) oldvalue, fn_get_changtype( TA.newvalue,TA.cmdtype) newvalue,
                  TA.chgtlid,TA.chgtime,TA.odrnum,TA.busdate,A.AREA,A.BACK
                    FROM(SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.AUTHID, rl.cmdcode, aun.cmdname, decode(rl.logtable,'TLAUTH',rl.cmdtype||rl.tltype,rl.cmdtype) cmdtype,
                        CASE WHEN rl.newvalue = 'D' THEN 'D'
                            WHEN rl.oldvalue IS NULL AND rl.newvalue IS NOT NULL THEN 'A'
                            ELSE 'E' END chgtype,
                         decode(rl.logtable,'TLAUTH',to_char(rl.oldvalue,'999,999,999,999,999,999,999,999,999,999'),rl.oldvalue) oldvalue,
                         decode(rl.logtable,'TLAUTH',to_char(decode(rl.newvalue,'D','',rl.newvalue),'999,999,999,999,999,999,999,999,999,999'),decode(rl.newvalue,'D','',rl.newvalue)) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime,
                        decode(rl.cmdtype,'M','1','T','2','G','3','R','4') odrnum, to_char(rl.busdate,'dd/mm/yyyy') busdate
                    FROM rightassign_log rl,
                        (SELECT cmd.cmdid, cmd.cmdid || ': ' || cmd.cmdname cmdname, 'M' cmdtype
                        FROM cmdmenu cmd
                        UNION ALL
                        SELECT tl.tltxcd cmdid, tl.tltxcd || ': ' || tl.txdesc cmdname, 'T' cmdtype
                        FROM tltx tl
                        UNION ALL
                        SELECT rpt.rptid cmdid, rpt.rptid || ': ' || rpt.description cmdname, decode(rpt.cmdtype,'R','R','V','G') cmdtype
                        FROM rptmaster rpt
                        ) aun, VW_CMDMENU_ALL_RPT PT
                    WHERE rl.authtype = 'G' AND rl.logtable in ('CMDAUTH', 'TLAUTH')
                        AND CASE WHEN rl.logtable = 'CMDAUTH' AND rl.cmdtype = 'T' THEN 0 ELSE 1 END = 1
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.cmdcode = aun.cmdid AND rl.cmdtype = aun.cmdtype AND AUN.CMDID=PT.CMDID
                     and NVL(rl.strauth,'YY') NOT IN ('NN','NNNNN','NNNN') AND NVL(RL.OLDVALUE,'YYYYY') NOT LIKE '%YNNNNNA'
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.AUTHID LIKE V_OBJID) TA
                          LEFT JOIN ( SELECT CMDTYPE,AUTHID,CMDCODE, AREA,(CASE WHEN CMDTYPE='M' THEN '' WHEN CMDTYPE='R' THEN '' ELSE BACK END) BACK FROM
                          (SELECT  AU.CMDTYPE ,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','Có','Không')) BACK, AU.AUTHID,AU.CMDCODE,A1.CDCONTENT AREA
                             FROM CMDAUTH AU ,ALLCODE A1
                            WHERE  A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                     AND AU.AUTHID LIKE V_OBJID
                                   GROUP BY  AU.AUTHID,AU.CMDCODE,A1.CDCONTENT, AU.CMDTYPE)
                     ) A ON TA.AUTHID=A.AUTHID AND TA.CMDCODE=A.CMDCODE
                    UNION all
                    -- thay doi NSD cua nhom
               /*     SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.brid cmdcode, br.brname cmdname, 'U' cmdtype, 'E' chgtype,\* rl.oldvalue, rl.newvalue,*\
                    fn_get_username(rl.oldvalue) oldvalue, fn_get_username(rl.newvalue) newvalue,
                     rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                      to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,''BACK
                    FROM rightassign_log rl, brgrp br
                    WHERE rl.authtype = 'G' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.brid = br.brid
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID*/
                        SELECT OBJTYPE,OBJID, AUTHID ,CMDCODE, CMDNAME, CMDTYPE,
                        (CASE WHEN OLDVALUE IS NULL THEN 'EN' ELSE 'EO' END) CHGTYPE, OLDVALUE, NEWVALUE,chgtlid,chgtime,odrnum,busdate,AREA, BACK
                        FROM( SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, OLDVALUE, NEWVALUE,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                        FROM( SELECT  V_OBJTYPE OBJTYPE, V_OBJID OBJID,rl.grpid authid, rl.brid cmdcode, br.brname cmdname, 'U' cmdtype, 'E' chgtype,/* rl.oldvalue, rl.newvalue,*/
                    fn_get_username(rl.oldvalue) oldvalue, fn_get_username(rl.newvalue) newvalue,
                     rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                      to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,''BACK
                    FROM rightassign_log rl, brgrp br
                    WHERE rl.authtype = 'G' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.brid = br.brid(+)
                         AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS NULL
                        UNION ALL
                        SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, OLDVALUE, NEWVALUE,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                        FROM( SELECT  V_OBJTYPE OBJTYPE, V_OBJID OBJID,rl.grpid authid, rl.brid cmdcode, br.brname cmdname, 'U' cmdtype, 'E' chgtype,/* rl.oldvalue, rl.newvalue,*/
                    fn_get_username(rl.oldvalue) oldvalue, fn_get_username(rl.newvalue) newvalue,
                     rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                      to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,''BACK
                    FROM rightassign_log rl, brgrp br
                    WHERE rl.authtype = 'G' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.brid = br.brid(+)
                         AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS  NOT NULL  AND NEWVALUE IS NULL

                          UNION ALL
                          SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, OLDVALUE, '' NEWVALUE,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                          FROM( SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.brid cmdcode, br.brname cmdname, 'U' cmdtype, 'E' chgtype,/* rl.oldvalue, rl.newvalue,*/
                    fn_get_username(rl.oldvalue) oldvalue, fn_get_username(rl.newvalue) newvalue,
                     rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                      to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,''BACK
                    FROM rightassign_log rl, brgrp br
                    WHERE rl.authtype = 'G' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.brid = br.brid(+)
                         AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS  NOT NULL  AND NEWVALUE IS NOT NULL
                          UNION ALL
                          SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, '' OLDVALUE, NEWVALUE ,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                          FROM( SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.brid cmdcode, br.brname cmdname, 'U' cmdtype, 'E' chgtype,/* rl.oldvalue, rl.newvalue,*/
                    fn_get_username(rl.oldvalue) oldvalue, fn_get_username(rl.newvalue) newvalue,
                     rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                      to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,''BACK
                    FROM rightassign_log rl, brgrp br
                    WHERE rl.authtype = 'G' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.brid = br.brid(+)
                         AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS  NOT NULL  AND NEWVALUE IS NOT NULL )
                    UNION all
                    -- thay doi AFTYPE cua nhom
                    SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.brid cmdcode, '' cmdname, 'AF' cmdtype, 'E' chgtype,
                          rl.oldvalue, rl.newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '6' odrnum,
                        to_char(rl.busdate,'dd/mm/yyyy') busdate,''AREA,'' BACK
                    FROM rightassign_log rl
                    WHERE rl.authtype = 'G' AND rl.logtable in ('TLGRPAFTYPE')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID
                ) rl,
                (SELECT TLG.grpid, TLG.grpid || ': ' || TLG.grpname GRPNAME FROM TLGROUPS TLG WHERE TLG.GRPTYPE='2') TLG,
                (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL) TL2
            WHERE RL.AUTHID = TLG.GRPID
                AND RL.chgtlid = TL2.TLID
            ORDER BY rl.authid, rl.chgtime, rl.odrnum, rl.cmdcode, rl.chgtype;
    ELSIF V_OBJTYPE = 'U' THEN
        OPEN PV_REFCURSOR
        FOR
            SELECT rl.OBJTYPE, rl.OBJID, rl.AUTHID, TL.TLNAME authname, rl.cmdcode, rl.cmdname, rl.cmdtype, rl.chgtype,
                   rl.oldvalue, rl.newvalue, rl.chgtlid, TL2.TLNAME CHGTLNAME, rl.chgtime,rl.odrnum, rl.busdate,RL.AREA,RL.BACK
            FROM
                (
                    -- thay doi quyen cua NSD
                   -- SELECT TA.*,A.AREA,A.BACK
                   SELECT TA.OBJTYPE, TA.OBJID, TA.AUTHID,TA.cmdcode, TA.cmdname,TA.cmdtype, TA.chgtype,
                   fn_get_changtype( TA.oldvalue,TA.cmdtype) oldvalue, fn_get_changtype( TA.newvalue,TA.cmdtype) newvalue,
                   TA.chgtlid,TA.chgtime,TA.odrnum,TA.busdate,A.AREA,A.BACK
                    FROM(SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.AUTHID, rl.cmdcode, aun.cmdname, decode(rl.logtable,'TLAUTH',rl.cmdtype||rl.tltype,rl.cmdtype) cmdtype,
                        CASE WHEN rl.newvalue = 'D' THEN 'D'
                            WHEN rl.oldvalue IS NULL AND rl.newvalue IS NOT NULL THEN 'A'
                            ELSE 'E' END chgtype,

                         decode(rl.logtable,'TLAUTH',to_char(rl.oldvalue,'999,999,999,999,999,999,999,999,999,999'),rl.oldvalue) oldvalue,
                         decode(rl.logtable,'TLAUTH',to_char(decode(rl.newvalue,'D','',rl.newvalue),'999,999,999,999,999,999,999,999,999,999'),decode(rl.newvalue,'D','',rl.newvalue)) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime,
                        decode(rl.cmdtype,'M','1','T','2','G','3','R','4') odrnum, to_char(rl.busdate,'dd/mm/yyyy') busdate
                    FROM rightassign_log rl,
                        (SELECT cmd.cmdid, cmd.cmdid || ': ' || cmd.cmdname cmdname, 'M' cmdtype
                        FROM cmdmenu cmd
                        UNION ALL
                        SELECT tl.tltxcd cmdid, tl.tltxcd || ': ' || tl.txdesc cmdname, 'T' cmdtype
                        FROM tltx tl
                        UNION ALL
                        SELECT rpt.rptid cmdid, rpt.rptid || ': ' || rpt.description cmdname, decode(rpt.cmdtype,'R','R','V','G') cmdtype
                        FROM rptmaster rpt
                        ) aun, VW_CMDMENU_ALL_RPT PT
                    WHERE rl.authtype = 'U' AND rl.logtable in ('CMDAUTH', 'TLAUTH')
                        AND CASE WHEN rl.logtable = 'CMDAUTH' AND rl.cmdtype = 'T' THEN 0 ELSE 1 END = 1
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        AND rl.cmdcode = aun.cmdid AND rl.cmdtype = aun.cmdtype AND AUN.CMDID=PT.CMDID
                        and NVL(rl.strauth,'YY') NOT IN ('NN','NNNNN','NNNN') AND NVL(RL.OLDVALUE,'YYYYY') NOT LIKE '%YNNNNNA'
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.AUTHID LIKE V_OBJID) TA
                          LEFT JOIN ( SELECT CMDTYPE,AUTHID,CMDCODE, AREA,(CASE WHEN CMDTYPE='M' THEN '' WHEN CMDTYPE='R' THEN '' ELSE BACK END) BACK FROM
                          (SELECT  AU.CMDTYPE ,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','Có','Không')) BACK, AU.AUTHID,AU.CMDCODE,A1.CDCONTENT AREA
                             FROM CMDAUTH AU ,ALLCODE A1
                            WHERE  A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                  AND AU.AUTHID LIKE V_OBJID
                                   GROUP BY  AU.AUTHID,AU.CMDCODE,A1.CDCONTENT, AU.CMDTYPE)
                     ) A ON TA.AUTHID=A.AUTHID AND TA.CMDCODE=A.CMDCODE
                    UNION all
                    -- thay doi nhom cua NSD
                  /*  SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.cmdtype cmdcode, '' cmdname, 'GU' cmdtype, 'E' chgtype,
                       -- rl.oldvalue, rl.newvalue,
                     FN_GET_GROUPNAME1(rl.oldvalue) oldvalue, FN_GET_GROUPNAME1(rl.newvalue) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                        to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,'' BACK
                    FROM rightassign_log rl
                    WHERE rl.authtype = 'U' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID*/
                        SELECT OBJTYPE,OBJID, AUTHID ,CMDCODE, CMDNAME, CMDTYPE,
                        (CASE WHEN OLDVALUE IS NULL THEN 'EN' ELSE 'EO' END) CHGTYPE, OLDVALUE, NEWVALUE,chgtlid,chgtime,odrnum,busdate,AREA, BACK
                        FROM( SELECT OBJTYPE,OBJID, AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, OLDVALUE, NEWVALUE,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                        FROM(   SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.cmdtype cmdcode, '' cmdname, 'GU' cmdtype, 'E' chgtype,
                       -- rl.oldvalue, rl.newvalue,
                     FN_GET_GROUPNAME1(rl.oldvalue) oldvalue, FN_GET_GROUPNAME1(rl.newvalue) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                        to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,'' BACK
                    FROM rightassign_log rl
                    WHERE rl.authtype = 'U' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS NULL
                        UNION ALL
                        SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, OLDVALUE, NEWVALUE,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                        FROM(   SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.cmdtype cmdcode, '' cmdname, 'GU' cmdtype, 'E' chgtype,
                       -- rl.oldvalue, rl.newvalue,
                     FN_GET_GROUPNAME1(rl.oldvalue) oldvalue, FN_GET_GROUPNAME1(rl.newvalue) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                        to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,'' BACK
                    FROM rightassign_log rl
                    WHERE rl.authtype = 'U' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS  NOT NULL  AND NEWVALUE IS NULL

                          UNION ALL
                          SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, OLDVALUE, '' NEWVALUE,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                          FROM(  SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.cmdtype cmdcode, '' cmdname, 'GU' cmdtype, 'E' chgtype,
                       -- rl.oldvalue, rl.newvalue,
                     FN_GET_GROUPNAME1(rl.oldvalue) oldvalue, FN_GET_GROUPNAME1(rl.newvalue) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                        to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,'' BACK
                    FROM rightassign_log rl
                    WHERE rl.authtype = 'U' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS  NOT NULL  AND NEWVALUE IS NOT NULL
                          UNION ALL
                          SELECT OBJTYPE,OBJID,AUTHID ,CMDCODE, CMDNAME, CMDTYPE, CHGTYPE, '' OLDVALUE, NEWVALUE ,chgtlid,chgtime,odrnum,busdate,NVL(AREA,'')AREA,NVL(BACK,'') BACK
                          FROM(  SELECT V_OBJTYPE OBJTYPE, V_OBJID OBJID, rl.grpid authid, rl.cmdtype cmdcode, '' cmdname, 'GU' cmdtype, 'E' chgtype,
                       -- rl.oldvalue, rl.newvalue,
                     FN_GET_GROUPNAME1(rl.oldvalue) oldvalue, FN_GET_GROUPNAME1(rl.newvalue) newvalue,
                        rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime, '5' odrnum,
                        to_char(rl.busdate,'dd/mm/yyyy') busdate,'' AREA,'' BACK
                    FROM rightassign_log rl
                    WHERE rl.authtype = 'U' AND rl.logtable in ('TLGRPUSERS')
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.grpid LIKE V_OBJID) WHERE OLDVALUE IS  NOT NULL  AND NEWVALUE IS NOT NULL )
                ) rl,
                (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL) TL,
                (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL) TL2
            WHERE rl.AUTHID = tl.tlid AND RL.CMDCODE='2'
                AND RL.chgtlid = TL2.TLID
            ORDER BY rl.authid, rl.chgtime, rl.odrnum, rl.cmdcode, rl.chgtype;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE
 
 
 
 
/
