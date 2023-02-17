SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI1025" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   pv_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2,
   BANKID                 IN       VARCHAR2,
   BRANHID                IN       VARCHAR2,
   CI_TLTXCD              IN       VARCHAR2,
   CI_TYPE                IN       VARCHAR2
  )
IS
--
   /* ThangNV: Cap nhat 03/01/2014 */

   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate     date;
   v_ToDate       date;
   v_CurrDate     date;
   v_CustodyCD    varchar2(20);
   v_AFAcctno     varchar2(20);
   v_TLID         varchar2(4);
   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;

   v_BANKID     VARCHAR2(10);
   v_BRANHID    VARCHAR2(10);
   v_CI_TLTXCD  VARCHAR2(10);
   v_CI_TYPE    VARCHAR2(10);

BEGIN


   V_STROPTION := OPT;

   IF V_STROPTION = 'A' then
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(pv_BRID,1,2) || '__' ;
   else
    V_STRBRID:=pv_BRID;
   END IF;

   v_FromDate  :=     TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   v_ToDate    :=     TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    IF BANKID IS NULL OR UPPER(BANKID) = 'ALL' THEN
        v_BANKID := '%';
    ELSE
        v_BANKID := BANKID;
    END IF;

   IF BRANHID IS NULL OR UPPER(BRANHID) = 'ALL' THEN
        v_BRANHID := '%';
    ELSE
        v_BRANHID := BRANHID;
    END IF;

    IF CI_TLTXCD IS NULL OR UPPER(CI_TLTXCD) = 'ALL' THEN
        v_CI_TLTXCD := '%';
    ELSE
        v_CI_TLTXCD := CI_TLTXCD;
    END IF;

    IF CI_TYPE IS NULL OR UPPER(CI_TYPE) = 'ALL' THEN
        v_CI_TYPE := '%';
    ELSE
        v_CI_TYPE :=  CI_TYPE;
    END IF;

   select TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) into v_CurrDate from SYSVAR where grname='SYSTEM' and varname='CURRDATE';

OPEN PV_REFCURSOR FOR
select BR.brname, tci.autoid orderid, tci.custid, tci.custodycd ,
    tci.fullname,tci.cmnd CMND, tci.tllog_autoid autoid, tci.txtype,
    tci.busdate, nvl(tci.trdesc,tci.txdesc) txdesc,
    '' symbol, 0 se_credit_amt, 0 se_debit_amt,
    case when tci.txtype = 'C' then namt else 0 end ci_credit_amt,
    case when tci.txtype = 'D' then namt else 0 end ci_debit_amt,
    tci.txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, tci.dfacctno dealno,
    tci.old_dfacctno description, tci.trdesc, tci.bkdate, ba.bankacctno
