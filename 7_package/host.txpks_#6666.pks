SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6666
/** ----------------------------------------------------------------------------------------------------
 ** Module: TX
 ** Description: Transfer sale fee
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      04/09/2014     Created
 ** (c) 2008 by Financial Software Solutions. JSC.
 ----------------------------------------------------------------------------------------------------*/
IS

FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
FUNCTION fn_BatchTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
FUNCTION fn_txrevert(p_txnum varchar2,p_txdate varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#6666
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

PROCEDURE pr_txlog(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
IS
   v_count number;
BEGIN
plog.setbeginsection (pkgctx, 'pr_txlog');
   plog.debug(pkgctx, 'abt to insert into tllog, txnum: ' || p_txmsg.txnum);
   select count(1) into v_count from tllog where txnum = p_txmsg.txnum;
   if v_count=0 then
      INSERT INTO tllog(autoid, txnum, txdate, txtime, brid, tlid,offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line, deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts, ovrsts, batchname, msgamt,msgacct, chktime, offtime, reftxnum)
          VALUES(
          seq_tllog.NEXTVAL,
          p_txmsg.txnum,
          TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
          p_txmsg.txtime,
          p_txmsg.brid,
          p_txmsg.tlid,
          p_txmsg.offid,
          p_txmsg.ovrrqd,
          p_txmsg.chid,
          p_txmsg.chkid,
          p_txmsg.tltxcd,
          p_txmsg.ibt,
          p_txmsg.brid2,
          p_txmsg.tlid2,
          p_txmsg.ccyusage,
          p_txmsg.off_line,
          p_txmsg.deltd,
          TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
          TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),
          NVL(p_txmsg.txfields('30').value,p_txmsg.txdesc),
          p_txmsg.ipaddress,
          p_txmsg.wsname,
          p_txmsg.txstatus,
          p_txmsg.msgsts,
          p_txmsg.ovrsts,
          p_txmsg.batchname,
          p_txmsg.txfields('10').value ,
          p_txmsg.txfields('03').value ,
          TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.chkid,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.chkid)),
          TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.offtime)),
          p_txmsg.reftxnum);


       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'06',0,p_txmsg.txfields('06').value,'Transfer type');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'08',0,p_txmsg.txfields('08').value,'Due date');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'03',0,p_txmsg.txfields('03').value,'RM Account No');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'90',0,p_txmsg.txfields('90').value,'Fullname');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'91',0,p_txmsg.txfields('91').value,'Address');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'92',0,p_txmsg.txfields('92').value,'License');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'93',0,p_txmsg.txfields('93').value,'Bank acctno');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'05',0,p_txmsg.txfields('05').value,'Destination account');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'07',0,p_txmsg.txfields('07').value,'Destination account name');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'94',0,p_txmsg.txfields('94').value,'Bank name');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'95',0,p_txmsg.txfields('95').value,'Bank queue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'10',TO_NUMBER(p_txmsg.txfields('10').value),NULL,'Hold Amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'04',0,p_txmsg.txfields('04').value,'Order id');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'11',0,p_txmsg.txfields('11').value,'So hieu giao dich 8856');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'30',0,p_txmsg.txfields('30').value,'Description');
          plog.debug(pkgctx,'Check if neccessary to poplulate FEETRAN and VATTRAN');
      IF p_txmsg.txinfo.exists(txnums.C_TXINFO_VATTRAN) THEN
          plog.debug(pkgctx,'Abt to insert into VATTRAN');
          INSERT INTO VATTRAN (AUTOID,TXNUM,TXDATE,VOUCHERNO,VOUCHERTYPE,SERIENO,VOUCHERDATE,CUSTID,TAXCODE,CUSTNAME,ADDRESS,CONTENTS,QTTY, PRICE,AMT,VATRATE,VATAMT,DESCRIPTION,DELTD)
          VALUES (
              SEQ_VATTRAN.NEXTVAL,
              p_txmsg.txnum,
              TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERNO), -- voucherno
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERTYPE), -- vouchertype
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_SERIALNO), -- serieno
              TO_DATE(p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERDATE),systemnums.C_DATE_FORMAT), --voucherdate
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CUSTID ), -- CUSTID
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_TAXCODE ), -- TAXCODE
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CUSTNAME ), -- CUSTNAME
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_ADDRESS ), -- ADDRESS
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CONTENTS ), -- CONTENTS
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_QTTY ), -- QTTY
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_PRICE ), -- PRICE
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_AMT ), -- AMT
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VATRATE ), -- VATRATE
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VATAMT ), -- VATAMT
              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_DESCRIPTION ), -- DESCRIPTION
              txnums.C_DELTD_TXNORMAL);
      END IF;
          plog.debug(pkgctx,'Abt to insert into FEETRAN');
      IF p_txmsg.txinfo.exists(txnums.C_TXINFO_FEETRAN ) THEN
           INSERT INTO FEETRAN(AUTOID,TXDATE,TXNUM,DELTD,FEECD,GLACCTNO,FEEAMT,VATAMT,TXAMT,FEERATE,VATRATE)
           VALUES (
               SEQ_FEETRAN.NEXTVAL,
               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
               p_txmsg.txnum, --TXNUM
               txnums.C_DELTD_TXNORMAL,
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN )(txnums.C_FEETRAN_FEECD),  --FEECD
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_GLACCTNO),  --GLACCTNO
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_FEEAMT),  --FEEAMT
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_VATAMT),  --VATAMT
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_TXAMT),  --TXAMT
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_FEERATE),  --FEERATE
               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_VATRATE)); --VATRATE
      END IF;
   Else
               txpks_txlog.pr_update_status(p_txmsg);
   End if;
   plog.setendsection (pkgctx, 'pr_txlog');
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'pr_txlog');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_txlog;--


