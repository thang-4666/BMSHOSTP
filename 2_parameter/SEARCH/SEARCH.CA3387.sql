SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3387','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3387', 'Thực cắt đăng ký quyền mua', 'Cut right to register buying', 'SELECT   CA.AUTOID,cf.custodycd , CF.FULLNAME, SUBSTR(CAMAST.CAMASTID,1,4) || ''.'' || SUBSTR(CAMAST.CAMASTID,5,6) || ''.'' || SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
CA.AFACCTNO,camast.codeid codeid_org, CAMAST.TOCODEID CODEID, A2.CDCONTENT CATYPE,  CA.BALANCE  BALANCE, (CA.qtty+ ca.sendqtty+ca.cutqtty - CA.TQTTY )  QTTY,
CA.NMQTTY,(CA.qtty+ ca.sendqtty+ca.cutqtty  - CA.TQTTY - CA.NMQTTY )  MQTTY,
(CA.qtty+ca.sendqtty+ca.cutqtty  - CA.TQTTY) * CAMAST.EXPRICE AMT , ( CASE WHEN CI.COREBANK =''Y'' THEN 0 ELSE 1 END) ISCOREBANK,
(CASE WHEN CI.COREBANK =''Yes'' THEN ''Y'' ELSE ''No'' END) COREBANK, SYM.SYMBOL, A1.CDCONTENT STATUS, CA.AFACCTNO||CAMAST.TOCODEID SEACCTNO, CA.AFACCTNO||CAMAST.OPTCODEID OPTSEACCTNO,SYM.PARVALUE PARVALUE,  CAMAST.REPORTDATE REPORTDATE, CAMAST.ACTIONDATE,CAMAST.EXPRICE,
(CASE WHEN SUBSTR(CF.custodycd,4,1) = ''F'' THEN to_char( ''Secondary-offer shares, ''||SYM.SYMBOL ||'', exdate on '' || to_char (camast.reportdate,''DD/MM/YYYY'')||'',
ratio '' ||camast.RIGHTOFFRATE ||'', quantity '' ||ca.pqtty ||'', price ''|| CAMAST.EXPRICE ||'', '' || cf.fullname) else to_char( ''Thực cắt tiền dkqm, ''||SYM.SYMBOL ||'', ngày ch?t '' ||
 to_char (camast.reportdate,''DD/MM/YYYY'')||'', tỉ lệ '' ||camast.RIGHTOFFRATE ||'', SL '' ||ca.pqtty ||'', giá ''|| CAMAST.EXPRICE ||'', '' || cf.fullname ) end ) description,
'''' POTXNUM, '''' POTXDATE, '''' GLACCTNO, ''002'' POTYPE, '''' BANKACC, '''' BANKNAME, '''' BANKACCNAME, '''' BENEFCUSTNAME, '''' BENEFACCT, '''' BENEFNAME,
SYM_ORG.symbol symbol_org, camast.isincode, CAMAST.DUEDATE
FROM  SBSECURITIES SYM, ALLCODE A1, CAMAST, CASCHD  CA, AFMAST AF , CFMAST CF , CIMAST CI, ALLCODE A2, SBSECURITIES SYM_ORG
WHERE AF.ACCTNO = CI.ACCTNO AND  A1.CDTYPE = ''CA'' AND A1.CDNAME = ''CASTATUS'' AND A1.CDVAL = CA.STATUS AND CAMAST.TOCODEID = SYM.CODEID AND CAMAST.catype=''014''
AND CAMAST.camastid  = CA.camastid AND CA.AFACCTNO = AF.ACCTNO AND CAMAST.catype =''014'' AND CAMAST.CATYPE = A2.CDVAL AND A2.CDTYPE = ''CA''
AND A2.CDNAME = ''CATYPE'' AND AF.CUSTID = CF.CUSTID AND CA.status IN(''M'',''O'') AND CA.status <>''Y'' AND CA.Deltd <> ''Y''
AND CA.balance > 0 AND (CA.qtty+ ca.sendqtty+ca.cutqtty- CA.TQTTY)  > 0
and SYM_ORG.codeid=camast.codeid
 AND AF.ACCTNO LIKE ''%<$AFACCTNO>%''', 'CAMAST', '', '', '3387', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;