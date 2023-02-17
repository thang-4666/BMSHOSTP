SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL1005" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2
   --TLID IN VARCHAR2
  )
IS
--

-- BAO CAO Sao ke tien cua tai khoan khach hang
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- TUNH        13-05-2010           CREATED
--
   --CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate date;
   v_ToDate date;
   v_CurrDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   V_SUM number(20);
   V_PS number(20);
--   v_TLID varchar2(4);

BEGIN

--v_TLID := TLID;
V_STROPTION := OPT;
IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(BRID,1,2) || '__' ;
else
    V_STRBRID:=BRID;
END IF;

v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
v_ToDate:= to_date(T_DATE,'DD/MM/RRRR');
v_CustodyCD:= upper(replace(pv_custodycd,'.',''));
v_AFAcctno:= upper(replace(PV_AFACCTNO,'.',''));

if v_AFAcctno = 'ALL' or v_AFAcctno is null then
    v_AFAcctno := '%';
else
    v_AFAcctno := v_AFAcctno;
end if;

    SELECT sum(ci.dfdebtamt) into V_SUM
    FROM cimast ci, cfmast cf, afmast af
    WHERE cf.custodycd LIKE v_CustodyCD
    AND af.acctno LIKE v_AFAcctno
    AND af.custid = cf.custid
    AND ci.afacctno = af.acctno;

    SELECT sum(case when app.txtype = 'D' then -vw.namt else vw.namt END) into V_PS
    FROM cfmast cf, afmast af, vw_tllog_citran_all vw, apptx app
    WHERE app.txtype IN ('D','C')
    AND app.apptype = 'CI'
    AND app.field = 'DFDEBTAMT'
    AND cf.custodycd LIKE v_CustodyCD
    AND af.acctno LIKE v_AFAcctno
    AND vw.busdate >= v_FromDate
    AND vw.txcd = app.txcd
    AND cf.custid = af.custid;

OPEN PV_REFCURSOR FOR

    SELECT V_SUM - V_PS CI_BAL, cf.custodycd, af.acctno, cf.fullname, vw.TXNUM, vw.TXDATE, vw.TXDESC,
          case when app.txtype = 'D' then vw.namt else 0 end ci_debit_amt,
          case when app.txtype = 'C' then vw.namt else 0 end ci_credit_amt
    FROM cfmast cf, afmast af ,vw_tllog_citran_all vw, apptx app
    WHERE  app.txtype IN ('D','C')
    AND app.apptype = 'CI'
    AND app.field = 'DFDEBTAMT'
    AND cf.custodycd LIKE v_CustodyCD
    AND af.acctno LIKE v_AFAcctno
    AND vw.busdate  >= v_FromDate AND vw.busdate <= v_ToDate
    AND vw.txcd = app.txcd
    AND cf.custid = af.custid
    AND vw.namt <> 0
    ORDER BY txdate, txnum;
EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;  -- PROCEDURE

 
 
 
 
/
