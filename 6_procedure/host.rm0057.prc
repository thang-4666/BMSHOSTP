SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RM0057" (
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

SELECT TL.tlname, TL.TXDATE DELDATE, FN_GET_LOCATION(AF.BRID) LOCATION, MST.REQID,MST.OBJNAME, MST.TXDATE,MST.AFFECTDATE, MST.OBJKEY,MST.TRFCODE,
A1.CDCONTENT TRFNAME,MST.BANKCODE,CRB.BANKNAME, CF.CUSTODYCD,MST.AFACCTNO,
MST.BANKACCT BANKACCTNO,CF.FULLNAME BANKACCTNAME, RF.DESACCTNO_R DESACCTNO,
RF.DESACCTNAME_R DESACCTNAME,MST.TXAMT,MST.STATUS,MST.NOTES,TXDESC
FROM vw_crbtxreq_all MST,AFMAST AF,(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,CRBDEFBANK CRB,ALLCODE A1,
 (SELECT *
FROM   (SELECT DTL.REQID, DTL.FLDNAME, NVL(DTL.CVAL,DTL.NVAL) REFVAL
        FROM   vw_crbtxreq_all MST,  VW_crbtxreqdtl_ALL DTL WHERE MST.REQID=DTL.REQID)
PIVOT  (MAX(REFVAL) AS R FOR (FLDNAME) IN
('DESACCTNO' as DESACCTNO,'DESACCTNAME' as DESACCTNAME))
ORDER BY REQID) RF,
(
SELECT TL.TXDATE,TL.TXNUM, TLDTL.nVALUE, TL.TXDESC, TLP.tlname FROM vw_tllog_all TL, vw_tllogfld_all TLDTL, TLPROFILES TLP
    WHERE TLTXCD = '6612' AND TL.TXDATE=TLDTL.TXDATE AND TL.TXNUM=TLDTL.TXNUM and FLDCD = '01'
    AND TL.DELTD <> 'Y' AND TL.TLID = TLP.TLID
    and TL.txdate  between v_FromDate and v_ToDate
) TL

WHERE MST.REQID=RF.REQID AND MST.REQID=TL.NVALUE
AND MST.AFACCTNO = AF.ACCTNO
AND AF.CUSTID=CF.CUSTID AND MST.BANKCODE=CRB.BANKCODE AND MST.STATUS='D'
AND MST.TRFCODE = A1.CDVAL AND A1.CDNAME='TRFCODE'
AND CF.CUSTODYCD LIKE v_CustodyCD
AND AF.ACCTNO LIKE v_AFAcctno

;

EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
