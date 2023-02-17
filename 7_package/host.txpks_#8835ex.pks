SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8835ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8835EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      03/12/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8835ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_orgorderid       CONSTANT CHAR(2) := '03';
   c_codeid           CONSTANT CHAR(2) := '80';
   c_symbol           CONSTANT CHAR(2) := '81';
   c_custodycd        CONSTANT CHAR(2) := '82';
   c_afacctno         CONSTANT CHAR(2) := '07';
   c_orderprice       CONSTANT CHAR(2) := '10';
   c_orderqtty        CONSTANT CHAR(2) := '11';
   c_matchprice       CONSTANT CHAR(2) := '12';
   c_matchqtty        CONSTANT CHAR(2) := '13';
   c_execamt          CONSTANT CHAR(2) := '14';
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
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_orderid varchar2(30);
    v_exectype varchar2(20);
    v_seTrade number;
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

    -- hsx04: check xem kl mua khop da dung de ban chua
          v_orderid:=p_txmsg.txfields ('03').VALUE;
          select od.exectype into  v_exectype from odmast od where orderid = v_orderid;

           if(v_exectype = 'NB') then
               select se.trade - NVL (b.secureamt, 0) + (case when sb.domain in ('STCK','CBND') then se.execbuyqtty + se.odreceiving else 0 end ) -   p_txmsg.txfields(c_matchqtty).value
               into v_seTrade
               from semast se, v_getsellorderinfo b, sbsecurities sb
               where  se.codeid = sb.codeid and acctno = b.seacctno(+)
                 and se.afacctno = p_txmsg.txfields(c_afacctno).value and se.codeid = p_txmsg.txfields(c_codeid).value;
                 if(v_seTrade <0) then
                     p_err_code := '-260041';
                     plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                     RETURN errnums.C_BIZ_RULE_INVALID;
                 end if;
            end if;

   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER

IS
v_aamt      number ;
v_aqtty     number ;
p_orderid   varchar2(30);
v_tllogrow  tllog%rowtype;
v_EXECQTTY  number ;
v_amt       number ;

V_MATCHQTTY NUMBER;
V_EXECAMT   NUMBER;
V_REFTXNUM  VARCHAR2(50);
V_REFTXDATE VARCHAR2(50);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
--    plog.debug (pkgctx, 'nam test '|| p_txmsg.txfields ('03').VALUE);
--    pr_revert_trading_allocating(p_txmsg.txfields ('03').VALUE);
       p_orderid:=p_txmsg.txfields ('03').VALUE;

       V_MATCHQTTY := p_txmsg.txfields ('13').VALUE;
       V_EXECAMT   := p_txmsg.txfields ('14').VALUE;
       V_REFTXNUM  := p_txmsg.txfields ('83').VALUE;
       V_REFTXDATE := p_txmsg.txfields ('84').VALUE;


        SELECT SUM(AAMT), SUM(AQTTY), SUM(QTTY) ,SUM(AMT) INTO V_AAMT, V_AQTTY,V_EXECQTTY,V_AMT
        FROM STSCHD WHERE ORGORDERID = P_ORDERID /*and duetype in ('SM','SS')*/;

        IF v_aamt > 0 or v_aqtty > 0 THEN
            p_err_code := '-701022';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
                rollback;
        ELSE
            secnet_un_map(V_REFTXNUM,V_REFTXDATE);
            delete from iod where txnum = V_REFTXNUM and txdate = to_date(V_REFTXDATE,'DD/MM/RRRR');
            -- REVERT TLLOG
             ---UPDATE TLLOG SET DELTD = 'Y' WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = p_orderid;

             ----FOR I IN (SELECT * FROM TLLOG WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = p_orderid)
             ----LOOP
                 ----SELECT * INTO v_tllogrow FROM TLLOG WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = p_orderid AND TXNUM = i.TXNUM;
                 -- REVERT TLLOGFLD
                 --DELETE TLLOGFLD WHERE TXNUM = v_tllogrow.TXNUM;

                 -- REVERT AFTRAN

                 ----UPDATE AFTRAN SET DELTD = 'Y' WHERE TXNUM = v_tllogrow.TXNUM;
              /*   IF SQL%ROWCOUNT <> 1 THEN
                     dbms_output.put_line('Error: Duplicate AFTRAN. Going to rollback');
                     rollback;
                 END IF;*/

                 -- REVERT ODTRAN
                 ----UPDATE ODTRAN SET DELTD = 'Y' WHERE TXNUM = v_tllogrow.TXNUM AND ACCTNO = p_orderid;
                 ----secnet_un_map(v_tllogrow.txnum,to_char(v_tllogrow.txdate,'DD/MM/RRRR'));
             ----END LOOP;


/*             -- REVERT AFMAST
             UPDATE      afmast
             SET         dmatchamt = NVL(dmatchamt,0) - rec_orderrow.MATCHAMT
             WHERE       acctno = rec_orderrow.AFACCTNO;
             IF SQL%ROWCOUNT <> 1 THEN
                dbms_output.put_line('Error: Duplicate AFMAST. Going to rollback');
                rollback;
             END IF;*/

             -- REVERT IOD
             -- DELETE      IOD
             -- WHERE       ORGORDERID = p_orderid;

             -- REVERT odchanging_trigger_log
             DELETE      odchanging_trigger_log
             WHERE       orderid = p_orderid and txnum = V_REFTXNUM and txdate = to_date(V_REFTXDATE,'DD/MM/RRRR');

             -- REVERT orderdeal
             ---DELETE      orderdeal
             ---WHERE       orderid = p_orderid;

             -- REVERT ODMAST
             UPDATE odmast
             SET         execamt = NVL(execamt,0) - V_EXECAMT,
                         execqtty = NVL(execqtty,0) - V_MATCHQTTY,
                         matchamt = NVL(matchamt,0) - V_EXECAMT,
                         orstatus = '2',
                         --cancelqtty = cancelqtty - rec_orderrow.CANCELQTTY,
                         --remainqtty = remainqtty + rec_orderrow.EXECQTTY + rec_orderrow.CANCELQTTY,
                         remainqtty = remainqtty + V_MATCHQTTY,
                         last_change = SYSTIMESTAMP
             WHERE       orderid = p_orderid;

             -- REVERT STSCHD
            -- DELETE      STSCHD
            -- WHERE       ORGORDERID = p_orderid;

            update stschd SET qtty = nvl(qtty,0) - V_MATCHQTTY,
                amt = nvl(amt,0) - V_EXECAMT
            where ORGORDERID = p_orderid;
            --        COMMIT;

            -- GW04: cap nhat SE/CI
           EXECORDER_UPDATE_AFT(p_orderid,V_MATCHQTTY,V_EXECAMT/V_MATCHQTTY,'0','','',p_err_code);
           if(p_err_code <>'0') then
              plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
           end if;

            -- end GW04

            delete stschd
            where ORGORDERID = p_orderid and nvl(qtty,0)  = 0;

        END IF;



    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
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
         plog.init ('TXPKS_#8835EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8835EX;
/
