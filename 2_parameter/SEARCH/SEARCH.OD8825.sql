SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD8825','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD8825', 'Thanh toán lệnh mua OTC (8825)', 'OTC buy settlement(wait for 8825)', 'select * from (select od.orderid, max(sts.afacctno) afacctno,max(sb.symbol) symbol,max(od.SEACCTNO) SEACCTNO ,sum(sts.AMT) AMT, sum(sts.QTTY) QTTY,max(od.feeacr-od.feeamt) feeamt, 0 vat ,max(sb.parvalue) parvalue
from odmast od, stschd sts , sbsecurities sb
where od.orderid=sts.orgorderid  and od.codeid=sb.codeid and sb.tradeplace=''003''
and sts.duetype=''SM'' and sts.deltd <>''Y'' and sts.status =''N''
and od.deltd <>''Y''
group by orderid) where 0=0', 'ODMAST', '', '', '8825', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;