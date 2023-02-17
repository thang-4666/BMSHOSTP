SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#2225EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2225EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      25/03/2015     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#2225EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_fullname         CONSTANT CHAR(2) := '08';
   c_symbol           CONSTANT CHAR(2) := '09';
   c_tradedate        CONSTANT CHAR(2) := '10';
   c_depotype         CONSTANT CHAR(2) := '11';
   c_trade            CONSTANT CHAR(2) := '14';
   c_blocked          CONSTANT CHAR(2) := '15';
   c_txdateref        CONSTANT CHAR(2) := '23';
   c_txnumref         CONSTANT CHAR(2) := '24';
   c_description      CONSTANT CHAR(2) := '30';
   c_note             CONSTANT CHAR(2) := '31';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
L_ISWFT CHar(1);
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
    -- check xem dong log da dc chuyen sang luu ky chua
    IF TO_DATE(P_TXMSG.txfields(10).VALUE,'DD/MM/RRRR')=  P_TXMSG.TXDATE THEN
       SELECT ISWFT INTO L_ISWFT FROM SEDEPOWFTLOG
       WHERE TXNUM=P_TXMSG.txfields(24).VALUE  AND TXDATE=TO_DATE(P_TXMSG.txfields(23).VALUE,'DD/MM/RRRR');
       IF L_ISWFT='N' THEN
           p_err_code := '-901215';
           plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;
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
  l_txmsg       tx.msg_rectype;
  V_DTCURRDATE  DATE;
  l_err_param varchar2(300);
  L_ISMARGIN VARCHAR2(1);
  L_COUNT     NUMBER(20);
  L_ROOMREMAIN NUMBER(20);
  L_REFCODEID  VARCHAR2(10);
  l_afacctno   VARCHAR2(300);
  l_sectype    VARCHAR2(300);
  l_custid     VARCHAR2(300);
  l_codeid          VARCHAR2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    UPDATE SEDEPOWFTLOG SET TRADEDATE=TO_DATE(P_TXMSG.txfields(10).VALUE,'DD/MM/RRRR')
    WHERE TXNUM=P_TXMSG.txfields(24).VALUE  AND TXDATE=TO_DATE(P_TXMSG.txfields(23).VALUE,'DD/MM/RRRR');

       -- neu set ngay trade la ngay hien tai: thuc hien chuyen thanh CK giao dich luon
    IF TO_DATE(P_TXMSG.txfields(10).VALUE,'DD/MM/RRRR')=  P_TXMSG.txdate THEN
         --   PLOG.ERROR (pkgctx,'=P_TXMSG.txfields(03).VALUE: ' || P_TXMSG.txfields('03').VALUE);

           /* SELECT COUNT(*) INTO L_COUNT FROM AFMAST af,AFTYPE AFT, MRTYPE MRT
            WHERE AF.ACTYPE=AFT.ACTYPE AND AFT.MRTYPE=MRT.ACTYPE
            AND MRT.MRTYPE IN ('S','T') AND AF.ACCTNO=P_TXMSG.txfields('03').VALUE;

            IF L_COUNT >0 THEN
               L_ISMARGIN:='Y';
            ELSE
               L_ISMARGIN:='N';
            ENd IF;
            IF L_ISMARGIN='Y' THEN
               SELECT REFCODEID INTO L_REFCODEID FROM SBSECURITIES WHERE CODEID=P_TXMSG.txfields(09).VALUE;
               L_ROOMREMAIN:=FN_GETAVLROOM( P_TXMSG.txfields(03).VALUE,L_REFCODEID);
            END IF;*/
            FOR REC IN  (SELECT LOG.* ,SEC.REFCODEID ,CF.BRID,CF.CUSTODYCD,
                                SE.COSTPRICE PRICE,SEC.PARVALUE,CF.FULLNAME,CF.ADDRESS,CF.IDCODE,
                                LEAST (LOG.TRADE,SE.TRADE) TRADEAVL,
                                LEAST (LOG.BLOCKED,SE.BLOCKED)BLOCKEDAVL

                         FROM SEDEPOWFTLOG LOG,
                         (SELECT * FROM SYSVAR WHERE VARNAME='CURRDATE') Sys,
                          SBSECURITIES SEC, CFMAST CF , AFMAST af,SEMAST SE
                         WHERE LOG.DELTD <> 'Y' AND LOG.ISWFT='Y'
                         AND LOG.TRADEDATE<=TO_DATE(SYS.VARVALUE,'DD/MM/RRRR')
                         AND LOG.CODEID=SEC.CODEID
                         AND LOG.AFACCTNO=AF.ACCTNO
                         AND AF.CUSTID=CF.CUSTID
                         AND LOG.AFACCTNO=SE.AFACCTNO
                         AND LOG.CODEID=SE.CODEID
                         AND LOG.TXNUM=P_TXMSG.txfields('24').VALUE
                         AND LOG.TXDATE=TO_DATE(P_TXMSG.txfields('23').VALUE,'DD/MM/RRRR')
                         )
            LOOP
                SELECT count(*) INTO l_count
    FROM SEMAST
    WHERE ACCTNO= REC.AFACCTNO||REC.REFCODEID;


  IF l_count = 0 THEN
         l_afacctno := REC.AFACCTNO;
         l_codeid := REC.REFCODEID;
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
         l_sectype, l_custid,REC.AFACCTNO||REC.REFCODEID,l_codeid,l_afacctno,
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
    END IF;





                  --Set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                       || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                INTO l_txmsg.txnum
                FROM DUAL;
                l_txmsg.msgtype:='T';
                l_txmsg.local:='N';
                L_TXMSG.reftxnum:=P_TXMSG.TXNUM;
                --Set txtime
                select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
                l_txmsg.brid        := REC.BRID;
                L_TXMSG.TLTXCD:='2262';
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
                l_txmsg.txdate:=P_TXMSG.txdate;

                --Set cac field giao dich
                --01   N   CODEID

                l_txmsg.txfields ('01').defname   := 'CODEID';
                l_txmsg.txfields ('01').TYPE      := 'N';
                l_txmsg.txfields ('01').VALUE     := REC.REFCODEID;
                --02   C   AFACCTNO
                l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                l_txmsg.txfields ('02').TYPE      := 'C';
                l_txmsg.txfields ('02').VALUE     := rec.AFACCTNO;
                --03   C   SEACCTNODR
                l_txmsg.txfields ('03').defname   := 'SEACCTNODR';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO||REC.CODEID;
                --04   C   CUSTODYCD
                l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('04').TYPE      := 'C';
                l_txmsg.txfields ('04').VALUE     := rec.CUSTODYCD;
                --05   C   SEACCTNOCR
                l_txmsg.txfields ('05').defname   := 'SEACCTNOCR';
                l_txmsg.txfields ('05').TYPE      := 'C';
                l_txmsg.txfields ('05').VALUE     := REC.AFACCTNO||REC.REFCODEID ;
                --09   C   PRICE
                l_txmsg.txfields ('09').defname   := 'PRICE';
                l_txmsg.txfields ('09').TYPE      := 'N';
                l_txmsg.txfields ('09').VALUE     := rec.PRICE;
                --10   N   TRADE
                l_txmsg.txfields ('10').defname   := 'TRADE';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := rec.TRADEAVL;
                --11   N   PARVALUE
                l_txmsg.txfields ('11').defname   := 'PARVALUE';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec.PARVALUE;
                --12   N   MORTAGE
                l_txmsg.txfields ('12').defname   := 'MORTAGE';
                l_txmsg.txfields ('12').TYPE      := 'N';
                l_txmsg.txfields ('12').VALUE     :=  0;

                 --14   N   NETTING
                l_txmsg.txfields ('14').defname   := 'NETTING';
                l_txmsg.txfields ('14').TYPE      := 'N';
                l_txmsg.txfields ('14').VALUE     := 0;

                 --15   N   STANDING
                l_txmsg.txfields ('15').defname   := 'STANDING';
                l_txmsg.txfields ('15').TYPE      := 'N';
                l_txmsg.txfields ('15').VALUE     := 0;
                --16   N   WITHDRAW
                l_txmsg.txfields ('16').defname   := 'WITHDRAW';
                l_txmsg.txfields ('16').TYPE      := 'N';
                l_txmsg.txfields ('16').VALUE     := 0;

                 --17   N   DEPOSIT
                l_txmsg.txfields ('17').defname   := 'DEPOSIT';
                l_txmsg.txfields ('17').TYPE      := 'N';
                l_txmsg.txfields ('17').VALUE     := 0;


                 --19   N   BLOCKED
                l_txmsg.txfields ('19').defname   := 'BLOCKED';
                l_txmsg.txfields ('19').TYPE      := 'N';
                l_txmsg.txfields ('19').VALUE     := REC.BLOCKEDAVL;

                 --20   N   RECEIVING
                l_txmsg.txfields ('20').defname   := 'RECEIVING';
                l_txmsg.txfields ('20').TYPE      := 'N';
                l_txmsg.txfields ('20').VALUE     := 0;

                 --21   N   TRANSFER
                l_txmsg.txfields ('21').defname   := 'TRANSFER';
                l_txmsg.txfields ('21').TYPE      := 'N';
                l_txmsg.txfields ('21').VALUE     := 0;


                 --22   N   SENDDEPOSIT
                l_txmsg.txfields ('22').defname   := 'SENDDEPOSIT';
                l_txmsg.txfields ('22').TYPE      := 'N';
                l_txmsg.txfields ('22').VALUE     := 0;

              --23   N   SENDPENDING
                l_txmsg.txfields ('23').defname   := 'SENDPENDING';
                l_txmsg.txfields ('23').TYPE      := 'N';
                l_txmsg.txfields ('23').VALUE     := 0;

                --25   C   DTOCLOSE
                l_txmsg.txfields ('25').defname   := 'DTOCLOSE';
                l_txmsg.txfields ('25').TYPE      := 'N';
                l_txmsg.txfields ('25').VALUE := 0 ;

                 --26   C   EMKQTTY
                l_txmsg.txfields ('26').defname   := 'EMKQTTY';
                l_txmsg.txfields ('26').TYPE      := 'N';
                l_txmsg.txfields ('26').VALUE :=  0 ;


                --27   C   BLOCKWITHDRAW
                l_txmsg.txfields ('27').defname   := 'BLOCKWITHDRAW';
                l_txmsg.txfields ('27').TYPE      := 'N';
                l_txmsg.txfields ('27').VALUE :=  0 ;


                --25   C   BLOCKDTOCLOSE
                l_txmsg.txfields ('28').defname   := 'BLOCKDTOCLOSE';
                l_txmsg.txfields ('28').TYPE      := 'N';
                l_txmsg.txfields ('28').VALUE :=  0 ;


                --44   N   PARVALUE
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := utf8nums.c_const_TLTX_TXDESC_2262;

                --90   N   CUSTNAME
                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                l_txmsg.txfields ('90').TYPE      := 'C';
                l_txmsg.txfields ('90').VALUE     := rec.fullname;

                --91   N   ADDRESS
                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                l_txmsg.txfields ('91').TYPE      := 'N';
                l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

                 --53   N   LICENSE
                l_txmsg.txfields ('92').defname   := 'LICENSE';
                l_txmsg.txfields ('92').TYPE      := 'C';
                l_txmsg.txfields ('92').VALUE     := rec.idcode;
                BEGIN
                    IF txpks_#2262.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       PLOG.ERROR (pkgctx,
                                   'got error 2262: ' || p_err_code
                       );
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                END;
                -- update trong bang log
                UPDATE SEDEPOWFTLOG SET ISWFT='N' WHERE TXNUM=REC.TXNUM AND TXDATE=REC.TXDATE;
            END LOOP;
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
         plog.init ('TXPKS_#2225EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2225EX;
/
