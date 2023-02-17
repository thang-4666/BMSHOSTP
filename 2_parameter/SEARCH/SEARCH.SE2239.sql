SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2239','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2239', 'Chuyển đổi chứng khoán nội bộ cùng khách hàng thành tiền (Giao dịch 2239)', 'View account transfer to other account(wait for 2242)', 'SELECT SUBSTR (semast.acctno, 1, 4) || ''.'' || SUBSTR (semast.acctno, 5, 6) || ''.'' || SUBSTR (semast.acctno, 11, 6) acctno,
       sym.codeid codeid, sym.symbol symbol,
       SUBSTR (semast.afacctno, 1, 4) || ''.'' || SUBSTR (semast.afacctno, 5, 6) afacctno,
       a1.cdcontent status,
       semast.trade- nvl(b.secureamt,0) trade,
       SUBSTR (cf.custid, 1, 4) || ''.'' || SUBSTR (cf.custid, 5, 6) custid, cf.custodycd,  cf.custodycd custodycdref,
       cf.idcode,  cf.fullname, cf.iddate, cf.idplace, cf.ADDRESS, aft.mnemonic
  FROM cfmast cf, afmast af, aftype aft, mrtype mrt, semast , sbsecurities sym, allcode a1,
       v_getsellorderinfo b
 WHERE a1.cdtype = ''SE''
   AND a1.cdname = ''STATUS''
   AND a1.cdval = semast.status
   AND sym.codeid = semast.codeid
   AND sym.sectype <> ''004''
   AND semast.afacctno = af.acctno
   AND semast.acctno = b.seacctno(+)
   AND AF.STATUS NOT IN (''C'')
   and af.custid = cf.custid and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = ''T'' --and aft.istrfbuy = ''Y''
     and semast.trade > 0', 'SEMAST', 'frmSEMAST', '', '2239', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;