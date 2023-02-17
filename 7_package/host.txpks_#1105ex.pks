SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#1105EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1105EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      17/01/2017     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#1105EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '00';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_fullname         CONSTANT CHAR(2) := '64';
   c_address          CONSTANT CHAR(2) := '65';
   c_license          CONSTANT CHAR(2) := '69';
   c_iddate           CONSTANT CHAR(2) := '67';
   c_idplace          CONSTANT CHAR(2) := '68';
   c_ioro             CONSTANT CHAR(2) := '09';
   c_$feecd           CONSTANT CHAR(2) := '66';
   c_castbal          CONSTANT CHAR(2) := '89';
   c_amt              CONSTANT CHAR(2) := '10';
   c_percent          CONSTANT CHAR(2) := '23';
   c_dvatrate         CONSTANT CHAR(2) := '21';
   c_dvatamt          CONSTANT CHAR(2) := '22';
   c_realamt          CONSTANT CHAR(2) := '25';
   c_feeamt           CONSTANT CHAR(2) := '11';
   c_vatamt           CONSTANT CHAR(2) := '12';
   c_trfamt           CONSTANT CHAR(2) := '13';
   c_bankbalance      CONSTANT CHAR(2) := '14';
   c_bankavlbal       CONSTANT CHAR(2) := '15';
   c_benefcustname    CONSTANT CHAR(2) := '82';
   c_benefacct        CONSTANT CHAR(2) := '81';
   c_receivlicense    CONSTANT CHAR(2) := '83';
   c_benefacct        CONSTANT CHAR(2) := '18';
   c_receividplace    CONSTANT CHAR(2) := '96';
   c_receividdate     CONSTANT CHAR(2) := '95';
   c_refid            CONSTANT CHAR(2) := '79';
   c_bankid           CONSTANT CHAR(2) := '05';
   c_benefbank        CONSTANT CHAR(2) := '80';
   c_citybank         CONSTANT CHAR(2) := '84';
   c_cityef           CONSTANT CHAR(2) := '85';
   c_desc             CONSTANT CHAR(2) := '30';
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

    l_baldefovd apprules.field%TYPE;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_holdbalance apprules.field%TYPE;
    v_balance   NUMBER;
    v_bchsts    varchar2(4);
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

    l_leader_expired:= false;
    l_member_expired:= false;
    if p_txmsg.deltd <> 'Y' THEN
        --Canh bao neu GD su dung tien ung truoc
        BEGIN
            SELECT nvl(bchsts, 'N') INTO v_bchsts FROM sbbatchsts WHERE bchdate = getcurrdate AND bchmdl = 'SAAFINDAYPROCESS';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_bchsts := 'N';
        END;
        IF v_bchsts = 'Y' then
            SELECT balance INTO v_balance FROM cimast ci WHERE ci.acctno = p_txmsg.txfields('03').value;
            IF p_txmsg.tlid <> '0000' AND p_txmsg.tlid <> '6868' AND p_txmsg.txfields('10').value > v_balance THEN
                p_txmsg.txWarningException('-4001411').value:= cspks_system.fn_get_errmsg('-400141');
                p_txmsg.txWarningException('-4001411').errlev:= '1';
            END IF;
        END IF;
        --Kiem tra neu tai khoan phu corebank, khong cho chuyen tien tren phan tien Hold
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');
        l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
        l_holdbalance:=l_CIMASTcheck_arr(0).HOLDBALANCE;
      --  PLOG.error(pkgctx,'l_BALDEFOVD: ' || L_BALDEFOVD ||',13: '|| p_txmsg.txfields('13').value);
        IF NOT (to_number(l_BALDEFOVD - l_holdbalance) >= to_number(p_txmsg.txfields('13').value)) THEN
            p_err_code := '-400110';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;
    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');

    -- HaiLT them Insert lai~ moi' vao CIINTTRAN, gd giam tien nen - so tien
    if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
        cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, p_txmsg.txfields('03').value, -p_txmsg.txfields('10').value, p_err_code);
        if p_err_code <> 0 then
            p_err_code := '-400050';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

    end if;

    if not cspks_cfproc.pr_check_Account_Call(p_txmsg.txfields('88').value) then
        p_err_code := '-200900';
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
    l_emaillst VARCHAR2(250);
    l_data_source varchar2(2000);
    l_custname varchar2(300);
    l_cfcustodycd varchar2(50);
    l_cffullname varchar2(50);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    IF CSPKS_CIPROC.fn_GenRemittanceTrans(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    if p_txmsg.deltd <> 'Y' then

        select cfcustodycd, cffullname
            into l_cfcustodycd, l_cffullname
        from tltx where tltxcd = p_txmsg.tltxcd;
        --05/04/2016, TruongLD Add, xu ly cap nhat lai cfcustodycd va cffullname trong tllog doi voi GD ko qua code VB
        If length(l_cfcustodycd) > 0 and l_cfcustodycd <> '##' Then
            Update tllog
                set cfcustodycd = p_txmsg.txfields(l_cfcustodycd).value
            where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);
        End If;

        If length(l_cffullname) > 0 and l_cffullname <> '##' Then
            Update tllog
                set cffullname = p_txmsg.txfields(l_cffullname).value
            where txnum = p_txmsg.txnum and txdate = to_date(p_txmsg.txdate,systemnums.c_date_format);
        End If;
        --End TruongLD


        INSERT INTO CICUSTWITHDRAW (AUTOID,AFACCTNO,REF,TXNUM,TXDATE,AMT,TXDESC)
        VALUES(seq_cicustwithdraw.nextval,p_txmsg.txfields(c_acctno).value,p_txmsg.txfields(c_refid).value,p_txmsg.txnum,p_txmsg.txdate,to_number(p_txmsg.txfields(c_amt).value),p_txmsg.txdesc);

        if SUBSTR2(p_txmsg.txnum,1,2) in (systemnums.C_FO_PREFIXED,systemnums.C_OL_PREFIXED) then

            select VARVALUE into l_emaillst
            from sysvar
            where varname='EMAILONLTRANF' and grname='SYSTEM';

            FOR rec_EMAIL IN (
                        SELECT REGEXP_SUBSTR (l_emaillst,
                                         '[^,]+',
                                         1,
                                         LEVEL)
                             TXT
                        FROM DUAL
                        CONNECT BY REGEXP_SUBSTR (l_emaillst,
                                         '[^,]+',
                                         1,
                                         LEVEL)
                             IS NOT NULL)
            LOOP
                /*l_datasourcesms:='select ''Thong bao chuyen tien vuot han muc: KH '|| l_custname ||', TK CK '
                                  || l_custodycd ||' chuyen so tien '|| ltrim(to_char(l_amt, '9,999,999,999,999,999'))
                                  ||' den ngan hang ' || l_bank || ' '' detail from dual';*/
                select fullname into l_custname
                from cfmast
                where custodycd=p_txmsg.txfields('88').value
                    and rownum<=1;

                l_data_source:='select '''|| p_txmsg.txfields('88').value||''' CUSTODYCD, '''|| l_custname ||''' CUSTNAME,     '''
                            || p_txmsg.txfields('03').value||''' ACCTNO, '''|| trim(to_char(p_txmsg.txfields('10').value, '9,999,999,999,999,999'))||''' AMT,     '''
                            || p_txmsg.txfields('81').value||''' BENEFACCT, '''|| p_txmsg.txfields('80').value||''' BENEFBANK '
                            ||' from dual';
                nmpks_ems.InsertEmailLog(trim(rec_EMAIL.TXT), '218E', l_data_source, p_txmsg.txfields('03').value);
            END LOOP;

        end if;

    else
        DELETE CICUSTWITHDRAW WHERE TXNUM = p_txmsg.txnum AND TXDATE = p_txmsg.txdate;
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
         plog.init ('TXPKS_#1105EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1105EX;
/
