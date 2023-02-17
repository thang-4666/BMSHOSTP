SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0008" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   TLTXCD         IN       VARCHAR2

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
   V_STRTLTXCD         VARCHAR2 (6);
    V_STRGRPID1              VARCHAR2 (600);
   V_STRGRPNAME            VARCHAR2 (500);
   V_STRCOU                VARCHAR2 (600);

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

 /*  IF(TLTXCD <> 'ALL')
   THEN
        V_STRTLTXCD  := TLTXCD;
   ELSE
        V_STRTLTXCD  := '%%';
   END IF;
*/
 V_STRTLTXCD  := TLTXCD;

   -- END OF GETTING REPORT'S PARAMETERS

  OPEN PV_CUR
    FOR
SELECT TLGR.CDVAL,  MAX(/*TLGR.CDVAL || ': ' || */TO_CHAR(TLGR.txdesc)) TXNAME, COU.COU
    FROM (select tltxcd CDVAL, txdesc, en_txdesc , 1 LSTODR from tltx WHERE VISIBLE='Y'
         UNION ALL
         SELECT CMDID CDVAL,CMDNAME txdesc,CMDNAME en_txdesc , 1 LSTODR FROM CMDMENU WHERE MENUTYPE not in ('T','R')
         UNION ALL
         SELECT RPTID CDVAL, DESCRIPTION txdesc,DESCRIPTION en_txdesc,1 LSTODR FROM RPTMASTER WHERE VISIBLE='Y' AND CMDTYPE in ('V','D','L','R')
         UNION ALL
         SELECT 'ALL' CDVAL,'ALL' txdesc, 'ALL' en_txdesc, -1 LSTODR FROM DUAL)  TLGR,
   (SELECT COUNT(ROWNUM) COU FROM  CMDAUTH WHERE AUTHTYPE='G'  AND  CMDCODE =  V_STRTLTXCD )COU
    WHERE  TLGR.CDVAL = V_STRTLTXCD
    GROUP BY  TLGR.CDVAL,COU.COU  ;
    LOOP
FETCH PV_CUR
INTO V_STRGRPID1,V_STRGRPNAME,V_STRCOU;
  EXIT WHEN PV_CUR%NOTFOUND;

