SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1004 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2 ,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   P_DATE         IN       VARCHAR2,
   custodycd      IN       VARCHAR2,
   PV_AFACCTNO    IN       varchar2,
   TLID           IN       VARCHAR2
)
IS

   V_STROPTION          VARCHAR2 (5);
   V_STRBRID            VARCHAR2 (4);
   v_strcustodycd       VARCHAR2 (20);
   V_P_date             date;
   V_CRRDATE            date;
   V_SETDATE            date;
   V_VAT                number;
   V_STRTLID            VARCHAR2(6);
   V_STRAFACCTNO        VARCHAR2 (20);
V_SYSCLEARDAY            number;
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

   v_strcustodycd := upper(custodycd);

   IF (PV_AFACCTNO = 'ALL') OR (PV_AFACCTNO is null)
   THEN
      V_STRAFACCTNO := '%';
   ELSE
      V_STRAFACCTNO := PV_AFACCTNO;
   END IF;

   select to_date(varvalue,'dd/mm/rrrr') into V_CRRDATE  from sysvar where varname = 'CURRDATE';
    --select varvalue into V_VAT from sysvar where varname = 'ADVSELLDUTY' and grname = 'SYSTEM';
 --   V_SETDATE := getduedate(V_P_date, 'B', '000', 3);
       --T2- NAMNT
    SELECT fn_getSYSCLEARDAY(V_P_date) INTO V_SYSCLEARDAY FROM dual;
    --ngoc.vu-Jira561
    --V_SETDATE := getduedate(V_P_date, 'B', '000', V_SYSCLEARDAY);
    V_SETDATE := getduedate(V_P_date, 'B', '001', V_SYSCLEARDAY);
    --End T2-NAMNT


-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR

select  V_P_date IN_DATE, cf.fullname, cf.address, cf.custodycd,
    (io.matchqtty) exqtty, io.matchprice exprice, (io.matchqtty*io.matchprice) examt,
    od.orderqtty orderqtty, od.quoteprice quoteprice,
    (case when od.execamt > 0 and od.feeacr = 0 then
        ROUND(IO.matchqtty * io.matchprice * odt.deffeerate / 100, 2)
    else
        (CASE WHEN (od.execamt * od.feeacr) = 0 THEN 0 ELSE
            (CASE WHEN od.TXDATE = V_CRRDATE THEN ROUND(IO.matchqtty * io.matchprice * odt.deffeerate/100,2)
                ELSE ROUND(io.matchqtty * io.matchprice/od.execamt * od.feeacr, 2) END)
            END)
    end) feeamt,
    sb.symbol, od.exectype,
    case when  od.taxrate <>0 then  od.taxrate/100*(IO.matchqtty * io.matchprice) else (decode (cf.whtax,'Y', ROUND(TO_NUMBER(nvl(SYS1.VARVALUE,0)),5),'N',0 )+
    decode (cf.VAT,'Y', ROUND(TO_NUMBER(nvl(SYS.VARVALUE,0)),5),'N',0 )) /100*(IO.matchqtty * io.matchprice) END   selling_tax,
    V_SETDATE txdate, od.orderid, al.cdcontent tradeplace
from (select * from odmast where txdate = V_P_date
        union all select * from odmasthist where txdate = V_P_date
    ) od,
    (select * from iod where txdate = V_P_date
        union all select * from iodhist where txdate = V_P_date
    ) io,
    sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf, afmast af, ODTYPE ODT, aftype aft, allcode al, SYSVAR SYS, SYSVAR SYS1
where od.codeid = sb.codeid
    and af.custid = cf.custid
    and af.actype = aft.actype
    AND AF.ACTYPE NOT IN ('0000')
    and od.orderid = io.orgorderid
    and af.acctno = od.afacctno
    AND oD.ACTYPE = ODT.ACTYPE
    and sb.tradeplace = al.cdval
    AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
    AND SYS1.GRNAME = 'SYSTEM' AND SYS1.VARNAME = 'WHTAX'
    and al.cdname like 'TRADEPLACE'
    and al.cdtype = 'OD'
    AND OD.DELTD <> 'Y'
    and od.exectype IN ('NS','MS','SS')
    and cf.custodycd = v_strcustodycd
    and od.afacctno like V_STRAFACCTNO

;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
