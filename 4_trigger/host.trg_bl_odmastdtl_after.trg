SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_BL_ODMASTDTL_AFTER 
 AFTER
  INSERT OR UPDATE
 ON bl_odmastdtl
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    v_hostatus varchar2(10);
    v_errmsg varchar2(2000);
    pkgctx plog.log_ctx;
    logrow tlogdebug%rowtype;

BEGIN
    -- Initialization
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('TRG_BL_ODMASTDTL_AFTER',
                      plevel         => nvl(logrow.loglevel, 30),
                      plogtable      => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert         => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace         => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_BL_ODMASTDTL_AFTER');

    SELECT      VARVALUE
    INTO        V_HOSTATUS
    FROM        SYSVAR
    WHERE       VARNAME = 'HOSTATUS';

    IF V_HOSTATUS = '1' THEN

        -- Them vao xu ly cho lenh Bloomberg
        -- Cac lenh gian tiep, any thi tra ve confirm cho Bloomberg
        -- TheNN, 30-Sep-2013
        IF INSERTING AND :newval.Via = 'L' and :newval.status in ('N') AND :newval.exectype in ('CB','CS') Then
            pck_blg.Prc_Event('BLCANCEL_PD',:newval.blorderid,:newval.blorderid,'');

        End if;
        -- Ket thuc: Them vao xu ly cho lenh Bloomberg

    END IF;
EXCEPTION
WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_BL_ODMASTDTL_AFTER');
END;
/
