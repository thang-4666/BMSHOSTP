SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3336ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3336EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  HUNG.LB     24/08/10     Updated
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#3336ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '02';
   c_taskcd           CONSTANT CHAR(2) := '16';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_seacctno         CONSTANT CHAR(2) := '06';
   c_exprice          CONSTANT CHAR(2) := '05';
   c_balance          CONSTANT CHAR(2) := '07';
   c_qtty             CONSTANT CHAR(2) := '21';
   c_optseacctno      CONSTANT CHAR(2) := '09';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_status           CONSTANT CHAR(2) := '40';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_iscorebank       CONSTANT CHAR(2) := '60';
   c_description      CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_leader_license varchar2(100);
    l_leader_idexpired date;
    l_member_license varchar2(100);
    l_member_idexpired date;
    l_idexpdays apprules.field%TYPE;
    l_afmastcheck_arr txpks_check.afmastcheck_arrtype;
    l_leader_expired boolean;
    l_member_expired boolean;
    l_country VARCHAR2(5);

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
    l_count NUMBER;
    l_availqtty FLOAT;
    l_baldefovd number;
    l_baldeftrfamtex number;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
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
    /*l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');

    l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
    l_baldeftrfamtex := l_CIMASTcheck_arr(0).baldeftrfamtex;
    IF NOT (greatest(to_number(l_BALDEFOVD),to_number(l_baldeftrfamtex)) >= to_number(p_txmsg.txfields('21').value*p_txmsg.txfields('05').value)) THEN
       p_err_code := '-400110';
       plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;*/

    BEGIN
    select PQTTY INTO l_availqtty from CASCHD WHERE CAMASTID= p_txmsg.txfields ('02').VALUE AND AFACCTNO = p_txmsg.txfields ('03').VALUE
                                              AND deltd='N'
                                              AND autoid=p_txmsg.txfields ('01').VALUE;
    IF l_availqtty < p_txmsg.txfields ('21').VALUE THEN
        p_err_code:= '-300026';
        RETURN errnums.C_BIZ_RULE_INVALID; -- Chua het ngay cho phep dang ki chuyen nhuong.
    END IF;
    EXCEPTION
    WHEN no_data_found THEN
        p_err_code:= '-300013';
        RETURN errnums.C_BIZ_RULE_INVALID; -- Chua het ngay cho phep dang ki chuyen nhuong.
    END;


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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

    l_camastid varchar2(30); --02   CAMASTID      C
    l_afacctno varchar2(30); --03   AFACCTNO      C
    l_symbol varchar2(30); --04   SYMBOL        C
    l_exprice number(20,0); --05   EXPRICE       N
    l_qtty number(20,0); --21   QTTY          N
    l_status varchar2(1); --40   STATUS        C
    -- TRANSACTION
    l_left_rightoffrate varchar2(30);
    l_right_rightoffrate varchar2(30);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if p_txmsg.deltd <> 'Y' then
        --Get cac field giao dich
        --02   CAMASTID      C
        l_camastid:= p_txmsg.txfields ('02').VALUE;
        --03   AFACCTNO      C
        l_afacctno:= p_txmsg.txfields ('03').VALUE;
        --04   SYMBOL        C
        l_symbol:= p_txmsg.txfields ('04').VALUE;
        --05   EXPRICE       N
        l_exprice:= p_txmsg.txfields ('05').VALUE;
        --21   QTTY          N
        l_qtty:=p_txmsg.txfields ('21').VALUE;
        --40   STATUS        C
        l_status:=p_txmsg.txfields ('40').VALUE;

        FOR REC IN
        (
        SELECT rightoffrate, excodeid, optcodeid FROM CAMAST WHERE CAMASTID= l_camastid AND deltd='N'
        )
        LOOP

           SELECT      substr(REC.rightoffrate,1,instr(REC.rightoffrate,'/')-1),
                           substr(REC.rightoffrate,instr(REC.rightoffrate,'/') + 1,length(REC.rightoffrate))
               INTO    l_left_rightoffrate, l_right_rightoffrate
           from dual;

           Update semast
            set trade = trade - TRUNC( l_qtty * to_number(l_left_rightoffrate / l_right_rightoffrate))
           where acctno = l_afacctno || REC.optcodeid;

           INSERT INTO SETRAN (ACCTNO, TXNUM, TXDATE, TXCD, NAMT, CAMT, REF, DELTD,AUTOID,acctref,tltxcd)
           VALUES (l_afacctno || REC.optcodeid,p_txmsg.txnum,p_txmsg.txdate,'0011', TRUNC(l_qtty * to_number(l_left_rightoffrate / l_right_rightoffrate) ),'',p_txmsg.txfields ('01').value,'N',SEQ_SETRAN.NEXTVAL,p_txmsg.txfields ('01').value,p_txmsg.tltxcd);

           UPDATE CASCHD
            SET STATUS= l_status
           WHERE AFACCTNO= l_afacctno
               AND CAMASTID= l_camastid
               AND DELTD = 'N'
               AND autoid=p_txmsg.txfields ('01').VALUE;

           UPDATE CAMAST
           SET STATUS= l_status
           WHERE CAMASTID= l_camastid;

           -- Cap nhat giam so tien nop cho quyen mua
           UPDATE CASCHD
           SET     BALANCE = BALANCE + TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ) ,
                   AAMT= AAMT + l_exprice * l_qtty  ,
                   QTTY = QTTY + l_qtty,
                   NMQTTY = NMQTTY + l_qtty,
                   PAAMT= PAAMT - l_exprice * l_qtty ,
                   PQTTY= PQTTY - l_qtty,
                   PBALANCE = PBALANCE - TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ),
                   inbalance=inbalance- least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                   RETAILBAL=RETAILBAL- TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )+least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                   RORETAILBAL=RORETAILBAL+ TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )-least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ))
           WHERE AFACCTNO= l_afacctno AND CAMASTID= l_camastid AND DELTD = 'N'
           AND autoid=p_txmsg.txfields ('01').VALUE;

        END LOOP;

    else
        UPDATE CASCHD
        SET STATUS='A'
        WHERE AFACCTNO=p_txmsg.txfields(c_afacctno).value
        AND CAMASTID=p_txmsg.txfields(c_camastid).value
        AND DELTD = 'N'
        AND autoid=p_txmsg.txfields ('01').VALUE;

        UPDATE CAMAST
        SET STATUS='A'
        WHERE  CAMASTID=p_txmsg.txfields(c_camastid).value;

        UPDATE CASCHD
        SET BALANCE = BALANCE - TRUNC(l_qtty * TO_NUMBER(l_left_rightoffrate / l_right_rightoffrate)) ,
                AAMT= AAMT - l_exprice * l_qtty ,QTTY= QTTY - l_qtty,  NMQTTY = NMQTTY - l_qtty,
                PAAMT= PAAMT + l_exprice * l_qtty ,
                PQTTY= PQTTY + l_qtty,
                PBALANCE = PBALANCE + TRUNC(l_qtty * to_number(l_left_rightoffrate / l_right_rightoffrate)) ,
              inbalance=inbalance+ least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                   RETAILBAL=RETAILBAL+ TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )-least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                   RORETAILBAL=RORETAILBAL- TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )+least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ))
              WHERE AFACCTNO= p_txmsg.txfields(c_afacctno).value  AND CAMASTID=p_txmsg.txfields(c_camastid).value
        AND DELTD = 'N' AND autoid=p_txmsg.txfields ('01').VALUE;

    end if;
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
         plog.init ('TXPKS_#3336EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3336EX;
/
