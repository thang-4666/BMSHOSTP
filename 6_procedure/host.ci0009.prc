SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0009" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   TLID           IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   CHECKER        IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TINH PHI THAU CHI CUA KHACH HANG
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- HUNG.LB 10-SEP-10  UPDATED
-- ANH.PT  14-SEP-10  UPDATED
-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2 (4);

   V_STRCUSTODYCD   VARCHAR2 (20);
   v_SubBRID  varchar2(4);
   v_TLID  varchar2(4);

   V_BRNAME     VARCHAR2 (1000);
   V_I_BRIDGD     VARCHAR2 (20);

   V_MAKER       VARCHAR2(100);
   V_CHECKER     VARCHAR2(100);
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE IF (V_STROPTION = 'B') THEN
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        ELSE
            V_STRBRID := V_INBRID;
        END IF;
   END IF;

   -- GET REPORT'S PARAMETERS
  IF (CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTODYCD :=  CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   v_TLID:=TLID;
   select brid into v_SubBRID from tlprofiles where tlid = v_TLID;
   -----------------------
     IF  (MAKER <> 'ALL')
   THEN
         V_MAKER := MAKER;
   ELSE
         V_MAKER := '%';
   END IF;

        IF  (CHECKER <> 'ALL')
   THEN
         V_CHECKER := CHECKER;
   ELSE
         V_CHECKER := '%';
   END IF;
   -----------------------
        IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  ' Toàn công ty ';
   END IF;

   -- GET REPORT'S DATA

OPEN  PV_REFCURSOR FOR

SELECT TL.TXDATE, TL.BUSDATE,TL.TXNUM, CF.CUSTODYCD, TL.ACCTNO, CF.FULLNAME,CF.BRID,A0.CDCONTENT PRODUCT, TL.NAMT,
       CF1.CUSTODYCD CUSTODYCD1, CF1.FULLNAME FULLNAME1, CI.ACCTNO ACCTNO1, CF1.BRID BRID1, A1.CDCONTENT PRODUCT1,
       TLP.TLNAME MAKER, TLP1.TLNAME CHECKER,TL.TXDESC,V_STRCUSTODYCD CUST
FROM VW_CITRAN_GEN TL, VW_CITRAN_GEN CI, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
      AFMAST AF, CFMAST CF1, AFMAST AF1, AFTYPE AFT, AFTYPE AFT1, ALLCODE A0, ALLCODE A1,TLPROFILES TLP, TLPROFILES TLP1
WHERE TL.txnum=CI.txnum
      AND TL.TXDATE=CI.TXDATE
      AND TL.TLTXCD IN ('1120','1134')
      AND TL.deltd<>'Y'
      AND TL.TXCD='0011'
      AND CI.TXCD='0012'
      AND TL.acctno=AF.ACCTNO
      AND AF.CUSTID=CF.CUSTID
      AND CI.acctno=AF1.ACCTNO
      AND AF1.custid=CF1.CUSTID
      AND TL.TLID=TLP.TLID(+)
      AND TL.OFFID=TLP1.TLID(+)
      AND AF.ACTYPE=AFT.ACTYPE
      AND AF1.ACTYPE=AFT1.ACTYPE
      AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
      AND A1.CDTYPE='CF' AND A1.CDNAME='PRODUCTTYPE' AND A1.CDVAL=AFT1.PRODUCTTYPE
      AND TL.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
      AND NVL(TL.TLID,'0000') LIKE V_MAKER
      AND NVL(TL.offid,'0000') LIKE V_CHECKER
      AND CF.BRID LIKE V_I_BRIDGD
      AND CF.CUSTODYCD LIKE V_STRCUSTODYCD

      AND EXISTS (SELECT AF1.ACCTNO FROM VW_CUSTODYCD_SUBACCOUNT VW WHERE AF1.ACCTNO=VW.VALUE)

ORDER BY TL.BUSDATE, TL.TXDATE, CF.CUSTODYCD;

/*select tl.txdate , tl.busdate , tl.txnum , fcf.custodycd fcustodycd,tl.msgacct  f_acctno,
    fcf.fullname  ffullname ,tcf.custodycd tcustodycd, ci.acctno t_acctno, tcf.fullname  tfullname,
    ci.namt ,mk.tlname  maker , ck.tlname checker, tl.txdesc, tl.autoid
from tllogall tl , citrana ci , afmast faf , afmast taf , (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) fcf ,
    cfmast tcf , tlprofiles mk , tlprofiles ck
where tl.txnum = ci.txnum
and tl.txdate = ci.txdate
and tl.deltd  <> 'Y'
and tl.tltxcd in ('1120','1134')
and ci.txcd ='0012'
and tl.msgacct = faf.acctno
and faf.custid = fcf.custid
and ci.acctno = taf.acctno
and taf.custid = tcf.custid
and tl.TLID =mk.tlid
and tl.offid =ck.tlid(+)
and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
and tl.busdate BETWEEN to_date (F_DATE,'DD/MM/YYYY') and to_date (T_DATE ,'DD/MM/YYYY')
and exists (select faf.acctno from vw_custodycd_subaccount vw
where
\*vw.filtercd like V_STRCUSTODYCD and *\
faf.acctno =  vw.value)

---and ( case when substr(tl.txnum,1,1)='9' then '0001' else  tl.brid end) = v_SubBRID
union all
select tl.txdate , tl.busdate , tl.txnum , fcf.custodycd fcustodycd ,tl.msgacct  f_acctno  ,
    fcf.fullname  ffullname ,tcf.custodycd tcustodycd,ci.acctno t_acctno, tcf.fullname  tfullname,
    ci.namt ,mk.tlname  maker , ck.tlname checker, tl.txdesc,tl.autoid
from tllog tl , citran ci , afmast faf , afmast taf , (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) fcf , cfmast tcf ,
    tlprofiles mk , tlprofiles ck
where tl.txnum = ci.txnum
and tl.txdate = ci.txdate
and tl.deltd  <> 'Y'
and tl.tltxcd in ('1120','1134')
and ci.txcd ='0012'
and tl.msgacct = faf.acctno
and faf.custid = fcf.custid
and ci.acctno = taf.acctno
and taf.custid = tcf.custid
and tl.TLID =mk.tlid
and tl.offid =ck.tlid(+)
and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
and tl.busdate BETWEEN to_date (F_DATE,'DD/MM/YYYY') and to_date (T_DATE ,'DD/MM/YYYY')
--and ( case when substr(tl.txnum,1,1)='9' then '0001' else  tl.brid end) = v_SubBRID

and exists (select faf.acctno from vw_custodycd_subaccount vw
where
\*vw.filtercd like V_STRCUSTODYCD and *\
faf.acctno =  vw.value)
order by busdate, autoid ;*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
