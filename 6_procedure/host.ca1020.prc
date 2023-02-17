SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA1020" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRSYMBOL           VARCHAR2 (30);
   V_STRTRADEPLACE        VARCHAR2 (30);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := BRID;


   IF (PV_SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := PV_SYMBOL||'%';
   ELSE
      V_STRSYMBOL := '%%';
   END IF;

   IF (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
   ELSE
      V_STRTRADEPLACE := '%%';
   END IF;



OPEN PV_REFCURSOR
  FOR

select txdate,symbol,iss.fullname,  AL1.CDCONTENT  frtradeplace , AL2.CDCONTENT  totradeplace,ctype
from setradeplace setr, sbsecurities sb,issuers iss,allcode al1 ,allcode al2
where setr.codeid = sb.codeid and sb.issuerid =iss.issuerid
and setr.frtradeplace  = al1.cdval and al1.cdname ='TRADEPLACE' AND al1.CDTYPE ='OD'
and setr.totradeplace  = al2.cdval and al2.cdname ='TRADEPLACE' AND al2.CDTYPE ='OD'
AND SB.SYMBOL LIKE V_STRSYMBOL
AND SB.TRADEPLACE LIKE V_STRTRADEPLACE
ORDER BY SB.SYMBOL , TXDATE

;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
