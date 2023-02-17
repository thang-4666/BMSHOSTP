SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2624ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2624EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      14/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2624ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_groupid          CONSTANT CHAR(2) := '20';
   c_lnacctno         CONSTANT CHAR(2) := '21';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '57';
   c_address          CONSTANT CHAR(2) := '58';
   c_license          CONSTANT CHAR(2) := '59';
   c_amt              CONSTANT CHAR(2) := '41';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_status varchar2(1);
l_rlsamt number;
v_txdate date;
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
    select STATUS into l_status  from DFGROUP  where GROUPID =  p_txmsg.txfields ('20').VALUE  ;

    IF l_status ='A' THEN
       p_err_code:= -540050;
       RETURN -540050;
    END IF;
    /*
    select ISVSD into l_status  from DFGROUP  where GROUPID =  p_txmsg.txfields ('20').VALUE  ;

    IF l_status ='N' THEN
       p_err_code:= -260036;
       RETURN -260036;
    END IF;
    */

    select txdate into v_txdate from DFGROUP where GROUPID =  p_txmsg.txfields ('20').VALUE  ;

    plog.debug(pkgctx,to_date(p_txmsg.busdate,'DD/MM/RRRR') || '  ' || v_txdate );


    if to_date(p_txmsg.busdate,'DD/MM/RRRR') < v_txdate then
        p_err_code:= -900105;
        RETURN -900105;
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
--l_check varchar2(1);
l_limitchk varchar2(20);
   v_blnREVERSAL boolean;
   l_lngErrCode    number(20,0);
   v_strOBJTYPE    varchar2(100);
   v_strTRFCODE    varchar2(100);
   v_strBANK    varchar2(200);
   v_strAMTEXP    varchar2(200);
   v_strAFACCTNO    varchar2(100);
   v_strREFCODE    varchar2(100);
   v_strBANKACCT    varchar2(100);
   v_strFLDAFFECTDATE    varchar2(100);
   v_strAFFECTDATE    varchar2(100);
   v_strNOTES    varchar2(1000);
   v_strVALUE     varchar2(1000);
   v_strFLDNAME     varchar2(100);
   v_strFLDTYPE     varchar2(100);
   v_strREFAUTOID     number;
   v_strSQL     varchar2(4000);
   v_strStatus char(1);
   v_strCOREBANK    char(1);
   v_strafbankname varchar(100);
   v_strafbankacctno    varchar2(100);
   v_refdorc char(1);
   v_refunhold char(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

       /* --Ghi nhan vao crbdrawndowndtl de len phu luc danh sach chung khoan giai ngan
        for rec in (
            select df.*, sb.symbol,sb.DFREFPRICE from dfmast df, securities_info sb
            where df.codeid = sb.codeid and groupid = p_txmsg.txfields('20').VALUE
        )
        loop
            insert into crbdrawndowndtl
              (trfcode, objkey, txdate,groupid, dfacctno, symbol, qtty,
               mktprice, ratio, price, mktamt, amt,DFREFPRICE)
            values
              ('DFDRAWNDOWN',p_txmsg.txnum, p_txmsg.txdate, rec.groupid, rec.acctno,rec.symbol,rec.dfqtty+rec.rcvqtty+rec.blockqtty+rec.carcvqtty,
              rec.refprice, rec.dfrate, rec.dfprice, rec.refprice * (rec.dfqtty+rec.rcvqtty+rec.blockqtty+rec.carcvqtty), rec.dfprice * (rec.dfqtty+rec.rcvqtty+rec.blockqtty+rec.carcvqtty),rec.DFREFPRICE
              );
        end loop;*/


      p_err_code:=CSPKS_LNPROC.fn_CreateLoanSchedule(p_txmsg.txfields ('21').VALUE ,p_txmsg.txfields ('41').VALUE ,p_err_code);
     -- PhuongHT add
     -- insert vao lnschdlog
      INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML)
      VALUES((SELECT autoid FROM lnschd WHERE reftype='P' AND acctno=p_txmsg.txfields ('21').VALUE ),
       p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), to_number(p_txmsg.txfields ('41').VALUE));
     --end of PhuongHT add

      UPDATE  DFgroup SET STATUS ='A', AMT=AMT+p_txmsg.txfields ('41').VALUE WHERE GROUPID=  p_txmsg.txfields ('20').VALUE  ;

     -- TheNN added, 03-Aug-2012
     -- Them doan log vao bang log de tao bao cao
        if not fn_gen_cl_drawndown_report then
            p_err_code:='-540229';
            plog.setendsection(pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    -- End TheNN added

/*    -- HaiLT cap nhap DFODAMT
    select LIMITCHK into l_check from dftype where actype in (select actype from dfgroup where groupid = p_txmsg.txfields('20').VALUE );

    -- Giai ngan cam co VSD ko ghi nhan DFODAMT
    IF  nvl(l_check,'N') = 'Y' THEN
      UPDATE CIMAST SET DFODAMT = DFODAMT + (ROUND(p_txmsg.txfields('41').value,0))
        WHERE ACCTNO=p_txmsg.txfields('03').value;
    END IF;*/

    --Them doan hach toan DFODAMT
    SELECT limitchk into l_limitchk FROM DFTYPE WHERE ACTYPE IN (
            SELECT ACTYPE fROM DFGROUP WHERE GROUPID= p_txmsg.txfields('20').value);
    if l_limitchk = 'Y' then
         UPDATE CIMAST SET DFODAMT = DFODAMT + (ROUND(p_txmsg.txfields('41').value,0)) WHERE ACCTNO=p_txmsg.txfields('03').value;

         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0072',ROUND(p_txmsg.txfields('41').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


    end if;
    --TuanNH ADD
    --Gent bang ke sang NH
       plog.setbeginsection (pkgctx, 'fn_genBankRequest');
       plog.debug (pkgctx, '<<BEGIN OF fn_GenBankRequest');
       v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
       l_lngErrCode:=0;
       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
           if v_strCOREBANK ='N' then
               return l_lngErrCode;
           end if;
           --Begin Gen yeu cau sang ngan hang 2624-TRFDFRELEASE
           v_strOBJTYPE:='T';
           v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
           v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
           v_strTRFCODE:='TRFDFRELEASE';
           v_strBANK:=v_strafbankname;
           v_strBANKACCT:=v_strafbankacctno;
           v_strNOTES:=p_txmsg.txfields('30').value;
           v_strVALUE:=p_txmsg.txfields('41').value;
           if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then
               --Ghi nhan vao CRBTXREQ
               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
               INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                   VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                           v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

               --Dr HoldBalance transfer amount
               update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;
               INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0011',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
           End if;
       else
           v_strTRFCODE:='TRFDFRELEASE';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('41').value;
           begin
               SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
               if  v_strStatus = 'P' then
                   update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');

                   --Revert Dr HoldBalance transfer amount
                   update cimast set holdbalance = holdbalance + v_strVALUE where acctno = v_strAFACCTNO;

               else
                   plog.setendsection (pkgctx, 'fn_txAppUpdate');
                   p_err_code:=-670101;--Trang thai bang ke khong hop le
                   Return errnums.C_BIZ_RULE_INVALID;
               end if;
           exception when others then
               null; --Khong co bang ke can xoa
           end;
       End if;
    cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code);
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
         plog.init ('TXPKS_#2624EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2624EX;

/
