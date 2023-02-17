SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2266ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2266EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      27/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2266ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '05';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_symbol           CONSTANT CHAR(2) := '07';
   c_trade            CONSTANT CHAR(2) := '10';
   c_blocked          CONSTANT CHAR(2) := '06';
   c_caqtty           CONSTANT CHAR(2) := '13';
   c_qtty             CONSTANT CHAR(2) := '12';
   c_recustodycd      CONSTANT CHAR(2) := '23';
   c_recustname       CONSTANT CHAR(2) := '24';
   c_desc             CONSTANT CHAR(2) := '30';
   c_codeid           CONSTANT CHAR(2) := '01';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_status VARCHAR2(1);
v_OUTWARD VARCHAR2(3);
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

      SELECT OUTWARD INTO v_OUTWARD FROM SESENDOUT WHERE autoid= p_txmsg.txfields('18').value;
      if v_OUTWARD = systemnums.C_COMPANYCD then
        select nvl(status, '') into v_status from afmast where acctno = p_txmsg.txfields('55').value;
        IF INSTR('A',v_status)=0 THEN
            p_err_code:='-200010';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
          END IF;
     END IF;

     --check k thuc hien 1 gd 2 lan
    select count(1) into l_count from sesendout where autoid= p_txmsg.txfields('18').value and status='C';
    if L_COUNT > 0 then
       p_err_code := '-100778'; -- Pre-defined in DEFERROR table
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
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
l_count NUMBER(20);
l_trade NUMBER(20);
l_blocked NUMBER(20);
l_caqtty NUMBER(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_trade:=p_txmsg.txfields('10').value;
    l_blocked:=p_txmsg.txfields('06').value;
    l_caqtty:=p_txmsg.txfields('13').value;
    if(p_txmsg.deltd <> 'Y') THEN
        BEGIN
           SELECT COUNT(*) INTO L_count
           FROM sesendout
           WHERE autoid=p_txmsg.txfields('18').value
           AND ((strade < l_trade) OR(sblocked<l_blocked) OR(scaqtty<l_caqtty))
           AND deltd='N';
        EXCEPTION WHEN OTHERS THEN
                      p_err_code:='-200402';
                      plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
         END;
       IF(l_count >0) THEN
          p_err_code := '-200402'; -- Pre-defined in DEFERROR table
          plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
          RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;
    ELSE -- xoa jao dich
       BEGIN
             SELECT COUNT(*) INTO L_count
             FROM sesendout
             WHERE autoid=p_txmsg.txfields('18').value
             AND ((ctrade < l_trade) OR(cblocked<l_blocked) OR(ccaqtty<l_caqtty))
             AND deltd='N';
         EXCEPTION WHEN OTHERS THEN
                    p_err_code:='-200404';
                    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
         END;
         IF(l_count >0) THEN
            p_err_code := '-200404'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
    END IF;
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
l_trade NUMBER(20);
l_blocked NUMBER(20);
l_caqtty NUMBER(20);
l_price NUMBER(20);
l_codeid varchar2(20);
v_OUTWARD varchar2(10);
v_count number;

l_sectype  semast.actype%TYPE;
l_custid afmast.custid%TYPE;
l_afacctno afmast.acctno%TYPE;
l_semastcheck_arr txpks_check.semastcheck_arrtype;
l_sewithdrawcheck_arr txpks_check.sewithdrawcheck_arrtype;
l_avlsewithdraw apprules.field%TYPE;
l_tradeapp apprules.field%TYPE;
l_BLOCKEDapp apprules.field%TYPE;


BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
      plog.error (pkgctx, 'xoa update'||p_txmsg.deltd);
    l_trade:=p_txmsg.txfields('10').value;
    l_blocked:=p_txmsg.txfields('06').value;
    l_caqtty:=p_txmsg.txfields('13').value;
    select max(price), max(codeid) into l_price, l_codeid from sesendout where autoid= p_txmsg.txfields('18').value;
    if(p_txmsg.deltd <> 'Y') THEN

        UPDATE sesendout
        SET strade=strade-l_trade ,sblocked=sblocked-l_blocked, scaqtty=scaqtty-l_caqtty,
        ctrade=ctrade+l_trade ,cblocked=cblocked+l_blocked, ccaqtty=ccaqtty+l_caqtty,
        status='C',id2266=  to_char(p_txmsg.txdate,'dd/mm/rrrr')||p_txmsg.txnum
        WHERE autoid= p_txmsg.txfields('18').value;
                -----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
  --  secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('02').value,
  --           l_codeid, 'D', 'O', NULL, NULL, l_trade + l_blocked , l_price, 'Y');

        SELECT OUTWARD INTO v_OUTWARD FROM SESENDOUT WHERE autoid= p_txmsg.txfields('18').value;
        if v_OUTWARD = systemnums.C_COMPANYCD then
            select count(*) into v_count from semast where acctno = p_txmsg.txfields('55').value || p_txmsg.txfields('01').value and status in ('A','N');
            if v_count = 0 then
                SELECT b.setype,a.custid
                 INTO l_sectype,l_custid
                 FROM AFMAST A, aftype B
                 WHERE  A.actype= B.actype
                 AND a.ACCTNO = p_txmsg.txfields('55').value;


                 INSERT INTO SEMAST
                 (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                 COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
                 VALUES(
                 l_sectype, l_custid, p_txmsg.txfields('55').value || p_txmsg.txfields('01').value,p_txmsg.txfields('01').value,p_txmsg.txfields('55').value,
                 TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                 TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                 'A','Y','000', 0,0,0,0,0,0,0,0,0);

            end if;

            update semast set trade = trade + ROUND(p_txmsg.txfields('10').value,0), BLOCKED = BLOCKED +  ROUND(p_txmsg.txfields('06').value,0)
            where acctno = p_txmsg.txfields('55').value || p_txmsg.txfields('01').value;

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('55').value || p_txmsg.txfields('01').value,'0012',ROUND(p_txmsg.txfields('10').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('55').value || p_txmsg.txfields('01').value,'0043',ROUND(p_txmsg.txfields('06').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        end if;

                   UPDATE caschd SET sendpbalance=sendpbalance-sendpbalance,
                                     sendqtty=sendqtty-sendqtty,
                                     sendaqtty=sendaqtty-sendaqtty,sendamt=sendamt-sendamt,
                                     cutpbalance=cutpbalance+sendpbalance,
                                     cutqtty=cutqtty+sendqtty,
                                     cutaqtty=cutaqtty+sendaqtty,cutamt=cutamt+sendamt
                    WHERE  afacctno=p_txmsg.txfields('02').value and codeid =p_txmsg.txfields('01').value and deltd <>'Y' AND status ='O';


    ELSE

        UPDATE caschd SET sendpbalance=sendpbalance+sendpbalance,
                                     sendqtty=sendqtty+sendqtty,
                                     sendaqtty=sendaqtty+sendaqtty,sendamt=sendamt+sendamt,
                                     cutpbalance=cutpbalance-sendpbalance,
                                     cutqtty=cutqtty-sendqtty,
                                     cutaqtty=cutaqtty-sendaqtty,cutamt=cutamt-sendamt
                    WHERE  afacctno=p_txmsg.txfields('02').value and codeid =p_txmsg.txfields('01').value and deltd <>'Y' AND status ='O';

        --Kiem tra sl du cho phep xoa hay khong
         l_SEWITHDRAWcheck_arr := txpks_check.fn_SEWITHDRAWcheck( p_txmsg.txfields('55').value || p_txmsg.txfields('01').value ,'SEWITHDRAW','ACCTNO');
         l_AVLSEWITHDRAW := l_SEWITHDRAWcheck_arr(0).AVLSEWITHDRAW;
         --Ck trade
         IF NOT (to_number(l_AVLSEWITHDRAW) >= to_number(p_txmsg.txfields('10').value)) THEN
            p_err_code := '-900017';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
         l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck( p_txmsg.txfields('55').value || p_txmsg.txfields('01').value ,'SEMAST','ACCTNO');
         l_TRADEapp := l_SEMASTcheck_arr(0).TRADE;
         IF NOT (to_number(l_TRADEapp) >= to_number(p_txmsg.txfields('10').value)) THEN
            p_err_code := '-900017';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
         --Ck blocked
         l_BLOCKEDapp := l_SEMASTcheck_arr(0).BLOCKED;
         IF NOT (to_number(l_BLOCKEDapp) >= to_number(p_txmsg.txfields('06').value)) THEN
             p_err_code := '-900040';
             plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

        UPDATE sesendout
        SET strade=strade+l_trade ,sblocked=sblocked+l_blocked, scaqtty=scaqtty+l_caqtty,
        ctrade=ctrade-l_trade ,cblocked=cblocked-l_blocked, ccaqtty=ccaqtty-l_caqtty,
        status='S',id2266=''
        WHERE autoid= p_txmsg.txfields('18').value;

    secnet_un_map(p_txmsg.txnum, p_txmsg.txdate);
         plog.error (pkgctx, 'xoa update khi xoa'||p_txmsg.deltd);
        SELECT OUTWARD INTO v_OUTWARD FROM SESENDOUT WHERE autoid= p_txmsg.txfields('18').value;
        if v_OUTWARD = systemnums.C_COMPANYCD then
            select count(*) into v_count from semast where acctno = p_txmsg.txfields('55').value || p_txmsg.txfields('01').value and status in ('A');
            if v_count > 0 then
                update semast set trade = trade - ROUND(p_txmsg.txfields('10').value,0), BLOCKED = BLOCKED -  ROUND(p_txmsg.txfields('06').value,0)
                 where acctno = p_txmsg.txfields('55').value || p_txmsg.txfields('01').value and status in ('A');
                 UPDATE SETRAN SET DELTD ='Y' WHERE TXNUM = p_txmsg.txnum AND TXDATE =  TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
            else
                 p_err_code := '-900019'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;


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
         plog.init ('TXPKS_#2266EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2266EX;
/
