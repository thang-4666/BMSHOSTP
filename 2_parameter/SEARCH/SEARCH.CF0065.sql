SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0065','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0065', 'Tra cứu trạng thái gửi SMS và Email', 'Tra cứu trạng thái gửi SMS và Email', 'SELECT E.EMAIL,E.STATUS STATUSE,E.DATASOURCE,E.AFACCTNO,E.RETRY_COUNT,E.LAST_RETRY_TIME,E.GATEWAY_TIME,TO_CHAR(SENTTIME,''DD/MM/YYYY hh24:mI'') SENTTIME,
 TO_CHAR(createtime,''DD/MM/YYYY hh24:mI'') createtime,
 to_char(createtime,''DD/MM/YYYY'')  txdate, templateid,t.subject,
 case when e.status = ''A'' then ''Chờ gửi'' when e.status = ''R'' then ''Từ chối'' when e.status = ''S'' then ''Đã gửi'' else ''Không gửi'' end status,
e.note,
 decode (t.type,''E'',''EMAIL'',''S'',''SMS'') TYPE,AUTOID
FROM (SELECT * FROM EMAILLOG UNION ALL SELECT * FROM EMAILLOGHIST ) E  inner join templates t on  e.templateid = t.code
 ', 'CF0065', 'frm', '', '0333', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', 'CUSTODYCD', 'N', '', '');COMMIT;