from
    (
    -- Cac GD 1115, 1121 va 1135 co truong Transaction Type la 18
    SELECT 0 AUTOID, max(CF.custodycd) custodycd, max(cf.custid) custid,
        max(case when (tl.tltxcd = '1134' and tla.fldcd = '09') or (tl.tltxcd in ('1115','1121','1135') and tla.fldcd = '18') then tla.cvalue else null end) citype,
        max(case when tla.fldcd = '90' then tla.cvalue else null end) fullname,
        TL.txnum, TL.txdate, max(case when tla.fldcd = '01' then tla.cvalue else null end) cmnd, 'C' txcd, max(tl.msgamt) namt, '' camt, '' ref,
        max(nvl(TL.deltd, 'N')) deltd, max(TL.MSGacct) acctref, tl.tltxcd, tl.busdate, max(tl.txdesc) txdesc,
        max(tl.txtime) txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
        '' dfacctno,' ' old_dfacctno, 'D' txtype, 'BALANCE' field,
        max(tl.autoid) tllog_autoid, '' trdesc, TL.txdate bkdate,
        max(case when tla.fldcd = '02' then tla.cvalue else null end) bankid
    FROM VW_TLLOG_ALL TL, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_tllogfld_all tla
    where tl.txdate = tla.txdate and tl.txnum = tla.txnum and tla.fldcd in ('90','02','01','09','18')
        and TL.MSGacct = cf.idcode (+)
        and tl.deltd <> 'Y'
        AND TL.TLTXCD IN ('1134','1115','1121','1135')


    group by TL.txnum, TL.txdate, tl.tltxcd, tl.busdate, tl.brid, tl.tlid, tl.offid, tl.chid

    union all

    -- Cac GD 1133 va 1136 deu co truong Transaction Type la 09
    SELECT 0 AUTOID, max(CF.custodycd) custodycd, max(cf.custid) custid,
        max(case when tla.fldcd = '09' then tla.cvalue else null end) ci_type,
        max(case when tla.fldcd = '90' then tla.cvalue else null end) fullname,
        TL.txnum, TL.txdate, max(case when tla.fldcd = '01' then tla.cvalue else null end) cmnd, 'C' txcd, max(tl.msgamt) namt, '' camt, '' ref,
        max(nvl(TL.deltd, 'N')) deltd, max(TL.MSGacct) acctref, tl.tltxcd, tl.busdate, max(tl.txdesc) txdesc,
        max(tl.txtime) txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
        '' dfacctno,' ' old_dfacctno, 'C' txtype, 'BALANCE' field,
        max(tl.autoid) tllog_autoid, '' trdesc, TL.txdate bkdate,
        max(case when tla.fldcd = '02' then tla.cvalue else null end) bankid
    FROM VW_TLLOG_ALL TL, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_tllogfld_all tla
    where tl.txdate = tla.txdate and tl.txnum = tla.txnum and tla.fldcd IN ('90','02','01','09')
        and TL.MSGacct = cf.idcode (+)
        and tl.deltd <> 'Y' AND TL.TLTXCD IN ('1133','1136')

    group by TL.txnum, TL.txdate, tl.tltxcd, tl.busdate, tl.brid, tl.tlid, tl.offid, tl.chid


    union all

    select tr.autoid, cf.custodycd, cf.custid, ' ' citype,cf.fullname, tr.txnum, tr.txdate, cf.idcode, tr.txcd, tr.namt,
        tr.camt, tr.ref, nvl(tr.deltd, 'N') deltd, tr.acctref, tr.tltxcd, tr.busdate, tr.txdesc,
        tr.txtime, tr.brid, tr.tlid, tR.offid, tr.chid, tr.ref dfacctno, ' ' old_dfacctno,
        tr.txtype, tr.field, tr.autoid tllog_autoid, tr.trdesc,
        nvl(tr.busdate, tr.txdate) bkdate , tla.cvalue bankid
    from vw_citran_gen TR, vw_tllogfld_all TLA, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
    where TR.txdate = TLA.txdate and TR.txnum = TLA.txnum and tla.fldcd = '02'
        and cf.custid = af.custid and tr.acctno = af.acctno --and af.corebank <> 'Y'
        and tr.txtype in ('D','C') and tr.deltd <> 'Y' and tr.namt <> 0
        AND Tr.TLTXCD in ('1131','1132') and tr.field = 'BALANCE'

    ) tci, BRGRP BR, BANKNOSTRO ba
where tci.bkdate between v_FromDate and v_ToDate
    and tci.brid =  BR.brid and
    tci.bankid = ba.SHORTNAME(+)
    AND TCI.BANKID LIKE v_BANKID
    AND TCI.BRID LIKE v_BRANHID
    AND TCI.TLTXCD LIKE v_CI_TLTXCD
    and TCI.CITYPE like v_CI_TYPE
ORDER BY BR.BRNAME, tci.TXDATE, tci.TXNUM;

EXCEPTION
  WHEN OTHERS
   THEN
      Return;

End;

 
 
 
 
/
