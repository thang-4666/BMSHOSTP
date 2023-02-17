SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2647ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2647EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      18/05/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2647ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '02';
   c_lnacctno         CONSTANT CHAR(2) := '03';
   c_afacctno         CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '57';
   c_address          CONSTANT CHAR(2) := '58';
   c_license          CONSTANT CHAR(2) := '59';
   c_glmast           CONSTANT CHAR(2) := '08';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_seacctno         CONSTANT CHAR(2) := '06';
   c_lntype           CONSTANT CHAR(2) := '07';
   c_prinovd          CONSTANT CHAR(2) := '13';
   c_prinnml          CONSTANT CHAR(2) := '15';
   c_intnmlovd        CONSTANT CHAR(2) := '23';
   c_intovdacr        CONSTANT CHAR(2) := '26';
   c_intdue           CONSTANT CHAR(2) := '31';
   c_intnmlacr        CONSTANT CHAR(2) := '35';
   c_feepaid          CONSTANT CHAR(2) := '36';
   c_dfqtty           CONSTANT CHAR(2) := '37';
   c_rcvqtty          CONSTANT CHAR(2) := '38';
   c_carcvqtty        CONSTANT CHAR(2) := '39';
   c_blockqtty        CONSTANT CHAR(2) := '40';
   c_bqtty            CONSTANT CHAR(2) := '42';
   c_secured          CONSTANT CHAR(2) := '43';
   c_rlsqtty          CONSTANT CHAR(2) := '50';
   c_rlsamt           CONSTANT CHAR(2) := '51';
   c_dealfee          CONSTANT CHAR(2) := '53';
   c_pfeepaid         CONSTANT CHAR(2) := '90';
   c_dealamt          CONSTANT CHAR(2) := '52';
   c_amt              CONSTANT CHAR(2) := '45';
   c_qtty             CONSTANT CHAR(2) := '46';
   c_odamt            CONSTANT CHAR(2) := '41';
   c_pprinovd         CONSTANT CHAR(2) := '63';
   c_pprinnml         CONSTANT CHAR(2) := '65';
   c_pintnmlovd       CONSTANT CHAR(2) := '72';
   c_pintovdacr       CONSTANT CHAR(2) := '74';
   c_pintdue          CONSTANT CHAR(2) := '77';
   c_pintnmlacr       CONSTANT CHAR(2) := '80';
   c_pdfqtty          CONSTANT CHAR(2) := '91';
   c_prcvqtty         CONSTANT CHAR(2) := '92';
   c_pcarcvqtty       CONSTANT CHAR(2) := '93';
   c_pblockqtty       CONSTANT CHAR(2) := '94';
   c_dfref            CONSTANT CHAR(2) := '29';
   c_rrid             CONSTANT CHAR(2) := '95';
   c_cidrawndown      CONSTANT CHAR(2) := '96';
   c_limitcheck       CONSTANT CHAR(2) := '99';
   c_bankdrawndown    CONSTANT CHAR(2) := '97';
   c_cmpdrawndown     CONSTANT CHAR(2) := '98';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER

