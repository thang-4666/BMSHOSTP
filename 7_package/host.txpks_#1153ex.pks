SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1153ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1153EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      05/05/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1153ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_ismortage        CONSTANT CHAR(2) := '60';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_bankid           CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_duedate          CONSTANT CHAR(2) := '09';
   c_ordate           CONSTANT CHAR(2) := '08';
   c_amt              CONSTANT CHAR(2) := '10';
   c_maxamt           CONSTANT CHAR(2) := '20';
   c_days             CONSTANT CHAR(2) := '13';
   c_intrate          CONSTANT CHAR(2) := '12';
   c_feeamt           CONSTANT CHAR(2) := '11';
   c_bnkrate          CONSTANT CHAR(2) := '15';
   c_bnkfeeamt        CONSTANT CHAR(2) := '14';
   c_cmpminbal        CONSTANT CHAR(2) := '16';
   c_bnkminbal        CONSTANT CHAR(2) := '17';
   c_desc             CONSTANT CHAR(2) := '30';
   c_100              CONSTANT CHAR(2) := '40';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
l_baldefovd apprules.field%TYPE;
v_maxAvlAdv number;
l_limitadv number;
V_TOTAL_LM NUMBER;
v_HOSTATUS VARCHAR2(5);
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
    /*if p_txmsg.deltd = 'Y' then
        --Kiem tra neu khong co tien thi khong cho xoa giao dich UT
        --10--94**10
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');
        l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
        IF NOT (to_number(l_BALDEFOVD) >= to_number(p_txmsg.txfields('10').value-p_txmsg.txfields('10').value*p_txmsg.txfields('94').value)) THEN
            p_err_code := '-400110';
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;*/

    --GW04: khong UT manual lenh khop trong ngay
    IF to_date(p_txmsg.txfields('42').value,'DD/MM/RRRR') = getcurrdate THEN
        SELECT VARVALUE INTO v_HOSTATUS
        FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'HOSTATUS';
        IF v_HOSTATUS = '1' THEN
          p_err_code := '-400142';
          plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;


    if p_txmsg.deltd <> 'Y' then
    --  --29/01/2018 DieuNDA: Check chan nhap so am
      if (TO_NUMBER(p_txmsg.txfields('10').value) <= 0 or TO_NUMBER(p_txmsg.txfields('11').value) < 0 or TO_NUMBER(p_txmsg.txfields('18').value) < 0) then
            p_err_code := '-100810';
            plog.error (pkgctx, 'ACCTNO=' || p_txmsg.txfields('03').value
                               || ', ADVAMT=' || p_txmsg.txfields('10').value
                               || ', FEEAMT=' || TO_NUMBER(p_txmsg.txfields('11').value)
                               || ', VATAMT=' || TO_NUMBER(p_txmsg.txfields('18').value)
                       );
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
       end if;
    --  --29/01/2018 DieuNDA: Check chan nhap so am

       begin
         SELECT GREATEST(MAXAVLAMT-ROUND(DEALPAID,0),0) MAXAVLAMT INTO v_maxAvlAdv
         FROM (
             SELECT VW.CUSTODYCD, VW.CUSTID, VW.FULLNAME, VW.ACCTNO, VW.AUTOADV, VW.ACTYPE, VW.TRFBANK, VW.COREBANK,
             VW.BANKACCT, VW.BANKCODE, VW.CLEARDATE, VW.TXDATE, VW.CURRDATE, VW.MAXAVLAMT, VW.EXECAMT, VW.AMT,
             VW.AAMT, VW.PAIDAMT, VW.PAIDFEEAMT, VW.BRKFEEAMT, VW.RIGHTTAX, VW.INCOMETAXAMT, VW.DAYS,
             (CASE WHEN VW.TXDATE =TO_DATE(SYS.VARVALUE,'DD/MM/RRRR') AND ISVSD='N' THEN fn_getdealgrppaid(VW.ACCTNO) ELSE 0 END)*
             (1+ADT.ADVRATE/100/360*VW.days) DEALPAID,CF.IDCODE, CF.IDTYPE, CF.IDDATE, CF.IDPLACE, CF.ADDRESS, ISVSD
             FROM VW_ADVANCESCHEDULE VW, SYSVAR SYS,AFMAST AF, AFTYPE AFT ,ADTYPE ADT,CFMAST CF
             WHERE SYS.GRNAME='SYSTEM' AND SYS.VARNAME ='CURRDATE'
             AND VW.ACCTNO = AF.ACCTNo AND AF.ACTYPE=AFT.ACTYPE AND AFT.ADTYPE=ADT.ACTYPE
           AND CF.CUSTID = AF.CUSTID
         ) WHERE ACCTNO=p_txmsg.txfields('03').value
             and CLEARDATE=TO_DATE(p_txmsg.txfields('08').value,'DD/MM/RRRR')
             and TXDATE=TO_DATE(p_txmsg.txfields('42').value,'DD/MM/RRRR')
             and (CASE WHEN ISVSD = 'N' THEN 0 ELSE 1 END)=p_txmsg.txfields('60').value ;
       exception when others then
            v_maxAvlAdv:=0;
       end;
       if v_maxAvlAdv< to_number(p_txmsg.txfields('10').value) then
          --Thong bao vuot qua so tien ung truoc
          p_err_code := '-400200';
          plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
          plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
          RETURN errnums.C_BIZ_RULE_INVALID;
       end if;
              --chek han muc nguon ao
       /* BEGIN

       select ((lmamtmax)- nvl(ad.amt,0)) into l_limitadv
        from aftype , adtype ,cflimit,
              ( select actype , sum (amt) amt from adschd , afmast af
                where adschd.acctno = af.acctno and adschd.status<>'C'
                group by af.actype   ) ad
        where aftype.adtype = adtype.actype
        and adtype.custbank = cflimit.bankid
        and aftype.actype = ad.actype(+)
        AND CFLIMIT.LMSUBTYPE='ADV'
        and aftype.actype =to_number(p_txmsg.txfields('89').value);

       exception when others then
            l_limitadv:=0;
       end;

       if l_limitadv < to_number(p_txmsg.txfields('10').value) then
          --Thong bao vuot qua so tien ung truoc
          p_err_code := '-400291';
          plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
          plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
          RETURN errnums.C_BIZ_RULE_INVALID;
       end if;*/

       --TONG NGUON CHO TK

       BEGIN
       SELECT SUM( GREATEST( fn_adv_amt(AFI.actype),0)) INTO  V_TOTAL_LM
       FROM afidtype afi
       WHERE objname ='AD.ADTYPE'
       AND afi.aftype =to_number(p_txmsg.txfields('89').value);

       exception when others then
            V_TOTAL_LM:=0;
       END;

       IF cspks_system.fn_get_sysvar('SYSTEM', 'HOSTATUS')=1 THEN
        if V_TOTAL_LM < to_number(p_txmsg.txfields('10').value) then
          --Thong bao vuot qua so tien ung truoc
          p_err_code := '-400292';
          plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
          plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
          RETURN errnums.C_BIZ_RULE_INVALID;
         end if;
       END IF;


      -- plog.error (pkgctx, 'v_maxAvlAdv:' || v_maxAvlAdv);
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
l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
l_baldefovd apprules.field%TYPE;
l_mblock apprules.field%TYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if p_txmsg.deltd = 'Y' then
        --Kiem tra neu khong co tien thi khong cho xoa giao dich UT
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');

        if p_txmsg.txfields('60').value = 0 then -- Ung  truoc thuong`
            --10--94**10
            l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
            IF NOT (to_number(l_BALDEFOVD) >= to_number(p_txmsg.txfields('10').value-p_txmsg.txfields('10').value*p_txmsg.txfields('94').value)) THEN
                p_err_code := '-400110';
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else    -- Ung  truoc cam co VSD
            l_mblock := l_CIMASTcheck_arr(0).MBLOCK;
            if l_mblock < p_txmsg.txfields('10').value then
                p_err_code := '-400110';
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;

    end if;
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
--l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
--l_baldefovd apprules.field%TYPE;
l_adtype varchar2(10);
l_Oldadtype varchar2(10);
l_reqid number;
l_status char(1);
l_count number;

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
v_strStatus char(1);
v_strCOREBANK    char(1);
v_strafbankname varchar(100);
v_strafbankacctno    varchar2(100);
v_strfullname    varchar2(100);
v_strREFAUTOID_DT number;
v_strCUSTODYCD varchar2(100);
v_blnTCDT boolean;
v_lngREQID number;
v_strBANKCODE varchar2(30) ;
L_ISUSEOADRES VARCHAR2(1);
v_strHOSTATUS VARCHAR2(5);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnTCDT:= false;
   -- if p_txmsg.deltd = 'Y' then
        --Kiem tra neu khong co tien thi khong cho xoa giao dich UT
        --10--94**10
        /*l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');
        l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
        IF NOT (to_number(l_BALDEFOVD) >= to_number(p_txmsg.txfields('10').value-p_txmsg.txfields('10').value*p_txmsg.txfields('94').value)) THEN
            p_err_code := '-400110';
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;*/

        --Kiem tra neu lam giao dich 1178 roi thi khong cho xoa
       -- plog.error (pkgctx, '1153: ' ||  p_txmsg.txnum);
       /* l_adtype:=P_TXMSG.txfields ('06').VALUE;
       \* select nvl(cvalue,'NULL') into l_adtype from tllogfld
        where txnum= p_txmsg.txnum and txdate = p_txmsg.txdate and fldcd ='06';*\
        select nvl(adtype,'NULL') into l_Oldadtype from adschd where txnum= p_txmsg.txnum and txdate = p_txmsg.txdate;
        if l_Oldadtype <> l_adtype then
            --Nguon ung truoc da bi doi.
            p_err_code := '-400209';
            plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/
    --end if;

    -- GW04: trong ngay khong uttb T0 --> tinh lai 2 gia tri advreceiving
        SELECT VARVALUE INTO v_strHOSTATUS
        FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'HOSTATUS';
        if ( v_strHOSTATUS = '1') then
          PRC_ADV_CIMASTEXT (p_txmsg.txfields('03').value, 'Y');
        else
          PRC_ADV_CIMASTEXT (p_txmsg.txfields('03').value, 'N');
        end if;


    IF cspks_ciproc.fn_DayAdvancedPayment(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    --Kiem tra neu la tai khoan corebank thi thuc hien goi giao dich gen bang ke sang ngan hang. va khong phai lenh Ung truoc lenh VSD
    if  to_number(p_txmsg.txfields ('10').VALUE) - to_number(p_txmsg.txfields ('10').VALUE)*to_number(p_txmsg.txfields ('60').VALUE) >0 then
        /*if to_number(p_txmsg.txfields('94').value)=1 then
            if p_txmsg.deltd = 'Y' then
                --Kiem tra chi cho xoa khi chua gom bang ke
                begin

                    select reqid into l_reqid from crbtxreq where refcode = p_txmsg.txnum and  txdate =p_txmsg.txdate;
                    select count(1) into l_count from crbtrflogdtl where refreqid =l_reqid and status ='P';
                    if l_count>0 then --Da gom bang ke, nhung dang cho xu ly --> Huy bang ke de xoa 1153
                        --Thong bao khong cho xoa
                        p_err_code := '-400215';
                        plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
                        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;

                    else  --Chua gom bang ke hoac bang ke da gui hoac xoa bang ke
                        --Xu ly xoa
                        delete from crbtxreq where refcode = p_txmsg.txnum and  txdate =p_txmsg.txdate;
                    end if;
                exception when others then
                    --Thong bao giao dich khong duoc xoa
                    p_err_code := '-400214';
                    plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
                    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end;
            else
                 cspks_rmproc.pr_CreateAdvTransferTransact(p_txmsg,p_err_code);
                 if p_err_code <> '0' then
                     plog.error (pkgctx, p_err_code || dbms_utility.format_error_backtrace);
                     plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                     RETURN errnums.C_BIZ_RULE_INVALID;
                 end if;
            end if;
        end if;*/

        --Genbankrequest neu la tai khoan ngan hang.
        if to_number(p_txmsg.txfields('94').value)=1 then
            if not p_txmsg.deltd='Y' then
               v_strAFACCTNO:=p_txmsg.txfields('03').value;
               --Kiem tra neu la TK corebank thi tiep tuc
               select af.corebank corebank,af.bankname,af.bankacctno, cf.fullname
                into v_strCOREBANK, v_strafbankname, v_strafbankacctno , v_strfullname
                from afmast af, cfmast cf where af.custid = cf.custid and af.acctno = v_strAFACCTNO;
               --Begin Gen yeu cau sang ngan hang 6646-$06
               v_strOBJTYPE:='T';
               v_strREFCODE:=to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strTRFCODE:='TRFADVAMT';

               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;

               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;

               v_strNOTES:=utf8nums.c_const_TLTX_TXDESC_6646 || p_txmsg.txfields ('88').VALUE || ' ' || utf8nums.c_const_TLTX_TXDESC_6646_amt || to_number(p_txmsg.txfields ('10').VALUE) || ' ' || utf8nums.c_const_TLTX_TXDESC_6646_fee || to_number(p_txmsg.txfields ('11').VALUE);
               v_strVALUE:=to_number(p_txmsg.txfields ('10').VALUE) + to_number(p_txmsg.txfields ('11').VALUE);
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then

                   --Neu dang trong gio giao dich TTDT va trang thai ngan hang la A thi Gen theo duong thu chi dien tu
                   select result into l_count from v_rm_tcdt_checkworkingtime;
                   if l_count <> 0 then
                       --Ghi nhan vao CRBTXREQ voi VIA ='RPT' la kenh bang ke
                       INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                           VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                                   v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                        --Dr Balance transfer amount
                       update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;
                       INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                       VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0011',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
                       v_strREFAUTOID_DT:= v_strREFAUTOID;
                   else
                       select count(1) into l_count from crbbanklist where BANKCODE = fn_getBankcodeByAccount(v_strBANKACCT) ;
                       if l_count >0 then
                           for rec in (
                                select * from crbbanklist where BANKCODE = fn_getBankcodeByAccount(v_strBANKACCT)
                            )
                            loop
                               if substr(v_strAFACCTNO,1,4) ='0101' then
                                   v_strBANKCODE:='TCDTHCM';
                               elsif substr(v_strAFACCTNO,1,4) ='0001'   then
                                   v_strBANKCODE:='TCDTHN';
                               else
                                   v_strBANKCODE:='TCDT';
                               end if;
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
                       else
                            --Khong tim thay bank code thi van phai di theo luong bang ke
                            --Ghi nhan vao CRBTXREQ voi VIA ='RPT' la kenh bang ke
                           select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                           INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                               VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                                       v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                            --Dr Balance transfer amount
                           update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;
                           INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                           VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0011',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
                           v_strREFAUTOID_DT:= v_strREFAUTOID;
                       end if;

                   end if;

               End if;
           else
               /*v_strTRFCODE:='TRFADVAMT';
               v_strAFACCTNO:=p_txmsg.txfields('03').value;
               v_strVALUE:=to_number(p_txmsg.txfields ('10').VALUE) - to_number(p_txmsg.txfields ('10').VALUE)*to_number(p_txmsg.txfields ('60').VALUE);
               begin
                   SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
                   if  v_strStatus = 'P' then
                       update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');

                       --Revert Dr Balance transfer amount
                       update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;
                   else
                       plog.setendsection (pkgctx, 'fn_txAppUpdate');
                       p_err_code:=-670101;--Trang thai bang ke khong hop le
                       Return errnums.C_BIZ_RULE_INVALID;
                   end if;
               exception when others then
                   null; --Khong co bang ke can xoa
               end;*/
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
           End if;

        end if;
        --Gent bang ke phi
        if to_number(p_txmsg.txfields('94').value)=1 and v_blnTCDT = false then
           if not p_txmsg.deltd='Y' then
                v_strAFACCTNO:=p_txmsg.txfields('03').value;
                --Kiem tra neu la TK corebank thi tiep tuc
                select af.corebank corebank,af.bankname,af.bankacctno, cf.fullname,cf.custodycd
                 into v_strCOREBANK, v_strafbankname, v_strafbankacctno , v_strfullname,v_strCUSTODYCD
                 from afmast af, cfmast cf where af.custid = cf.custid and af.acctno = v_strAFACCTNO;
                v_strOBJTYPE:='T';
               --select cf.custodycd into v_strCUSTODYCD from cfmast cf where cf.custid = v_strAFACCTNO;
               v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
               v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
               v_strTRFCODE:='TRFADVAMTFEE';
               v_strBANK:=v_strafbankname;
               v_strBANKACCT:=v_strafbankacctno;
               v_strNOTES:= utf8nums.c_const_TLTX_TXDESC_1153_desc || v_strCUSTODYCD;
               v_strVALUE:= p_txmsg.txfields('11').value;
               if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then
                   --Ghi nhan vao CRBTXREQ
                   select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                   INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                               v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                   --Dr Balance transfer amount
                   update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;
                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,'0012',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'');
                   update CRBTXREQ set grpreqid = v_strREFAUTOID_DT where REQID in (v_strREFAUTOID,v_strREFAUTOID_DT);
                end if;
               End if;
           else
               v_strTRFCODE:='TRFADVAMTFEE';
               v_strAFACCTNO:=p_txmsg.txfields('03').value;
               v_strVALUE:= p_txmsg.txfields('11').value;
               begin
                   SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
                   if  v_strStatus = 'P' then
                       update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');

                       --Revert Dr Balance transfer amount
                       --Khong tru tien tai day. Da tru trong bang ke ben tren
                       --update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;

                   else
                       plog.setendsection (pkgctx, 'fn_txAppUpdate');
                       p_err_code:=-670101;--Trang thai bang ke khong hop le
                       Return errnums.C_BIZ_RULE_INVALID;
                   end if;
               exception when others then
                   null; --Khong co bang ke can xoa
               end;
           End if;

        end if;
    ----Auto Gen request
    cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code);
/*    --PhuongHT add: phan bo nguon
     IF P_TXMSG.batchname <> 'DAY' THEN-- giao dich lam trong batch
      cspks_ciproc.PR_ADVRESALLOC(p_txmsg.txfields('03').value,TO_NUMBER(p_txmsg.txfields('09').value),
      P_TXMSG.TXDATE,P_TXMSG.txnum);
     ELSE -- giao dihc lam trong ngay
         SELECT ISUSEOADVRES INTO L_ISUSEOADRES FROM CFMAST CF
         WHERE CUSTODYCD=p_txmsg.txfields('88').VALUE;
         IF L_ISUSEOADRES='N' THEN
              cspks_ciproc.PR_ADVRESALLOC(p_txmsg.txfields('03').value,TO_NUMBER(p_txmsg.txfields('09').value),
              P_TXMSG.TXDATE,P_TXMSG.txnum);
         ENd IF;
     END IF;
    --end of PhuongHT add*/
    IF P_TXMSG.DELTD <> 'Y' THEN
        IF P_TXMSG.batchname = 'DAY' THEN
             SELECT ISUSEOADVRES INTO L_ISUSEOADRES FROM CFMAST CF
             WHERE CUSTODYCD=p_txmsg.txfields('88').VALUE;
             IF L_ISUSEOADRES='N' THEN
                  cspks_ciproc.PR_ADVRESALLOC(p_txmsg.txfields('03').value,TO_NUMBER(p_txmsg.txfields('09').value),
                  P_TXMSG.TXDATE,P_TXMSG.txnum);
             ENd IF;
        END IF;
    ELSE
         INSERT INTO ADVRESLOGHIST( AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AFACCTNO,AMT,RESREMAIN,BANKRATE,DELTD,advrate)
         SELECT AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AFACCTNO,AMT,RESREMAIN,BANKRATE,'Y',advrate
                FROM ADVRESLOG WHERE TXNUM=P_TXMSG.TXNUM AND TXDATE=P_TXMSG.TXDATE;
         DELETE FROM ADVRESLOG WHERE TXNUM=P_TXMSG.TXNUM AND TXDATE=P_TXMSG.TXDATE;
    ENd IF;
    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace );
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
         plog.init ('TXPKS_#1153EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1153EX;
/
