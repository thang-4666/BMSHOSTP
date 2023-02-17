SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1610ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1610EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      03/03/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1610ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_afacctno         CONSTANT CHAR(2) := '05';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_intavlamt        CONSTANT CHAR(2) := '12';
   c_balance          CONSTANT CHAR(2) := '09';
   c_mortgage         CONSTANT CHAR(2) := '13';
   c_amt              CONSTANT CHAR(2) := '10';
   c_directamt        CONSTANT CHAR(2) := '15';
   c_intamt           CONSTANT CHAR(2) := '11';
   c_desc             CONSTANT CHAR(2) := '30';
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
l_NOTINTDUECD NUMBER(1);
l_strBuyingPower VARCHAR2(1);
l_txdesc VARCHAR2(1000);
l_balance number;
l_mortage number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_NOTINTDUECD:=to_number(p_txmsg.txfields('20').value);
    SELECT buyingpower INTO l_strBuyingPower from tdmast
    WHERE acctno=p_txmsg.txfields('03').value;
      UPDATE AFMAST
         SET
           MRCRLIMIT = MRCRLIMIT -
             ((p_txmsg.txfields('10').value  - p_txmsg.txfields('15').value)* p_txmsg.txfields('16').value)
         WHERE ACCTNO=p_txmsg.txfields('05').value;

     INSERT INTO TDLINK (TXDATE, TXNUM, AFACCTNO, ACCTNO, DORC, DELTD, AMT)
         VALUES (TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,
         p_txmsg.txfields('05').value,p_txmsg.txfields('03').value,'D','N',
         (p_txmsg.txfields('10').value-p_txmsg.txfields('15').value)*p_txmsg.txfields('16').value);
      -- PhuongHT edit: neu tu dong nhap lai vao goc  l_NOTINTDUECD=0
      IF (l_NOTINTDUECD=0) THEN
        -- nhap lai vao goc:  khong log phan nay vao tdtran vi jao dich mo 1670 cung khong log vao tdtran
        UPDATE tdmast SET ORGAMT=ORGAMT+p_txmsg.txfields('11').value,
        BALANCE=BALANCE+p_txmsg.txfields('11').value
        WHERE acctno=p_txmsg.txfields('03').value;
        l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'1610','TD','0022','0001');
        INSERT INTO TDTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0022',+p_txmsg.txfields('11').value,NULL,p_txmsg.txfields('05').value,p_txmsg.deltd,p_txmsg.txfields('05').value,seq_TDTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

        -- cong lai vao dam bao suc mua
        if(l_strBuyingPower='Y') THEN
        UPDATE afmast SET mrcrlimit=MRCRLIMIT+p_txmsg.txfields('11').value
        WHERE ACCTNO=p_txmsg.txfields('05').value;

        UPDATE tdmast SET mortgage=mortgage+p_txmsg.txfields('11').value
        WHERE acctno=p_txmsg.txfields('03').value;

        INSERT INTO TDLINK (TXDATE, TXNUM, AFACCTNO, ACCTNO, DORC, DELTD, AMT)
        VALUES (TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,
        p_txmsg.txfields('05').value,p_txmsg.txfields('03').value,'C','N',
        p_txmsg.txfields('11').value);
        END IF;
      END IF;
      -- end of PhuongHT edit
      --Begin Hoi lai phan tinh vao suc mua bi giam tru do cam co
      SELECT buyingpower, balance, mortgage INTO l_strBuyingPower, l_balance, l_mortage from tdmast
        WHERE acctno=p_txmsg.txfields('03').value;
      if l_balance-l_mortage>0 and l_strBuyingPower='Y' then
        UPDATE afmast SET mrcrlimit=MRCRLIMIT+(l_balance-l_mortage)
        WHERE ACCTNO=p_txmsg.txfields('05').value;

        UPDATE tdmast SET mortgage=mortgage+(l_balance-l_mortage)
        WHERE acctno=p_txmsg.txfields('03').value;

        INSERT INTO TDLINK (TXDATE, TXNUM, AFACCTNO, ACCTNO, DORC, DELTD, AMT)
        VALUES (TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,
        p_txmsg.txfields('05').value,p_txmsg.txfields('03').value,'C','N',
        (l_balance-l_mortage));
      end if;
      --End Hoi lai phan tinh vao suc mua bi giam tru do cam co
      --Tat toan tai khoan TD
     UPDATE tdmast set STATUS ='C', PSTATUS =PSTATUS||STATUS
         Where ACCTNO = p_txmsg.txfields('03').value
         And (autornd <>'Y' Or p_txmsg.txfields ('10').VALUE+p_txmsg.txfields ('21').VALUE =0);

          --Backup nhung tai khoan se duoc gia han ra bang hist.
     Insert into tdmasthist
        select * from tdmast td where Autornd ='Y' And ACCTNO = p_txmsg.txfields('03').value;
     --Cap nhat lai trang thai la N voi tai khoan da Unblock (Status la A)
     UPDATE tdmast set STATUS ='N', PSTATUS =PSTATUS||STATUS
         Where ACCTNO = p_txmsg.txfields('03').value
         And STATUS ='A';

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
         plog.init ('TXPKS_#1610EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1610EX; 
/
