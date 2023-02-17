SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0095" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE          IN       VARCHAR2,
   T_DATE          IN       VARCHAR2,
   PV_AFTYPE    IN       VARCHAR2,
   PV_SECTYPE         IN       VARCHAR2,
   PV_ISSUE    IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO DANH SACH NGUOI SO HUU CHUNG KHOAN LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   15-12-2011   CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2(5);
   V_STRBRID           VARCHAR2(40);
   V_INBRID            VARCHAR2(4);
   V_PV_AFTYPE         VARCHAR2(40);
   V_PV_SECTYPE         VARCHAR2(40);
   v_PV_ISSUE VARCHAR2(40);
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSif (V_STROPTION = 'B') then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
   else
        V_STRBRID := V_INBRID;
   END IF;

   IF (PV_AFTYPE <> 'ALL') THEN
    V_PV_AFTYPE := PV_AFTYPE;
  ELSE
    V_PV_AFTYPE := '%%';
  END IF;

   IF (PV_SECTYPE <> 'ALL') THEN
    V_PV_SECTYPE := PV_SECTYPE;
  ELSE
    V_PV_SECTYPE := '%%';
  END IF;
   IF (PV_ISSUE <> 'ALL') THEN
    V_PV_ISSUE := PV_ISSUE;
  ELSE
    V_PV_ISSUE := '%%';
  END IF;
   -- GET REPORT'S DATA

  OPEN PV_REFCURSOR
FOR
select to_char(i.txdate,'dd/MM/rrrr') ngaydat, -- ngay dat
       to_char(i.busdate,'dd/MM/rrrr') ngaykhop,  -- ngay khop
       cf.custodycd,  --- tai khoan
       cf.fullname, -- ten nha dau tu
       i.exeqtty ,-- khoi luong khop
       i.EXEAMT,-- gia tri khop
       i.feeamt, -- phi gd
       i.brfeeamt , -- phi hoa hong
       a.cdcontent,-- loai giao dich
       aft.rfacctno, -- tai khoan ngan quy
       F_DATE F_DATE,
       T_DATE T_DATE,
       sb.symbol,
       iss.fullname tenccq,
       af.acctno
  from

       (SELECT * FROM IBDEALS i where i.status = 'E') i, afmast af, (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf , allcode a,AFEXTACCT aft,
                                      (select distinct sb.issuerid,sb.sectype,sb.codeid,sb.symbol from sbsecurities sb) sb,issuers iss
 where
 af.custid = cf.custid
 and i.afacctno = af.acctno
 and a.cdname = 'IBDEALTYPE'
 and a.cdtype = 'SA'
 and i.dealtype = a.cdval
 and aft.afacctno = af.acctno
 and aft.status = 'A'
 and i.busdate >= to_date(f_date,'dd/MM/rrrr')
 and i.busdate <= to_date(t_date,'dd/MM/rrrr')
 and aft.ordertype like  v_PV_AFTYPE
 and aft.issuerid = sb.issuerid
 and sb.issuerid like v_PV_ISSUE
 and sb.symbol like V_PV_SECTYPE
 and iss.issuerid = sb.issuerid
 and i.codeid = sb.codeid ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
