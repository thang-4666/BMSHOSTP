SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL0011" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GLBANK         IN       VARCHAR2,
   TASKCD         IN       VARCHAR2,
   DEPTCD         IN       VARCHAR2,
   TLTXCD         in       VARCHAR
     )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- SO CHI TIET TAI KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS

-- NAMNT  21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_STRGLBANK        VARCHAR2 (20);
   V_STRTASKCD        VARCHAR2 (10);
   V_STRDEPTCD        VARCHAR2 (10);
   V_STRTLTXCD        VARCHAR2 (10);
   V_EOY              VARCHAR2 (1);
   V_EOM              VARCHAR2 (1);
   v_PERIOD           VARCHAR2 (4);
  BE_BALANCE          NUMBER (20, 2);
   LENG               NUMBER (20, 2);
   VP_CUR             PKG_REPORT.REF_CURSOR;
    Dmin         date ;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;
   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
   IF (GLBANK  <> 'ALL')
   THEN
      V_STRGLBANK  := GLBANK  ;
   ELSE
      V_STRGLBANK  := '%%';
   END IF;

    IF (TASKCD <> 'ALL')
   THEN
      V_STRTASKCD := TASKCD;
   ELSE
      V_STRTASKCD := '%%';
   END IF;

 IF (DEPTCD  <> 'ALL')
   THEN
      V_STRDEPTCD := DEPTCD ;
   ELSE
      V_STRDEPTCD  := '%%';
   END IF;

     IF (TLTXCD  <> 'ALL')
   THEN
      V_STRTLTXCD := TLTXCD;
   ELSE
      V_STRTLTXCD := '%%';
   END IF;

   -- END OF GETTING REPORT'S PARAMETERS
  open VP_CUR
  for
  SELECT min(TXDATE)
  FROM GLHIST
  WHERE ACCTNO like V_STRGLBANK   ;
  LOOP
      FETCH VP_CUR
       INTO Dmin ;
       EXIT WHEN VP_CUR%NOTFOUND;
  END LOOP;
  CLOSE VP_CUR;

 --XAC DINH LOAI NGAY
   v_PERIOD :='EOD';
