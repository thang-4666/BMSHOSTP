SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0061" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   CACODE         IN       VARCHAR2

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
    v_tddate            date;

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
/*   IF (CACODE <> 'ALL' OR CACODE <> '')
   THEN
      V_CACODE :=  CACODE;
   ELSE
      V_CACODE := '%%';
   END IF;*/
SELECT  getduedate(tdateotc,'B','000',1) into v_tddate from camast where camastid=CACODE;

   -- GET REPORT'S DATA
if to_date(I_DATE,'dd/MM/yyyy') = getcurrdate then
OPEN PV_REFCURSOR
FOR
  select 'H??i, ng?'||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' th? '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' nam '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
   ,mst.optsymbol,
      /* mst.*/v_tddate actiondate,
       cf.fullname,
       cf.address,
       fn_convert_to_vn(cf.address) address_E,
       (case when cf.country = '234' then  cf.idcode
         else cf.tradingcode end ) idcode ,
       cf.iddate,
       cf.idplace,
       cf.mobilesms,
       iss.fullname  tentp,
       sb.issuedate,
       sb.parvalue,
       mst.reportdate,
       (-to_number(nvl(to_char(sb.issuedate,'rrrr'),0)) + to_number(nvl(to_char(sb.expdate,'rrrr'),0))) /*+1*/ term, -- ky han
       to_number(nvl(mst.INTERESTRATE,0)) /*sb.intcoupon*/ intcoupon, -- lai suat
       cf.custodycd,
       getcurrdate,
       sb.expdate,
       iss.officename,
       to_date(I_DATE,'dd/MM/yyyy') I_DATE_E
  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       CFMAST CF,
       ALLCODE AL,
       SBSECURITIES SB,
       ISSUERS ISS,
       (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       semast se

 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND SB.ISSUERID = ISS.ISSUERID
   AND MST.CATYPE = '027'
   and se.afacctno = af.acctno
   and mst.codeid = sb.codeid
   and se.codeid = sb.codeid
   and mst.camastid = CACODE
   and se.trade+se.blocked+se.emkqtty >0
;
else
  OPEN PV_REFCURSOR
FOR
  select 'H??i, ng?'||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' th? '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' nam '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
   ,mst.optsymbol,
      /* mst.*/v_tddate actiondate,
       cf.fullname,
       cf.address,
       fn_convert_to_vn(cf.address) address_E,
        (case when cf.country = '234' then  cf.idcode
         else cf.tradingcode end ) idcode ,
       cf.iddate,
       cf.idplace,
       cf.mobilesms,
       iss.fullname  tentp,
       sb.issuedate,
       sb.parvalue,
       mst.reportdate,
       (-to_number(nvl(to_char(sb.issuedate,'rrrr'),0)) + to_number(nvl(to_char(sb.expdate,'rrrr'),0))) /*+1*/ term, -- ky han
       to_number(nvl(mst.INTERESTRATE,0)) /*sb.intcoupon*/ intcoupon, -- lai suat
       cf.custodycd,
       getcurrdate,
       sb.expdate,
       iss.officename,
       to_date(I_DATE,'dd/MM/yyyy') I_DATE_E
  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       CFMAST CF,
       ALLCODE AL,
       SBSECURITIES SB,
       ISSUERS ISS,
       (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       semast se

 WHERE
    AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND SB.ISSUERID = ISS.ISSUERID
   AND MST.CATYPE = '027'
   and se.afacctno = af.acctno
   and se.codeid = sb.codeid
   and mst.codeid = sb.codeid
   and mst.camastid = CACODE
   and
    (
    se.trade-nvl((SELECT
            SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('TRADE')
            and busdate > to_date(I_DATE,'dd/MM/yyyy')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'TRADE' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0)
        +
        se.blocked-nvl((SELECT
            SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('BLOCKED')
            and busdate > to_date(I_DATE,'dd/MM/yyyy')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'BLOCKED' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0)
      +
       se.Emkqtty-nvl((SELECT
            SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) TRADE_NAMT
             FROM VW_SETRAN_GEN
        WHERE DELTD <> 'Y' AND FIELD IN ('EMKQTTY')
            and busdate > to_date(I_DATE,'dd/MM/yyyy')
            and acctno = se.acctno and symbol = sb.symbol
        GROUP BY ACCTNO
        HAVING SUM(CASE WHEN FIELD = 'EMKQTTY' THEN (CASE WHEN TXTYPE = 'D' THEN - NAMT ELSE NAMT END) ELSE 0 END) <> 0),0)

        )>0

;

  end if;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
