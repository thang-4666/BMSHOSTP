SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2200ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2200EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2200ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_licensedate      CONSTANT CHAR(2) := '95';
   c_license          CONSTANT CHAR(2) := '92';
   c_licenseplace     CONSTANT CHAR(2) := '96';
   c_tamt             CONSTANT CHAR(2) := '08';
   c_amt              CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
   c_custid           CONSTANT CHAR(2) := '05';
   c_fullnameauth     CONSTANT CHAR(2) := '16';
   c_iddateauth       CONSTANT CHAR(2) := '19';
   c_idcodeauth       CONSTANT CHAR(2) := '17';
   c_idplaceauth      CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '04';
   c_securitiesname   CONSTANT CHAR(2) := '12';
   c_phone            CONSTANT CHAR(2) := '93';
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

    l_mrrate number;
    l_mrirate number;
    l_marginrate number;
    l_symbol varchar2(50);
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

    --Check xem co tieu khoan nao bi call khong
    if not cspks_cfproc.pr_check_Account_Call(p_txmsg.txfields('88').value) then
        p_err_code := '-200900';
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    --check ma dot phat hanh doi voi ck WFT
    select symbol into l_symbol from sbsecurities where codeid = p_txmsg.txfields('01').value;
    if instr(l_symbol,'_WFT') > 0 and p_txmsg.txfields('77').value is null then
        p_err_code := '-150016';
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    --check chi cho nhap 1 loai CK
    if p_txmsg.txfields('10').value > 0 and p_txmsg.txfields('14').value > 0 then
       p_err_code := '-200112';
       RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    /*select idcode, idexpired into l_leader_license, l_leader_idexpired
    from cfmast cf, afmast af
    where cf.custid = af.custid
    and af.acctno = p_txmsg.txfields(c_afacctno).value;

    select idcode, idexpired into l_member_license, l_member_idexpired
    from cfmast where idcode = p_txmsg.txfields(c_license).value and status <> 'C';

    IF l_leader_idexpired < p_txmsg.txdate THEN --leader expired
        l_leader_expired:=true;
    END IF;

    if l_leader_license <> l_member_license or l_leader_idexpired <> l_member_idexpired then
        if l_member_idexpired < p_txmsg.txdate then
            l_member_expired:=true;
        end if;
    end if;


    if l_leader_expired = true and l_member_expired = true then
        p_txmsg.txWarningException('-2002091').value:= cspks_system.fn_get_errmsg('-200209');
        p_txmsg.txWarningException('-2002091').errlev:= '1';
    else
        if l_leader_expired = true and l_member_expired = false then
            p_txmsg.txWarningException('-2002081').value:= cspks_system.fn_get_errmsg('-200208');
            p_txmsg.txWarningException('-2002081').errlev:= '1';
        elsif l_leader_expired = false and l_member_expired = true then
            p_txmsg.txWarningException('-2002071').value:= cspks_system.fn_get_errmsg('-200207');
            p_txmsg.txWarningException('-2002071').errlev:= '1';
        end if;
    end if;
*/
IF P_TXMSG.deltd <> 'Y' THEN
                      select nvl(max(rsk.mrratiorate * least(rsk.mrpricerate,se.margincallprice) / 100),0)
                          into l_mrrate
                      from afserisk rsk, afmast af, aftype aft, mrtype mrt, securities_info se
                      where af.actype = rsk.actype and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T' and aft.istrfbuy = 'N'
                      and af.acctno = p_txmsg.txfields('02').value and rsk.codeid = p_txmsg.txfields('01').value and rsk.codeid = se.codeid;

                      if l_mrrate > 0 then -- check them khi chuyen chung khoan di, tai san con lai phai dam bao ty le.
                          select round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) -
                          ci.trfbuyamt - ci.ramt-CI.CIDEPOFEEACR-CI.DEPOFEEAMT>=0 then 100000
                                 -- else least( greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0), af.mrcrlimitmax - dfodamt)
                                   else  greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0)
                                      / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt -
                                      ci.ramt-CI.CIDEPOFEEACR-CI.DEPOFEEAMT) end),4) * 100 MARGINRATE,
                                  af.mrirate
                                      into l_marginrate, l_mrirate
                          from afmast af, cimast ci, v_getsecmarginratio sec
                          where af.acctno = ci.acctno and af.acctno = sec.afacctno(+)
                          and af.acctno = p_txmsg.txfields('02').value;

                          if l_marginrate < l_mrirate then
                              p_err_code:='-180064';
                              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                              RETURN errnums.C_BIZ_RULE_INVALID;
                          end if;
                      end if;
  END IF;
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
    l_Count number;
    l_RefTxnum VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_RefTxnum := to_char(p_txmsg.busdate, systemnums.C_DATE_FORMAT) || p_txmsg.txnum;

    If p_txmsg.deltd <> 'Y' THEN
        Begin
            SELECT Count(1) Into l_Count FROM SEWITHDRAWDTL WHERE TXDATETXNUM= l_RefTxnum;
            EXCEPTION When Others Then l_Count := 0;
        END;
        If l_Count <> 0 Then
            UPDATE SEWITHDRAWDTL SET WITHDRAW = p_txmsg.txfields('10').value,BLOCKWITHDRAW = p_txmsg.txfields('14').value, STATUS = 'P' WHERE TXDATETXNUM= l_RefTxnum;
        Else
            INSERT INTO SEWITHDRAWDTL (TXDATE, ACCTNO, CODEID, AFACCTNO, STATUS, PRICE, WITHDRAW,BLOCKWITHDRAW, DELTD, TXNUM, TXDATETXNUM, REFERENCEID)
            VALUES (TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),
                    p_txmsg.txfields('03').value,
                    p_txmsg.txfields('01').value,
                    p_txmsg.txfields('02').value, 'P',
                    p_txmsg.txfields('09').value,
                    p_txmsg.txfields('10').value,
                    p_txmsg.txfields('14').value, 'N',
                    p_txmsg.txnum, l_RefTxnum,
                    p_txmsg.txfields('77').value);
        End If;

    Else

        Begin
            SELECT Count(1) Into l_Count FROM SEWITHDRAWDTL WHERE TXDATETXNUM= l_RefTxnum;
            EXCEPTION When Others Then l_Count := 0;
        END;
        If l_Count <> 0 Then
            UPDATE SEWITHDRAWDTL SET DELTD='Y' WHERE STATUS = 'P' AND DELTD = 'N' AND TXDATETXNUM = l_RefTxnum;
        End If;

    End If;
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
         plog.init ('TXPKS_#2200EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2200EX;
/
