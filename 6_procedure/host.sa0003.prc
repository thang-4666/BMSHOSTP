SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sa0003 (
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
    V_STRGRPID1              VARCHAR2 (6);
   V_STRGRPNAME            VARCHAR2 (500);
   V_STRACTIVE             VARCHAR2 (6);
   V_STRDESCRIPTION        VARCHAR2 (500);
   V_STRCOU                VARCHAR2 (6);
   V_STRGRPTYPE            VARCHAR2 (500);
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

    FROM TLGROUPS TLGR,(SELECT COUNT(ROWNUM) COU
         FROM ( SELECT DISTINCT TLG.TLID FROM TLGRPUSERS TLG, TLGROUPS TL
         WHERE TLG.GRPID=TL.GRPID  AND  TL.GRPID LIKE V_STRAUTHID AND TL.ACTIVE LIKE V_STATUS) )COU,ALLCODE AL, ALLCODE AL2
    WHERE AL.CDNAME='GRPTYPE' AND  AL.CDTYPE='SA' AND  AL.CDVAL =TLGR.GRPTYPE
        and AL2.CDNAME='YESNO' AND  AL2.CDTYPE='SY' AND  AL2.CDVAL =TLGR.ACTIVE
        AND TLGR.ACTIVE LIKE V_STATUS
        AND TLGR.GRPID LIKE V_STRAUTHID;
LOOP
FETCH PV_CUR
   INTO V_STRGRPID1,V_STRGRPNAME,V_STRACTIVE,V_STRDESCRIPTION ,V_STRCOU,V_STRGRPTYPE;
  EXIT WHEN PV_CUR%NOTFOUND;

END LOOP;

    OPEN PV_REFCURSOR
    FOR
        SELECT V_STRAUTHID GRPID,V_STRGRPNAME GRPNAME,V_STRACTIVE ACTIVE,V_STRDESCRIPTION DESCRIPTION,V_STATUS STATUS1,
            V_STRCOU COUNT,V_STRGRPTYPE TYPEGROUP,DT.*
        FROM
            (
                -- QUYEN CHUC NANG
                SELECT PT.LEV,PT.ODRID,fn_getparentgroupmenu(au.cmdcode,'M',null, 'Y') groupname,TL.GRPID GRP,TL.GRPNAME TEN,  MAX(au.cmdcode || ': ' || TO_CHAR(ME.CMDNAME))TXNAME,
                    MAX(DECODE(AU.CMDALLOW,'Y','X','')) C1,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,1,1) END,'Y','X','')) C2,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,2,1) END,'Y','X','')) C3,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END,'Y','X','')) C4,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,4,1) END,'Y','X','')) C5,
                    MAX(DECODE(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END,'Y','X','')) C6, 'M' C7,
                    A1.CDCONTENT  C8,'' C9
                FROM CMDMENU ME, CMDAUTH AU, TLGROUPS TL,ALLCODE A1, VW_CMDMENU_ALL_RPT PT
                WHERE ME.CMDID = AU.CMDCODE
                    AND AU.CMDTYPE ='M' AND ME.MENUTYPE not in ('T','R')
                    AND AU.AUTHTYPE ='G' and ME.last = 'Y'
                    AND ME.CMDID=PT.CMDID
                   -- AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
                     AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N' OR  AU.STRAUTH<>'NNNN' )
                    and ME.LEV >= 0
                    AND AU.AUTHID=TL.GRPID
                    AND INSTR(PT.en_cmdname,'General view')=0
                    AND A1.CDTYPE='SY'
                    AND A1.CDNAME='RIGHTSCOPE'
                    AND A1.CDVAL=AU.RIGHTSCOPE
                     AND AU.AUTHID LIKE V_STRAUTHID
                     AND TL.ACTIVE LIKE V_STATUS
                GROUP BY PT.LEV,PT.ODRID, AU.CMDCODE,TL.GRPNAME,TL.GRPID,A1.CDCONTENT
                UNION ALL
                -- QUYEN GIAO DICH
           SELECT TA.LEV,TA.ODRID, TA.groupname,TA.GRPID GRP , TA.GRPNAME TEN ,TA.TXNAME,TA.C1,NVL(TA.C2,'') C2, TA.C3, NVL(TA.C4,'') C4, TA.C5,TA.C6,TA.C7,
                 A.CDCONTENT  C8,MAX(DECODE(SUBSTR(A.STRAUTH,1,1),'Y','X',''))  C9
           FROM (  SELECT PT.LEV,PT.ODRID, fn_getparentgroupmenu(TA.TLTXCD,'T',app.modcode, 'Y') groupname,TX.TLTXCD,TLG.GRPID,
                           TO_CHAR(TA.TLTXCD)||'-'||TO_CHAR(TX.TXDESC) TXNAME,TLG.GRPNAME, '' C1,
                           replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                           /*   MAX(DECODE(TA.TLTYPE,'C',to_char(TA.TLLIMIT/1000000),'')) C2,*/   --BO THANH TOAN
                           replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                           /*  MAX(DECODE(TA.TLTYPE,'R',to_char(TA.TLLIMIT/1000000),'')) C4,*/   --BO DUYET RUI RO
                            '' C4,'' C5,'' C6, 'O' C7
                   FROM TLAUTH TA ,TLTX TX, appmodules app, tlgroups tlg, VW_CMDMENU_ALL_RPT PT
                   WHERE  TA.TLTXCD =TX.TLTXCD
                           AND TA.AUTHID LIKE V_STRAUTHID
                           AND TX.TLTXCD=PT.CMDID
                           AND ta.AUTHID = tlg.grpid
                           AND TA.AUTHTYPE='G'
                           AND INSTR(PT.en_cmdname,'General view')=0
                           AND TLG.ACTIVE LIKE V_STATUS
                           and substr(TX.tltxcd,1,2) = app.txcode
                    GROUP BY PT.LEV,PT.ODRID,TA.TLTXCD,TX.TXDESC,app.modcode,TX.TLTXCD,TLG.GRPID,TLG.GRPNAME) TA

                    LEFT JOIN (SELECT * FROM CMDAUTH AU ,ALLCODE A1
                               WHERE AU.CMDTYPE='T'
                                   AND A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                  AND AU.AUTHID LIKE V_STRAUTHID
                    ) A ON TA.GRPID=A.AUTHID AND TA.TLTXCD=A.CMDCODE

             GROUP BY TA.LEV,TA.ODRID,TA.groupname,TA.GRPID, TA.GRPNAME,TA.TXNAME,TA.C1,TA.C2,TA.C3,TA.C4,TA.C5,TA.C6,TA.C7, A.CDCONTENT


                UNION ALL
                -- QUYEN BAO CAO
                SELECT PT.LEV,PT.ODRID, fn_getparentgroupmenu(RPT.RPTID,'R',RPT.modcode, 'Y') groupname, TL.GRPID GRP,TL.GRPNAME TEN,
                    TO_CHAR(RPT.RPTID)||'-'||TO_CHAR(RPT.DESCRIPTION) TXNAME,
                    MAX(DECODE(SUBSTR(AU.STRAUTH,2,1),'Y','X','')) C1,
                    MAX(DECODE(AU.CMDALLOW,'Y','X','')) C2,
                    MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) C3,
                    --MAX(SUBSTR(AU.STRAUTH,3,1)) C4,
                   /* max(a1.cdcontent) c4,*/  '' C4,
                    '' C5,'' C6, 'R' c7, A1.CDCONTENT C8,'' C9
                FROM RPTMASTER RPT ,CMDAUTH AU, ALLCODE A1, TLGROUPS TL,VW_CMDMENU_ALL_RPT PT
                WHERE RPT.RPTID  = AU.CMDCODE
                    AND AU.AUTHID LIKE V_STRAUTHID
                       AND TL.ACTIVE LIKE V_STATUS
                    AND RPT.CMDTYPE ='R'
                    AND RPT.RPTID=PT.CMDID
                    AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                    AND AU.AUTHTYPE='G'
                    AND INSTR(PT.en_cmdname,'General view')=0
                    AND RPT.VISIBLE = 'Y'
                    AND AU.AUTHID=TL.GRPID
                    AND A1.CDTYPE='SY'
                    AND A1.CDNAME='RIGHTSCOPE'
                    AND A1.CDVAL=AU.RIGHTSCOPE
                GROUP BY PT.LEV,PT.ODRID,RPT.RPTID,RPT.DESCRIPTION,RPT.modcode,TL.GRPNAME,TL.GRPID,A1.CDCONTENT
                UNION ALL
                -- QUYEN TRA CUU TONG HOP
                -- QUYEN TRA CUU TONG HOP
                SELECT A.LEV,A.ODRID,fn_getparentgroupmenu(A.CMDCODE,'S',A.modcode, 'Y') groupname,A.GRP,A.TEN,
                    A.TXNAME, NVL(A.C1,'') C1, NVL(B.C2,'') C2, NVL(B.C3,'') C3,
                    NVL(B.C4,'') C4, '' C5, '' C6, 'S' C7, A.C8,NVL(B.C9,'') C9
                FROM
                    (   -- DANH SACH TRA CUU TONG HOP
                        SELECT AU.AUTHID,PT.LEV, PT.ODRID, AU.CMDCODE, RPT.MODCODE, max(nvl(sr.tltxcd,'')) tltxcd,TL.GRPID GRP, TL.GRPNAME TEN,A1.CDCONTENT C8,
                         MAX(RPT.RPTID ||'-'|| CASE WHEN SR.TLTXCD IS NULL THEN 'VIEW' ELSE SR.TLTXCD END ||': '|| RPT.DESCRIPTION) TXNAME,
                           MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) C9, MAX(DECODE(AU.CMDALLOW,'Y','X','')) C1
                        FROM RPTMASTER RPT ,CMDAUTH AU, search sr, TLGROUPS TL, ALLCODE A1, VW_CMDMENU_ALL_RPT PT
                        WHERE RPT.RPTID = AU.CMDCODE AND SR.SEARCHCODE = RPT.RPTID
                            AND RPT.CMDTYPE in ('V','D','L') AND rpt.visible = 'Y'
                            AND au.cmdtype = 'G'
                            AND RPT.RPTID=PT.CMDID
                          AND AU.AUTHID LIKE V_STRAUTHID
                             AND TL.ACTIVE LIKE V_STATUS
                            AND AU.AUTHTYPE='G'
                            AND AU.AUTHID=TL.GRPID
                            AND INSTR(PT.en_cmdname,'General view')=0
                            AND A1.CDTYPE='SY'
                            AND A1.CDNAME='RIGHTSCOPE'
                            AND A1.CDVAL=AU.RIGHTSCOPE
                        GROUP BY AU.AUTHID,PT.LEV,PT.ODRID,AU.CMDCODE, RPT.MODCODE,TL.GRPID , TL.GRPNAME ,A1.CDCONTENT
                   ) A
                    LEFT JOIN
                    (   -- QUYEN GIAO DICH TUONG UNG
                        SELECT TA.AUTHID,TA.TLTXCD CMDCODE, MAX(TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC)) TXNAME,
                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                       /*     MAX(DECODE(TA.TLTYPE,'C',to_char(round(TA.TLLIMIT/1000000,2)),'')) C2,*/
                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                           /* MAX(DECODE(TA.TLTYPE,'R',to_char(round(TA.TLLIMIT/1000000,2)),'')) C4,*/ '' C4,
                            '' C5,'' C6, 'T' C7, 'U' ATYPE, MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X','')) C9
                        FROM TLAUTH TA ,TLTX TX,CMDAUTH AU
                        WHERE  TA.TLTXCD =TX.TLTXCD
                          AND TA.AUTHID=AU.AUTHID
                          AND AU.AUTHTYPE='G'
                          AND TA.TLTXCD=AU.CMDCODE
                          AND TA.AUTHID LIKE V_STRAUTHID
                            AND TA.AUTHTYPE='G'
                            AND EXISTS (
                                         SELECT SR.searchcode, SR.tltxcd
                                         FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                         WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                            AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd
                                        )
                        GROUP BY TA.AUTHID,TA.TLTXCD

                    ) B
                    ON A.TLTXCD = B.CMDCODE AND A.AUTHID=B.AUTHID
               /* UNION ALL
                -- QUYEN LOAI HINH TIEU KHOAN
                SELECT max(fn_getparentgroupmenu(cmd.cmdid,'M',null, 'Y')) groupname,TLG.GRPID GRP, TLG.GRPNAME TEN,
                    MAX(TO_CHAR(GA.AFTYPE)||': '||TO_CHAR(AFT.TYPENAME)) TXNAME,
                    '' C1, '' C2, '' C3, '' C4 ,'' C5,'' C6, 'W' C7,'' C8, '' C9
                FROM TLGRPAFTYPE GA, TLGROUPS TLG, AFTYPE AFT,
                (select * from cmdmenu where objname = 'AFTYPE') cmd
                WHERE TLG.GRPID = GA.GRPID AND GA.AFTYPE = AFT.ACTYPE
                    AND TLG.ACTIVE = 'Y'
                    AND tlg.grpid   LIKE V_STRAUTHID
                GROUP BY GA.AFTYPE,TLG.GRPID, TLG.GRPNAME  */

            ) DT
        order by DT.ODRID --,DT.GRP,DT.C7, DT.TXNAME
    ;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE

 
 
 
 
/
