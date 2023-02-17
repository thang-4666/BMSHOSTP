SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3355ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3355EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/02/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3355ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '06';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '04';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_seacctnodr       CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_seacctnocr       CONSTANT CHAR(2) := '05';
   c_trade            CONSTANT CHAR(2) := '10';
   c_blocked          CONSTANT CHAR(2) := '19';
   c_tradedate        CONSTANT CHAR(2) := '07';
   c_type             CONSTANT CHAR(2) := '08';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
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
v_codeid  varchar2(20);
v_wftcodeid  varchar2(20);
V_AUTOID varchar2(20);
v_camastid varchar2(30);
v_blocked NUMBER(20);
v_seacctnocr VARCHAR2(20);
v_seacctnodr VARCHAR2(20);
l_blocked_change NUMBER(20);
V_afacctno varchar2(20);
V_TRQTTY   number(20);
V_QTTY   number(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_codeid := p_txmsg.txfields('01').VALUE;
    V_AUTOID := p_txmsg.txfields('06').VALUE;
    v_blocked:=(ROUND(p_txmsg.txfields('19').value,0));
    v_seacctnocr:=p_txmsg.txfields('05').VALUE;
     v_seacctnodr:=p_txmsg.txfields('03').VALUE;
     V_afacctno := p_txmsg.txfields('02').VALUE;
     V_TRQTTY := (ROUND(p_txmsg.txfields('10').value,0));
     -- neu blocked > 0 thi update vao semastdtl
/*    if(v_blocked> 0) THEN
       l_blocked_change:=0; -- so luong ck da chuyen sang jao dich trong semastdtl
              FOR rec_semastdtl IN
                           (SELECT * FROM semastdtl WHERE acctno= v_seacctnodr
                            AND DELTD <> 'Y' AND status <> 'C' AND qttytype IN ('002','007')
                            ORDER BY autoid )
              LOOP
                if(l_blocked_change <v_blocked) THEN -- neu van chua chuyen het
                     IF ((v_blocked-l_blocked_change)>= rec_semastdtl.qtty) THEN --  neu sl chua chuyen lon hon record dang xet
                        update semastdtl set acctno = v_seacctnocr where autoid = rec_semastdtl.autoid;
                        l_blocked_change:=l_blocked_change+rec_semastdtl.qtty;
                     ELSE -- chi update giam mot phan, ghi them mot dong cho chung khoan jao dich moi
                        UPDATE semastdtl SET qtty=qtty-(v_blocked-l_blocked_change) WHERE autoid=rec_semastdtl.autoid;

                         INSERT INTO SEMASTDTL (ACCTNO,QTTY,QTTYTYPE,TXNUM,TXDATE,DELTD,DFQTTY,STATUS,AUTOID)
                         SELECT v_seacctnocr,(v_blocked-l_blocked_change),qttytype,txnum,txdate,deltd,0,status,sEQ_SEMASTDTL.NEXTVAL
                         FROM semastdtl WHERE autoid=rec_semastdtl.autoid;

                         l_blocked_change:=l_blocked_change+(v_blocked-l_blocked_change);

                     END IF;

                END IF;

                 exit when l_blocked_change >=v_blocked;
              END LOOP;


            INSERT INTO setran (TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,AUTOID,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(p_txmsg.txnum,p_txmsg.txdate,v_seacctnodr,'0082',0,v_seacctnocr,NULL,'N',seq_setran.nextval,NULL,'3355',p_txmsg.txdate,NULL);

    END IF;
*/
    select codeid into v_wftcodeid  from sbsecurities where refcodeid = v_codeid ;
    select camastid into v_camastid from vw_caschd_all  where autoid = V_AUTOID;

    V_TRQTTY := V_TRQTTY+v_blocked;
    V_QTTY := V_TRQTTY;
   /* for rec in
    (
        select autoid, acctno, codeid, qtty, mapqtty, trqtty
        from secmast
        where deltd <> 'Y' and qtty-mapqtty > 0 and ptype = 'I'
            and codeid = v_wftcodeid and acctno =  V_afacctno
    )
    loop
        if(V_QTTY > 0 and V_QTTY >= rec.qtty-rec.mapqtty) then
            update secmast set qtty = qtty-mapqtty, trqtty = trqtty + (qtty-mapqtty), deltd = 'Y'
            where autoid = rec.autoid;
            V_QTTY := V_QTTY-(rec.qtty-rec.mapqtty);
        -----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
            secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, V_afacctno,
             v_codeid, 'D', 'I', NULL, NULL, rec.qtty-rec.mapqtty, p_txmsg.txfields('09').value, 'Y');
        end if;
        if(V_QTTY > 0 and V_QTTY < rec.qtty-rec.mapqtty) then
            update secmast set qtty = qtty-V_QTTY, trqtty = trqtty + V_QTTY
            where autoid = rec.autoid;
            -----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
            secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, V_afacctno,
             v_codeid, 'D', 'I', NULL, NULL, V_QTTY, p_txmsg.txfields('09').value, 'Y');
            V_QTTY := 0;
        end if;
    end loop;*/

    UPDATE CASCHD SET STATUS='W' WHERE AUTOID = V_AUTOID;
    UPDATE CASCHDHIST SET STATUS='W' WHERE AUTOID = V_AUTOID;

    UPDATE SEPITLOG SET CODEID=v_codeid,acctno=p_txmsg.txfields('05').VALUE WHERE CODEID=v_wftcodeid and afacctno =p_txmsg.txfields('02').VALUE
    and camastid =v_camastid;

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
         plog.init ('TXPKS_#3355EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3355EX;
/
