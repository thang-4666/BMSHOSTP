SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3384ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3384EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      15/08/2013     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in OUT tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#3384ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '02';
   c_taskcd           CONSTANT CHAR(2) := '16';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_seacctno         CONSTANT CHAR(2) := '06';
   c_exprice          CONSTANT CHAR(2) := '05';
   c_balance          CONSTANT CHAR(2) := '07';
   c_qtty             CONSTANT CHAR(2) := '21';
   c_optseacctno      CONSTANT CHAR(2) := '09';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_status           CONSTANT CHAR(2) := '40';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_iscorebank       CONSTANT CHAR(2) := '60';
   c_description      CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_leader_license varchar2(100);
    l_leader_idexpired date;
    l_member_license varchar2(100);
    l_member_idexpired date;
    l_idexpdays apprules.field%TYPE;
    l_afmastcheck_arr txpks_check.afmastcheck_arrtype;
    l_leader_expired boolean;
    l_member_expired boolean;
    l_country VARCHAR2(5);
    l_count NUMBER;
    v_balance NUMBER;
    v_bchsts  varchar2(4);

    v_begindate      DATE;
    v_dueate         DATE;


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

    -- Dang ky phai trong khoang time cho phep dang ky
    IF p_txmsg.txfields('18').value IS NULL THEN
       v_begindate := p_txmsg.txdate - 1;
    ELSE
       v_begindate := to_date(p_txmsg.txfields('18').value, systemnums.C_DATE_FORMAT);
    END IF;

    IF p_txmsg.txfields('19').value IS NULL THEN
       v_dueate := p_txmsg.txdate + 1;
    ELSE
       v_dueate := to_date(p_txmsg.txfields('19').value, systemnums.C_DATE_FORMAT);
    END IF;

    IF p_txmsg.txdate < v_begindate OR p_txmsg.txdate > v_dueate THEN
       p_err_code := '-300082';
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;



     IF p_txmsg.deltd <> 'Y' THEN
        --29/01/2018 DieuNDA: Check chan nhap so am
        if to_number(p_txmsg.txfields('21').value) <= 0 or to_number(p_txmsg.txfields('05').value) < 0   then
            p_err_code := '-100810';
            plog.error (pkgctx, p_err_code || ': Acctno='||p_txmsg.txfields('03').value
                                 ||', camastid='||p_txmsg.txfields('02').value
                                 ||', Qtty='||p_txmsg.txfields('21').value
                                 ||', Price='||p_txmsg.txfields('05').value);
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        --End 29/01/2018 DieuNDA: Check chan nhap so am
    end if;

    l_leader_expired:= false;
    l_member_expired:= false;
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
    /*
    BEGIN
    select idcode, idexpired, country into l_leader_license, l_leader_idexpired,l_country
    from cfmast cf, afmast af
    where cf.custid = af.custid
    and af.acctno = p_txmsg.txfields(c_afacctno).value;
      EXCEPTION
        WHEN OTHERS
        THEN
              p_err_code := '-900096';
              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
       END ;
    if(l_country='234') THEN
    BEGIN
    select idcode, idexpired into l_member_license, l_member_idexpired
    from cfmast where idcode = p_txmsg.txfields(c_license).value and status <> 'C';
    EXCEPTION
        WHEN OTHERS
        THEN
              p_err_code := '-900096';
              plog.setendsection (pkgctx, 'fn_txPreAppCheck');
              RETURN errnums.C_BIZ_RULE_INVALID;
         END ;
    IF l_leader_idexpired < p_txmsg.txdate THEN --leader expired
        l_leader_expired:=true;
    END IF;

    if l_leader_license <> l_member_license or l_leader_idexpired <> l_member_idexpired then
        if l_member_idexpired < p_txmsg.txdate then
            l_member_expired:=true;
        end if;
    end if;


    if l_leader_expired = true and l_member_expired = true then
        p_txmsg.txWarningException('-2002091').value:= cspks_system.fn_get_errmsg('-200209');
        p_txmsg.txWarningException('-2002091').errlev:= '1';
    else
        if l_leader_expired = true and l_member_expired = false then
            p_txmsg.txWarningException('-2002081').value:= cspks_system.fn_get_errmsg('-200208');
            p_txmsg.txWarningException('-2002081').errlev:= '1';
        elsif l_leader_expired = false and l_member_expired = true then
            p_txmsg.txWarningException('-2002071').value:= cspks_system.fn_get_errmsg('-200207');
            p_txmsg.txWarningException('-2002071').errlev:= '1';
        end if;
    end if;
    end if;
    */
    --Check xem co tieu khoan nao bi call khong
    if not cspks_cfproc.pr_check_Account_Call(p_txmsg.txfields('96').value) then
        p_err_code := '-200900';
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;


 SELECT COUNT(*) into l_count FROM afserisk WHERE ACTYPE =(SELECT actype FROM afmast WHERE acctno = substr(p_txmsg.txfields('09').value,1,10) ) AND CODEID =substr(p_txmsg.txfields('09').value,11) ;

  --IF  l_count >0  THEN
     if txpks_prchk.fn_RoomLimitCheck(substr(p_txmsg.txfields('09').value,1,10), substr(p_txmsg.txfields('09').value,11),
           p_txmsg.txfields('21').value, p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
      end if;
  --END IF ;

    --check truong loai quyen
        /*if p_txmsg.txfields('51').value > 0 and p_txmsg.txfields('53').value > 0 then
            p_err_code := '-300008';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/

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

FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count NUMBER;
    l_availqtty FLOAT;
    l_baldefovd number;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;

    l_mrtype char(1);
    l_outstanding number;
    l_navaccount number;
    l_mrirate number;
    l_mrmrate number;
    l_mrlrate number;
    l_marginrate number;
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
    if p_txmsg.deltd <> 'Y' then
    l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');

    --l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
    l_BALDEFOVD := least(greatest(l_CIMASTcheck_arr(0).pp,l_CIMASTcheck_arr(0).balance + l_CIMASTcheck_arr(0).avladvance) ,l_CIMASTcheck_arr(0).balance + l_CIMASTcheck_arr(0).bamt + l_CIMASTcheck_arr(0).avladvance - l_CIMASTcheck_arr(0).dueamt - l_CIMASTcheck_arr(0).ovamt);
    IF NOT (greatest(to_number(l_BALDEFOVD),0) >= to_number(p_txmsg.txfields('21').value*p_txmsg.txfields('05').value)) THEN
       p_err_code := '-400110';
       plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --Kiem tra sau khi dang ky ty le duoi muc call thi canh bao, duoi muc xu ly thi chan
    l_mrtype:= l_CIMASTcheck_arr(0).mrtype;
    if l_mrtype in ('S','T') then
        l_outstanding :=l_CIMASTcheck_arr(0).se_outstanding - to_number(p_txmsg.txfields('21').value*p_txmsg.txfields('05').value);
        l_navaccount :=l_CIMASTcheck_arr(0).se_navaccount;
        if l_outstanding <0 then
            l_marginrate:= l_navaccount / (- l_outstanding) * 100;
            select af.mrirate, af.mrmrate, af.mrlrate
                into l_mrirate, l_mrmrate,l_mrlrate
            from afmast af where acctno = p_txmsg.txfields('03').value;
            if   l_marginrate < l_mrmrate then
                --Vi pham ty le duy tri 05/10/15
                    p_err_code := '-400502';
                    plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;

              /*  if l_marginrate < l_mrlrate then --Chan lai
                    --Vi pham ty le xu ly
                    p_err_code := '-400500';
                    plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                else --Canh bao
                    --Canh bao do cham muc canh bao
                    p_txmsg.txWarningException('-4005011').value:= cspks_system.fn_get_errmsg('-400501');
                    p_txmsg.txWarningException('-4005011').errlev:= '1';
                end if;*/
            end if;
        end if;
    end if;

    BEGIN
    select PQTTY INTO l_availqtty from CASCHD WHERE CAMASTID= p_txmsg.txfields ('02').VALUE AND AFACCTNO = p_txmsg.txfields ('03').VALUE
                                              AND deltd='N' AND autoid=p_txmsg.txfields ('01').VALUE;
    IF l_availqtty < p_txmsg.txfields ('21').VALUE THEN
        p_err_code:= '-300026';
        RETURN errnums.C_BIZ_RULE_INVALID; -- Chua het ngay cho phep dang ki chuyen nhuong.
    END IF;



 SELECT COUNT(*) into l_count FROM afserisk WHERE ACTYPE =(SELECT actype FROM afmast WHERE acctno = substr(p_txmsg.txfields('09').value,1,10) ) AND CODEID =substr(p_txmsg.txfields('09').value,11) ;

  --IF  l_count >0  THEN
     if txpks_prchk.fn_RoomLimitCheck(substr(p_txmsg.txfields('09').value,1,10), substr(p_txmsg.txfields('09').value,11),
           p_txmsg.txfields('21').value, p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
      end if;
  --END IF ;

    EXCEPTION
    WHEN no_data_found THEN
        p_err_code:= '-300013';
        RETURN errnums.C_BIZ_RULE_INVALID; -- Chua het ngay cho phep dang ki chuyen nhuong.
    END;


    SELECT COUNT(1)
        INTO l_count
    FROM CAMAST CA, SYSVAR SYS
    WHERE SYS.VARNAME = 'CURRDATE'
        AND SYS.GRNAME = 'SYSTEM'
        AND CATYPE = '014'
        AND TO_DATE (VARVALUE,'DD/MM/RRRR') >= BEGINDATE
        AND camastid = p_txmsg.txfields ('02').VALUE;

    IF l_count = 0 THEN
        p_err_code:= '-300046';
        RETURN errnums.C_BIZ_RULE_INVALID; -- Chua het ngay cho phep dang ki chuyen nhuong.
    END IF;

    --IF P_TXMSG.TLID =SYSTEMNUMS.C_ONLINE_USERID THEN
       /*   SELECT COUNT(1)
              INTO l_count
          FROM CAMAST CA, SYSVAR SYS
          WHERE SYS.VARNAME = 'CURRDATE'
              AND SYS.GRNAME = 'SYSTEM'
              AND CATYPE = '014'
              AND TO_DATE (VARVALUE,'DD/MM/RRRR') <= DUEDATE
              AND camastid = p_txmsg.txfields ('02').VALUE;

          IF l_count = 0 THEN
              p_err_code:= '-300045';
              RETURN errnums.C_BIZ_RULE_INVALID; -- Chua het ngay cho phep dang ki chuyen nhuong.
          END IF;*/
    -- ENd IF;
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
           select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
           if v_strCOREBANK ='Y' then

           --Begin Gen yeu cau sang ngan hang 3384-TRFCAREG
           v_strOBJTYPE:='T';
           v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
           v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
           v_strTRFCODE:='TRFCAREG';
           v_strBANK:=v_strafbankname;
           v_strBANKACCT:=v_strafbankacctno;
           --v_strNOTES:=p_txmsg.txfields('30').value;
           v_strNOTES:= utf8nums.c_const_RM_RM3384ex_diengiai_1 || p_txmsg.txfields ('04').VALUE || ',SL ' || p_txmsg.txfields ('21').VALUE || utf8nums.c_const_RM_RM3384ex_gia ||p_txmsg.txfields ('22').VALUE|| ',TK ' || p_txmsg.txfields ('96').VALUE || '';

           v_strVALUE:=p_txmsg.txfields('21').value*p_txmsg.txfields('05').value;
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
           /*v_strTRFCODE:='TRFCAREG';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('21').value*p_txmsg.txfields('05').value;
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
           v_strTRFCODE:='TRFCAREG';
           v_strAFACCTNO:=p_txmsg.txfields('03').value;
           v_strVALUE:=p_txmsg.txfields('21').value*p_txmsg.txfields('05').value;
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
   cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code,p_txmsg.tlid);
   plog.debug (pkgctx, '<<END OF fn_GenBankRequest');
   plog.setendsection (pkgctx, 'fn_GenBankRequest');
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

    l_camastid varchar2(30); --02   CAMASTID      C
    l_afacctno varchar2(30); --03   AFACCTNO      C
    l_symbol varchar2(30); --04   SYMBOL        C
    l_exprice number(20,0); --05   EXPRICE       N
    l_qtty number(20,0); --21   QTTY          N
    l_status varchar2(1); --40   STATUS        C
    -- TRANSACTION
    l_left_rightoffrate varchar2(30);
    l_right_rightoffrate varchar2(30);
    l_VSDSTOCKTYPE varchar2(10);

    l_maxTrade      number;
    l_Trade         number;
    l_maxBlocked    number;
    l_Blocked       number;


BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

        --Get cac field giao dich
        --02   CAMASTID      C
        l_camastid:= p_txmsg.txfields ('02').VALUE;
        --03   AFACCTNO      C
        l_afacctno:= p_txmsg.txfields ('03').VALUE;
        --04   SYMBOL        C
        l_symbol:= p_txmsg.txfields ('04').VALUE;
        --05   EXPRICE       N
        l_exprice:= p_txmsg.txfields ('05').VALUE;
        --21   QTTY          N
        l_qtty:=p_txmsg.txfields ('21').VALUE;
        --40   STATUS        C
        l_status:=p_txmsg.txfields ('40').VALUE;
        l_maxTrade      := FN_GET_PTRADE(l_camastid,p_txmsg.txfields ('24').VALUE,l_afacctno);
        l_maxBlocked    := FN_GET_PTRADE(l_camastid,p_txmsg.txfields ('24').VALUE,l_afacctno);
        l_Blocked := LEAST(l_maxBlocked,l_qtty);
        l_Trade := GREATEST(LEAST(l_maxTrade,l_qtty-l_Blocked),0);



        FOR REC IN
        (
        SELECT rightoffrate, excodeid, optcodeid, nvl(ISALLOC,'Y') ISALLOC FROM CAMAST WHERE CAMASTID= l_camastid AND deltd='N'
        )
        LOOP

           SELECT      substr(REC.rightoffrate,1,instr(REC.rightoffrate,'/')-1),
                           substr(REC.rightoffrate,instr(REC.rightoffrate,'/') + 1,length(REC.rightoffrate))
               INTO    l_left_rightoffrate, l_right_rightoffrate
           from dual;
            if p_txmsg.deltd <> 'Y' then
                 /*  Update semast
                    set trade = trade - TRUNC( l_qtty * to_number(l_left_rightoffrate / l_right_rightoffrate))
                   where acctno = l_afacctno || REC.optcodeid;

                   INSERT INTO SETRAN (ACCTNO, TXNUM, TXDATE, TXCD, NAMT, CAMT, REF, DELTD,AUTOID,acctref,Tltxcd)
                   VALUES (l_afacctno || REC.optcodeid,p_txmsg.txnum,p_txmsg.txdate,'0011', TRUNC(l_qtty * to_number(l_left_rightoffrate / l_right_rightoffrate) ),'',p_txmsg.txfields ('01').VALUE,'N',SEQ_SETRAN.NEXTVAL,p_txmsg.txfields ('01').VALUE,'3384');
*/
                   UPDATE CASCHD
                    SET STATUS= l_status
                   WHERE AFACCTNO= l_afacctno
                       AND CAMASTID= l_camastid
                       AND DELTD = 'N'
                       AND autoid=p_txmsg.txfields ('01').VALUE;

                   UPDATE CAMAST
                   SET STATUS= l_status
                   WHERE CAMASTID= l_camastid;

                   -- Cap nhat giam so tien nop cho quyen mua
                   UPDATE CASCHD
                   SET     BALANCE = BALANCE + TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ) ,
                           AAMT= AAMT + l_exprice * l_qtty  ,
                           QTTY = QTTY + l_qtty,
                           PAAMT= PAAMT - l_exprice * l_qtty ,
                           PQTTY= PQTTY - l_qtty,
                           PBALANCE = TRUNC(PBALANCE - l_qtty * l_left_rightoffrate / l_right_rightoffrate ),
                           inbalance=inbalance- least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                           RETAILBAL=RETAILBAL- TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )+least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                           RORETAILBAL=RORETAILBAL+ TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )-least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ))
                   WHERE AFACCTNO= l_afacctno AND CAMASTID= l_camastid AND DELTD = 'N'
                         AND autoid=p_txmsg.txfields ('01').VALUE;

                   if  rec.isalloc = 'N' then
                        update CASCHD set isse='Y' where autoid=p_txmsg.txfields ('01').VALUE;
                   end if;
                   -- VuTN: cap nhat log caschd tung loai CK
                   UPDATE caschd_log
                    /*set PTRADE = PTRADE - p_txmsg.txfields ('51').VALUE ,
                        TRADE = TRUNC(TRADE - (p_txmsg.txfields ('51').VALUE  * (l_left_rightoffrate / l_right_rightoffrate ))),*/

                    set PTRADE = PTRADE - l_Trade ,
                        TRADE = TRUNC(TRADE - (l_Trade  * (l_left_rightoffrate / l_right_rightoffrate ))),

                        PBLOCKED = PBLOCKED - l_Blocked,
                        BLOCKED = TRUNC(BLOCKED - (l_Blocked  * (l_left_rightoffrate / l_right_rightoffrate ))),

                        OUTPTRADE = OUTPTRADE + l_Trade,
                        OUTPBLOCKED = OUTPBLOCKED + l_Blocked
                    where CAMASTID= l_camastid
                    and AFACCTNO= l_afacctno
                    --and codeid = p_txmsg.txfields ('24').VALUE
                    and DELTD = 'N';

                   /*if p_txmsg.txfields ('51').VALUE > 0 then
                        l_VSDSTOCKTYPE:='1';
                   else
                        l_VSDSTOCKTYPE:='2';
                   end if;*/

                   l_VSDSTOCKTYPE:='1';

                   --insert log 3384
                   insert into caregister (TXDATE, TXNUM, CAMASTID, CUSTODYCD, AFACCTNO, SEACCTNO, OPTSEACCTNO,
                   CODEID, QTTY, AMT, EXPRICE, PARVALUE, STATUS, VSDSTOCKTYPE, MSGSTATUS)
                   values(p_txmsg.txdate, p_txmsg.txnum,l_camastid,p_txmsg.txfields ('96').VALUE,l_afacctno,p_txmsg.txfields ('06').VALUE,p_txmsg.txfields ('09').VALUE,
                   p_txmsg.txfields ('24').VALUE, l_qtty,p_txmsg.txfields ('10').VALUE, l_exprice, p_txmsg.txfields ('22').VALUE,'P',l_VSDSTOCKTYPE,'P');

                   --log de tinh gia von
                    --locpt 20180321 ghi nhan tinh gia von realtime


                 secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, l_afacctno,
                 substr(p_txmsg.txfields ('06').VALUE,11,6), 'C', 'I', l_camastid, NULL,  l_qtty, l_exprice , 'Y',0);


            else
                UPDATE CASCHD
                SET STATUS='V'
                WHERE AFACCTNO=p_txmsg.txfields(c_afacctno).value
                AND CAMASTID=p_txmsg.txfields(c_camastid).value
                AND DELTD = 'N'
                AND autoid=p_txmsg.txfields ('01').VALUE;

                UPDATE CAMAST
                SET STATUS='V'
                WHERE  CAMASTID=p_txmsg.txfields(c_camastid).value;

                UPDATE CASCHD
                SET BALANCE = BALANCE - TRUNC(l_qtty * TO_NUMBER(l_left_rightoffrate / l_right_rightoffrate)) ,
                        AAMT= AAMT - l_exprice * l_qtty ,QTTY= QTTY - l_qtty,
                        PAAMT= PAAMT + l_exprice * l_qtty ,
                        PQTTY= PQTTY + l_qtty,
                        PBALANCE = PBALANCE + TRUNC(l_qtty * to_number(l_left_rightoffrate / l_right_rightoffrate)) ,
                      inbalance=inbalance+ least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                           RETAILBAL=RETAILBAL+ TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )-least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )),
                           RORETAILBAL=RORETAILBAL- TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate )+least(inbalance,TRUNC(l_qtty * l_left_rightoffrate / l_right_rightoffrate ))
                      WHERE AFACCTNO= p_txmsg.txfields(c_afacctno).value  AND CAMASTID=p_txmsg.txfields(c_camastid).value
                AND DELTD = 'N'
                AND autoid=p_txmsg.txfields ('01').VALUE;

               if  rec.isalloc = 'N' then
                    update CASCHD set isse='N' where autoid=p_txmsg.txfields ('01').VALUE;
               end if;


               -- VuTN: cap nhat log caschd tung loai CK
               UPDATE caschd_log
                set PTRADE = PTRADE + p_txmsg.txfields ('51').VALUE ,
                    TRADE = TRUNC(TRADE + (p_txmsg.txfields ('51').VALUE  * (l_left_rightoffrate / l_right_rightoffrate ))),

                    PBLOCKED = PBLOCKED + p_txmsg.txfields ('53').VALUE,
                    BLOCKED = TRUNC(BLOCKED + (p_txmsg.txfields ('53').VALUE  * (l_left_rightoffrate / l_right_rightoffrate ))),

                    OUTPTRADE = OUTPTRADE - p_txmsg.txfields ('51').VALUE,
                    OUTPBLOCKED = OUTPBLOCKED - p_txmsg.txfields ('53').VALUE
                where CAMASTID= l_camastid
                and AFACCTNO= l_afacctno
                --and codeid = p_txmsg.txfields ('24').VALUE
                and DELTD = 'N';
               update caregister set status = 'C' where txdate = p_txmsg.txdate and txnum = p_txmsg.txnum;
            end if;
        END LOOP;


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
         plog.init ('TXPKS_#3384EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3384EX;
/