PROCEDURE pr_PrintInfo(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
IS
   l_sectype  semast.actype%TYPE;
   l_codeid varchar2(6);
   l_acctno varchar2(30);
   l_custid afmast.custid%TYPE;
   l_afacctno afmast.acctno%TYPE;
   l_count NUMBER(10):= 0;
BEGIN
   plog.setbeginsection (pkgctx, 'pr_PrintInfo');


    --<<BEGIN OF PROCESS CIMAST>>
    l_acctno := p_txmsg.txfields('03').value;
    SELECT count(*) INTO l_count
    FROM CIMAST
    WHERE ACCTNO= l_acctno;

    IF l_count = 0 THEN
        p_err_code := errnums.C_PRINTINFO_ACCTNOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END IF;
    BEGIN
         SELECT FULLNAME CUSTNAME, ADDRESS, IDCODE LICENSE, CUSTODYCD
         INTO p_txmsg.txPrintInfo('03').custname,p_txmsg.txPrintInfo('03').address,p_txmsg.txPrintInfo('03').license,p_txmsg.txPrintInfo('03').custody
         FROM CFMAST A
         WHERE EXISTS (
             SELECT 1 FROM CIMAST
             WHERE CUSTID=A.CUSTID
             AND ACCTNO = l_acctno
         );
    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END;
    --<<END OF PROCESS CIMAST>>


    plog.setendsection (pkgctx, 'pr_PrintInfo');
END pr_PrintInfo;

FUNCTION fn_txAppAutoCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN  NUMBER IS
   l_allow         boolean;

    l_allowcorebank apprules.field%TYPE;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppAutoCheck');
   IF p_txmsg.deltd = 'N' THEN

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('03').value,'CIMAST','03','6666')<>'TRUE' then
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');

     l_ALLOWCOREBANK := l_CIMASTcheck_arr(0).ALLOWCOREBANK;

     IF NOT ( INSTR('Y',l_ALLOWCOREBANK) > 0) THEN
        p_err_code := '-400111';
plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

    END IF;
   plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
  WHEN others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppAutoCheck;

FUNCTION fn_txAppAutoUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN  NUMBER
IS
l_txdesc VARCHAR2(1000);
BEGIN
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction



      UPDATE CIMAST
         SET
           LASTDATE = to_date(TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), 'DD/MM/RRRR'), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;

   ELSE -- Reversal
      UPDATE TLLOG
        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);




      UPDATE CIMAST
      SET
           LASTDATE=to_date(TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'DD/MM/RRRR'), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;

   END IF;
   plog.setendsection (pkgctx, 'fn_txAppAutoUpdate');
   RETURN systemnums.C_SUCCESS ;
EXCEPTION
  WHEN others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAppAutoUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppAutoUpdate;


