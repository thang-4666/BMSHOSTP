SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0045','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0045', 'Tra cứu trạng thái tiền', 'View cash statement', 'SELECT cf.custodycd,  ci.acctno, cf.fullname, af.actype, ci.balance - NVL(v.ADVAMT,0)- NVL(v.SECUREAMT,0) balance, ci.odamt,
       NVL (c.aamt, 0) receiving, NVL (b.execamt, 0) execamt,
       NVL(v.ADVAMT,0) + NVL(v.SECUREAMT,0) securedamt, NVL (b.matchedamt, 0) matchedamt
  FROM cimast ci,
       afmast af,
       cfmast cf,
       (SELECT   af.acctno,
                 SUM (CASE
                         WHEN od.exectype IN (''NS'', ''SS'')
                            THEN execamt
                         ELSE 0
                      END
                     ) execamt,
                 SUM (CASE
                         WHEN od.exectype IN (''NB'', ''BC'')
                            THEN securedamt - rlssecured
                         ELSE 0
                      END
                     ) securedamt,
                 SUM (CASE
                         WHEN od.exectype IN (''NB'', ''BC'')
                            THEN execamt
                         ELSE 0
                      END
                     ) matchedamt
            FROM odmast od, afmast af, odtype typ, sysvar SYS
           WHERE SYS.varname = ''CURRDATE''
             AND SYS.grname = ''SYSTEM''
             AND od.actype = typ.actype
             AND af.acctno = od.afacctno
             AND od.txdate = TO_DATE (SYS.varvalue, ''DD/MM/YYYY'')
             AND deltd <> ''Y''
        GROUP BY af.acctno) b,
       (SELECT   afacctno acctno,
                 SUM (amt - aamt - famt + paidamt + paidfeeamt) aamt
            FROM stschd
           WHERE duetype = ''RM'' AND status = ''N'' AND deltd <> ''Y''
        GROUP BY afacctno) c,
        v_getbuyorderinfo v
 WHERE af.acctno = ci.acctno
   AND af.custid = cf.custid
   AND ci.acctno = b.acctno(+)
   AND ci.acctno = c.acctno(+)
   and ci.acctno = v.AFACCTNO(+)', 'CFMAST', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;