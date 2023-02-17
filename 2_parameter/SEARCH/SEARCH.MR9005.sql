SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('MR9005','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('MR9005', 'Quy định giá trị CK vay tối đa cho tiểu khoản', 'Quy định giá trị CK vay tối đa cho tiểu khoản', 'select lm.afacctno,lm.autoid,sb.symbol, lm.codeid, lm.afmaxamt,
case when aft.istrfbuy <> ''Y'' then rsk.afmaxamt else rsk.afmaxamtt3 end sysafmaxamt,
nvl(alm.seqtty,0) seqtty, nvl(alm.seamt,0) seamt, lm.afmaxamt - nvl(alm.seamt,0) remainseamt
from afselimit lm,
v_getaccountseclimit alm,
securities_risk rsk, sbsecurities sb,
afmast af, aftype aft, mrtype mrt
where lm.afacctno = alm.afacctno (+) and lm.codeid = alm.codeid(+)
and lm.codeid = rsk.codeid and lm.codeid= sb.codeid
and lm.afacctno = af.acctno and af.actype = aft.actype and aft.mrtype = mrt.actype
and mrt.mrtype in (''S'',''T'')', 'AFSELIMIT', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;