SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci1029 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2
     )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STRSYMBOL          VARCHAR2 (20);

 CUR            PKG_REPORT.REF_CURSOR;
 V_BRID    VARCHAR2 (5);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN

IF  (I_BRID <> 'ALL')
THEN
      V_BRID := upper(I_BRID);
ELSE
   V_BRID := '%';
END IF;

 -- GET REPORT'S DATA

 OPEN PV_REFCURSOR
   FOR
SELECT to_date( I_DATE,'dd/mm/yyyy') I_DATE,  cf.custodycd,CF.brid, MAX(CF.FULLNAME) FULLNAME , MAX(CF.IDCODE) IDCODE, sum( CASE WHEN ci.corebank='N' THEN  ci.balance ELSE 0 END   - nvl(citr.namt,0)) balance
FROM cimast ci ,afmast af,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
        (
        SELECT  sum(CASE WHEN tr.txtype ='C' THEN  NAMT ELSE -NAMT END ) NAMT , ACCTNO
        FROM vw_citran_gen tr
        WHERE tr.field ='BALANCE'
        AND tr.deltd <>'Y'
        AND tr.corebank='N'
        AND tr. busdate > to_date(I_DATE,'dd/mm/yyyy')
        GROUP BY ACCTNO
          ) citr
WHERE ci.acctno = citr.acctno (+)
AND ci.acctno =af.acctno
AND af.custid = cf.custid
and cf.custatcom='Y'
AND CF.brid LIKE  V_BRID
AND SUBSTR(CF.CUSTODYCD,4,1) <>'P'
GROUP BY  cf.custodycd,CF.brid
ORDER BY CF.BRID, cf.custodycd  ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
