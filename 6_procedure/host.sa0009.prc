SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0009" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   TLTXCD         IN       VARCHAR2,
   AUTHTYPE       IN        VARCHAR2
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
    V_AUTHTYPE            VARCHAR2(1);

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
 V_AUTHTYPE := AUTHTYPE;

   -- END OF GETTING REPORT'S PARAMETERS

  OPEN PV_CUR
    FOR
SELECT TLGR.CDVAL,  MAX(TLGR.CDVAL || ': ' || TO_CHAR(TLGR.txdesc)) TXNAME, COU.COU
    FROM (select tltxcd CDVAL, txdesc, en_txdesc , 1 LSTODR from tltx WHERE VISIBLE='Y'
         UNION ALL
         SELECT CMDID CDVAL,CMDNAME txdesc,CMDNAME en_txdesc , 1 LSTODR FROM CMDMENU WHERE MENUTYPE not in ('T','R')
         UNION ALL
         SELECT RPTID CDVAL, DESCRIPTION txdesc,DESCRIPTION en_txdesc,1 LSTODR FROM RPTMASTER WHERE VISIBLE='Y' AND CMDTYPE in ('V','D','L','R')
         UNION ALL
         SELECT 'ALL' CDVAL,'ALL' txdesc, 'ALL' en_txdesc, -1 LSTODR FROM DUAL)  TLGR,
   (SELECT COUNT(ROWNUM) COU FROM CMDAUTH WHERE AUTHTYPE='U'  AND  CMDCODE =   V_STRTLTXCD )COU
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
SELECT  a.cmdcode, a.txname,A.USER_DN,A.TEN,
                    DECODE(CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END,'Y','X','') c1,
                    DECODE(CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END,'Y','X','') c2,
                    DECODE(CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END,'Y','X','') c3,
                    DECODE(CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END,'Y','X','') c4,
                    DECODE(CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END,'Y','X','') c5,
                    DECODE(CASE WHEN a.uc6 IS NOT NULL THEN a.uc6 ELSE a.gc6 END,'Y','X','') C6,
                    A.C7 c7,C8,NVL(A.C9,'') C9,A.AUTHID,A.GRPID,A.GRPNAME
                FROM
                    (
                        SELECT gr.cmdcode, max(gr.txname) txname,GR.AUTHID,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c1 ELSE '' END) UC1,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c2 ELSE '' END) UC2,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c3 ELSE '' END) UC3,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c4 ELSE '' END) UC4,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c5 ELSE '' END) UC5,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c6 ELSE '' END) UC6,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c1 ELSE '' END) GC1,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c2 ELSE '' END) GC2,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c3 ELSE '' END) GC3,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c4 ELSE '' END) GC4,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c5 ELSE '' END) GC5,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c6 ELSE '' END) GC6,
                            max(C7) C7,nvl(gr.C8,'') C8,'' C9, NVL(GR.USER_DN,'') USER_DN ,NVL(GR.TEN,'') TEN,
                            GR.GRPID,GR.GRPNAME
                        FROM
                            (
                                SELECT AU.AUTHID,au.cmdcode, MAX(au.cmdcode || ': ' || TO_CHAR(ME.CMDNAME))TXNAME, MAX(AU.CMDALLOW) C1,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,1,1) END) C2,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,2,1) END) C3,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END) C4,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,4,1) END) C5,
                                     MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END) C6,
                                      'M' C7, 'U' ATYPE,A1.CDCONTENT C8, TL.TLNAME USER_DN, TL.TLFULLNAME TEN,'' GRPID,''GRPNAME
                                FROM CMDMENU ME,CMDAUTH AU, ALLCODE A1, TLPROFILES TL, VW_CMDMENU_ALL_RPT PT
                                WHERE ME.CMDID = AU.CMDCODE AND ME.CMDID=PT.CMDID
                                    AND AU.AUTHID=TL.TLID
                                    AND AU.CMDTYPE ='M' AND ME.MENUTYPE IN ('M','O','A','P')
                                    AND AU.AUTHTYPE ='U' and ME.last = 'Y'
                                    AND AU.AUTHTYPE =V_AUTHTYPE
                                    AND AU.CMDCODE = V_STRTLTXCD
                                    AND A1.CDTYPE='SY'
                                    AND A1.CDNAME='RIGHTSCOPE'
                                    AND A1.CDVAL=AU.RIGHTSCOPE
                                     AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N' OR  AU.STRAUTH<>'NNNN' )
                                   -- AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
                                GROUP BY AU.CMDCODE,A1.CDCONTENT,AU.AUTHID, TL.TLNAME,TL.TLFULLNAME

                                UNION ALL

                                -- quyen group
                                SELECT AU.AUTHID,au.cmdcode, MAX(au.cmdcode || ': ' || TO_CHAR(ME.CMDNAME))TXNAME,  MAX(AU.CMDALLOW) C1,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,1,1) END) C2,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,2,1) END) C3,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END) C4,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,4,1) END) C5,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END) C6,
                                     'M' C7, 'G' ATYPE,A1.CDCONTENT C8, TLP.TLNAME USER_DN, TLP.TLFULLNAME TEN,TLR.GRPID,TLR.GRPNAME
                                FROM cmdmenu ME ,CMDAUTH AU, allcode a1, TLGROUPS TLR, TLGRPUSERS TLG,
                                     TLPROFILES TLP,BRGRPPARAM BR, VW_CMDMENU_ALL_RPT PT
                                WHERE ME.CMDID = AU.CMDCODE AND ME.CMDID=PT.CMDID
                                     AND AU.CMDTYPE ='M' AND ME.MENUTYPE IN ('M','O','A','P')
                                     AND AU.AUTHTYPE ='G' and ME.last = 'Y'
                                     -- AND V_AUTHTYPE = 'G'
                                     AND AU.AUTHTYPE =V_AUTHTYPE
                                     AND A1.CDTYPE='SY'
                                     AND AU.AUTHID=TLR.GRPID
                                     AND AU.CMDCODE = V_STRTLTXCD
                                     AND A1.CDNAME='RIGHTSCOPE'
                                     AND A1.CDVAL=AU.RIGHTSCOPE
                                      AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N' OR  AU.STRAUTH<>'NNNN' )
                                     --AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
                                     AND TLR.GRPID=TLG.GRPID AND TLP.TLID=TLG.TLID AND BR.BRID=TLP.BRID
                                     AND BR.PARATYPE= 'TLGROUPS' AND BR.PARAVALUE=TLR.GRPID
                                     AND BR.DELTD='N' AND TLR.ACTIVE='Y' AND TLG.GRPID=AU.AUTHID
                                GROUP BY au.cmdcode,A1.CDCONTENT,AU.AUTHID, TLP.TLNAME,TLP.TLFULLNAME,TLR.GRPID,TLR.GRPNAME

                          ) gr
                        GROUP BY gr.cmdcode,GR.C8,GR.USER_DN,GR.TEN,GR.AUTHID,  GR.GRPID,GR.GRPNAME
                            ) a

                -- QUYEN BAO CAO
                UNION ALL

   SELECT  a.cmdcode, a.txname, A.USER_DN,A.TEN,
                    DECODE(CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END,'Y','X','') c1,
                    DECODE(CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END,'Y','X','') c2,
                    DECODE(CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END,'Y','X','') c3,
                    --CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END c4,
                   /* A1.CDCONTENT C4,*/ '' C4,
                    DECODE(CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END,'Y','X','') c5,
                    NVL(C6,'') C6, A.C7, a.C8,NVL(A.C9,'') C9,A.AUTHID,A.GRPID,A.GRPNAME
                FROM
                    (
                        SELECT gr.cmdcode, GR.MODCODE, max(gr.txname) txname,GR.AUTHID,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c1 ELSE '' END) UC1,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c2 ELSE '' END) UC2,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c3 ELSE '' END) UC3,
                            MIN(CASE WHEN gr.atype = 'U' THEN gr.c4 ELSE '' END) UC4,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c5 ELSE '' END) UC5,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c1 ELSE '' END) GC1,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c2 ELSE '' END) GC2,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c3 ELSE '' END) GC3,
                            MIN(CASE WHEN gr.atype = 'G' THEN gr.c4 ELSE '' END) GC4,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c5 ELSE '' END) GC5,
                            max(C6) C6, MAX(C7) C7,NVL(C8,'') C8,'' C9, NVL(GR.USER_DN,'') USER_DN ,NVL(GR.TEN,'') TEN,
                            GR.GRPID,GR.GRPNAME
                        FROM
                            (
                                SELECT AU.AUTHID,AU.CMDCODE, RPT.MODCODE, MAX(TO_CHAR(RPT.RPTID)||': '||TO_CHAR(RPT.DESCRIPTION)) TXNAME,
                                    MAX(AU.CMDALLOW) C1, MAX(SUBSTR(AU.STRAUTH,1,1)) C2, MAX(SUBSTR(AU.STRAUTH,2,1)) C3,
                                    MIN(SUBSTR(AU.STRAUTH,3,1)) C4 ,'' C5,'' C6, 'R' C7, 'U' ATYPE,A1.CDCONTENT C8, TLP.TLNAME USER_DN,
                                    TLP.TLFULLNAME TEN,'' GRPID,'' GRPNAME
                                FROM RPTMASTER RPT ,CMDAUTH AU, ALLCODE A1, TLPROFILES TLP
                                WHERE RPT.RPTID = AU.CMDCODE
                                    AND RPT.CMDTYPE = 'R'
                                    AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                                    AND AU.AUTHTYPE='U'
                                    AND AU.AUTHTYPE =V_AUTHTYPE
                                    AND A1.CDTYPE='SY'
                                    AND RPT.VISIBLE='Y'
                                    AND AU.CMDCODE = V_STRTLTXCD
                                    AND A1.CDNAME='RIGHTSCOPE'
                                    AND A1.CDVAL=AU.RIGHTSCOPE
                                    AND AU.AUTHID=TLP.TLID
                                GROUP BY AU.CMDCODE, RPT.MODCODE,A1.CDCONTENT,AU.AUTHID,TLP.TLNAME,TLP.TLFULLNAME
                                UNION ALL
                                -- QUYEN GROUP
                                SELECT AU.AUTHID,AU.CMDCODE, RPT.MODCODE, MAX(TO_CHAR(RPT.RPTID)||': '||TO_CHAR(RPT.DESCRIPTION)) TXNAME,
                                    MAX(AU.CMDALLOW) C1, MAX(SUBSTR(AU.STRAUTH,1,1)) C2, MAX(SUBSTR(AU.STRAUTH,2,1)) C3,
                                    MIN(SUBSTR(AU.STRAUTH,3,1)) C4 ,'' C5,'' C6, 'R' C7, 'G' ATYPE,A1.CDCONTENT C8, TLP.TLNAME USER_DN,
                                    TLP.TLFULLNAME TEN,TLR.GRPID,TLR.GRPNAME
                                FROM RPTMASTER RPT ,CMDAUTH AU,ALLCODE A1, TLGROUPS TLR, TLGRPUSERS TLG,
                                     TLPROFILES TLP,BRGRPPARAM BR
                                WHERE RPT.RPTID = AU.CMDCODE
                                      AND AU.AUTHID=TLR.GRPID
                                      AND RPT.CMDTYPE = 'R'
                                      AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                                      AND AU.AUTHTYPE='G'
                                      -- AND V_AUTHTYPE = 'G'
                                       AND AU.AUTHTYPE =V_AUTHTYPE
                                      AND A1.CDTYPE='SY'
                                      AND RPT.VISIBLE='Y'
                                      AND AU.CMDCODE = V_STRTLTXCD
                                      AND A1.CDNAME='RIGHTSCOPE'
                                      AND A1.CDVAL=AU.RIGHTSCOPE
                                      AND TLR.GRPID=TLG.GRPID AND TLP.TLID=TLG.TLID AND BR.BRID=TLP.BRID
                                      AND BR.PARATYPE= 'TLGROUPS' AND BR.PARAVALUE=TLR.GRPID
                                      AND BR.DELTD='N' AND TLR.ACTIVE='Y' AND TLG.GRPID=AU.AUTHID
                                GROUP BY AU.CMDCODE, RPT.MODCODE,A1.CDCONTENT,AU.AUTHID,TLP.TLNAME,TLP.TLFULLNAME,TLR.GRPID,TLR.GRPNAME
                            ) GR
                        GROUP BY GR.CMDCODE, GR.MODCODE,GR.C8, GR.USER_DN,GR.TEN,GR.AUTHID,GR.GRPID,GR.GRPNAME
                    ) a


   -- QUYEN GIAO DICH
                UNION ALL

                   SELECT  a.cmdcode, a.txname,A.USER_DN,A.TEN,'' c1,
                  /*  CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END c2,*/ '' c2,
                   CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END   c3,
                  /*  CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END c4,*/ '' c4,
                    CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END c5,
                    CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END C6,
                      A.C7,a.c8,a.c9,A.AUTHID,A.GRPID,A.GRPNAME
                FROM
                    (
                        SELECT gr.cmdcode, max(gr.txname) txname,GR.AUTHID,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c1 ELSE '' END) UC1,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c2 ELSE '' END) UC2,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c3 ELSE '' END) UC3,
                            MAX(CASE WHEN gr.atype = 'U' THEN gr.c4 ELSE '' END) UC4,
                            max(CASE WHEN gr.atype = 'U' THEN gr.c5 ELSE '' END) UC5,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c1 ELSE '' END) GC1,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c2 ELSE '' END) GC2,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c3 ELSE '' END) GC3,
                            MAX(CASE WHEN gr.atype = 'G' THEN gr.c4 ELSE '' END) GC4,
                            max(CASE WHEN gr.atype = 'G' THEN gr.c5 ELSE '' END) GC5,
                            max(C6) C6, MAX(C7) C7, NVL(C8,'') C8, NVL(C9,'') c9, NVL(GR.USER_DN,'') USER_DN ,
                            NVL(GR.TEN,'') TEN,GR.GRPID,GR.GRPNAME
                        FROM
                            (
                         SELECT TA.*, A.C8,A.C9 FROM (
                               SELECT TA.TLTXCD CMDCODE, TA.AUTHID,TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC) TXNAME,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                                    '' C5,'' C6, 'T' C7, 'U' ATYPE, TLP.TLNAME USER_DN, TLP.TLFULLNAME TEN,
                                    '' GRPID,'' GRPNAME
                                FROM TLAUTH TA ,TLTX TX, TLPROFILES TLP, VW_CMDMENU_ALL_RPT PT
                                WHERE  TA.TLTXCD =TX.TLTXCD
                                    AND TA.AUTHID=TLP.TLID AND TX.TLTXCD=PT.CMDID
                                    AND TA.TLTXCD LIKE V_STRTLTXCD
                                    AND TA.AUTHTYPE='U'
                                    AND TA.AUTHTYPE =V_AUTHTYPE
                                    AND NOT EXISTS (
                                                 SELECT SR.searchcode, SR.tltxcd
                                                 FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                                 WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                                    AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd)
                                GROUP BY TA.TLTXCD,TX.TXDESC,TA.AUTHID,TLP.TLNAME, TLP.TLFULLNAME

                                UNION ALL

                                -- QUYEN GROUP
                               SELECT TA.TLTXCD CMDCODE,TA.AUTHID, TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC) TXNAME,
                                    replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                                    replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                                    replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                                    replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','')C4,
                                    ''C5,'' C6, 'T' C7, 'G' ATYPE, TLP.TLNAME USER_DN, TLP.TLFULLNAME TEN,
                                    TLR.GRPID,TLR.GRPNAME
                                  FROM TLAUTH TA ,TLTX TX, TLGROUPS TLR, TLGRPUSERS TLG,
                                     TLPROFILES TLP,BRGRPPARAM BR, VW_CMDMENU_ALL_RPT PT
                                  WHERE  TA.TLTXCD =TX.TLTXCD AND TX.TLTXCD=PT.CMDID
                                    AND TLR.GRPID=TA.AUTHID
                                    AND TA.AUTHTYPE='G'
                                   --  AND V_AUTHTYPE = 'G'
                                   AND TA.AUTHTYPE =V_AUTHTYPE
                                    AND TA.TLTXCD LIKE V_STRTLTXCD
                                    AND TLR.GRPID=TLG.GRPID AND TLP.TLID=TLG.TLID AND BR.BRID=TLP.BRID
                                    AND BR.PARATYPE= 'TLGROUPS' AND BR.PARAVALUE=TLR.GRPID
                                    AND BR.DELTD='N' AND TLR.ACTIVE='Y' AND TLG.GRPID=TA.AUTHID
                                    AND NOT EXISTS (
                                                 SELECT SR.searchcode, SR.tltxcd
                                                 FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                                 WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                                    AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd)
                                    GROUP BY TA.TLTXCD,TX.TXDESC,TA.AUTHID,TLP.TLNAME, TLP.TLFULLNAME,TLR.GRPID,TLR.GRPNAME
                                ) TA

                               LEFT JOIN (SELECT AU.AUTHID,AU.CMDCODE,A1.CDCONTENT C8,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X',''))  C9
                                        FROM CMDAUTH AU ,ALLCODE A1, TLPROFILES TL
                               WHERE AU.CMDTYPE='T'
                                   AND A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                   AND TL.TLID=AU.AUTHID
                                 GROUP BY AU.AUTHID,AU.CMDCODE,A1.CDCONTENT,TL.TLID,TL.TLNAME, TL.TLFULLNAME
                                 ) A ON TA.AUTHID=A.AUTHID AND TA.CMDCODE=A.CMDCODE
                            ) GR


                        GROUP BY GR.CMDCODE,gr.c8,gr.c9,GR.USER_DN,GR.TEN,GR.AUTHID,GR.GRPID,GR.GRPNAME
                    ) A, appmodules app
                    where substr(a.cmdcode,1,2) = app.txcode

                union ALL
                -- QUYEN TRA CUU TONG HOP
            SELECT A.CMDCODE, A.TXNAME,A.USER_DN,A.TEN,
             A.TRUYCAP C1, '' C2, -- C2 NHAP GD, C1 TRUY CAP
             /* NVL(B.C2,'') C2,*/  NVL(B.C1,'') C3, '' c4,/* NVL(B.C4,'') C4,*/ '' C5,  NVL(B.C3,'') C6, 'S' C7,A.C8,
                A.C9,A.AUTHID,A.GRPID,A.GRPNAME
                FROM
                    (   -- DANH SACH TRA CUU TONG HOP
                        SELECT GR.CMDCODE, GR.MODCODE,GR.TRUYCAP, MAX(GR.TLTXCD) TLTXCD, MAX(GR.TXNAME) TXNAME,NVL(GR.C8,'') C8,
                        NVL(GR.C9,'') C9, NVL(GR.USER_DN,'') USER_DN ,NVL(GR.TEN,'') TEN,GR.AUTHID,
                        GR.GRPID,GR.GRPNAME,GR.A
                        FROM
                            (
                                SELECT AU.AUTHID,AU.CMDCODE, RPT.modcode, max(nvl(sr.tltxcd,'')) tltxcd,
                                  MAX(DECODE(AU.CMDALLOW,'Y','X','')) TRUYCAP,A1.CDCONTENT C8,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X',''))  C9,
                                 MAX(RPT.RPTID ||'-'|| CASE WHEN SR.TLTXCD IS NULL THEN 'VIEW' ELSE SR.TLTXCD END ||': '|| RPT.DESCRIPTION) TXNAME
                                 , TLP.TLNAME USER_DN, TLP.TLFULLNAME TEN,'' GRPID,'' GRPNAME,'U' A
                                FROM RPTMASTER RPT ,CMDAUTH AU, search sr,ALLCODE A1, TLPROFILES TLP, VW_CMDMENU_ALL_RPT PT
                                WHERE RPT.RPTID = AU.CMDCODE AND SR.SEARCHCODE = RPT.RPTID
                                    AND RPT.CMDTYPE in ('V','D','L') AND rpt.visible = 'Y'
                                    AND au.cmdtype = 'G'
                                    AND A1.CDTYPE='SY' AND RPT.RPTID=PT.CMDID
                                    AND AU.CMDCODE LIKE V_STRTLTXCD
                                    AND A1.CDNAME='RIGHTSCOPE'
                                    AND A1.CDVAL=AU.RIGHTSCOPE
                                    AND AU.AUTHTYPE='U'
                                    AND AU.AUTHTYPE =V_AUTHTYPE
                                    AND AU.AUTHID=TLP.TLID
                                GROUP BY AU.CMDCODE, RPT.modcode,A1.CDCONTENT,AU.AUTHID,TLP.TLNAME, TLP.TLFULLNAME
                                UNION ALL
                                -- QUYEN GROUP
                                SELECT AU.AUTHID,AU.CMDCODE, RPT.modcode, max(nvl(sr.tltxcd,'')) tltxcd,
                                MAX(DECODE(AU.CMDALLOW,'Y','X','')) TRUYCAP,A1.CDCONTENT C8,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X',''))  C9,
                                 MAX(RPT.RPTID ||'-'|| CASE WHEN SR.TLTXCD IS NULL THEN 'VIEW' ELSE SR.TLTXCD END ||': '|| RPT.DESCRIPTION) TXNAME
                                  , TLP.TLNAME USER_DN, TLP.TLFULLNAME TEN,TLR.GRPID,TLR.GRPNAME,'G' A
                                FROM RPTMASTER RPT ,CMDAUTH AU, search sr,ALLCODE A1, TLGRPUSERS TLG,TLGROUPS TLR,
                                     TLPROFILES TLP,BRGRPPARAM BR, VW_CMDMENU_ALL_RPT PT
                                WHERE RPT.RPTID = AU.CMDCODE AND SR.SEARCHCODE = RPT.RPTID
                                    AND RPT.CMDTYPE in ('V','D','L') AND rpt.visible = 'Y'
                                    AND au.cmdtype = 'G' AND RPT.RPTID=PT.CMDID
                                    --AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                                    AND AU.AUTHTYPE='G'
                                    -- AND V_AUTHTYPE = 'G'
                                    AND AU.AUTHTYPE =V_AUTHTYPE
                                    AND A1.CDTYPE='SY'
                                    AND TLR.GRPID=AU.AUTHID
                                    AND AU.CMDCODE LIKE V_STRTLTXCD
                                    AND A1.CDNAME='RIGHTSCOPE'
                                    AND A1.CDVAL=AU.RIGHTSCOPE
                                    AND TLR.GRPID=TLG.GRPID AND TLP.TLID=TLG.TLID AND BR.BRID=TLP.BRID
                                    AND BR.PARATYPE= 'TLGROUPS' AND BR.PARAVALUE=TLR.GRPID
                                    AND BR.DELTD='N' AND TLR.ACTIVE='Y' AND TLG.GRPID=AU.AUTHID
                                GROUP BY AU.CMDCODE, RPT.modcode,A1.CDCONTENT,AU.AUTHID ,TLP.TLNAME, TLP.TLFULLNAME,TLR.GRPID,TLR.GRPNAME
                            ) GR
                       GROUP BY GR.CMDCODE, GR.modcode,GR.TRUYCAP,GR.C8,GR.C9,GR.USER_DN,GR.TEN,GR.AUTHID,GR.GRPID,GR.GRPNAME,A
                       )A
                    LEFT JOIN
                    (   -- QUYEN GIAO DICH TUONG UNG
                        SELECT a.cmdcode, a.txname,
                            CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END c1,
                            CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END c2,
                            CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END c3,
                            CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END c4,
                            CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END c5,
                            A.C6, A.C7,A.AUTHID, A.B
                        FROM
                            (
                                SELECT gr.cmdcode, max(gr.txname) txname,
                                    max(CASE WHEN gr.atype = 'U' THEN gr.c1 ELSE '' END) UC1,
                                    max(CASE WHEN gr.atype = 'U' THEN gr.c2 ELSE '' END) UC2,
                                    max(CASE WHEN gr.atype = 'U' THEN gr.c3 ELSE '' END) UC3,
                                    MAX(CASE WHEN gr.atype = 'U' THEN gr.c4 ELSE '' END) UC4,
                                    max(CASE WHEN gr.atype = 'U' THEN gr.c5 ELSE '' END) UC5,
                                    max(CASE WHEN gr.atype = 'G' THEN gr.c1 ELSE '' END) GC1,
                                    max(CASE WHEN gr.atype = 'G' THEN gr.c2 ELSE '' END) GC2,
                                    max(CASE WHEN gr.atype = 'G' THEN gr.c3 ELSE '' END) GC3,
                                    MAX(CASE WHEN gr.atype = 'G' THEN gr.c4 ELSE '' END) GC4,
                                    max(CASE WHEN gr.atype = 'G' THEN gr.c5 ELSE '' END) GC5,
                                    max(C6) C6, MAX(C7) C7, GR.AUTHID, GR.B
                                FROM
                                    (
                                        SELECT TA.TLTXCD CMDCODE, TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC) TXNAME,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                                            '' C5,'' C6, 'T' C7, 'U' ATYPE, TA.AUTHID, 'U'B
                                        FROM TLAUTH TA ,TLTX TX
                                        WHERE  TA.TLTXCD =TX.TLTXCD
                                            AND TA.AUTHTYPE='U'
                                            AND TA.AUTHTYPE =V_AUTHTYPE
                                            AND EXISTS (
                                                         SELECT SR.searchcode, SR.tltxcd
                                                         FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                                         WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                                            AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd)
                                        GROUP BY TA.TLTXCD,TX.TXDESC, TA.AUTHID
                                        UNION ALL
                                        -- QUYEN GROUP
                                        SELECT TA.TLTXCD CMDCODE, TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC) TXNAME,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(TA.TLLIMIT/1000000),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                                            ''C5,'' C6, 'T' C7, 'G' ATYPE, TA.AUTHID,'G' B
                                        FROM TLAUTH TA ,TLTX TX
                                        WHERE  TA.TLTXCD =TX.TLTXCD
                                            AND TA.AUTHTYPE='G'
                                            -- AND V_AUTHTYPE = 'G'
                                            AND TA.AUTHTYPE =V_AUTHTYPE
                                            AND EXISTS (
                                                         SELECT SR.searchcode, SR.tltxcd
                                                         FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                                         WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                                            AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd)
                                        GROUP BY TA.TLTXCD,TX.TXDESC, TA.AUTHID
                                    ) GR
                                GROUP BY GR.CMDCODE, GR.AUTHID, GR.B
                            ) A
                    ) B
                    ON A.TLTXCD = B.CMDCODE AND A.AUTHID=B.AUTHID AND A.A=B.B

            ) DT
        order by DT.CMDCODE, DT.TXNAME,DT.AUTHID
    ;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE

 
 
 
 
/
