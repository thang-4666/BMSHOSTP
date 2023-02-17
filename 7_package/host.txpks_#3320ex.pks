SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3320ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3320EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/10/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3320ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_codeid varchar2(10);
    l_wft_codeid varchar2(10);
    l_qtty  number;
    l_emkqtty   number;
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

    l_codeid:= p_txmsg.txfields('01').value;
    -- lay ra ma CK wft
    Begin
        select codeid into l_wft_codeid from sbsecurities where refcodeid=l_codeid;
    EXCEPTION
        WHEN OTHERS THEN
            l_wft_codeid := '';
    END;

    Begin
        select sum(MORTAGE) into l_qtty from semast where codeid=l_codeid or codeid=l_wft_codeid;
    EXCEPTION
        WHEN OTHERS THEN
            l_qtty := 0;
    END;
    l_qtty := nvl(l_qtty,0);
    if l_qtty > 0 then
        p_txmsg.txWarningException('-900089').value := cspks_system.fn_get_errmsg('-900089');
        p_txmsg.txWarningException('-900089').errlev := '1';
   end if;

   Begin
        select sum(emkqtty) into l_emkqtty from semast where codeid=l_codeid or codeid=l_wft_codeid;
   EXCEPTION
        WHEN OTHERS THEN
            l_emkqtty := 0;
    END;
    l_emkqtty := nvl(l_emkqtty,0);
    if l_emkqtty > 0 then
        p_txmsg.txWarningException('-900090').value := cspks_system.fn_get_errmsg('-900090');
        p_txmsg.txWarningException('-900090').errlev := '1';
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
l_codeid varchar2(10);
l_wft_codeid varchar2(10);
v_MARGIN NUMBER(20);
v_WTRADE NUMBER(20);
v_MORTAGE  NUMBER(20);
v_BLOCKED  NUMBER(20);
v_SECURED  NUMBER(20);
v_REPO     NUMBER(20);
v_NETTING  NUMBER(20);
v_DTOCLOSE NUMBER(20);
v_WITHDRAW NUMBER(20);
v_BLOCKDTOCLOSE NUMBER(20);
v_BLOCKWITHDRAW NUMBER(20);
v_blocked_dtl  NUMBER(20);
v_dbseacctno   varchar2(30);
v_trade        number(20);
v_standing     number(20);
v_custodycd    varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_codeid:= p_txmsg.txfields('01').value;
    V_BLOCKED:=0;

    if p_txmsg.txfields('88').value = 'ALL' or p_txmsg.txfields('88').value is null then
        v_custodycd:='%%';
    else
        v_custodycd:=p_txmsg.txfields('88').value;
    end if;
    -- lay ra ma CK wft
    Begin
        select codeid into l_wft_codeid from sbsecurities where refcodeid=l_codeid;
    EXCEPTION
        WHEN OTHERS THEN
            l_wft_codeid := '';
    END;

      for rec in (select se.* from semast se, cfmast cf, afmast af
                 where (se.codeid=l_codeid or se.codeid=l_wft_codeid)
                 and cf.custid = af.custid
                 and af.acctno = se.afacctno
                 and cf.custodycd like v_custodycd
                 )
      loop
       v_dbseacctno:= rec.acctno;
       IF p_txmsg.deltd <> 'Y' THEN
         v_BLOCKED:=rec.blocked;
      -- cap nhat CK ve 0
          UPDATE semast
          SET trade=0,margin=0,wtrade=0,mortage=0,BLOCKED=0,secured=0,repo=0,netting=0,dtoclose=0,withdraw=0,
            BLOCKWITHDRAW=0, BLOCKDTOCLOSE=0, STANDING = 0
          WHERE acctno= v_dbseacctno ;
      -- sinh log trong setran
            if (rec.trade>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
                '0040',rec.trade,NULL,p_txmsg.txfields ('01').value,
                p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;

            if (rec.STANDING<>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
                '0013',rec.STANDING,NULL,p_txmsg.txfields ('01').value,
                p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;

            if (rec.margin>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0083',rec.margin,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
            if (rec.wtrade>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0080',rec.wtrade,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
            if (rec.mortage>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0066',rec.mortage,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
              /*-- update ref trong setran la ja tri qtty type trong semastdtl
              FOR rec1 IN (SELECT * FROM semastdtl WHERE acctno=v_dbseacctno AND status ='N' AND qtty <> 0)
              LOOP
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0044',rec1.qtty,NULL,rec1.autoid,
              p_txmsg.deltd,rec1.qttytype,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
              v_BLOCKED:=v_BLOCKED-rec1.qtty;
              END LOOP;*/
              IF v_BLOCKED>0 THEN
                  INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
                   '0044',v_BLOCKED,NULL,p_txmsg.txfields ('01').value,
                   p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);

              END IF;
            if (rec.secured>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0018',rec.secured,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
            if (rec.repo>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0084',rec.repo,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
            if (rec.netting>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0020',rec.netting,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
            if (rec.dtoclose>0) then
               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0071',rec.dtoclose,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;

            if (rec.BLOCKDTOCLOSE>0) then
               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0090',rec.BLOCKDTOCLOSE,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;

            if (rec.withdraw>0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0042',rec.withdraw,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;
            if (rec.BLOCKWITHDRAW > 0) then
              INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
              VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_dbseacctno,
              '0088',rec.BLOCKWITHDRAW,NULL,p_txmsg.txfields ('01').value,
              p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,null);
            end if;

    else-- xoa giao dich
      -- lay du lieu trong setran_gen de revert
       -- plog.error (pkgctx, 'txnum | txdate : ' || p_txmsg.txnum || '|' ||  to_char(p_txmsg.txdate)|| '|' || v_dbseacctno);
        begin
        SELECT nvl(namt,0) INTO v_trade FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0040';
        exception
        when others then
          v_trade:=0;
        end;
        begin
        SELECT nvl(namt,0) INTO v_margin FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0083';
        exception
        when others then
          v_margin:=0;
        end;

        begin
        SELECT nvl(namt,0) INTO v_WTRADE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0080';
        exception
        when others then
          v_WTRADE:=0;
        end;

        begin
        SELECT nvl(namt,0) INTO v_standing FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0013';
        exception
        when others then
          v_standing := 0;
        end;

        begin
        SELECT nvl(namt,0) INTO v_MORTAGE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0066';
        exception
        when others then
          v_MORTAGE:=0;
        end;

        /*FOR rec1 IN (SELECT * FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0044')
        LOOP
          v_BLOCKED:=v_BLOCKED+NVL(REC1.NAMT,0);
          ---UPDATE SEMASTDTL SET STATUS='N' WHERE AUTOID=REC1.ACCTREF;
        END LOOP;*/

         begin
        SELECT nvl(namt,0) INTO v_BLOCKED FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0044';
        exception
        when others then
          v_BLOCKED:=0;
        end;

        begin
        SELECT nvl(namt,0) INTO v_SECURED FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0018';
        exception
        when others then
          v_SECURED:=0;
        end;

        begin
        SELECT nvl(namt,0) INTO v_REPO FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0084';
        exception
        when others then
          v_REPO:=0;
        end;
        begin
        SELECT nvl(namt,0) INTO v_NETTING FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0020';
        exception
        when others then
          v_NETTING:=0;
        end;
        begin
        SELECT nvl(namt,0) INTO v_DTOCLOSE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0071';
        exception
        when others then
          v_DTOCLOSE:=0;
        end;
        begin
        SELECT nvl(namt,0) INTO v_BLOCKDTOCLOSE FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0090';
        exception
        when others then
          v_BLOCKDTOCLOSE:=0;
        end;
        begin
        SELECT nvl(namt,0) INTO v_WITHDRAW FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0042';
        exception
        when others then
          v_WITHDRAW:=0;
        end;
        begin
        SELECT nvl(namt,0) INTO v_BLOCKWITHDRAW FROM setran
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
        AND acctno=v_dbseacctno AND txcd='0088';
        exception
        when others then
          v_BLOCKWITHDRAW:=0;
        end;
        -- revert du lieu
        UPDATE semast
        SET
        trade=trade+v_trade,
        margin=margin+v_margin,wtrade=wtrade+v_wtrade,
        mortage=mortage+v_mortage,BLOCKED=BLOCKED+v_BLOCKED,
        secured=secured+v_secured,repo=repo+v_repo,netting=netting+v_netting,
        dtoclose=dtoclose+v_dtoclose,withdraw=withdraw+v_withdraw,
        BLOCKWITHDRAW= BLOCKWITHDRAW+v_BLOCKWITHDRAW, BLOCKDTOCLOSE=BLOCKDTOCLOSE+v_BLOCKDTOCLOSE,
        standing = standing+v_standing
        WHERE acctno=v_dbseacctno;

        UPDATE setran SET deltd='Y'
        WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate ;
    end if;
    end loop;
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
         plog.init ('TXPKS_#3320EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3320EX;
/
