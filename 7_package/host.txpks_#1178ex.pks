SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1178ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1178EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      24/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1178ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_acctno           CONSTANT CHAR(2) := '03';
   c_rrtype           CONSTANT CHAR(2) := '44';
   c_actype           CONSTANT CHAR(2) := '46';
   c_ciacctno         CONSTANT CHAR(2) := '43';
   c_bankid           CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '90';
   c_advamt           CONSTANT CHAR(2) := '09';
   c_amt              CONSTANT CHAR(2) := '10';
   c_maxamt           CONSTANT CHAR(2) := '20';
   c_days             CONSTANT CHAR(2) := '13';
   c_txdate           CONSTANT CHAR(2) := '42';
   c_ordate           CONSTANT CHAR(2) := '08';
   c_intrate          CONSTANT CHAR(2) := '12';
   c_bnkrate          CONSTANT CHAR(2) := '15';
   c_feeamt           CONSTANT CHAR(2) := '11';
   c_bnkfeeamt        CONSTANT CHAR(2) := '14';
   c_cmpminbal        CONSTANT CHAR(2) := '16';
   c_bnkminbal        CONSTANT CHAR(2) := '17';
   c_vatamt           CONSTANT CHAR(2) := '18';
   c_vat              CONSTANT CHAR(2) := '19';
   c_cidrawndown      CONSTANT CHAR(2) := '96';
   c_bankdrawndown    CONSTANT CHAR(2) := '97';
   c_cmpdrawndown     CONSTANT CHAR(2) := '98';
   c_autodrawndown    CONSTANT CHAR(2) := '95';
   c_3600             CONSTANT CHAR(2) := '40';
   c_adtxnum          CONSTANT CHAR(2) := '99';
   c_100              CONSTANT CHAR(2) := '41';
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
v_stractype varchar2(10);
v_dbladvminbal number(20,0);
v_dbladvmaxbal  number(20,0);
v_dbladvminbank number(20,0);
v_dbladfminfee  number(20,0);
v_dbladvmaxfee  number(20,0);
v_dbladvminfeebank number(20,0);

v_dbladvrate    number;
v_dblvatrate    number;
v_dbladvbankrate number;
v_days number;
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
    if p_txmsg.deltd <>'Y' then
        for rec in (
            select *  from adschd where autoid = p_txmsg.txfields('01').value
        )
        loop
            --Lay thong tin ve loai hinh UT moi
            select actype, advminamt, advmaxamt, advminbank, advminfee, advmaxfee, advrate, vatrate, advbankrate,advminfeebank
                into v_stractype, v_dbladvminbal, v_dbladvmaxbal, v_dbladvminbank, v_dbladfminfee,
                v_dbladvmaxfee, v_dbladvrate, v_dblvatrate, v_dbladvbankrate,v_dbladvminfeebank
            from adtype where actype = p_txmsg.txfields('06').value;
            --Kiem tra loai hinh UT moi phai khac loai hinh UT cu
            if v_stractype = rec.adtype then
               p_err_code := '-400132'; --Loai hinh ung moi phai khac loai hinh ung cu
               plog.setendsection (pkgctx, 'fn_txAftAppCheck');
               RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
            v_days:=to_number(rec.cleardt- rec.txdate);
            --Kiem tra phi UT moi khong duoc lon hon phi UT cu
            if greatest (v_dbladfminfee,  v_days * rec.amt*v_dbladvrate/36500)
               > rec.feeamt then

               p_err_code := '-400131'; --Ung qua so tien duoc phep
               plog.setendsection (pkgctx, 'fn_txAftAppCheck');
               RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
            --Kiem tra gia tri ung phai lon hon gia tri ung toi thieu va nho hon gia tri ung toi da
            if rec.amt + rec.feeamt  < v_dbladvminbal or rec.amt + rec.feeamt > v_dbladvmaxbal then
               p_err_code := '-400133'; --Ung ngoai pham vi duoc phep ung
               plog.setendsection (pkgctx, 'fn_txAftAppCheck');
               RETURN errnums.C_BIZ_RULE_INVALID;
            end if;

        end loop;
    end if;


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
v_stradsautoid number(20,0);
v_strorgtxnum varchar2(20);
v_strorgtxdate varchar2(10);
v_strrrtype varchar2(10);
v_strciacctno   varchar2(20);
v_strcustbank   varchar2(20);
v_stractype varchar2(10);
v_dbladvminbal number(20,0);
v_dbladvmaxbal  number(20,0);
v_dbladvminbank number(20,0);
v_dbladfminfee  number(20,0);
v_dbladvmaxfee  number(20,0);
v_dbladvrate    number;
v_dblvatrate    number;
v_dbladvbankrate number;
v_dbladvminfeebank number(20,0);

