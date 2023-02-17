SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0065" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   I_DATE          IN       VARCHAR2
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
   V_CACODE            VARCHAR2(100);

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

   -- GET REPORT'S PARAMETERS
   IF (CACODE <> 'ALL' OR CACODE <> '')
   THEN
      V_CACODE :=  CACODE;
   ELSE
      V_CACODE := '%%';
   END IF;

   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR select t.I_DATE_E
       , t.optsymbol,
       t.actiondate,-- ngay thanh toan
       t.fullname,-- ten trai chu
       t.address,
       t.address_E,
       t.idcode,
       t.iddate,
       t.idplace,
       t.idplace_E,
       t.country,-- quoc gia
       t.mobilesms,
       t.issfullname, -- ten chung khoan
       t.officename , -- ten tieng anh
       t.issuedate , -- ngay phat hanh
       t.parvalue,
       t.Intcoupon,
       t.reportdate,-- ngay chot
       t.custodycd,
       t.dayofyear,-- ngay tren nam tinh la
       t.expdate,-- ngay den han
       sum(t.qtty) qtty,
       sum(tongmg) tongmg,
       t.fdateotc,  -- ngày bat dau tinh lai
       t.tdateotc, -- ngay ket thuc tinh lai
       t.songay,
       t.interestrate, -- lai suat ky tinh lai
       --t.amt, -- trai tuc
       t.LOAI, -- tdcn
       t.shareholdersid, --  mscd
      t.bankacname, -- ten tai khoan
       t.bankname,-- ten ngan hang
       t.bankacc, -- -- so tai khoan
       t.order_id,
       t.internation,
       TO_NUMBER(t.interestrate) RATECA

        from (
  select 'Hà Nội, ngày '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' tháng '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' năm '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
       ,to_date(I_DATE,'dd/MM/yyyy') I_DATE_E
       , mst.optsymbol,
       mst.actiondate,-- ngay thanh toan
       cf.fullname,-- ten trai chu
       cf.address,
       fn_convert_to_vn(cf.address) address_E,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       fn_convert_to_vn(cf.idplace) idplace_E,
       AL.cdcontent country,-- quoc gia
       cf.mobilesms,
       iss.fullname issfullname, -- ten chung khoan
       iss.officename , -- ten tieng anh
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       mst.reportdate,-- ngay chot
       cf.custodycd,
       mst.dayofyear,-- ngay tren nam tinh la
       sb.expdate,-- ngay den han
       se.trade-nvl((SELECT
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE')
            and busdate > mst.reportdate
            and acctno = se.acctno and symbol = mst.optsymbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0)  qtty,
       (se.trade-nvl((SELECT
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE')
            and busdate > mst.reportdate
            and acctno = se.acctno
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))*sb.parvalue tongmg,
       mst.fdateotc,  -- ngày bat dau tinh lai
       mst.tdateotc, -- ngay ket thuc tinh lai
       (mst.tdateotc-mst.fdateotc) + 1 songay,
       mst.interestrate, -- lai suat ky tinh lai
       --ca.amt, -- trai tuc
       'TDCN' LOAI, -- tdcn
       max(se.shareholdersid) shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
       '1' order_id,
       cf.internation


  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
       ALLCODE AL,
       SBSECURITIES SB,
       ISSUERS ISS,
       (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       (SELECT * FROM caschd UNION ALL SELECT * FROM caschdhist) ca,
       semast se,(select *
  from (select c.cfcustid,
               MAX(bankacname) bankacname,
               MAX(bankname) bankname,
               MAX(bankacc) bankacc
          from cfotheracc c
         where NVL(c.citybank, 'A') = 'OTC'
         group by c.cfcustid
        UNION ALL
        select c.cfcustid,
               MAX(bankacname) bankacname,
               MAX(bankname) bankname,
               MAX(bankacc) bankacc
          from cfotheracc c
         where NVL(c.citybank, 'A') != 'OTC'
         and c.cfcustid not in ( select c.cfcustid
          from cfotheracc c
         where NVL(c.citybank, 'A') = 'OTC')
         group by c.cfcustid)) bank
 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND CA.CODEID = SB.CODEID
   AND SB.ISSUERID = ISS.ISSUERID
   AND CA.DELTD <> 'Y'
   AND CA.CAMASTID = MST.CAMASTID
   AND MST.CATYPE = '027'
   AND CA.CAMASTID = CACODE
   and se.afacctno = af.acctno
   and sb.codeid = se.codeid
 --  and se.trade >0
   and cf.custid = bank.cfcustid(+)
   group by
    mst.optsymbol,
       mst.actiondate,-- ngay thanh toan
       cf.fullname,-- ten trai chu
       cf.address,
       fn_convert_to_vn(cf.address) ,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       fn_convert_to_vn(cf.idplace) ,
       AL.cdcontent ,-- quoc gia
       cf.mobilesms,
       iss.fullname , -- ten chung khoan
       iss.officename , -- ten tieng anh
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       mst.reportdate,-- ngay chot
       cf.custodycd,
       mst.dayofyear,-- ngay tren nam tinh la
       sb.expdate,-- ngay den han
      mst.fdateotc,  -- ngày bat dau tinh lai
       mst.tdateotc, -- ngay ket thuc tinh lai
      -- (mst.tdateotc-mst.fdateotc) + 1 ,
       mst.interestrate, -- lai suat ky tinh lai
       --ca.amt, -- trai tuc
      -- 'TDCN' LOAI, -- tdcn
      -- se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc ,-- -- so tai khoan
       se.trade,se.acctno, cf.internation

 union all

 select 'Hà Nội, ngày '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' tháng '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' năm '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
       ,to_date(I_DATE,'dd/MM/yyyy') I_DATE_E
       , mst.optsymbol,
       mst.actiondate,-- ngay thanh toan
       cf.fullname,-- ten trai chu
       cf.address,
       fn_convert_to_vn(cf.address) address_E,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       fn_convert_to_vn(cf.idplace) idplace_E,
       AL.cdcontent country,-- quoc gia
       cf.mobilesms,
       iss.fullname issfullname, -- ten chung khoan
       iss.officename , -- ten tieng anh
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       mst.reportdate,-- ngay chot
       cf.custodycd,
       mst.dayofyear,-- ngay tren nam tinh la
       sb.expdate,-- ngay den han
       se.blocked-nvl((SELECT
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BLOCKED')
            and busdate > mst.reportdate
            and acctno = se.acctno and symbol = mst.optsymbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0)  qtty,
       (se.Blocked-nvl((SELECT
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BLOCKED')
            and busdate > mst.reportdate
            and acctno = se.acctno
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))*sb.parvalue tongmg,
       mst.fdateotc,  -- ngày bat dau tinh lai
       mst.tdateotc, -- ngay ket thuc tinh lai
       (mst.tdateotc-mst.fdateotc) + 1 songay,
       mst.interestrate, -- lai suat ky tinh lai
     --  ca.amt, -- trai tuc
       'HCCN' LOAI, -- tdcn
       max(se.shareholdersid) shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
        '2' order_id,
        cf.internation


  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
       ALLCODE AL,
       SBSECURITIES SB,
       ISSUERS ISS,
       (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       (SELECT * FROM caschd UNION ALL SELECT * FROM caschdhist) ca,
       semast se,(select *
  from (select c.cfcustid,
               MAX(bankacname) bankacname,
               MAX(bankname) bankname,
               MAX(bankacc) bankacc
          from cfotheracc c
         where NVL(c.citybank, 'A') = 'OTC'
         group by c.cfcustid
        UNION ALL
        select c.cfcustid,
               MAX(bankacname) bankacname,
               MAX(bankname) bankname,
               MAX(bankacc) bankacc
          from cfotheracc c
         where NVL(c.citybank, 'A') != 'OTC'
         and c.cfcustid not in ( select c.cfcustid
          from cfotheracc c
         where NVL(c.citybank, 'A') = 'OTC')
         group by c.cfcustid)) bank
 WHERE
   AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND CA.CODEID = SB.CODEID
   AND SB.ISSUERID = ISS.ISSUERID
   AND CA.DELTD <> 'Y'
   AND CA.CAMASTID = MST.CAMASTID
   AND MST.CATYPE = '027'
   AND CA.CAMASTID = CACODE
   and se.afacctno = af.acctno
   and sb.codeid = se.codeid
  -- and se.blocked >0
   and cf.custid = bank.cfcustid(+)
   group by  mst.optsymbol,
       mst.actiondate,-- ngay thanh toan
       cf.fullname,-- ten trai chu
       cf.address,
       fn_convert_to_vn(cf.address) ,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       fn_convert_to_vn(cf.idplace) ,
       AL.cdcontent ,-- quoc gia
       cf.mobilesms,
       iss.fullname , -- ten chung khoan
       iss.officename , -- ten tieng anh
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       mst.reportdate,-- ngay chot
       cf.custodycd,
       mst.dayofyear,-- ngay tren nam tinh la
       sb.expdate,-- ngay den han
      mst.fdateotc,  -- ngày bat dau tinh lai
       mst.tdateotc, -- ngay ket thuc tinh lai
      -- (mst.tdateotc-mst.fdateotc) + 1 ,
       mst.interestrate, -- lai suat ky tinh lai
      -- ca.amt, -- trai tuc
      -- 'TDCN' LOAI, -- tdcn
      -- se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc ,-- -- so tai khoan
       se.blocked,se.acctno, cf.internation


UNION  ALL

select 'Hà Nội, ngày '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' tháng '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' năm '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
       ,to_date(I_DATE,'dd/MM/yyyy') I_DATE_E
       , mst.optsymbol,
       mst.actiondate,-- ngay thanh toan
       cf.fullname,-- ten trai chu
       cf.address,
        fn_convert_to_vn(cf.address) address_E,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       fn_convert_to_vn(cf.idplace) idplace_E,
       AL.cdcontent country,-- quoc gia
       cf.mobilesms,
       iss.fullname issfullname, -- ten chung khoan
       iss.officename , -- ten tieng anh
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       mst.reportdate,-- ngay chot
       cf.custodycd,
       mst.dayofyear,-- ngay tren nam tinh la
       sb.expdate,-- ngay den han
       se.emkqtty-nvl((SELECT
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('EMKQTTY')
            and busdate > mst.reportdate
            and acctno = se.acctno and symbol = mst.optsymbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0)  qtty,
       (se.Emkqtty-nvl((SELECT
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('EMKQTTY')
            and busdate > mst.reportdate
            and acctno = se.acctno
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0))*sb.parvalue tongmg,
       mst.fdateotc,  -- ngày bat dau tinh lai
       mst.tdateotc, -- ngay ket thuc tinh lai
       (mst.tdateotc-mst.fdateotc) + 1 songay,
       mst.interestrate, -- lai suat ky tinh lai
      -- ca.amt, -- trai tuc
       'Phong toa' LOAI, -- tdcn
       max(se.shareholdersid) shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
        '3' order_id,
        cf.internation


  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
       ALLCODE AL,
       SBSECURITIES SB,
       ISSUERS ISS,
       (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       (SELECT * FROM caschd UNION ALL SELECT * FROM caschdhist) ca,
       semast se,(select *
  from (select c.cfcustid,
               MAX(bankacname) bankacname,
               MAX(bankname) bankname,
               MAX(bankacc) bankacc
          from cfotheracc c
         where NVL(c.citybank, 'A') = 'OTC'
         group by c.cfcustid
        UNION ALL
        select c.cfcustid,
               MAX(bankacname) bankacname,
               MAX(bankname) bankname,
               MAX(bankacc) bankacc
          from cfotheracc c
         where NVL(c.citybank, 'A') != 'OTC'
         and c.cfcustid not in ( select c.cfcustid
          from cfotheracc c
         where NVL(c.citybank, 'A') = 'OTC')
         group by c.cfcustid)) bank
 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND CA.CODEID = SB.CODEID
   AND SB.ISSUERID = ISS.ISSUERID
   AND CA.DELTD <> 'Y'
   AND CA.CAMASTID = MST.CAMASTID
   AND MST.CATYPE = '027'
   AND CA.CAMASTID = CACODE
   and se.afacctno = af.acctno
   and sb.codeid = se.codeid
  -- and se.emkqtty >0
   and cf.custid = bank.cfcustid(+)
 group by  mst.optsymbol,
       mst.actiondate,-- ngay thanh toan
       cf.fullname,-- ten trai chu
       cf.address,
       fn_convert_to_vn(cf.address) ,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       fn_convert_to_vn(cf.idplace) ,
       AL.cdcontent ,-- quoc gia
       cf.mobilesms,
       iss.fullname , -- ten chung khoan
       iss.officename , -- ten tieng anh
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       mst.reportdate,-- ngay chot
       cf.custodycd,
       mst.dayofyear,-- ngay tren nam tinh la
       sb.expdate,-- ngay den han
      mst.fdateotc,  -- ngày bat dau tinh lai
       mst.tdateotc, -- ngay ket thuc tinh lai
      -- (mst.tdateotc-mst.fdateotc) + 1 ,
       mst.interestrate, -- lai suat ky tinh lai
       ca.amt, -- trai tuc
      -- 'TDCN' LOAI, -- tdcn
      -- se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc ,-- -- so tai khoan
       se.emkqtty,se.acctno, cf.internation ) t

       WHERE t.qtty >0
       group by  t.I_DATE_E
       , t.optsymbol,
       t.actiondate,-- ngay thanh toan
       t.fullname,-- ten trai chu
       t.address,
       t.address_E,
       t.idcode,
       t.iddate,
       t.idplace,
       t.idplace_E,
       t.country,-- quoc gia
       t.mobilesms,
       t.issfullname, -- ten chung khoan
       t.officename , -- ten tieng anh
       t.issuedate , -- ngay phat hanh
       t.parvalue,
       t.Intcoupon,
       t.reportdate,-- ngay chot
       t.custodycd,
       t.dayofyear,-- ngay tren nam tinh la
       t.expdate,-- ngay den han
       t.fdateotc,  -- ngày bat dau tinh lai
       t.tdateotc, -- ngay ket thuc tinh lai
       t.songay,
       t.interestrate, -- lai suat ky tinh lai
      -- t.amt, -- trai tuc
       t.LOAI, -- tdcn
       t.shareholdersid, --  mscd
       t.bankacname, -- ten tai khoan
       t.bankname,-- ten ngan hang
       t.bankacc,t.order_id,internation -- -- so tai khoan
       order by t.custodycd,t.shareholdersid,t.order_id
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
