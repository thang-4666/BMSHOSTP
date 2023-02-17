SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2239ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2239EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      09/08/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2239ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_custodycd2       CONSTANT CHAR(2) := '89';
   c_afacct2          CONSTANT CHAR(2) := '04';
   c_acct2            CONSTANT CHAR(2) := '05';
   c_custname2        CONSTANT CHAR(2) := '93';
   c_address2         CONSTANT CHAR(2) := '94';
   c_license2         CONSTANT CHAR(2) := '95';
   c_trade_chk        CONSTANT CHAR(2) := '21';
   c_mrrate           CONSTANT CHAR(2) := '11';
   c_trade            CONSTANT CHAR(2) := '10';
   c_mrprice          CONSTANT CHAR(2) := '12';
   c_rlsamt_chk       CONSTANT CHAR(2) := '14';
   c_rlsamt           CONSTANT CHAR(2) := '15';
   c_hundred          CONSTANT CHAR(2) := '99';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_margintype    char(1);
    l_istrfbuy      char(1);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_AVLLIMIT number;

    l_pp_trf number;
    l_se_trf number;
    l_f_mnemonic VARCHAR (10);
    l_t_mnemonic VARCHAR (10);
    l_aamt  number;
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
    SELECT mr.mrtype,af.istrfbuy,af.mnemonic
        INTO l_margintype, l_istrfbuy,l_t_mnemonic
    FROM afmast mst, aftype af, mrtype mr
    WHERE mst.actype = af.actype
      AND af.mrtype = mr.actype
      AND mst.acctno = p_txmsg.txfields('04').value;

      SELECT af.mnemonic
        INTO l_f_mnemonic
    FROM afmast mst, aftype af
    WHERE mst.actype = af.actype
      AND mst.acctno = p_txmsg.txfields('02').value;

    if l_margintype in ('S','T') then
        IF p_txmsg.deltd = 'N' THEN
            if txpks_prchk.fn_RoomLimitCheck(p_txmsg.txfields('04').value, p_txmsg.txfields('01').value,
                greatest(to_number(p_txmsg.txfields('10').value),0), p_err_code) <> 0 then
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
        --Chan khong cho chuyen cung tieu khoan T3
        if l_istrfbuy ='Y' then
            p_err_code:='-200107';
            plog.error (pkgctx, 'Chuyen chung khoan cung tieu khoan T3, Ma loi p_err_code:' || p_err_code);
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    end if;
    --Chan khong cho chuyen cung so tieu khoan
    if p_txmsg.txfields('04').value = p_txmsg.txfields('02').value then
        p_err_code:='-200106';
        plog.error (pkgctx, 'Chuyen chung khoan cung tieu khoan, Ma loi p_err_code:' || p_err_code);
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    IF p_txmsg.deltd = 'N' THEN
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('04').value,'CIMAST','ACCTNO');
        l_AVLLIMIT := l_CIMASTcheck_arr(0).AVLLIMIT;
        IF NOT (to_number(l_AVLLIMIT) >= to_number(p_txmsg.txfields('15').value)) THEN
            p_err_code := '-400117';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;

    --Them rule chan han muc theo nhom
    if fn_checkMrlimitByGroup(p_txmsg.txfields('04').value, to_number(p_txmsg.txfields('15').value)) <0 then
        p_err_code := '-400217';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    --Kiem tra tai khoan Chuyen chung khoan, sau khi chuyen thi thang du phai >0
    IF p_txmsg.deltd = 'N' THEN
        l_pp_trf:=0;
        l_se_trf:=0;
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('02').value,'CIMAST','ACCTNO');
        --Suc mua tai khoan chuyen
        l_pp_trf := l_CIMASTcheck_arr(0).PP;
        --Phan chung khoan chuyen di khoi tai khoan
        l_se_trf := nvl(cspks_mrproc.fn_getMrRate(p_txmsg.txfields('02').value,p_txmsg.txfields('01').value),0)
                    * nvl(cspks_mrproc.fn_getMrPrice(p_txmsg.txfields('02').value,p_txmsg.txfields('01').value),0)
                    * to_number(p_txmsg.txfields('10').value)/100;
        if l_pp_trf - l_se_trf + to_number(p_txmsg.txfields('15').value) <0 and l_se_trf > to_number(p_txmsg.txfields('15').value) then
            --Thong bao tai khoan chuyen sau khi chuyen khong du thang du
            p_err_code := '-400116';
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    end if;

    IF upper(l_f_mnemonic)='T3' AND upper(l_t_mnemonic) ='MARGIN' THEN

    SELECT     ROUND(p_txmsg.txfields('15').value,0)- ( cimast.dueamt + cimast.ovamt -cimast.balance) INTO l_aamt
    FROM cimast WHERE acctno = p_txmsg.txfields('02').value;


        if  l_aamt > 0 then
            p_err_code := '-401116';
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

    END IF ;


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
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT          **
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
    V_COSTPRICE NUMBER(20,0);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_PP number;
    v_seqtty number;
    v_strAFACCTNO varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     IF p_txmsg.deltd = 'N' THEN
        SELECT ROUND(SUM((qtty-mapqtty)*costprice)/SUM(qtty-mapqtty) ,4) INTO V_COSTPRICE
        FROM secmast
        WHERE ptype  = 'I' AND deltd = 'N' AND qtty - mapqtty > 0
        AND acctno = p_txmsg.txfields('02').value AND Codeid = p_txmsg.txfields('01').value;
        V_COSTPRICE :=  NVL(V_COSTPRICE,0);




     /*--- VOI TAI KHOAN CHUYEN
        secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('03').value,
        p_txmsg.txfields('01').value, 'D', 'O', NULL, NULL, p_txmsg.txfields('10').value, V_COSTPRICE, 'Y');
     --- VOI TAI KHOAN NHAN
        secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('04').value,
        p_txmsg.txfields('01').value, 'D', 'I', NULL, NULL, p_txmsg.txfields('10').value, V_COSTPRICE, 'Y');*/

        --Kiem tra sau khi chuyen khoan thi PP cua tai khoan chuyen phai >=0.
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('04').value,'CIMAST','ACCTNO');
        l_PP := l_CIMASTcheck_arr(0).PP;
        if l_PP<0 then
            p_err_code := '-400116';
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

     v_strAFACCTNO := p_txmsg.txfields('03').value;
    v_seqtty := p_txmsg.txfields('10').value;
    for rec1 IN (SELECT AUTOID, qtty-mapqtty REMAIN_QTTY, BUSDATE, costprice costprice
        FROM secmast WHERE ACCTNO = p_txmsg.txfields('02').value AND codeid = p_txmsg.txfields('01').value
            AND PTYPE = 'I' AND mapavl = 'Y' AND deltd = 'N' AND qtty > 0 and qtty-mapqtty <> 0
            and v_seqtty > 0
        ORDER BY BUSDATE,AUTOID, TXNUM
    ) loop
        IF v_seqtty > 0 THEN

            if(v_seqtty <= rec1.REMAIN_QTTY) then
                ---TH ben nhan CK.
                secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('04').value,
                     p_txmsg.txfields('01').value, 'D', 'I', NULL, NULL,  v_seqtty, rec1.costprice, 'Y');
                ---TH ben chuyen CK.
                secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('02').value,
                     p_txmsg.txfields('01').value, 'D', 'O', NULL, NULL,  v_seqtty, rec1.costprice, 'Y');
                v_seqtty := 0;
            else
                ---TH ben nhan CK.
                secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('04').value,
                     p_txmsg.txfields('01').value, 'D', 'I', NULL, NULL,  rec1.REMAIN_QTTY, rec1.costprice, 'Y');
                ---TH ben chuyen CK.
                secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('02').value,
                     p_txmsg.txfields('01').value, 'D', 'O', NULL, NULL,  rec1.REMAIN_QTTY, rec1.costprice, 'Y');
                v_seqtty := v_seqtty-rec1.REMAIN_QTTY;
            end if;
        END IF;
    end loop;

     ELSE
        secnet_un_map(p_txmsg.txnum, p_txmsg.txdate);
---        NULL;
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
         plog.init ('TXPKS_#2239EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2239EX;
/
