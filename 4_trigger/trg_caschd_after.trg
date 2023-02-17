SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CASCHD_AFTER 
 AFTER
  UPDATE
 ON caschd
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
declare
  l_custodycd       varchar2(10);
  l_smsmobile       varchar2(10);
  l_templateid      varchar2(6);
  l_datasource      varchar2(1000);
  l_symbol          varchar2(20);
  l_to_codeid       varchar2(10);
  l_to_symbol       varchar2(20);
  l_catype          varchar2(3);
  l_catype_desc     varchar2(100);
  l_report_date     varchar2(10);
  l_trade_date      varchar2(10);
  l_rate            varchar2(5);
  l_devident_shares varchar2(5);
  l_floor_code      varchar2(10);
  l_right_off_rate  varchar2(10);
  l_devident_rate   varchar2(10);
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

  pkgctx := plog.init('TRG_CASCHD_AFTER',
                      plevel            => nvl(logrow.loglevel, 30),
                      plogtable         => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert            => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace            => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_CASCHD_AFTER');

  if :new.status = 'H' then

    select c.catype, c.devidentshares, c.rightoffrate, c.reportdate,
           c.tradedate, c.tocodeid
      into l_catype, l_devident_shares, l_right_off_rate, l_report_date,
           l_trade_date, l_to_codeid
      from camast c
     where camastid = :old.camastid;

    --plog.error(pkgctx, 'CATYPE: ' || l_catype);

    -- CATYPE : 011, 014
    if l_catype in ('011', '014', '020') then
      select symbol
        into l_symbol
        from sbsecurities
       where codeid = :new.codeid;

      if l_catype = '011' then
        l_catype_desc := 'Co phieu phat hanh them';
        l_rate        := l_devident_shares;
        l_templateid  := '325C';
      elsif l_catype = '014' then
        l_catype_desc := 'Co tuc bang co phieu';
        l_rate        := l_right_off_rate;
        l_templateid  := '325C';
      elsif l_catype = '020' then
        l_catype_desc := '';
        l_rate        := l_right_off_rate;
        l_templateid  := '325D';

        select symbol
          into l_to_symbol
          from sbsecurities
         where codeid = l_to_codeid;
      else
        l_templateid := '';
      end if;

      -- Thong tin khach hang
      select c.custodycd, c.mobilesms
        into l_custodycd, l_smsmobile
        from cfmast c, afmast a
       where c.custid = a.custid
         and a.acctno = :old.afacctno;

      if l_smsmobile is not null and length(l_smsmobile) > 0 and
         length(l_templateid) > 0 then

        if l_templateid = '325C' then

          l_datasource := 'select ''' || l_custodycd ||
                          ''' custodycode, ''' ||
                          to_char(getcurrdate, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_symbol || ''' symbol, ''' ||
                          l_catype_desc || ''' catype, ''' || :old.qtty ||
                          ''' quantity,''' || l_report_date ||
                          ''' reportdate, ''' || l_rate || ''' rate, ''' ||
                          l_trade_date || ''' tradedate from dual';
        elsif l_templateid = '325D' then
          l_datasource := 'select ''' || l_custodycd ||
                          ''' custodycode, ''' ||
                          to_char(getcurrdate, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_symbol ||
                          ''' fromsymbol, ''' || :old.qtty ||
                          ''' quantity,''' || l_to_symbol ||
                          ''' tosymbol from dual';
        end if;

        insert into emaillog
          (autoid, email, templateid, datasource, status, createtime)
        values
          (seq_emaillog.nextval, l_smsmobile, l_templateid, l_datasource,
           'A', sysdate);

      end if;

    end if;

  end if;

  plog.setEndSection(pkgctx, 'TRG_CASCHD_AFTER');
exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_CASCHD_AFTER');

end TRG_CASCHD_AFTER;
/