IS
I NUMBER ;
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

     IF   p_txmsg.txfields('46').value > p_txmsg.txfields('48').value THEN
          p_err_code:= -900050;
          RETURN -900050;
    END IF;


   SELECT  MOD ( p_txmsg.txfields('46').value ,tradelot )   INTO I FROM securities_info WHERE CODEID =p_txmsg.txfields('01').value ;
     IF  I <> 0 AND  p_txmsg.txfields('46').value <>0 THEN
          p_err_code:= -260153;
          RETURN -260153;
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
l_txdesc VARCHAR2(1000);
v_dblCARCVQTTY number;
v_dblRCVQTTY number;
v_dblBLOCKQTTY number;
v_dblAVLQTTY NUMBER;
v_dblCACASHQTTY NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0043',ROUND(p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0045',ROUND(p_txmsg.txfields('93').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN
      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2647','CI','0012');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('95').value,'0012',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
    END IF;
      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2647','CI','0011');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2647','CI','0028');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0028',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN
      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2647','CI','0029');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('95').value,'0029',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
    END IF;
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0071',ROUND(p_txmsg.txfields('99').value*(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value),0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('06').value,'0012',ROUND(p_txmsg.txfields('91').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('06').value,'0043',ROUND(p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('06').value,'0066',ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0014',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0015',ROUND(p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0017',ROUND(p_txmsg.txfields('63').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0024',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0025',ROUND(p_txmsg.txfields('77').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0027',ROUND(p_txmsg.txfields('72').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0041',ROUND(p_txmsg.txfields('80').value,4),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0043',ROUND(p_txmsg.txfields('74').value,4),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0011',ROUND(p_txmsg.txfields('91').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0016',ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0020',ROUND(p_txmsg.txfields('89').value*(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value),0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0023',ROUND(p_txmsg.txfields('90').value,4),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0028',ROUND(p_txmsg.txfields('90').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0041',ROUND(p_txmsg.txfields('92').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

-- Cap nhap so tien nop vao de giai toa ck
update dfgroup set RLSAMT = RLSAMT + p_txmsg.txfields('16').value WHERE GROUPID=p_txmsg.txfields('20').value;
/*
  UPDATE dfgroup
         SET
           RLSAMT = RLSAMT + ROUND(p_txmsg.txfields('89').value * (p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value),0)
         WHERE GROUPID=p_txmsg.txfields('20').value;
*/



    v_dblCARCVQTTY:=0;
    v_dblRCVQTTY:=0;
    v_dblAVLQTTY:=0;
    v_dblBLOCKQTTY:=0;

    if p_txmsg.txfields('55').value='N' then
        v_dblAVLQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='B' then
        v_dblBLOCKQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='R' then
        v_dblRCVQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='P' then
        v_dblCARCVQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='T' then
        v_dblCACASHQTTY:=p_txmsg.txfields('46').value;
    end if;

    plog.debug(pkgctx,'UPDATE DFMAST ' || p_txmsg.txfields('16').value || ' ' || p_txmsg.txfields('46').value);

    UPDATE DFMAST
       SET
         INTAMTACR = INTAMTACR - (ROUND(p_txmsg.txfields('90').value,4)),
         BLOCKQTTY = BLOCKQTTY - v_dblBLOCKQTTY,
         CARCVQTTY = CARCVQTTY - v_dblCARCVQTTY,
         RLSAMT = RLSAMT + p_txmsg.txfields('16').value ,
         RCVQTTY = RCVQTTY - v_dblRCVQTTY,
         RLSFEEAMT = RLSFEEAMT + (ROUND(p_txmsg.txfields('90').value,0)),
         DFQTTY = DFQTTY - v_dblAVLQTTY,
         CACASHQTTY=CACASHQTTY - v_dblCACASHQTTY,
         RLSQTTY = RLSQTTY + p_txmsg.txfields('46').value, LAST_CHANGE = SYSTIMESTAMP
      WHERE ACCTNO=p_txmsg.txfields('02').value;

    plog.debug(pkgctx,'UPDATE CASCHD OR SEMAST ' || p_txmsg.txfields('55').value || ' ' || p_txmsg.txfields('29').value || ' ' || ROUND(p_txmsg.txfields('16').value,0) || ' ' || ROUND(p_txmsg.txfields('46').value,0) );
      IF  p_txmsg.txfields ('55').value = 'T' THEN
            UPDATE caschd set dfamt= dfamt - (ROUND(p_txmsg.txfields('46').value,0)) where autoid=p_txmsg.txfields('29').value;
      else
            UPDATE SEMAST SET
                BLOCKED = BLOCKED + v_dblBLOCKQTTY,
                TRADE = TRADE + v_dblAVLQTTY,
                MORTAGE = MORTAGE - (v_dblAVLQTTY+v_dblBLOCKQTTY), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('06').value;
      end if;
/*
---- Gio chi dung giai ngan tu Ngan hang
    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN
      UPDATE CIMAST
         SET
           BALANCE = BALANCE + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('95').value;
    END IF;

      UPDATE LNMAST
         SET
--           PRINOVD = PRINOVD - (ROUND(p_txmsg.txfields('63').value,0)),
--           INTNMLACR = INTNMLACR - (ROUND(p_txmsg.txfields('80').value,4)),
--           INTDUE = INTDUE - (ROUND(p_txmsg.txfields('77').value,0)),
           PRINNML = PRINNML - (p_txmsg.txfields('16').value,0)),
--           INTNMLOVD = INTNMLOVD - (ROUND(p_txmsg.txfields('72').value,0)),
--           INTPAID = INTPAID + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0)),
--           INTOVDACR = INTOVDACR - (ROUND(p_txmsg.txfields('74').value,4)),
           PRINPAID = PRINPAID + (ROUND(p_txmsg.txfields('16').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;
*/

    plog.debug(pkgctx,'UPDATE LNMAST' || p_txmsg.txfields('16').value);
   UPDATE LNMAST
         SET
           PRINNML = PRINNML - ROUND(p_txmsg.txfields('16').value,0),
           PRINPAID = PRINPAID + (ROUND(p_txmsg.txfields('16').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;

    plog.debug(pkgctx,'UPDATE CIMAST' || p_txmsg.txfields('16').value);
  UPDATE CIMAST
     SET
       BALANCE = BALANCE - ROUND(p_txmsg.txfields('16').value,0),
       DFODAMT = DFODAMT - ROUND(p_txmsg.txfields('16').value,0), LAST_CHANGE = SYSTIMESTAMP
    WHERE ACCTNO=p_txmsg.txfields('05').value;

   ELSE -- Reversal

      UPDATE CITRAN SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
      UPDATE LNTRAN SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
      UPDATE DFTRAN SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
      UPDATE SETRAN SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);



/*
      UPDATE DFMAST
      SET
           INTAMTACR=INTAMTACR + (ROUND(p_txmsg.txfields('90').value,4)),
           BLOCKQTTY=BLOCKQTTY + (ROUND(p_txmsg.txfields('94').value,0)),
           CARCVQTTY=CARCVQTTY + (ROUND(p_txmsg.txfields('93').value,0)),
           RLSAMT=RLSAMT - (ROUND(p_txmsg.txfields('89').value*(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value),0)),
           RCVQTTY=RCVQTTY + (ROUND(p_txmsg.txfields('92').value,0)),
           RLSFEEAMT=RLSFEEAMT - (ROUND(p_txmsg.txfields('90').value,0)),
           DFQTTY=DFQTTY + (ROUND(p_txmsg.txfields('91').value,0)),
           RLSQTTY=RLSQTTY - (ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('02').value;




      UPDATE SEMAST
      SET
           BLOCKED=BLOCKED - (ROUND(p_txmsg.txfields('94').value,0)),
           TRADE=TRADE - (ROUND(p_txmsg.txfields('91').value,0)),
           MORTAGE=MORTAGE + (ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('94').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('06').value;

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN



      UPDATE CIMAST
      SET
           BALANCE=BALANCE - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) - (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('95').value;
    END IF;



      UPDATE LNMAST
      SET
           PRINOVD=PRINOVD + (ROUND(p_txmsg.txfields('63').value,0)),
           INTNMLACR=INTNMLACR + (ROUND(p_txmsg.txfields('80').value,4)),
           INTDUE=INTDUE + (ROUND(p_txmsg.txfields('77').value,0)),
           PRINNML=PRINNML + (ROUND(p_txmsg.txfields('65').value,0)),
           INTNMLOVD=INTNMLOVD + (ROUND(p_txmsg.txfields('72').value,0)),
           INTPAID=INTPAID - (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0)),
           INTOVDACR=INTOVDACR + (ROUND(p_txmsg.txfields('74').value,4)),
           PRINPAID=PRINPAID - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;




      UPDATE CIMAST
      SET
           BALANCE=BALANCE + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)),
           DFODAMT=DFODAMT + (ROUND(p_txmsg.txfields('99').value*(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value),0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;
*/

-- Cap nhap so tien nop vao de giai toa ck
update dfgroup set RLSAMT = RLSAMT - p_txmsg.txfields('16').value WHERE GROUPID=p_txmsg.txfields('20').value;


    v_dblCARCVQTTY:=0;
    v_dblRCVQTTY:=0;
    v_dblAVLQTTY:=0;
    v_dblBLOCKQTTY:=0;
    v_dblCACASHQTTY:=0;

    if p_txmsg.txfields('55').value='N' THEN
        v_dblAVLQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='B' then
        v_dblBLOCKQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='R' then
        v_dblRCVQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='P' then
        v_dblCARCVQTTY:=p_txmsg.txfields('46').value;
    end if;
    if p_txmsg.txfields('55').value='T' then
        v_dblCACASHQTTY:=p_txmsg.txfields('46').value;
    end if;

    UPDATE DFMAST
       SET
         INTAMTACR = INTAMTACR + (ROUND(p_txmsg.txfields('90').value,4)),
         BLOCKQTTY = BLOCKQTTY + v_dblBLOCKQTTY,
         CARCVQTTY = CARCVQTTY + v_dblCARCVQTTY,
         RLSAMT = RLSAMT - p_txmsg.txfields('16').value ,
         RCVQTTY = RCVQTTY + v_dblRCVQTTY,
         RLSFEEAMT = RLSFEEAMT - (ROUND(p_txmsg.txfields('90').value,0)),
         DFQTTY = DFQTTY + v_dblAVLQTTY,
         CACASHQTTY=CACASHQTTY + v_dblCACASHQTTY,
         RLSQTTY = RLSQTTY - p_txmsg.txfields('46').value, LAST_CHANGE = SYSTIMESTAMP
      WHERE ACCTNO=p_txmsg.txfields('02').value;

      IF  p_txmsg.txfields ('55').value = 'T' THEN
            UPDATE caschd set dfamt= dfamt + (ROUND(p_txmsg.txfields('46').value,0)) where autoid=p_txmsg.txfields('29').value;
      else
            UPDATE SEMAST SET
                BLOCKED = BLOCKED - v_dblBLOCKQTTY,
                TRADE = TRADE - v_dblAVLQTTY,
                MORTAGE = MORTAGE - (v_dblAVLQTTY+v_dblBLOCKQTTY), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('06').value;
      end if;


   UPDATE LNMAST
         SET
           PRINNML = PRINNML + ROUND(p_txmsg.txfields('16').value,0),
           PRINPAID = PRINPAID - (ROUND(p_txmsg.txfields('16').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;

      UPDATE CIMAST
         SET
           BALANCE = BALANCE + ROUND(p_txmsg.txfields('16').value,0),
           DFODAMT = DFODAMT + ROUND(p_txmsg.txfields('16').value,0), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;

   END IF;


    plog.debug (pkgctx,'HaiLT 0 ' || p_txmsg.txfields('03').value);
    IF txpks_batch.fn_LoanPaymentScheduleAllocate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    plog.debug (pkgctx,'HaiLT 0 End' || p_txmsg.txfields('03').value);

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
         plog.init ('TXPKS_#2647EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2647EX;
/
