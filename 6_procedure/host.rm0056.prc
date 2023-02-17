SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RM0056" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2
  )
IS
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate date;
   v_ToDate date;
   v_CurrDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   v_TLID varchar2(4);

   -- added by Truong for logging
   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;
   v_tmtracham NUMBER;

BEGIN

-- return;

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

if v_CustodyCD = 'ALL' or v_CustodyCD is null then
    v_CustodyCD := '%';
else
    v_CustodyCD := v_CustodyCD;
end if;
---------------------------------------------------------------------------------
select to_date(VARVALUE,'DD/MM/YYYY') into v_CurrDate from sysvar where grname='SYSTEM' and varname='CURRDATE';


OPEN PV_REFCURSOR FOR
SELECT CF.FULLNAME, CF.IDCODE, CF.iddate, CF.idplace, CF.MOBILE, CF.ADDRESS, CF.CUSTODYCD , CRBD.REFDORC, CRB.*,
CASE WHEN REFDORC = 'C' THEN CRB.TXAMT ELSE 0 END DEBIT,
CASE WHEN REFDORC = 'D' THEN CRB.TXAMT ELSE 0 END CREDIT
    FROM vw_crbtxreq_all CRB, AFMAST AF, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF, CRBDEFACCT CRBD
WHERE CRB.OBJNAME NOT IN ('6640','6600')  AND CRB.OBJNAME LIKE '66%' AND CRB.STATUS = 'C'
AND CRB.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
AND CRB.TRFCODE= CRBD.TRFCODE AND CRB.bankcode = CRBD.REFBANK
and txdate between v_FromDate and v_ToDate
and cf.custodycd like v_CustodyCD
and crb.afacctno like v_AFAcctno
;

EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
