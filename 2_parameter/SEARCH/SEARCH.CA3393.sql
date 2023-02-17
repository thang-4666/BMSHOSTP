SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3393','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3393', 'Hủy đăng ký mua CP phát hành thêm (không phong tỏa tiền)', 'Hủy đăng ký mua CP phát hành thêm (không phong tỏa tiền)', 'SELECT   SUBSTR(CAMAST.CAMASTID,1,4) || ''.'' ||
SUBSTR(CAMAST.CAMASTID,5,6) || ''.'' ||
SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
 CA.AFACCTNO, CAMAST.CODEID,CF.CUSTODYCD , A2.CDCONTENT
CATYPE, CA.PBALANCE ,  CA.BALANCE, CA.nmqtty  QTTY,
CA.nmqtty  MAXQTTY ,CA.aamt aamt , ( CASE WHEN CI.COREBANK
=''Y'' THEN 0 ELSE 1 END) ISCOREBANK, ( CASE WHEN
CI.COREBANK =''Yes'' THEN ''Y'' ELSE ''No'' END) COREBANK,
 SYM.SYMBOL, A1.CDCONTENT STATUS,CA.AFACCTNO||CA.CODEID
 SEACCTNO, CA.AFACCTNO||CAMAST.OPTCODEID
OPTSEACCTNO,SYM.PARVALUE PARVALUE,  CAMAST.REPORTDATE
REPORTDATE, CAMAST.ACTIONDATE,CAMAST.EXPRICE,
(CASE WHEN SUBSTR(CF.custodycd,4,1) = ''F'' THEN to_char(
''Secondary-offer shares, ''||SYM.SYMBOL ||'', exdate on ''
|| to_char (camast.reportdate,''DD/MM/YYYY'')||'',
ratio '' ||camast.RIGHTOFFRATE ||'', quantity '' ||ca.pqtty
||'', price ''|| CAMAST.EXPRICE ||'', '' || cf.fullname)
else to_char( ''Đăng ký quyền mua, ''||SYM.SYMBOL ||'',
ngày chốt '' ||
 to_char (camast.reportdate,''DD/MM/YYYY'')||'', tỉ lệ ''
||camast.RIGHTOFFRATE ||'', SL '' ||ca.pqtty ||'', giá ''||
CAMAST.EXPRICE ||'', '' || cf.fullname ) end )
description,  ISS.fullname, camast.isincode FROM  SBSECURITIES SYM,
ALLCODE A1,
 CAMAST, CASCHD  CA, AFMAST AF , CFMAST CF , CIMAST CI,
ISSUERS ISS, ALLCODE A2 WHERE AF.ACCTNO = CI.ACCTNO AND
A1.CDTYPE = ''CA'' AND A1.CDNAME = ''CASTATUS'' AND A1.CDVAL
= CA.STATUS AND CAMAST.CODEID = SYM.CODEID AND
CAMAST.catype=''014''
AND CAMAST.camastid  = CA.camastid AND CA.AFACCTNO =
AF.ACCTNO AND ISS.issuerid = sym.issuerid
AND CAMAST.CATYPE = A2.CDVAL AND A2.CDTYPE = ''CA'' AND
A2.CDNAME = ''CATYPE''
AND AF.CUSTID = CF.CUSTID AND CA.status IN( ''M'',''A'',''S'')
AND CA.status <>''Y'' AND CA.balance > 0 AND nvl(ca.nmqtty,0)> 0  AND AF.ACCTNO
LIKE ''%<$AFACCTNO>%''', 'CAMAST', '', '', '3393', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;