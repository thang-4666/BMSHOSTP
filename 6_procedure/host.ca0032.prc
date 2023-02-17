SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0032" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS

   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);        -- USED WHEN V_NUMOPTION > 0
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


OPEN PV_REFCURSOR
  FOR
    SELECT  tr.SYMBOL, tr.CUSTODYCD, tr.ISSNAME, cf.FULLNAME, cf.ADDRESS,
        (case when cf.country = '234' then cf.idcode else cf.tradingcode end) LICENSE,
        TO_CHAR((case when cf.country = '234' then cf.idDATE else cf.tradingcodeDT end),'DD/MM/RRRR') IDDATE,
       CF.IDPLACE, TR.COUNTRY,
       TR.CUSTODYCD2, TR.TOMEMCUS, TR.FULLNAME2 FULLNAME2, TR.ADDRESS2 ADDRESS2,
        TR.LICENSE2 LICENSE2,
        TR.IDDATE2 IDDATE2,
        TR.IDPLACE2 IDPLACE2, TR.COUNTRY2, TR.DES, TR.AMT, TR.MANT, TR.RAMT,
        0 NUOC_NGOAI,  0  TU_DOANH,  0 TRONG_NUOC, TOSYMBOL, TOISSNAME
FROM
(     SELECT tl.txnum,tl.txdate,
       max(decode(fld.fldcd,'35',cvalue,null)) SYMBOL,-- b?chuyen
       max(decode(fld.fldcd,'36',cvalue,null)) CUSTODYCD,
       max(decode(fld.fldcd,'38',cvalue,null)) ISSNAME,
/*       max(decode(fld.fldcd,'90',cvalue,null)) FULLNAME,
       max(decode(fld.fldcd,'91',cvalue,null)) ADDRESS,
       max(decode(fld.fldcd,'92',cvalue,null)) LICENSE,
       max(decode(fld.fldcd,'93',cvalue,null)) IDDATE,
       max(decode(fld.fldcd,'94',cvalue,null)) IDPLACE,*/
       max(decode(fld.fldcd,'80',cvalue,null)) COUNTRY,
       max(decode(fld.fldcd,'21',nvalue,null)) AMT,
       max(decode(fld.fldcd,'22',nvalue,null)) MANT,
       max(decode(fld.fldcd,'23',nvalue,null)) RAMT,

       max(decode(fld.fldcd,'07',cvalue,null)) CUSTODYCD2,
       max(decode(fld.fldcd,'08',cvalue,null)) TOMEMCUS,
       max(decode(fld.fldcd,'95',cvalue,null)) FULLNAME2,
       max(decode(fld.fldcd,'96',cvalue,null)) ADDRESS2,
       max(decode(fld.fldcd,'97',cvalue,null)) LICENSE2,
       max(decode(fld.fldcd,'98',cvalue,null)) IDDATE2,
       max(decode(fld.fldcd,'99',cvalue,null)) IDPLACE2,
       max(decode(fld.fldcd,'81',cvalue,null)) COUNTRY2,
       max(decode(fld.fldcd,'60',cvalue,null)) TOSYMBOL,
       max(decode(fld.fldcd,'61',cvalue,null)) TOISSNAME,
       max(decode(fld.fldcd,'30',cvalue,null)) DES--diengiai
    FROM
       vw_tllog_all tl, vw_tllogfld_all fld
    WHERE
       tl.txnum=fld.txnum
       and tl.txdate=fld.txdate
       and tl.txdate >=to_date(F_DATE,'DD/MM/YYYY')
       and tl.txdate <=to_date(T_DATE,'DD,MM,YYYY')
       and tl.tltxcd in ('3383')
       AND FLD.FLDCD IN ('35','36','38','80','21','22','23','07','08','81','30','60','61', '95','96','97','98','99')
       and tl.deltd <>'Y'
    group by tl.txnum,tl.txdate
) tr, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf2
where tr.CUSTODYCD = cf.custodycd
    and tr.CUSTODYCD2 =  cf2.custodycd(+)
