SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0013" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
  /* OBJTYPE          IN      VARCHAR2,
   OBJID            IN      VARCHAR2*/
   AAUTHID            IN      VARCHAR2
   )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
/*   V_OBJTYPE            VARCHAR2(1);
   V_OBJID              VARCHAR2(50);
*/
   V_STRAAUTHID        VARCHAR2(50);
BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
  /*  V_OBJTYPE := OBJTYPE;
    IF (OBJID <> 'ALL')
    THEN
        V_OBJID := substr(OBJID,2);
    ELSE
        V_OBJID := '%%';
    END IF;*/

        IF (AAUTHID <> 'ALL')
    THEN
        V_STRAAUTHID := AAUTHID;
    ELSE
        V_STRAAUTHID := '%%';
    END IF;
   -- END OF GETTING REPORT'S PARAMETERS

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
                    FROM(SELECT 'U' OBJTYPE, V_STRAAUTHID OBJID, rl.AUTHID, rl.cmdcode, aun.cmdname, decode(rl.logtable,'TLAUTH',rl.cmdtype||rl.tltype,rl.cmdtype) cmdtype,
                        CASE WHEN rl.newvalue = 'D' THEN 'D'
                            WHEN rl.oldvalue IS NULL AND rl.newvalue IS NOT NULL THEN 'A'
                            ELSE 'E' END chgtype,

                         decode(rl.logtable,'TLAUTH',replace(to_char(rl.oldvalue,'999,999,999,999,999,999,999,999,999,999'),' ',''),rl.oldvalue) oldvalue,
                         decode(rl.logtable,'TLAUTH',replace(to_char(decode(rl.newvalue,'D','',rl.newvalue),'999,999,999,999,999,999,999,999,999,999'),' ',''),decode(rl.newvalue,'D','',rl.newvalue)) newvalue,
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
                        ) aun, (SELECT * FROM  VW_CMDMENU_ALL_RPT/* WHERE (LAST<>'N' OR MENUTYPE NOT IN ('R','G','T'))*/)PT
                    WHERE rl.authtype = 'U' AND rl.logtable in ('CMDAUTH', 'TLAUTH')
                      --  AND CASE WHEN rl.logtable = 'CMDAUTH' AND rl.cmdtype = 'T' THEN 0 ELSE 1 END = 1
                        AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null) AND NVL(PT.LAST,'Y')='Y'
                        AND rl.cmdcode = aun.cmdid AND rl.cmdtype = aun.cmdtype AND AUN.CMDID=PT.CMDID(+)
                         AND (CASE WHEN RL.CMDTYPE='M' AND RL.OLDVALUE IS NOT NULL AND LENGTH(RL.OLDVALUE)<=6 THEN 'NN'
                          ELSE NVL(rl.strauth,'YY') END)<> 'NN'
                       -- and NVL(rl.strauth,'YY') NOT IN ('NN','NNNNN','NNNN') AND NVL(RL.OLDVALUE,'YYYYY') NOT LIKE '%YNNNNNA'
                        --AND to_date(F_DATE,'dd/mm/yyyy') <= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        --AND to_date(T_DATE,'dd/mm/yyyy') >= to_date(to_char(rl.chgtime,'dd/mm/yyyy'),'dd/mm/yyyy')
                        AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                        AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                        AND rl.AUTHID LIKE V_STRAAUTHID) TA
                          LEFT JOIN ( SELECT CMDTYPE,AUTHID,CMDCODE, AREA,(CASE WHEN CMDTYPE='M' THEN '' WHEN CMDTYPE='R' THEN '' ELSE BACK END) BACK FROM
                          (SELECT  AU.CMDTYPE ,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','Có','Không')) BACK, AU.AUTHID,AU.CMDCODE,A1.CDCONTENT AREA
                             FROM CMDAUTH AU ,ALLCODE A1
                            WHERE  A1.CDTYPE='SY' AND AU.authtype = 'U'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                  AND AU.AUTHID LIKE V_STRAAUTHID
                                   GROUP BY  AU.AUTHID,AU.CMDCODE,A1.CDCONTENT, AU.CMDTYPE)
                     ) A ON TA.AUTHID=A.AUTHID AND TA.CMDCODE=A.CMDCODE
                  ) rl,
                (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL) TL,
                (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL) TL2
            WHERE rl.AUTHID = tl.tlid AND RL.CMDCODE<>'2'
                AND RL.chgtlid = TL2.TLID
            ORDER BY rl.authid, rl.chgtime, rl.odrnum, rl.cmdcode, rl.chgtype;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE

 
 
 
 
/
