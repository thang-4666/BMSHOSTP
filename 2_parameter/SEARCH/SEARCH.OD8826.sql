SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD8826','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD8826', 'Thanh toán lệnh bán OTC (8826)', 'OTC sell settlement(wait for 8826)', 'select * from (select od.orderid,max(se.costprice) costprice,
(case when sum(sts.AMT) > sum(sts.QTTY) * max(se.costprice) then sum(sts.AMT) - sum(sts.QTTY) * max(se.costprice) else 0 end ) PROFITAMT,
(case when sum(sts.AMT) < sum(sts.QTTY) * max(se.costprice) then sum(sts.QTTY) * max(se.costprice) - sum(sts.AMT) else 0 end ) lossamt,
max(sts.afacctno) afacctno,
max(sb.symbol) symbol,max(od.SEACCTNO) SEACCTNO ,sum(sts.AMT) AMT, sum(sts.QTTY) QTTY,
max(od.feeacr-od.feeamt) feeamt, 0 vat ,max(sb.parvalue) parvalue
from odmast od, stschd sts , sbsecurities sb, semast se
where od.orderid=sts.orgorderid  and od.codeid=sb.codeid and sb.tradeplace=''003''
and sts.duetype=''SS'' and sts.deltd <>''Y'' and sts.status =''N''
and od.deltd <>''Y'' and od.seacctno =se.acctno
group by orderid) where 0=0 ', 'ODMAST', '', '', '8826', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;