FUNCTION fn_GenBankRequest(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
   TYPE v_CurTyp  IS REF CURSOR;
    c0        v_CurTyp;
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
   v_lngREQID number;
BEGIN
       plog.setbeginsection (pkgctx, 'fn_genBankRequest');
       plog.debug (pkgctx, '<<BEGIN OF fn_GenBankRequest');
       v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
       l_lngErrCode:=0;
       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
           select (case when corebank ='Y' then corebank else alternateacct end) corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
           if v_strCOREBANK ='N' then
               return l_lngErrCode;
           end if;
           --Begin Gen yeu cau sang ngan hang 6666-TRFODSFEE
           v_strOBJTYPE:='T';
           v_strREFCODE:=p_txmsg.txfields('04').value;
           v_strAFFECTDATE:=p_txmsg.txfields('08').value;
           v_strTRFCODE:='TRFODSFEE';
           v_strBANK:=p_txmsg.txfields('95').value;
           v_strBANKACCT:=p_txmsg.txfields('93').value;
           v_strNOTES:=p_txmsg.txfields('30').value;
           v_strVALUE:=p_txmsg.txfields('10').value;
           if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then
               --Ghi nhan vao CRBTXREQ
               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
               INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                   VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                           v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

               --Dr HoldBalance transfer amount
               update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;
               INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0012',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');

               --Gen detail request to bankSECACCOUNT
               v_strFLDNAME:='SECACCOUNT';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$03';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankBANKACCTNO
               v_strFLDNAME:='BANKACCTNO';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$93';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankORDERID
               v_strFLDNAME:='ORDERID';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$04';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankTXNUM
               v_strFLDNAME:='TXNUM';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$11';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankCUSTNAME
               v_strFLDNAME:='CUSTNAME';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$90';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankDESACCTNO
               v_strFLDNAME:='DESACCTNO';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$05';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankDESACCTNAME
               v_strFLDNAME:='DESACCTNAME';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$07';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;


               --Gen detail request to bankBANKNAME
               v_strFLDNAME:='BANKNAME';
               v_strFLDTYPE:='C';
               v_strAMTEXP:='$94';
               v_strSQL:='';
               v_strVALUE := substr(v_strAMTEXP, 2);
               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;

               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,
                   case when v_strFLDTYPE='N' then '' else to_char(v_strVALUE) end,
                   case when v_strFLDTYPE<>'N' then 0 else to_number(v_strVALUE) end
                   from dual;

           End if;
       else
           v_strTRFCODE:='TRFODSFEE';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('10').value;
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

               --Revert Cr Balance transfer amount
               update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;
           exception when others then
               null; --Khong co bang ke can xoa
           end;
       End if;
   plog.debug (pkgctx, '<<END OF fn_GenBankRequest');
   plog.setendsection (pkgctx, 'fn_GenBankRequest');
   RETURN l_lngErrCode;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_GenBankRequest');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_genBankRequest;

FUNCTION fn_txAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppUpdate');
-- Run Pre Update
   IF txpks_#6666EX.fn_txPreAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run Auto Update
   IF fn_txAppAutoUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run send bank request
   IF fn_GenBankRequest(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run After Update
   IF txpks_#6666EX.fn_txAftAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'Begin of updating pool and room');
   IF txpks_prchk.fn_txAutoUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAppUpdate');
        Return errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'End of updating pool and room');
   plog.setendsection (pkgctx, 'fn_txAppUpdate');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppUpdate;

FUNCTION fn_txAppCheck(p_txmsg in out tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppCheck');
-- Run Pre check
   IF txpks_#6666EX.fn_txPreAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run Auto check
   IF fn_txAppAutoCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run After check
   IF txpks_#6666EX.fn_txAftAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'Begin of checking pool and room');
   IF txpks_prchk.fn_txAutoCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAppCheck');
        Return errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'End of checking pool and room');
   plog.setendsection (pkgctx, 'fn_txAppCheck');
   RETURN SYSTEMNUMS.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAppCheck');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txAppCheck;

FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;
   l_txmsg tx.msg_rectype;
   l_count NUMBER(3);
   l_approve BOOLEAN := FALSE;
   l_status VARCHAR2(1);
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txProcess');
   SELECT count(*) INTO l_count
   FROM SYSVAR
   WHERE GRNAME='SYSTEM'
   AND VARNAME='HOSTATUS'
   AND VARVALUE= systemnums.C_OPERATION_ACTIVE;
   IF l_count = 0 THEN
       p_err_code := errnums.C_HOST_OPERATION_ISINACTIVE;
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   plog.debug(pkgctx, 'xml2obj');
   l_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg);
   l_count := 0; -- reset counter
   SELECT count(*) INTO l_count
   FROM SYSVAR
   WHERE GRNAME='SYSTEM'
   AND VARNAME='CURRDATE'
   AND TO_DATE(VARVALUE,systemnums.C_DATE_FORMAT)= l_txmsg.txdate;
   IF l_count = 0 THEN
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_BRANCHDATE_INVALID;
   END IF;
   plog.debug(pkgctx, 'l_txmsg.txaction: ' || l_txmsg.txaction);
   l_status:= l_txmsg.txstatus;
   --GHI NHAN DE TRANH DOUBLE HACH TOAN GIAO DICH
   pr_lockaccount(l_txmsg,p_err_code);
   if p_err_code <> 0 then
       pr_unlockaccount(l_txmsg);
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_SYSTEM_ERROR;
   end if;
   -- <<BEGIN OF PROCESSING A TRANSACTION>>
   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txdeleting THEN
       txpks_txlog.pr_update_status(l_txmsg);
       IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND length(l_txmsg.ovrrqd)> 0 THEN
           IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
               p_err_code := errnums.C_CHECKER1_REQUIRED;
           ELSE
               p_err_code := errnums.C_CHECKER2_REQUIRED;
           END IF;
           plog.setendsection (pkgctx, 'fn_txProcess');
           pr_unlockaccount(l_txmsg);
           RETURN l_return_code;
       END IF;
    END IF;
   IF l_txmsg.deltd = txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txcompleted THEN
       -- if Refuse a delete tx then update tx status
       txpks_txlog.pr_update_status(l_txmsg);
       plog.setendsection (pkgctx, 'fn_txProcess');
       pr_unlockaccount(l_txmsg);
       RETURN l_return_code;
   END IF;
   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED THEN
       plog.debug(pkgctx, '<<BEGIN PROCESS NORMAL TX>>');
       plog.debug(pkgctx, 'l_txmsg.pretran: ' || l_txmsg.pretran);
       IF l_txmsg.pretran = 'Y' THEN
           IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
               RAISE errnums.E_BIZ_RULE_INVALID;
           END IF;
           pr_PrintInfo(l_txmsg, p_err_code);
           IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN
               IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
                   p_err_code := errnums.C_CHECKER1_REQUIRED;
               ELSE
                   p_err_code := errnums.C_CHECKER2_REQUIRED;
               END IF;
           END IF;
           IF Length(Trim(Replace(l_txmsg.ovrrqd, errnums.C_CHECKER_CONTROL, ''))) > 0 AND (NVL(l_txmsg.chkid,'$NULL$') = '$NULL$' OR Length(l_txmsg.chkid) = 0) Then
               p_err_code := errnums.C_CHECKER1_REQUIRED;
           ELSE
               IF InStr(l_txmsg.ovrrqd, errnums.OVRRQS_CHECKER_CONTROL) > 0 AND ( NVL(l_txmsg.offid,'$NULL$') = '$NULL$' OR length(l_txmsg.offid) = 0) THEN
                   p_err_code := errnums.C_CHECKER2_REQUIRED;
               ELSE
                   p_err_code := systemnums.C_SUCCESS;
               End IF;
           End IF;
       ELSE --pretran='N'
           plog.debug(pkgctx, 'l_txmsg.nosubmit: ' || l_txmsg.nosubmit);
           IF l_txmsg.nosubmit = '1' THEN
               IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                   RAISE errnums.E_BIZ_RULE_INVALID;
               END IF;
               IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN
                   IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
                       p_err_code := errnums.C_CHECKER1_REQUIRED;
                   ELSE
                       p_err_code := errnums.C_CHECKER2_REQUIRED;
                   END IF;
               END IF;
               IF Length(Trim(Replace(l_txmsg.ovrrqd, errnums.C_CHECKER_CONTROL, ''))) > 0 AND (NVL(l_txmsg.chkid,'$NULL$')='$NULL$' OR Length(l_txmsg.chkid) = 0) THEN
                   p_err_code := errnums.C_CHECKER1_REQUIRED;
               ELSE
                   IF InStr(l_txmsg.ovrrqd, errnums.OVRRQS_CHECKER_CONTROL) > 0 AND (NVL(l_txmsg.offid,'$NULL$')='$NULL$' OR length(l_txmsg.offid) = 0) THEN
                       p_err_code := errnums.C_CHECKER2_REQUIRED;
                   ELSE
                       l_return_code := systemnums.C_SUCCESS;
                   END IF;
               END IF;
           END IF; -- END OF NOSUBMIT=1
           plog.debug(pkgctx, 'l_return_code: ' || l_return_code);
           IF l_return_code = systemnums.C_SUCCESS THEN
               IF NVL(l_txmsg.ovrrqd,'$X$')= '$X$' OR Length(l_txmsg.ovrrqd) = 0 OR (InStr(l_txmsg.ovrrqd, errnums.C_OFFID_REQUIRED) > 0 AND Length(l_txmsg.offid) > 0) OR (Length(Replace(l_txmsg.ovrrqd, errnums.C_OFFID_REQUIRED, '')) > 0 And Length(l_txmsg.chkid) > 0)  THEN
                  l_approve := TRUE;
               END IF;
               plog.debug(pkgctx, 'l_txmsg.ovrrqd: ' || NVL(l_txmsg.ovrrqd,'$NULL$'));
               plog.debug(pkgctx, 'l_approve,txstatus: ' ||  CASE WHEN l_approve=TRUE THEN 'TRUE' ELSE 'FALSE' END || ',' || l_txmsg.txstatus);
               IF l_approve = TRUE AND (l_txmsg.txstatus= txstatusnums.c_txlogged OR l_txmsg.txstatus= txstatusnums.c_txpending) THEN
                    IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                        RAISE errnums.E_BIZ_RULE_INVALID;
                    END IF;
                    IF NVL(l_txmsg.ovrrqd,'$NULL$')<> '$NULL$' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN
                        IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
                            p_err_code := errnums.C_CHECKER1_REQUIRED;
                        ELSE
                            p_err_code := errnums.C_CHECKER2_REQUIRED;
                        END IF;
                    END IF;
                    l_txmsg.txstatus := txstatusnums.c_txcompleted;
                    IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                        RAISE errnums.E_BIZ_RULE_INVALID;
                    END IF;
                    pr_txlog(l_txmsg, p_err_code);
               End IF; -- END IF APPROVE=TRUE
            END IF; -- end of return_code
       END IF; --<<END OF PROCESS PRETRAN>>
   ELSE -- DELETING TX
   -- <<BEGIN OF DELETING A TRANSACTION>>
   -- This kind of tx has not yet updated mast table in the host
   -- Only need update tllog status
      IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
          RAISE errnums.E_BIZ_RULE_INVALID;
      END IF;
   -- <<END OF DELETING A TRANSACTION>>
   END IF;
   plog.debug(pkgctx, 'obj2xml');
   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
   plog.setendsection (pkgctx, 'fn_txProcess');
   pr_unlockaccount(l_txmsg);
   RETURN l_return_code;
