SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0091" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE          IN       VARCHAR2,
   PV_CUSTODYCD    IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2
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
   V_STRSYMBOL         VARCHAR2(40);
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

   V_STRSYMBOL := replace(SYMBOL,' ','_');
   -- GET REPORT'S DATA
if to_date(I_DATE,'dd/MM/yyyy') = getcurrdate then
  OPEN PV_REFCURSOR
FOR
  select  * from (
  select
       I_DATE I_DATE_E,
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       sb.Symbol,
       t.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname NAMETP,
       sb.issuedate , -- ngay phat hanh
       sum(T.Trade) trade,
       sum(sb.parvalue*t.trade)  tong,
       NVL(mst.interestrate,SB.INTCOUPON) Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       '1' orderid,
       'TDCN' LOAI

  FROM -----VW_CASCHD_ALL CA,

       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       SBSECURITIES SB,ISSUERS ISS,afmast af,
      semast t,(SELECT ca.codeid,ca.interestrate FROM CAMAST ca where ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc
                                                                   UNION ALL SELECT ca.codeid,ca.interestrate FROM CAMASTHIST ca
                                                                  where  ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc) MST
      where t.codeid = sb.codeid and sb.symbol = V_STRSYMBOL
      and af.acctno = t.afacctno and   SB.ISSUERID = ISS.ISSUERID
      and af.custid = cf.custid
      and (cf.custodycd = PV_CUSTODYCD or PV_CUSTODYCD = 'ALL')
      --and t.txdate = to_date(I_DATE,'dd/MM/yyyy')
      and t.trade >0
      and sb.codeid = mst.codeid(+)
      group by
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') ,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       t.shareholdersid,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname ,
       sb.issuedate , -- ngay phat hanh
       mst.interestrate,
       SB.INTCOUPON,
       cf.custodycd,
       sb.expdate,
       sb.Symbol-- ngay den han


      union  all
      select
       I_DATE I_DATE_E,
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       sb.Symbol,
       t.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname NAMETP,
       sb.issuedate , -- ngay phat hanh
       sum(T.BLOCKED) trade,
       sum(sb.parvalue*t.BLOCKED)  tong,
       nvl(mst.interestrate,SB.INTCOUPON) Intcoupon ,
       cf.custodycd,
       sb.expdate,-- ngay den han
        '2' orderid,
       'HCCN' LOAI

  FROM -----VW_CASCHD_ALL CA,

       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       SBSECURITIES SB,ISSUERS ISS,afmast af,
      semast t,(SELECT ca.codeid,ca.interestrate FROM CAMAST ca where ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc
                                                                   UNION ALL SELECT ca.codeid,ca.interestrate FROM CAMASTHIST ca
                                                                  where  ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc) MST
      where t.codeid = sb.codeid and sb.symbol = V_STRSYMBOL
      and af.acctno = t.afacctno and   SB.ISSUERID = ISS.ISSUERID
      and af.custid = cf.custid
      and (cf.custodycd = PV_CUSTODYCD or PV_CUSTODYCD = 'ALL')
      --and t.txdate = to_date(I_DATE,'dd/MM/yyyy')
      and t.BLOCKED >0
      and sb.codeid = mst.codeid(+)
      group by
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') ,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       t.shareholdersid,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname ,
       sb.issuedate , -- ngay phat hanh
       mst.interestrate,
       cf.custodycd,
       sb.expdate,
       sb.Symbol,-- ngay den han
       SB.INTCOUPON

      UNION all

       select
       I_DATE I_DATE_E,
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       sb.Symbol,
       t.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname NAMETP,
       sb.issuedate , -- ngay phat hanh
       sum(T.Emkqtty) trade,
       sum(sb.parvalue*t.Emkqtty)  tong,
       nvl(mst.interestrate,SB.INTCOUPON) Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
        '3' orderid,
       'Phong toa' LOAI

  FROM -----VW_CASCHD_ALL CA,

       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       SBSECURITIES SB,ISSUERS ISS,afmast af,
      semast t,(SELECT ca.codeid,ca.interestrate FROM CAMAST ca where ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc
                                                                   UNION ALL SELECT ca.codeid,ca.interestrate FROM CAMASTHIST ca
                                                                  where  ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc) MST
      where t.codeid = sb.codeid and sb.symbol = V_STRSYMBOL
      and af.acctno = t.afacctno and   SB.ISSUERID = ISS.ISSUERID
      and af.custid = cf.custid
      and (cf.custodycd = PV_CUSTODYCD or PV_CUSTODYCD = 'ALL')
      --and t.txdate = to_date(I_DATE,'dd/MM/yyyy')
      and t.Emkqtty >0
      and sb.codeid = mst.codeid(+)
      group by
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') ,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       t.shareholdersid,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname ,
       sb.issuedate , -- ngay phat hanh
       mst.interestrate ,
       cf.custodycd,
       sb.expdate,
       sb.Symbol,-- ngay den han
       SB.INTCOUPON
      ) se
      order by se.shareholdersid,se.orderid;


  else
