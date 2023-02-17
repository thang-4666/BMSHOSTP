SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI1109','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI1109', 'Tra cứu nguồn ứng trước tiền bán', 'Tra cứu nguồn ứng trước tiền bán', '
select cfl.bankid,cf.fullname, LMAMTMAX , case when cf.fullname =''VCBSAD'' then ''C'' ELSE ''BANK'' END RRTYPE, nvl(ad.amt,0)   limituse, LMAMTMAX-nvl(ad.amt,0) remain
from cflimit cfl, cfmast cf ,(SELECT NVL( custbank,''0001000019'') custbank,rrtype,sum(amt) amt  FROM ADSCHD WHERE STATUS <>''C'' group by custbank, rrtype )ad
where lmsubtype =''ADV''
and cfl.bankid = cf.custid
and cfl.bankid= ad.custbank(+)
AND CFL.bankid NOT IN (
SELECT DISTINCT AD.CUSTBANK  FROM AFTYPE AF,ADTYPE AD
WHERE AF.ADTYPE = AD.ACTYPE)
UNION ALL
select cfl.bankid,cf.fullname, LMAMTMAX , case when cf.fullname =''VCBSAD''then ''C'' ELSE ''BANK'' END RRTYPE, nvl(ad.amt,0)   limituse, LMAMTMAX-nvl(ad.amt,0) remain
from cflimit cfl, cfmast cf ,(SELECT sum(amt) amt  FROM ADSCHD WHERE STATUS <>''C''  )ad
where lmsubtype =''ADV''
and cfl.bankid = cf.custid
AND CFL.bankid  IN (
SELECT DISTINCT AD.CUSTBANK  FROM AFTYPE AF,ADTYPE AD
WHERE AF.ADTYPE = AD.ACTYPE)
 ', 'CFLINK', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;