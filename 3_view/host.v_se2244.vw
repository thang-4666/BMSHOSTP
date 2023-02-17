SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SE2244
(LOCATION, ACTYPE, ACCTNO, CODEID, SYMBOL, 
 AFACCTNO, OPNDATE, CLSDATE, LASTDATE, STATUS, 
 PSTATUS, IRTIED, ICCFTIED, IRCD, COSTPRICE, 
 TRADE, ORGAMT, TRADEWTF, ORGTRADEWTF, MORTAGE, 
 MARGIN, NETTING, STANDING, WITHDRAW, DEPOSIT, 
 TRANSFER, LOAN, CUSTID, COSTDT, BLOCKED, 
 BLOCKED_CHK, RECEIVING, PARVALUE, CUSTODYCD, AUTOID, 
 FULLNAME, ADDRESS, LICENSE, TRADEPLACE, MOBILE, 
 IDDATE, IDPLACE, ISSFULLNAME)
BEQUEATH DEFINER
AS 
SELECT FN_GET_LOCATION(af.BRID) LOCATION, se.actype,
          SUBSTR (se.acctno, 1, 4)
       || '.'
       || SUBSTR (se.acctno, 5, 6)
       || '.'
       || SUBSTR (se.acctno, 11, 6) acctno,
       sym.codeid codeid, sym.symbol symbol,
       SUBSTR (se.afacctno, 1, 4) || '.' || SUBSTR (se.afacctno, 5, 6) afacctno,
       se.opndate, se.clsdate, se.lastdate, a1.cdcontent status, se.pstatus,
       a2.cdcontent irtied, a3.cdcontent iccftied, ircd, costprice,
     least(trade -NVL(od.secureamt,0),GETAVLSEWITHDRAW(se.acctno)) trade,least(trade -NVL(od.secureamt,0),GETAVLSEWITHDRAW(se.acctno)) ORGAMT,
        nvl(pit.qtty,0) tradewtf, nvl(pit.qtty,0) ORGTRADEWTF, (mortage -NVL(od.securemtg,0)) mortage, margin, se.netting, standing, withdraw, deposit, transfer, loan,
       SUBSTR (cf.custid, 1, 4) || '.' || SUBSTR (cf.custid, 5, 6) custid, costdt,
       nvl(se.blocked,0) blocked, se.blocked blocked_chk, se.receiving, sym.parvalue, cf.custodycd, 0 autoid,
        cf.fullname, cf.address, cf.idcode  LICENSE, a4.cdcontent tradeplace,cf.mobilesms mobile,cf.iddate,cf.idplace,
        iss.fullname issfullname
  FROM sbsecurities sym, allcode a1, allcode a2, allcode a3,allcode a4, sbsecurities sym2,
  (SELECT    seacctno seacctno,
        SUM (case when od.exectype IN ('NS', 'SS') then remainqtty + execqtty else 0 end)  secureamt,
        SUM (case when od.exectype ='MS' then remainqtty + execqtty else 0 end)  securemtg
        FROM odmast od
        WHERE deltd <> 'Y' AND od.exectype IN ('NS', 'SS','MS')
        and txdate = (select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
   group by seacctno
  ) od, cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt, semast se,
    (
        select acctno,codeid,sum(qtty-mapqtty) qtty
        from sepitlog where deltd <> 'Y' and qtty-mapqtty>0
        group by acctno,codeid
    ) pit, issuers iss
 WHERE a1.cdtype = 'SE'
   AND a1.cdname = 'STATUS'
   AND a1.cdval = se.status
   AND a2.cdtype = 'SY'
   and sym.issuerid = iss.issuerid(+)
   AND a2.cdname = 'YESNO'
   AND a2.cdval = irtied
   AND sym.codeid = se.codeid
   AND sym.sectype <> '004'
   AND a3.cdtype = 'SY'
   AND a3.cdname = 'YESNO'
   and a4.cdtype = 'SE'
   and a4.cdname = 'TRADEPLACE'
   and sym.refcodeid = sym2.codeid(+)
   and (case when sym.refcodeid is null then sym.tradeplace else sym2.tradeplace end) = a4.cdval
   AND a3.cdval = se.iccftied
   AND se.afacctno = af.acctno
   and af.custid = cf.custid
   AND AF.STATUS NOT IN ('C')
   AND se.acctno = od.seacctno(+)
   AND af.actype = aft.actype
   AND af.acctno = ci.afacctno
   AND aft.mrtype = mrt.actype
   AND se.acctno =pit.acctno(+)
   AND trade+ blocked -NVL(od.secureamt,0)>0
/
