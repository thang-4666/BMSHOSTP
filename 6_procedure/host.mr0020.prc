SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0020" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

   V_IDATE           DATE; --ngay lam viec gan ngay indate nhat
   v_CurrDate        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);
   v_strcustodycd   VARCHAR2(20);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS

    v_idate := to_date(I_DATE,'dd/mm/rrrr');
    if(upper(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD is null) then
        v_strcustodycd := '%';
    else
        v_strcustodycd := UPPER(PV_CUSTODYCD);
    end if ;
---    SELECT max(sbdate) V_IDATE V_FDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(F_DATE,'DD/MM/RRRR');
---   SELECT max(sbdate) INTO v_TDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(T_DATE,'DD/MM/RRRR');
----   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
    select v_idate indate, cf.custodycd, cf.fullname,
    sum(case when od.tradeplace = '001' then od.execamt else 0 end) HOSE_AMT,
    sum(case when od.tradeplace = '001' then (CASE WHEN OD.EXECAMT > 0 AND OD.FEEACR = 0
        THEN ROUND(OD.EXECAMT*ODT.DEFFEERATE/100) ELSE OD.FEEACR END) else 0 end) HOSE_FEEACR,
    sum(case when od.tradeplace = '002' then od.execamt else 0 end) HNX_AMT,
    sum(case when od.tradeplace = '002' then (CASE WHEN OD.EXECAMT > 0 AND OD.FEEACR = 0
        THEN ROUND(OD.EXECAMT*ODT.DEFFEERATE/100) ELSE OD.FEEACR END) else 0 end) HNX_FEEACR,
    sum(case when od.tradeplace = '005' then od.execamt else 0 end) UP_AMT,
    sum(case when od.tradeplace = '005' then (CASE WHEN OD.EXECAMT > 0 AND OD.FEEACR = 0
        THEN ROUND(OD.EXECAMT*ODT.DEFFEERATE/100) ELSE OD.FEEACR END) else 0 end) UP_FEEACR
from afmast af, aftype aft, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
    vw_odmast_tradeplace_all od, allcode A1, ODTYPE odt
where af.actype = aft.actype and aft.istrfbuy = 'Y'
    and od.afacctno = af.acctno and A1.cdtype = 'OD' and A1.cdname like 'TRADEPLACE'
    and od.tradeplace = A1.cdval and od.tradeplace in ('002','001','005')
    and af.custid = cf.custid and odt.actype = OD.ACTYPE and od.exectype = 'NB'
    and cf.custodycd like v_strcustodycd and od.txdate = v_idate
group by cf.custodycd, cf.fullname
    ;
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
