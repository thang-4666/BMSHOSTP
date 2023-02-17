SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3332ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3332EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/06/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3332ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacct           CONSTANT CHAR(2) := '02';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_custodycd2       CONSTANT CHAR(2) := '32';
   c_custname         CONSTANT CHAR(2) := '34';
   c_address          CONSTANT CHAR(2) := '35';
   c_license          CONSTANT CHAR(2) := '36';
   c_autoid           CONSTANT CHAR(2) := '09';
   c_camastid         CONSTANT CHAR(2) := '18';
   c_description      CONSTANT CHAR(2) := '29';
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
    l_AMT       number(20,4);
    l_TRADE       number(20,4);
    l_QTTY       number(20,4);
    l_AQTTY       number(20,4);
    l_PQTTY       number(20,4);
    l_RQTTY       number(20,4);
    l_ISSE       varchar2(2);
    l_ISCI       varchar2(2);
    l_tqtty      NUMBER(20,4);
    l_casqtty    NUMBER(20,4);
    l_catype     VARCHAR2(3);
    l_optcodeid   VARCHAR2(6);
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
    if p_txmsg.deltd <> 'Y' then

        begin
            select AMT, TRADE, QTTY, AQTTY, PQTTY, RQTTY, ISSE, ISCI,tqtty
                into l_AMT, l_TRADE, l_QTTY, l_AQTTY, l_PQTTY, l_RQTTY, l_ISSE, l_ISCI,l_tqtty
            from caschd
            where autoid = to_number(p_txmsg.txfields(c_autoid).value) and camastid = p_txmsg.txfields(c_camastid).value;
        exception when others then
            p_err_code := '-260010'; -- Pre-defined in DEFERROR table
            plog.error('3332:'||SQLERRM||'.'||dbms_utility.format_error_backtrace||'.');
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end;
        SELECT catype,optcodeid INTO l_catype,l_optcodeid FROM camast
        WHERE camastid=p_txmsg.txfields(c_camastid).value AND deltd <> 'Y';
     /*   -- check neu skqm da lam 3384 thi pai lam het 3387
    IF (l_tqtty <> l_qtty AND l_catype='014') THEN
                p_err_code:='-300071';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;*/

        if not (l_ISSE = p_txmsg.txfields(c_isse).value
                and l_ISCI = p_txmsg.txfields(c_isci).value) then
            p_err_code := '-300013'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if not (l_AMT >= to_number(p_txmsg.txfields(c_amt).value)
                and l_TRADE >= to_number(p_txmsg.txfields(c_trade).value)
                and l_QTTY >= to_number(p_txmsg.txfields(c_qtty).value)
                and l_AQTTY >= to_number(p_txmsg.txfields(c_aqtty).value)
                and l_PQTTY >= to_number(p_txmsg.txfields(c_pqtty).value)
                and l_RQTTY >= to_number(p_txmsg.txfields(c_rqtty).value))
            then
            p_err_code := '-300021'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        IF l_QTTY >0 AND l_optcodeid IS NOT NULL  AND NOT  cspks_cfproc.fn_check_account_mrirate(p_txmsg.txfields(c_afacct).value,l_optcodeid,l_QTTY,0 )   THEN

             p_err_code:='-180064';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;



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
l_isWFT char(1);
l_seacctno VARCHAR2(20);
l_tocodeid VARCHAR2(20);
l_catype   VARCHAR2(10);
l_qtty NUMBER;
l_casqtty NUMBER;
l_tqtty NUMBER;
l_amt NUMBER;
l_status VARCHAR2(1);
l_afacctno VARCHAR2(10);
l_count    number;
l_balance  number(20);
l_pbalance  number(20);
l_DBL_Left_rightoffrate number(10);
l_DBL_right_rightoffrate number(10);
l_rightoffrate           varchar2(30);
l_retailbal             number(20);
l_codeid                   varchar2(30);
l_orgcodeid                varchar2(30);
l_optcodeid                varchar2(30);
l_isse                     varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_balance:=0;
    l_pbalance:=0;
    l_retailbal:=0;
    SELECT ca.catype,
    (schd.afacctno ||(CASE WHEN iswft='N' THEN nvl(ca.tocodeid,ca.codeid)
     ELSE sec.codeid END)) ,qtty,tqtty,schd.status, afacctno,nvl(rightoffrate,'1/1'),
     (CASE WHEN iswft='N' THEN nvl(ca.tocodeid,ca.codeid)
     ELSE sec.codeid END),ca.codeid,ca.optcodeid,isse

    INTO l_catype,l_seacctno ,l_casqtty,l_tqtty,l_status,l_afacctno,l_rightoffrate,l_codeid,l_orgcodeid,l_optcodeid,l_isse
    FROM camast ca, caschd schd, sbsecurities sec
    WHERE ca.camastid=p_txmsg.txfields(c_camastid).value
    AND ca.camastid=schd.camastid
    AND nvl(ca.tocodeid,ca.codeid)=sec.refcodeid
    AND schd.autoid= p_txmsg.txfields(c_autoid).value;
    l_qtty:=to_number(p_txmsg.txfields('13').value);
    l_amt:= to_number(p_txmsg.txfields(c_amt).value);
    -- tinh ra tuong ung so luong quyen da DK va chua DK
    l_dbl_left_rightoffrate := nvl(to_number(substr(l_rightoffrate,0,instr(l_rightoffrate,'/') - 1)),1);
    l_dbl_right_rightoffrate := nvl(to_number(substr(l_rightoffrate,instr(l_rightoffrate,'/') + 1,length(l_rightoffrate))),1);
    if l_catype='014' then
        l_balance:=TRUNC(to_number(p_txmsg.txfields(c_qtty).value)
                         *l_DBL_Left_rightoffrate / l_DBL_right_rightoffrate);-- sl da dkqm
        l_pbalance:=TRUNC(to_number(p_txmsg.txfields(c_pqtty).value)
                         *l_DBL_Left_rightoffrate / l_DBL_right_rightoffrate);-- sl chua dkqm
    end if;
    if p_txmsg.deltd <> 'Y' then
        select least(l_pbalance,RETAILBAL)
        into l_retailbal from caschd
        where  autoid = p_txmsg.txfields(c_autoid).value;

        update caschd
        set AMT = AMT - to_number(p_txmsg.txfields(c_amt).value),
        TRADE = TRADE - to_number(p_txmsg.txfields(c_trade).value),
        QTTY = QTTY - to_number(p_txmsg.txfields(c_qtty).value),
        AQTTY = AQTTY - to_number(p_txmsg.txfields(c_aqtty).value),
        PQTTY = PQTTY - to_number(p_txmsg.txfields(c_pqtty).value),
        RQTTY = RQTTY - to_number(p_txmsg.txfields(c_rqtty).value),
        balance=balance-l_balance,
        pbalance=pbalance-l_pbalance,
        RETAILBAL =  RETAILBAL -  l_retailbal,
        inbalance=inbalance-(l_pbalance-l_retailbal)
        where autoid = p_txmsg.txfields(c_autoid).value and camastid = p_txmsg.txfields(c_camastid).value;

        INSERT INTO CATRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields(c_autoid).value,
        '0015',l_retailbal,'',p_txmsg.deltd,'',seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

          -- neu la quyen mua update truong chung khoan receiving trong semast
        IF ( l_qtty >0 and l_tqtty >0 ) THEN -- skqm da lam 3387
          UPDATE caschd
          SET tqtty=tqtty-least(to_number(p_txmsg.txfields(c_qtty).value),l_tqtty)
          where autoid = p_txmsg.txfields(c_autoid).value
          and camastid = p_txmsg.txfields(c_camastid).value;
          -- sinh log trong catran
          insert into catran (TXNUM, TXDATE, ACCTNO, TXCD, NAMT, CAMT, REF, DELTD, AUTOID, TLTXCD, BKDATE, TRDESC)
          values (p_txmsg.txnum,p_txmsg.txdate,p_txmsg.txfields('09').value ,
          '0013', p_txmsg.txfields(c_qtty).value, '', '', 'N', seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate , '');
        end if;

        IF ( l_qtty >0) AND l_isse = 'N' AND l_status IN  ('S','J','G','H','I') THEN
          UPDATE semast
          SET receiving=receiving -l_qtty
          WHERE acctno=l_seacctno;

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0015',l_qtty,NULL,p_txmsg.txfields(c_autoid).value,p_txmsg.deltd,p_txmsg.txfields(c_autoid).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        IF  l_optcodeid IS NOT NULL THEN
         UPDATE semast
          SET trade=trade -l_qtty
          WHERE acctno= p_txmsg.txfields(c_afacct).value || l_optcodeid;

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields(c_afacct).value || l_optcodeid,'0040',l_qtty,NULL,p_txmsg.txfields(c_autoid).value,p_txmsg.deltd,p_txmsg.txfields(c_autoid).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        END IF ;

        END IF;
             --update giam receving trong cimast
        IF ( l_amt >0 ) THEN
          UPDATE cimast
          SET receiving=receiving -l_amt
          WHERE acctno=l_afacctno;

          INSERT INTO citran(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_afacctno,'0045',l_amt,NULL,p_txmsg.txfields(c_autoid).value,p_txmsg.deltd,p_txmsg.txfields(c_autoid).value,seq_ciTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        END IF;
         --ngoc.vu edit VCBSDEPII-227
   /*INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
   VALUES(seq_catrflog.NEXTVAL,TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) , p_txmsg.txnum ,p_txmsg.txfields(c_camastid).value,null,l_afacctno||l_orgcodeid,l_orgcodeid,NULL,l_balance,l_amt,l_qtty,p_txmsg.txfields('32').value,p_txmsg.txfields('88').value,'N');
   */
   INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
   VALUES(seq_catrflog.NEXTVAL,TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) , p_txmsg.txnum ,p_txmsg.txfields(c_camastid).value,null,l_afacctno||l_orgcodeid,l_orgcodeid,
          NULL,to_number(p_txmsg.txfields('12').value),l_amt,to_number(p_txmsg.txfields('16').value)+to_number(p_txmsg.txfields('13').value)+to_number(p_txmsg.txfields('20').value),p_txmsg.txfields('32').value,p_txmsg.txfields('88').value,'N');

    else-- xoa giao dich
        -- lay ra gia tri tru trong retail_bal de revert
        begin
          select namt into l_retailbal
          from catran where txnum=p_txmsg.txnum
          and  txdate=p_txmsg.txdate and txcd='0015';
        exception
        when others then
         l_retailbal:=l_pbalance;
        end;
        update caschd
        set AMT = AMT + to_number(p_txmsg.txfields(c_amt).value),
        TRADE = TRADE + to_number(p_txmsg.txfields(c_trade).value),
        QTTY = QTTY + to_number(p_txmsg.txfields(c_qtty).value),
        AQTTY = AQTTY + to_number(p_txmsg.txfields(c_aqtty).value),
        PQTTY = PQTTY + to_number(p_txmsg.txfields(c_pqtty).value),
        RQTTY = RQTTY + to_number(p_txmsg.txfields(c_rqtty).value),
        balance=balance+l_balance,
        pbalance=pbalance+l_pbalance,
        RETAILBAL =  RETAILBAL +  l_retailbal,
        inbalance=inbalance+ (l_pbalance-l_retailbal)
        where autoid = p_txmsg.txfields(c_autoid).value and camastid = p_txmsg.txfields(c_camastid).value;
        -- kiem tra xem chieu thuan giao dich co ghi giam trong tqtty khong
        select count(*) into l_count from catran where txnum=p_txmsg.txnum and txdate=p_txmsg.txdate
        and txcd='0013';
         -- neu la quyen mua update truong chung khoan receiving trong semast
        if (l_count>0) then
          UPDATE caschd SET tqtty=tqtty+to_number(p_txmsg.txfields(c_qtty).value)
          where autoid = p_txmsg.txfields(c_autoid).value
          and camastid = p_txmsg.txfields(c_camastid).value;
          update catran set deltd='Y' where txnum=p_txmsg.txnum and txdate=p_txmsg.txdate;
        end if;
        IF l_qtty >0 AND l_isse = 'N' AND l_status IN  ('S','J','G','H','I') THEN
          UPDATE semast
          SET receiving=receiving +l_qtty
          WHERE acctno=l_seacctno;

       IF  l_optcodeid IS NOT NULL THEN
         UPDATE semast
          SET trade=trade + l_qtty
          WHERE acctno= p_txmsg.txfields(c_afacct).value || l_optcodeid;
        END IF ;
        UPDATE setran SET deltd='Y'
        WHERE txnum=p_txmsg.txnum AND txdate=TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);

        END IF;

            DELETE FROM catrflog WHERE txnum= p_txmsg.txnum AND txdate = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
                --update cong receving trong cimast
        IF ( l_amt >0 ) THEN
          UPDATE cimast
          SET receiving=receiving +l_amt
          WHERE acctno=l_afacctno;

          INSERT INTO citran(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_afacctno,'0046',l_amt,NULL,p_txmsg.txfields(c_autoid).value,p_txmsg.deltd,p_txmsg.txfields(c_autoid).value,seq_ciTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


        END IF;

    end if;

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
         plog.init ('TXPKS_#3332EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3332EX;


-- End of DDL Script for Package HOSTTEST9.TXPKS_#3332EX

-- Start of DDL Script for Package Body HOSTTEST9.TXPKS_#3332EX
-- Generated 1-Jul-2013 14:07:40 from HOSTTEST9@FLEX_233



-- End of DDL Script for Package Body HOSTTEST9.TXPKS_#3332EX
/
