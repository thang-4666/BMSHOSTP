SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3354ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3354EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      19/08/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3354ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_camastid         CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_reportdate       CONSTANT CHAR(2) := '06';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_seacctno         CONSTANT CHAR(2) := '08';
   c_exseacctno       CONSTANT CHAR(2) := '09';
   c_amt              CONSTANT CHAR(2) := '10';
   c_dutyamt          CONSTANT CHAR(2) := '20';
   c_aamt             CONSTANT CHAR(2) := '12';
   c_parvalue         CONSTANT CHAR(2) := '14';
   c_exparvalue       CONSTANT CHAR(2) := '15';
   c_desc             CONSTANT CHAR(2) := '30';
   c_fullname         CONSTANT CHAR(2) := '17';
   c_idcode           CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '19';
   c_taskcd           CONSTANT CHAR(2) := '16';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

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
   v_catype VARCHAR2(3);
    v_MARGIN NUMBER(20);
    v_WTRADE NUMBER(20);
    v_MORTAGE  NUMBER(20);
    v_BLOCKED  NUMBER(20);
    v_SECURED  NUMBER(20);
    v_REPO     NUMBER(20);
    v_NETTING  NUMBER(20);
    v_DTOCLOSE NUMBER(20);
    v_WITHDRAW NUMBER(20);
    v_dbseacctno VARCHAR2(20);
    l_txdesc     VARCHAR2(1000);
    v_blocked_dtl  NUMBER(20);
    v_emkqtty NUMBER(20);
    v_blockwithdraw NUMBER(20);
    v_blockdtoclose NUMBER(20);
    V_TRADE  NUMBER(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF cspks_caproc.fn_executecontractcaevent(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;


   --RESET CK VOI SU KIEN 016
 v_catype:=p_txmsg.txfields('05').value;
 v_dbseacctno:=p_txmsg.txfields('08').value;
 IF (v_catype IN ('016')    ) THEN
      -- not xoa
      IF p_txmsg.deltd <> 'Y' THEN

        SELECT trade, margin,wtrade,mortage,BLOCKED,secured,repo,netting,dtoclose,withdraw,emkqtty,blockwithdraw,blockdtoclose
        INTO v_trade, v_MARGIN,v_WTRADE,v_MORTAGE,v_BLOCKED,v_SECURED,v_REPO,v_NETTING,v_DTOCLOSE,v_WITHDRAW,v_emkqtty,v_blockwithdraw,v_blockdtoclose
        FROM semast WHERE acctno=v_dbseacctno;
        -- update cac truong ck ve 0 va insert vao setran
        UPDATE semast
        SET trade=0 , margin=0,wtrade=0,mortage=0,BLOCKED=0,secured=0,repo=0,netting=0,dtoclose=0,withdraw=0,blockwithdraw=0,blockdtoclose=0
        WHERE acctno=v_dbseacctno;

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0011',v_trade,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);


        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0083',v_MARGIN,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

         INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0080',v_WTRADE,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0066',v_MORTAGE,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0044',v_BLOCKED ,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0088',v_BLOCKWITHDRAW,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0090',v_blockdtoclose,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);


        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0018',v_SECURED,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0084',v_REPO,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0020',v_NETTING,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

         INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO, TXCD, NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0071',v_DTOCLOSE,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
        '0042',v_WITHDRAW,NULL,p_txmsg.txfields ('01').value,
        p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

      ELSE -- xoa jao dich
        -- lay du lieu trong setran_gen de revert
        UPDATE CAMAST SET cancelstatus = 'N', STATUS = 'I'
        WHERE CAMASTID = p_txmsg.txfields('02').value AND CATYPE IN ('023','020','016');

        plog.error (pkgctx, 'txnum | txdate : ' || p_txmsg.txnum || '|' ||  to_char(p_txmsg.txdate));

        SELECT nvl(namt,0) INTO v_TRADE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0011';

        SELECT nvl(namt,0) INTO v_margin FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0083';

        SELECT nvl(namt,0) INTO v_WTRADE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0080';

        SELECT nvl(namt,0) INTO v_MORTAGE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0066';


        SELECT nvl(namt,0) INTO v_SECURED FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0018';

        SELECT nvl(namt,0) INTO v_REPO FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0084';

        SELECT nvl(namt,0) INTO v_NETTING FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0020';

        SELECT nvl(namt,0) INTO v_DTOCLOSE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0071';

        SELECT nvl(namt,0) INTO v_WITHDRAW FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0042';

        SELECT nvl(namt,0) INTO v_BLOCKED FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0044';

        SELECT nvl(namt,0) INTO v_blockwithdraw FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0088';

        SELECT nvl(namt,0) INTO v_blockdtoclose FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0090';
        -- revert du lieu
        UPDATE semast
        SET TRADE=TRADE+v_TRADE, margin=margin+v_margin,wtrade=wtrade+v_wtrade,
        mortage=mortage+v_mortage,BLOCKED=BLOCKED+v_BLOCKED,
        secured=secured+v_secured,repo=repo+v_repo,netting=netting+v_netting,
        dtoclose=dtoclose+v_dtoclose,withdraw=withdraw+v_withdraw,
        blockwithdraw=blockwithdraw+v_blockwithdraw,
        blockdtoclose=blockdtoclose+v_blockdtoclose
        WHERE acctno=v_dbseacctno;

        UPDATE setran SET deltd='Y'
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate ;

      END IF;

    END IF;
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
         plog.init ('TXPKS_#3354EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3354EX;

/
