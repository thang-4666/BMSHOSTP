SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE1020" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
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
SELECT se.SYMBOL,iss.fullname,ceilingprice,floorprice ,basicprice , al.cdcontent tradeplace
FROM securities_info_hist se,sbsecurities sb,issuers iss ,allcode al
where se.codeid = sb.codeid and sb.issuerid =iss.issuerid and sb.tradeplace = al.cdval
and  al.cdname = 'TRADEPLACE' and al.cdtype ='OD'
and histdate =to_date(I_DATE,'dd/mm/yyyy')
and se.symbol like V_STRSYMBOL
and sb.tradeplace like  V_STRTRADEPLACE
and tradeplace in ('001','002','005')
order by sb.tradeplace, symbol
 ;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
