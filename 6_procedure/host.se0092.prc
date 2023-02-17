SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0092" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE          IN       VARCHAR2,
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

OPEN PV_REFCURSOR
FOR
    /*



    */
  select * from (select  'TP.HCM, '
                        || UTF8NUMS.C_CONST_DATE_VI ||' '||to_char(to_date(I_DATE,'DD/MM/RRRR'),'dd')
                        ||' ' || UTF8NUMS.C_CONST_MONTH_VI ||' '|| to_char(to_date(I_DATE,'DD/MM/RRRR'),'MM')
                        ||' ' || UTF8NUMS.C_CONST_YEAR_VI || ' '|| to_char(to_date(I_DATE,'DD/MM/RRRR'),'RRRR') I_DATE
       ,to_date(I_DATE,'DD/MM/RRRR') I_DATE_E,
       iss.fullname issfullname, -- ten to chuc phat hanh = ten chung khoan
       iss.officename , -- ten tieng anh
       iss.address  issaddress, -- dia chi
       iss.operateno,-- giay phep dkkd
       iss.licensedate,
       iss.lincenseplace,
       to_number(nvl(to_char(sb.expdate,'RRRR'),0)) -to_number(nvl(to_char(sb.issuedate,'RRRR'),0))/*+1*/ kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       SB.Symbol,
       sb.sbtotalamt, -- tong gia tri phat hanh
      AL.cdcontent country,-- quoc gia
       cf.mobilesms,
       a1.cdcontent idtype,
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,

       cf.custodycd,
       sb.expdate,-- ngay den han

       'TDCN' LOAI, -- tdcn
       'Trade' LOAI_E, -- tdcn
       se.trade,
       se.trade*sb.parvalue tong,
       se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
       cf.internation,
       fn_convert_to_vn(cf.idplace) idplace_e,
       fn_convert_to_vn(bank.bankacname) bankacname_e,
       fn_convert_to_vn(bank.bankname) bankname_e,
       fn_convert_to_vn(cf.address)  address_e,
       '1' id
  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       ALLCODE AL,allcode a1,
       SBSECURITIES SB,
       ISSUERS ISS,(select *
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
         group by c.cfcustid)) bank,
       (select se.trade-NVL(TR.TRADE_NAMT,0) trade,se.codeid,se.shareholdersid,se.afacctno  from  sbsecurities sb, SEMAST SE
    left join
    (
        SELECT ACCTNO,
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE')
            and busdate > to_date(I_DATE,'dd/MM/yyyy')
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0
             ) TR
    on SE.ACCTNO = TR.ACCTNO)  se


 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   aND AL.CDNAME = 'COUNTRY'
   AND CF.CUSTTYPE = a1.CDVAL
   AND a1.CDNAME = 'CUSTTYPE'
   AND SB.ISSUERID = ISS.ISSUERID
   and se.afacctno = af.acctno
   and sb.codeid = se.codeid
   and sb.symbol = V_STRSYMBOL
  -- and se.txdate = to_date(I_DATE,'dd/MM/yyyy')
   and se.trade >0
   and cf.custid = bank.cfcustid(+)
  group by
       iss.fullname ,
       iss.officename , -- ten tieng anh
       iss.address ,
       iss.operateno,-- giay phep dkkd
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
        iss.licensedate,
       iss.lincenseplace,
       SB.Symbol,
       sb.sbtotalamt, -- tong gia tri phat hanh
        AL.cdcontent ,-- quoc gia
       cf.mobilesms,
       a1.cdcontent,
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       se.trade,
       se.trade*sb.parvalue ,
       se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
       cf.internation,
       fn_convert_to_vn(cf.idplace)

  union all
  select  'TP.HCM, ngày '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' tháng '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' năm '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
       ,to_date(I_DATE,'dd/MM/yyyy') I_DATE_E,
        iss.fullname issfullname, -- ten to chuc phat hanh = ten chung khoan
       iss.officename , -- ten tieng anh
       iss.address  issaddress, -- dia chi
       iss.operateno,-- giay phep dkkd
        iss.licensedate,
       iss.lincenseplace,
       to_number(nvl(to_char(sb.expdate,'rrrr'),0)) -to_number(nvl(to_char(sb.issuedate,'rrrr'),0))/* + 1*/ kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       SB.Symbol,
       sb.sbtotalamt, -- tong gia tri phat hanh
      AL.cdcontent country,-- quoc gia
       cf.mobilesms,
       a1.cdcontent idtype,
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,

       cf.custodycd,
       sb.expdate,-- ngay den han

       'HCCN' LOAI, -- tdcn
       'Restricted' LOAI_E, -- tdcn
       se.Blocked,
       se.Blocked*sb.parvalue tong,
       se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
       cf.internation,
       fn_convert_to_vn(cf.idplace) idplace_e,
       fn_convert_to_vn(bank.bankacname) bankacname_e,
       fn_convert_to_vn(bank.bankname) bankname_e,
       fn_convert_to_vn(cf.address)  address_e,
       '2' id
  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       ALLCODE AL,allcode a1,
       SBSECURITIES SB,
       ISSUERS ISS,(select *
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
         group by c.cfcustid)) bank,
       (select se.Blocked-NVL(TR.BLOCKED_NAMT,0) Blocked,se.codeid,se.shareholdersid,se.afacctno  from  sbsecurities sb, SEMAST SE
    left join
    (
        SELECT ACCTNO,
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) BLOCKED_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BLOCKED')
            and busdate > to_date(I_DATE,'dd/MM/yyyy')
        GROUP BY ACCTNO
        having    SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0
             ) TR
    on SE.ACCTNO = TR.ACCTNO)  se


 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND SB.ISSUERID = ISS.ISSUERID
     AND CF.CUSTTYPE = a1.CDVAL
   AND a1.CDNAME = 'CUSTTYPE'
   and se.afacctno = af.acctno
   and sb.codeid = se.codeid
   and sb.symbol = V_STRSYMBOL
  -- and se.txdate = to_date(I_DATE,'dd/MM/yyyy')
   and se.Blocked >0
   and cf.custid = bank.cfcustid(+)
  group by
       iss.fullname ,
       iss.officename , -- ten tieng anh
       iss.address ,
       iss.operateno,-- giay phep dkkd
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
        iss.licensedate,
       iss.lincenseplace,
       SB.Symbol,
       sb.sbtotalamt, -- tong gia tri phat hanh
        AL.cdcontent ,-- quoc gia
       cf.mobilesms,
       a1.cdcontent,
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       se.Blocked,
       se.Blocked*sb.parvalue ,
       se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc ,-- -- so tai khoan
       cf.internation,
       fn_convert_to_vn(cf.idplace)


  union all

  select 'TP.HCM, ngày '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' tháng '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' năm '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
       ,to_date(I_DATE,'dd/MM/yyyy') I_DATE_E,
       iss.fullname issfullname, -- ten to chuc phat hanh = ten chung khoan
       iss.officename , -- ten tieng anh
       iss.address  issaddress, -- dia chi
       iss.operateno,-- giay phep dkkd
        iss.licensedate,
       iss.lincenseplace,
       to_number(nvl(to_char(sb.expdate,'rrrr'),0)) -to_number(nvl(to_char(sb.issuedate,'rrrr'),0)) /*+ 1*/ kyhan,
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       SB.Symbol,
       sb.sbtotalamt, -- tong gia tri phat hanh
      AL.cdcontent country,-- quoc gia
       cf.mobilesms,
       a1.cdcontent idtype,
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,

       cf.custodycd,
       sb.expdate,-- ngay den han

       'Phong toa' LOAI, -- tdcn
       'Blocked' LOAI_E, -- tdcn
       se.EMKQTTY,
       se.EMKQTTY*sb.parvalue tong,
       se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
       cf.internation,
       fn_convert_to_vn(cf.idplace) idplace_e,
       fn_convert_to_vn(bank.bankacname) bankacname_e,
       fn_convert_to_vn(bank.bankname) bankname_e,
       fn_convert_to_vn(cf.address)  address_e,
       '3' id
  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
       ALLCODE AL,ALLCODE a1,
       SBSECURITIES SB,
       ISSUERS ISS,(select *
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
         group by c.cfcustid)) bank,
       (select se.emkqtty-NVL(TR.EMKQTTY_NAMT,0) EMKQTTY,se.codeid,se.shareholdersid,se.afacctno  from  sbsecurities sb, SEMAST SE
    left join
    (
        SELECT ACCTNO,
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) EMKQTTY_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('EMKQTTY')
            and busdate > to_date(I_DATE,'dd/MM/yyyy')
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0
             ) TR
    on SE.ACCTNO = TR.ACCTNO)  se


 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
    AND CF.CUSTTYPE = a1.CDVAL
   AND a1.CDNAME = 'CUSTTYPE'
   AND SB.ISSUERID = ISS.ISSUERID
   and se.afacctno = af.acctno
   and sb.codeid = se.codeid
   and sb.symbol = V_STRSYMBOL
  -- and se.txdate = to_date(I_DATE,'dd/MM/yyyy')
   and se.EMKQTTY >0
   and cf.custid = bank.cfcustid(+)
  group by
       iss.fullname ,
       iss.officename , -- ten tieng anh
       iss.address ,
       iss.operateno,-- giay phep dkkd
       cf.fullname,-- ten trai chu
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
        iss.licensedate,
       iss.lincenseplace,
       SB.Symbol,
       sb.sbtotalamt, -- tong gia tri phat hanh
        AL.cdcontent ,-- quoc gia
       cf.mobilesms,
       a1.cdcontent,
       sb.issuedate , -- ngay phat hanh
       sb.parvalue,
       SB.Intcoupon,
       cf.custodycd,
       sb.expdate,-- ngay den han
       se.EMKQTTY,
       se.EMKQTTY*sb.parvalue ,
       se.shareholdersid, --  mscd
       bank.bankacname, -- ten tai khoan
       bank.bankname,-- ten ngan hang
       bank.bankacc, -- -- so tai khoan
       cf.internation,
       fn_convert_to_vn(cf.idplace)) t
       where 1= 1 order by  t.custodycd,t.shareholdersid,t.id

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
