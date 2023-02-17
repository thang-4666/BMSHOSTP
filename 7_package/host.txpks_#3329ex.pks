SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3329ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3329EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      14/07/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg IN OUT tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#3329ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacct2          CONSTANT CHAR(2) := '04';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_inward           CONSTANT CHAR(2) := '03';
   c_camastid         CONSTANT CHAR(2) := '18';
   c_amt              CONSTANT CHAR(2) := '17';
   c_trade            CONSTANT CHAR(2) := '12';
   c_qtty             CONSTANT CHAR(2) := '13';
   c_rqtty            CONSTANT CHAR(2) := '14';
   c_aqtty            CONSTANT CHAR(2) := '15';
   c_pqtty            CONSTANT CHAR(2) := '16';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in OUT tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count  NUMBER;
l_isse   VARCHAR2(1);
l_isci   VARCHAR2(1);
l_catype    varchar2(10);
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
    l_isse:=p_txmsg.txfields('21').value;
    l_isci:=p_txmsg.txfields('22').value;
    SELECT COUNT(*) INTO l_count
    FROM camast
    WHERE camastid=replace(p_txmsg.txfields('18').value,'.')
    AND codeid=p_txmsg.txfields('01').value;
    --AND catype=p_txmsg.txfields('31').value;
    IF(l_count<=0) THEN
          p_err_code:='-300066';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    SELECT COUNT(*) INTO l_count
    FROM camast
    WHERE camastid=replace(p_txmsg.txfields('18').value,'.')
    AND status <> 'C';
    IF(l_count<=0) THEN
          p_err_code:='-300014';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    IF (l_isse='Y' AND l_isci ='Y') THEN
          p_err_code:='-301001';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;

    END IF;
    -- canh bao voi so luu ky da dc chot
    SELECT COUNT(*) INTO l_count
    from caschd
    WHERE deltd='N'
    AND camastid=replace(p_txmsg.txfields('18').value,'.')
    AND isreceive <> 'Y'
    AND afacctno IN (SELECT acctno FROM afmast WHERE custid=
                 (SELECT custid FROM cfmast WHERE custodycd=p_txmsg.txfields('88').value));
    if(l_count>0) THEN
        p_txmsg.txWarningException('-300067').value:= cspks_system.fn_get_errmsg('-300067');
        p_txmsg.txWarningException('-300067').errlev:= '1';
    END IF;

    BEGIN
        SELECT catype INTO l_catype
        FROM camast
        WHERE camastid=replace(p_txmsg.txfields('18').value,'.') AND codeid=p_txmsg.txfields('01').value;
    EXCEPTION WHEN OTHERS
        THEN
        l_catype := '000';
    end;
    if l_catype = '014' then
        p_err_code:='-300066';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
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
l_isse                  VARCHAR(1);
l_isci                  VARCHAR2(1);
l_pstatus               VARCHAR2(10);
l_count                 NUMBER(10);
l_optcodeid             VARCHAR2(6);
l_seacctno              VARCHAR2(20);
l_orgpbalance           NUMBER(20);
l_sectype  semast.actype%TYPE;
l_custid afmast.custid%TYPE;
l_receiving             NUMBER;
l_autoid                NUMBER;
l_orgcodeid               VARCHAR2(6);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    BEGIN
         l_autoid:=SEQ_CASCHD.NEXTVAL;
    SELECT catype,codeid INTO l_catype,l_orgcodeid
    FROM camast
    WHERE camastid=replace(p_txmsg.txfields('18').value,'.') AND codeid=p_txmsg.txfields('01').value;
    EXCEPTION WHEN OTHERS
        THEN
        l_catype := '000';
    end;
    l_strCAMASTID:=replace(p_txmsg.txfields('18').value,'.');
    ---l_catype:=p_txmsg.txfields('31').value;
    l_trade:=to_number(p_txmsg.txfields('12').value);
    l_qtty:=to_number(p_txmsg.txfields('14').value);-- CK? d?k mua,nhan CP
    l_qttyreceive:=to_number(p_txmsg.txfields('13').value);-- ck cho ve chung
    l_amt:=to_number(p_txmsg.txfields('17').value);-- tien cho ve
    l_aqtty:=to_number(p_txmsg.txfields('15').value);-- CK cho giam
    l_pqtty:=to_number(p_txmsg.txfields('16').value);-- CK chua DK nhan CP
    l_afacctno:=p_txmsg.txfields('04').value;
    l_codeid:=p_txmsg.txfields('01').value;
    l_rqtty:=to_number(p_txmsg.txfields('20').value);
    l_isse:=p_txmsg.txfields('21').value;
    l_isci:=p_txmsg.txfields('22').value;
    l_pstatus:=NULL;
    SELECT nvl(exrate,'1/1'),nvl(rightoffrate,'1/1'),nvl(ciroundtype,0),
    nvl(exprice,0),nvl(camast.parvalue,0),nvl(interestrate,0),camast.status,optcodeid,
    (l_afacctno|| (CASE WHEN iswft='N' THEN nvl(camast.tocodeid,camast.codeid) ELSE sb.codeid END))
    INTO l_exrate,l_rightoffrate,l_roundcitype,
    l_exprice,l_parvalue,l_interestrate,l_status,l_optcodeid,
    l_seacctno
    FROM camast, sbsecurities sb
    WHERE camastid=l_strCAMASTID
    AND sb.refcodeid=nvl(camast.tocodeid,camast.codeid);
    l_dbl_left_exrate := nvl(to_number(substr(l_exrate,0,instr(l_exrate,'/') - 1)),'1');
    l_dbl_right_exrate :=nvl(to_number( substr(l_exrate,instr(l_exrate,'/') + 1,length(l_exrate))),1);
   /* l_dbl_left_devidentshares:=nvl( to_number(substr(l_devidentshares,0,instr(l_devidentshares,'/') - 1)),1);
    l_dbl_right_devidentshares:=nvl(to_number( substr(l_devidentshares,instr(l_devidentshares,'/') + 1,length(l_devidentshares))),1);
 */   l_dbl_left_rightoffrate := nvl(to_number(substr(l_rightoffrate,0,instr(l_rightoffrate,'/') - 1)),1);
    l_dbl_right_rightoffrate := nvl(to_number(substr(l_rightoffrate,instr(l_rightoffrate,'/') + 1,length(l_rightoffrate))),1);

    --dvoi cac sk chung balance=trade
    l_balance:=l_trade;
    l_pbalance:=0;
    l_paamt:=0;
    l_aamt:=0;
    l_intamt:=0;
    l_orgpbalance:=0;-- sl quyen mua chot so huu

    SELECT COUNT(*) INTO l_count
    FROM semast WHERE acctno= l_afacctno||l_optcodeid;
     IF l_count  = 0 THEN
        BEGIN
             SELECT b.setype,a.custid
             INTO l_sectype,l_custid
             FROM AFMAST A, aftype B
             WHERE  A.actype= B.actype
             AND a.ACCTNO = l_afacctno;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
         END;
         INSERT INTO SEMAST
         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
         VALUES(
         l_sectype, l_custid, l_afacctno||l_optcodeid,l_optcodeid,l_afacctno,
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
        END if;


    IF(l_STATUS IN ('J','G','H','I')) THEN
                l_status:='S';
    END IF;

    if(l_STATUS='B') THEN -- dvoi cac sk ko co so du ck
      if(l_catype IN ('014','023') )THEN
            l_status:='V';
      ELSE
            l_status:='S';
      END IF;
      UPDATE camast SET status=l_status WHERE camastid=l_strCAMASTID;
    END IF;
    if(l_isse='Y') THEN -- da phan bo CK
      l_status:='H';
      l_pstatus:='X';
    ELSE-- chua pbo CK thi pai cong RECEIVING cho ck se dc nhan ve o buoc 3351
    -- kiem tra xem co tk semast chua
    SELECT COUNT(*) INTO l_count
    FROM semast WHERE acctno=l_seacctno;
    if(l_count=0) THEN
    BEGIN
             SELECT b.setype,a.custid
             INTO l_sectype,l_custid
             FROM AFMAST A, aftype B
             WHERE  A.actype= B.actype
             AND a.ACCTNO = l_afacctno;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
         END;
         INSERT INTO SEMAST
         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
         VALUES(
         l_sectype, l_custid, l_seacctno,substr(l_seacctno,11),l_afacctno,
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
    END IF;
     -- neu da lam 3340
     IF (l_status='V' AND l_catype='023') THEN
       l_receiving:=0;
     ELSE
       l_receiving:=l_qtty+l_qttyreceive;
     END IF;


     UPDATE semast
     SET receiving=receiving + l_receiving
     WHERE acctno=l_seacctno;
     -- lay truoc ja tri autoid cho caschd dc sinh de lam ref cho report

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0016',l_receiving,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    -- nhan so du cho chung khoan quyen
     IF  l_catype IN ('014','021','011') THEN
     UPDATE semast
     SET trade=trade + l_receiving
     WHERE acctno=l_afacctno||l_optcodeid;

     INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
     VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_afacctno||l_optcodeid,'0045',l_receiving,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

     END IF;


    END IF;
    if(l_isci='Y') THEN -- da phan bo tien
      l_status:='G';
      l_pstatus:='X';
    ELSE
      if(l_status ='S') THEN
         UPDATE cimast SET receiving =receiving+l_amt WHERE acctno=l_afacctno;

        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_afacctno,'0046',l_amt,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      END IF;
    END IF;
    -- sk quyen mua va chuyen doi chon nhan CP tien
    if(l_catype='014') THEN
       l_pbalance:= TRUNC(l_trade*l_dbl_right_exrate/l_dbl_left_exrate);-- sl max cua ca dong lich
       l_balance:=TRUNC(l_qtty*l_DBL_Left_rightoffrate / l_DBL_right_rightoffrate);-- sl da dkqm
       l_pbalance:=l_pbalance-l_balance;
       l_aamt:=l_exprice*l_qtty;
       l_paamt:=l_exprice*l_pqtty;
       -- insert semast cho CK quyen
      Select Count(1) INTO l_count
      from semast se
      Where afacctno=l_afacctno AND codeid=l_optcodeid;

      IF l_count  = 0 THEN
        BEGIN
             SELECT b.setype,a.custid
             INTO l_sectype,l_custid
             FROM AFMAST A, aftype B
             WHERE  A.actype= B.actype
             AND a.ACCTNO = l_afacctno;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
         END;
         INSERT INTO SEMAST
         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
         VALUES(
         l_sectype, l_custid, l_afacctno||l_optcodeid,l_optcodeid,l_afacctno,
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,l_pbalance,0,0,0,0,0,0,0);

/*      ELSE
          UPDATE semast SET trade=trade+l_pbalance WHERE acctno= l_afacctno||l_optcodeid;*/

      END IF;
      -- end of insert semast cho CK quyen
    ELSIF (l_catype='023') THEN
       l_balance:=trunc(l_trade-(l_qtty*l_dbl_left_exrate/l_dbl_right_exrate),l_roundcitype);
       -- PhuongHT: ghi nhan rieng phan lai
       l_intamt:=round(l_balance*l_parvalue*l_interestrate/100) ;

    ELSIF(l_catyPe IN ('016','015')) THEN
       l_intamt:=round(l_trade*l_parvalue*l_interestrate/100) ;
    END IF;


    INSERT INTO caschd
  (AUTOID, CAMASTID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS, AFACCTNO,
   CODEID, EXCODEID, DELTD, PSTATUS, REFCAMASTID, RETAILSHARE, DEPOSIT,
   REQTTY, REAQTTY, RETAILBAL, PBALANCE, PQTTY, PAAMT, COREBANK, ISCISE,
   DFQTTY, ISCI, ISSE, ISRO, TQTTY, TRADE, INBALANCE, OUTBALANCE,
   PITRATEMETHOD, ISEXEC, NMQTTY, DFAMT, INTAMT, RQTTY, RORETAILBAL,
   SENDPBALANCE, SENDQTTY, SENDAQTTY, SENDAMT, ISRECEIVE,INQTTY,ORGPBALANCE)
   VALUES
  (l_autoid, l_strCAMASTID, l_balance,(l_qtty+l_qttyreceive), l_amt,
    l_aqtty, 0, l_status, l_afacctno, l_codeid,
   l_codeid, 'N',l_pstatus , 0, '', '', 0, 0, l_pbalance, l_pbalance, l_pqtty, l_paamt, 'N', '',
    0, l_isci, l_isse,
   'N', l_qtty, l_trade, 0, 0, '##', 'Y', 0, 0, l_intamt, l_rqtty, 0, 0, 0, 0, 0, 'Y',(l_qtty+l_qttyreceive),l_balance+l_pbalance);

    --ngoc.vu edit VCBSDEPII-227
   /*INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
   VALUES(seq_catrflog.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,l_strCAMASTID,l_afacctno||l_orgcodeid,NULL,l_orgcodeid,NULL,l_balance,l_amt,l_qtty,p_txmsg.txfields('88').value,NULL,'N');
*/
   INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
   VALUES(seq_catrflog.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,l_strCAMASTID,l_afacctno||l_orgcodeid,NULL,l_orgcodeid,NULL,to_number(p_txmsg.txfields('12').value),l_amt,
          p_txmsg.txfields('14').value+p_txmsg.txfields('16').value+l_qttyreceive+l_rqtty,p_txmsg.txfields('88').value,NULL,'N');

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
         plog.init ('TXPKS_#3329EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3329EX;
/
