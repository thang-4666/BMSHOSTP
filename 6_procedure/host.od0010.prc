SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0010" (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   pv_brid           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   f_date         IN       VARCHAR2,
   t_date         IN       VARCHAR2
)
IS
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- TheNN    06-Dec-06  Created
-- ---------   ------  -------------------------------------------
   v_stroption        VARCHAR2 (5);       -- A: All; B: Branch; S: Sub-branch
   v_strbrid          VARCHAR2 (4);              -- Used when v_numOption > 0

-- Declare program variables as shown above
BEGIN
   v_stroption := opt;

   IF (v_stroption <> 'A') AND (pv_brid <> 'ALL')
   THEN
      v_strbrid := pv_brid;
   ELSE
      v_strbrid := '%%';
   END IF;

   -- Get report's parameters


   -- End of getting report's parameters

   -- Get report's data
   IF (v_stroption <> 'A') AND (pv_brid <> 'ALL')
   THEN
      OPEN pv_refcursor
       FOR
SELECT AF.ACCTNO ACCTNO, AF.CUSTID CUSTID, CF.FULLNAME FULLNAME, CF.PHONE PHONE,
       OD.ORDERID ORDERID, OD.CODEID CODEID,OD.TXTIME TXTIME, OD.TXDATE TXDATE,
       AL2.CDCONTENT VIA, AL1.CDCONTENT EXECTYPE,OD.EXPRICE EXPRICE, OD.EXQTTY EXQTTY,
       SB.SYMBOL SYMBOL,cf.mobile
FROM AFMAST AF,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,( SELECT * FROM   ODMAST  UNION ALL  SELECT * FROM  ODMASTHIST)OD
, SBSECURITIES SB, ALLCODE AL1, ALLCODE AL2
WHERE AF.ACCTNO = OD.AFACCTNO   AND AF.CUSTID = CF.CUSTID AND OD.CODEID = SB.CODEID
      AND AF.ACTYPE NOT IN ('0000')
      AND OD.VOUCHER = 'P'AND AL1.CDTYPE = 'OD' AND AL1.CDNAME = 'EXECTYPE' AND  AL1.CDVAL=OD.EXECTYPE
      AND AL2.CDTYPE='OD' AND  AL2.CDNAME ='VIA'AND AL2.CDVAL=OD.VIA
      AND OD.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
      AND OD.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
      AND SUBSTR(AF.acctno ,1,4) LIKE v_strbrid
     ORDER BY AF.acctno, OD.txtime, OD.txdate;

  ELSE
OPEN pv_refcursor
       FOR
      SELECT AF.ACCTNO ACCTNO, AF.CUSTID CUSTID, CF.FULLNAME FULLNAME, CF.PHONE PHONE,
       OD.ORDERID ORDERID, OD.CODEID CODEID,OD.TXTIME TXTIME, OD.TXDATE TXDATE,
       AL2.CDCONTENT VIA, AL1.CDCONTENT EXECTYPE,OD.EXPRICE EXPRICE, OD.EXQTTY EXQTTY,
       SB.SYMBOL SYMBOL,cf.mobile
FROM AFMAST AF,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,( SELECT * FROM   ODMAST  UNION ALL  SELECT * FROM  ODMASTHIST)OD
, SBSECURITIES SB, ALLCODE AL1, ALLCODE AL2
WHERE AF.ACCTNO = OD.AFACCTNO   AND AF.CUSTID = CF.CUSTID AND OD.CODEID = SB.CODEID
      AND AF.ACTYPE NOT IN ('0000')
     AND OD.VOUCHER = 'P'  AND AL1.CDTYPE = 'OD' AND AL1.CDNAME = 'EXECTYPE' AND  AL1.CDVAL=OD.EXECTYPE
      AND AL2.CDTYPE='OD' AND  AL2.CDNAME ='VIA'AND AL2.CDVAL=OD.VIA
      AND OD.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
      AND OD.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')

     ORDER BY AF.acctno, OD.txtime, OD.txdate;

   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- Procedure

 
 
 
 
/
