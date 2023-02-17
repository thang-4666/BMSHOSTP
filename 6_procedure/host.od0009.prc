SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0009" (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   brid           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   f_date         IN       VARCHAR2,
   t_date         IN       VARCHAR2,
   acctno         IN       VARCHAR2,
   codeid         IN       VARCHAR2,
   exectype       IN       VARCHAR2

)
IS
--
-- Purpose: Briefly explain the functionality of the procedure
--DANH SACH LENH THOA THUAN CHUYEN LEN TRUNG TAM TPHCM

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- NAMNT   21-Nov-06  Created
-- ---------   ------  -------------------------------------------
   v_stroption     VARCHAR2 (5);          -- A: All; B: Branch; S: Sub-branch
   v_strbrid       VARCHAR2 (4);                 -- Used when v_numOption > 0
   v_strcodeid     VARCHAR2 (6);
   v_strexectype   VARCHAR2 (10);
   v_stracctno     VARCHAR2 (50);
-- Declare program variables as shown above
BEGIN
   v_stroption := opt;

   IF (v_stroption <> 'A') AND (brid <> 'ALL')
   THEN
      v_strbrid := brid;
   ELSE
      v_strbrid := '%%';
   END IF;

   -- Get report's parameters
   IF (codeid <> 'ALL')
   THEN
      v_strcodeid := codeid;
   ELSE
      v_strcodeid := '%%';
   END IF;

   IF (acctno <> 'ALL')
   THEN
      v_stracctno := acctno;
   ELSE
      v_stracctno := '%%';
   END IF;

   IF (exectype <> 'ALL')
   THEN
      v_strexectype := exectype;
   ELSE
      v_strexectype := '%%';
   END IF;

   -- End of getting report's parameters

   -- Get report's data
   IF (v_stroption <> 'A') AND (brid <> 'ALL')
   THEN
      OPEN pv_refcursor
       FOR


          SELECT issuerid, exectype1, symbol, orderid,  txtime,
                 quoteprice, orderqtty, exectype,V.custid,afacctno
            FROM (SELECT sb.issuerid issuerid, al.cdcontent exectype1,
                         od.exectype exectype, sb.symbol symbol,
                         od.orderid orderid, od.txtime txtime,
                         od.quoteprice quoteprice, od.orderqtty orderqtty,
                         od.custid custid, od.afacctno afacctno,
                         od.codeid codeid, br.brid brid,od.txdate txdate
                    FROM odmast od, sbsecurities sb, allcode al, brgrp br,OOD oo
                   WHERE od.codeid = sb.codeid
                     AND oo.orgorderid= OD.orderid
                     AND al.cdtype = 'OD'
                     AND al.cdname = 'EXECTYPE'
                     AND al.cdval = od.exectype
                     AND SUBSTR (od.afacctno, 1, 4) = TRIM (br.brid)
                     AND sb.tradeplace = 001
                     AND OD.matchtype ='P'
                  UNION ALL
                SELECT sb.issuerid issuerid, al.cdcontent exectype1,
                         od.exectype exectype, sb.symbol symbol,
                         od.orderid orderid, od.txtime txtime,
                         od.quoteprice quoteprice, od.orderqtty orderqtty,
                         od.custid custid, od.afacctno afacctno,
                         od.codeid codeid, br.brid brid,od.txdate txdate
                    FROM odmasthist od, sbsecurities sb, allcode al, brgrp br,OODhist oo
                   WHERE od.codeid = sb.codeid
                     AND oo.orgorderid= OD.orderid
                     AND al.cdtype = 'OD'
                     AND al.cdname = 'EXECTYPE'
                     AND al.cdval = od.exectype
                     AND SUBSTR (od.afacctno, 1, 4) = TRIM (br.brid)
                     AND sb.tradeplace = 001
                     AND OD.matchtype ='P') v, afmast af
           WHERE v.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
             AND v.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
             and v.afacctno = af.acctno and af.actype not in ('0000')
             AND v.exectype LIKE v_strexectype
             AND v.afacctno LIKE v_stracctno
             AND v.exectype LIKE v_strexectype
             AND v.brid LIKE v_strbrid


             ;
   ELSE
      OPEN pv_refcursor
       FOR
          SELECT issuerid, exectype1, symbol, orderid,  txtime,
                 quoteprice, orderqtty, exectype,V.custid,afacctno
            FROM (SELECT sb.issuerid issuerid, al.cdcontent exectype1,
                         od.exectype exectype, sb.symbol symbol,
                         od.orderid orderid, od.txtime txtime,
                         od.quoteprice quoteprice, od.orderqtty orderqtty,
                         od.custid custid, od.afacctno afacctno,
                         od.codeid codeid, br.brid brid,od.txdate txdate
                    FROM odmast od, sbsecurities sb, allcode al, brgrp br,OOD oo
                   WHERE od.codeid = sb.codeid
                     AND oo.orgorderid= OD.orderid
                     AND al.cdtype = 'OD'
                     AND al.cdname = 'EXECTYPE'
                     AND al.cdval = od.exectype
                     AND SUBSTR (od.afacctno, 1, 4) = TRIM (br.brid)
                     AND sb.tradeplace = 001
                     AND OD.matchtype ='P'
                  UNION ALL
                SELECT sb.issuerid issuerid, al.cdcontent exectype1,
                         od.exectype exectype, sb.symbol symbol,
                         od.orderid orderid, od.txtime txtime,
                         od.quoteprice quoteprice, od.orderqtty orderqtty,
                         od.custid custid, od.afacctno afacctno,
                         od.codeid codeid, br.brid brid,od.txdate txdate
                    FROM odmasthist od, sbsecurities sb, allcode al, brgrp br,OODhist oo
                   WHERE od.codeid = sb.codeid
                     AND oo.orgorderid= OD.orderid
                     AND al.cdtype = 'OD'
                     AND al.cdname = 'EXECTYPE'
                     AND al.cdval = od.exectype
                     AND SUBSTR (od.afacctno, 1, 4) = TRIM (br.brid)
                     AND sb.tradeplace = 001
                     AND OD.matchtype ='P') v, afmast af
           WHERE v.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
             AND v.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
             and v.afacctno = af.acctno and af.actype not in ('0000')
             AND v.exectype LIKE v_strexectype
             AND v.afacctno LIKE v_stracctno
             AND v.exectype LIKE v_strexectype;

   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- Procedure

 
 
 
 
/
