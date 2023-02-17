SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1005 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   P_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID           IN       VARCHAR2
)
IS

   V_STROPTION          VARCHAR2 (5);
   V_STRBRID            VARCHAR2 (4);
   v_strcustodycd       VARCHAR2 (20);
   V_STRAFACCTNO        VARCHAR2 (20);
   V_P_date             date;
   V_CRRDATE            date;
   V_Set_day            date;
   V_VAT                number;
   V_STRTLID            VARCHAR2(6);
   V_SYSCLEARDAY      NUMBER;
BEGIN
    V_P_date := TO_DATE(P_date,'dd/mm/rrrr');
    V_STRTLID:= TLID;
    V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


    V_STRCUSTODYCD := UPPER(CUSTODYCD);

    IF  (PV_AFACCTNO <> 'ALL')
    THEN
        V_STRAFACCTNO := PV_AFACCTNO;
    ELSE
        V_STRAFACCTNO := '%%';
    END IF;

    select to_date(varvalue,'dd/mm/rrrr') into V_CRRDATE  from sysvar where varname = 'CURRDATE';
    --V_Set_day := getduedate(V_P_date, 'B', '000', 3);
        --T2- NAMNT
    SELECT fn_getSYSCLEARDAY(V_P_date) INTO V_SYSCLEARDAY FROM dual;
    -- V_SETDATE := getduedate(V_P_date, 'B', '000', 3);
    --ngoc.vu-Jira561
   -- V_Set_day := getduedate(V_P_date, 'B', '000', V_SYSCLEARDAY);
    V_Set_day := getduedate(V_P_date, 'B', '001', V_SYSCLEARDAY);
    --End T2-NAMNT

-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
select V_P_date in_date, cf.fullname, cf.address, cf.custodycd,
    (io.matchqtty) exqtty,
    (io.matchprice) exprice,
    (io.matchqtty*io.matchprice) examt,
    (od.orderqtty) orderqtty,
    (od.quoteprice) quoteprice,
    (case when od.execamt > 0 and od.feeacr = 0 then
        ROUND(IO.matchqtty * io.matchprice * odt.deffeerate / 100, 2)
    else
        (CASE WHEN (od.execamt * od.feeacr) = 0 THEN 0 ELSE
            (CASE WHEN od.TXDATE = V_CRRDATE THEN ROUND(IO.matchqtty * io.matchprice * odt.deffeerate/100,2)
                ELSE ROUND(io.matchqtty * io.matchprice/od.execamt * od.feeacr, 2) END)
            END)
    end) feeamt, sb.symbol, od.exectype, V_Set_day txdate, od.orderid
from (select * from odmast where txdate = V_P_date
        union all select * from odmasthist where txdate = V_P_date
    ) od,
    (select * from iod where txdate = V_P_date
        union all select * from iodhist where txdate = V_P_date
    ) io,
    sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf, afmast af, ODTYPE ODT
where od.codeid = sb.codeid
    and od.orderid = io.orgorderid
    and af.custid = cf.custid
    and af.acctno = od.afacctno
    AND AF.ACTYPE NOT IN ('0000')
    and od.ACTYPE = ODT.ACTYPE
    and od.deltd <> 'Y'
    and od.exectype IN ('NB','BC')
    and cf.custodycd = v_strcustodycd
    and od.afacctno like V_STRAFACCTNO
    and od.txdate = V_P_date
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
