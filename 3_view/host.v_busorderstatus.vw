SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_BUSORDERSTATUS
(CUSTID, ACCTNO, ORDERID, SYMBOL, TXDATE, 
 TXTIME, EXECTYPE, QUOTEPRICE, ORDERQTTY, REMAINQTTY, 
 EXECQTTY, ORSTATUS, PRICETYPE, VIA, REFORDERID, 
 EDSTATUS, CANCELQTTY, ADJUSTQTTY, HOSESESSION, FEEDBACKMSG)
BEQUEATH DEFINER
AS 
(
select af.custid,afacctno ACCTNO,ORDERID,sb.symbol,od.txdate,tl.TXTIME,a2.cdcontent exectype,QUOTEPRICE,ORDERQTTY,REMAINQTTY,EXECQTTY,a1.cdcontent ORSTATUS
,a3.cdcontent PRICETYPE,a4.cdcontent VIA,reforderid,to_char(a5.cdcontent) EDSTATUS,CANCELQTTY,od.ADJUSTQTTY,od.HOSESESSION,'' FEEDBACKMSG
from odmast od,afmast af,allcode a1 ,allcode a2,allcode a3,allcode a4,securities_info sb, allcode a5,tllog tl
where a1.cdname='ORSTATUS' and a1.CDTYPE='OD' and a1.cdval=od.orstatus
and a2.cdname='EXECTYPE' and a2.CDTYPE='OD' and a2.cdval=od.exectype
and a3.cdname='PRICETYPE' and a3.CDTYPE='OD' and a3.cdval=od.pricetype
and a4.cdname='VIA' and a4.CDTYPE='OD' and a4.cdval=od.via
and a5.cdname='EDSTATUS' and a5.CDTYPE='OD' and a5.cdval=od.edstatus
and sb.codeid=od.codeid and od.afacctno =af.acctno
and od.txnum=tl.txnum and od.txdate=tl.txdate and TL.TXSTATUS='1'
union
select af.custid,afacctno ACCTNO,od.ACCTNO ORDERID,sb.symbol,od.effdate txdate,substr(CREATEDDT,12,8) TXTIME,a2.cdcontent exectype,QUOTEPRICE*SB.TRADEUNIT,od.QUANTITY ORDERQTTY,REMAINQTTY,EXECQTTY,a1.cdcontent ORSTATUS
,a3.cdcontent PRICETYPE,a4.cdcontent VIA,REFACCTNO reforderid,'------' EDSTATUS,CANCELQTTY,od.AMENDQTTY ADJUSTQTTY,'N' HOSESESSION,od.FEEDBACKMSG
from fomast od,afmast af,allcode a1 ,allcode a2,allcode a3,allcode a4,securities_info sb
where a1.cdname='STATUS' and a1.CDTYPE='FO' and a1.cdval=od.status
and a2.cdname='EXECTYPE' and a2.CDTYPE='OD' and a2.cdval=od.exectype
and a3.cdname='PRICETYPE' and a3.CDTYPE='OD' and a3.cdval=od.pricetype
and a4.cdname='VIA' and a4.CDTYPE='OD' and a4.cdval=od.via
and sb.codeid=od.codeid and od.afacctno =af.acctno
and od.status='R'
)
/
