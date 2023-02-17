SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DFMRGRP','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DFMRGRP', 'View danh sách tiểu khoản margin', 'DF Deal margin account', 'select cf.custodycd, cf.fullname, cf.idcode, af.acctno afacctno,
-(ci.balance - nvl(b.secureamt,0) - nvl(b.overamt,0) + nvl(adv.avladvance,0)) outstanding,
dft.actype dftype, df.dfamt
from cfmast cf, afmast af,cimast ci, aftype aft, mrtype mrt, afidtype afid, dftype dft,
v_getbuyorderinfo b,
(select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance group by afacctno) adv,
(select se.afacctno, dft.actype dftype,
    sum(case when dfbk.dealtype = ''N'' then (trade - nvl(execsellqtty,0) - nvl(od.remainsellqtty,0)) *
                (case when dfbk.DFPRICE <=0 then round((case when dfbk.REFPRICE<=0 then sb.BASICPRICE else least(dfbk.REFPRICE,sb.BASICPRICE) end)* dfbk.dfrate/100,0) else least(dfbk.DFPRICE,sb.BASICPRICE*dfbk.dfrate/100) end)
            when dfbk.dealtype = ''R'' then nvl(execbuyqtty,0) *
                (case when dfbk.DFPRICE <=0 then round((case when dfbk.REFPRICE<=0 then sb.BASICPRICE else least(dfbk.REFPRICE,sb.BASICPRICE) end)* dfbk.dfrate/100,0) else least(dfbk.DFPRICE,sb.BASICPRICE*dfbk.dfrate/100) end)
            when dfbk.dealtype = ''B'' then se.blocked *
                (case when dfbk.DFPRICE <=0 then round((case when dfbk.REFPRICE<=0 then sb.BASICPRICE else least(dfbk.REFPRICE,sb.BASICPRICE) end)* dfbk.dfrate/100,0) else least(dfbk.DFPRICE,sb.BASICPRICE*dfbk.dfrate/100) end)
        else 0 end) dfamt
from afmast af, afidtype afid, dftype dft, dfbasket dfbk, semast se, securities_info sb,
   (select afacctno, codeid,
        sum(case when duetype = ''SS'' then qtty - decode(status,''C'',qtty,aqtty) else 0 end) execsellqtty,
        sum(case when duetype = ''RS'' then qtty - decode(status,''C'',qtty,aqtty) else 0 end) execbuyqtty
   from stschd
   where duetype in (''SS'',''RS'')and deltd <> ''Y''
   group by afacctno, codeid) sts,
   (select afacctno, codeid,
       sum(remainqtty) remainsellqtty
       from odmast
       where exectype in (''NS'',''MS'')and deltd <> ''Y''
       group by afacctno, codeid) od
where se.afacctno = sts.afacctno (+) and se.codeid = sts.codeid (+)
and se.afacctno = od.afacctno (+) and se.codeid = od.codeid (+)
and af.acctno = se.afacctno
and af.actype = afid.aftype and afid.actype = dft.actype and afid.objname = ''DF.DFTYPE'' and dft.dfgroup = ''Y''
and dft.basketid = dfbk.basketid and dfbk.symbol = sb.symbol and sb.codeid = se.codeid
group by se.afacctno, dft.actype) df
where cf.custid = af.custid and af.acctno = ci.afacctno
and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = ''T''
and aft.actype = afid.aftype and dft.actype = afid.actype and afid.objname = ''DF.DFTYPE''
and dft.dfgroup = ''Y'' and af.corebank <> ''Y''
and af.acctno = b.afacctno (+) and af.acctno = adv.afacctno(+)
and dft.rrtype = ''B'' and dft.custbank = ''<$CUSTBANK>''
and af.acctno = df.afacctno and dft.actype = df.dftype
and (ci.balance - nvl(b.secureamt,0) - nvl(b.overamt,0) + nvl(adv.avladvance,0)) < 0
and dft.actype = ''<$DFTYPE>''
and 0=0', 'DFMAST', '', '', '2676', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;