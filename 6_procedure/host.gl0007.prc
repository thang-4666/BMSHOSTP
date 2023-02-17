SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL0007" (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   brid           IN       VARCHAR2,
   f_date         IN       VARCHAR2,
   t_date         IN       VARCHAR2,
   acctno         In       varchar2
)
IS
--
-- Purpose: Briefly explain the functionality of the procedure
--  SO TONG HOP CHU T CUA TAI KHOAN
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- namnt   21-Nov-06  Created
-- ---------   ------  -------------------------------------------
 v_stroption        VARCHAR2 (5);       -- A: All; B: Branch; S: Sub-branch
 v_strbrid          VARCHAR2 (4);
 v_stracctno        VARCHAR2 (20);
 BE_BALANCE          NUMBER (20, 2);
   A             PKG_REPORT.REF_CURSOR;
   B             PKG_REPORT.REF_CURSOR;
   Dmin         date ;
             -- Used when v_numOption > 0
   v_leng          NUMBER (20, 2);
-- Declare program variables as shown above
BEGIN
   v_stroption := opt;
   v_leng := length (acctno);
   v_stracctno:= '%'|| acctno ||'%';
   IF (v_stroption <> 'A') AND (brid <> 'ALL')
   THEN
      v_strbrid := brid;
   ELSE
      v_strbrid := '%%';
   END IF;

   -- Get report's parameters

   -- End of getting report's parameters
 open b
  for
  SELECT min(TXDATE)
  FROM GLHIST
  where substr(ACCTNO,7,v_leng) like v_stracctno;

  LOOP
      FETCH b
       INTO Dmin ;
       EXIT WHEN b%NOTFOUND;
  END LOOP;
  CLOSE b;


  if Dmin > TO_DATE(F_DATE ,'dd/MM/yyyy')-1then
       BE_BALANCE:=0;
        else
        OPEN A
         FOR
        SELECT sum(BALANCE)
        FROM GLHIST
        WHERE TXDATE= ( SELECT MAX(TXDATE)
         FROM GLHIST WHERE TXDATE< TO_DATE ( F_DATE ,'DD/MM/YYYY'))
        AND substr(ACCTNO,7,v_leng) LIKE v_stracctno
        AND substr(ACCTNO,1,4) LIKE v_strbrid ;
      LOOP
      FETCH A
   INTO BE_BALANCE;

      EXIT WHEN A%NOTFOUND;
   END LOOP;
   CLOSE A;
   END IF ;

   OPEN PV_REFCURSOR
             FOR
 SELECT   nvl(BE_BALANCE,0) BE_BALANCE, SUM(A.DRAMT) DRAMT,SUM(A.CRAMT) CRAMT,GL.GLBANK,GL.GLNAME FROM
   (  SELECT   MST.TLTXCD TLTXCD  ,MST.TXDATE TXDATE,MST.BUSDATE BUSDATE
         ,DTL.ACCTNO COACCTNO ,(CASE WHEN ABS(MST.DRAMT)< ABS(DTL.AMT) THEN MST.DRAMT ELSE DTL.AMT END)DRAMT,
         (CASE WHEN ABS(MST.CRAMT)< ABS(DTL.AMT) THEN MST.CRAMT ELSE DTL.AMT END)CRAMT,MST.ACCTNO
          FROM
         (SELECT TLTX.MNEM, TL.TLTXCD, TL.TXDATE, TL.TXNUM, TL.BUSDATE, GL.CCYCD, TL.TXDESC,
                GL.ACCTNO, GL.DORC, GL.SUBTXNO, (CASE WHEN DORC='D' THEN GL.AMT ELSE 0 END) DRAMT,
                (CASE WHEN DORC='C' THEN GL.AMT ELSE 0 END) CRAMT
            FROM TLTX, TLLOGALL TL, GLTRANA GL
            WHERE TL.TXDATE=GL.TXDATE AND TL.TXNUM=GL.TXNUM AND TLTX.TLTXCD=TL.TLTXCD
            AND TL.DELTD<>'Y'
            AND  SUBSTR(GL.ACCTNO,7,v_leng)LIKE v_stracctno
             AND substr(GL.ACCTNO,1,4) LIKE v_strbrid
            AND TL.BUSDATE >= TO_DATE (f_date , 'DD/MM/YYYY')
            AND TL.BUSDATE <= TO_DATE (t_date, 'DD/MM/YYYY')
            AND gl.bkdate  <= TO_DATE (T_DATE, 'DD/MM/YYYY')
            AND gl.bkdate  >= TO_DATE(F_DATE, 'DD/MM/YYYY')
            )MST
       LEFT JOIN GLTRANA DTL
            ON MST.TXDATE=DTL.TXDATE AND MST.TXNUM=DTL.TXNUM AND MST.SUBTXNO=DTL.SUBTXNO
            AND DTL.DORC= (CASE WHEN MST.DORC='D' THEN 'C' ELSE 'D' END)

UNION ALL
         SELECT   MST.TLTXCD TLTXCD  ,MST.TXDATE TXDATE,MST.BUSDATE BUSDATE
         ,DTL.ACCTNO COACCTNO ,(CASE WHEN ABS(MST.DRAMT)< ABS(DTL.AMT) THEN MST.DRAMT ELSE DTL.AMT END)DRAMT,
         (CASE WHEN ABS(MST.CRAMT)< ABS(DTL.AMT) THEN MST.CRAMT ELSE DTL.AMT END)CRAMT,MST.ACCTNO
         FROM
            (SELECT TLTX.MNEM, TL.TLTXCD, TL.TXDATE, TL.TXNUM, TL.BUSDATE, GL.CCYCD, TL.TXDESC,
                GL.ACCTNO, GL.DORC, GL.SUBTXNO, (CASE WHEN DORC='D' THEN GL.AMT ELSE 0 END) DRAMT,
                (CASE WHEN DORC='C' THEN GL.AMT ELSE 0 END) CRAMT
             FROM TLTX, TLLOG TL, GLTRAN GL
             WHERE TL.TXDATE=GL.TXDATE AND TL.TXNUM=GL.TXNUM AND TLTX.TLTXCD=TL.TLTXCD
             AND TL.DELTD<>'Y'
             AND SUBSTR(GL.ACCTNO,7,v_leng)LIKE v_stracctno
             AND substr(GL.ACCTNO,1,4) LIKE v_strbrid
             AND TL.BUSDATE >= TO_DATE (f_date , 'DD/MM/YYYY')
             AND TL.BUSDATE <= TO_DATE (t_date, 'DD/MM/YYYY')

                      ) MST
         LEFT JOIN GLTRAN DTL
              ON MST.TXDATE=DTL.TXDATE AND MST.TXNUM=DTL.TXNUM AND MST.SUBTXNO=DTL.SUBTXNO
              AND DTL.DORC= (CASE WHEN MST.DORC='D' THEN 'C' ELSE 'D' END)

              )A
              ,GLBANK GL
        WHERE  SUBSTR(A.COACCTNO,7,5)= GL.GLBANK

            GROUP BY GL.GLBANK,GL.GLNAME
               order by GLBANK
               ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- Procedure

 
 
 
 
/