UNION ALL
    SELECT TR.SYMBOL,TR.CUSTODYCD,TR.ISSNAME,CF.FULLNAME,CF.ADDRESS,
    (case when cf.country = '234' then cf.idcode else cf.tradingcode end) LICENSE,
    TO_CHAR((case when cf.country = '234' then cf.idDATE else cf.tradingcodeDT end),'DD/MM/RRRR') IDDATE,
    CF.IDPLACE,TR.COUNTRY,TR.CUSTODYCD2,TR.TOMEMCUS,NVL(CF2.FULLNAME,'') FULLNAME2, NVL(CF2.ADDRESS,'') ADDRESS2,
    (case when NVL(cf2.country,'') = '234' then NVL(cf2.idcode,'') else NVL(cf2.tradingcode,'') end) LICENSE2,
    TO_CHAR((case when NVL(cf2.country,'') = '234' then NVL(cf2.idDATE,'') else NVL(cf2.tradingcodeDT,'') end),'DD/MM/RRRR') IDDATE2,
    NVL(CF2.IDPLACE,'') IDPLACE2, TR.COUNTRY2, TR.DES, TR.AMT, TR.MANT, TR.RAMT,
     0 NUOC_NGOAI, 0 TU_DOANH, 0 TRONG_NUOC, TOSYMBOL, TOISSNAME
FROM
(     SELECT tl.txnum,tl.txdate,
       max(decode(fld.fldcd,'35',cvalue,null)) SYMBOL,-- b?chuyen
       max(decode(fld.fldcd,'36',cvalue,null)) CUSTODYCD,
       max(decode(fld.fldcd,'79',cvalue,null)) ISSNAME,
/*       max(decode(fld.fldcd,'90',cvalue,null)) FULLNAME,
       max(decode(fld.fldcd,'91',cvalue,null)) ADDRESS,
       max(decode(fld.fldcd,'92',cvalue,null)) LICENSE,
       max(decode(fld.fldcd,'93',cvalue,null)) IDDATE,
       max(decode(fld.fldcd,'94',cvalue,null)) IDPLACE,*/
       max(decode(fld.fldcd,'80',cvalue,null)) COUNTRY,
       max(decode(fld.fldcd,'21',nvalue,null)) AMT,
       max(decode(fld.fldcd,'22',nvalue,null)) MANT,
       max(decode(fld.fldcd,'23',nvalue,null)) RAMT,

       max(decode(fld.fldcd,'38',cvalue,null)) CUSTODYCD2,
       max(decode(fld.fldcd,'08',cvalue,null)) TOMEMCUS,
/*       max(decode(fld.fldcd,'95',cvalue,null)) FULLNAME2,
       max(decode(fld.fldcd,'96',cvalue,null)) ADDRESS2,
       max(decode(fld.fldcd,'97',cvalue,null)) LICENSE2,
       max(decode(fld.fldcd,'98',cvalue,null)) IDDATE2,
       max(decode(fld.fldcd,'99',cvalue,null)) IDPLACE2,*/
       max(decode(fld.fldcd,'81',cvalue,null)) COUNTRY2,
       max(decode(fld.fldcd,'60',cvalue,null)) TOSYMBOL,
       max(decode(fld.fldcd,'61',cvalue,null)) TOISSNAME,
       max(decode(fld.fldcd,'30',cvalue,null)) DES--diengiai
    FROM
       vw_tllog_all tl, vw_tllogfld_all fld
    WHERE
       tl.txnum=fld.txnum
       and tl.txdate=fld.txdate
       and tl.txdate >=to_date(F_DATE,'DD/MM/YYYY')
       and tl.txdate <=to_date(T_DATE,'DD,MM,YYYY')
       and tl.tltxcd in ('3382')
       AND FLD.FLDCD IN ('35','36','79','80','21','22','23','38','08','81','30','60','61')
       and tl.deltd <>'Y'
    group by tl.txnum,tl.txdate
) TR, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF2
WHERE tr.CUSTODYCD = cf.custodycd
    and tr.CUSTODYCD2 =  cf2.custodycd(+)
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
