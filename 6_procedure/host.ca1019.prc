SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA1019" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
  F_DATE         IN       VARCHAR2,
  T_DATE         IN       VARCHAR2,
  TLTXCD         IN       VARCHAR2,
  CAMASTID       IN     VARCHAR2,
  PV_CUSTODYCD   IN    VARCHAR2,
  PV_AFACCTNO    IN    VARCHAR2

 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (16);        -- USED WHEN V_NUMOPTION > 0
   V_STRTLTXCD              VARCHAR2 (6);
   V_STRMAKER            VARCHAR2 (20);
   V_STRCHECKER             VARCHAR2 (20);
   V_STRCUSTOCYCD           VARCHAR2 (20);
    V_STRAFACCTNO           VARCHAR2 (20);
   V_STRCAMASTID              VARCHAR2 (30);
     v_brid               VARCHAR2(4);
V_STRCOREBANK      VARCHAR2(4);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
      v_brid := pv_brid;


  IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STROPTION := v_brid;
END IF;

   IF (TLTXCD <> 'ALL')
   THEN
      V_STRTLTXCD := TLTXCD;
   ELSE
      V_STRTLTXCD := '%%';
   END IF;

      IF (CAMASTID <> 'ALL')
   THEN
      V_STRCAMASTID := CAMASTID;
   ELSE
      V_STRCAMASTID := '%%';
   END IF;

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTOCYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTOCYCD := '%%';
   END IF;

   IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%%';
   END IF;



OPEN PV_REFCURSOR
  FOR
