SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SA9901','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SA9901', 'Tra cứu thay đổi thông tin', 'Audit logs', 'select e.cdcontent table_name,
       rtrim(substr(record_key, 1, instrc(record_key, '' = '', 1, 1))) table_pk,
       replace(substr(record_key, instrc(record_key, ''='', 1, 1) + 2), '''''''') key_value,
       b.tlname maker, maker_dt, d.cdcontent action_flag
       , c.tlname approver, approve_dt, mod_num, column_name,
       from_value, to_value
  from maintain_log a, tlprofiles b, tlprofiles c, (select * from allcode where cdtype =''SA'' and cdname=''ACTION_FLAG'') d,
       (select *
           from allcode
          where cdtype = ''SA''
            and cdname = ''TABLE_NAME'') e
 where a.maker_id = b.tlid and a.approve_id = c.tlid and a.action_flag = d.cdval and a.table_name = e.cdval
 order by table_name, maker_dt, mod_num, column_name', 'MAINTAIN_LOG', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;