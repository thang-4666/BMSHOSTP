SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL1000_OLD" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   MNEMONIC       IN       VARCHAR2
)
IS
--
-- PURPOSE: Bao cao Rut nop tien mat
--
-- MODIFICATION HISTORY
-- PERSON               DATE                COMMENTS
-- ---------------      -----------         ---------------------
-- TUNH                 22/05/2010          Tao moi
-- Huynh.nd             22/09/2010          Chinh sua dong 86-91
-- Huynh.nd        22/10/2010      Chinh sua loi khi chay dieu kien ALL change ID 94
-- ---------   ------  -------------------------------------------
  V_STROPTION            VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID              VARCHAR2 (4);
  v_FromDate date;
  v_ToDate date;
  v_mnemonic varchar2(100);
  v_GLAcctno varchar2(30);
  v_GLName varchar2(300);
  v_EndBal number(28,4);
  v_tramt_from_curr number(28,4);


BEGIN

    V_STROPTION := OPT;

    IF V_STROPTION = 'A' THEN
        V_STRBRID := '%';
    ELSif V_STROPTION = 'B' THEN
        V_STRBRID := substr(BRID,1,2) || '__';
    else
        V_STRBRID := BRID;
    END IF;

    v_FromDate := to_date(F_DATE,'DD/MM/RRRR');
    v_ToDate := to_date(T_DATE,'DD/MM/RRRR');
    v_mnemonic := TRIM(upper(MNEMONIC));



Open PV_REFCURSOR FOR
select  '' GLAcctno, '' GLName, 0 EndBal, 0 tramt_from_curr,
    0 BeginBal,
    af.acctno, ci.txdate, ci.busdate, ci.txnum, ci.tltxcd, ci.txdesc,mk.tlname maker_name, ch.tlname checker_name,
    case
     when ci.tltxcd in('1100','1107') then ci.msgamt else 0
    end debit_amt,
    case
   when ci.tltxcd in('1140') then ci.msgamt else 0
    end credit_amt,
    cf.custodycd, af.acctno afacctno, cf.fullname, ci.autoid
from vw_tllog_all ci,  tlprofiles mk, tlprofiles ch, cfmast cf, afmast af
 where ci.tltxcd in('1140','1100','1107')
   and ci.tlid = mk.tlid
   and ci.offid = ch.tlid(+)
   and cf.custid=af.custid
   and af.acctno=ci.msgacct
   and ci. busdate >=v_FromDate
   and ci.busdate <=v_ToDate
   order by ci.txdate,ci.autoid;


EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;

 
 
 
 
/