EXCEPTION
WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value := p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_txProcess');
      pr_unlockaccount(l_txmsg);
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value :=  p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_txProcess');
      pr_unlockaccount(l_txmsg);
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txProcess;

FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_AutoTxProcess');
   --GHI NHAN DE TRANH DOUBLE HACH TOAN GIAO DICH
   pr_lockaccount(p_txmsg,p_err_code);
   if p_err_code <> 0 then
       pr_unlockaccount(p_txmsg);
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_SYSTEM_ERROR;
   end if;
   IF fn_txAppCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF fn_txAppUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction
       pr_txlog(p_txmsg, p_err_code);
   ELSE    -- Delete transaction
       txpks_txlog.pr_txdellog(p_txmsg,p_err_code);
   END IF;
   plog.setendsection (pkgctx, 'fn_AutoTxProcess');
   pr_unlockaccount(p_txmsg);
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      pr_unlockaccount(p_txmsg);
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      pr_unlockaccount(p_txmsg);
      RETURN errnums.C_SYSTEM_ERROR;
END fn_AutoTxProcess;

FUNCTION fn_BatchTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_BatchTxProcess');
   IF fn_txAppCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF fn_txAppUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
  /* IF fn_txAutoPostmap(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF; */
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction
       pr_txlog(p_txmsg, p_err_code);
   ELSE    -- Delete transaction
       txpks_txlog.pr_txdellog(p_txmsg,p_err_code);
   END IF;

   plog.setendsection (pkgctx, 'fn_BatchTxProcess');
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_BatchTxProcess');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_BatchTxProcess');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_BatchTxProcess;

