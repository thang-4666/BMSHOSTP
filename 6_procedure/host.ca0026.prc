SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0026" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PLSENT         in       varchar2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      12/01/2012 Create
-- ---------   ------     -------------------------------------------
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

  SELECT PLSENT sendto, SYMBOL,CUSTODYCD,ISSNAME,FULLNAME,ADDRESS,LICENSE,IDDATE,IDPLACE,COUNTRY,
       CUSTODYCD2,TOMEMCUS,FULLNAME2,ADDRESS2,LICENSE2,IDDATE2,IDPLACE2,COUNTRY2, TOSYMBOL, TOISSNAME,
       (case when substr(CUSTODYCD,4,1)='F' then AMT else 0 end) NUOC_NGOAI,
       (case when substr(CUSTODYCD,4,1)='P' then AMT else 0 end) TU_DOANH,
       (case when substr(CUSTODYCD,4,1)='C' then AMT else 0 end) TRONG_NUOC
FROM
(     SELECT tl.txnum,tl.txdate,
       max(decode(fld.fldcd,'35',cvalue,null)) SYMBOL,-- b?chuyen
       max(decode(fld.fldcd,'36',cvalue,null)) CUSTODYCD,
       max(decode(fld.fldcd,'38',cvalue,null)) ISSNAME,
       max(decode(fld.fldcd,'90',cvalue,null)) FULLNAME,
       max(decode(fld.fldcd,'91',cvalue,null)) ADDRESS,
       max(decode(fld.fldcd,'92',cvalue,null)) LICENSE,
       max(decode(fld.fldcd,'93',cvalue,null)) IDDATE,
       max(decode(fld.fldcd,'94',cvalue,null)) IDPLACE,
       max(decode(fld.fldcd,'80',cvalue,null)) COUNTRY,
       max(decode(fld.fldcd,'21',nvalue,null)) AMT,

       max(decode(fld.fldcd,'07',cvalue,null)) CUSTODYCD2,
       max(decode(fld.fldcd,'85',cvalue,null)) TOMEMCUS,
       max(decode(fld.fldcd,'95',cvalue,null)) FULLNAME2,
       max(decode(fld.fldcd,'96',cvalue,null)) ADDRESS2,
       max(decode(fld.fldcd,'97',cvalue,null)) LICENSE2,
       max(decode(fld.fldcd,'98',cvalue,null)) IDDATE2,
       max(decode(fld.fldcd,'99',cvalue,null)) IDPLACE2,
       max(decode(fld.fldcd,'81',cvalue,null)) COUNTRY2,
       max(decode(fld.fldcd,'60',cvalue,null)) TOSYMBOL,
       max(decode(fld.fldcd,'61',cvalue,NULL)) TOISSNAME,
       max(decode(fld.fldcd,'30',cvalue,null)) DES--diengiai
    FROM
       vw_tllog_all tl, vw_tllogfld_all fld
    WHERE
       tl.txnum=fld.txnum
       and tl.txdate=fld.txdate
       and tl.txdate >=to_date(F_DATE,'DD/MM/YYYY')
       and tl.txdate <=to_date(T_DATE,'DD,MM,YYYY')
       and tl.tltxcd='3383'
       and tl.deltd <>'Y'
    group by tl.txnum,tl.txdate)
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
