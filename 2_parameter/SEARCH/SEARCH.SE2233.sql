SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2233','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2233', 'Yêu cầu giải tỏa cầm cố chứng khoán(2233)', 'Yêu cầu giải tỏa cầm cố chứng khoán (2233)', 'SELECT  autoid, SE.AFACCTNO afacctno, SE.ACCTNO acctno, CF.FULLNAME CUSTNAME, CF.CUSTODYCD, SB.SYMBOL,
    SB.PARVALUE, mt.qtty qtty, SB.CODEID, CF.ADDRESS,mt.MDATE,mt.CRFULLNAME,mt.NUM_MG
from (
    select se.autoid, se.acctno, se.afacctno, se.released - nvl(b.qtty,0) qtty,se.MDATE,se.CRFULLNAME,se.NUM_MG
    from semortage se
    left join
    (    select acctno, afacctno, refid,sum(CASE WHEN sendqtty - released <> 0 THEN sendqtty + released else qtty END) qtty from semortage se where se.qtty > 0 and tltxcd = ''2233''  and deltd = ''N''
      group by acctno, afacctno, refid
    ) b on se.autoid = b.refid and se.acctno = b.acctno and se.afacctno = b.afacctno
    where se.tltxcd = ''2232''  and se.status IN (''C'',''E'') AND se.released >0
)mt, semast se, sbsecurities sb, afmast af, cfmast cf
where mt.acctno = se.acctno and se.mortage > 0 and se.codeid = sb.codeid
and se.afacctno = af.acctno and af.custid = cf.custid and mt.qtty > 0 ', 'SEMAST', '', '', '2233', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;