-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
       FOR
   SELECT * FROM

  ( SELECT NVL(sum(GH.BALANCE),0) BE_BALANCE , GM.ACCTNO,GM.acname
        FROM GLMAST GM
        LEFT JOIN
        ( SELECT * FROM  GLHIST
           WHERE TXDATE =
                   ( SELECT MAX(TXDATE)
                       FROM GLHIST
                       WHERE TXDATE <  TO_DATE ( F_DATE  ,'DD/MM/YYYY') )
                       AND    PERIOD LIKE 'EOD'
        ) GH
        ON GM.acctno =GH.acctno
             WHERE   SUBSTR(GM.ACCTNO,7,5) like V_STRGLBANK
             GROUP BY GM.ACCTNO,GM.acname
         )BE_BALANCE

 LEFT JOIN
   (
   SELECT   MST.TLTXCD TLTXCD ,MST.ACCTNO ,MST.TXDATE TXDATE,MST.TXNUM TXNUM,MST.TXDESC TXDESC
         ,DTL.ACCTNO COACCTNO , ROUND(CASE WHEN NVL(DTL.AMT,0)=0 OR ABS(MST.DRAMT)<ABS( DTL.AMT) THEN MST.DRAMT ELSE DTL.AMT END)DRAMT,
        ROUND (CASE WHEN NVL(DTL.AMT,0)=0 OR ABS(MST.CRAMT)< ABS(DTL.AMT) THEN MST.CRAMT ELSE DTL.AMT END)CRAMT, MST.BUSDATE
         FROM

    (SELECT TLTX.MNEM, TL.TLTXCD, TL.TXDATE, TL.TXNUM, TL.BUSDATE, GL.CCYCD, TL.TXDESC,
                GL.ACCTNO, GL.DORC, GL.SUBTXNO, (CASE WHEN DORC='D' THEN GL.AMT ELSE 0 END) DRAMT,
                (CASE WHEN DORC='C' THEN GL.AMT ELSE 0 END) CRAMT
            FROM TLTX, TLLOG TL, GLTRAN GL
             WHERE TL.TXDATE=GL.TXDATE AND TL.TXNUM=GL.TXNUM AND TLTX.TLTXCD=TL.TLTXCD
                AND TL.DELTD<>'Y'
                AND TL.BUSDATE >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                AND TL.BUSDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                AND SUBSTR(GL.ACCTNO,7,5) like V_STRGLBANK
                AND SUBSTR(GL.ACCTNO,1,4)LIKE V_STRBRID
                AND TL.TLTXCD  LIKE  V_STRTLTXCD
                      ) MST
           LEFT JOIN GLTRAN DTL
              ON MST.TXDATE=DTL.TXDATE AND MST.TXNUM=DTL.TXNUM AND MST.SUBTXNO=DTL.SUBTXNO AND DTL.DORC= (CASE WHEN MST.DORC='D' THEN 'C' ELSE 'D' END)
           LEFT JOIN (SELECT TXDATE ,TXNUM,SUBTXNO,DORC ,ACCTNO ,MAX(CUSTID) CUSTID,MAX(CUSTNAME ) CUSTNAME,
                       max(TASKCD)TASKCD,max(DEPTCD) DEPTCD ,max(DESCRIPTION) DESCRIPTION FROM  MITRAN  WHERE DELTD<>'Y'
                       GROUP BY TXDATE ,TXNUM,SUBTXNO,DORC ,ACCTNO
                        ) MI
            ON MST.TXNUM= MI.TXNUM  AND MST.TXDATE=MI.TXDATE AND MST.SUBTXNO=MI.SUBTXNO AND MST.DORC=MI.DORC AND MST.ACCTNO=MI.ACCTNO
          where      NVL(MI.TASKCD,'-') LIKE V_STRTASKCD
                     AND NVL(MI.DEPTCD,'-') LIKE V_STRDEPTCD


UNION ALL


   SELECT   MST.TLTXCD TLTXCD ,MST.ACCTNO ,MST.TXDATE TXDATE,MST.TXNUM TXNUM,MST.TXDESC TXDESC
         ,DTL.ACCTNO COACCTNO , ROUND(CASE WHEN NVL(DTL.AMT,0)=0 OR ABS(MST.DRAMT)<ABS( DTL.AMT) THEN MST.DRAMT ELSE DTL.AMT END)DRAMT,
        ROUND (CASE WHEN NVL(DTL.AMT,0)=0 OR ABS(MST.CRAMT)< ABS(DTL.AMT) THEN MST.CRAMT ELSE DTL.AMT END)CRAMT,MST.BUSDATE
         FROM

    (SELECT TLTX.MNEM, TL.TLTXCD, TL.TXDATE, TL.TXNUM, TL.BUSDATE, GL.CCYCD, TL.TXDESC,
                GL.ACCTNO, GL.DORC, GL.SUBTXNO, (CASE WHEN DORC='D' THEN GL.AMT ELSE 0 END) DRAMT,
                (CASE WHEN DORC='C' THEN GL.AMT ELSE 0 END) CRAMT
            FROM TLTX, TLLOGALL TL, GLTRANA GL
             WHERE TL.TXDATE=GL.TXDATE AND TL.TXNUM=GL.TXNUM AND TLTX.TLTXCD=TL.TLTXCD
                AND TL.DELTD<>'Y'
                AND TL.BUSDATE >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                AND TL.BUSDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                AND SUBSTR(GL.ACCTNO,7,5) like V_STRGLBANK
                AND SUBSTR(GL.ACCTNO,1,4)LIKE V_STRBRID
                AND TL.TLTXCD  LIKE  V_STRTLTXCD
                      ) MST
           LEFT JOIN GLTRANA DTL
              ON MST.TXDATE=DTL.TXDATE AND MST.TXNUM=DTL.TXNUM AND MST.SUBTXNO=DTL.SUBTXNO AND DTL.DORC= (CASE WHEN MST.DORC='D' THEN 'C' ELSE 'D' END)

           LEFT JOIN (SELECT TXDATE ,TXNUM,SUBTXNO,DORC ,ACCTNO ,MAX(CUSTID) CUSTID,MAX(CUSTNAME ) CUSTNAME,
                       max(TASKCD)TASKCD,max(DEPTCD) DEPTCD ,max(DESCRIPTION) DESCRIPTION FROM  MITRAN  WHERE DELTD<>'Y'
                       GROUP BY TXDATE ,TXNUM,SUBTXNO,DORC ,ACCTNO
                        ) MI
            ON MST.TXNUM= MI.TXNUM  AND MST.TXDATE=MI.TXDATE AND MST.SUBTXNO=MI.SUBTXNO AND MST.DORC=MI.DORC AND MST.ACCTNO=MI.ACCTNO
          where      NVL(MI.TASKCD,'-') LIKE V_STRTASKCD
                     AND NVL(MI.DEPTCD,'-') LIKE V_STRDEPTCD
                     )BALANCE
         ON BE_BALANCE.ACCTNO = BALANCE.ACCTNO
          WHERE (  BALANCE.DRAMT <> 0  OR BALANCE.CRAMT <> 0) order by busdate;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
