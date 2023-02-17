SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_OL_ORDERSTATUS
(SRC, CUSTID, ACCTNO, ORDERID, SYMBOL, 
 TXDATE, TXTIME, EXECTYPE, QUOTEPRICE, ORDERQTTY, 
 REMAINQTTY, EXECQTTY, ORSTATUS, PRICETYPE, VIA, 
 REFORDERID, EDSTATUS, CANCELQTTY, ADJUSTQTTY, HOSESESSION, 
 FEEDBACKMSG)
BEQUEATH DEFINER
AS 
SELECT   'OD' src,af.custid, afacctno ACCTNO, ORDERID, sb.symbol, od.txdate,
             tl.TXTIME, od.exectype exectype, QUOTEPRICE, ORDERQTTY,
             REMAINQTTY, EXECQTTY, od.orstatus ORSTATUS,
             od.pricetype PRICETYPE, od.via VIA, reforderid,
             od.edstatus EDSTATUS, CANCELQTTY, od.ADJUSTQTTY, od.HOSESESSION,
             '' FEEDBACKMSG
      FROM   odmast od, afmast af, securities_info sb, tllog tl
     WHERE       sb.codeid = od.codeid
             AND od.afacctno = af.acctno
             AND od.txnum = tl.txnum
             AND od.txdate = tl.txdate
             AND TL.TXSTATUS = '1'
    UNION
    SELECT   'FO' src,af.custid, afacctno ACCTNO, od.ACCTNO ORDERID, sb.symbol,
             od.effdate txdate, SUBSTR (CREATEDDT, 12, 8) TXTIME,
             od.exectype exectype, QUOTEPRICE * SB.TRADEUNIT,
             od.QUANTITY ORDERQTTY, REMAINQTTY, EXECQTTY, od.status ORSTATUS,
             od.pricetype PRICETYPE, od.via VIA, REFACCTNO reforderid,
             '------' EDSTATUS, CANCELQTTY, od.AMENDQTTY ADJUSTQTTY,
             'N' HOSESESSION, od.FEEDBACKMSG
      FROM   fomast od, afmast af, securities_info sb
     WHERE       sb.codeid = od.codeid
             AND od.afacctno = af.acctno
             AND od.status = 'R'
             OR od.status = 'P'
/
