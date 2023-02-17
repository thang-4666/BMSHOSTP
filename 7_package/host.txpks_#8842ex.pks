SET DEFINE OFF;
CREATE OR REPLACE PACKAGE "TXPKS_#8842EX" 
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8842EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      19/08/2013     Created
 **  
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END; 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY TXPKS_#8842EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_orderid          CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_ciacctno         CONSTANT CHAR(2) := '04';
   c_custbank         CONSTANT CHAR(2) := '05';
   c_rrtype           CONSTANT CHAR(2) := '44';
   c_stautoid         CONSTANT CHAR(2) := '09';
   c_adlautoid        CONSTANT CHAR(2) := '19';
   c_txdate           CONSTANT CHAR(2) := '20';
   c_cleardate        CONSTANT CHAR(2) := '21';
   c_codeid           CONSTANT CHAR(2) := '07';
   c_symbol           CONSTANT CHAR(2) := '08';
   c_exectype         CONSTANT CHAR(2) := '22';
   c_matchamt         CONSTANT CHAR(2) := '14';
   c_aamt             CONSTANT CHAR(2) := '10';
   c_feeamt           CONSTANT CHAR(2) := '11';
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

FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_margintype    varchar2(1);
    l_pp            NUMBER;
    l_ADVT0AMT      NUMBER;
    l_aamt          number;
    l_MSVSDADVAMT   NUMBER;
    l_MBLOCK        NUMBER;
    l_baldefovd     number;
    l_advanceline   number;
    l_avladvance   number;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
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
    -- Kiem tra suc mua + BLTM cua tieu khoan phai du de hoan tra ung truoc
    SELECT mr.mrtype, CI.mblock
    INTO l_margintype, l_MBLOCK
    FROM afmast mst, aftype af, mrtype mr, CIMAST CI
    WHERE mst.actype = af.actype
        AND af.mrtype = mr.actype
        AND MST.acctno = CI.afacctno
        AND mst.acctno = p_txmsg.txfields(c_afacctno).value;
    -- Lay suc mua cua TK
    --SELECT getavlpp(p_txmsg.txfields(c_afacctno).value) INTO l_pp FROM dual;

    l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');
    l_PP := l_CIMASTcheck_arr(0).PP;
    l_baldefovd:= l_CIMASTcheck_arr(0).baldefovd;
    l_advanceline:= l_CIMASTcheck_arr(0).advanceline;

    -- Lay han muc BL con lai trong ngay
    l_ADVT0AMT:=0;

    /*IF l_margintype IN ('S','T') THEN

        FOR REC IN
            (
                SELECT nvl(adv.advt0amt,0)ADVT0AMT
                FROM VW_ACCOUNT_ADVT0 adv
                WHERE adv.acctno = p_txmsg.txfields(c_afacctno).value
            )
        LOOP
            l_ADVT0AMT:= NVL( REC.ADVT0AMT,0);
        END LOOP ;

    ELSE
        l_ADVT0AMT := 0;
    END IF;*/


    l_MSVSDADVAMT := 0;
    -- Lay len so tien UT doi voi lenh ban cam co VSD
    IF p_txmsg.txfields(c_exectype).value = 'MS' THEN
        SELECT nvl(sum(adl.aamt - round(ads.feeamt/(ads.amt+ads.feeamt)*adl.aamt)),0) adamt
        INTO l_MSVSDADVAMT
        FROM (SELECT * FROM odmapext UNION ALL SELECT * FROM odmapexthist) odm,
            adschd ads, adschddtl adl, vw_tllog_all tlg, vw_tllogfld_all tlfld
        WHERE odm.orderid = adl.orderid AND odm.isvsd = 'Y'
            AND ads.txdate = adl.txdate AND ads.txnum = adl.txnum
            AND tlg.txdate = tlfld.txdate AND tlg.txnum = tlfld.txnum
            AND tlg.txdate = ads.txdate AND tlg.txnum = ads.txnum
            AND tlfld.fldcd = '60' AND tlfld.cvalue = '1'
            AND adl.orderid = p_txmsg.txfields(c_orderid).value
            AND adl.autoid = to_number(p_txmsg.txfields(c_adlautoid).value);
    END IF;
    IF l_MBLOCK < l_MSVSDADVAMT THEN
        l_MSVSDADVAMT := l_MBLOCK;
    END IF;

    -- Ko cho hoan ung neu thieu tien
    IF NOT (GREATEST(to_number(l_PP),0) + l_ADVT0AMT + l_MSVSDADVAMT >= to_number(ROUND(p_txmsg.txfields(c_aamt).value-p_txmsg.txfields(c_feeamt).value,0))) THEN
        p_err_code := '-400116';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
    -- khong hoan ung qua so tien da ung con lai cua lenh

    select aamt-paidamt INTO l_aamt  from stschd where orgorderid =  p_txmsg.txfields('01').value and duetype ='RM' AND DELTD <>'Y';

    IF p_txmsg.txfields(c_aamt).value > l_aamt   THEN
        p_err_code := '-400220';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    l_avladvance:= 0-( GREATEST(to_number(l_PP),0) + l_ADVT0AMT + l_MSVSDADVAMT - to_number(ROUND(p_txmsg.txfields(c_aamt).value - p_txmsg.txfields(c_feeamt).value,0)) - l_advanceline);
    if l_avladvance>0 then --Tai khoan dang co cap bao lanh
        p_txmsg.txWarningException('-2002121').value:= replace(cspks_system.fn_get_errmsg('-200212'),'<ADVANCED>',to_char(l_avladvance));
        p_txmsg.txWarningException('-2002121').errlev:= '1';
    end if;
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
    l_count NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    -- Kiem tra da co GD nao dc duyet hay chua, neu da co GD 8842 thuc hien roi thi ko cho thuc hien nua
    l_count := 0;
    SELECT count(tl.tltxcd)
    INTO l_count
    FROM tllog tl, tllogfld tlf, tllogfld tlf2
    WHERE tl.txdate = tlf.txdate AND tl.txnum = tlf.txnum
        AND tl.txdate = tlf2.txdate AND tl.txnum = tlf2.txnum
        and tl.tltxcd = '8842' AND tlf.fldcd = c_orderid
        AND tl.msgacct = p_txmsg.txfields(c_afacctno).value
        AND tlf.cvalue = p_txmsg.txfields(c_orderid).value
        AND tlf2.nvalue = to_number(p_txmsg.txfields(c_adlautoid).value);
    IF l_count > 0 THEN
        p_err_code := errnums.C_SA_TRANS_APPROVED;
        plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

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
    l_count         NUMBER;
    l_MSVSDADVAMT   NUMBER;
    l_MBLOCK        NUMBER;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    -- Neu lenh hoan ung la ban cam co VSD thi ghi nhan giam so tien cam co VSD
    l_MSVSDADVAMT := 0;
    -- Lay len so tien UT doi voi lenh ban cam co VSD
    IF p_txmsg.txfields(c_exectype).value = 'MS' THEN
        -- Lay so tien MBLOCK hien tai
        SELECT ci.mblock
        INTO l_MBLOCK
        FROM cimast ci
        WHERE ci.afacctno = p_txmsg.txfields(c_afacctno).value;
        SELECT nvl(sum(adl.aamt - round(ads.feeamt/(ads.amt+ads.feeamt)*adl.aamt)),0) adamt
        INTO l_MSVSDADVAMT
        FROM (SELECT * FROM odmapext UNION ALL SELECT * FROM odmapexthist) odm,
            adschd ads, adschddtl adl, vw_tllog_all tlg, vw_tllogfld_all tlfld
        WHERE odm.orderid = adl.orderid AND odm.isvsd = 'Y'
            AND ads.txdate = adl.txdate AND ads.txnum = adl.txnum
            AND tlg.txdate = tlfld.txdate AND tlg.txnum = tlfld.txnum
            AND tlg.txdate = ads.txdate AND tlg.txnum = ads.txnum
            AND tlfld.fldcd = '60' AND tlfld.cvalue = '1'
            AND adl.orderid = p_txmsg.txfields(c_orderid).value
            AND adl.autoid = to_number(p_txmsg.txfields(c_adlautoid).value);

        IF l_MBLOCK < l_MSVSDADVAMT THEN
            l_MSVSDADVAMT := l_MBLOCK;
        END IF;

        IF l_MSVSDADVAMT > 0 THEN
            --Gent b?ng kê sang NH
            v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
           if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
           if v_strCOREBANK ='Y' then
               --Begin Gen yeu cau sang ngan hang 0088-TRFNML
               v_strOBJTYPE:='T';
               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strTRFCODE:='TRFRLSADV';
                 v_strBANK:=v_strafbankname;
                 v_strBANKACCT:=v_strafbankacctno;
                 v_strNOTES:=p_txmsg.txfields('30').value;
                 v_strVALUE:=p_txmsg.txfields('10').value-p_txmsg.txfields('11').value;
                 if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then
                     --Ghi nhan vao CRBTXREQ
                     select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                     INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                         VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                                 v_strAFACCTNO , v_strVALUE-l_MSVSDADVAMT , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                   update cimast
                   set HOLDBALANCE = HOLDBALANCE -(v_strVALUE-l_MSVSDADVAMT)
                   where acctno = p_txmsg.txfields('03').value;
                   ---UPDATE CITRAN

                  INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                  VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields('03').value,'0051', v_strVALUE-l_MSVSDADVAMT,NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL, p_txmsg.tltxcd,p_txmsg.busdate,utf8nums.c_const_TLTX_TXDESC_0088_FEE);


                     End if;
                 end if;
             else

                 begin
                     SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
                     if  v_strStatus = 'P' then
                         update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');
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
            -- Cap nhat CIMAST
            UPDATE cimast SET
                balance = balance + l_MSVSDADVAMT,
                mblock = mblock - l_MSVSDADVAMT
            WHERE acctno = p_txmsg.txfields(c_afacctno).value;
            -- Ghi nhan CITRAN
            -- 0012: Credit BALANCE
            INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_MSVSDADVAMT,NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
            -- 0053: Debit MBLOCK
            INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0053',l_MSVSDADVAMT,NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        END IF;
    END IF;
  --TuanNH
  --Lenh cam co thuong Gent bang ke sang ngan hang
    IF p_txmsg.txfields(c_exectype).value = 'NS' THEN
       plog.setbeginsection (pkgctx, 'fn_genBankRequest');
       plog.debug (pkgctx, '<<BEGIN OF fn_GenBankRequest');
       v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
       l_lngErrCode:=0;
       if not v_blnREVERSAL then
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           --Kiem tra neu la TK corebank thi tiep tuc
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
           if v_strCOREBANK ='Y' then

           --Begin Gen yeu cau sang ngan hang 8842-TRFADPAID
           v_strOBJTYPE:='T';
           v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
           v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
           v_strTRFCODE:='TRFRLSADV';
           v_strBANK:=v_strafbankname;
           v_strBANKACCT:=v_strafbankacctno;
           v_strNOTES:=p_txmsg.txfields('30').value;
           v_strVALUE:=p_txmsg.txfields('10').value-p_txmsg.txfields('11').value;
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

            end if;
           End if;
       else
           v_strTRFCODE:='TRFRLSADV';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('10').value-p_txmsg.txfields('11').value;
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
   plog.debug (pkgctx, '<<END OF fn_GenBankRequest');
   plog.setendsection (pkgctx, 'fn_GenBankRequest');

    END IF;
    -- Cap nhat tung giao dich ung truoc
    FOR rec IN
    (
        SELECT ADL.txdate, ADL.txnum, ADL.aamt
        FROM adschddtl ADL
        WHERE ADL.orderid = p_txmsg.txfields('01').value
            AND adl.autoid = to_number(p_txmsg.txfields(c_adlautoid).value)
        ORDER BY ADL.txdate, ADL.txnum
    )
    LOOP
        -- UPDATE ADSCHD
        UPDATE ADSCHD SET
            PAIDAMT = PAIDAMT + REC.aamt,
            PAIDDATE = p_txmsg.txdate
        WHERE TXDATE = REC.txdate AND TXNUM = REC.txnum;

        -- UPDATE STSCHD
        UPDATE STSCHD SET
            PAIDAMT = PAIDAMT + REC.aamt
        WHERE DUETYPE = 'RM' AND ORGORDERID = p_txmsg.txfields('01').value;

        -- UPDATE ADSCHDDTL
        UPDATE adschddtl SET
            DELTD = 'Y'
        WHERE TXDATE = REC.txdate AND TXNUM = REC.txnum AND orderid = p_txmsg.txfields('01').value;

    END LOOP;

    -- Kiem tra neu da hoan ung het thi cap nhat ODMAST
    l_count := 0;
    SELECT count(autoid)
    INTO l_count
    FROM adschddtl ADL
    WHERE ADL.orderid = p_txmsg.txfields(c_orderid).value;
    IF l_count = 0 THEN
        UPDATE ODMAST SET
            ERRSTS = 'A', LAST_CHANGE = SYSTIMESTAMP
        WHERE ORDERID=p_txmsg.txfields('01').value;
        INSERT INTO ODTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('01').value,'0051',0,'A','',p_txmsg.deltd,'',seq_ODTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
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
         plog.init ('TXPKS_#8842EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8842EX;

/
