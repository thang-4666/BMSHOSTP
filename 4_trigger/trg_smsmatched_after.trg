SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_SMSMATCHED_AFTER 
 AFTER
  INSERT
 ON smsmatched
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
  -- local variables here
/*  l_datasource varchar2(4000);
  l_smsmobile  varchar2(4000);
  l_custodycd  varchar2(10);
  l_account    varchar2(10);
  l_fullname   varchar2(50);*/
  -- l_message    varchar2(300);
  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
begin

  -- Initialization
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('fopks_api',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_SMSMATCHED_AFTER');

  --l_message := 'BVSC thong bao KQKL TK [custodycode] ngay [txdate]: [detail]';

    insert into log_notify_event
      (autoid, msgtype, keyvalue, status, CommandType, CommandText, logtime)
    values
      (seq_log_notify_event.nextval, 'ODMATCHED', :newval.afacctno, 'A', 'P', 'GENERATE_TEMPLATES', sysdate);

/*  select c.custodycd, a.acctno, c.fullname, a.fax1
    into l_custodycd, l_account, l_fullname, l_smsmobile
    from cfmast c, afmast a
   where c.custid = a.custid
     and c.custodycd = :newval.custodycd
     and a.acctno = :newval.afacctno;

  l_datasource := 'SELECT MAX(AUTOID) AUTOID, CUSTODYCD CUSTODYCODE, TO_CHAR(TXDATE, ''DD/MM/RRRR'') TXDATE,
       HEADER || LISTAGG(DETAIL, '','') WITHIN GROUP(ORDER BY DETAIL) || '', '' || MAX(FOOTER) AS DETAIL
  FROM (SELECT A.*, ROWNUM TOP
           FROM (SELECT MAX(AUTOID) AUTOID, TXDATE, CUSTODYCD, HEADER, MAX(FOOTER) FOOTER, ''KL '' || SUM(QUANTITY) || '' GIA '' || PRICE AS DETAIL
           FROM SMSMATCHED
          WHERE STATUS = ''N''
            AND CUSTODYCD = ''' || :newval.custodycd || '''
            GROUP BY TXDATE, CUSTODYCD, HEADER, PRICE ORDER BY AUTOID) A)
 WHERE TOP < 3
 GROUP BY CUSTODYCD, TXDATE, HEADER;';

  plog.debug(pkgctx, l_datasource);
  if l_smsmobile is not null and length(l_smsmobile) > 0 then
    insert into emaillog
      (autoid, email, templateid, datasource, status, createtime)
    values
      (seq_emaillog.nextval, l_smsmobile, '0323', l_datasource, 'A', sysdate);
  end if;*/
  plog.setEndSection(pkgctx, 'TRG_SMSMATCHED_AFTER');
exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_SMSMATCHED_AFTER');
end TRG_OTRIGHT_AFTER;
/
