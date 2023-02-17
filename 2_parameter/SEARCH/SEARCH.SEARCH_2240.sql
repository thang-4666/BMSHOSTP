SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SEARCH_2240','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SEARCH_2240', 'Các giao dịch 2240 chưa thực hiện 2246', 'Cac giao dich 2240 ch? thuc hien 2246', 'Select   sed.txnum , sed.txdate
,se.custodycd,Se.afacctno,cf.fullname,se.txdesc,
se.symbol,sed.depotrade,sed.depoblock , tl.tlname
 from cfmast cf ,afmast af,
 (Select
custodycd,afacctno,txdesc,symbol,acctno,txdate,txnum,tlid
,custid from setran_gen where tltxcd=''2240''
  Union
  Select custodycd,Substr(msgacct,0,10)
afacctno,txdesc,symbol,msgacct
acctno,txdate,txnum,tl.tlid,cf.custid
  from tllog tl,afmast af , cfmast cf , sbsecurities sb
  where tltxcd=''2240'' and af.custid = cf.custid and
Substr(msgacct,0,10) = af.acctno and sb.codeid=Substr
(msgacct,11,6)
 ) se,tlprofiles tl,
 (SELECT *  FROM SEDEPOSIT  WHERE STATUS = ''D'' AND DELTD
<> ''Y'')SED
            WHERE se.acctno=sed.acctno
            and se.txdate= sed.txdate
             and se.txnum= sed.txnum
             and cf.custid = se.custid
             and se.tlid = tl.tlid
             and af.custid = cf.custid
             AND (SUBSTR(CF.CUSTID,1,4) = DECODE(''<
$BRID>'', ''<$HO_BRID>'', SUBSTR(CF.CUSTID,1,4), ''<$BRID>'')
             OR AF.CAREBY IN (SELECT TLGRP.GRPID FROM
TLGRPUSERS TLGRP WHERE TLID = ''<$TELLERID>''))', 'SEARCH_2240', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;