SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0011" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
  /* OBJTYPE          IN      VARCHAR2,
   OBJID            IN      VARCHAR2*/
   GRPID            IN      VARCHAR2,
    PV_STATUS      IN       VARCHAR2
   )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
/*   V_OBJTYPE            VARCHAR2(1);
   V_OBJID              VARCHAR2(50);
*/ 
   V_STATUS                VARCHAR2 (10);
   V_STRGRPID          VARCHAR2(50);
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

        IF (GRPID <> 'ALL')
    THEN
        V_STRGRPID := GRPID;
    ELSE
        V_STRGRPID := '%%';
    END IF;
   IF(PV_STATUS <> 'ALL')
   THEN
        V_STATUS  := PV_STATUS;
   ELSE
        V_STATUS  := '%%';
   END IF;
   -- END OF GETTING REPORT'S PARAMETERS


        OPEN PV_REFCURSOR
        FOR
            SELECT rl.OBJTYPE, rl.OBJID, rl.AUTHID, TLG.GRPNAME authname, rl.cmdcode, rl.cmdname, rl.cmdtype, rl.chgtype,
                   rl.oldvalue, rl.newvalue, rl.chgtlid, TL2.TLNAME CHGTLNAME, rl.chgtime,rl.odrnum, rl.busdate,RL.AREA,RL.BACK
            FROM
                (-- thay doi quyen cua nhom
                SELECT TA.*, A.AREA,A.BACK
                FROM
                    (SELECT TB.OBJTYPE, TB.OBJID, TB.AUTHID,replace(TB.cmdcode, '#R') cmdcode, TB.cmdname,  TB.cmdtype, TB.chgtype,
                          fn_get_changtypesa0011( TB.oldvalue,TB.cmdtype) oldvalue,
                          fn_get_changtypesa0011( TB.newvalue,TB.cmdtype) newvalue,
                          TB.chgtlid,TB.chgtime,TB.odrnum,TB.busdate
                     FROM
                        (SELECT 'G' objtype, V_STRGRPID OBJID, rl.AUTHID, rl.cmdcode, aun.cmdname,
                                decode(rl.logtable,'TLAUTH',rl.cmdtype||rl.tltype,rl.cmdtype) cmdtype,
                                CASE WHEN rl.newvalue = 'D' THEN 'D'
                                     WHEN rl.oldvalue IS NULL AND rl.newvalue IS NOT NULL THEN 'A'
                                    ELSE 'E' END chgtype,
                                rl.oldvalue, rl.newvalue,rl.chgtlid, to_char(rl.chgtime,'dd/mm/yyyy hh:mi:ss') chgtime,
                                decode(rl.cmdtype,'M','1','T','2','G','3','R','4') odrnum, to_char(rl.busdate,'dd/mm/yyyy') busdate
                         FROM rightassign_log rl,

                                (SELECT cmd.cmdid, cmd.cmdid || ': ' || cmd.cmdname cmdname, 'M' cmdtype
                                 FROM cmdmenu cmd
                                    UNION ALL
                                SELECT tl.tltxcd cmdid, tl.tltxcd || ': ' || tl.txdesc cmdname, 'T' cmdtype
                                FROM tltx tl
                                    UNION ALL
                                SELECT rpt.rptid cmdid, rpt.rptid || ': ' || rpt.description cmdname, decode(rpt.cmdtype,'R','R','V','G') cmdtype
                                FROM rptmaster rpt) aun,

                                (SELECT * FROM  VW_CMDMENU_ALL_RPT )PT
                           WHERE rl.cmdtype = 'R' AND rl.logtable = 'CMDAUTH' AND rl.cmdcode LIKE '%#R%'
                              AND REPLACE (rl.cmdcode, '#R') = aun.cmdid AND rl.cmdtype = aun.cmdtype AND AUN.CMDID=PT.CMDID(+)
                              AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                              AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                              AND rl.AUTHID LIKE V_STRGRPID)TB
                          UNION ALL
                     SELECT TA.OBJTYPE, TA.OBJID, TA.AUTHID,TA.cmdcode, TA.cmdname,TA.cmdtype, TA.chgtype,
                            fn_get_changtype( TA.oldvalue,TA.cmdtype) oldvalue, fn_get_changtype( TA.newvalue,TA.cmdtype) newvalue,
                            TA.chgtlid,TA.chgtime,TA.odrnum,TA.busdate
                     FROM
                        (SELECT 'G' OBJTYPE, V_STRGRPID OBJID, rl.AUTHID, rl.cmdcode, aun.cmdname, decode(rl.logtable,'TLAUTH',rl.cmdtype||rl.tltype,rl.cmdtype) cmdtype,
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
                            FROM rptmaster rpt) aun,

                            (SELECT * FROM  VW_CMDMENU_ALL_RPT )PT

                        WHERE rl.authtype = 'G' AND rl.logtable in ('CMDAUTH', 'TLAUTH')
                            AND (rl.oldvalue IS NOT NULL OR rl.newvalue IS NOT null)  AND NVL(PT.LAST,'Y')='Y'
                            AND rl.cmdcode = aun.cmdid AND rl.cmdtype = aun.cmdtype AND AUN.CMDID=PT.CMDID(+)
                            AND (CASE WHEN RL.CMDTYPE='M' AND RL.OLDVALUE IS NOT NULL AND LENGTH(RL.OLDVALUE)<=6 THEN 'NN'
                                      ELSE NVL(rl.strauth,'YY') END)<> 'NN'
                            AND to_date(F_DATE,'dd/mm/yyyy') <= rl.busdate
                            AND to_date(T_DATE,'dd/mm/yyyy') >= rl.busdate
                            AND rl.AUTHID LIKE V_STRGRPID) TA )TA
                LEFT JOIN
                 (SELECT CMDTYPE,AUTHID,CMDCODE, AREA,(CASE WHEN CMDTYPE='M' THEN '' WHEN CMDTYPE='R' THEN '' ELSE BACK END) BACK
                 FROM
                    (SELECT  AU.CMDTYPE ,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','Có','Không')) BACK, AU.AUTHID,AU.CMDCODE,A1.CDCONTENT AREA
                     FROM CMDAUTH AU ,ALLCODE A1
                    WHERE  A1.CDTYPE='SY'
                        AND AU.authtype = 'G'
                        AND A1.CDNAME='RIGHTSCOPE'
                        AND A1.CDVAL=AU.RIGHTSCOPE
                        AND AU.AUTHID LIKE V_STRGRPID
                   GROUP BY  AU.AUTHID,AU.CMDCODE,A1.CDCONTENT, AU.CMDTYPE) ) A
                ON TA.AUTHID=A.AUTHID AND TA.CMDCODE=A.CMDCODE) rl,
                (SELECT TLG.grpid, TLG.grpid || ': ' || TLG.grpname GRPNAME FROM TLGROUPS TLG WHERE TLG.GRPTYPE='1' and tlg.active like v_status) TLG,
                 (SELECT TL.tlid, TL.tlid || ': ' || TL.tlname tlNAME FROM tlprofiles TL where tl.active like v_status) TL2
            WHERE RL.AUTHID = TLG.GRPID
            AND RL.chgtlid = TL2.TLID
            ORDER BY rl.authid, rl.chgtime, rl.odrnum, rl.cmdcode, rl.chgtype;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE
 
 
 
 
/
