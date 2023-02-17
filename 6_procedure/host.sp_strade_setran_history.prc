SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_STRADE_SETRAN_HISTORY" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   p_CustodyCD    in varchar2,
   p_FromDate     IN varchar2,
   p_ToDate       IN varchar2,
   p_SubAC        in varchar2 default null
)
IS
--
-- PURPOSE: Lay lich su giao dich chung khoan cua Sub Account
-- MODIFICATION HISTORY
-- PERSON       DATE            COMMENTS
-------------------------------------------
-- TUNH        20-DEC-06       CREATED


   v_FromDate date;
   v_ToDate date;
   v_AFacctno varchar2(20);
   v_CustodyCD varchar2(10);
   v_CurrDate date;
   v_fullname varchar2(1000);
BEGIN

v_FromDate := to_date(p_FromDate, 'DD/MM/RRRR');
v_ToDate := TO_DATE(p_ToDate, 'DD/MM/RRRR');

-- Get Current Date
select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where sysvar.varname= 'CURRDATE' and grname = 'SYSTEM';

if length(p_SubAc) >0 then
    v_AFacctno := p_SubAc;

    select cf.custodycd, fullname into v_CustodyCD,v_fullname
    from cfmast cf, afmast af
    where cf.custid = af.custid and af.acctno = p_SubAc;

else
    select acctno,fullname into v_AFacctno,v_fullname from
    (
        select cf.custodycd, af.acctno,cf.fullname
        from cfmast cf, afmast af
        where cf.custid = af.custid and cf.custodycd = p_CustodyCD
        order by af.acctno
    ) a
    where rownum = 1;
    v_CustodyCD := p_CustodyCD;
end if;


-- Main report
open PV_REFCURSOR for
select od.afacctno acctno,od.txdate busdate, iod.symbol, a.cdcontent BORS, iod.matchqtty, iod.matchprice, iod.matchqtty * iod.matchprice trAMT,od.txdesc,
    case when od.txdate = v_CurrDate
      then iod.matchqtty * iod.matchprice * odtype.deffeerate/100
        else  iod.matchqtty * iod.matchprice/od.execamt * od.feeamt
    end feeamt_detail
from odtype, allcode a,
(
    select orgorderid, codeid,symbol, bors, matchprice,sum(matchqtty) matchqtty from
    (
        select orgorderid, codeid,symbol, bors, matchprice, matchqtty
        from iodhist
        where deltd <> 'Y' and txdate between v_FromDate and v_ToDate
            and custodycd = v_CustodyCD and matchqtty >0

        union all
        select orgorderid, codeid,symbol, bors, matchprice,matchqtty
        from iod
        where deltd <> 'Y' and txdate between v_FromDate and v_ToDate
            and custodycd = v_CustodyCD and matchqtty >0
    ) i
    group by orgorderid, codeid,symbol, bors, matchprice
) iod,

(
    select tl.busdate, tl.autoid,actype,od.orderid, od.afacctno, od.txnum, od.txdate, od.execamt, od.feeamt,od.execqtty,
  CASE WHEN od.via = 'W' THEN od.orderid || '/' || v_fullname || '/' || od.matchtype || '/' || od.exectype || '/' || od.execqtty || '/' || sb.symbol || '/' || od.quoteprice ELSE tl.txdesc END txdesc
    from tllogall tl, sbsecurities sb,
    (
        -- tllogall
        select actype,orderid, afacctno, txnum, txdate, execamt, feeamt, execqtty,via,exectype,quoteprice,codeid,matchtype
        from odmasthist
        where deltd <> 'Y' and txdate between v_FromDate and v_ToDate
            and afacctno = v_AFacctno and execamt >0
        union all
        select actype,orderid, afacctno, txnum, txdate, execamt, feeamt, execqtty,via,exectype,quoteprice,codeid,matchtype
        from odmast
        where deltd <> 'Y' and txdate between v_FromDate and v_ToDate
            and afacctno = v_AFacctno and execamt >0
    ) od
    where tl.txdate = od.txdate and tl.txnum = od.txnum
  AND sb.codeid = od.codeid

    union all       -- tllog
    select tl.busdate, tl.autoid, actype,od.orderid, od.afacctno, od.txnum, od.txdate, od.execamt, od.feeamt, od.execqtty,
  CASE WHEN od.via = 'W' THEN od.orderid || '/' || v_fullname || '/' || od.matchtype || '/' || od.exectype || '/' || od.execqtty || '/' || sb.symbol || '/' || od.quoteprice ELSE tl.txdesc END txdesc
    from tllog tl, odmast od,sbsecurities sb
    where tl.txdate = od.txdate and tl.txnum = od.txnum AND sb.codeid = od.codeid
        and tl.deltd <> 'Y' and tl.txdate between v_FromDate and v_ToDate
            and od.afacctno = v_AFacctno and execamt >0
) od
where od.orderid = iod.orgorderid and od.actype = odtype.actype
    and iod.bors = a.cdval and a.cdname = 'BORS' and a.cdtype = 'OD'
Order by od.busdate desc, od.autoid desc;



END;

 
 
 
 
/
