SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1120ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1120EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      06/02/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg IN OUT tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#1120ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_dacctno          CONSTANT CHAR(2) := '03';
   c_castbal          CONSTANT CHAR(2) := '87';
   c_fullname         CONSTANT CHAR(2) := '31';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '96';
   c_idplace          CONSTANT CHAR(2) := '97';
   c_custodycd        CONSTANT CHAR(2) := '89';
   c_cacctno          CONSTANT CHAR(2) := '05';
   c_custname2        CONSTANT CHAR(2) := '93';
   c_address2         CONSTANT CHAR(2) := '94';
   c_license2         CONSTANT CHAR(2) := '95';
   c_refid            CONSTANT CHAR(2) := '79';
   c_iddate2          CONSTANT CHAR(2) := '98';
   c_idplace2         CONSTANT CHAR(2) := '99';
   c_amt              CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg IN OUT tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_crcorebank char(1);
v_drcorebank char(1);
v_fcustodycd varchar2(10);
v_tcustodycd varchar2(10);
v_fclass varchar2(10);
v_tclass varchar2(10);
v_balance NUMBER;
v_bchsts    VARCHAR2(4);

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
      --29/01/2018 DieuNDA: Check chan nhap so am
        --Check so am
        if to_number(p_txmsg.txfields('10').value) <= 0  then
            p_err_code := '-100810';
            plog.error (pkgctx, p_err_code || ': Acctno='||p_txmsg.txfields('03').value
                                 ||', Amount='||p_txmsg.txfields('10').value);
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;



    BEGIN
        select corebank into v_crcorebank from afmast where acctno = p_txmsg.txfields('03').value;
    EXCEPTION WHEN OTHERS THEN
        v_crcorebank := 'N';
    END;
    BEGIN
        select corebank into v_drcorebank from afmast where acctno = p_txmsg.txfields('05').value;
    EXCEPTION WHEN OTHERS THEN
        v_drcorebank := 'N';
    END;
    if v_crcorebank ='Y' and v_drcorebank='Y' then
        p_err_code := '-670404';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    --Canh bao neu GD su dung tien ung truoc
        BEGIN
            SELECT nvl(bchsts, 'N') INTO v_bchsts FROM sbbatchsts WHERE bchdate = getcurrdate AND bchmdl = 'SAAFINDAYPROCESS';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_bchsts := 'N';
        END;
        IF v_bchsts = 'Y' then
            SELECT balance INTO v_balance FROM cimast ci WHERE ci.acctno = p_txmsg.txfields('03').value;
            IF p_txmsg.tlid <> '0000' AND p_txmsg.tlid <> '6868' AND p_txmsg.txfields('10').value > v_balance THEN
                p_txmsg.txWarningException('-4001411').value:= cspks_system.fn_get_errmsg('-400141');
                p_txmsg.txWarningException('-4001411').errlev:= '1';
            END IF;
        END IF;

    IF CSPKS_CIPROC.fn_GenRemittanceTrans(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    if p_txmsg.deltd <> 'Y' then
        INSERT INTO CICUSTWITHDRAW (AUTOID,AFACCTNO,REF,TXNUM,TXDATE,AMT,TXDESC)
        VALUES(seq_cicustwithdraw.nextval,p_txmsg.txfields(c_dacctno).value,p_txmsg.txfields(c_refid).value,p_txmsg.txnum,p_txmsg.txdate,to_number(p_txmsg.txfields(c_amt).value),p_txmsg.txdesc);
    else
        DELETE CICUSTWITHDRAW WHERE TXNUM = p_txmsg.txnum AND TXDATE = p_txmsg.txdate;
    end if;
    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');

    -- check chi duoc chuyen noi bo neu tk chuyen va tk dich la tk chuyen dung thi duoc chuyen
    v_fcustodycd:=   p_txmsg.txfields('88').value;
    v_tcustodycd:=   p_txmsg.txfields('89').value;
    select class into v_fclass from cfmast where custodycd = v_fcustodycd;
    select class into v_tclass from cfmast where custodycd = v_tcustodycd;

    if (v_fclass <>'000' and v_tclass <>'000') and v_fcustodycd <> v_tcustodycd then
        p_err_code := '-670416';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     end if;







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
    l_count NUMBER(10);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    -- PhuongHT add
    -- check TK nhan con du tien de revert khong
    IF p_txmsg.deltd = 'Y' THEN
      SELECT COUNT(*) INTO l_count from cimast
      WHERE acctno=  p_txmsg.txfields('05').value
      AND balance < ROUND(p_txmsg.txfields('10').value,0);
      IF l_count > 0 THEN
        p_err_code := '-400210';
        RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;
    END IF;
    -- end of PhuongHT add
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
  v_crcorebank char(1);
    v_drcorebank char(1);
   v_blnREVERSAL boolean;
   l_lngErrCode    number(20,0);
   v_strOBJTYPE    varchar2(100);
   v_strTRFCODE    varchar2(100);
   v_strBANK    varchar2(200);
   v_strAMTEXP    varchar2(200);
   v_strAFACCTNO    varchar2(100);
   v_strDACCTNO    varchar2(100);
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
   v_strDCOREBANK    char(1);
   v_strafbankname varchar(100);
   v_strafbankacctno    varchar2(100);
   v_refdorc char(1);
   v_refunhold char(1);
   v_lngREQID number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    select corebank into v_crcorebank from afmast where acctno = p_txmsg.txfields('03').value;
    select corebank into v_drcorebank from afmast where acctno = p_txmsg.txfields('05').value;
   -- plog.error (pkgctx, 'V_CRCOREBANK '||v_crcorebank);
    --TuanNH add
    --Gent bang ke sang Ngan hang truong hop @-> Thuong
     v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
       l_lngErrCode:=0;
       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;

           --Begin Gen yeu cau sang ngan hang 1120-TRFDTRER
           --Truong hop 1 @-> Thuong
           if v_crcorebank ='Y' and v_drcorebank='N' then
               v_strOBJTYPE:='T';

               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');

               v_strTRFCODE:='TRFDTRER';
               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;
               plog.error (pkgctx, 'v_strBANK 1120 2 '||v_strBANK || 'v_strBANKACCT 1120 2 '||v_strBANKACCT);

               v_strNOTES:=p_txmsg.txfields('30').value;
               v_strVALUE:=p_txmsg.txfields('10').value;
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then
                   --Ghi nhan vao CRBTXREQ
                   select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                   INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                               v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                   --Dr HoldBalance transfer amount
                   update cimast set holdbalance = holdbalance - v_strVALUE where acctno = v_strAFACCTNO;
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0051',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
                 End if;
           end if;
       else
           /*v_strTRFCODE:='TRFDTRER';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('10').value;
           begin
               SELECT STATUS,REQID into v_strStatus,v_lngREQID FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
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
           end;*/

           v_strTRFCODE:='TRFDTRER';
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

               --Revert Dr Balance transfer amount
               update cimast set holdbalance = holdbalance + v_strVALUE where acctno = v_strAFACCTNO;
           exception when others then
               null; --Khong co bang ke can xoa
           end;
       End if;
       --cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code);

    --TuanNH add
    --Gent bang ke sang Ngan hang truong hop Thuong -> @
     v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
       l_lngErrCode:=0;
       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('05').value;
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;

           --Begin Gen yeu cau sang ngan hang 1120-TRFCTRER
           --Truong hop 2 Thuong-> @
           if v_crcorebank ='N' and v_drcorebank='Y' then
               v_strOBJTYPE:='T';
               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strTRFCODE:='TRFCTRER';
               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;
              plog.error (pkgctx, 'v_strBANK 1120 2 '||v_strBANK || 'v_strBANKACCT 1120 2 '||v_strBANKACCT);
               v_strNOTES:=p_txmsg.txfields('30').value;
               v_strVALUE:=p_txmsg.txfields('10').value;
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then
                   --Ghi nhan vao CRBTXREQ
                   select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                   INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                               v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                    UPDATE CIMAST
                    SET
                    BALANCE = BALANCE - (ROUND(p_txmsg.txfields('10').value,0))
                    WHERE ACCTNO=v_strAFACCTNO;
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0011',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
              End if;
           end if;
       else
           /*v_strTRFCODE:='TRFCTRER';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('10').value;
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
           end;*/


           v_strTRFCODE:='TRFCTRER';
           v_strAFACCTNO:=p_txmsg.txfields('05').value;
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

               --Revert Dr Balance transfer amount
               update cimast set BALANCE = BALANCE + v_strVALUE where acctno = v_strAFACCTNO;
           exception when others then
               null; --Khong co bang ke can xoa
           end;

       End if;
    cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code,p_txmsg.tlid);

    -- HaiLT them Insert lai~ moi' vao CIINTTRAN, gd giam tien nen - so tien
    if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
        cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, p_txmsg.txfields('03').value, -p_txmsg.txfields('10').value, p_err_code);
        if p_err_code <> 0 then
            p_err_code := '-400050';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

    end if;

    -- HaiLT them Insert lai~ moi' vao CIINTTRAN, gd tang tien nen + so tien
    if to_date(p_txmsg.busdate,systemnums.c_date_format) < to_date(p_txmsg.txdate,systemnums.c_date_format) then
        cspks_ciproc.pr_CalBackdateFeeAmt(p_txmsg.busdate, p_txmsg.txfields('05').value, p_txmsg.txfields('10').value, p_err_code);
        if p_err_code <> 0 then
            p_err_code := '-400050';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

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
         plog.init ('TXPKS_#1120EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1120EX;
/
