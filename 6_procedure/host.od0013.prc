SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0013" (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   pv_brid           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   d_date         IN       VARCHAR2
)
IS
-- BAO CAO GIAO DICH CUA CO DONG LON
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- AnhLTV   18-Dec-06  Created
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
          SELECT CUSTID, FULLNAME, RATE_AFTER, ROLECD,
                 ADDRESS, ORDERID ,SYMBOL, MATCHQTTY,
                 MATCHPRICE , ODVALUE, TXDATE
          FROM
          (SELECT ISS.CUSTID CUSTID, ISS.fullname FULLNAME,
                  round(((od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice)/(od.orderqtty * od.quoteprice)), 4) * 100  RATE_AFTER,
                  AL.cdcontent ROLECD, CF.address ADDRESS, OD.orderid ORDERID,
                  SE.symbol SYMBOL, IO.matchqtty  MATCHQTTY,
                  IO.matchprice MATCHPRICE, IO.matchqtty*IO.matchprice ODVALUE,
                  IO.txdate TXDATE, CF.brid
           FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ISSUER_MEMBER ISS, ALLCODE AL, ODMAST OD,
                 SECURITIES_INFO SE, IOD IO, BRGRP BR
           WHERE CF.custid = ISS.custid
                and iss.rolecd = AL.cdval
                AND iss.custid = od.custid
                and od.codeid = se.codeid
                and od.orderid = io.orgorderid
                and al.cdname = 'ROLECD' and al.cdtype = 'SA'
                AND CF.brid = br.brid
                AND ISS.rolecd = '004'
                AND (od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice) > 0

           UNION ALL
           SELECT ISS.CUSTID CUSTID, ISS.fullname FULLNAME,
                  round(((od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice)/(od.orderqtty * od.quoteprice)), 4) * 100  RATE_AFTER,
                  AL.cdcontent ROLECD, CF.address ADDRESS, OD.orderid ORDERID,
                  SE.symbol SYMBOL, IO.matchqtty  MATCHQTTY,
                  IO.matchprice MATCHPRICE, IO.matchqtty*IO.matchprice ODVALUE,
                  IO.txdate TXDATE, CF.brid
           FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ISSUER_MEMBER ISS, ALLCODE AL, ODMASTHIST OD,
                 SECURITIES_INFO SE, IODHIST IO, BRGRP BR
           WHERE CF.custid = ISS.custid
                and iss.rolecd = AL.cdval
                AND iss.custid = od.custid
                and od.codeid = se.codeid
                and od.orderid = io.orgorderid
                and al.cdname = 'ROLECD' and al.cdtype = 'SA'
                AND CF.brid = br.brid
                AND ISS.rolecd = '004'
                AND (od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice) > 0
          ) v
          WHERE v.txdate = TO_DATE(d_date, 'DD/MM/YYYY')
                AND v.brid LIKE v_strbrid;
   ELSE
      OPEN pv_refcursor
       FOR
         SELECT CUSTID, FULLNAME, RATE_AFTER, ROLECD,
                 ADDRESS, ORDERID ,SYMBOL, MATCHQTTY,
                 MATCHPRICE , ODVALUE, TXDATE
          FROM
          (SELECT ISS.CUSTID CUSTID, ISS.fullname FULLNAME,
                  round(((od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice)/(od.orderqtty * od.quoteprice)), 4) * 100  RATE_AFTER,
                  AL.cdcontent ROLECD, CF.address ADDRESS, OD.orderid ORDERID,
                  SE.symbol SYMBOL, IO.matchqtty  MATCHQTTY,
                  IO.matchprice MATCHPRICE, IO.matchqtty*IO.matchprice ODVALUE,
                  IO.txdate TXDATE, CF.brid
           FROM CFMAST CF, ISSUER_MEMBER ISS, ALLCODE AL, ODMAST OD,
                 SECURITIES_INFO SE, IOD IO, BRGRP BR
           WHERE CF.custid = ISS.custid
                and iss.rolecd = AL.cdval
                AND iss.custid = od.custid
                and od.codeid = se.codeid
                and od.orderid = io.orgorderid
                and al.cdname = 'ROLECD' and al.cdtype = 'SA'
                AND CF.brid = br.brid
                AND ISS.rolecd = '004'
                AND (od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice) > 0

           UNION ALL
           SELECT ISS.CUSTID CUSTID, ISS.fullname FULLNAME,
                  round(((od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice)/(od.orderqtty * od.quoteprice)), 4) * 100  RATE_AFTER,
                  AL.cdcontent ROLECD, CF.address ADDRESS, OD.orderid ORDERID,
                  SE.symbol SYMBOL, IO.matchqtty  MATCHQTTY,
                  IO.matchprice MATCHPRICE, IO.matchqtty*IO.matchprice ODVALUE,
                  IO.txdate TXDATE, CF.brid
           FROM CFMAST CF, ISSUER_MEMBER ISS, ALLCODE AL, ODMASTHIST OD,
                 SECURITIES_INFO SE, IODHIST IO, BRGRP BR
           WHERE CF.custid = ISS.custid
                and iss.rolecd = AL.cdval
                AND iss.custid = od.custid
                and od.codeid = se.codeid
                and od.orderid = io.orgorderid
                and al.cdname = 'ROLECD' and al.cdtype = 'SA'
                AND CF.brid = br.brid
                AND ISS.rolecd = '004'
                AND (od.orderqtty * od.quoteprice - IO.matchqtty*IO.matchprice) > 0
          ) v
          WHERE v.txdate = TO_DATE(d_date, 'DD/MM/YYYY');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- Procedure

 
 
 
 
/
