SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0002_1" (
    PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
    OPT            IN       VARCHAR2,
    BRID           IN       VARCHAR2,
    TLGOUPS        IN       VARCHAR2,
    TLSCOPE        IN       VARCHAR2,
    AAUTHID        IN       VARCHAR2,
    AUTHTYPE       IN        VARCHAR2,
    TLTXCD         IN         VARCHAR2,
     PLSENT         in        varchar2
   )
IS

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NGOCVTT   16-05-15  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (50);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (20);              -- USED WHEN V_NUMOPTION > 0
   V_STRAUTHID         VARCHAR2 (20);
   V_STRTLID                 VARCHAR2 (60);
   V_STRTLNAME               VARCHAR2 (300);
   V_STRTLFULLNAME           VARCHAR2 (500);
   V_STRTLLEV                VARCHAR2 (60);
   V_STRTLGROUP              VARCHAR2 (360);
   V_AUTHTYPE            VARCHAR2(10);

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

  --  V_STRAUTHID:= AAUTHID;

    IF (AAUTHID <> 'ALL')
   THEN
      V_STRAUTHID := AAUTHID;
   ELSE
      V_STRAUTHID := '%%';
   END IF;

    V_AUTHTYPE := AUTHTYPE;

   -- END OF GETTING REPORT'S PARAMETERS
OPEN PV_CUR
    FOR

    SELECT nvl(tl.tlid,''), nvl(tl.tlname,''), nvl(tl.tlfullname,''), nvl(tl.tllev,''), nvl(a.cdcontent,'')
    FROM tlprofiles tl, allcode a
    WHERE tl.tlid like V_STRAUTHID
        AND a.cdtype = 'SA' AND a.cdname = 'TLGROUP' AND a.cdval = tl.tlgroup;
LOOP
FETCH PV_CUR
  INTO V_STRTLID,V_STRTLNAME,V_STRTLFULLNAME,V_STRTLLEV,V_STRTLGROUP;

  EXIT WHEN PV_CUR%NOTFOUND;

