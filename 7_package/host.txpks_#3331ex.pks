SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3331ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3331EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/09/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3331ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacct           CONSTANT CHAR(2) := '02';
   c_afacct2          CONSTANT CHAR(2) := '04';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_autoid           CONSTANT CHAR(2) := '09';
   c_camastid         CONSTANT CHAR(2) := '18';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_amt              CONSTANT CHAR(2) := '17';
   c_trade            CONSTANT CHAR(2) := '12';
   c_qtty             CONSTANT CHAR(2) := '13';
   c_aqtty            CONSTANT CHAR(2) := '15';
   c_pqtty            CONSTANT CHAR(2) := '16';
   c_rqtty            CONSTANT CHAR(2) := '20';
   c_isse             CONSTANT CHAR(2) := '21';
   c_isci             CONSTANT CHAR(2) := '22';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_afacctno VARCHAR2(10);
l_autoid NUMBER;
l_rafacctno VARCHAR2(10);
l_isse  VARCHAR2(10);
l_catype VARCHAR2(10);
l_status VARCHAR2(10);
l_qtty NUMBER ;
l_optcodeid VARCHAR2(10);
l_pqtty NUMBER ;
l_count NUMBER;
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


    SELECT COUNT(*) INTO l_count from caschd WHERE deltd='N' AND autoid=p_txmsg.txfields('09').value
    AND status IN ('V','S','M');
    if(l_count<=0) THEN
    p_err_code := '-300014';
    plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
    RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

     l_autoid:=p_txmsg.txfields('09').value;
     l_rafacctno:=p_txmsg.txfields('04').value;-- afacctno nhan chuyen nhuong


    SELECT schd.isse,ca.catype,schd.status,schd.qtty,NVL(ca.optcodeid,ca.codeid) optcodeid,pqtty
    INTO l_isse,l_catype,l_status,l_qtty, l_optcodeid,l_pqtty
    FROM camast ca, caschd schd, sbsecurities sb
    WHERE ca.camastid=schd.camastid
    AND schd.autoid=p_txmsg.txfields('09').value
    AND sb.refcodeid=nvl(ca.tocodeid,ca.codeid);




    SELECT COUNT(*) into l_count FROM afserisk WHERE ACTYPE =(SELECT actype FROM afmast WHERE acctno =l_rafacctno ) AND CODEID =l_optcodeid;


  IF  l_optcodeid IS NOT NULL AND l_catype IN ('014','011','021') THEN
     if txpks_prchk.fn_RoomLimitCheck(l_rafacctno, l_optcodeid,
           l_QTTY, p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
      end if;
  END IF ;

    SELECT afacctno INTO l_afacctno FROM caschd WHERE autoid=p_txmsg.txfields('09').value;
    if(l_afacctno <> p_txmsg.txfields('02').value) THEN
        p_err_code:='-300070';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
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
v_length NUMBER;
l_seacctno VARCHAR2(20);
l_isse     VARCHAR2(1);
l_receiving NUMBER;
l_status    VARCHAR2(1);
l_catype    VARCHAR2(3);
l_qtty      NUMBER;
l_sseacctno VARCHAR2(20);
l_rseacctno VARCHAR2(20);
l_safacctno VARCHAR2(10);
l_rafacctno VARCHAR2(10);
l_optcodeid VARCHAR2(6);
l_pbalance NUMBER;
l_count NUMBER;
l_sectype  semast.actype%TYPE;
l_custid afmast.custid%TYPE;
l_autoid NUMBER;
l_tradeopt NUMBER;
l_seacctnooptr varchar2(20);
l_seacctnoopts varchar2(20);
l_codeid varchar2(20);
l_pqtty NUMBER ;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_receiving:=0;
    l_tradeopt:=0;
    SELECT length(nvl(pafacctno,'')) INTO v_length from caschd WHERE autoid=p_txmsg.txfields('09').value;
    IF v_length >80 THEN
      UPDATE caschd SET pafacctno='' WHERE autoid=p_txmsg.txfields('09').value;
    END IF;
    l_rafacctno:=p_txmsg.txfields('04').value;-- afacctno nhan chuyen nhuong
    l_autoid:=p_txmsg.txfields('09').value;

    SELECT schd.isse,ca.catype,schd.status,schd.qtty,
    (schd.afacctno|| (CASE WHEN iswft='N' THEN nvl(ca.tocodeid,ca.codeid) ELSE sb.codeid END)) sseacctno,
    (p_txmsg.txfields('04').value|| (CASE WHEN iswft='N' THEN nvl(ca.tocodeid,ca.codeid) ELSE sb.codeid END)) rseacctno,
    schd.afacctno,NVL(ca.optcodeid,ca.codeid) optcodeid,
    pbalance,ca.codeid,pqtty
    INTO l_isse,l_catype,l_status,l_qtty,
    l_sseacctno,l_rseacctno,l_safacctno,l_optcodeid,l_pbalance,l_codeid,l_pqtty
    FROM camast ca, caschd schd, sbsecurities sb
    WHERE ca.camastid=schd.camastid
    AND schd.autoid=p_txmsg.txfields('09').value
    AND sb.refcodeid=nvl(ca.tocodeid,ca.codeid);
    -- update afacctno cua dong lich thanh tk nhan chuyen nhuong
    UPDATE caschd SET pafacctno=nvl(pafacctno,'')||'/'|| afacctno,afacctno=p_txmsg.txfields('04').value, ISRECEIVE='Y'
    WHERE autoid=p_txmsg.txfields('09').value;
    -- update slck receiving cua tk chuyen va nhan
    if(l_isse='N') THEN-- chua phan bo CK


  /*    if(l_catype IN ('014','011','021')) THEN
      l_receiving:=0;
       ELSIF INSTR('SGHJ',l_status) >0 THEN-- ko pai skqm va chua phan bo
      l_receiving:=l_qtty;
      END IF;*/

 /*     if(l_catype='014') THEN
      l_receiving:=l_qtty;
      ELSIF INSTR('SGHJ',l_status) >0 THEN-- ko pai skqm va chua phan bo
      l_receiving:=l_qtty;
     END IF;
*/
  if INSTR('SGHJM',l_status) >0 THEN
           l_receiving:=l_qtty;
  end if;


      IF l_catype IN ('014','011','021') THEN
         l_seacctnooptr:=   l_rafacctno|| l_optcodeid ;

                    -- kiem tra xem co tk nhan chua
          SELECT COUNT(*) INTO l_count FROM  semast
          WHERE acctno=l_seacctnooptr;
          IF(L_COUNT=0) THEN
                BEGIN
                SELECT b.setype,a.custid
                INTO l_sectype,l_custid
                FROM AFMAST A, aftype B
                WHERE  A.actype= B.actype
                AND a.ACCTNO = l_rafacctno;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
                    RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
                END;
                INSERT INTO SEMAST
                (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
                VALUES(
                l_sectype, l_custid, l_seacctnooptr,SUBSTR(l_seacctnooptr,11),l_rafacctno,
                TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                'A','Y','000', 0,0,0,0,0,0,0,0,0);

         END IF;
     END IF;

      -- su ly cho chung khoan quyen
      IF (l_catype IN ('014','011','021') AND INSTR('SGHJM',l_status) >0 ) THEN
      l_tradeopt:=l_qtty;
         l_seacctnoopts:=   l_safacctno|| l_optcodeid ;
      END IF;

    END IF;


          IF l_QTTY >0 AND l_optcodeid IS NOT NULL  AND NOT  cspks_cfproc.fn_check_account_mrirate(SUBSTR(l_seacctnoopts,1,10),l_optcodeid,l_QTTY,0 )   THEN
             p_err_code:='-180064';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        --chek room
        --(p_afacctno in varchar2, p_codeid in varchar2, p_qtty in NUMBER, p_err_code in out varchar2)


    SELECT COUNT(*) into l_count FROM afserisk WHERE ACTYPE =(SELECT actype FROM afmast WHERE acctno =l_rafacctno ) AND CODEID =l_optcodeid;


  IF  l_optcodeid IS NOT NULL AND l_catype IN ('014','011','021') THEN
     if txpks_prchk.fn_RoomLimitCheck(l_rafacctno, l_optcodeid,
           l_QTTY, p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
      end if;
  END IF ;


     if(l_tradeopt>0) THEN




       -- tru tk chuyen
          UPDATE semast
          SET trade=trade -l_tradeopt
          WHERE acctno=l_seacctnoopts;

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctnoopts,'0040',l_tradeopt,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



          UPDATE semast
          SET trade=trade +l_tradeopt
          WHERE acctno=l_seacctnooptr;

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctnooptr,'0045',l_tradeopt,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



     END IF;


    if(l_receiving>0) THEN
       -- tru tk chuyen
          UPDATE semast
          SET receiving=receiving -l_receiving
          WHERE acctno=l_sseacctno;

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_sseacctno,'0015',l_receiving,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

       -- cong tk nhan
          -- kiem tra xem co tk nhan chua
          SELECT COUNT(*) INTO l_count FROM  semast
          WHERE acctno=l_rseacctno;
          if(l_count=0) THEN
                BEGIN
                SELECT b.setype,a.custid
                INTO l_sectype,l_custid
                FROM AFMAST A, aftype B
                WHERE  A.actype= B.actype
                AND a.ACCTNO = l_rafacctno;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
                    RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
                END;
                INSERT INTO SEMAST
                (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
                VALUES(
                l_sectype, l_custid, l_rseacctno,SUBSTR(l_rseacctno,11),l_rafacctno,
                TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                'A','Y','000', 0,0,0,0,0,0,0,0,0);

          END IF;

          UPDATE semast
          SET receiving=receiving +l_receiving
          WHERE acctno=l_rseacctno;

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_rseacctno,'0016',l_receiving,NULL,l_autoid,p_txmsg.deltd,l_autoid,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    END IF;

  /*  -- neu la skqm: update luong quyen chua dki cho semast
    if(l_catype='014') THEN
    -- tk chuyen
      UPDATE semast SET trade=trade-l_receiving WHERE afacctno=l_safacctno AND codeid=l_optcodeid;
      INSERT INTO SETRAN (ACCTNO, TXNUM, TXDATE, TXCD, NAMT, CAMT, REF, DELTD,AUTOID,Acctref)
      VALUES (l_safacctno || l_optcodeid,p_txmsg.txnum,p_txmsg.txdate,'0011',l_pbalance,'',l_autoid,'N',SEQ_SETRAN.NEXTVAL,l_autoid);
    -- tk nhan
        SELECT COUNT(*) INTO l_count FROM  semast
          WHERE acctno=l_rafacctno||l_optcodeid;
          if(l_count=0) THEN
                BEGIN
                SELECT b.setype,a.custid
                INTO l_sectype,l_custid
                FROM AFMAST A, aftype B
                WHERE  A.actype= B.actype
                AND a.ACCTNO = l_rafacctno;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
                    RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
                END;
                INSERT INTO SEMAST
                (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
                VALUES(
                l_sectype, l_custid, l_rafacctno||l_optcodeid,l_optcodeid,l_rafacctno,
                TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
                'A','Y','000', 0,0,0,0,0,0,0,0,0);

          END IF;
      UPDATE semast SET trade=trade+l_receiving WHERE afacctno=l_rafacctno AND codeid=l_optcodeid;
      INSERT INTO SETRAN (ACCTNO, TXNUM, TXDATE, TXCD, NAMT, CAMT, REF, DELTD,AUTOID,acctref)
      VALUES (l_rafacctno || l_optcodeid,p_txmsg.txnum,p_txmsg.txdate,'0012',l_receiving,'',l_autoid,'N',SEQ_SETRAN.NEXTVAL,l_autoid);

    END IF;*/
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
         plog.init ('TXPKS_#3331EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3331EX;

/