END LOOP;


    OPEN PV_REFCURSOR
    FOR
        SELECT V_STRTLTXCD GRPID,V_STRGRPNAME GRPNAME1,
            V_STRCOU COUNT,DT.*
        FROM
            (
             -- QUYEN CHUC NANG
                SELECT AU.cmdcode,TL.GRPNAME,
                    MAX(au.cmdcode || ': ' || TO_CHAR(ME.CMDNAME))TXNAME,
                    MAX(DECODE(AU.CMDALLOW,'Y','X','')) C1,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,1,1) END,'Y','X','')) C2,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,2,1) END,'Y','X','')) C3,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END,'Y','X','')) C4,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,4,1) END,'Y','X','')) C5,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END,'Y','X','')) C6,
                    A1.CDCONTENT C7,'' C8,'M' C9
                FROM CMDMENU ME, CMDAUTH AU,ALLCODE A1,TLGROUPS TL, VW_CMDMENU_ALL_RPT PT
                WHERE ME.CMDID = AU.CMDCODE
                    AND A1.CDTYPE='SY'
                    AND A1.CDNAME='RIGHTSCOPE'
                    AND A1.CDVAL=AU.RIGHTSCOPE
                    AND TL.GRPID=AU.AUTHID
                    AND AU.CMDTYPE ='M'
                    AND ME.MENUTYPE not in ('T','R')
                    AND AU.AUTHTYPE ='G'
                    AND ME.CMDID=PT.CMDID
                    AND ME.last = 'Y'
                     AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N' OR  AU.STRAUTH<>'NNNN' )
                    --AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
                    AND  ME.LEV >= 0
                    AND AU.cmdcode = V_STRTLTXCD
                GROUP BY AU.CMDCODE,A1.CDCONTENT,TL.GRPNAME
 UNION ALL
        -- QUYEN BAO CAO
                SELECT RPT.RPTID cmdcode,TL.GRPNAME,
                    TO_CHAR(RPT.RPTID)||'-'||TO_CHAR(RPT.DESCRIPTION) TXNAME,
                    MAX(DECODE(SUBSTR(AU.STRAUTH,2,1),'Y','X','')) C1,
                    MAX(DECODE(AU.CMDALLOW,'Y','X','')) C2,
                    MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) C3,
                    '' C4,'' C5,'' C6, A1.CDCONTENT C7,'' C8,'R' C9
                FROM RPTMASTER RPT ,CMDAUTH AU, ALLCODE A1,TLGROUPS TL
                WHERE RPT.RPTID  = AU.CMDCODE
                    AND RPT.CMDTYPE ='R'
                    AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                    AND AU.AUTHTYPE='G'
                    AND RPT.VISIBLE = 'Y'
                    AND A1.CDTYPE='SY'
                    AND A1.CDNAME='RIGHTSCOPE'
                    AND A1.CDVAL=AU.RIGHTSCOPE
                    AND TL.GRPID=AU.AUTHID
                    AND RPT.RPTID = V_STRTLTXCD
                GROUP BY RPT.RPTID,RPT.DESCRIPTION,TL.GRPNAME,A1.CDCONTENT

 UNION ALL
  -- QUYEN TRA CUU TONG HOP
  SELECT A.CMDCODE,A.GRPNAME,A.TXNAME,
                      ''  C1, NVL(B.C2,'') C2,NVL(B.C1,'') C3,
                       NVL(B.C4,'') C4, '' C5,  NVL(B.C3,'') C6, NVL(A.C7,'') C7,  NVL(A.C8,'') C8, 'S' C9
                FROM
                    (   -- DANH SACH TRA CUU TONG HOP
                        SELECT AU.CMDCODE, RPT.MODCODE,TL.GRPID,TL.GRPNAME,
                               MAX(nvl(sr.tltxcd,'')) tltxcd,
                               MAX(RPT.RPTID ||'-'|| CASE WHEN SR.TLTXCD IS NULL THEN 'VIEW' ELSE SR.TLTXCD END ||': '|| RPT.DESCRIPTION) TXNAME,
                               A1.CDCONTENT C7,  MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) C8
                        FROM RPTMASTER RPT ,CMDAUTH AU, search sr, ALLCODE A1, TLGROUPS TL, VW_CMDMENU_ALL_RPT PT
                        WHERE RPT.RPTID = AU.CMDCODE AND SR.SEARCHCODE = RPT.RPTID
                            AND RPT.CMDTYPE in ('V','D','L') AND rpt.visible = 'Y'
                            AND au.cmdtype = 'G'
                            AND TL.GRPID=AU.AUTHID
                            AND RPT.RPTID=PT.CMDID
                            AND A1.CDTYPE='SY'
                            AND A1.CDNAME='RIGHTSCOPE'
                            AND A1.CDVAL=AU.RIGHTSCOPE
                            AND AU.AUTHTYPE='G'
                            AND AU.cmdcode = V_STRTLTXCD
                        GROUP BY AU.CMDCODE, RPT.MODCODE,A1.CDCONTENT,TL.GRPNAME,TL.GRPID
                   ) A
                    LEFT JOIN
                    (   -- QUYEN GIAO DICH TUONG UNG
                        SELECT TA.AUTHID,TA.TLTXCD CMDCODE, MAX(TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC)) TXNAME,
                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                            '' C5,'' C6,'T' C9, 'U' ATYPE
                        FROM TLAUTH TA ,TLTX TX
                        WHERE  TA.TLTXCD =TX.TLTXCD
                            AND TA.TLTXCD =SUBSTR(V_STRTLTXCD,3)
                            AND TA.AUTHTYPE='G'
                            AND EXISTS (
                                         SELECT SR.searchcode, SR.tltxcd
                                         FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                         WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                            AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd
                                        )
                        GROUP BY TA.TLTXCD,TA.AUTHID

                    ) B
                    ON A.TLTXCD = B.CMDCODE AND A.GRPID=B.AUTHID
 UNION ALL
 --QUYEN GIAO DICH
   SELECT TA.CMDCODE,TA.GRPNAME,TA.TXNAME,TA.C1 ,TA.C2,TA.C3,TA.C4,NVL(TA.C5,'') C5,NVL(TA.C6,'') C6,A.CDCONTENT C7,
          MAX(DECODE(SUBSTR(A.STRAUTH,1,1),'Y','X','')) C8,TA.C9
   FROM((   SELECT TA.TLTXCD  cmdcode, TLG.GRPNAME,TLG.GRPID,
                    TO_CHAR(TA.TLTXCD)||'-'||TO_CHAR(TX.TXDESC) TXNAME,
                   '' C1,
                    replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,2,1) = 'Y' AND tx.txtype = 'W' THEN DECODE(TA.TLTYPE,'C',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                  --  MAX(CASE WHEN substr(tlg.grpright,3,1) = 'Y' THEN DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END) C3, duyet DG
                    replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,1,1) = 'Y' THEN DECODE(TA.TLTYPE,'T',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                    replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,4,1) = 'Y' THEN DECODE(TA.TLTYPE,'R',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                    '' C5,   replace(TO_CHAR(MAX(CASE WHEN substr(tlg.grpright,3,1) = 'Y' THEN DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'0') ELSE '' END),'999,999,999,999,999,999,999,999,999,999'),' ','')  C6,
                    'T' C9
                FROM TLAUTH TA ,TLTX TX, appmodules am, tlgroups tlg, VW_CMDMENU_ALL_RPT PT,
                    (SELECT me.cmdid, me.modcode FROM cmdmenu me WHERE me.menutype = 'T' AND to_number(me.lev) >= 0) me
                WHERE  TA.TLTXCD =TX.TLTXCD
                    AND am.txcode = substr(tx.tltxcd,1,2) AND tx.visible = 'Y'
                    AND am.modcode = me.modcode AND TX.TLTXCD=PT.CMDID
                    AND ta.AUTHID = tlg.grpid
                    AND TA.TLTXCD = V_STRTLTXCD
                    AND NOT EXISTS (
                        SELECT SR.searchcode, SR.tltxcd
                        FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                        WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N'
                            AND NOT EXISTS(SELECT TLTXCD FROM CMDMENU CM WHERE CM.tltxcd IS NOT NULL AND INSTR(CM.tltxcd, TL.tltxcd) > 0)
                            AND tx.tltxcd = SR.tltxcd)
                    AND (tx.DIRECT = 'Y' OR EXISTS(SELECT TLTXCD FROM CMDMENU CM WHERE CM.tltxcd IS NOT NULL AND INSTR(CM.tltxcd, tx.tltxcd) > 0))
                    AND TA.AUTHTYPE='G'
                GROUP BY TA.TLTXCD,TX.TXDESC,TLG.GRPNAME,TLG.GRPID ) TA

                 LEFT JOIN (SELECT * FROM CMDAUTH AU ,ALLCODE A1
                            WHERE AU.CMDTYPE='T'
                                   AND A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                   AND AU.CMDCODE = V_STRTLTXCD
                     ) A ON TA.GRPID=A.AUTHID AND TA.CMDCODE=A.CMDCODE)


                     GROUP BY TA.CMDCODE,TA.GRPNAME,TA.TXNAME,TA.C1,TA.C2,TA.C3,TA.C4,TA.C5,TA.C6,A.CDCONTENT,TA.C9
            ) DT
        order by DT.CMDCODE, DT.TXNAME
    ;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE
 
 
 
 
/
