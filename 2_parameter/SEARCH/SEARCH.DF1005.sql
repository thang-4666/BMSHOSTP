SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF1005','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF1005', 'View theo dõi trạng thái vay quá hạn', 'Status of Overdue DF Deals', '
select * from
(SELECT v.*,ln.overduedate, nvl(NML,0) DUEAMT,CD.CDCONTENT DEALSTATUS,CD1.CDCONTENT DEALFLAGTRIGGER,
        esl.txdate emaildate, esl.txtime emailtime, nvl(esl.smscount,0) smscount , nvl(esl.emailcount,0) emailcount,
        TO_DATE((select varvalue from sysvar where grname =''SYSTEM'' and varname =''CURRDATE''),''DD/MM/YYYY'') - ln.overduedate COUNTDUEDATE,
        tlpr.tlname, brg.brname, v.triggerdate newtriggerdate,
         A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS
        FROM v_getdealinfo v,ALLCODE CD,ALLCODE CD1, TLPROFILES TLPR, BRGRP BRG,
    (select DISTINCT acctno, overduedate  from (select acctno, overduedate from lnschd union all select acctno, overduedate from lnschdhist) )ln,
(SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
        WHERE S.OVERDUEDATE = TO_DATE((select varvalue from sysvar where grname =''SYSTEM'' and varname =''CURRDATE''),''DD/MM/YYYY'') AND S.NML > 0 AND S.REFTYPE IN (''P'')
            AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN (''P'',''R'',''C'')
        GROUP BY S.ACCTNO, M.TRFACCTNO
        ORDER BY S.ACCTNO) sts, (select * from emailsmslog where reportname = ''DF1005'') esl,
          ALLCODE A1, ALLCODE A2, ALLCODE A3
where CD1.cdname = ''FLAGTRIGGER'' and CD1.cdtype =''DF'' AND CD1.CDVAL = v.FLAGTRIGGER
and A1.cdname = ''YESNO'' and A1.cdtype =''SY'' AND A1.CDVAL = v.PREPAID
      and A2.cdname = ''INTPAIDMETHOD'' and A2.cdtype =''LN'' AND A2.CDVAL = v.INTPAIDMETHOD
       and A3.cdname = ''AUTOAPPLY'' and a3.cdtype =''LN'' AND A3.CDVAL = v.AUTOAPPLY
      and CD.cdname = ''DEALSTATUS'' and CD.cdtype =''DF'' AND CD.CDVAL = v.STATUS
      and v.lnacctno = sts.acctno (+)
      and v.lnacctno = ln.acctno
      and v.ACCTNO = esl.acctno (+)
      and v.tlid = tlpr.tlid
      and tlpr.brid = brg.brid
) WHERE prinovd + oprinovd>0
', 'DFMAST', '', 'ACCTNO DESC', 'EXEC', NULL, 50, 'N', 30, 'NYNNYYYYYN', 'Y', 'T', '', 'N', '', '');COMMIT;