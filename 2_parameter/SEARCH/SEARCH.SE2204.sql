SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2204','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2204', 'Cắt chứng khoán bán(Giao dịch 2204)', 'View account to outward transfer (wait for 2204)', 'SELECT FN_GET_LOCATION(af.BRID) LOCATION, semast.actype,
          SUBSTR (semast.acctno, 1, 4)
       || ''.''
       || SUBSTR (semast.acctno, 5, 6)
       || ''.''
       || SUBSTR (semast.acctno, 11, 6) acctno,
       sym.codeid codeid,sym.symbol symbol,
       SUBSTR (semast.afacctno, 1, 4) || ''.'' || SUBSTR (semast.afacctno, 5, 6) afacctno,
       semast.opndate, semast.clsdate, semast.lastdate, a1.cdcontent status, semast.pstatus,
       a2.cdcontent irtied, a3.cdcontent iccftied, ircd, costprice,
     least(trade -NVL(od.secureamt,0),GETAVLSEWITHDRAW(semast.acctno)) trade,least(trade -NVL(od.secureamt,0),GETAVLSEWITHDRAW(semast.acctno)) ORGAMT,
        nvl(pit.qtty,0) tradewtf, nvl(pit.qtty,0) ORGTRADEWTF, (mortage -NVL(od.securemtg,0)) mortage, margin, semast.netting, standing, withdraw, deposit, transfer, loan,
       SUBSTR (cf.custid, 1, 4) || ''.'' || SUBSTR (cf.custid, 5, 6) custid, costdt,
       semast.blocked blocked, semast.blocked blocked_chk, semast.receiving, sym.parvalue, cf.custodycd, 0 autoid,
        cf.fullname, cf.address,cf.idcode  LICENSE
  FROM sbsecurities sym, allcode a1, allcode a2, allcode a3,
  (SELECT    seacctno seacctno,
        SUM (case when od.exectype IN (''NS'', ''SS'') then remainqtty + execqtty else 0 end)  secureamt,
        SUM (case when od.exectype =''MS'' then remainqtty + execqtty else 0 end)  securemtg
        FROM odmast od
        WHERE deltd <> ''Y'' AND od.exectype IN (''NS'', ''SS'',''MS'')
        and txdate = (select to_date(VARVALUE,''DD/MM/YYYY'') from sysvar where grname=''SYSTEM'' and varname=''CURRDATE'')
   group by   seacctno
  ) od, cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt ,
semast,
(select acctno,sum(qtty-mapqtty) qtty
    from sepitlog where deltd <> ''Y'' and qtty-mapqtty>0
    group by acctno) pit
 WHERE a1.cdtype = ''SE''
   AND a1.cdname = ''STATUS''
   AND a1.cdval = semast.status
   AND a2.cdtype = ''SY''
   AND a2.cdname = ''YESNO''
   AND a2.cdval = irtied
   AND sym.codeid = semast.codeid
   AND sym.sectype <> ''004''
   AND a3.cdtype = ''SY''
   AND a3.cdname = ''YESNO''
   AND a3.cdval = semast.iccftied
   AND semast.afacctno = af.acctno
   and af.custid = cf.custid
   AND semast.acctno =od.seacctno(+)
   AND af.actype = aft.actype
   AND af.acctno = ci.afacctno
   AND aft.mrtype = mrt.actype
   and semast.acctno =pit.acctno(+)
   AND trade+ blocked -NVL(od.secureamt,0)>0
   ', 'SEMAST', 'frmSEMAST', '', '2204', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;