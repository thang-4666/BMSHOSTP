SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3340ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3340EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3340ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_contents         CONSTANT CHAR(2) := '13';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
      l_count NUMBER;
      l_catype VARCHAR2(4);
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
     SELECT catype INTO l_catype FROM camast
    WHERE camastid=p_txmsg.txfields ('03').VALUE;

    IF (l_catype='014') THEN
       SELECT COUNT(*) INTO l_count from CASCHD
       WHERE CAMASTID= p_txmsg.txfields ('03').VALUE
       AND tqtty <> qtty AND status <> 'O';
             IF l_count >0 THEN
                 p_err_code:= '-300047';
                 RETURN errnums.C_BIZ_RULE_INVALID; -- Van con sot tieu khoan
             END IF;
    END IF;
    SELECT COUNT(*) INTO L_COUNT FROM V_CA3380 WHERE REPLACE(CAMASTID,'.','')=p_txmsg.txfields ('03').VALUE;
    IF L_COUNT=0 THEN
        p_err_code:= '-300013';
        RETURN errnums.C_BIZ_RULE_INVALID; -- Van con sot tieu khoan
    ENd IF;
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
    l_err_param varchar2(500);
    l_CATYPE varchar2(10);
    l_codeid varchar2(50);
    l_count number;
    --BMSSUP-102
    l_txmsg               tx.msg_rectype;
    l_txdesc varchar2(2000);
    --End BMSSUP-102
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    if p_txmsg.deltd<>'Y' then
        cspks_caproc.pr_3380_send_cop_action(p_txmsg,p_err_code);
        if p_err_code <> systemnums.C_SUCCESS THEN
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;


    ELSE
        for rec in
        (
            select * from tllog where reftxnum =p_txmsg.txnum order by autoid desc
        )
        loop
            if rec.tltxcd = '3380' then
                if txpks_#3380.fn_txrevert(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                    plog.error (pkgctx, 'Loi khi thuc hien xoa giao dich '||rec.tltxcd||', txnum='||rec.txnum);
                    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                    return errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;

            --BMSSUP-102: BMS yeu cau cac skq Tham du dai hoi co dong, lay y kien co dong, bo phieu tu dong sinh 3388
            if rec.tltxcd = '3388' then
                if txpks_#3388.fn_txrevert(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                    plog.error (pkgctx, 'Loi khi thuc hien xoa giao dich '||rec.tltxcd||', txnum='||rec.txnum);
                    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                    return errnums.C_SYSTEM_ERROR;
                end if;
            end if;
            --End BMSSUP-102

        end loop;

    end if;
    --select catype into l_catype from camast where camastid =p_txmsg.txfields('03').value;
    select catype, codeid into l_CATYPE, l_codeid from camast where camastid =p_txmsg.txfields('03').value;
    if p_txmsg.deltd ='N' then
        /*if not length(trim(p_txmsg.reftxnum))=10 then
            SELECT count(1) into l_count FROM CASCHD
            WHERE instr((case when l_catype ='014' then 'VM' else 'A' end),STATUS)>0  AND CAMASTID=p_txmsg.txfields('02').value  AND DELTD ='N';
            if l_count=0 then
                UPDATE CAMAST SET STATUS='S' WHERE CAMASTID=p_txmsg.txfields('02').value;
                select catype, codeid into l_CATYPE, l_codeid from camast where camastid =p_txmsg.txfields('02').value;
                if l_CATYPE= '002' then --Halt chung khoan
                    UPDATE SBSECURITIES SET HALT ='Y'
                    WHERE CODEID=l_codeid;
                end if;
            end if;
        end if;*/
        UPDATE CAMAST SET STATUS='S' WHERE CAMASTID=p_txmsg.txfields('03').value;

        if l_CATYPE= '002' then --Halt chung khoan
           UPDATE SBSECURITIES SET HALT ='Y'
            WHERE CODEID=l_codeid;
        end if;

        --BMSSUP-102: BMS yeu cau cac skq Tham du dai hoi co dong, lay y kien co dong, bo phieu tu dong sinh 3388
        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := p_txmsg.TLID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname        := 'DAY';
        l_txmsg.busdate:= p_txmsg.busdate;

        l_txmsg.txdate:= p_txmsg.txdate;
        l_txmsg.tltxcd:='3388';
        l_txmsg.reftxnum := p_txmsg.txnum;

        select txdesc || ' (Auto)' into l_txdesc from tltx where tltxcd = l_txmsg.tltxcd;
        for rec in
        (
            SELECT * FROM V_CAMAST ca
            WHERE replace(CAMASTID,'.','') = replace(p_txmsg.txfields('03').value ,'.','')
                and TYPEID in ('005', '006', '022') and STATUSVAL not in ('C')
        )
        loop
            --Set txnum
            SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            --Set txtime
            select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
            l_txmsg.brid        := p_txmsg.BRID;
            --03    Ma SKQ   C
                 l_txmsg.txfields ('03').defname   := 'CAMASTID';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.VALUE;
            --04    CK nhan   C
                 l_txmsg.txfields ('04').defname   := 'SYMBOL';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.TOSYMBOL;
            --05    Loai thuc hien quyen   C
                 l_txmsg.txfields ('05').defname   := 'CATYPE';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.TYPEID;
            --06    Ngay dang ky cuoi cung   C
                 l_txmsg.txfields ('06').defname   := 'REPORTDATE';
                 l_txmsg.txfields ('06').TYPE      := 'C';
                 l_txmsg.txfields ('06').value      := rec.REPORTDATE;
            --07    Ngay thuc hien quyen   C
                 l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.ACTIONDATE;
            --10    Ty le   C
                 l_txmsg.txfields ('10').defname   := 'RATE';
                 l_txmsg.txfields ('10').TYPE      := 'C';
                 l_txmsg.txfields ('10').value      := rec.RATE;
            --20    trang thai   C
                 l_txmsg.txfields ('20').defname   := 'STATUS';
                 l_txmsg.txfields ('20').TYPE      := 'C';
                 l_txmsg.txfields ('20').value      := rec.STATUSVAL;
            --30    Mo ta   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_txdesc;
            --71    Chung khoan chot   C
                 l_txmsg.txfields ('71').defname   := 'SYMBOL_ORG';
                 l_txmsg.txfields ('71').TYPE      := 'C';
                 l_txmsg.txfields ('71').value      := rec.SYMBOL;
            BEGIN
                IF txpks_#3388.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.error (pkgctx,
                               'got error 3388: ' || p_err_code ||', CAMASTID='||rec.VALUE
                   );
                   ROLLBACK;
                   plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                   return errnums.C_SYSTEM_ERROR;
                END IF;
            END;
        end loop;
        --End BMSSUP-102

    ELSE
        if l_catype = '023' then
            UPDATE CAMAST SET STATUS='V' WHERE CAMASTID=p_txmsg.txfields('03').value;
        ELSIF l_catype <> '014' then
            UPDATE CAMAST SET STATUS='A' WHERE CAMASTID=p_txmsg.txfields('03').value;

        else
            select count(1) into l_count from caschd where camastid =p_txmsg.txfields('03').value and deltd <> 'Y' and status ='M';
            if l_count=0 then
                UPDATE CAMAST SET STATUS='V' WHERE CAMASTID=p_txmsg.txfields('03').value;
            else
                UPDATE CAMAST SET STATUS='M' WHERE CAMASTID=p_txmsg.txfields('03').value;
            end if;
        end if;
        if l_CATYPE= '002' then --Halt chung khoan
             UPDATE SBSECURITIES SET HALT ='N'
             WHERE CODEID=l_codeid;
        end if;

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
         plog.init ('TXPKS_#3340EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3340EX;
/
