SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SE2242
(LOCATION, ACTYPE, ACCTNO, TYPENAME, CODEID, 
 SYMBOL, AFACCTNO, OPNDATE, CLSDATE, LASTDATE, 
 STATUS, PSTATUS, IRTIED, ICCFTIED, IRCD, 
 COSTPRICE, TRADE, ORGAMT, TRADEWTF, ORGTRADEWTF, 
 MORTAGE, MARGIN, NETTING, STANDING, WITHDRAW, 
 DEPOSIT, TRANSFER, LOAN, CUSTID, COSTDT, 
 BLOCKED, BLOCKED_CHK, RECEIVING, PARVALUE, CUSTODYCD, 
 AUTOID, IDCODE, FULLNAME, IDDATE, IDPLACE, 
 ADDRESS, ACCTNOAFMAST)
BEQUEATH DEFINER
AS 
SELECT FN_GET_LOCATION(af.BRID) LOCATION, actype,
          SUBSTR (semast.acctno, 1, 4)
       || '.'
       || SUBSTR (semast.acctno, 5, 6)
       || '.'
       || SUBSTR (semast.acctno, 11, 6) acctno,AFT.TYPENAME,
       sym.codeid codeid, sym.symbol symbol,
       SUBSTR (semast.afacctno, 1, 4) || '.' || SUBSTR (semast.afacctno, 5, 6) afacctno,
       opndate, clsdate, lastdate, a1.cdcontent status, semast.pstatus,
       a2.cdcontent irtied, a3.cdcontent iccftied, ircd, Fn_SECostPriceCalculateDtl(semast.acctno) costprice,
       semast.trade - nvl(tlp.trade,0) trade ,
          semast.trade- nvl(tlp.trade,0) ORGAMT,
       nvl(pit.qtty,0) tradewtf, nvl(pit.qtty,0) ORGTRADEWTF, (mortage ) mortage, margin, netting, standing, withdraw, deposit, transfer, loan,
       SUBSTR (custid, 1, 4) || '.' || SUBSTR (custid, 5, 6) custid, costdt,
       nvl(semast.blocked,0)-nvl(tlp.blocked,0) blocked, semast.blocked -nvl(tlp.blocked,0) blocked_chk, receiving, sym.parvalue, cf.custodycd, '0' autoid,
       cf.idcode,  cf.fullname, cf.iddate, cf.idplace, cf.ADDRESS,af.acctnoafmast
  FROM sbsecurities sym, allcode a1, allcode a2, allcode a3,
    (select custodycd, custid custidcfmast, idcode,fullname, iddate, idplace,ADDRESS  from cfmast) cf,
    (select brid,ACTYPE AFTYPE, custid custidafmast, acctno acctnoafmast from afmast WHERE STATUS NOT IN ('C')) af,
    (SELECT ACTYPE AFTYPE, TYPENAME FROM AFTYPE) AFT,
     semast,
(select acctno,sum(qtty-mapqtty) qtty
    from sepitlog where deltd <> 'Y' and qtty-mapqtty>0
    group by acctno) pit,
(select seacctno , sum(trade) trade , sum (blocked)blocked
from
   (select  max(decode (tlfld.fldcd,'03', cvalue,'')) seacctno, max( decode (tlfld.fldcd,'10', nvalue,0)) trade, max( decode (tlfld.fldcd,'06', nvalue,0)) blocked
    from tllog tl,tllogfld tlfld
    where tltxcd ='2242' and txstatus ='4'
    and tl.txnum = tlfld.txnum
    AND tl.deltd <>'Y'
    group by tl.txnum)
group by  seacctno ) tlp
 WHERE a1.cdtype = 'SE'
   AND a1.cdname = 'STATUS'
   AND a1.cdval = semast.status
   AND a2.cdtype = 'SY'
   AND a2.cdname = 'YESNO'
   AND a2.cdval = irtied
   AND sym.codeid = semast.codeid
   AND sym.sectype <> '004'
   AND a3.cdtype = 'SY'
   AND a3.cdname = 'YESNO'
   AND a3.cdval = semast.iccftied
   AND semast.afacctno = af.acctnoafmast
   and af.custidafmast = cf.custidcfmast
   AND AF.AFTYPE = AFT.AFTYPE
   AND nvl(semast.blocked,0) + semast.trade - nvl(tlp.trade,0)-nvl(tlp.blocked,0)> 0
   and semast.acctno =pit.acctno(+)
   and semast.acctno =tlp.seacctno(+)
/
