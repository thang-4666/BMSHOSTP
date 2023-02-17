SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8847ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8847EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      22/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8847ex
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
   c_errreason        CONSTANT CHAR(2) := '20';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

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
v_ordertxdate date;
v_amt  number ;
v_bratio number(20,4);
v_aright number(20,4);
v_feeAmt number(20,4);
v_dblAdvRate      NUMBER(20,4);
v_vatAmt       number(20,4);
v_advFeeAmt    number(20,4);
v_dblADVANCEDAYS  NUMBER;
v_dblVATRATE      NUMBER;
v_dblDays NUMBER;
v_strclearday odmast.clearday%type;
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

    If(  p_txmsg.txfields(c_exectype).value <> 'NB' ) then
 select custid, nvl(vat, 'N'), nvl(whtax, 'N') , custatcom  into v_cfCustid, v_cfVat, v_cfwhtax,v_cfCusatcom
 from cfmast where custodycd = p_txmsg.txfields (c_custodycd).VALUE;

 select BRATIO, feeacr, od.execamt, clearday,nvl(grporder,'N')
 into v_bratio, v_feeAmt, v_amt, v_strclearday, v_grporder
  from odmast od where orderid = p_txmsg.txfields('01').value;

      if(v_cfCusatcom ='Y' and v_grporder <>'Y') then
       if(to_date( p_txmsg.txfields(c_txdate).value, 'DD/MM/RRRR') = getcurrdate) then

         select s.aright, (CASE WHEN s.CLEARDATE - getcurrdate =0  and s.clearday > 0 THEN 1 ELSE s.CLEARDATE - getcurrdate END) DAYS, amt
         into v_aright,v_dblDays, v_amt
         from stschd s where ORGORDERID = p_txmsg.txfields('01').value and duetype ='RM';

         SELECT adt.advrate + adt.advbankrate
            INTO v_dblAdvRate
            FROM afmast af, aftype aft, adtype adt
            WHERE af.actype = aft.actype AND aft.adtype = adt.actype
            AND af.acctno = p_txmsg.txfields(c_afacctno).value;



         SELECT varvalue INTO v_dblADVANCEDAYS FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'ADVANCEDAYS';
         SELECT varvalue INTO v_dblVATRATE FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'ADVSELLDUTY';

         if (v_feeAmt <=0) then
               v_feeAmt:= v_amt * (v_bratio-100) /100 ;
         end if;

          v_VatAmt := case when v_cfVat ='Y' then v_amt * v_dblVATRATE / 100 else 0 end  + v_aright;
          v_AdvFeeAmt := (v_amt - v_feeAmt - v_VatAmt) * v_dblDays * v_dblAdvRate / 100  / ( v_dblADVANCEDAYS + v_dblDays * (v_dblAdvRate/100));

           UPDATE CIMASTEXT CI
               SET   ci.advamtbuyin = ci.advamtbuyin + case when v_dblDays = 0 then v_amt- v_feeAmt - v_VatAmt else 0 end  ,
                     ci.advfeebuyin = ci.advfeebuyin + case when v_dblDays = 0 then v_AdvFeeAmt else 0 end ,
                     ci.advamtt0 = ci.advamtt0 + case when v_dblDays = 1  then v_amt- v_feeAmt - v_VatAmt else 0 end  ,
                     ci.advfeet0 = ci.advfeet0 + case when v_dblDays = 1 then v_AdvFeeAmt else 0 end ,
                     ci.advamtt1 = ci.advamtt1 + case when v_dblDays > 1 and v_strclearday = 1 then v_amt- v_feeAmt - v_VatAmt  else 0 end ,
                     ci.advfeet1 = ci.advfeet1 + case when v_dblDays > 1 and v_strclearday = 1 then v_AdvFeeAmt else 0 end ,
                     ci.advamtt2 = ci.advamtt2 + case when v_strclearday = 2 then v_amt- v_feeAmt - v_VatAmt  else 0 end ,
                     ci.advfeet2 = ci.advfeet2 + case when v_strclearday = 2 then v_AdvFeeAmt else 0 end ,
                     ci.advamttn = ci.advamttn + case when v_strclearday > 2 then v_amt- v_feeAmt - v_VatAmt  else 0 end ,
                     ci.advfeetn = ci.advfeetn + case when v_strclearday > 2 then v_AdvFeeAmt else 0 end
               where afacctno = p_txmsg.txfields(c_afacctno).value;
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
         plog.init ('TXPKS_#8847EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8847EX;
/
