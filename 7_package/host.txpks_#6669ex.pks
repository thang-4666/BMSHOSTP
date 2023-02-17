SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6669ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6669EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/11/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6669ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_trftype          CONSTANT CHAR(2) := '06';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_secaccount       CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_bankacctno       CONSTANT CHAR(2) := '93';
   c_desacctno        CONSTANT CHAR(2) := '05';
   c_desacctname      CONSTANT CHAR(2) := '07';
   c_bankname         CONSTANT CHAR(2) := '94';
   c_bankque          CONSTANT CHAR(2) := '95';
   c_amount           CONSTANT CHAR(2) := '10';
   c_catxnum          CONSTANT CHAR(2) := '02';
   c_description      CONSTANT CHAR(2) := '30';
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
  l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
  l_BALDEFOVD number;
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

     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');

     l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD + CEIL(l_CIMASTcheck_arr(0).CIDEPOFEEACR);

     IF NOT (to_number(l_BALDEFOVD) >= to_number(p_txmsg.txfields('10').value)) THEN
        p_err_code := '-400110';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;



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
   v_blnREVERSAL boolean;
   v_strOBJTYPE    varchar2(100);
   l_lngErrCode    number(20,0);
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
   l_count NUMBER;
   v_strBANKCODE VARCHAR2(100);
   v_strfullname VARCHAR2(100);
   v_blnTCDT BOOLEAN;
   v_lngREQID number;
   v_strCATXNUM VARCHAR2(100);
   v_bridBIDVHN varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;


     if not v_blnREVERSAL THEN
       v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
          /* select (case when corebank ='Y' then corebank else alternateacct end) corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
           if v_strCOREBANK ='N' then
               return l_lngErrCode;
           end if;*/
           --Begin Gen yeu cau sang ngan hang 6669-$06
           v_strOBJTYPE:='T';
           v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
           v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
           v_strTRFCODE:=p_txmsg.txfields('06').value;
           v_strBANK:=p_txmsg.txfields('95').value;
           v_strBANKACCT:=p_txmsg.txfields('93').value;
           v_strNOTES:=p_txmsg.txfields('30').value;
           v_strVALUE:=p_txmsg.txfields('10').value;
           v_strfullname:=p_txmsg.txfields('90').value;
           v_strCATXNUM:=p_txmsg.txfields('02').value;
           if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 THEN
           --Ghi nhan vao CRBTXREQ
           --Neu dang trong gio giao dich TTDT va trang thai ngan hang la A thi Gen theo duong thu chi dien tu
                   select result into l_count from v_rm_tcdt_checkworkingtime;
              if l_count = 0  AND NVL(v_strCATXNUM,'XXXX') NOT IN ('3354','3350') then
                  select count(1) into l_count from crbbanklist where BANKCODE = fn_getBankcodeByAccount(v_strBANKACCT) ;

                     if l_count >0 then       for rec in (
                                select * from crbbanklist where BANKCODE = fn_getBankcodeByAccount(v_strBANKACCT)
                                   )
                            loop
                                --19/09/2015 DieuNDA: PHS khong phan biet chi nhanh --> mac dinh la TCDTHCM
                               /*if substr(v_strAFACCTNO,1,4) ='0101' then
                                   v_strBANKCODE:='TCDTHCM';
                               elsif substr(v_strAFACCTNO,1,4) ='0001'   then
                                   v_strBANKCODE:='TCDTHN';
                               else
                                   v_strBANKCODE:='TCDT';
                               end if;*/
                               --v_strBANKCODE:='TCDTHCM';
                            --End 19/09/2015

                                select varvalue into v_bridBIDVHN from sysvar where grname='TCDT' and varname='BIDVBRGRPLIST' and rownum <= 1 ;
                                if instr(v_bridBIDVHN,substr(p_txmsg.txfields('03').value,1,4)) > 0 then
                                    v_strBANKCODE:='TCDTHN';
                                else
                                    v_strBANKCODE:='TCDTHCM';
                                end if;


                               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                               INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES, VIA,DIRBANKCODE,DIRBANKNAME,DIRBANKCITY,DIRACCNAME)
                                   VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum,v_strTRFCODE, v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                                           v_strAFACCTNO , to_number(p_txmsg.txfields ('10').VALUE) , v_strBANKCODE,v_strBANKACCT, 'P', NULL,v_strNOTES,'DIR',rec.bankcode,rec.bankname,rec.regional,v_strfullname);
                                 --Dr Balance transfer amount
                               update cimast set balance = balance - to_number(p_txmsg.txfields ('10').VALUE) where acctno = v_strAFACCTNO;
                               INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0011',to_number(p_txmsg.txfields ('10').VALUE),NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');

                               v_blnTCDT:= true;
                               EXIT;
                            end loop;
                          END IF;
                     ELSE -- theo bang ke

               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
               INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                   VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                           v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

               select max(refdorc), max(refunhold) into v_refdorc, v_refunhold from crbdefacct where trfcode = v_strTRFCODE;
               if v_refdorc = 'D' then
                   --Dr Balance transfer amount
                   update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0011',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
               elsif  v_refdorc = 'C' and v_refunhold ='Y' then
                   --Dr HoldBalance transfer amount
                   update cimast set holdbalance = holdbalance - v_strVALUE where acctno = v_strAFACCTNO;
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0051',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
               elsif  v_refdorc = 'C' and v_refunhold ='N' then
                   --Dr HoldBalance transfer amount
                   update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0012',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
               end if;
           End if;
          END IF;
       ELSE

          v_strTRFCODE:='TRFADVAMT';
               v_strAFACCTNO:=p_txmsg.txfields('03').value;
               v_strVALUE:=to_number(p_txmsg.txfields ('10').VALUE); --Revert ca tien ung va phi luon
               begin
                   SELECT STATUS,REQID into v_strStatus,v_lngREQID FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
                   if  v_strStatus in ('P','D') then
                       update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');

                   else
                       begin
                           select mst.status into v_strStatus from crbtrflog mst, crbtrflogdtl dtl where refreqid = v_lngREQID
                                and mst.refbank=dtl.bankcode and mst.trfcode=dtl.trfcode and mst.txdate=dtl.txdate
                                and mst.version=dtl.version and mst.status not in  ('D','B');
                       exception when others then
                           v_strStatus :='X';
                       end;
                       if  v_strStatus ='P' then
                            p_err_code:=-670101;--Trang thai bang ke khong hop le
                            plog.error (pkgctx, 'Error code:' || p_err_code);
                            plog.setendsection (pkgctx, 'fn_txAppUpdate');
                            Return errnums.C_BIZ_RULE_INVALID;
                       end if;
                   end if;

                   --Revert Dr Balance transfer amount
                   update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;
               exception when others then
                   null; --Khong co bang ke can xoa
               end;

        /*   begin
               SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
               if  v_strStatus = 'P' then
                   update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');

                   select max(refdorc), max(refunhold) into v_refdorc, v_refunhold from crbdefacct where trfcode = v_strTRFCODE;
                   if v_refdorc = 'D' then
                       --Revert Dr Balance transfer amount
                       update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;
                   elsif  v_refdorc = 'C' and v_refunhold ='Y' then
                       --Revert Dr HoldBalance transfer amount
                       update cimast set holdbalance = holdbalance + v_strVALUE where acctno = v_strAFACCTNO;
                   elsif  v_refdorc = 'C' and v_refunhold ='N' then
                       --Revert Cr Balance transfer amount
                       update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;
                   end if;

               else
                   plog.setendsection (pkgctx, 'fn_txAppUpdate');
                   p_err_code:=-670101;--Trang thai bang ke khong hop le
                   Return errnums.C_BIZ_RULE_INVALID;
               end if;*/


          /* exception when others then
               null; --Khong co bang ke can xoa
           end;*/
       End if;
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
         plog.init ('TXPKS_#6669EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#6669EX;
/
