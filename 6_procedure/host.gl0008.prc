SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL0008" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TLID           IN       VARCHAR2,
   TYPEBA         IN       VARCHAR2,
   TLTXCD         IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- SO NHAT KY CHUNG
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);          -- USED WHEN V_NUMOPTION > 0
   V_STRTLID          VARCHAR2 (6);
   V_STRTYPEBA        VARCHAR2 (10);
   V_STRTLTXCD        VARCHAR2(6);
   V_DMAX             DATE;
   V_DMIN             DATE;


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

   --001 la ngoai bang
   --002 la noi bang
   IF (TYPEBA = '001') THEN
        V_STRTYPEBA := '0';
   ELSE
        V_STRTYPEBA := '123456789';
   END IF;
   if (TLTXCD <> 'ALL') THEN
        V_STRTLTXCD := TLTXCD ;
   else
        V_STRTLTXCD := '%%';
   end if;


  IF  (TLID <> 'ALL')
   THEN
      V_STRTLID := TLID;
   ELSE
      V_STRTLID := '%%';
   END IF;
   -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR
  SELECT  TL.TLTXCD , TL.BUSDATE,TL.TXNUM,TL.TXDESC ,GL.ACCTNO, /*NVL(GM.acname,'') acname,*/ NVL(MI.custid,'') custid, NVL(MI.custname,'') custname
  ,(CASE WHEN GL.DORC ='C' THEN GL.AMT ELSE 0 END )CAMT ,
   (CASE WHEN GL.DORC ='D' THEN GL.AMT ELSE 0 END )DAMT
        FROM TLLOG TL, /*GLMAST GM,*/ GLTRAN GL left JOIN MITRAN MI ON (gl.txdate  = mi.txdate
        AND gl.txnum   = mi.txnum
        AND gl.subtxno = mi.subtxno
        AND gl.dorc    = mi.dorc
        AND gl.acctno  = mi.acctno)
        WHERE GL.TXNUM = TL.TXNUM
--        AND GL.acctno  = GM.acctno
        AND TL.tltxcd Like V_STRTLTXCD
        AND TL.DELTD <>'Y'
        AND TL.BUSDATE <=TO_DATE (T_DATE ,'DD/MM/YYYY')
        AND TL.BUSDATE >=TO_DATE (F_DATE ,'DD/MM/YYYY')
        AND TL.BRID LIKE V_STRBRID
        AND TL.tlid LIKE V_STRTLID
        AND INSTR(V_STRTYPEBA,SUBSTR(GL.acctno,7,1)) >0
  UNION ALL

SELECT   TL.TLTXCD ,TL.BUSDATE,TL.TXNUM,TL.TXDESC ,GL.ACCTNO, /*NVL(GM.acname,'') acname,*/ NVL(MI.custid,'') custid, NVL(MI.custname,'') custname
,(CASE WHEN GL.DORC ='C' THEN GL.AMT ELSE 0 END )CAMT ,
 (CASE WHEN GL.DORC ='D' THEN GL.AMT ELSE 0 END )DAMT
        FROM (Select * from TLLOGALL where BUSDATE <=TO_DATE (T_DATE ,'DD/MM/YYYY')
        AND BUSDATE >=TO_DATE (F_DATE ,'DD/MM/YYYY')
        and TLTXCD Like V_STRTLTXCD
		) TL, /*GLMAST GM,*/
		(Select * from GLTRANA where bkdate <=TO_DATE (T_DATE ,'DD/MM/YYYY')
		and bkdate >= TO_DATE (F_DATE ,'DD/MM/YYYY')
		) GL left JOIN MITRAN MI ON
        (gl.txdate  = mi.txdate
        AND gl.txnum   = mi.txnum
        AND gl.subtxno = mi.subtxno
        AND gl.dorc    = mi.dorc
        AND gl.acctno  = mi.acctno)
        WHERE GL.TXNUM =TL.TXNUM
        AND GL.TXDATE =TL.TXDATE
--        AND GL.acctno = GM.acctno
        AND TL.DELTD <>'Y'
        AND TL.BRID LIKE V_STRBRID
        AND TL.tlid LIKE V_STRTLID
        AND INSTR(V_STRTYPEBA,SUBSTR(GL.acctno,7,1)) >0
        ORDER BY BUSDATE,TXNUM;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
