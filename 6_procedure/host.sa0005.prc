SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0005" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   BANKID         IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      28/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);
   V_STRCUSTOCYCD     VARCHAR2 (20);
   V_STRBANKID        VARCHAR2 (4);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := BRID;
   IF (V_STROPTION = 'A') AND (V_INBRID  = '0001')
   THEN
        V_STRBRID := '%';
   ELSE if V_STROPTION = 'B' then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
        V_STRBRID := V_INBRID;
        end if;
   END IF;

    IF (BANKID <> 'ALL')
   THEN
      V_STRBANKID := BANKID;
   ELSE
      V_STRBANKID := '%%';
   END IF;

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTOCYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTOCYCD := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR

  SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,po.txnum potxnum,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,
         substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,
         AL.CDCONTENT STATUS,ba.shortname
  FROM   vw_tllog_all tl, vw_tllogfld_all tf, pomast po, banknostro ba,
         allcode al,afmast af, cfmast cf
  WHERE  tl.txnum = tf.txnum
      AND tl.txdate = tf.txdate
      AND AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS'
      AND AL.CDVAL =TL.TXSTATUS
      AND tf.fldcd = '99'
      AND tf.cvalue = po.txnum
      AND po.bankid = ba.shortname
      AND tl.tltxcd ='1104'
      AND af.acctno(+)= substr(TL.MSGACCT,1,10)
      AND cf.custid (+)= af.custid
      AND Tl.Deltd <>'Y'
      and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
      AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
      AND tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
      AND tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
      and ba.shortname like V_STRBANKID
      AND cf.custodycd like V_STRCUSTOCYCD
order by tl.txdate, tl.txnum, po.txnum
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
