SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_ADTYPE_INFO
(VALUE, FILTERID, DISPLAY, EN_DISPLAY, ACTYPE, 
 TYPENAME, RRTYPE, CIACCTNO, CUSTBANK, SCRACCTNO, 
 ADVMINAMT, ADVMINFEE, ADVMINFEEBANK, ADVRATE, ADVMAXAMT, 
 ADVMAXFEE, VATRATE, DESCRIPTION, CIDRAWNDOWN, BANKDRAWNDOWN, 
 CMPDRAWNDOWN, AVLPOOL)
BEQUEATH DEFINER
AS 
SELECT AD.ACTYPE VALUE, AD.ACTYPE FILTERID, AD.ACTYPE || ' - ' || AD.TYPENAME || ' - ' || A1.CDCONTENT  DISPLAY,
       AD.ACTYPE || ' - ' || AD.TYPENAME || ' - ' || A1.CDCONTENT  EN_DISPLAY,
       AD.ACTYPE, AD.TYPENAME, AD.RRTYPE, AD.CIACCTNO, AD.CUSTBANK,
       (CASE WHEN AD.RRTYPE = 'O' THEN AD.CIACCTNO WHEN AD.RRTYPE='B' THEN AD.CUSTBANK ELSE '' END) SCRACCTNO,
       NVL((AD.ADVMINAMT + AD.ADVMINBANK),0) ADVMINAMT,
       nvl(AD.ADVMINFEE,0) ADVMINFEE, nvl(AD.ADVMINFEEBANK,0) ADVMINFEEBANK,
       NVL((AD.ADVRATE+AD.ADVBANKRATE),0) ADVRATE,
       NVL(AD.ADVMAXAMT,0) ADVMAXAMT, NVL(AD.ADVMAXFEE,0) ADVMAXFEE, NVL(AD.VATRATE,0) VATRATE, AD.DESCRIPTION,
       decode(AD.RRTYPE, 'O', 1,0) CIDRAWNDOWN,
       decode(AD.RRTYPE, 'B', 1,0) BANKDRAWNDOWN,
       decode(AD.RRTYPE, 'C', 1,0) CMPDRAWNDOWN,
       case when AD.RRTYPE='B' then cspks_cfproc.fn_getavlbanklimit(ad.custbank,'ADV') else 0 end AVLPOOL
FROM ADTYPE AD, ALLCODE A1
WHERE AD.RRTYPE = A1.CDVAL
      AND A1.CDTYPE ='LN'
      AND A1.CDNAME ='RRTYPE'
      AND AD.RRTYPE='B'
      AND AD.APPRV_STS='A'
      AND AD.actype NOT IN (SELECT DISTINCT adtype FROM aftype  )
UNION ALL
SELECT AD.ACTYPE VALUE, AD.ACTYPE FILTERID, AD.ACTYPE || ' - ' || AD.TYPENAME || ' - ' || A1.CDCONTENT  DISPLAY,
       AD.ACTYPE || ' - ' || AD.TYPENAME || ' - ' || A1.CDCONTENT  EN_DISPLAY,
       AD.ACTYPE, AD.TYPENAME, AD.RRTYPE, AD.CIACCTNO, AD.CUSTBANK,
       (CASE WHEN AD.RRTYPE = 'O' THEN AD.CIACCTNO WHEN AD.RRTYPE='B' THEN AD.CUSTBANK ELSE '' END) SCRACCTNO,
       NVL((AD.ADVMINAMT + AD.ADVMINBANK),0) ADVMINAMT,
       nvl(AD.ADVMINFEE,0) ADVMINFEE, nvl(AD.ADVMINFEEBANK,0) ADVMINFEEBANK,
       NVL((AD.ADVRATE+AD.ADVBANKRATE),0) ADVRATE,
       NVL(AD.ADVMAXAMT,0) ADVMAXAMT, NVL(AD.ADVMAXFEE,0) ADVMAXFEE, NVL(AD.VATRATE,0) VATRATE, AD.DESCRIPTION,
       decode(AD.RRTYPE, 'O', 1,0) CIDRAWNDOWN,
       decode(AD.RRTYPE, 'B', 1,0) BANKDRAWNDOWN,
       decode(AD.RRTYPE, 'C', 1,0) CMPDRAWNDOWN,
       cspks_cfproc.fn_getavlbanklimit(CF.CUSTID,'ADV')  AVLPOOL
FROM ADTYPE AD, ALLCODE A1,( SELECT CUSTID FROM CFMAST WHERE shortname='VCBS')CF
WHERE AD.RRTYPE = A1.CDVAL
      AND A1.CDTYPE ='LN'
      AND A1.CDNAME ='RRTYPE'
      AND AD.RRTYPE='C'
      AND AD.APPRV_STS='A'
      AND AD.actype NOT IN (SELECT DISTINCT adtype FROM aftype  )
/