OPEN PV_REFCURSOR
FOR select * from (
  select
       I_DATE I_DATE_E,
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       sb.Symbol,
       se.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname NAMETP,
       sb.issuedate , -- ngay phat hanh
      -- SUM(T.Trade) TRADE,
     --  SUM(sb.parvalue*t.trade) tong,
     sum(se.trade-nvl((SELECT
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE')
            and busdate > TO_DATE(i_date,'dd/MM/rrrr')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))  TRADE,
       sum((se.trade-nvl((SELECT
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE')
            and busdate > TO_DATE(i_date,'dd/MM/rrrr')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))*sb.parvalue) tong,

       nvl(mst.interestrate,SB.INTCOUPON) Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       '1' orderid,
       'TDCN' LOAI

  FROM -----VW_CASCHD_ALL CA,

       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       SBSECURITIES SB,ISSUERS ISS,afmast af,
      semast se,
      (SELECT ca.codeid,ca.interestrate FROM CAMAST ca where ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc
                                                                   UNION ALL SELECT ca.codeid,ca.interestrate FROM CAMASTHIST ca
                                                                  where  ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc) MST
      where
        sb.symbol = V_STRSYMBOL
      and  sb.codeid = mst.codeid(+)
      and   SB.ISSUERID = ISS.ISSUERID
      and (cf.custodycd = PV_CUSTODYCD or PV_CUSTODYCD = 'ALL')
      and af.custid = cf.custid
      and se.afacctno = af.acctno
      and se.codeid = sb.codeid
      group by
      cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       se.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname ,
       sb.issuedate ,
        mst.interestrate,
       cf.custodycd,
       sb.expdate,-- ngay den han
       sb.issuedate,
       sb.Symbol,
       SB.INTCOUPON

 union all

 select
       I_DATE I_DATE_E,
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       sb.Symbol,
       se.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname NAMETP,
       sb.issuedate , -- ngay phat hanh
      -- SUM(T.Trade) TRADE,
     --  SUM(sb.parvalue*t.trade) tong,
     sum(se.blocked-nvl((SELECT
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BLOCKED')
            and busdate > TO_DATE(i_date,'dd/MM/rrrr')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))  TRADE,
       sum((se.blocked-nvl((SELECT
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BLOCKED')
            and busdate > TO_DATE(i_date,'dd/MM/rrrr')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))*sb.parvalue) tong,

       nvl(mst.interestrate,SB.INTCOUPON) Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       '2' orderid,
       'HCCN' LOAI

  FROM -----VW_CASCHD_ALL CA,

       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       SBSECURITIES SB,ISSUERS ISS,afmast af,
      semast se,
      (SELECT ca.codeid,ca.interestrate FROM CAMAST ca where ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc
                                                                   UNION ALL SELECT ca.codeid,ca.interestrate FROM CAMASTHIST ca
                                                                  where  ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc) MST
      where
        sb.symbol = V_STRSYMBOL
      and  sb.codeid = mst.codeid(+)
      and   SB.ISSUERID = ISS.ISSUERID
      and (cf.custodycd = PV_CUSTODYCD or PV_CUSTODYCD = 'ALL')
      and af.custid = cf.custid
      and se.afacctno = af.acctno
      and se.codeid = sb.codeid
      group by
      cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       se.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname ,
       sb.issuedate ,
        mst.interestrate,
       cf.custodycd,
       sb.expdate,-- ngay den han
       sb.issuedate,
       sb.Symbol,
       SB.INTCOUPON

    union all

    select
       I_DATE I_DATE_E,
       to_char(to_date(sb.expdate,'dd/MM/yyyy'),'yyyy') -to_char(to_date(sb.issuedate,'dd/MM/yyyy'),'yyyy') kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       sb.Symbol,
       se.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname NAMETP,
       sb.issuedate , -- ngay phat hanh
      -- SUM(T.Trade) TRADE,
     --  SUM(sb.parvalue*t.trade) tong,
     sum(se.EMKQTTY-nvl((SELECT
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('EMKQTTY')
            and busdate > TO_DATE(i_date,'dd/MM/rrrr')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))  TRADE,
       sum((se.EMKQTTY-nvl((SELECT
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('EMKQTTY')
            and busdate > TO_DATE(i_date,'dd/MM/rrrr')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))*sb.parvalue) tong,

       nvl(mst.interestrate,SB.INTCOUPON) Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       '3' orderid,
       'Phong toa' LOAI

  FROM -----VW_CASCHD_ALL CA,

       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       SBSECURITIES SB,ISSUERS ISS,afmast af,
      semast se,
      (SELECT ca.codeid,ca.interestrate FROM CAMAST ca where ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc
                                                                   UNION ALL SELECT ca.codeid,ca.interestrate FROM CAMASTHIST ca
                                                                  where  ca.catype = '027'  and  to_date(I_DATE,'dd/MM/rrrr') >= ca.fdateotc
                                                                 and to_date(I_date,'dd/MM/rrrr') <= ca.tdateotc) MST
      where
        sb.symbol = V_STRSYMBOL
      and  sb.codeid = mst.codeid(+)
      and   SB.ISSUERID = ISS.ISSUERID
      and (cf.custodycd = PV_CUSTODYCD or PV_CUSTODYCD = 'ALL')
      and af.custid = cf.custid
      and se.afacctno = af.acctno
      and se.codeid = sb.codeid
      group by
      cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       se.shareholdersid ,
       sb.sbtotalamt, -- tong gia tri phat hanh
       cf.mobilesms,
       cf.idtype,
       iss.fullname ,
       sb.issuedate ,
        mst.interestrate,
       cf.custodycd,
       sb.expdate,-- ngay den han
       sb.issuedate,
       sb.Symbol,
       SB.INTCOUPON
       ) se
       where se.trade >0 order by shareholdersid,se.orderid


      ;
end if;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
