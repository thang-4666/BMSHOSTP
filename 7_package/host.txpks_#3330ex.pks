SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3330ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3330EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      16/07/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3330ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '18';
   c_trtype           CONSTANT CHAR(2) := '31';
   c_autoid           CONSTANT CHAR(2) := '01';
   c_symbol           CONSTANT CHAR(2) := '06';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacct2          CONSTANT CHAR(2) := '04';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_trade            CONSTANT CHAR(2) := '12';
   c_amt              CONSTANT CHAR(2) := '17';
   c_inqtty           CONSTANT CHAR(2) := '13';
   c_roqtty           CONSTANT CHAR(2) := '14';
   c_regisqtty        CONSTANT CHAR(2) := '19';
   c_aqtty            CONSTANT CHAR(2) := '15';
   c_pqtty            CONSTANT CHAR(2) := '16';
   c_rqtty            CONSTANT CHAR(2) := '20';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count  NUMBER;
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
    -- check trang thai lich thuc hien quyen
    SELECT COUNT(*) INTO l_count
    FROM caschd
    WHERE autoid=p_txmsg.txfields('01').value
    AND ( status NOT IN  ('J','C','G','H') OR SUBSTR(pstatus,LENGTH(pstatus))='X');
    IF(l_count<=0) THEN
          p_err_code:='-300014';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    SELECT COUNT(*) INTO l_count
    FROM caschd
    WHERE autoid=p_txmsg.txfields('01').value
    AND (qtty-inqtty)=to_number(p_txmsg.txfields('19').value);
    IF(l_count<=0) THEN
          p_err_code:='-300068';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    -- check
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
l_strCAMASTID VARCHAR2(50);
l_balance NUMBER;
l_trade      NUMBER;
l_catype     VARCHAR2(3);
l_pbalance   NUMBER;
l_exrate  VARCHAR2(50);
l_dbl_left_exrate NUMBER;
l_dbl_right_exrate NUMBER;
l_dbl_right_rightoffrate  NUMBER;
l_dbl_left_rightoffrate NUMBER;
l_rightoffrate          VARCHAR2(250);
l_roundcitype           NUMBER;
l_qttyreceive           NUMBER;
l_aqtty                 NUMBER;
l_aamt                  NUMBER;
l_exprice               NUMBER;
l_paamt                 NUMBER;
l_pqtty                 NUMBER;
l_afacctno              VARCHAR2(10);
l_codeid                VARCHAR2(6);
l_intamt                NUMBER;
l_parvalue              NUMBER;
l_interestrate          NUMBER;
l_rqtty                 NUMBER;
l_qtty                  NUMBER;
l_amt                   NUMBER;
l_status                VARCHAR2(1);
l_autoid                NUMBER;
l_regisqtty             NUMBER;
l_optcodeid             VARCHAR2(6);
l_seacctno              VARCHAR2(20);
l_orgpbalance           NUMBER;
l_isse                  VARCHAR2(1);
l_qtty_old              NUMBER;
l_receiving              NUMBER;
l_old_amt                NUMBER;
l_isci                  VARCHAR2(1);
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

        l_strCAMASTID:=replace(p_txmsg.txfields('18').value,'.');
    l_catype:=p_txmsg.txfields('31').value;
    l_trade:=to_number(p_txmsg.txfields('12').value);
    l_qtty:=to_number(p_txmsg.txfields('14').value);-- CK? d?k mua,nhan CP
    l_qttyreceive:=to_number(p_txmsg.txfields('13').value);-- ck cho ve chung
    l_amt:=to_number(p_txmsg.txfields('17').value);-- tien cho ve
    l_aqtty:=to_number(p_txmsg.txfields('15').value);-- CK cho giam
    l_pqtty:=to_number(p_txmsg.txfields('16').value);-- CK chua DK nhan CP
    l_afacctno:=p_txmsg.txfields('04').value;
    l_autoid:=to_number(p_txmsg.txfields('01').value);
    l_rqtty:=to_number(p_txmsg.txfields('20').value);
    l_regisqtty:=to_number(p_txmsg.txfields('19').value);

        SELECT nvl(exrate,'1/1'),nvl(rightoffrate,'1/1'),nvl(ciroundtype,0),
    nvl(exprice,0),nvl(camast.parvalue,0),nvl(interestrate,0),optcodeid,
    (l_afacctno|| (CASE WHEN iswft='N' THEN nvl(camast.tocodeid,camast.codeid) ELSE sb.codeid END))
    INTO l_exrate,l_rightoffrate,l_roundcitype,
    l_exprice,l_parvalue,l_interestrate,l_optcodeid,
    l_seacctno
    FROM camast,sbsecurities sb
    WHERE camastid=l_strCAMASTID AND camast.codeid = sb.codeid ;


    SELECT isse,qtty ,status,amt,isci
    INTO l_isse,l_qtty_old,l_status,l_old_amt,l_isci
    from caschd
    WHERE autoid=l_autoid;
    --dvoi cac sk chung balance=trade
    l_balance:=l_trade;
    l_pbalance:=0;
    l_paamt:=0;
    l_aamt:=0;
    l_intamt:=0;
    l_orgpbalance:=0;-- sl quyen mua chot so huu


    l_receiving:=(l_qtty_old-(l_qtty+l_qttyreceive+l_regisqtty));


      IF l_receiving >0 AND l_optcodeid IS NOT NULL  AND NOT  cspks_cfproc.fn_check_account_mrirate(l_afacctno,l_optcodeid,l_receiving,0 )   THEN

             p_err_code:='-180064';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;




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
l_strCAMASTID VARCHAR2(50);
l_balance NUMBER;
l_trade      NUMBER;
l_catype     VARCHAR2(3);
l_pbalance   NUMBER;
l_exrate  VARCHAR2(50);
l_dbl_left_exrate NUMBER;
l_dbl_right_exrate NUMBER;
l_dbl_right_rightoffrate  NUMBER;
l_dbl_left_rightoffrate NUMBER;
l_rightoffrate          VARCHAR2(250);
l_roundcitype           NUMBER;
l_qttyreceive           NUMBER;
l_aqtty                 NUMBER;
l_aamt                  NUMBER;
l_exprice               NUMBER;
l_paamt                 NUMBER;
l_pqtty                 NUMBER;
l_afacctno              VARCHAR2(10);
l_codeid                VARCHAR2(6);
l_intamt                NUMBER;
l_parvalue              NUMBER;
l_interestrate          NUMBER;
l_rqtty                 NUMBER;
l_qtty                  NUMBER;
l_amt                   NUMBER;
l_status                VARCHAR2(1);
l_autoid                NUMBER;
l_regisqtty             NUMBER;
l_optcodeid             VARCHAR2(6);
l_seacctno              VARCHAR2(20);
l_orgpbalance           NUMBER;
l_isse                  VARCHAR2(1);
l_qtty_old              NUMBER;
l_receiving              NUMBER;
l_old_amt                NUMBER;
l_isci                  VARCHAR2(1);
p_qtty                   NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_strCAMASTID:=replace(p_txmsg.txfields('18').value,'.');
    l_catype:=p_txmsg.txfields('31').value;
    l_trade:=to_number(p_txmsg.txfields('12').value);
    l_qtty:=to_number(p_txmsg.txfields('14').value);-- CK? d?k mua,nhan CP
    l_qttyreceive:=to_number(p_txmsg.txfields('13').value);-- ck cho ve chung
    l_amt:=to_number(p_txmsg.txfields('17').value);-- tien cho ve
    l_aqtty:=to_number(p_txmsg.txfields('15').value);-- CK cho giam
    l_pqtty:=to_number(p_txmsg.txfields('16').value);-- CK chua DK nhan CP
    l_afacctno:=p_txmsg.txfields('04').value;
    l_autoid:=to_number(p_txmsg.txfields('01').value);
    l_rqtty:=to_number(p_txmsg.txfields('20').value);
    l_regisqtty:=to_number(p_txmsg.txfields('19').value);

    SELECT nvl(exrate,'1/1'),nvl(rightoffrate,'1/1'),nvl(ciroundtype,0),
    nvl(exprice,0),nvl(camast.parvalue,0),nvl(interestrate,0),optcodeid,
    (l_afacctno|| (CASE WHEN iswft='N' THEN nvl(camast.tocodeid,camast.codeid) ELSE sb.codeid END))
    INTO l_exrate,l_rightoffrate,l_roundcitype,
    l_exprice,l_parvalue,l_interestrate,l_optcodeid,
    l_seacctno
    FROM camast,sbsecurities sb
    WHERE camastid=l_strCAMASTID
    AND sb.refcodeid=nvl(camast.tocodeid,camast.codeid);
    l_dbl_left_exrate := nvl(to_number(substr(l_exrate,0,instr(l_exrate,'/') - 1)),'1');
    l_dbl_right_exrate :=nvl(to_number( substr(l_exrate,instr(l_exrate,'/') + 1,length(l_exrate))),1);
   /* l_dbl_left_devidentshares:=nvl( to_number(substr(l_devidentshares,0,instr(l_devidentshares,'/') - 1)),1);
    l_dbl_right_devidentshares:=nvl(to_number( substr(l_devidentshares,instr(l_devidentshares,'/') + 1,length(l_devidentshares))),1);
 */   l_dbl_left_rightoffrate := nvl(to_number(substr(l_rightoffrate,0,instr(l_rightoffrate,'/') - 1)),1);
    l_dbl_right_rightoffrate := nvl(to_number(substr(l_rightoffrate,instr(l_rightoffrate,'/') + 1,length(l_rightoffrate))),1);

    SELECT isse,qtty ,status,amt,isci
    INTO l_isse,l_qtty_old,l_status,l_old_amt,l_isci
    from caschd
    WHERE autoid=l_autoid;
    --dvoi cac sk chung balance=trade
    l_balance:=l_trade;
    l_pbalance:=0;
    l_paamt:=0;
    l_aamt:=0;
    l_intamt:=0;
    l_orgpbalance:=0;-- sl quyen mua chot so huu


    -- sk quyen mua va chuyen doi chon nhan CP tien
    if(l_catype='014') THEN
       l_pbalance:= TRUNC(l_trade*l_dbl_right_exrate/l_dbl_left_exrate);-- sl max cua ca dong lich
       l_balance:=TRUNC((l_qtty+l_regisqtty)*l_DBL_Left_rightoffrate / l_DBL_right_rightoffrate);-- sl da dkqm
       l_pbalance:=l_pbalance-l_balance;
       l_aamt:=l_exprice*(l_qtty+l_regisqtty);
       l_paamt:=l_exprice*l_pqtty;

       UPDATE semast SET trade=l_pbalance WHERE acctno=l_afacctno||l_optcodeid;
    ELSIF (l_catype='023') THEN
       l_balance:=trunc(l_trade-((l_qtty+l_regisqtty)*l_dbl_left_exrate/l_dbl_right_exrate),
                           l_roundcitype);
       -- PhuongHT: ghi nhan rieng phan lai
       l_intamt:=round(l_balance*l_parvalue*l_interestrate/100) ;
    ELSIF(l_catype IN ('016','015')) THEN
       l_intamt:=round(l_trade*l_parvalue*l_interestrate/100) ;
    END IF;

    -- neu tk chua pbo CK thi jam receiving
    IF (l_isse='N') THEN
      if(l_status='V' AND l_catype='023') THEN
         l_receiving:=0;
      ELSE
          l_receiving:=(l_qtty_old-(l_qtty+l_qttyreceive+l_regisqtty));
      END IF;
      UPDATE semast SET receiving=receiving-l_receiving
      WHERE acctno=l_seacctno;
      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0015',(l_qtty_old-(l_qtty+l_qttyreceive+l_regisqtty)),NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      UPDATE semast SET trade=trade-l_receiving
      WHERE acctno=l_afacctno||l_optcodeid;
      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_afacctno||l_optcodeid,'0040',(l_qtty_old-(l_qtty+l_qttyreceive+l_regisqtty)),NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    END IF;
    --chua phan bo tien thi update lai receving
    if(l_isci='N' AND l_status='S') THEN
         UPDATE cimast SET receiving =receiving- (l_qtty_old-l_amt)
         WHERE acctno=l_afacctno;

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_afacctno,'0045',(l_qtty_old-l_amt),NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


    end IF;
    if l_catype IN ('014','023') THEN
      p_qtty:=to_number(p_txmsg.txfields('14').value)+to_number(p_txmsg.txfields('16').value)+to_number(p_txmsg.txfields('13').value)+to_number(p_txmsg.txfields('20').value);
     else
       p_qtty:=to_number(p_txmsg.txfields('14').value)+to_number(p_txmsg.txfields('13').value)+to_number(p_txmsg.txfields('20').value);
    end if;
     INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
     VALUES(seq_catrflog.NEXTVAL,TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) , p_txmsg.txnum ,p_txmsg.txfields(c_camastid).value,l_afacctno||l_optcodeid,null,p_txmsg.txfields('06').value,
          null,to_number(p_txmsg.txfields('12').value),to_number(p_txmsg.txfields('17').value),p_qtty,null,p_txmsg.txfields('88').value,'N');


    UPDATE caschd SET
    trade=l_trade,qtty=l_qtty+l_qttyreceive+l_regisqtty,pqtty=l_pqtty,
    rqtty=l_rqtty, amt=l_amt,aqtty=l_aqtty,inqtty=l_qtty+l_qttyreceive,
    tqtty=l_qtty,
    balance=l_balance,pbalance=l_pbalance,paamt=l_paamt,intamt=l_intamt,
    retailbal=l_pbalance,orgpbalance=TRUNC(l_trade*l_dbl_right_exrate/l_dbl_left_exrate)
    WHERE autoid=l_autoid;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS
    ;
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
         plog.init ('TXPKS_#3330EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3330EX;
/
