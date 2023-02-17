SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI1153MANUAL" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   p_AFACCTNO       IN      VARCHAR2,
   p_MATCHDATE      IN      VARCHAR2,
   p_DUEDATE        IN      VARCHAR2,
   p_ADVAMT         IN      number,
   p_BUSDATE        IN      VARCHAR2,
   p_FEEAMT         IN      number
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN


OPEN PV_REFCURSOR
    FOR
    select CF.CUSTODYCD, p_AFACCTNO AFACCTNO,  CF.FULLNAME, CF.IDCODE, CF.IDPLACE, TO_DATE(TO_CHAR(CF.IDDATE),'DD/MM/RRRR') IDDATE,
        TO_DATE(p_BUSDATE,'DD/MM/RRRR') BUSDATE,  TO_DATE(p_MATCHDATE,'DD/MM/RRRR') MATCHDATE, TO_DATE(p_DUEDATE,'DD/MM/RRRR') DUEDATE,
        p_ADVAMT ADVAMT, p_FEEAMT FEEAMT
     from cfmast cf, afmast af
    where cf.custid = af.custid
    and af.acctno = p_AFACCTNO;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
