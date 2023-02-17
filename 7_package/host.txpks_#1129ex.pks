SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1129ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1129EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      06/03/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1129ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_fileid           CONSTANT CHAR(2) := '03';
   c_amt              CONSTANT CHAR(2) := '10';
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
    l_txmsg               tx.msg_rectype;
    v_strCURRDATE varchar2(20);
    v_strPREVDATE varchar2(20);
    v_strNEXTDATE varchar2(20);
    v_strDesc varchar2(1000);
    v_strEN_Desc varchar2(1000);
    l_err_param varchar2(300);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if p_txmsg.deltd<>'Y' then
        SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1137';

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_strCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'AUTO';
        l_txmsg.reftxnum    := p_txmsg.txnum;
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='1137';

            FOR REC in (
                     select a.autoid, a.custodycd, a.acctno, a.amt, b.fullname, b.address, b.idcode, b.iddate, b.idplace, a.fileid
                        from TBLCI1137 a, cfmast b where a.fileid = p_txmsg.txfields('03').value and nvl(a.status,'N') <> 'Y'
                        and nvl(a.deltd,'N') <> 'Y' and a.custodycd = b.custodycd
                )
            loop

                SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                     -- Tao giao dich 1137
                   -- 88  CUSTODYCD   C
                   l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                   l_txmsg.txfields ('88').TYPE      := 'C';
                   l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

                   --  03  ACCTNO      C
                   l_txmsg.txfields ('03').defname   := 'ACCTNO';
                   l_txmsg.txfields ('03').TYPE      := 'C';
                   l_txmsg.txfields ('03').VALUE     := rec.ACCTNO;

                   --  90  CUSTNAME    C
                   l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                   l_txmsg.txfields ('90').TYPE      := 'C';
                   l_txmsg.txfields ('90').VALUE     := rec.fullname;

                   --  91  ADDRESS     C
                   l_txmsg.txfields ('91').defname   := 'ADDRESS';
                   l_txmsg.txfields ('91').TYPE      := 'C';
                   l_txmsg.txfields ('91').VALUE     := rec.address;

                   --  92  LICENSE     C
                   l_txmsg.txfields ('92').defname   := 'LICENSE';
                   l_txmsg.txfields ('92').TYPE      := 'C';
                   l_txmsg.txfields ('92').VALUE     := rec.idcode;

                   --  96  BANKACCTNO  C
                   l_txmsg.txfields ('96').defname   := 'BANKACCTNO';
                   l_txmsg.txfields ('96').TYPE      := 'C';
                   l_txmsg.txfields ('96').VALUE     := '';

                   --  93  IDDATE      C
                   l_txmsg.txfields ('93').defname   := 'IDDATE';
                   l_txmsg.txfields ('93').TYPE      := 'C';
                   l_txmsg.txfields ('93').VALUE     := rec.iddate;

                   --  94  IDPLACE     C
                   l_txmsg.txfields ('94').defname   := 'IDPLACE';
                   l_txmsg.txfields ('94').TYPE      := 'C';
                   l_txmsg.txfields ('94').VALUE     := rec.IDPLACE;

                   --  07  COREBANK    C
                   l_txmsg.txfields ('07').defname   := 'COREBANK';
                   l_txmsg.txfields ('07').TYPE      := 'C';
                   l_txmsg.txfields ('07').VALUE     := '';

                   --  89  AVLCASH     N
                   l_txmsg.txfields ('89').defname   := 'AVLCASH';
                   l_txmsg.txfields ('89').TYPE      := 'N';
                   l_txmsg.txfields ('89').VALUE     := 0;

                   --  95  BANKNAME    C
                   l_txmsg.txfields ('95').defname   := 'BANKNAME';
                   l_txmsg.txfields ('95').TYPE      := 'C';
                   l_txmsg.txfields ('95').VALUE     := '';

                   --  10  AMT         N
                   l_txmsg.txfields ('10').defname   := 'AMT';
                   l_txmsg.txfields ('10').TYPE      := 'N';
                   l_txmsg.txfields ('10').VALUE     := rec.amt;

                    --30  DESCRIPTION            C
                    l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
                    l_txmsg.txfields ('30').TYPE      := 'C';
                    l_txmsg.txfields ('30').VALUE     := v_strDesc;

                    BEGIN
                        IF txpks_#1137.fn_batchtxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 1137: ' || p_err_code
                           );
                           ROLLBACK;
                           RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END;

                    update TBLCI1137 set status = 'Y' where autoid = rec.autoid;

            end loop;

        insert into tblci1137hist select * from TBLCI1137;
        delete from tblci1137;

        --Tu dong Gom cac bang ke pending ra ngan hang
        cspks_rmproc.sp_exec_create_crbtrflog_multi('TRFRLSTAX',p_err_code);
        if p_err_code <> systemnums.C_SUCCESS then
            plog.setendsection(pkgctx, 'pr_SAAfterBatch');
            return errnums.C_BIZ_RULE_INVALID;
        end if;
    else
        for rec in
        (
            select * from tllog where reftxnum =p_txmsg.txnum
        )
        loop
            if txpks_#1137.fn_txrevert(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                plog.error (pkgctx, 'Loi khi thuc hien xoa giao dich');
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                return errnums.C_SYSTEM_ERROR;
            end if;
        end loop;
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
         plog.init ('TXPKS_#1129EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1129EX;

/
