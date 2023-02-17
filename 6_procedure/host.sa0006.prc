SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sa0006 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   AUTHID         IN       VARCHAR2,
   PV_STATUS      IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   12-Oct-12  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_STRAUTHID         VARCHAR2 (6);
   V_STRGRPID              VARCHAR2 (6);
   V_STRGRPNAME            VARCHAR2 (500);
   V_STRACTIVE             VARCHAR2 (6);
   V_STRDESCRIPTION        VARCHAR2 (500);
   V_STRCOU                VARCHAR2 (6);
   V_STRGRPTYPE            VARCHAR2 (50);
    V_STATUS                VARCHAR2 (500);


 PV_CUR      PKG_REPORT.REF_CURSOR;
BEGIN

   V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

   IF(AUTHID <> 'ALL')
   THEN
        V_STRAUTHID  := AUTHID;
   ELSE
        V_STRAUTHID  := '%%';
   END IF;

/*      V_STRAUTHID:= AUTHID;*/
 IF(PV_STATUS <> 'ALL')
   THEN
        V_STATUS  := PV_STATUS;
   ELSE
        V_STATUS  := '%%';
   END IF;

   -- END OF GETTING REPORT'S PARAMETERS
   OPEN PV_CUR
    FOR
    SELECT TLGR.GRPID, TLGR.GRPNAME, AL2.CDCONTENT ACTIVE, TLGR.DESCRIPTION, COU.COU, AL.CDCONTENT
    FROM TLGROUPS TLGR,(SELECT COUNT(ROWNUM) COU FROM
    ( SELECT DISTINCT TLG.TLID FROM TLGRPUSERS TLG, TLGROUPS TL
         WHERE TLG.GRPID=TL.GRPID  AND  TL.GRPID LIKE V_STRAUTHID AND TL.ACTIVE LIKE V_STATUS) )COU,ALLCODE AL, ALLCODE AL2
    WHERE AL.CDNAME='GRPTYPE' AND  AL.CDTYPE='SA' AND  AL.CDVAL =TLGR.GRPTYPE
     and AL2.CDNAME='YESNO' AND  AL2.CDTYPE='SY' AND  AL2.CDVAL =TLGR.ACTIVE
      AND TLGR.ACTIVE LIKE V_STATUS
        AND TLGR.GRPID LIKE V_STRAUTHID;
LOOP
FETCH PV_CUR
   INTO V_STRGRPID,V_STRGRPNAME,V_STRACTIVE,V_STRDESCRIPTION ,V_STRCOU,V_STRGRPTYPE;
  EXIT WHEN PV_CUR%NOTFOUND;

