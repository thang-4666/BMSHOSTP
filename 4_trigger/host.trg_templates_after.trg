SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TEMPLATES_AFTER 
 AFTER
  INSERT OR DELETE OR UPDATE
 ON templates
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
declare

  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
  -- local variables here
  l_template_id      templates.code%type;
  l_is_new_scheduler boolean := false;
  l_scheduler_status templates_scheduler.status%type;
  l_last_start_date  timestamp;
  l_next_run_date    timestamp;
  l_create_date      timestamp;
  c_datetime_format  varchar2(21) := 'DD/MM/RRRR HH24:MI:SS';
  c_date_format      varchar2(10) := 'DD/MM/RRRR';

  not_a_valid_date exception;
  pragma exception_init(not_a_valid_date, -1847);
begin

  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('TRG_TEMPLATES_AFTER',
                      plevel               => nvl(logrow.loglevel, 30),
                      plogtable            => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert               => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace               => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_TEMPLATES_AFTER');
  IF updating THEN
        IF :new.Isdefault <> :old.Isdefault THEN
           IF :new.require_register = 'Y' AND :new.isdefault = 'Y'  THEN
                    INSERT INTO aftemplates (autoid,custid,template_code)
                    SELECT seq_aftemplates.nextval,custid, :new.Code FROM cfmast
                    WHERE custid NOT IN (SELECT custid FROM aftemplates WHERE template_code = :new.code);
            ELSIF /*:new.require_register = 'Y' AND*/ :new.Isdefault = 'N' THEN
                  DELETE FROM aftemplates WHERE template_code = :new.code;
            END IF;
        END IF;
        ------truong hop chuyen trang thai tu co phai dang ky ve khong phai dang ky, tu dong xoa aftemplates
        IF :new.require_register <> :old.require_register THEN
            IF :new.isdefault ='Y' AND :new.require_register = 'N' THEN
                 DELETE FROM aftemplates WHERE template_code = :new.code;
         ELSIF   :new.isdefault = 'Y' AND :new.require_register = 'Y' THEN
                INSERT INTO aftemplates (autoid,custid,template_code)
                        SELECT seq_aftemplates.nextval,custid, :new.Code FROM cfmast
                        WHERE custid NOT IN (SELECT custid FROM aftemplates WHERE template_code = :new.code);
            END IF;
        END IF;
    END IF;

  if inserting then
    if :new.code <> '0338' then --mau khop lenh cuoi ngay khong dung scheduler
        if :new.cycle = 'M' then
            insert into templates_scheduler
            (template_id, create_date, next_run_date, repeat_interval, status)
            values
            (:new.code, sysdate, fn_get_nextdate(last_day(getcurrdate), 1) , :new.cycle, 'A');
        elsif :new.cycle = 'Y' then
            insert into templates_scheduler
            (template_id, create_date, next_run_date, repeat_interval, status)
            values
            (:new.code, sysdate, fn_get_nextdate(ADD_MONTHS(TRUNC (SYSDATE ,'YEAR'),12)-1,1), :new.cycle, 'A');
        elsif :new.cycle = 'D' then
            insert into templates_scheduler
            (template_id, create_date, next_run_date, repeat_interval, status)
            values
            (:new.code, sysdate, fn_get_nextdate(getcurrdate , 1), :new.cycle, 'A');
        end if;
    end if;

  end if;
  ---end

  if deleting then
    delete templates_scheduler
     where templates_scheduler.template_id = :old.code;
  end if;

  if :new.cycle <> :old.cycle or :new.cycle_day <> :old.cycle_day or :new.cycle_time <> :old.cycle_time then

    begin
      select template_id, status, last_start_date, create_date
        into l_template_id,
             l_scheduler_status,
             l_last_start_date,
             l_create_date
        from templates_scheduler
       where template_id = :new.code;

    exception
      when NO_DATA_FOUND then
        l_is_new_scheduler := true;
    end;

    if :new.cycle = 'P' then
      update templates_scheduler
         set status = 'D', repeat_interval = 'P'
       where template_id = l_template_id;

      return;
    end if;

    if l_is_new_scheduler then

      if :new.cycle = 'D' then
        l_next_run_date := to_date(sysdate + 1, c_date_format);
        /*          update templates_scheduler
          set repeat_interval = :new.cycle,
              next_run_date   = last_start_date + 1
        where template_id = l_template_id;*/
      elsif :new.cycle = 'M' then
        begin
          l_next_run_date := to_date(:new.cycle_day ||
                                     to_char(add_months(sysdate, 1),
                                             '/MM/RRRR'),
                                     c_date_format);
        exception
          when not_a_valid_date then
            l_next_run_date := LAST_DAY(to_date('01' ||
                                       to_char(add_months(sysdate, 1),
                                               '/MM/RRRR'),
                                       'DD/MM/RRRR'));
        end;
        /*          update templates_scheduler
          set repeat_interval = :new.cycle,
              next_run_date   = add_months(last_start_date, 1)
        where template_id = l_template_id;*/
      elsif :new.cycle = 'Y' then
        l_next_run_date := to_date(add_months(sysdate, 12), c_date_format);
        /*          update templates_scheduler
          set repeat_interval = :new.cycle,
              next_run_date   =  add_months(last_start_date, 12)
        where template_id = l_template_id;*/
      end if;

      insert into templates_scheduler
        (template_id, create_date, next_run_date, repeat_interval, status)
      values
        (:new.code,
         sysdate,
         to_date(to_char(l_next_run_date, 'DD/MM/RRRR') || :new.cycle_time,
                 c_datetime_format),
         :new.cycle,
         'A');
    else

      if l_scheduler_status = 'R' then
        update templates_scheduler
           set repeat_interval = :new.cycle
         where template_id = l_template_id;
      else

        if l_last_start_date is null then
          l_last_start_date := l_create_date;
        end if;

        if :new.cycle = 'D' then
          l_next_run_date := l_last_start_date + 1;
          /*          update templates_scheduler
            set repeat_interval = :new.cycle,
                next_run_date   = last_start_date + 1
          where template_id = l_template_id;*/
        elsif :new.cycle = 'M' then

          --l_next_run_date := add_months(l_last_start_date, 1);
          begin
            l_next_run_date := to_date(:new.cycle_day ||
                                       to_char(add_months(l_last_start_date,
                                                          1),
                                               '/MM/RRRR'),
                                       c_date_format);
          exception
            when not_a_valid_date then
              l_next_run_date := LAST_DAY(to_date('01' ||
                                         to_char(add_months(l_last_start_date,
                                                            1),
                                                 '/MM/RRRR'),
                                         'DD/MM/RRRR'));
          end;
          /*          update templates_scheduler
            set repeat_interval = :new.cycle,
                next_run_date   = add_months(last_start_date, 1)
          where template_id = l_template_id;*/
        elsif :new.cycle = 'Y' then
          l_next_run_date := add_months(l_last_start_date, 12);
          /*          update templates_scheduler
            set repeat_interval = :new.cycle,
                next_run_date   =  add_months(last_start_date, 12)
          where template_id = l_template_id;*/
        end if;

        plog.debug(pkgctx,
                   'next_run_date: ' || l_next_run_date ||
                   ' next_run_time: ' || :new.cycle_time);

        update templates_scheduler
           set repeat_interval = :new.cycle,
               next_run_date   = to_date(to_char(l_next_run_date,
                                                 'DD/MM/RRRR') ||
                                         :new.cycle_time,
                                         c_datetime_format),
               status          = 'A'
         where template_id = l_template_id;

      end if;

    end if;

  end if;
  plog.setEndSection(pkgctx, 'TRG_TEMPLATES_AFTER');
exception
  when others then
    plog.setEndSection(pkgctx, 'TRG_TEMPLATES_AFTER');
    plog.error(pkgctx, sqlerrm || dbms_utility.format_error_stack);
end TRG_TEMPLATES_AFTER;
/
