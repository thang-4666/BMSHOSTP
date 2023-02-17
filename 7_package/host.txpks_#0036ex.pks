SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0036ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0036EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      22/06/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0036ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_idcode           CONSTANT CHAR(2) := '88';
   c_fullname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_oldstatus        CONSTANT CHAR(2) := '06';
   c_newstatus        CONSTANT CHAR(2) := '09';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_status varchar2(1);
v_count NUMBER;
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
    select status into v_status from cfmasttemp where idcode = p_txmsg.txfields('88').value AND STATUS <> 'A';
    plog.error(pkgctx, 'status =  ' || v_status || ' ' || p_txmsg.txfields('88').value|| ' - newstatus ' || p_txmsg.txfields(c_newstatus).value);

        SELECT count(*) INTO v_count FROM CFMAST where idcode = p_txmsg.txfields('88').value and status <> 'C';
    if v_count <> 0 AND p_txmsg.txfields(c_newstatus).value not IN ('R') then
        p_err_code:= -100530;
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

        ----? g?i thu, ? x?nh?n th?tin, Ch? m? T?kho?n... d?u kh?Reverse l?i T?kho?n v? tr?ng th?ban d?u l?Ch? m? t?kho?n".

    --Trang thai P (Cho xac nhan) chi duoc chuyen sang trang thai N (Xac nhan) hoac R (Het hieu luc)
    If v_status = 'P' And p_txmsg.txfields(c_newstatus).value not IN ('N','R','P') Then
        p_err_code :=  -100500;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

    --Trang thai N (da Xac nhan TT KH) chi duoc chuyen sang trang thai S (da gui), R (Het hieu luc)
    If v_status = 'N' And p_txmsg.txfields(c_newstatus).value not IN ('R','S','W','P') Then
        p_err_code :=  -100501;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

    --Trang thai S (Da gui ho so) chi duoc chuyen sang trang thai W (cho bo sung ho so) , C (Da xac nhan mo tai khoan) , R(da huy)
    If v_status = 'S' And p_txmsg.txfields(c_newstatus).value not IN ('W','C','R','P') Then
        p_err_code :=  -100502;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

    --Cho bo sung ho/s chi co chuyen sang (Da xac nhan mo tai khoan) hoac (da huy)
    If v_status = 'W' And p_txmsg.txfields(c_newstatus).value not IN ('C','R','P') Then
        p_err_code :=  -100503;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

    --Trang thai R (Het hieu luc) chi duoc chuyen sang trang thai P (Cho Xac nhan), R (Het hieu luc) N (Xac nhan) hoac S (Da Gui ho so)
    /*If v_status = 'R' And p_txmsg.txfields(c_newstatus).value not In('P','R','N','S') Then
        p_err_code :=  -100503;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;*/
    --trang thai het hieu luc chi duoc thay doi khi khach hang gui lai thong tin tu web

    --Trang thai C (Da mo tai khoan) khong dc sua thong tin
    If v_status = 'C' AND p_txmsg.txfields(c_newstatus).value not IN ('P','R') Then
        p_err_code := -100504;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

        --Trang thai R duoc phep tro ve trang thai P
    If v_status = 'R' AND p_txmsg.txfields(c_newstatus).value not IN ('P') Then
        p_err_code := -100528;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

         If v_status = 'A'  Then
        p_err_code := -100527;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    End If;

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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
   /* IF  p_txmsg.deltd  <> 'Y'  AND c_newstatus = 'R' THEN
           INSERT INTO cfmasttemp_hist
             SELECT * FROM cfmasttemp WHERE idcode = c_idcode;
             DELETE FROM cfmasttemp WHERE idcode = c_idcode;
        END IF;*/
    IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction
      UPDATE CFMASTTEMP
         SET
           PSTATUS=PSTATUS||STATUS,STATUS=p_txmsg.txfields('09').value, LAST_CHANGE = SYSTIMESTAMP,
           NOTE = p_txmsg.txfields('31').value
        WHERE IDCODE=p_txmsg.txfields('88').value and status <> 'A';
        -- insert vao aftran(binhvt)
        insert into aftran(autoid,txnum,txdate,ref,acctref,tltxcd,deltd,trdesc,namt) 
        values (seq_aftran.nextval,p_txmsg.txnum,TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('06').value,p_txmsg.txfields('09').value,'0036','N',p_txmsg.txfields('31').value,1);
   ELSE -- Reversal
      UPDATE TLLOG
        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
      UPDATE CFMASTTEMP
      SET
         PSTATUS=PSTATUS||STATUS,STATUS=substr(PSTATUS,length(PSTATUS),1), LAST_CHANGE = SYSTIMESTAMP
        WHERE IDCODE=p_txmsg.txfields('88').value and status <> 'A';
        -- begin binhvt
       UPDATE  aftran set  DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        -- end binhvt
   END IF;
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
         plog.init ('TXPKS_#0036EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0036EX;
/
