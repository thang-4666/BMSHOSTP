SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2267','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2267', 'Chuyển chứng khoán chờ giao dịch thành giao dịch (Giao dịch 2267)', 'View account transfer to other account(wait for 2267)', 'select (SB.refcodeid ) codeid  , sum(trade) trade , sum(mortage) mortage , sum(blocked) blocked , sum(emkqtty) emkqtty
    ,sum(standing*(-1)) standing,sum(withdraw) withdraw, sum(deposit) deposit,sum(senddeposit)  senddeposit
    ,sum(dtoclose) dtoclose, sum(blockwithdraw)  blockwithdraw,
     sum(blockdtoclose) blockdtoclose, max(sb.PARVALUE) PARVALUE, max(seif.BASICPRICE) PRICE
from semast se, sbsecurities sb,securities_info seif
where se.codeid = sb.codeid
and sb.codeid = seif.codeid
and sb.refcodeid is not null
group by SB.refcodeid  ', 'SEMAST', 'frmSEMAST', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;