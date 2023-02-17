SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI9006','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI9006', 'Tra cứu thông tin tài khoản thấu chi', 'Overdraft account information', 'SELECT CI.ACCTNO AFACCTNO,CF.FULLNAME,CF.MOBILESMS TRADEPHONE ,CI.BALANCE - NVL(v.ADVAMT,0) -NVL(v.SECUREAMT,0) BALANCE,CI.ODAMT,CI.ODINTACR,
greatest(CI.OAMT + nvl(T0.OAMT,0),0) TOAMT,
ABS(CASE WHEN CI.OAMT + nvl(T0.OAMT,0)> 0 THEN least(NVL(T0.OAMT,0),CI.OAMT + nvl(T0.OAMT,0)) ELSE greatest(NVL(T0.OAMT,0) - abs(CI.OAMT)-nvl(T0.OAMT,0),0) END) T0AMT,
ABS(CASE WHEN CI.OAMT  > 0 THEN least(NVL(T1.OAMT,0),CI.OAMT) ELSE 0 END) T1AMT,
ABS(CASE WHEN CI.OAMT > NVL(T1.OAMT,0) THEN least (nvl(T2.OAMT,0),CI.OAMT+nvl(T0.OAMT,0) - NVL(T0.OAMT,0) -NVL(T1.OAMT,0)) ELSE 0 END) T2AMT,
ABS(CASE WHEN CI.OAMT > NVL(T1.OAMT,0)+nvl(T2.OAMT,0) THEN least (NVL(T3.OAMT,0) ,CI.OAMT+nvl(T0.OAMT,0) - NVL(T0.OAMT,0) -NVL(T1.OAMT,0)-nvl(T2.OAMT,0)) ELSE 0 END) T3AMT,
ABS(CASE WHEN CI.OAMT > NVL(T1.OAMT,0)+nvl(T2.OAMT,0)+nvl(T3.OAMT,0) THEN CI.OAMT+nvl(T0.OAMT,0) - NVL(T0.OAMT,0) - NVL(T1.OAMT,0)- nvl(T2.OAMT,0)-nvl(T3.OAMT,0) ELSE 0 END) TTAMT,
greatest(CI.OAMT + nvl(TT0.OAMT,0),0) TTOAMT,
ABS(CASE WHEN CI.OAMT + nvl(TT0.OAMT,0)> 0 THEN least(NVL(TT0.OAMT,0),CI.OAMT + nvl(TT0.OAMT,0)) ELSE greatest(NVL(TT0.OAMT,0) - abs(CI.OAMT)-nvl(TT0.OAMT,0),0) END) TT0AMT
FROM CFMAST CF,AFMAST AF,
(SELECT BALANCE-NVL(V.SECUREAMT,0) BALANCE, ODAMT, ODINTACR,(ODAMT + ODINTACR-BALANCE+NVL(V.SECUREAMT,0)) OAMT,ACCTNO FROM CIMAST,V_GETBUYORDERINFO V WHERE CIMAST.ACCTNO =V.AFACCTNO (+) ) CI,
(SELECT NVL(SUM(execamt + 0.2/100 * execamt - execqtty * quoteprice * bratio/100),0) OAMT, AFACCTNO FROM ODMAST WHERE DELTD <> ''Y'' AND EXECTYPE IN (''NB'',''BC'') AND  execamt + feeacr - execqtty * quoteprice * bratio/100>0 AND TXDATE=to_date(''<$BUSDATE>'',''DD/MM/YYYY'') GROUP BY AFACCTNO) TT0,
(SELECT ROUND(NVL(SUM(quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + 0.2/100 * execamt - execqtty * quoteprice * bratio/100),0),4) OAMT, AFACCTNO FROM ODMAST WHERE DELTD <> ''Y'' AND EXECTYPE IN (''NB'',''BC'') AND  quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100>0 AND TXDATE=to_date(''<$BUSDATE>'',''DD/MM/YYYY'') GROUP BY AFACCTNO) T0,
(SELECT ROUND(NVL(SUM(quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100),0)* (1+ 14.5/100/360* (to_date(''<$BUSDATE>'',''DD/MM/YYYY'')-txdate)),4) OAMT, AFACCTNO FROM ODMAST WHERE DELTD <> ''Y'' AND EXECTYPE IN (''NB'',''BC'') AND quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100>0 AND GETDUEDATE(TXDATE,''B'',''000'',1)=to_date(''<$BUSDATE>'',''DD/MM/YYYY'') GROUP BY AFACCTNO,TXDATE) T1,
(SELECT ROUND(NVL(SUM(quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100),0) * (1+ 14.5/100/360* (to_date(''<$BUSDATE>'',''DD/MM/YYYY'')-txdate)),4) OAMT, AFACCTNO FROM ODMAST WHERE DELTD <> ''Y'' AND EXECTYPE IN (''NB'',''BC'') AND quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100>0 AND GETDUEDATE(TXDATE,''B'',''000'',2)=to_date(''<$BUSDATE>'',''DD/MM/YYYY'') GROUP BY AFACCTNO,TXDATE) T2,
(SELECT ROUND(NVL(SUM(quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100),0) * (1+ 14.5/100/360* (to_date(''<$BUSDATE>'',''DD/MM/YYYY'')-txdate)),4) OAMT, AFACCTNO FROM ODMAST WHERE DELTD <> ''Y'' AND EXECTYPE IN (''NB'',''BC'') AND quoteprice* remainqtty * (1+0.2/1000- bratio/100) + execamt + feeacr - execqtty * quoteprice * bratio/100>0 AND GETDUEDATE(TXDATE,''B'',''000'',3)=to_date(''<$BUSDATE>'',''DD/MM/YYYY'') GROUP BY AFACCTNO,TXDATE) T3,
 v_getbuyorderinfo v
WHERE
CF.CUSTID=AF.CUSTID AND AF.ACCTNO=CI.ACCTNO
AND AF.ACCTNO =TT0.AFACCTNO(+)
AND AF.ACCTNO =T0.AFACCTNO(+)
AND AF.ACCTNO =T1.AFACCTNO(+)
AND AF.ACCTNO =T2.AFACCTNO(+)
AND AF.ACCTNO =T3.AFACCTNO(+)
AND AF.ACCTNO =v.AFACCTNO(+)', 'CIMAST', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;