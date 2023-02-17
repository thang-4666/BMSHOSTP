SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3343','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3343', 'Danh sách phân bổ tiền chờ thực hiện', 'Coporate action list detail', 'SELECT CA.AUTOID, CA.TRADE, CA.CAMASTID, CA.AFACCTNO,A0.CDCONTENT CATYPE, CA.CODEID, CA.EXCODEID,
CA.QTTY, (CA.AMT-CA.INTAMT)AMT, CA.AQTTY, CFMAST.ADDRESS ,
       CA.AAMT, SYM.SYMBOL, A1.CDCONTENT STATUS,CA.AFACCTNO || CA.CODEID  SEACCTNO,
       CA.AFACCTNO || (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END) EXSEACCTNO,
       SYM.PARVALUE PARVALUE, EXSYM.PARVALUE EXPARVALUE, CAMAST.REPORTDATE REPORTDATE, CAMAST.ACTIONDATE,
       CFMAST.FULLNAME, CFMAST.IDCODE, CFMAST.CUSTODYCD,CASE WHEN CI.COREBANK=''Y'' THEN 1 ELSE 0 END COREBANK,
       CASE WHEN CI.COREBANK=''Y'' THEN ''Yes'' ELSE ''No'' END ISCOREBANK
       ,decode(priceaccounting,0,exsym.parvalue,priceaccounting) priceaccounting, a0.cdval CATYPEVALUE,
       CA.INTAMT, camast.isincode
FROM CASCHD CA, SBSECURITIES SYM, SBSECURITIES EXSYM, ALLCODE A0, ALLCODE A1, CAMAST, AFMAST, CFMAST,CIMAST CI
WHERE A0.CDTYPE = ''CA'' AND A0.CDNAME = ''CATYPE'' AND A0.CDVAL = CAMAST.CATYPE
AND A1.CDTYPE = ''CA'' AND A1.CDNAME = ''CASTATUS'' AND A1.CDVAL = CA.STATUS
AND CA.CAMASTID = CAMAST.CAMASTID AND CAMAST.CODEID = SYM.CODEID
AND CA.DELTD =''N'' AND CA.STATUS <> ''C'' AND CA.ISCI =''N''
AND EXSYM.CODEID = (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END)
AND CA.AFACCTNO = AFMAST.ACCTNO AND CI.AFACCTNO=AFMAST.ACCTNO
AND AFMAST.CUSTID = CFMAST.CUSTID  AND CA.AMT>0', 'CAMAST', '', '', '3343', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;