SELECT * FROM (
select maker_dt ,  approve_dt ,  tlmk.tlname maker, tlck.tlname checker,'' tltxcd ,action_flag, substr(record_key, instr(record_key,'''')+1,16 ) camastid , caption column_name,from_value,to_value, '' afacctno ,'' custodycd,
ca.description,sb.symbol,m.maker_time
from maintain_log M , tlprofiles tlmk,tlprofiles tlck,camast ca,sbsecurities sb,(select  defname , caption caption ,substr(fldname,1,3) catype from   FLDMASTER where objname='CA.CAMAST' and substr(fldname,1,1)='0'
union
select  defname , caption caption ,'' catype from   FLDMASTER where objname='CA.CAMAST' and substr(fldname,1,1)<>'0'
)FLDMASTER
where m.maker_id=tlmk.tlid(+) and m.approve_id= tlck.tlid and  table_name='CAMAST'
and substr(record_key, instr(record_key,'''')+1,16 ) = ca.camastid and ca.codeid = sb.codeid
 AND DEFNAME =column_name
AND maker_dt BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
and ca.catype= nvl(fldmaster.catype,ca.catype)
union all

select tl.busdate maker_dt, tl.busdate txdate_ap , tlmk.tlname maker, tlck.tlname checker, tl.tltxcd , tl.txdesc action_flag, msgacct camastid ,'' column_name, '' from_value, '' to_value , '' afacctno ,'' custodycd
,ca.description,sb.symbol,tl.txtime
from  vw_tllog_all tl, tlprofiles tlmk,tlprofiles tlck,camast ca,sbsecurities sb
where tl.tltxcd  in ('3375','3370','3376','3340','3390','3341','3342','3356','3331')
and tl.tlid = tlmk.tlid (+)
and tl.offid = tlck.tlid (+)
and tl.deltd <>'Y'
and msgacct = ca.camastid and ca.codeid = sb.codeid
AND  tl.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
union all
select tl.busdate maker_dt, tl.busdate txdate_ap , tlmk.tlname maker, tlck.tlname checker, tl.tltxcd , tl.txdesc action_flag, msgacct camastid ,fldmaster.caption column_name, catr.ref from_value, catr.camt to_value , '' afacctno ,'' custodycd
,ca.description,sb.symbol,tl.txtime
from  vw_tllog_all tl, tlprofiles tlmk,tlprofiles tlck,camast ca,sbsecurities sb,
(select * from catran union select * from catrana )catr,
(select * from  v_appmap_by_tltxcd where tltxcd ='3389')app,
(select  defname , caption caption ,substr(fldname,1,3) catype from   FLDMASTER where objname='CA.CAMAST' and substr(fldname,1,1)='0'
union
select  defname , caption caption ,'' catype from   FLDMASTER where objname='CA.CAMAST' and substr(fldname,1,1)<>'0'
)FLDMASTER
where tl.tltxcd  ='3389'
and fldmaster.defname= app.field
and tl.tlid = tlmk.tlid (+)
and tl.offid = tlck.tlid (+)
and tl.deltd <>'Y'
and tl.txnum = catr.txnum
and tl.txdate = catr.txdate
and msgacct = ca.camastid and ca.codeid = sb.codeid
and catr.txcd = app.apptxcd
AND  tl.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')

UNION ALL
select  tl.busdate maker_dt, tl.busdate txdate_ap , tlmk.tlname maker, tlck.tlname checker, tl.tltxcd , tl.txdesc action_flag, ca.camastid camastid ,'' column_name, '' from_value, '' to_value , SE.afacctno afacctno ,SE.custodycd custodycd
,ca.description,sb.symbol,tl.txtime
from vw_tllog_all tl,( select * from  vw_setran_gen where tltxcd in ('3385','3324','3384','3382','3383')  )se , tlprofiles tlmk,tlprofiles tlck,sbsecurities sb,caschd cas,camast ca
where tl.txnum = se.txnum and tl.txdate =se.txdate
and field IN ('TRADE')
and tl.tlid = tlmk.tlid (+)
and tl.offid = tlck.tlid (+)
and tl.deltd <>'Y'
and SE.ref =to_char( cas.autoid) and ca.codeid = sb.codeid
and ca.camastid = cas.camastid
AND  tl.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
UNION ALL
select  tl.busdate maker_dt, tl.busdate txdate_ap , tlmk.tlname maker, tlck.tlname checker, tl.tltxcd , tl.txdesc action_flag, ca.camastid camastid ,'' column_name, '' from_value, '' to_value , SE.afacctno afacctno ,SE.custodycd custodycd
,ca.description,sb.symbol,tl.txtime
from vw_tllog_all tl,( select * from  vw_setran_gen where tltxcd ='3324'  )se , tlprofiles tlmk,tlprofiles tlck,sbsecurities sb,caschd cas,camast ca
where tl.txnum = se.txnum and tl.txdate =se.txdate
and field IN ('RECEIVING')
and tl.tlid = tlmk.tlid (+)
and tl.offid = tlck.tlid (+)
and tl.deltd <>'Y'
and SE.ref =to_char( cas.autoid) and ca.codeid = sb.codeid
and ca.camastid = cas.camastid
AND  tl.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')

UNION ALL
select  tl.busdate maker_dt, tl.busdate txdate_ap , tlmk.tlname maker, tlck.tlname checker, tl.tltxcd , tl.txdesc action_flag, tlfld.cvalue camastid ,'' column_name, '' from_value, '' to_value , af.acctno afacctno ,cf.custodycd custodycd
,ca.description,sb.symbol,tl.txtime
from vw_tllog_all tl, vw_tllogfld_all tlfld , tlprofiles tlmk,tlprofiles tlck,afmast af, cfmast cf,camast ca,sbsecurities sb
where tl.txnum = tlfld.txnum and tl.txdate =tlfld.txdate
and tl.tltxcd ='3327' and tlfld.fldcd='02'
and tl.tlid = tlmk.tlid (+)
and tl.offid = tlck.tlid (+)
and tl.msgacct = af.acctno
and af.custid = cf.custid
and tl.deltd <>'Y'
and tlfld.cvalue = ca.camastid and ca.codeid = sb.codeid
AND  tl.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
union all
select  tl.busdate maker_dt, tl.busdate txdate_ap , tlmk.tlname maker, tlck.tlname checker, tl.tltxcd , tl.txdesc action_flag, tlfld.cvalue camastid ,'' column_name, '' from_value, '' to_value , af.acctno afacctno ,cf.custodycd custodycd
,ca.description,sb.symbol,tl.txtime
from vw_tllog_all tl, vw_tllogfld_all tlfld , tlprofiles tlmk,tlprofiles tlck,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,camast ca,sbsecurities sb
where tl.txnum = tlfld.txnum and tl.txdate =tlfld.txdate
and tl.tltxcd ='3331' and tlfld.fldcd='18'
and tl.tlid = tlmk.tlid (+)
and tl.offid = tlck.tlid (+)
and tl.msgacct = af.acctno
and af.custid = cf.custid
and tl.deltd <>'Y'
and tlfld.cvalue = ca.camastid and ca.codeid = sb.codeid
AND  tl.busdate BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
) DT
WHERE DT.maker_dt BETWEEN TO_DATE (F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
AND nvl( DT.camastid,'-') LIKE V_STRCAMASTID
AND nvl(DT.TLTXCD,'-') LIKE V_STRTLTXCD
AND nvl(DT.CUSTODYCD,'-') LIKE V_STRCUSTOCYCD
AND nvl(DT.AFACCTNO,'-') LIKE V_STRAFACCTNO
ORDER BY DT.maker_dt,DT.camastid,tltxcd desc ,action_flag
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
-- End of DDL Script for Procedure HOST.CA1018

 
 
 
 
/