END LOOP;
    OPEN PV_REFCURSOR
    FOR
        SELECT V_STRAUTHID GRPID,V_STRGRPNAME GRPNAME,V_STRACTIVE ACTIVE,V_STRDESCRIPTION DESCRIPTION,V_STATUS STATUS1,
            V_STRCOU COUNT,V_STRGRPTYPE TYPEGROUP,DT.*
        FROM
            (
                 -- QUYEN CHUC NANG
                SELECT max(me.modcode) modcode, au.cmdcode cmdcode, max(me.lev) lev,
                    max(CASE WHEN instr(me.objname,'GENERALVIEW') > 0 THEN 'G' else me.menutype end) menutype,
                    MAX(au.cmdcode || ': ' || TO_CHAR(ME.CMDNAME))TXNAME,TL.GRPID GRP,TL.GRPNAME TEN,
                    MAX(DECODE(AU.CMDALLOW,'Y','X','')) C1,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') OR SUBSTR(ME.AUTHCODE,2,1) = 'N' THEN '-' ELSE SUBSTR(AU.STRAUTH,1,1) END,'Y','X','-','-','')) C2,
/*                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') OR SUBSTR(ME.AUTHCODE,1,1) = 'N' THEN '-' ELSE SUBSTR(AU.STRAUTH,2,1) END,'Y','X','-','-','')) C3,*/--bo them moi
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') OR SUBSTR(ME.AUTHCODE,3,1) = 'N' THEN '-' ELSE SUBSTR(AU.STRAUTH,3,1) END,'Y','X','-','-','')) C3,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') OR SUBSTR(ME.AUTHCODE,4,1) = 'N' THEN '-' ELSE SUBSTR(AU.STRAUTH,4,1) END,'Y','X','-','-','')) C4,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('R','T') THEN ' ' WHEN ME.MENUTYPE IN ('A','P') OR SUBSTR(ME.AUTHCODE,11,1) = 'N' THEN '-' ELSE SUBSTR(AU.STRAUTH,5,1) END,'Y','X','-','-','')) C5,
                    a1.cdcontent C6,'M' C7, '' C8,1 odrnum, max(SUBSTR(me.CMDID, 1,4)) cmdid,
                    max(CASE WHEN me.menutype = 'T' THEN '2' WHEN me.menutype = 'R' THEN '3'
                            WHEN me.menutype = 'A' AND instr(me.objname,'GENERALVIEW') > 0  THEN '4' ELSE '1' END) CMDTYPE
                FROM CMDMENU ME, CMDAUTH AU, TLGROUPS TL, ALLCODE A1, VW_CMDMENU_ALL_RPT PT
                WHERE ME.CMDID = AU.CMDCODE-- AND to_number(me.lev) >=0
                    AND AU.CMDTYPE ='M' AND ME.MENUTYPE not in ('T','R')
                    AND AU.AUTHTYPE ='G' and ME.last = 'Y'
                    AND ME.CMDID=PT.CMDID
                    AND INSTR(PT.en_cmdname,'General view')=0
                   AND AU.AUTHID LIKE V_STRAUTHID
                    AND TL.ACTIVE LIKE V_STATUS
                    AND AU.AUTHID=TL.GRPID
                    AND A1.CDTYPE='SY'
                    AND A1.CDNAME='RIGHTSCOPE'
                    AND A1.CDVAL=AU.RIGHTSCOPE
                     AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N' OR  AU.STRAUTH<>'NNNN' )
                  -- AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
                GROUP BY AU.CMDCODE,TL.GRPID,TL.GRPNAME, a1.cdcontent
                UNION ALL
                -- QUYEN GIAO DICH
                 SELECT TA.MODCODE,TA.CMDCODE,TA.LEV,TA.MENUTYPE,TA.TXNAME,TA.GRPID GRP ,TA.GRPNAME TEN,TA.C1,NVL(TA.C2,'') C2,NVL(TA.C3,'') C3,NVL(TA.C4,'') C4,
         TA.C5,A.CDCONTENT C6,TA.C7, MAX(DECODE(SUBSTR(A.STRAUTH,1,1),'Y','X',''))  C8,TA.odrnum, TA.CMDID,TA.CMDTYPE

  FROM(SELECT max(am.modcode) modcode, max(me.cmdid) cmdcode, 4 lev, 'T' menutype,
                    TO_CHAR(TA.TLTXCD)||'-'||TO_CHAR(TX.TXDESC) TXNAME,TLG.GRPID ,TLG.GRPNAME,TX.TLTXCD,
                    replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,1,1) = 'Y' THEN DECODE(TA.TLTYPE,'T',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
               /*     MAX(CASE WHEN substr(tlg.grpright,2,1) = 'Y' AND tx.txtype = 'W' THEN DECODE(TA.TLTYPE,'C',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END) C2,*/
                    '' C2,'' C3, '' C4,
                    replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,3,1) = 'Y' THEN DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','') C5,
                 /*   MAX(CASE WHEN substr(tlg.grpright,4,1) = 'Y' THEN DECODE(TA.TLTYPE,'R',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END) C4,*/
                     'T' C7, 2 odrnum, max(SUBSTR(me.CMDID, 1,4)) cmdid, '2' cmdtype
                FROM TLAUTH TA ,TLTX TX, appmodules am, tlgroups tlg,VW_CMDMENU_ALL_RPT PT,
                    (SELECT me.cmdid, me.modcode FROM cmdmenu me WHERE me.menutype = 'T' /*AND to_number(me.lev) >= 0*/) me
                WHERE  TA.TLTXCD =TX.TLTXCD
                    AND TX.TLTXCD=PT.CMDID
                    AND am.txcode = substr(tx.tltxcd,1,2) AND tx.visible = 'Y'
                    AND am.modcode = me.modcode
                     AND TLG.ACTIVE LIKE V_STATUS
                     AND INSTR(PT.en_cmdname,'General view')=0
                    AND ta.AUTHID = tlg.grpid
                    AND NOT EXISTS (
                        SELECT SR.searchcode, SR.tltxcd
                        FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                        WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N'
                            AND NOT EXISTS(SELECT TLTXCD FROM CMDMENU CM WHERE CM.tltxcd IS NOT NULL AND INSTR(CM.tltxcd, TL.tltxcd) > 0)
                            AND tx.tltxcd = SR.tltxcd)
                    AND (tx.DIRECT = 'Y' OR EXISTS(SELECT TLTXCD FROM CMDMENU CM WHERE CM.tltxcd IS NOT NULL AND INSTR(CM.tltxcd, tx.tltxcd) > 0))
                    AND TA.AUTHID LIKE V_STRAUTHID
                    AND TA.AUTHTYPE='G'
                GROUP BY TA.TLTXCD,TX.TXDESC,TLG.GRPID ,TLG.GRPNAME,TX.TLTXCD) TA
                 LEFT JOIN (SELECT * FROM CMDAUTH AU ,ALLCODE A1
                               WHERE AU.CMDTYPE='T'
                                   AND A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                  AND AU.AUTHID LIKE V_STRAUTHID
                    ) A ON TA.GRPID=A.AUTHID AND TA.TLTXCD=A.CMDCODE

         GROUP BY TA.MODCODE,TA.CMDCODE,TA.LEV,TA.MENUTYPE,TA.TXNAME,TA.GRPID,TA.GRPNAME,TA.C1,TA.C2,TA.C3,TA.C4,
         TA.C5,A.CDCONTENT ,TA.C7, TA.odrnum, TA.CMDID,TA.CMDTYPE
                UNION ALL
                -- QUYEN BAO CAO
                  SELECT max(am.modcode) modcode, max(me.cmdid) cmdcode, 4 lev, 'R' menutype,
                    TO_CHAR(RPT.RPTID)||'-'||TO_CHAR(RPT.DESCRIPTION) TXNAME,TL.GRPID GRP, TL.GRPNAME TEN,
                     MAX(DECODE(AU.CMDALLOW,'Y','X','')) C1,--XEM BAO CAO
                    MAX(DECODE(SUBSTR(AU.STRAUTH,2,1),'Y','X','')) C2,--TAO BAO CAO
                    '' C3,'' C4,'' C5, A1.CDCONTENT C6,
                   'R' c7,'' C8, 2 odrnum, max(SUBSTR(me.CMDID, 1,4)) cmdid, '3' cmdtype
                FROM RPTMASTER RPT ,CMDAUTH AU, appmodules am,TLGROUPS TL,ALLCODE A1,
                    (SELECT me.cmdid, me.modcode, me.cmdname FROM cmdmenu me WHERE me.menutype = 'R' AND to_number(me.lev) >= 0) me
                WHERE RPT.RPTID  = AU.CMDCODE
                    AND am.modcode = rpt.modcode
                    AND am.modcode = me.modcode
                    AND AU.AUTHID LIKE V_STRAUTHID
                     AND TL.ACTIVE LIKE V_STATUS
                    AND RPT.CMDTYPE ='R'
                     AND AU.AUTHID=TL.GRPID
                    AND A1.CDTYPE='SY'
                    AND A1.CDNAME='RIGHTSCOPE'
                    AND A1.CDVAL=AU.RIGHTSCOPE
                    AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                    AND AU.AUTHTYPE='G'
                    AND RPT.VISIBLE = 'Y'

                GROUP BY RPT.RPTID,RPT.DESCRIPTION,TL.GRPID,TL.GRPNAME,A1.CDCONTENT
                UNION ALL
                -- QUYEN TRA CUU TONG HOP
                -- QUYEN TRA CUU TONG HOP
               SELECT a.modcode, a.cmdcode, a.lev, a.menutype, A.TXNAME,A.GRP,A.TEN,
                    CASE WHEN a.tltxcd IS NOT NULL AND a.tltxcd <> 'EXEC' THEN NVL(B.C1,'0') ELSE NVL(B.C1,'X') END C1, NVL(B.C2,'') C2,
                    NVL(B.C3,'') C3, NVL(B.C4,'') C4, '' C5, A.C6, 'S' C7,A.C8, 2 odrnum, a.cmdid, '4' cmdtype
                FROM
                    (   -- DANH SACH TRA CUU TONG HOP
                        SELECT AU.AUTHID,max(am.modcode) modcode, max(me.cmdid) cmdcode, 4 lev, 'G' menutype,TL.GRPID GRP,TL.GRPNAME TEN,A1.CDCONTENT C6,
                            max(nvl(sr.tltxcd,'')) tltxcd, MAX(RPT.RPTID ||'-'|| CASE WHEN SR.TLTXCD IS NULL THEN 'VIEW' ELSE SR.TLTXCD END ||': '|| RPT.DESCRIPTION) TXNAME,
                            max(SUBSTR(me.CMDID, 1,4)) cmdid, MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X',''))  C8
                        FROM RPTMASTER RPT ,CMDAUTH AU, search sr, appmodules am,ALLCODE A1, TLGROUPS TL,VW_CMDMENU_ALL_RPT PT,
                            (SELECT me.cmdid, me.modcode, me.cmdname FROM cmdmenu me WHERE me.menutype = 'A' AND instr(me.objname,'GENERALVIEW') > 0 AND to_number(me.lev) >= 0) me
                        WHERE RPT.RPTID = AU.CMDCODE AND SR.SEARCHCODE = RPT.RPTID
                            AND am.modcode = rpt.modcode
                            AND am.modcode = me.modcode
                            AND RPT.CMDTYPE in ('V','D','L') AND rpt.visible = 'Y'
                            AND au.cmdtype = 'G'
                            AND RPT.RPTID=PT.CMDID
                           AND AU.AUTHID LIKE V_STRAUTHID
                            AND TL.ACTIVE LIKE V_STATUS
                            AND AU.AUTHTYPE='G'
                             AND AU.AUTHID=TL.GRPID
                              AND A1.CDTYPE='SY'
                               AND A1.CDNAME='RIGHTSCOPE'
                                AND A1.CDVAL=AU.RIGHTSCOPE
                        GROUP BY AU.AUTHID,AU.CMDCODE,TL.GRPID ,TL.GRPNAME ,A1.CDCONTENT
                   ) A
                    LEFT JOIN
                    (   -- QUYEN GIAO DICH TUONG UNG
                        SELECT TA.AUTHID,TA.TLTXCD CMDCODE, MAX(TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC)) TXNAME,
                            replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,1,1) = 'Y' THEN DECODE(TA.TLTYPE,'T',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
  /*                          MAX(CASE WHEN substr(tlg.grpright,2,1) = 'Y' AND tx.txtype = 'W' THEN DECODE(TA.TLTYPE,'C',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END) C2,
                            MAX(CASE WHEN substr(tlg.grpright,3,1) = 'Y' THEN DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END) C3,
                            MAX(CASE WHEN substr(tlg.grpright,4,1) = 'Y' THEN DECODE(TA.TLTYPE,'R',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END) C4,*/
                            '' C2,'' C3,'' C4,'' C5, 'T' C7, 'U' ATYPE
                        FROM TLAUTH TA ,TLTX TX, tlgroups tlg
                        WHERE  TA.TLTXCD =TX.TLTXCD AND tx.visible = 'Y'
                           AND TA.AUTHID LIKE V_STRAUTHID
                            AND TA.AUTHTYPE='G'
                            AND ta.AUTHID = tlg.grpid
                            AND EXISTS (
                                         SELECT SR.searchcode, SR.tltxcd
                                         FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                         WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                            AND SR.TLTXCD = TL.TLTXCD /*AND TL.DIRECT = 'N'*/ AND TX.tltxcd = SR.tltxcd
                                        )
                        GROUP BY TA.AUTHID,TA.TLTXCD

                    ) B
                    ON A.TLTXCD = B.CMDCODE AND A.AUTHID=B.AUTHID
            ) DT
        order by DT.GRP,dt.cmdid, dt.cmdtype, dt.cmdcode, dt.odrnum, dt.txname
    ;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE

 
 
 
 
/