END LOOP;



    OPEN PV_REFCURSOR
    FOR

        SELECT V_STRAUTHID auth,V_STRTLID TLID,V_STRTLNAME TLNAME,V_STRTLFULLNAME FULLNAME,V_STRTLLEV LEV ,V_STRTLGROUP TLGROUP, DT.*, TLP.TLNAME NAME
        FROM
            (
                              -- QUYEN CHUC NANG
                SELECT fn_getparentgroupmenu(a.cmdcode,'M',null, 'Y') groupname, a.cmdcode, a.txname,
                    DECODE(CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END,'Y','X','') c1,
                    DECODE(CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END,'Y','X','') c2,
                    DECODE(CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END,'Y','X','') c3,
                    DECODE(CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END,'Y','X','') c4,
                    DECODE(CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END,'Y','X','') c5,
                    DECODE(CASE WHEN a.uc6 IS NOT NULL THEN a.uc6 ELSE a.gc6 END,'Y','X','') C6,
                    A.C7 c7,C8,NVL(A.C9,'') C9,A.TENNHOM, A.AUTHID
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
                            max(CASE WHEN gr.atype = 'G' THEN gr.c6 ELSE '' END) GC6, max(C7) C7,nvl(gr.C8,'') C8,'' C9,NVL(GR.TENNHOM,'') TENNHOM
                        FROM
                            (
                                SELECT AU.AUTHID,au.cmdcode, MAX(au.cmdcode || ': ' || TO_CHAR(ME.CMDNAME))TXNAME, MAX(AU.CMDALLOW) C1,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,1,1) END) C2,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,2,1) END) C3,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,3,1) END) C4,
                                    MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,4,1) END) C5,
                                     MAX(CASE WHEN ME.MENUTYPE IN ('A','P') THEN '' ELSE SUBSTR(AU.STRAUTH,5,1) END) C6,
                                      'M' C7, 'U' ATYPE,A1.CDCONTENT C8,'' TENNHOM
                                FROM CMDMENU ME,CMDAUTH AU, ALLCODE A1, VW_CMDMENU_ALL_RPT PT
                                WHERE ME.CMDID = AU.CMDCODE
                                    AND AU.CMDTYPE ='M' AND ME.MENUTYPE IN ('M','O','A','P')
                                    AND AU.AUTHTYPE ='U' and ME.last = 'Y'
                                    AND ME.CMDID=PT.CMDID
                                     AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N' OR  AU.STRAUTH<>'NNNN' )
                                    --AND AU.STRAUTH<>'NNNN' AND AU.CMDALLOW<>'N' AND  AU.STRAUTH<>'NN' AND AU.STRAUTH<>'NNNNN'
                                    AND AU.AUTHID like V_STRAUTHID
                                    AND A1.CDTYPE='SY'
                                      AND A1.CDNAME='RIGHTSCOPE'
                                        AND A1.CDVAL=AU.RIGHTSCOPE
                                       AND (AU.STRAUTH<>'NNNN' OR AU.CMDALLOW<>'N')
                                GROUP BY AU.CMDCODE,A1.CDCONTENT,AU.AUTHID

                            ) gr
                        GROUP BY gr.cmdcode,GR.C8, GR.TENNHOM,GR.AUTHID
                            ) a


                -- QUYEN BAO CAO
                UNION ALL

                 SELECT fn_getparentgroupmenu(a.cmdcode,'R',modcode, 'Y') groupname, a.cmdcode, a.txname,
                    DECODE(CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END,'Y','X','') c1,
                    DECODE(CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END,'Y','X','') c2,
                    DECODE(CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END,'Y','X','') c3,
                    --CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END c4,
                   /* A1.CDCONTENT C4,*/ '' C4,
                    DECODE(CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END,'Y','X','') c5,
                    NVL(C6,'') C6, A.C7, a.C8,NVL(A.C9,'') C9,A.TENNHOM,A.AUTHID
                FROM
                    (
                        SELECT gr.cmdcode, GR.MODCODE, max(gr.txname) txname, GR.AUTHID,
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
                            max(C6) C6, MAX(C7) C7,NVL(C8,'') C8,'' C9, NVL(GR.TENNHOM,'') TENNHOM
                        FROM
                            (
                                SELECT AU.AUTHID,AU.CMDCODE, RPT.MODCODE, MAX(TO_CHAR(RPT.RPTID)||': '||TO_CHAR(RPT.DESCRIPTION)) TXNAME,
                                    MAX(AU.CMDALLOW) C1, MAX(SUBSTR(AU.STRAUTH,1,1)) C2, MAX(SUBSTR(AU.STRAUTH,2,1)) C3,
                                    MIN(SUBSTR(AU.STRAUTH,3,1)) C4 ,'' C5,'' C6, 'R' C7, 'U' ATYPE,A1.CDCONTENT C8,'' TENNHOM
                                FROM RPTMASTER RPT ,CMDAUTH AU, ALLCODE A1
                                WHERE RPT.RPTID = AU.CMDCODE
                                    AND AU.AUTHID like V_STRAUTHID
                                    AND RPT.CMDTYPE = 'R'
                                    AND RPT.VISIBLE='Y'
                                    AND (AU.STRAUTH<>'NN' OR AU.CMDALLOW<>'N')
                                    AND AU.AUTHTYPE='U'
                                      AND A1.CDTYPE='SY'
                                      AND A1.CDNAME='RIGHTSCOPE'
                                        AND A1.CDVAL=AU.RIGHTSCOPE
                                GROUP BY AU.CMDCODE, RPT.MODCODE,A1.CDCONTENT,AU.AUTHID

                            ) GR
                        GROUP BY GR.CMDCODE, GR.MODCODE,GR.C8,GR.TENNHOM,GR.AUTHID
                    ) a
   -- QUYEN GIAO DICH
                UNION ALL

          SELECT fn_getparentgroupmenu(a.cmdcode,'T',app.modcode, 'Y') groupname, a.cmdcode, a.txname,
                    CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END c1,
                  /*  CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END c2,*/ '' c2,
                    CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END c3,
                  /*  CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END c4,*/ '' c4,
                    CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END c5,
                    A.C6, A.C7,a.c8,a.c9,A.TENNHOM,A.AUTHID
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
                            max(C6) C6, MAX(C7) C7, NVL(C8,'') C8, NVL(C9,'') c9, nvl(GR.TENNHOM,'') TENNHOM
                        FROM
                            (
                         SELECT TA.*, A.C8,A.C9,A.TLID FROM (
                         SELECT TA.TLTXCD CMDCODE, TA.AUTHID,TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC) TXNAME,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                                     replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                                    '' C5,'' C6, 'T' C7, 'U' ATYPE, '' TENNHOM
                                FROM TLAUTH TA ,TLTX TX, VW_CMDMENU_ALL_RPT PT
                                WHERE  TA.TLTXCD =TX.TLTXCD
                                AND TA.TLTXCD=PT.CMDID
                                   AND TA.AUTHID like V_STRAUTHID
                                    AND TA.AUTHTYPE='U'
                                    AND NOT EXISTS (
                                                 SELECT SR.searchcode, SR.tltxcd
                                                 FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                                 WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                                    AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd)
                                GROUP BY TA.TLTXCD,TX.TXDESC,TA.AUTHID


                                ) TA

                                  LEFT JOIN (SELECT AU.AUTHID,AU.CMDCODE,TL.TLID,TL.TLNAME USER_DN,NVL(TL.TLFULLNAME,'') TEN, A1.CDCONTENT C8,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X',''))  C9
                                        FROM CMDAUTH AU ,ALLCODE A1, TLPROFILES TL
                               WHERE AU.CMDTYPE='T'
                                   AND A1.CDTYPE='SY'
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                   AND TL.TLID=AU.AUTHID
                                -- AND AU.AUTHID  LIKE V_STRAUTHID
                                 GROUP BY AU.AUTHID,AU.CMDCODE,A1.CDCONTENT,TL.TLID,TL.TLNAME, TL.TLFULLNAME
                    ) A ON TA.AUTHID=A.AUTHID AND TA.CMDCODE=A.CMDCODE
                            ) GR


                        GROUP BY GR.CMDCODE,gr.c8,gr.c9,GR.TENNHOM,GR.AUTHID
                    ) A, appmodules app
                    where substr(a.cmdcode,1,2) = app.txcode


                union ALL
                -- QUYEN TRA CUU TONG HOP
                SELECT fn_getparentgroupmenu(a.cmdcode,'S',modcode, 'Y') groupname, A.CMDCODE, A.TXNAME, A.TRUYCAP C1, NVL(B.C1,'') C2, -- C2 NHAP GD, C1 TRUY CAP
                /* NVL(B.C2,'') C2,*/ NVL(B.C3,'') C3, '' c4,  /* NVL(B.C4,'') C4,*/ '' C5, '' C6, 'S' C7,A.C8,A.C9,A.TENNHOM,A.AUTHID
                FROM
                    (   -- DANH SACH TRA CUU TONG HOP
                        SELECT GR.CMDCODE, GR.MODCODE,GR.TRUYCAP, MAX(GR.TLTXCD) TLTXCD, MAX(GR.TXNAME) TXNAME, GR.AUTHID,NVL(GR.C8,'') C8,NVL(GR.C9,'') C9,NVL(GR.TENNHOM,'') TENNHOM
                        FROM
                            (
                                SELECT AU.AUTHID,AU.CMDCODE, RPT.modcode, max(nvl(sr.tltxcd,'')) tltxcd,
                                  MAX(DECODE(AU.CMDALLOW,'Y','X','')) TRUYCAP,A1.CDCONTENT C8,MAX(DECODE(SUBSTR(AU.STRAUTH,1,1),'Y','X',''))  C9,
                                 MAX(RPT.RPTID ||'-'|| CASE WHEN SR.TLTXCD IS NULL THEN 'VIEW' ELSE SR.TLTXCD END ||': '|| RPT.DESCRIPTION) TXNAME, '' TENNHOM
                                FROM RPTMASTER RPT ,CMDAUTH AU, search sr,ALLCODE A1, VW_CMDMENU_ALL_RPT PT
                                WHERE RPT.RPTID = AU.CMDCODE AND SR.SEARCHCODE = RPT.RPTID
                                    AND RPT.CMDTYPE in ('V','D','L') AND rpt.visible = 'Y'
                                    AND au.cmdtype = 'G'
                                    AND A1.CDTYPE='SY'
                                    AND RPT.RPTID=PT.CMDID
                                   AND A1.CDNAME='RIGHTSCOPE'
                                   AND A1.CDVAL=AU.RIGHTSCOPE
                                    AND AU.AUTHID like V_STRAUTHID
                                    AND AU.AUTHTYPE='U'
                                GROUP BY AU.CMDCODE, RPT.modcode,A1.CDCONTENT,AU.AUTHID

                            ) GR


                        GROUP BY GR.CMDCODE, GR.modcode,GR.TRUYCAP,GR.C8,GR.C9,GR.TENNHOM,GR.AUTHID
                    ) A
                    LEFT JOIN
                    (   -- QUYEN GIAO DICH TUONG UNG
                        SELECT a.cmdcode, a.txname,
                            CASE WHEN a.uc1 IS NOT NULL THEN a.uc1 ELSE a.gc1 END c1,
                            CASE WHEN a.uc2 IS NOT NULL THEN a.uc2 ELSE a.gc2 END c2,
                            CASE WHEN a.uc3 IS NOT NULL THEN a.uc3 ELSE a.gc3 END c3,
                            CASE WHEN a.uc4 IS NOT NULL THEN a.uc4 ELSE a.gc4 END c4,
                            CASE WHEN a.uc5 IS NOT NULL THEN a.uc5 ELSE a.gc5 END c5,
                            A.C6, A.C7
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
                                    max(C6) C6, MAX(C7) C7
                                FROM
                                    (
                                        SELECT TA.TLTXCD CMDCODE, TO_CHAR(TA.TLTXCD)||': ' ||TO_CHAR(TX.TXDESC) TXNAME,
                                            replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'T',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C1,
                                             replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'C',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C2,
                                             replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'A',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C3,
                                             replace(TO_CHAR(MAX(DECODE(TA.TLTYPE,'R',to_char(round(TA.TLLIMIT/1000000,2)),'')),'999,999,999,999,999,999,999,999,999,999'),' ','') C4,
                                            '' C5,'' C6, 'T' C7, 'U' ATYPE
                                        FROM TLAUTH TA ,TLTX TX
                                        WHERE  TA.TLTXCD =TX.TLTXCD
                                           AND TA.AUTHID like V_STRAUTHID
                                            AND TA.AUTHTYPE='U'
                                            AND EXISTS (
                                                         SELECT SR.searchcode, SR.tltxcd
                                                         FROM SEARCH SR, RPTMASTER RPT, TLTX TL
                                                         WHERE SR.searchcode = RPT.rptid AND RPT.visible = 'Y' AND SR.tltxcd IS NOT NULL
                                                            AND SR.TLTXCD = TL.TLTXCD AND TL.DIRECT = 'N' AND TX.tltxcd = SR.tltxcd)
                                        GROUP BY TA.TLTXCD,TX.TXDESC

                                    ) GR
                                GROUP BY GR.CMDCODE
                            ) A
                    ) B
                    ON A.TLTXCD = B.CMDCODE
            ) DT,TLPROFILES TLP WHERE DT.AUTHID=TLP.TLID
        ORDER BY DT.AUTHID,DT.C7, DT.CMDCODE, DT.TXNAME,DT.TENNHOM
    ;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN;
    END;                                                              -- PROCEDURE
 
 
 
 
/
