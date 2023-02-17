SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3314ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3314EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/08/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3314ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_reportdate       CONSTANT CHAR(2) := '06';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_rate             CONSTANT CHAR(2) := '10';
   c_status           CONSTANT CHAR(2) := '20';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_camastid varchar2(30);
    l_catype varchar2(30);
    l_count NUMBER;
    l_reportdate DATE;
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
     l_camastid varchar2(30);
    l_catype varchar2(30);
    L_qtty number ;
    L_status varchar2 (300);
    v_txdate varchar2(100);
    l_optcodeid VARCHAR2 (6);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_camastid:= p_txmsg.txfields('03').value;

select catype,optcodeid into l_catype,l_optcodeid  from camast where camastid =l_camastid;


select max(to_char(txdate,'DD/MM/RRRR')) into v_txdate from vw_tllog_all where tltxcd ='3340' and msgacct =l_camastid;

for rec in
(
    /*select tl.txnum , tl.txdate ,se.acctno, se.namt, tlfld.cvalue from vw_tllog_all tl,
     vw_tllogfld_all tlfld, vw_setran_gen se
    where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
    and tl.txnum = se.txnum and tl.txdate= se.txdate
    and tl.tltxcd ='3380'  and  se.tltxcd ='3380'and tlfld.fldcd='02'
    and tlfld.cvalue = l_camastid*/
    select tl.txnum , tl.txdate ,se.acctno, se.namt, tlfld.cvalue, substr(se.acctno,1,10) afacctno from tllogall tl,
     tllogfldall tlfld, setran_gen se
    where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
    and tl.txnum = se.txnum and tl.txdate= se.txdate
    and tl.tltxcd ='3380'  and  se.tltxcd ='3380'and tlfld.fldcd='02'
    AND se.txcd IN ('0015','0016')
    and tlfld.cvalue = l_camastid and tl.txdate=to_date(v_txdate,'DD/MM/RRRR')
    union
    select tl.txnum , tl.txdate ,se.acctno, se.namt, tlfld.cvalue, substr(se.acctno,1,10) afacctno from tllog tl,
     tllogfld tlfld, setran se
    where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
    and tl.txnum = se.txnum and tl.txdate= se.txdate
    AND se.txcd IN ('0015','0016')
    and tl.tltxcd ='3380'  and  se.tltxcd ='3380'and tlfld.fldcd='02'
    and tlfld.cvalue = l_camastid and tl.txdate=to_date(v_txdate,'DD/MM/RRRR')
)
loop
    update  tllog set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  setran set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  tllogall set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  setrana set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  setran_gen set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;

    update semast set receiving = receiving - rec.namt  where acctno = rec.acctno ;

  IF l_catype IN ('014','011','021') THEN
  update semast set trade = trade - rec.namt  where acctno = rec.afacctno||l_optcodeid ;
  END IF;
end loop;



for rec in
(
    /*select tl.txnum , tl.txdate ,  tlfld.cvalue ,tl.msgamt,tl.msgacct
    from vw_tllog_all tl, vw_tllogfld_all tlfld
    where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
    and tl.tltxcd ='3380'  and tlfld.fldcd='02'
    and tlfld.cvalue = l_camastid*/
    select tl.txnum , tl.txdate ,  tlfld.cvalue ,tl.msgamt,tl.msgacct
    from tllogall tl, tllogfldall tlfld
    where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
    and tl.tltxcd ='3380'  and tlfld.fldcd='02'
    and tlfld.cvalue = l_camastid and tl.txdate=to_date(v_txdate,'DD/MM/RRRR')
    union
    select tl.txnum , tl.txdate ,  tlfld.cvalue ,tl.msgamt,tl.msgacct
    from tllog tl, tllogfld tlfld
    where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
    and tl.tltxcd ='3380'  and tlfld.fldcd='02'
    and tlfld.cvalue = l_camastid and tl.txdate=to_date(v_txdate,'DD/MM/RRRR')
)
loop
    update  tllog set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  citran set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  tllogall set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  citrana set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;
    update  citran_gen set deltd ='Y' where txnum = rec.txnum and txdate= rec.txdate ;

    update cimast set receiving = receiving - rec.msgamt  where acctno = rec.msgacct ;

end loop;

IF l_catype ='023' then
L_status :='V';
ELSIF l_catype ='014' THEN
    select SUM (qtty) into L_qtty  from CASCHD where CAMASTID = l_camastid ;
    IF L_qtty >0 THEN
     L_status :='M';
    ELSE
    L_status := 'V';
    END IF;
ELSE
L_status :='A';
END IF ;

--TrungNQ 23/05/2022 phi chuyen khoan
UPDATE CASCHD SET  STATUS =  L_status, TRFFEE=0 WHERE CAMASTID = l_camastid;
UPDATE CAMAST SET  STATUS = L_status, trffeeamt=0 WHERE CAMASTID = l_camastid;
--End TrungNQ

    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppUpdate;

END TXPKS_#3314EX;
/
