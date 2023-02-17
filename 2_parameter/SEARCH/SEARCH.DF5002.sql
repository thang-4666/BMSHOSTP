SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF5002','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF5002', 'Trả nợ Deal dùng tiền phong tỏa và tiền CI', '', '
SELECT A.*, ROUND(A.CURAMT + A.INTM + A.FEEM) SUMAMT, LEAST (ROUND(A.CURAMT + A.INTM + A.FEEM),A.dfblockORG) dfblockamt,
    ROUND((ROUND(A.CURAMT + A.INTM + A.FEEM)) - LEAST (ROUND(A.CURAMT + A.INTM + A.FEEM),A.dfblockORG)) CIPAID
FROM (
    SELECT v.*, cf.custodycd, cf.fullname, cf.idcode, cf.ADDRESS , df.orgamt, df.rlsamt+df.dfamt dfpaidamt, 
         df.dfblockamt DFBLOCKORG, greatest(getavlciwithdraw (v.afacctno,''''),0) CIAVLWITHDRAW, LN.FEEINTOVDACR,

    CASE WHEN TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME=''CURRDATE''),''DD/MM/RRRR'') - TO_DATE(ln.RLSDATE,''DD/MM/RRRR'') >= ln.MINTERM THEN 0 ELSE
        ROUND( (v.CURAMT *   (LEAST(ln.Minterm, ln.PRINFRQ)* ln.RATE1 + GREATEST ( 0 , ln.MINTERM - ln.PRINFRQ) * ln.RATE2) ) /100/360,4) END INTM,
                        CASE WHEN TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME=''CURRDATE''),''DD/MM/RRRR'') - TO_DATE(ln.RLSDATE,''DD/MM/RRRR'') >= ln.MINTERM THEN 0 ELSE
    ROUND( (v.CURAMT *   (LEAST(ln.Minterm, ln.PRINFRQ)* ln.CFRATE1 + GREATEST ( 0 , ln.MINTERM - ln.PRINFRQ) * ln.CFRATE2) ) /100/360,4) END FEEM

    FROM v_getgrpdealformular v, afmast af, cfmast cf, dfgroup df,
       (
            SELECT LNM.ACCTNO, LEAST(LNM.MINTERM, TO_NUMBER( TO_DATE(LNS.OVERDUEDATE,''DD/MM/RRRR'') - TO_DATE(LNS.RLSDATE,''DD/MM/RRRR'')) )  MINTERM, LNS.RLSDATE,
                TO_DATE(lns.DUEDATE,''DD/MM/RRRR'') -  TO_DATE(lns.RLSDATE,''DD/MM/RRRR'') PRINFRQ,
                LNS.RATE1, LNS.RATE2, LNS.CFRATE1, LNS.CFRATE2, LNS.FEEINTOVDACR FROM
                LNMAST LNM, LNSCHD LNS WHERE LNM.ACCTNO=LNS.ACCTNO AND LNS.REFTYPE=''P''
        ) LN
    where af.custid=cf.custid and v.afacctno=af.acctno and v.groupid=df.groupid and v.lnacctno=ln.acctno
) A WHERE 0=0', 'DFGROUP', '', '', '2666', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;