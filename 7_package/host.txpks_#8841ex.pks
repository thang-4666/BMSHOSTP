SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8841ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8841EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      16/08/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#8841ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_orderid          CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_txdate           CONSTANT CHAR(2) := '08';
   c_cleardate        CONSTANT CHAR(2) := '09';
   c_codeid           CONSTANT CHAR(2) := '07';
   c_exectype         CONSTANT CHAR(2) := '22';
   c_orderqtty        CONSTANT CHAR(2) := '10';
   c_quoteprice       CONSTANT CHAR(2) := '11';
   c_matchqtty        CONSTANT CHAR(2) := '12';
   c_matchamt         CONSTANT CHAR(2) := '14';
   c_dfqtty           CONSTANT CHAR(2) := '15';
   c_aamt             CONSTANT CHAR(2) := '16';
   c_errreason        CONSTANT CHAR(2) := '20';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_seTrade number;
v_netByOrderid number;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/

    -- hsx04: check xem kl mua khop da dung de ban chua
     if(p_txmsg.txfields(c_exectype).value = 'NB') then
           select se.trade - NVL (b.secureamt, 0) + (case when sb.domain in ('STCK','CBND') then se.execbuyqtty + se.odreceiving else 0 end ) -   p_txmsg.txfields(c_matchqtty).value
           into v_seTrade
           from semast se, v_getsellorderinfo b, sbsecurities sb
           where  se.codeid = sb.codeid and acctno = b.seacctno(+)
             and se.afacctno = p_txmsg.txfields(c_afacctno).value
            and se.codeid = p_txmsg.txfields(c_codeid).value;
           if(v_seTrade <0) then
              p_err_code := '-260041';
              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
           end if;
     end if;
    select  od.netexecqtty + od.cfnetexecqtty + od.netexecamt + od.cfnetexecamt into v_netByOrderid
        from odmast od where orderid = p_txmsg.txfields(c_orderid).value;
        if(v_netByOrderid > 0) then
            p_err_code := '-540125';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;


    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAftAppCheck');
   plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_cfVat cfmast.vat%type;
v_cfCustid cfmast.custid%type;
v_grporder odmast.grporder%type;
v_cfCusatcom cfmast.custatcom%type;
v_cfwhtax cfmast.whtax%type;

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    -- HSX04: tinh toan lai tien UTTB
    if(  p_txmsg.txfields(c_exectype).value <> 'NB' ) then
     select custid, nvl(vat, 'N'), nvl(whtax, 'N') , custatcom  into v_cfCustid, v_cfVat, v_cfwhtax,v_cfCusatcom
     from cfmast where custodycd = p_txmsg.txfields (c_custodycd).VALUE;

     select nvl(grporder,'N')
     into v_grporder
     from odmast od where orderid = p_txmsg.txfields('01').value;

      if( v_cfCusatcom ='Y' and v_grporder <>'Y' ) then
       if(to_date( p_txmsg.txfields(c_txdate).value, 'DD/MM/RRRR') = getcurrdate) then
          execorder_update_aft (p_txmsg.txfields('01').value, p_txmsg.txfields('12').value,p_txmsg.txfields('14').value/p_txmsg.txfields('12').value,'0','','',p_err_code,'2');
         else
           prc_adv_cimastext(p_txmsg.txfields(c_afacctno).value, 'Y');
         end if;
      end if;

    end if;


    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppUpdate;

BEGIN
      FOR i IN (SELECT *
                FROM tlogdebug)
      LOOP
         logrow.loglevel    := i.loglevel;
         logrow.log4table   := i.log4table;
         logrow.log4alert   := i.log4alert;
         logrow.log4trace   := i.log4trace;
      END LOOP;
      pkgctx    :=
         plog.init ('TXPKS_#8841EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8841EX;
/
