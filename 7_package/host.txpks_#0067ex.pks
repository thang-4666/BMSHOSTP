SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0067ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0067EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      16/04/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0067ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_custid           CONSTANT CHAR(2) := '03';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count number;
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
-- HaiLT bo chi kich hoat tai khoan, ko kich hoat tieu khoan
/*
     select count(1) into l_count
        from (select actype from afmast
                where custid = p_txmsg.txfields('03').value
                and (p_txmsg.txfields('05').value = 'ALL'
                    or (p_txmsg.txfields('05').value <> 'ALL' and (acctno = p_txmsg.txfields('05').value or status <> 'C')))
                group by actype
                having count(1) > 1);
    if l_count > 0 then
        p_txmsg.txWarningException('-1001401').value:= cspks_system.fn_get_errmsg('-100140');
        p_txmsg.txWarningException('-1001401').errlev:= '1';
    end if;

    select count(1) into l_count
        from (select bankname, bankacctno
                from afmast
                where p_txmsg.txfields('05').value = decode(p_txmsg.txfields('05').value,'ALL',p_txmsg.txfields('05').value, acctno)
                    and custid = p_txmsg.txfields('03').value and status = 'C'
                    and bankname is not null and bankacctno is not null
             ) mst
        where exists (select 1 from afmast af where af.bankname is not null and af.bankacctno is not null
                        and mst.bankname = af.bankname and mst.bankacctno = af.bankacctno
                        and status <> 'C');

    if l_count > 0 then
        p_txmsg.txWarningException('-1001471').value:= cspks_system.fn_get_errmsg('-100147');
        p_txmsg.txWarningException('-1001471').errlev:= '1';
    end if;

    select count(1) into l_count from afmast af, cfmast cf where af.custid = cf.custid and cf.status = 'C' and af.status <> 'C' and af.custid = p_txmsg.txfields('03').value;
    if l_count > 0 then
        p_err_code := '-200010'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    --Kiem tra neu All tieu khoan thi phai co it nhat mot tai khoan dang dong
    --Neu 1 tieu khoan thi tieu khoan do phai la dang dong
    select count(1) into l_count from afmast af where af.status = 'C'
        and custid = p_txmsg.txfields('03').value
        and p_txmsg.txfields('05').value = decode(p_txmsg.txfields('05').value,'ALL',p_txmsg.txfields('05').value, af.acctno);
    if l_count <= 0 then
        p_err_code := '-200010'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
*/
  IF p_txmsg.txfields('46').value <> '<NULL>' THEN
   cspks_cfproc.pr_CFMAST_ChangeTypeCheck(p_txmsg.txfields('03').value,p_txmsg.txfields('46').value,p_err_code);
   END IF;
   If p_err_code<>'0' then
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    End if;

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
v_count number;
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
    v_count:=0;
    SELECT count(1) into v_count FROM CFMAST CF1,
        (SELECT IDCODE,CUSTTYPE FROM CFMAST WHERE CUSTID= p_txmsg.txfields('03').value) CF2
    WHERE CF1.STATUS<> 'C' and CF1.IDCODE=CF2.IDCODE and CF1.CUSTTYPE=CF2.CUSTTYPE;
    if v_count>1 then
        p_err_code:='-200020';
        plog.setendsection(pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
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
  v_newactype varchar2(10);
  v_nextcftype  varchar2(10);
  v_strCURRDATE DATE;

  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  l_OrgDesc varchar2(100);
  l_EN_OrgDesc varchar2(100);
  l_old_actype varchar2(100);
  L_fullname varchar2(600);
  l_brid varchar2(600);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
-- HaiLT bo chi kich hoat tai khoan, ko kich hoat tieu khoan
/*   if p_txmsg.txfields('05').value='ALL' then
        --Cap nhat cho toan bo tieu khoan
        for rec in
            (select acctno from afmast where custid = p_txmsg.txfields('03').value and status ='C')
        loop
            update afmast set status ='A'
            where acctno = rec.acctno and status <> 'A';
            update semast set status ='A'
            where afacctno = rec.acctno and status <> 'A';
            update cimast set status ='A'
            where acctno = rec.acctno and status <> 'A';
        end loop;
    else
        --Cap nhat cho tieu khoan da chon
        update afmast set status ='A'
        where acctno = p_txmsg.txfields('05').value and status <> 'A';
        update semast set status ='A'
        where afacctno = p_txmsg.txfields('05').value and status <> 'A';
        update cimast set status ='A'
        where acctno = p_txmsg.txfields('05').value and status <> 'A';
    end if;*/

    if p_txmsg.deltd <> 'Y' then
        if p_txmsg.txfields('08').value ='Y' then
            update cfmast
            set activests = 'Y', status = 'A'
            where custid = p_txmsg.txfields(c_custid).value;
        else
            update cfmast
            set activests = 'N', status = 'A'
            where custid = p_txmsg.txfields(c_custid).value;
        end if;
    end if;

    IF p_txmsg.txfields('46').value <> '<NULL>' THEN

       -- tao giao dich 0021
     select actype into l_old_actype from cfmast where custid = p_txmsg.txfields(c_custid).value ;

      SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='0021';

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
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='0021';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := l_brid;


      --Set cac field giao dich
      --03  CUSTID      C
        l_txmsg.txfields ('03').defname   := 'CUSTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_txmsg.txfields(c_custid).value;

      --88  CUSTODYCD    C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := p_txmsg.txfields(c_custodycd).value;

        --28  FULLNAME    C
        l_txmsg.txfields ('28').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('28').TYPE      := 'C';
        l_txmsg.txfields ('28').VALUE     := L_fullname;

        --45  ACTYPE       C
        l_txmsg.txfields ('45').defname   := 'ACTYPE';
        l_txmsg.txfields ('45').TYPE      := 'C';
        l_txmsg.txfields ('45').VALUE     := l_old_actype;

        --46  NACTYPE    C
        l_txmsg.txfields ('46').defname   := 'NACTYPE';
        l_txmsg.txfields ('46').TYPE      := 'C';
        l_txmsg.txfields ('46').VALUE     :=  p_txmsg.txfields('46').value;

        --30  DEC    C
        l_txmsg.txfields ('30').defname   := 'DEC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := l_OrgDesc;

        BEGIN
            IF txpks_#0021.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 0021: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;

            END IF;
        END;





  END IF ;








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
         plog.init ('TXPKS_#0067EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0067EX;
/