FUNCTION fn_txrevert(p_txnum varchar2 ,p_txdate varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_txmsg               tx.msg_rectype;
   l_err_param           varchar2(300);
   l_tllog               tx.tllog_rectype;
   l_fldname             varchar2(100);
   l_defname             varchar2(100);
   l_fldtype             char(1);
   l_return              number(20,0);
   pv_refcursor            pkg_report.ref_cursor;
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txrevert');
   OPEN pv_refcursor FOR
   select * from tllog
   where txnum=p_txnum and txdate=to_date(p_txdate,systemnums.c_date_format);
   LOOP
       FETCH pv_refcursor
       INTO l_tllog;
       EXIT WHEN pv_refcursor%NOTFOUND;
       if l_tllog.deltd='Y' then
           p_err_code:=errnums.C_SA_CANNOT_DELETETRANSACTION;
           plog.setendsection (pkgctx, 'fn_txrevert');
           RETURN errnums.C_SYSTEM_ERROR;
       end if;
       l_txmsg.msgtype:='T';
       l_txmsg.local:='N';
       l_txmsg.tlid        := l_tllog.tlid;
       l_txmsg.off_line    := l_tllog.off_line;
       l_txmsg.deltd       := txnums.C_DELTD_TXDELETED;
       l_txmsg.txstatus    := txstatusnums.c_txcompleted;
       l_txmsg.msgsts      := '0';
       l_txmsg.ovrsts      := '0';
       l_txmsg.batchname   := 'DEL';
       l_txmsg.txdate:=to_date(l_tllog.txdate,systemnums.c_date_format);
       l_txmsg.busdate:=to_date(l_tllog.busdate,systemnums.c_date_format);
       l_txmsg.txnum:=l_tllog.txnum;
       l_txmsg.tltxcd:=l_tllog.tltxcd;
       l_txmsg.brid:=l_tllog.brid;
       for rec in
       (
           select * from tllogfld
           where txnum=p_txnum and txdate=to_date(p_txdate,systemnums.c_date_format)
       )
       loop
       begin
           select fldname, defname, fldtype
           into l_fldname, l_defname, l_fldtype
           from fldmaster
           where objname=l_tllog.tltxcd and FLDNAME=rec.FLDCD;

           l_txmsg.txfields (l_fldname).defname   := l_defname;
           l_txmsg.txfields (l_fldname).TYPE      := l_fldtype;

           if l_fldtype='C' then
               l_txmsg.txfields (l_fldname).VALUE     := rec.CVALUE;
           elsif   l_fldtype='N' then
               l_txmsg.txfields (l_fldname).VALUE     := rec.NVALUE;
           else
               l_txmsg.txfields (l_fldname).VALUE     := rec.CVALUE;
           end if;
           plog.debug (pkgctx,'field: ' || l_fldname || ' value:' || to_char(l_txmsg.txfields (l_fldname).VALUE));
       exception when others then
           l_err_param:=0;
       end;
       end loop;
       IF txpks_#6666.fn_AutoTxProcess (l_txmsg,
                                        p_err_code,
                                        p_err_param
          ) <> systemnums.c_success
       THEN
           plog.debug (pkgctx,
           'got error 6666: ' || p_err_code
           );
           ROLLBACK;
           plog.setendsection (pkgctx, 'fn_txrevert');
           RETURN errnums.C_SYSTEM_ERROR;
       END IF;
       p_err_code:=0;
       plog.setendsection (pkgctx, 'fn_txrevert');
       return 0;
       plog.setendsection (pkgctx, 'fn_txrevert');
       p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;
       RETURN errnums.C_SYSTEM_ERROR;
   END LOOP;
   p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;
   plog.setendsection (pkgctx, 'fn_txrevert');
   RETURN errnums.C_SYSTEM_ERROR;
   plog.setendsection (pkgctx, 'fn_txrevert');
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_txrevert');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txrevert');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txrevert;

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
         plog.init ('txpks_#6666',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END txpks_#6666;

/