v_dblNewFeeamt number(20,0);
v_dblNewFeebank number(20,0);
v_dblNewfee number(20,0);
v_days number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if p_txmsg.deltd <>'Y' then
        --TungNT added ,xoa yeu cau cu di de tao yeu cau moi
        v_stradsautoid:=p_txmsg.txfields('01').value;
        plog.debug(pkgctx,'adsautoid:'||v_stradsautoid);
        BEGIN
            SELECT ADS.TXNUM,TO_DATE(ADS.TXDATE,'DD/MM/RRRR')
            INTO v_strorgtxnum,v_strorgtxdate
            FROM ADSCHD ADS WHERE ADS.AUTOID=v_stradsautoid;
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx,'Khong tim thay ma giao dich cu');
        END;

        plog.debug(pkgctx,'orgtxnum:'||v_strorgtxnum);
        plog.debug(pkgctx,'orgtxdate:'||v_strorgtxdate);

        IF v_strorgtxnum is not NULL THEN
            UPDATE CRBTXREQ SET STATUS='D' WHERE OBJNAME='1153'
            AND OBJKEY=v_strorgtxnum AND TXDATE=TO_DATE(v_strorgtxdate,'DD/MM/RRRR');
        END IF;
        --End

        for rec in (
            select *  from adschd where autoid = p_txmsg.txfields('01').value
        )
        loop
            --Lay thong tin ve loai hinh UT moi
            select rrtype,ciacctno,custbank,actype, advminamt, advmaxamt, advminbank, advminfee, advmaxfee, advrate, vatrate, advbankrate,advminfeebank
                into v_strrrtype,v_strciacctno,v_strcustbank,v_stractype, v_dbladvminbal, v_dbladvmaxbal, v_dbladvminbank, v_dbladfminfee,
                v_dbladvmaxfee, v_dbladvrate, v_dblvatrate, v_dbladvbankrate, v_dbladvminfeebank
            from adtype where actype = p_txmsg.txfields('06').value;
            --Cap nhat vao ADSCHD
            v_days:=to_number(rec.cleardt- rec.txdate);
            v_dblNewFeeamt:=greatest (v_dbladfminfee, v_days * rec.amt*v_dbladvrate/36500);
            v_dblNewFeebank:=greatest (v_dbladvminfeebank, v_days * rec.amt*v_dbladvbankrate/36500);
            update adschd set feeamt = v_dblNewFeeamt,
                              vatamt = v_dblNewFeeamt * v_dblvatrate,
                              bankfee =v_dblNewFeebank ,
                              rrtype = v_strrrtype, ciacctno =v_strciacctno, custbank=v_strcustbank,
                              adtype = p_txmsg.txfields('06').value
                   where autoid = rec.autoid;

            --Cap nhat lai vao STSCHD, ADSCHDDTL
            v_dblNewfee:=rec.feeamt -v_dblNewFeeamt;
            if v_dblNewfee>0 then
                for rec1 in (
                    select sts.*, dtl.autoid dtlautoid from stschd sts,adschddtl dtl where dtl.txnum = rec.txnum and dtl.txdate = rec.txdate
                    and sts.orgorderid= dtl.orderid
                    and sts.duetype ='RM'
                    order by sts.aamt - sts.amt desc
                )
                loop
                    if rec1.aamt > v_dblNewfee then
                        update stschd set aamt = aamt - v_dblNewfee
                        where autoid = rec1.autoid;
                        update adschddtl set aamt = aamt - v_dblNewfee where autoid= rec1.dtlautoid;
                        exit when 1=1 ;
                    else
                        v_dblNewfee:=v_dblNewfee-rec1.aamt;
                    end if;
                end loop;
            end if;

        end loop;
    end if;

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
         plog.init ('TXPKS_#1178EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1178EX;

/
