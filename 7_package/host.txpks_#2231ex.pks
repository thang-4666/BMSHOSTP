SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2231ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2231EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/05/2015     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
 is
  function fn_txpreappcheck(p_txmsg in tx.msg_rectype,
                            p_err_code out varchar2) return number;
  function fn_txaftappcheck(p_txmsg in tx.msg_rectype,
                            p_err_code out varchar2) return number;
  function fn_txpreappupdate(p_txmsg in tx.msg_rectype,
                             p_err_code out varchar2) return number;
  function fn_txaftappupdate(p_txmsg in tx.msg_rectype,
                             p_err_code out varchar2) return number;
end;
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#2231ex is
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  c_autoid    constant char(2) := '05';
  c_codeid    constant char(2) := '01';
  c_afacctno  constant char(2) := '02';
  c_acctno    constant char(2) := '03';
  c_custname  constant char(2) := '90';
  c_address   constant char(2) := '91';
  c_license   constant char(2) := '92';
  c_parvalue  constant char(2) := '11';
  c_price     constant char(2) := '09';
  c_qtty      constant char(2) := '10';
  c_depotrade constant char(2) := '06';
  c_depoblock constant char(2) := '04';
  c_qttytype  constant char(2) := '08';
  c_pdate     constant char(2) := '07';
  c_desc      constant char(2) := '30';
  function fn_txpreappcheck(p_txmsg in tx.msg_rectype,
                            p_err_code out varchar2) return number is
    l_count number;

  begin
    plog.setbeginsection(pkgctx, 'fn_txPreAppCheck');
    plog.debug(pkgctx, 'BEGIN OF fn_txPreAppCheck');
    /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/

    --check k thuc hien 1 gd 2 lan
    SELECT COUNT(1) into L_COUNT FROM SEDEPOSIT WHERE STATUS='D' AND AUTOID = P_TXMSG.TXFIELDS('05').VALUE;
    if L_COUNT > 0 then
        p_err_code := '-100778'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    plog.debug(pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection(pkgctx, 'fn_txPreAppCheck');
    return systemnums.c_success;
  exception
    when others then
      p_err_code := errnums.c_system_error;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_txPreAppCheck');
      raise errnums.e_system_error;
  end fn_txpreappcheck;

  function fn_txaftappcheck(p_txmsg in tx.msg_rectype,
                            p_err_code out varchar2) return number is
  begin
    plog.setbeginsection(pkgctx, 'fn_txAftAppCheck');
    plog.debug(pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');
    /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
    plog.debug(pkgctx, '<<END OF fn_txAftAppCheck>>');
    plog.setendsection(pkgctx, 'fn_txAftAppCheck');
    return systemnums.c_success;
  exception
    when others then
      p_err_code := errnums.c_system_error;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_txAftAppCheck');
      raise errnums.e_system_error;
  end fn_txaftappcheck;

  function fn_txpreappupdate(p_txmsg in tx.msg_rectype,
                             p_err_code out varchar2) return number is
  begin
    plog.setbeginsection(pkgctx, 'fn_txPreAppUpdate');
    plog.debug(pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
    /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    plog.debug(pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection(pkgctx, 'fn_txPreAppUpdate');
    return systemnums.c_success;
  exception
    when others then
      p_err_code := errnums.c_system_error;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_txPreAppUpdate');
      raise errnums.e_system_error;
  end fn_txpreappupdate;

  function fn_txaftappupdate(p_txmsg in tx.msg_rectype,
                             p_err_code out varchar2) return number is
  begin
    plog.setbeginsection(pkgctx, 'fn_txAftAppUpdate');
    plog.debug(pkgctx, '<<BEGIN OF fn_txAftAppUpdate');

    if (p_txmsg.deltd <> 'Y') then

      update sedeposit
         set status = 'D'
       where autoid = p_txmsg.txfields('05').value;

    else
      update sedeposit
         set status = 'S'
       where autoid = p_txmsg.txfields('05').value;

    end if;

    plog.debug(pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection(pkgctx, 'fn_txAftAppUpdate');
    return systemnums.c_success;
  exception
    when others then
      p_err_code := errnums.c_system_error;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_txAftAppUpdate');
      raise errnums.e_system_error;
  end fn_txaftappupdate;

begin
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;
  pkgctx := plog.init('TXPKS_#2231EX',
                      plevel         => nvl(logrow.loglevel, 30),
                      plogtable      => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert         => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace         => (nvl(logrow.log4trace, 'N') = 'Y'));
end txpks_#2231ex;
/
