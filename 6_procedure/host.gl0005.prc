SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL0005" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--  SO QUY TIEN MAT
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
 V_STROPTION         VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
 V_STRBRID           VARCHAR2 (4);
 BE_BALANCE          NUMBER (20, 2);
 V_CUR               PKG_REPORT.REF_CURSOR;
 DMIN                DATE ;
 V_PERIOD            VARCHAR2 (4);
             -- USED WHEN V_NUMOPTION > 0
  -- V_STRLEVELG        VARCHAR2 (10);

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

   -- END OF GETTING REPORT'S PARAMETERS
 OPEN V_CUR
  FOR
  SELECT MIN(TXDATE)
  FROM GLHIST;
  LOOP
      FETCH V_CUR
       INTO DMIN ;
       EXIT WHEN V_CUR%NOTFOUND;
  END LOOP;
  CLOSE V_CUR;

V_PERIOD :='EOD';

        OPEN V_CUR
         FOR
       SELECT SUM(BALANCE)
       FROM GLHIST
       WHERE TXDATE =
         ( SELECT MAX(TXDATE)
         FROM GLHIST
        WHERE TXDATE<  TO_DATE ( F_DATE ,'DD/MM/YYYY'))
        AND SUBSTR(ACCTNO,7,4) LIKE '1111'
        AND PERIOD LIKE V_PERIOD
        AND SUBSTR(ACCTNO,1,4) LIKE V_STRBRID
        ;
   LOOP
      FETCH V_CUR
   INTO BE_BALANCE;

   EXIT WHEN V_CUR%NOTFOUND;
   END LOOP;
   CLOSE V_CUR;




      OPEN PV_REFCURSOR
       FOR

SELECT ROUND(BE_BALANCE) BE_BALANCE, MST.TXDATE,MST.TLTXCD,MST.TXNUM,MST.TXDESC, ROUND(MST.DRAMT) DRAMT,
ROUND(MST.CRAMT) CRAMT,MST.BUSDATE,'' FULLNAME
FROM
    (SELECT GL.TXDATE, GL.TXNUM, TL.TXDESC ,TL.TLTXCD ,(CASE WHEN DORC='D' THEN GL.AMT ELSE 0 END) DRAMT,
          (CASE WHEN DORC='C' THEN GL.AMT ELSE 0 END) CRAMT,GL.DORC,GL.SUBTXNO,GL.ACCTNO,TL.BUSDATE
    FROM GLTRAN GL ,TLLOG TL
    WHERE TL.TXNUM =GL.TXNUM AND GL.DELTD <>'Y'
      AND SUBSTR(GL.ACCTNO,7,4)  LIKE '1111'
      AND  substr(GL.acctno,1,4)  LIKE V_STRBRID
      AND TL.BUSDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
      AND TL.BUSDATE >= TO_DATE(F_DATE, 'DD/MM/YYYY')
     )MST
/******************************************************************************
 Remove LEFT JOIN with MITRAN as it is not necessary
 Modification date: 24/07/2009
 Modifier: DungNT
 *****************************************************************************/
--LEFT JOIN MITRAN MI
-- ON MI.TXDATE= MST.TXDATE AND  MI.TXNUM =MST.TXNUM AND MI.DORC=MST.DORC
-- AND MI.SUBTXNO =MST.SUBTXNO AND MI.ACCTNO=MST.ACCTNO

/**********End Of Modification************************************************/


UNION ALL

SELECT ROUND(BE_BALANCE) BE_BALANCE, MST.TXDATE,MST.TLTXCD,MST.TXNUM,MST.TXDESC,
 ROUND(MST.DRAMT) DRAMT,ROUND(MST.CRAMT) CRAMT,MST.BUSDATE,'' FULLNAME
FROM
    (SELECT GL.TXDATE, GL.TXNUM, TL.TXDESC,TL.TLTXCD  ,(CASE WHEN DORC='D' THEN GL.AMT ELSE 0 END) DRAMT,
          (CASE WHEN DORC='C' THEN GL.AMT ELSE 0 END) CRAMT,GL.DORC,GL.SUBTXNO,GL.ACCTNO,TL.BUSDATE
    FROM GLTRANA GL ,TLLOGALL TL
    WHERE TL.TXNUM =GL.TXNUM
      AND TL.TXDATE = GL.TXDATE
      AND GL.DELTD <>'Y'
      AND SUBSTR(GL.ACCTNO,7,4)  LIKE '1111'
      AND substr(GL.acctno,1,4)   LIKE V_STRBRID
      AND TL.BUSDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
      AND TL.BUSDATE >= TO_DATE(F_DATE, 'DD/MM/YYYY')
      AND gl.bkdate  <= TO_DATE (T_DATE, 'DD/MM/YYYY')
      AND gl.bkdate  >= TO_DATE(F_DATE, 'DD/MM/YYYY')
       )MST

/******************************************************************************
 Remove LEFT JOIN with MITRAN as it is not necessary
 Modification date: 24/07/2009
 Modifier: DungNT
 *****************************************************************************/
--LEFT JOIN MITRAN MI
-- ON MI.TXDATE= MST.TXDATE AND  MI.TXNUM =MST.TXNUM AND MI.DORC=MST.DORC
-- AND MI.SUBTXNO =MST.SUBTXNO AND MI.ACCTNO=MST.ACCTNO

/**********End Of Modification************************************************/
  ORDER BY busdate , txnum

   ;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
