SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL0026" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   ACCTNO         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2,
   TASKCD         IN       VARCHAR2,
   DEPTCD         IN       VARCHAR2,
   MICD           IN       VARCHAR2
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
   V_STRACCTNO        VARCHAR2 (20);
   V_STRCUSTID        VARCHAR2 (20);
   V_STRTASKCD        VARCHAR2 (10);
   V_STRDEPTCD        VARCHAR2 (10);
   V_STRMICD          VARCHAR2 (10);
   V_EOY                  VARCHAR2 (1);
   V_EOM                  VARCHAR2 (1);
   V_PERIOD             VARCHAR2 (4);
  BE_BALANCE          NUMBER (20, 2);
   LENG                 NUMBER (20, 2);
     DMIN         DATE ;
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
   IF (ACCTNO <> 'ALL')
   THEN
      V_STRACCTNO := ACCTNO;
   ELSE
      V_STRACCTNO := '%%';
   END IF;
   LENG:=LENGTH(ACCTNO);

    IF (CUSTID  <> 'ALL')
   THEN
      V_STRCUSTID := CUSTID;
   ELSE
      V_STRCUSTID := '%%';
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
   IF (MICD  <> 'ALL')
   THEN
      V_STRMICD := MICD ;
   ELSE
      V_STRMICD  := '%%';
   END IF;
-- GET REPORT'S DATA

   OPEN PV_REFCURSOR
       FOR
          SELECT SUM(CASE WHEN GL.DORC = 'C' THEN GL.AMT ELSE 0 END) CRAMT,
          SUM(CASE WHEN GL.DORC = 'D' THEN GL.AMT ELSE 0 END) DRAMT,   nvl(MI.MICD,'MIS') MICD ,MAX(AL.CDCONTENT), substr(gl.acctno,7,5) acctno, max(glbank.glname) glname
              FROM (select  TXDATE ,TXNUM,SUBTXNO ,DORC,ACCTNO ,max(CUSTID) CUSTID ,max(TASKCD) TASKCD,max(DEPTCD) DEPTCD,max(MICD) MICD
               from  mitran WHERE DELTD <>'Y' group by TXDATE ,TXNUM,SUBTXNO ,DORC,ACCTNO )
               MI, (SELECT * FROM GLTRAN where deltd<>'Y' UNION SELECT * FROM GLTRANA where deltd<>'Y' ) GL,ALLCODE  AL, GLBANK
             WHERE  GL.TXDATE = MI.TXDATE (+)
               AND  AL.CDNAME ='IECD'
               AND AL.CDVAL = nvl(MI.MICD,'MIS')
               AND AL.CDTYPE ='SA'
               and GLBANK.glbank =substr(gl.acctno,7,5)
               AND GL.TXNUM = MI.TXNUM(+)
               AND GL.SUBTXNO = MI.SUBTXNO(+)
               AND  GL.DORC=MI.DORC (+)
               AND  GL.ACCTNO=MI.ACCTNO (+)
               AND SUBSTR(gl.ACCTNO,7,3)  IN ('642','631')
               AND NVL(MI.TASKCD,'- ')LIKE V_STRTASKCD
               AND NVL(MI.MICD,'-') LIKE V_STRMICD
               AND NVL(MI.DEPTCD,'-') LIKE V_STRDEPTCD
               AND NVL(MI.CUSTID,'-') LIKE V_STRCUSTID
               AND SUBSTR(gl.ACCTNO,7,LENG) LIKE V_STRACCTNO
              AND GL.BKDATE >= TO_DATE(F_DATE  ,'DD/MM/YYYY')
               AND GL.BKDATE<= TO_DATE(T_DATE ,'DD/MM/YYYY')
               AND SUBSTR(gl.acctno,1,4) LIKE V_STRBRID
              GROUP BY  nvl(MI.MICD,'MIS'),substr(gl.acctno,7,5)
              order by nvl(MI.MICD,'MIS'), substr(gl.acctno,7,5) ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
