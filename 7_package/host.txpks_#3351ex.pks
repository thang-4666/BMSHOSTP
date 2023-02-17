SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3351ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3351EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3351ex
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
   c_qtty             CONSTANT CHAR(2) := '11';
   c_dutyamt          CONSTANT CHAR(2) := '20';
   c_aqtty            CONSTANT CHAR(2) := '13';
   c_parvalue         CONSTANT CHAR(2) := '14';
   c_exparvalue       CONSTANT CHAR(2) := '15';
   c_description      CONSTANT CHAR(2) := '30';
   c_priceaccounting   CONSTANT CHAR(2) := '21';
   c_status           CONSTANT CHAR(2) := '40';
   c_fullname         CONSTANT CHAR(2) := '17';
   c_idcode           CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '19';
   c_catypevalue      CONSTANT CHAR(2) := '22';
   c_taskcd           CONSTANT CHAR(2) := '16';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_status varchar2(1);
l_catype varchar2(4);
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
        if p_txmsg.deltd<>'Y' then
        SELECT STATUS, catype INTO l_STATUS, l_catype
        FROM CAMAST
        WHERE CAMASTID = p_txmsg.txfields('02').value;
        if l_catype in ('023','020') then
            IF NOT(INSTR('IGHJ',l_STATUS) > 0) THEN
                p_err_code := '-300013';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else
            IF NOT(INSTR('IGH',l_STATUS) > 0) THEN
                p_err_code := '-300013';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;


               SELECT  STATUS
      INTO l_STATUS
        FROM CASCHD
        WHERE AUTOID = p_txmsg.txfields('01').value;

        if l_catype in ('023','020') then
            IF NOT(INSTR('SGHJW',l_STATUS) > 0) THEN
                p_err_code := '-300013';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else
             IF NOT ( INSTR('SGH',l_STATUS) > 0) THEN
                p_err_code := '-300014';
                plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;
          END IF;

    end if;

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
l_TRADE NUMBER(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
         -- neu la xoa jao dich: check xem TK co du tien, CK de revert ko
    if(p_txmsg.deltd = 'Y') THEN
    -- lay ra so du hien tai
        BEGIN
            SELECT trade INTO l_TRADE
            FROM semast WHERE acctno=p_txmsg.txfields('08').value;
        EXCEPTION WHEN OTHERS THEN
            p_err_code := '-300053'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END ;


        if l_TRADE < (ROUND(p_txmsg.txfields('11').value,0))
        then
              p_err_code := '-300053'; -- Pre-defined in DEFERROR table
              plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    END IF;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_catype:=p_txmsg.txfields('22').value;
    v_dbseacctno:=p_txmsg.txfields('09').value;
    --V_BLOCKED:=0;
    IF cspks_caproc.fn_executecontractcaevent(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    -- update cac truong chung khoan ve 0 doi voi cac sk: IN ('017','020','023')
   --locpt 20180320 bmsc
    /*IF p_txmsg.deltd <> 'Y' THEN
     -----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
      secmast_generate(p_txmsg.txnum, p_txmsg.txdate,  p_txmsg.txdate, p_txmsg.txfields('03').value,
             SUBSTR(p_txmsg.txfields('08').value,11,6), 'C', 'I', p_txmsg.txfields('02').value, NULL,  p_txmsg.txfields('11').value, p_txmsg.txfields('12').value, 'Y');
    else
        secnet_un_map(p_txmsg.txnum, p_txmsg.txdate);
    end if;*/
    --30/10/2018 DieuNDA Them log OTC
    IF p_txmsg.deltd <> 'Y' THEN
         INSERT INTO SEOTCTRANLOG (AUTOID,TXNUM,TXDATE,TLTXCD,SEACCTNO,TYPEPON,SHAREHOLDERSID,STATUS,AMOUNT,DELTD,TRADE,BLOCKED)
             SELECT seq_SEOTCTRANLOG.NEXTVAL AUTOID, p_txmsg.txnum TXNUM, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) TXDATE, p_txmsg.tltxcd TLTXCD,
                 SE.ACCTNO SEACCTNO, 'CR' TYPEPON, SE.SHAREHOLDERSID, 'A' STATUS,
                 0+p_txmsg.txfields('11').VALUE AMOUNT,'N' DELTD,
                 p_txmsg.txfields('11').VALUE TRADE,
                 0 BLOCKED
             FROM SEMAST SE
             WHERE ACCTNO=p_txmsg.txfields('08').value AND LENGTH(TRIM(NVL(SHAREHOLDERSID,''))) > 0;
    ELSE --REVERT
        UPDATE  SEOTCTRANLOG SET DELTD ='Y' WHERE TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND TXNUM =p_txmsg.TXNUM;
    END IF;
     --End 30/10/2018 DieuNDA Them log OTC
    IF (v_catype IN ('017') or (v_catype IN ('023','020') and p_txmsg.txfields('10').value = 'Y')) THEN
      -- not xoa
      IF p_txmsg.deltd <> 'Y' THEN
        --27/11/2017 DieuNDA: Do dac thu cua BMS neu tai khoan co 2 tieu cung co CK thi chi chot quyen tren tieu khoan Thuong=> Khi Huy niem yet se huy tren tat ca nhung tieu khoan cua TK
        for rec in (
            select se.*
            from semast se, afmast af
            where se.afacctno = af.acctno
                and EXISTS (
                                select * from semast se1, afmast af1
                                where se1.afacctno = af1.acctno
                                    and se1.codeid = se.codeid
                                    and af1.custid = af.custid
                                    and se1.acctno = v_dbseacctno
                            )
        ) loop
            /*SELECT margin,wtrade,mortage,BLOCKED,secured,repo,netting,dtoclose,withdraw,emkqtty,blockwithdraw,blockdtoclose
            INTO v_MARGIN,v_WTRADE,v_MORTAGE,v_BLOCKED,v_SECURED,v_REPO,v_NETTING,v_DTOCLOSE,v_WITHDRAW,v_emkqtty,v_blockwithdraw,v_blockdtoclose
            FROM semast WHERE acctno=v_dbseacctno;*/
            -- update cac truong ck ve 0 va insert vao setran
            UPDATE semast
            SET margin=0,wtrade=0,mortage=0,BLOCKED=0,secured=0,repo=0,netting=0,dtoclose=0,withdraw=0
            -- WHERE acctno=v_dbseacctno;
            WHERE acctno= rec.acctno;
            l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'3351','SE','0040','0002');

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0083',/*v_MARGIN*/rec.MARGIN,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

             INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0080',/*v_WTRADE*/rec.WTRADE,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0066',/*v_MORTAGE*/rec.MORTAGE,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0044',/*v_BLOCKED*/rec.BLOCKED ,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0088',/*v_BLOCKWITHDRAW*/rec.BLOCKWITHDRAW,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0090',/*v_blockdtoclose*/rec.blockdtoclose,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);


            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0018',/*v_SECURED*/rec.SECURED,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0084',/*v_REPO*/rec.REPO,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0020',/*v_NETTING*/rec.NETTING,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

             INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO, TXCD, NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0071',/*v_DTOCLOSE*/rec.DTOCLOSE,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),/*v_dbseacctno*/rec.acctno,
            '0042',/*v_WITHDRAW*/rec.WITHDRAW,NULL,p_txmsg.txfields ('01').value,
            p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);

            --Cap nhat giam TRADE cho tieu khoan khac tieu khoan chot quyen
            if (rec.acctno <> v_dbseacctno and rec.TRADE <> 0) then
                UPDATE SEMAST
                 SET
                   DDROUTQTTY = DDROUTQTTY + (ROUND(rec.TRADE,0)),
                   TRADE = TRADE - (ROUND(rec.TRADE,0)), LAST_CHANGE = SYSTIMESTAMP
                WHERE ACCTNO = rec.acctno;

                INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.acctno,'0068',ROUND(rec.TRADE,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

                l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'3351','SE','0040','0002');
                INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.acctno,'0040',ROUND(rec.TRADE,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

            end if;
        end loop;

      ELSE -- xoa jao dich
        -- lay du lieu trong setran_gen de revert
        UPDATE CAMAST SET cancelstatus = 'N', STATUS = 'I'
        WHERE CAMASTID = p_txmsg.txfields('02').value AND CATYPE IN ('023','020');

        plog.error (pkgctx, 'txnum | txdate : ' || p_txmsg.txnum || '|' ||  to_char(p_txmsg.txdate));
        for rec in (
            select se.*
            from semast se, (
                    select DISTINCT acctno from setran WHERE NAMT <> 0 AND txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
                ) tr
            where se.acctno = tr.acctno

        ) loop
            SELECT nvl(namt,0) INTO v_margin FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0083';

            SELECT nvl(namt,0) INTO v_WTRADE FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0080';

            SELECT nvl(namt,0) INTO v_MORTAGE FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0066';


            SELECT nvl(namt,0) INTO v_SECURED FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0018';

            SELECT nvl(namt,0) INTO v_REPO FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0084';

            SELECT nvl(namt,0) INTO v_NETTING FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0020';

            SELECT nvl(namt,0) INTO v_DTOCLOSE FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0071';

            SELECT nvl(namt,0) INTO v_WITHDRAW FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0042';

            SELECT nvl(namt,0) INTO v_BLOCKED FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0044';

            SELECT nvl(namt,0) INTO v_blockwithdraw FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0088';

            SELECT nvl(namt,0) INTO v_blockdtoclose FROM setran
            WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
            AND acctno=/*v_dbseacctno*/ rec.acctno AND txcd='0090';
            -- revert du lieu
            UPDATE semast
            SET margin=margin+v_margin,wtrade=wtrade+v_wtrade,
            mortage=mortage+v_mortage,BLOCKED=BLOCKED+v_BLOCKED,
            secured=secured+v_secured,repo=repo+v_repo,netting=netting+v_netting,
            dtoclose=dtoclose+v_dtoclose,withdraw=withdraw+v_withdraw,
            blockwithdraw=blockwithdraw+v_blockwithdraw,
            blockdtoclose=blockdtoclose+v_blockdtoclose
            WHERE acctno= /*v_dbseacctno*/ rec.acctno;

        end loop;

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
         plog.init ('TXPKS_#3351EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3351EX;
/
