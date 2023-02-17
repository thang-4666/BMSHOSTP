SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_lnproc
IS
    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

  FUNCTION fn_CreateLoanSchedule(p_lnacctno varchar2,p_amount number,p_err_code out varchar2)
RETURN NUMBER;
  FUNCTION fn_getOVDD_From_New(p_currOverDueDate varchar2, p_newOverDueDate varchar2 )  RETURN NUMBER;
  FUNCTION fn_getSEASS(p_afacctno varchar2 )  RETURN NUMBER;
  FUNCTION fn_getMRRATE74(p_afacctno varchar2 )  RETURN NUMBER;
  FUNCTION FN_GETMRRATE(p_afacctno varchar2 )  RETURN NUMBER;
  FUNCTION fn_OpenLoanAccount(p_acctno varchar2,p_lntype varchar2,p_err_code  OUT varchar2)
  RETURN VARCHAR2;
  FUNCTION fn_PaymentScheduleAllocate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
  function fn_Loanpaymentschd
   (pv_strTXNUM IN VARCHAR2,
    pv_strTXDATE IN VARCHAR2,
    pv_strACCTNO IN VARCHAR2,
    pv_dblT0PRINOVD IN NUMBER,
    pv_dblT0PRINNML IN NUMBER,
    pv_dblPRINOVD IN NUMBER,
    pv_dblPRINNML IN NUMBER,
    pv_dblFEEOVD IN NUMBER,
    pv_dblFEEDUE IN NUMBER,
    pv_dblFEENML IN NUMBER,
    pv_dblT0INTNMLOVD IN NUMBER,
    pv_dblT0INTOVDACR IN NUMBER,
    pv_dblT0INTDUE IN NUMBER,
    pv_dblT0INTNMLACR IN NUMBER,
    pv_dblINTNMLOVD IN NUMBER,
    pv_dblINTOVDACR IN NUMBER,
    pv_dblINTDUE IN NUMBER,
    pv_dblINTNMLACR IN NUMBER,
    pv_dblADVFEE IN NUMBER,
    pv_dblADVPAYFEE IN NUMBER,
    pv_blnAUTO IN CHAR,
    pv_dblFEEINTNMLACR IN NUMBER,
    pv_dblFEEINTOVDACR IN NUMBER,
    pv_dblFEEINTNMLOVD IN NUMBER,
    pv_dblFEEINTDUE IN NUMBER,
    pv_dblINTFLOATAMT  IN NUMBER,
    pv_dblFEEINTFLOATAMT  IN NUMBER,
    pv_dblISFLOATINT   IN NUMBER,
    pv_dblISPAYINTIM   IN NUMBER )
   return number;
-- Procedure pr_LNApplyTypeToMaster(p_err_code  OUT varchar2);
    FUNCTION fn_Gen_Prepaid_Payment(p_afacctno varchar2,
                                p_avlpaidamt number,
                                p_type varchar2,
                                p_duepaid varchar2,
                                p_err_code  OUT varchar2)
    RETURN VARCHAR2;

  function fn_Loanpaymentschd_by_autoid
     (pv_strTXNUM IN VARCHAR2,
      pv_strTXDATE IN VARCHAR2,
      pv_strACCTNO IN VARCHAR2,
      pv_dblT0PRINOVD IN NUMBER,
      pv_dblT0PRINNML IN NUMBER,
      pv_dblPRINOVD IN NUMBER,
      pv_dblPRINNML IN NUMBER,
      pv_dblFEEOVD IN NUMBER,
      pv_dblFEEDUE IN NUMBER,
      pv_dblFEENML IN NUMBER,
      pv_dblT0INTNMLOVD IN NUMBER,
      pv_dblT0INTOVDACR IN NUMBER,
      pv_dblT0INTDUE IN NUMBER,
      pv_dblT0INTNMLACR IN NUMBER,
      pv_dblINTNMLOVD IN NUMBER,
      pv_dblINTOVDACR IN NUMBER,
      pv_dblINTDUE IN NUMBER,
      pv_dblINTNMLACR IN NUMBER,
      pv_dblADVFEE IN NUMBER,
      pv_dblADVPAYFEE IN NUMBER,
      pv_blnAUTO IN CHAR,
      pv_dblFEEINTNMLACR IN NUMBER,
      pv_dblFEEINTOVDACR IN NUMBER,
      pv_dblFEEINTNMLOVD IN NUMBER,
      pv_dblFEEINTDUE IN NUMBER,
      pv_dblINTFLOATAMT  IN NUMBER,
      pv_dblFEEINTFLOATAMT  IN NUMBER,
      pv_dblISFLOATINT   IN NUMBER,
      pv_dblISPAYINTIM   IN NUMBER,
      pv_dblACCRUALSAMT   IN NUMBER,
      pv_dblAUTOID        in number )

     return number;

  FUNCTION fn_Gen_Prepaid_Payment_tmp(p_afacctno varchar2,
                                p_avlpaidamt number,
                                p_type varchar2,
                                p_duepaid varchar2,
                                p_err_code  OUT varchar2)
    RETURN VARCHAR2;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_lnproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;


/*---------------------------------pr_LNApplyTypeToMaster------------------------------------------------
  Procedure pr_LNApplyTypeToMaster(p_err_code  OUT varchar2)
  IS
  BEGIN
    plog.setendsection(pkgctx, 'pr_LNApplyTypeToMaster');
    p_err_code:=0;
    for i in (select * from lntype)
    loop
        if i.MASTERAPPLY='N' then
            --Khong  apply
            return;
        elsif i.MASTERAPPLY='A' then
            --Apply cho lnmast
            UPDATE lnmast
               SET LNCLDR = i.LNCLDR,
                   PRINFRQ = i.PRINFRQ,
                   PRINPERIOD = i.PRINPERIOD,
                   INTFRGCD = i.INTFRQCD,
                   INTDAY = i.INTDAY,
                   INTPERIOD = i.INTPERIOD,
                   NINTCD = i.NINTCD,
                   OINTCD = i.OINTCD,
                   RATE1 = i.RATE1,
                   RATE2 = i.RATE2,
                   RATE3 = i.RATE3,
                   OPRINFRQ = i.OPRINFRQ,
                   OPRINPERIOD = i.OPRINPERIOD,
                   OINTFRQCD = i.OINTFRQCD,
                   OINTDAY = i.OINTDAY,
                   ORATE1 = i.ORATE1,
                   ORATE2 = i.ORATE2,
                   ORATE3 = i.ORATE3,
                   DRATE = i.DRATE,
                   ADVPAY = i.ADVPAY,
                   ADVPAYFEE = i.ADVPAYFEE,
                   FRATE1   = i.FRATE1,
                   FRATE2   = i.FRATE2,
                   FRATE3   = i.FRATE3
                WHERE lnmast.actype =i.actype;
            --Apply cho lnschd margin
            update lnschd set
                   RATE1 = i.RATE1,
                   RATE2 = i.RATE2,
                   RATE3 = i.RATE3,
                   FRATE1   = i.FRATE1,
                   FRATE2   = i.FRATE2,
                   FRATE3   = i.FRATE3
                where acctno in (select acctno from lnmast where actype =i.actype) and reftype ='P';
            --Apply cho lnschd
            update lnschd set
                   RATE1 = i.ORATE1,
                   RATE2 = i.ORATE2,
                   RATE3 = i.ORATE3,
                   FRATE1   = i.FRATE1,
                   FRATE2   = i.FRATE2,
                   FRATE3   = i.FRATE3
                where acctno in (select acctno from lnmast where actype =i.actype) and reftype ='GP';
        elsif i.MASTERAPPLY='L' then
            --Apply cho lnmast
            UPDATE lnmast
               SET LNCLDR = i.LNCLDR,
                   PRINFRQ = i.PRINFRQ,
                   PRINPERIOD = i.PRINPERIOD,
                   INTFRGCD = i.INTFRQCD,
                   INTDAY = i.INTDAY,
                   INTPERIOD = i.INTPERIOD,
                   NINTCD = i.NINTCD,
                   OINTCD = i.OINTCD,
                   RATE1 = i.RATE1,
                   RATE2 = i.RATE2,
                   RATE3 = i.RATE3,
                   OPRINFRQ = i.OPRINFRQ,
                   OPRINPERIOD = i.OPRINPERIOD,
                   OINTFRQCD = i.OINTFRQCD,
                   OINTDAY = i.OINTDAY,
                   ORATE1 = i.ORATE1,
                   ORATE2 = i.ORATE2,
                   ORATE3 = i.ORATE3,
                   DRATE = i.DRATE,
                   ADVPAY = i.ADVPAY,
                   ADVPAYFEE = i.ADVPAYFEE,
                   FRATE1   = i.FRATE1,
                   FRATE2   = i.FRATE2,
                   FRATE3   = i.FRATE3
                WHERE lnmast.actype =i.actype;
            --Khong apply cho LNSCHD
        end if;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_LNApplyTypeToMaster');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_LNApplyTypeToMaster');
      RAISE errnums.E_SYSTEM_ERROR;
      return;
  END pr_LNApplyTypeToMaster;*/

---------------------------------pr_OpenLoanAccount------------------------------------------------
  FUNCTION fn_OpenLoanAccount(p_acctno varchar2,p_lntype varchar2,p_err_code  OUT varchar2)
  RETURN VARCHAR2
  IS
   V_DTCURDATE DATE;
   V_STRACCTNO VARCHAR2(30);
   V_STRBRID VARCHAR2(4);
  BEGIN
    plog.setendsection(pkgctx, 'pr_OpenLoanAccount');
    p_err_code:=0;
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO V_DTCURDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    FOR REC IN
        (SELECT p_acctno ACCTNO, LNT.CCYCD, LNT.LNTYPE, LNT.LNCLDR, LNT.PRINFRQ, LNT.PRINPERIOD,
            LNT.INTFRQCD, LNT.INTDAY, LNT.INTPERIOD, LNT.NINTCD, LNT.OINTCD, LNT.RATE1, LNT.RATE2, LNT.RATE3,
            LNT.OPRINFRQ, LNT.OPRINPERIOD, LNT.OINTFRQCD, LNT.OINTDAY, LNT.ORATE1, LNT.ORATE2, LNT.ORATE3,
            LNT.ADVPAY, LNT.ADVPAYFEE, LNT.DRATE, LNT.ACTYPE, LNT.PRINTFRQ1, LNT.PRINTFRQ2, LNT.PRINTFRQ3, LNT.PREPAID,
            LNT.CFRATE1,LNT.CFRATE2,LNT.CFRATE3,LNT.MINTERM,LNT.INTPAIDMETHOD,LNT.AUTOAPPLY,lnt.rrtype,lnt.custbank,lnt.ciacctno, lnt.intovdcd,
            LNT.Bankpaidmethod

        FROM LNTYPE LNT
        WHERE LNT.actype=p_lntype)
    LOOP
        V_STRBRID:= SUBSTR(REC.ACCTNO,0,4);
        SELECT SEQ_LNMAST.NEXTVAL LNACCTNO
            into V_STRACCTNO
        FROM DUAL;
        V_STRACCTNO:=substr('000000' || V_STRACCTNO,length('000000' || V_STRACCTNO)-5,6);
        V_STRACCTNO:=V_STRBRID    || substr(to_char(V_DTCURDATE,systemnums.c_date_format),1,2)
                                  || substr(to_char(V_DTCURDATE,systemnums.c_date_format),4,2)
                                  || substr(to_char(V_DTCURDATE,systemnums.c_date_format),9,2)
                                  || V_STRACCTNO;
        INSERT INTO LNMAST
          ("ACTYPE", "ACCTNO", "CCYCD", "BANKID", "APPLID", "OPNDATE",
           "EXPDATE", "EXTDATE", "CLSDATE", "RLSDATE", "LASTDATE", "ACRDATE",
           "OACRDATE", "STATUS", "PSTATUS", "TRFACCTNO", "PRINAFT", "INTAFT",
           "LNTYPE", "LNCLDR", "PRINFRQ", "PRINPERIOD", "INTFRGCD", "INTDAY",
           "INTPERIOD", "NINTCD", "OINTCD", "RATE1", "RATE2", "RATE3",
           "OPRINFRQ", "OPRINPERIOD", "OINTFRQCD", "OINTDAY", "ORATE1",
           "ORATE2", "ORATE3", "DRATE", "APRLIMIT", "RLSAMT", "PRINPAID",
           "PRINNML", "PRINOVD", "INTNMLACR", "INTOVDACR", "INTNMLPBL",
           "INTNMLOVD", "INTDUE", "INTPAID", "INTPREPAID", "NOTES",
           "LNCLASS", "ADVPAY", "ADVPAYFEE", "ORLSAMT", "OPRINPAID",
           "OPRINNML", "OPRINOVD", "OINTNMLACR", "OINTNMLOVD", "OINTOVDACR",
           "OINTDUE", "OINTPAID", "OINTPREPAID", "FEE", "FEEPAID", "FEEDUE",
           "FEEOVD", "FTYPE", "PRINTFRQ1", "PRINTFRQ2", "PRINTFRQ3",
           "PREPAID", "CFRATE1", "CFRATE2", "CFRATE3", "MINTERM",
           "INTPAIDMETHOD", "AUTOAPPLY", "FEEINTNMLACR", "FEEINTOVDACR",
           "FEEINTNMLOVD", "FEEINTDUE", "FEEINTPREPAID", "FEEINTPAID",
           "INTFLOATAMT", "FEEFLOATAMT",rrtype,custbank,ciacctno, INTOVDCD,BANKPAIDMETHOD)
        VALUES
          (REC.ACTYPE, V_STRACCTNO, REC.CCYCD, NULL, NULL, V_DTCURDATE,
           V_DTCURDATE, NULL, NULL, V_DTCURDATE, NULL, V_DTCURDATE,
           V_DTCURDATE, 'N', '', REC.ACCTNO, 'Y', 'Y', REC.LNTYPE,
           REC.LNCLDR, REC.PRINFRQ, REC.PRINPERIOD, REC.INTFRQCD, REC.INTDAY,
           REC.INTPERIOD, REC.NINTCD, REC.OINTCD, REC.RATE1, REC.RATE2,
           REC.RATE3, REC.OPRINFRQ, REC.OPRINPERIOD, REC.OINTFRQCD,
           REC.OINTDAY, REC.ORATE1, REC.ORATE2, REC.ORATE3, REC.DRATE, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 'I', REC.ADVPAY,
           REC.ADVPAYFEE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'DF',
           REC.PRINTFRQ1, REC.PRINTFRQ2, REC.PRINTFRQ3, REC.PREPAID,
           REC.CFRATE1,REC.CFRATE2,REC.CFRATE3,REC.Minterm,
           rec.intpaidmethod,rec.autoapply,0,0,
           0,0,0,0,0,0,rec.rrtype,rec.custbank,rec.ciacctno, rec.intovdcd,rec.bankpaidmethod);
        return V_STRACCTNO;
    END LOOP;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_OpenLoanAccount');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_OpenLoanAccount');
      RAISE errnums.E_SYSTEM_ERROR;
      return '';
  END fn_OpenLoanAccount;

FUNCTION fn_CreateLoanSchedule(p_lnacctno varchar2,p_amount number,p_err_code out varchar2)
RETURN NUMBER
IS
    l_lngErrCode    number(20,0);
    v_dblINTAMT number(20,0);
    v_strREFTYPE    varchar2(10);
    v_strTRFACCTNO varchar2(100);
    v_strLNTYPE varchar2(100);
    v_dblLNRLSAMT   number(20,4);
    v_strLNCLDR varchar2(100);
    v_lngPRINFRQ    number(20,0);
    v_lngPRINPERIOD number(20,0);
    v_lngOPRINFRQ   number(20,0);
    v_lngOPRINPERIOD    number(20,0);
    v_strDUEDATE varchar2(20);
    v_strOVERDUEDATE    varchar2(20);
    v_intWITHHOLIDAY    number(20,0);
    v_intWITHOUTHOLIDAY number(20,0);
    v_strNINTCD         varchar2(4);
    v_intPRINTFRQ1      number(20,0);
    v_intPRINTFRQ2      number(20,0);
    v_intPRINTFRQ3      number(20,0);
    v_intDueno number(20,0);
    v_dblRATE1 NUMBER(20,4);
    v_dblRATE2 NUMBER(20,4);
    v_dblRATE3 NUMBER(20,4);
    v_dblCFRATE1 NUMBER(20,4);
    v_dblCFRATE2 NUMBER(20,4);
    v_dblCFRATE3 NUMBER(20,4);
    i number(20,0);
    v_strCURRDATE varchar2(20);
    v_ISVSD varchar2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_CreateLoanSchedule');
    plog.debug (pkgctx, '<<BEGIN OF fn_CreateLoanSchedule');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    begin
        --VINHLD LAY THEM THAM SO TINH LAI BAC THANG THU KHI TRA GOC
        SELECT MST.TRFACCTNO, MST.LNTYPE, MST.RLSAMT + MST.ORLSAMT RLSAMT,
               MST.LNCLDR, MST.PRINFRQ, MST.PRINPERIOD, MST.OPRINFRQ,
               MST.OPRINPERIOD, LNTYPE.NINTCD, MST.PRINTFRQ1, MST.PRINTFRQ2,
               MST.PRINTFRQ3, MST.RATE1, MST.RATE2, MST.RATE3, MST.CFRATE1,
               MST.CFRATE2, MST.CFRATE3
          INTO v_strTRFACCTNO, v_strLNTYPE, v_dblLNRLSAMT, v_strLNCLDR,
               v_lngPRINFRQ, v_lngPRINPERIOD, v_lngOPRINFRQ,
               v_lngOPRINPERIOD, v_strNINTCD, v_intPRINTFRQ1, v_intPRINTFRQ2,
               v_intPRINTFRQ3, v_dblRATE1, v_dblRATE2, v_dblRATE3,
               v_dblCFRATE1, v_dblCFRATE2, v_dblCFRATE3
          FROM LNMAST MST, CIMAST CI, LNTYPE
         WHERE MST.ACCTNO = p_lnacctno
           AND CI.ACCTNO = MST.TRFACCTNO
           AND LNTYPE.ACTYPE = MST.ACTYPE;
        /*
        SELECT MST.TRFACCTNO, MST.LNTYPE, MST.RLSAMT+MST.ORLSAMT RLSAMT, MST.LNCLDR, MST.PRINFRQ, MST.PRINPERIOD, MST.OPRINFRQ, MST.OPRINPERIOD
        into v_strTRFACCTNO,v_strLNTYPE,v_dblLNRLSAMT,v_strLNCLDR,v_lngPRINFRQ,v_lngPRINPERIOD,v_lngOPRINFRQ,v_lngOPRINPERIOD
        FROM LNMAST MST, CIMAST CI
        WHERE MST.ACCTNO = p_lnacctno AND CI.ACCTNO = MST.TRFACCTNO;
        */
    exception
    when others then
        p_err_code:=0;--Ko bat exception
    end;
    If v_dblLNRLSAMT = 0 Then   --Lan giai ngan dau tien
        UPDATE LNMAST SET RLSDATE = TO_DATE(v_strCURRDATE,systemnums.c_date_format) WHERE ACCTNO = p_lnacctno;
        DELETE LNSCHD WHERE ACCTNO = p_lnacctno;
    end if;
     SELECT NVL(ISVSD,'N') INTO v_ISVSD FROM DFTYPE WHERE ACTYPE IN (SELECT ACTYPE FROM DFGROUP WHERE LNACCTNO = p_lnacctno);

    If (p_amount > 0) or (v_ISVSD = 'Y') Then --Giai ngan vay
        If v_strLNCLDR = 'N' Then --Lich tra no theo lich he thong: N: lich thuong (bao gom thu 7, CN); B: lich lam viec business
            IF v_strNINTCD='001' THEN -- 000: Cong Don; 001: Bac Thang
                v_strDUEDATE:=to_char(TO_DATE(v_strCURRDATE,systemnums.c_date_format) + v_intPRINTFRQ3,systemnums.c_date_format);
                v_strOVERDUEDATE:=to_char(TO_DATE(v_strCURRDATE,systemnums.c_date_format) + v_intPRINTFRQ3,systemnums.c_date_format);
            ELSE
                v_strDUEDATE:=to_char(TO_DATE(v_strCURRDATE,systemnums.c_date_format) + v_lngPRINFRQ,systemnums.c_date_format);
                v_strOVERDUEDATE:=to_char(TO_DATE(v_strCURRDATE,systemnums.c_date_format) + v_lngPRINPERIOD,systemnums.c_date_format);
            END IF;
            begin
                /*-- Lay ngay lam viec tiep theo, neu ngay duedate la ngay nghi.
                SELECT NVL(TO_CHAR(MIN(SBDATE),systemnums.c_date_format),v_strDUEDATE) into v_strDUEDATE FROM SBCLDR WHERE CLDRTYPE='000' AND SBDATE >= TO_DATE(v_strDUEDATE,systemnums.c_date_format) AND HOLIDAY = 'N';
                SELECT NVL(TO_CHAR(MIN(SBDATE),systemnums.c_date_format),v_strOVERDUEDATE) into v_strOVERDUEDATE FROM SBCLDR WHERE CLDRTYPE='000' AND SBDATE >= TO_DATE(v_strOVERDUEDATE,systemnums.c_date_format) AND HOLIDAY = 'N';*/
                -- Lay ngay lam viec gan nhat, neu ngay duedate la ngay nghi.
                SELECT NVL(TO_CHAR(min(SBDATE),systemnums.c_date_format),v_strDUEDATE) into v_strDUEDATE
                    FROM SBCLDR
                    WHERE CLDRTYPE='000'
                    AND SBDATE >= TO_DATE(v_strDUEDATE,systemnums.c_date_format)
                    and SBDATE >= TO_DATE(v_strCURRDATE,systemnums.c_date_format) AND HOLIDAY = 'N';
                SELECT NVL(TO_CHAR(min(SBDATE),systemnums.c_date_format),v_strOVERDUEDATE) into v_strOVERDUEDATE
                    FROM SBCLDR
                    WHERE CLDRTYPE='000'
                    AND SBDATE >= TO_DATE(v_strOVERDUEDATE,systemnums.c_date_format)
                    and SBDATE >= TO_DATE(v_strCURRDATE,systemnums.c_date_format) AND HOLIDAY = 'N';
            exception
            when others then
                p_err_code:=0;--Ko bat exception
            end;
        ElsIf v_strLNCLDR = 'B' Then   --Lich tra no tinh theo lich thanh toan
/*            i := v_lngPRINFRQ;
            v_strDUEDATE := v_strCURRDATE;
            v_intWITHHOLIDAY := 0;
            v_intWITHOUTHOLIDAY := 0;
            WHILE i > 0 LOOP
                begin
                    SELECT SUM(CASE WHEN CLR1.HOLIDAY='N' THEN 1 ELSE 0 END) WITHOUTHOLIDAY,TO_CHAR(MAX(SBDATE),systemnums.c_date_format) SBDATE
                            into v_intWITHOUTHOLIDAY,v_strDUEDATE
                    FROM SBCLDR CLR1 WHERE CLR1.CLDRTYPE='000' AND CLR1.SBDATE > TO_DATE(v_strDUEDATE ,systemnums.c_date_format) AND CLR1.SBDATE <= TO_DATE(v_strDUEDATE ,systemnums.c_date_format) +  i;
                exception
                when others then
                    p_err_code:=0;--Ko bat exception
                end;
                v_intWITHHOLIDAY:=i - v_intWITHOUTHOLIDAY;
                i := v_intWITHHOLIDAY;
            END LOOP;*/
            IF v_strNINTCD='001' THEN -- 000: Cong Don; 001: Bac Thang
                if v_intPRINTFRQ3 = 0 then
                    v_strDUEDATE:= v_strCURRDATE;
                    v_strOVERDUEDATE:= v_strCURRDATE;
                else
                    select to_char(sbdate,systemnums.c_date_format) into v_strDUEDATE
                    from (
                        select sbdate, rownum rn from (
                            select sbdate from SBCLDR where holiday = 'N' and CLDRTYPE='000' and sbdate > to_date(v_strCURRDATE,systemnums.c_date_format) order by sbdate
                        )
                    )
                    where rn = v_intPRINTFRQ3;

                    select to_char(sbdate,systemnums.c_date_format) into v_strOVERDUEDATE
                    from (
                        select sbdate, rownum rn from (
                            select sbdate from SBCLDR where holiday = 'N' and CLDRTYPE='000' and sbdate > to_date(v_strCURRDATE,systemnums.c_date_format) order by sbdate
                        )
                    )
                    where rn = v_intPRINTFRQ3;
                end if;
            else
                if v_lngPRINFRQ = 0 then
                    v_strDUEDATE:= v_strCURRDATE;
                else
                select to_char(sbdate,systemnums.c_date_format) into v_strDUEDATE
                from (
                    select sbdate, rownum rn from (
                        select sbdate from SBCLDR where holiday = 'N' and CLDRTYPE='000' and sbdate > to_date(v_strCURRDATE,systemnums.c_date_format) order by sbdate
                    )
                )
                where rn = v_lngPRINFRQ;
                end if;

                if v_lngPRINPERIOD = 0 then
                    v_strOVERDUEDATE:= v_strCURRDATE;
                else
                    select to_char(sbdate,systemnums.c_date_format) into v_strOVERDUEDATE
                    from (
                        select sbdate, rownum rn from (
                            select sbdate from SBCLDR where holiday = 'N' and CLDRTYPE='000' and sbdate > to_date(v_strCURRDATE,systemnums.c_date_format) order by sbdate
                        )
                    )
                    where rn = v_lngPRINPERIOD;
                end if;

            end if;
            /*
            If v_lngPRINPERIOD > 365 OR v_intPRINTFRQ3>0 Then
                IF v_strNINTCD='001' THEN
                   v_strOVERDUEDATE:=to_char(TO_DATE(v_strCURRDATE,systemnums.c_date_format) + v_intPRINTFRQ3,systemnums.c_date_format);
                ELSE
                   v_strOVERDUEDATE:=to_char(TO_DATE(v_strCURRDATE,systemnums.c_date_format) + v_lngPRINPERIOD,systemnums.c_date_format);
                END IF;

                begin
                    SELECT NVL(TO_CHAR(MIN(SBDATE),systemnums.c_date_format),v_strOVERDUEDATE) DUEDATE
                    into v_strOVERDUEDATE
                    FROM SBCLDR
                    WHERE CLDRTYPE='000'
                        AND SBDATE >= TO_DATE(v_strOVERDUEDATE ,systemnums.c_date_format)
                        AND HOLIDAY = 'N';
                exception
                when others then
                    p_err_code:=0;--Ko bat exception
                end;
            else
                IF v_strNINTCD='001' THEN
                   i := 0;
                ELSE
                   i := v_lngPRINPERIOD - v_lngPRINFRQ;
                END IF;
                v_strOVERDUEDATE := v_strDUEDATE;
                v_intWITHHOLIDAY := 0;
                v_intWITHOUTHOLIDAY := 0;
                WHILE i > 0 LOOP
                    begin
                        SELECT SUM(CASE WHEN CLR1.HOLIDAY='N' THEN 1 ELSE 0 END) WITHOUTHOLIDAY,TO_CHAR(MAX(SBDATE),systemnums.c_date_format) SBDATE
                        into v_intWITHOUTHOLIDAY,v_strOVERDUEDATE
                        FROM SBCLDR CLR1 WHERE CLR1.CLDRTYPE='000' AND CLR1.SBDATE > TO_DATE(v_strOVERDUEDATE ,systemnums.c_date_format) AND CLR1.SBDATE <= TO_DATE( v_strOVERDUEDATE ,systemnums.c_date_format) +  i;
                        v_intWITHHOLIDAY := i - v_intWITHOUTHOLIDAY;
                    exception
                    when others then
                        p_err_code:=0;--Ko bat exception
                    end;
                    i := v_intWITHHOLIDAY;
                end loop;
            end if;*/
        end if;
        --Moi lan giai ngan sinh mot dong lich
        begin
            SELECT NVL(MAX(DUENO),0) DUENO
            into v_intDueno
            FROM LNSCHD WHERE ACCTNO = p_lnacctno;
        exception
        when others then
            v_intDueno:=1;
        end;
        INSERT INTO LNSCHD
          (AUTOID, ACCTNO, DUENO, RLSDATE, DUEDATE, OVERDUEDATE, ACRDATE,
           OVDACRDATE, REFTYPE, NML, OVD, PAID, DUESTS, PDUESTS, INTNMLACR,
           FEE, DUE,RATE1,RATE2,RATE3,CFRATE1,CFRATE2,CFRATE3)
        VALUES
          (SEQ_LNSCHD.NEXTVAL, p_lnacctno, v_intDueno,
           TO_DATE(v_strCURRDATE, systemnums.c_date_format),
           TO_DATE(v_strDUEDATE, systemnums.c_date_format),
           TO_DATE(v_strOVERDUEDATE, systemnums.c_date_format),
           TO_DATE(v_strCURRDATE, systemnums.c_date_format),
           TO_DATE(v_strCURRDATE, systemnums.c_date_format), 'P',
           round(p_amount, 0), 0, 0, 'N', NULL, 0, 0, 'N',
            v_dblRATE1, v_dblRATE2, v_dblRATE3,
               v_dblCFRATE1, v_dblCFRATE2, v_dblCFRATE3);
        UPDATE LNMAST
             SET
               PRINNML = PRINNML + round(p_amount,0),
               RLSAMT = RLSAMT + round(p_amount,0)
            WHERE ACCTNO=p_lnacctno;
    end if;
    plog.debug (pkgctx, '<<END OF fn_CreateLoanSchedule');
    plog.setendsection (pkgctx, 'fn_CreateLoanSchedule');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_CreateLoanSchedule');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_CreateLoanSchedule;




 ---------------------------------fn_PaymentScheduleAllocate------------------------------------------------
FUNCTION fn_PaymentScheduleAllocate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_dblINTAMT number(20,0);
v_strREFTYPE    varchar2(10);
l_auto char(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_PaymentScheduleAllocate');
    plog.debug (pkgctx, '<<BEGIN OF fn_PaymentScheduleAllocate');

    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_auto:= case when p_txmsg.tltxcd='5567' then 'Y' else 'N' end;
    If Not v_blnReversal Then
        plog.debug (pkgctx, 'fn_Loanpaymentschd');
        p_err_code:=fn_Loanpaymentschd(
                                p_txmsg.txnum,
                                p_txmsg.txdate,
                                p_txmsg.txfields('03').value,
                                0,
                                0,
                                p_txmsg.txfields('63').value,
                                0 + p_txmsg.txfields('65').value,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                p_txmsg.txfields('72').value,
                                p_txmsg.txfields('74').value,
                                p_txmsg.txfields('77').value,
                                p_txmsg.txfields('80').value,
                                0,
                                0,
                                l_auto,
                                0,0,0,0,0,0,0,0);

    else
        for rec in (
            SELECT * FROM
                  (SELECT AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID, FEEPAID2 FROM LNSCHDLOG
                  UNION ALL
                  SELECT AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID, FEEPAID2 FROM LNSCHDLOGHIST)
                  WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate,systemnums.c_date_format)
        )
        loop
            UPDATE LNSCHD
                SET NML = NML - rec.NML,
                    OVD=OVD - rec.OVD,
                    PAID=PAID - rec.PAID,
                    INTNMLACR=INTNMLACR - rec.INTNMLACR,
                    FEE=FEE - rec.FEE   ,
                    INTDUE=INTDUE - rec.INTDUE,
                    INTOVD=INTOVD - rec.INTOVD,
                    INTOVDPRIN=INTOVDPRIN - rec.INTOVDPRIN,
                    FEEDUE=FEEDUE - rec.FEEDUE,
                    FEEOVD=FEEOVD - rec.FEEOVD,
                    INTPAID=INTPAID - rec.INTPAID,
                    FEEPAID=FEEPAID - rec.FEEPAID,
                    FEEPAID2=FEEPAID2 - rec.FEEPAID2
                WHERE AUTOID =rec.AUTOID;
        end loop;
        DELETE LNSCHDLOG WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate,systemnums.c_date_format);
        DELETE LNSCHDLOGHIST WHERE TXNUM = p_txmsg.txnum AND TXDATE =  TO_DATE(p_txmsg.txdate,systemnums.c_date_format);
    end if;
    plog.debug (pkgctx, '<<END OF fn_PaymentScheduleAllocate');
    plog.setendsection (pkgctx, 'fn_PaymentScheduleAllocate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_PaymentScheduleAllocate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_PaymentScheduleAllocate;


 ---------------------------------fn_Loanpaymentschd------------------------------------------------
function fn_Loanpaymentschd
   (pv_strTXNUM IN VARCHAR2,
    pv_strTXDATE IN VARCHAR2,
    pv_strACCTNO IN VARCHAR2,
    pv_dblT0PRINOVD IN NUMBER,
    pv_dblT0PRINNML IN NUMBER,
    pv_dblPRINOVD IN NUMBER,
    pv_dblPRINNML IN NUMBER,
    pv_dblFEEOVD IN NUMBER,
    pv_dblFEEDUE IN NUMBER,
    pv_dblFEENML IN NUMBER,
    pv_dblT0INTNMLOVD IN NUMBER,
    pv_dblT0INTOVDACR IN NUMBER,
    pv_dblT0INTDUE IN NUMBER,
    pv_dblT0INTNMLACR IN NUMBER,
    pv_dblINTNMLOVD IN NUMBER,
    pv_dblINTOVDACR IN NUMBER,
    pv_dblINTDUE IN NUMBER,
    pv_dblINTNMLACR IN NUMBER,
    pv_dblADVFEE IN NUMBER,
    pv_dblADVPAYFEE IN NUMBER,
    pv_blnAUTO IN CHAR,
    pv_dblFEEINTNMLACR IN NUMBER,
    pv_dblFEEINTOVDACR IN NUMBER,
    pv_dblFEEINTNMLOVD IN NUMBER,
    pv_dblFEEINTDUE IN NUMBER,
    pv_dblINTFLOATAMT  IN NUMBER,
    pv_dblFEEINTFLOATAMT  IN NUMBER,
    pv_dblISFLOATINT   IN NUMBER,
    pv_dblISPAYINTIM   IN NUMBER )

   return number
   IS
    l_lngErrCode    number(20,0);
    v_dblT0PRINOVD NUMBER(20,0);
    v_dblT0PRINNML NUMBER(20,0);
    v_dblPRINOVD NUMBER(20,0);
    v_dblPRINNML NUMBER(20,0);
    v_dblFEEOVD NUMBER(20,0);
    v_dblFEEDUE NUMBER(20,0);
    v_dblFEENML NUMBER(20,0);
    v_dblT0INTNMLOVD NUMBER(20,0);
    v_dblT0INTOVDACR NUMBER(20,0);
    v_dblT0INTDUE NUMBER(20,0);
    v_dblT0INTNMLACR NUMBER(20,0);
    v_dblINTNMLOVD NUMBER(20,0);
    v_dblINTOVDACR NUMBER(20,0);
    v_dblINTDUE NUMBER(20,0);
    v_dblINTNMLACR NUMBER(20,0);
    v_dblPaidAmt Number(20,0);
    v_dblFeeAmt Number(20,0);
    v_dblSumFee Number(20,0);
    v_dblAmt Number(20,0);
    v_dblT0RETRIEVED Number(20,0);
    --PhuongHT add
    v_dblFEEINTNMLOVD NUMBER(20,0);
    v_dblFEEINTOVDACR NUMBER(20,0);
    v_dblFEEINTDUE NUMBER(20,0);
    v_dblFEEINTNMLACR NUMBER(20,0);
    v_dblINTNMLACRTERM NUMBER (20,4);
    v_dblFEEINTNMLACRTERM NUMBER (20,4);
    v_strFTYPE VARCHAR2(10);
    v_dblADVFEE number(20,4);
    v_dblADVPAYFEE number(20,4);
    l_afacctno varchar2(100);
    v_REMAINLNAMT   NUMBER;


BEGIN
    plog.setbeginsection (pkgctx, 'fn_Loanpaymentschd');
    plog.debug (pkgctx, '<<BEGIN OF fn_Loanpaymentschd');
    plog.debug (pkgctx, 'chk:1');
    plog.debug (pkgctx, 'chk:2');
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    v_dblT0PRINOVD:= round(pv_dblT0PRINOVD,0);
    v_dblT0PRINNML:= round(pv_dblT0PRINNML,0);
    v_dblT0INTNMLOVD:= round(pv_dblT0INTNMLOVD,0);
    v_dblT0INTOVDACR:= round(pv_dblT0INTOVDACR,0);
    v_dblT0INTDUE:= round(pv_dblT0INTDUE,0);
    v_dblT0INTNMLACR:= round(pv_dblT0INTNMLACR,0);
    plog.debug (pkgctx, 'chk:3');
    v_dblPRINOVD:= round(pv_dblPRINOVD,0);
    v_dblPRINNML:= round(pv_dblPRINNML,0);
    v_dblINTNMLOVD:= round(pv_dblINTNMLOVD,0);
    v_dblINTOVDACR:= round(pv_dblINTOVDACR,0);
    v_dblINTDUE:= round(pv_dblINTDUE,0);
    v_dblINTNMLACR:= round(pv_dblINTNMLACR,0);
    plog.debug (pkgctx, 'chk:4');
    v_dblFEEOVD:= round(pv_dblFEEOVD,0);
    v_dblFEEDUE:= round(pv_dblFEEDUE,0);
    v_dblFEENML:= round(pv_dblFEENML,0);
    plog.debug (pkgctx, 'chk:5');
    v_dblFEEINTNMLOVD:= round(pv_dblFEEINTNMLOVD,0);
    v_dblFEEINTOVDACR:= round(pv_dblFEEINTOVDACR,0);
    v_dblFEEINTDUE:= round(pv_dblFEEINTDUE,0);
    v_dblFEEINTNMLACR:= round(pv_dblFEEINTNMLACR,0);
    v_dblADVPAYFEE:=round(pv_dblADVPAYFEE,0);

    -- xet xem hop dong thuoc loai nao
    SELECT ftype
        INTO v_strFTYPE
    FROM lnmast WHERE acctno =pv_strACCTNO;
    if(v_strFTYPE='DF' ) THEN
    -- tinh ti le  phi trong han thuc/phi TH theo term   : dung cho truong hop DF
    -- de neu tra truoc han chi tru paidint* no thuc/no theo term vao intnmlacr/feeintnmlacr

        SELECT  ROUND(GREATEST(
                (CASE WHEN  S.RLSDATE+m.minterm < S.DUEDATE THEN nml*S.RATE1*M.MINTERM/100/360
                ELSE nml*S.RATE1*(S.DUEDATE-S.RLSDATE)/100/360+NML*S.RATE2/100/360*(to_date(S.RLSDATE+m.minterm,'DD/MM/YYYY')-to_date(S.DUEDATE,'DD/MM/YYYY')) END)
                                  ,S.INTNMLACR) ,4) ,
                ROUND (GREATEST(
                (CASE WHEN  S.RLSDATE+m.minterm < S.DUEDATE THEN nml*S.cfRATE1*M.MINTERM/100/360
                ELSE nml*S.CFRATE1*(S.DUEDATE-S.RLSDATE)/100/360+NML*S.CFRATE2/100/360*(to_date(S.RLSDATE+m.minterm,'DD/MM/YYYY')-to_date(S.DUEDATE,'DD/MM/YYYY')) END)
                                  ,S.FEEINTNMLACR),4)
                    INTO v_dblINTNMLACRTERM,v_dblFEEINTNMLACRTERM

        FROM LNSCHD S, LNMAST M
        WHERE  S.REFTYPE IN ('P')  AND s.acctno=m.acctno
              AND s.acctno=pv_strACCTNO ;
    END IF ;




-- Phan bo goc T0
    -- Phan bo goc T0 qua han
    IF v_dblT0PRINOVD > 0 THEN
        FOR REC1 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0PRINOVD > 0 THEN
                IF v_dblT0PRINOVD >= REC1.OVD THEN
                    v_dblPaidAmt:= REC1.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblT0PRINOVD;
                END IF;
                v_dblT0PRINOVD:= v_dblT0PRINOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC1.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC1.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;
    plog.debug (pkgctx, 'chk:6');
    -- Phan bo goc T0 den han va trong han
    IF v_dblT0PRINNML > 0 THEN
        FOR REC2 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0PRINNML > 0 THEN
                IF v_dblT0PRINNML >= REC2.NML THEN
                    v_dblPaidAmt:= REC2.NML;
                ELSE
                    v_dblPaidAmt:= v_dblT0PRINNML;
                END IF;
                v_dblT0PRINNML:= v_dblT0PRINNML - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC2.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;
    plog.debug (pkgctx, 'chk:7');
-- Phan bo goc Margin
    -- Phan bo goc Margin qua han
    IF v_dblPRINOVD > 0 THEN
        FOR REC3 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblPRINOVD > 0 THEN
                IF v_dblPRINOVD >= REC3.OVD THEN
                    v_dblPaidAmt:= REC3.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblPRINOVD;
                END IF;
                v_dblPRINOVD:= v_dblPRINOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC3.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC3.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;
    plog.debug (pkgctx, 'chk:8');
    -- Phan bo goc Margin den han
    IF v_dblPRINNML > 0 THEN
        FOR REC4_1 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND NML > 0 AND OVERDUEDATE = TO_DATE(pv_strTXDATE,'dd/mm/rrrr'))
        LOOP
            IF v_dblPRINNML > 0 THEN
                IF v_dblPRINNML >= REC4_1.NML THEN
                    v_dblPaidAmt:= REC4_1.NML;
                ELSE
                    v_dblPaidAmt:= v_dblPRINNML;

                END IF;
                v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_1.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC4_1.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;

    END IF;

    v_dblADVFEE:= pv_dblADVFEE * (case when v_strFTYPE = 'AF' then 1 else 0 end);
    -- Phan bo goc Margin trong han
    IF v_dblPRINNML > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC4_2 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND NML > 0 AND OVERDUEDATE > TO_DATE(pv_strTXDATE,'dd/mm/rrrr') ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblPRINNML > 0 THEN
                v_dblPaidAmt:=least(v_dblPRINNML,REC4_2.NML);
                v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt;
                v_dblFeeAmt:= least(v_dblPaidAmt*v_dblAdvFee/100,v_dblADVPAYFEE);
                v_dblADVPAYFEE:= v_dblADVPAYFEE - v_dblFeeAmt;

                --v_dblPaidAmt:= round(least(v_dblPRINNML, (least(v_dblPRINNML,REC4_2.NML) / (least(v_dblPRINNML,REC4_2.NML)*(1+v_dblADVFEE/100)) ) * least(v_dblPRINNML,REC4_2.NML)),0);
                --v_dblFeeAmt:= least(v_dblPaidAmt*(v_dblADVFEE/100),v_dblPRINNML-v_dblPaidAmt);
                --v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                --v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt - v_dblFeeAmt;

                If pv_blnAUTO = 'Y' THEN
                    UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, --FEE = FEE + v_dblFeeAmt,
                    FEEPAID = FEEPAID + v_dblFeeAmt,
                    PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_2.AUTOID;
                    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,FEEPAID)
                    VALUES(REC4_2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0,0, v_dblFeeAmt);
                ELSE
                    UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, --FEEPAID2 = FEEPAID2 + v_dblFeeAmt,
                    PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_2.AUTOID;
                    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEEPAID2)
                    VALUES(REC4_2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                END IF;
            END IF;
        END LOOP;
        /*IF pv_blnAUTO = 'Y' THEN
            UPDATE LNMAST SET FEE = FEE + v_dblSumFee WHERE ACCTNO = pv_strACCTNO;
        END IF;*/

    END IF;

-- Phan bo phi
    -- Phan bo phi qua han
    IF v_dblFEEOVD > 0 THEN
        FOR REC5 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'F' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEOVD > 0 THEN
                IF v_dblFEEOVD >= REC5.OVD THEN
                    v_dblPaidAmt:= REC5.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblFEEOVD;
                END IF;
                v_dblFEEOVD:= v_dblFEEOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC5.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC5.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR FEEOVDREC IN
                    (SELECT AUTOID, round(FEEOVD,0) FEEOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEOVD > 0 ORDER BY RLSDATE)
                LOOP
                    If v_dblAmt > 0 THEN
                        If v_dblAmt >= FEEOVDREC.FEEOVD THEN
                            v_dblPaidAmt:= FEEOVDREC.FEEOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEOVD = FEEOVD - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt WHERE AUTOID = FEEOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(FEEOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi den han
    IF v_dblFEEDUE > 0 THEN
        FOR REC6 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'F' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEDUE > 0 THEN
                IF v_dblFEEDUE >= REC6.NML THEN
                    v_dblPaidAmt:= REC6.NML;
                ELSE
                    v_dblPaidAmt:= v_dblFEEDUE;
                END IF;
                v_dblFEEDUE:= v_dblFEEDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC6.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC6.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR FEEDUEREC IN
                    (SELECT AUTOID, round(FEEDUE,0) FEEDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= FEEDUEREC.FEEDUE THEN
                            v_dblPaidAmt:= FEEDUEREC.FEEDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEDUE = FEEDUE - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt WHERE AUTOID = FEEDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(FEEDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi trong han
    --IF pv_blnAUTO = 'N' AND v_dblFEENML > 0 THEN
    IF v_dblFEENML > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC7 IN
            (SELECT AUTOID, round(FEE,0) FEE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE IN ('P','GP') AND FEE > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEENML > 0 THEN
                IF v_dblFEENML >= REC7.FEE THEN
                    v_dblPaidAmt:= REC7.FEE;
                ELSE
                    v_dblPaidAmt:= v_dblFEENML;
                END IF;
                v_dblFEENML:= v_dblFEENML - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET FEE = FEE - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC7.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, FEEPAID, FEEPAID2)
                VALUES(REC7.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt, 0);
            END IF;
        END LOOP;
    END IF;

-- Phan bo lai vay T0
    -- Phan bo lai T0 qua han
    IF v_dblT0INTNMLOVD > 0 THEN
        FOR REC8 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GI' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTNMLOVD > 0 THEN
                IF v_dblT0INTNMLOVD >= REC8.OVD THEN
                    v_dblPaidAmt:= REC8.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTNMLOVD;
                END IF;
                v_dblT0INTNMLOVD:= v_dblT0INTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC8.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC8.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR T0INTOVDREC IN
                    (SELECT AUTOID, round(INTOVD,0) INTOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTOVD > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= T0INTOVDREC.INTOVD THEN
                            v_dblPaidAmt:= T0INTOVDREC.INTOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTOVD = INTOVD - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = T0INTOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(T0INTOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai tren goc T0 qua han
    IF v_dblT0INTOVDACR > 0 THEN
        FOR REC_OVD IN
            (SELECT AUTOID, round(INTOVDPRIN,0) INTOVDPRIN FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTOVDPRIN > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTOVDACR > 0 THEN
                IF v_dblT0INTOVDACR >= REC_OVD.INTOVDPRIN THEN
                    v_dblPaidAmt:= REC_OVD.INTOVDPRIN;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTOVDACR;
                END IF;
                v_dblT0INTOVDACR:= v_dblT0INTOVDACR - v_dblPaidAmt;
                UPDATE LNSCHD SET INTOVDPRIN = INTOVDPRIN - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC_OVD.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTOVDPRIN, INTPAID)
                VALUES(REC_OVD.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai T0 den han
    IF v_dblT0INTDUE > 0 THEN
        FOR REC9 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GI' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTDUE > 0 THEN
                IF v_dblT0INTDUE >= REC9.NML THEN
                    v_dblPaidAmt:= REC9.NML;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTDUE;
                END IF;
                v_dblT0INTDUE:= v_dblT0INTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC9.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC9.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR T0INTDUEREC IN
                    (SELECT AUTOID, round(INTDUE,0) INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= T0INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= T0INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTDUE = INTDUE - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = T0INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(T0INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai T0 trong han
    --IF pv_blnAUTO = 'N' AND v_dblT0INTNMLACR > 0 THEN
    IF v_dblT0INTNMLACR > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC10 IN
            (SELECT AUTOID, round(INTNMLACR,0) INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTNMLACR > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTNMLACR > 0 THEN
                IF v_dblT0INTNMLACR >= REC10.INTNMLACR THEN
                    v_dblPaidAmt:= REC10.INTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTNMLACR;
                END IF;
                v_dblT0INTNMLACR:= v_dblT0INTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC10.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID, FEEPAID2)
                VALUES(REC10.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, 0);
            END IF;
        END LOOP;
    END IF;

-- Phan bo lai vay Margin
    -- Phan bo lai Margin qua han
    IF v_dblINTNMLOVD > 0 THEN
        FOR REC11 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTNMLOVD > 0 THEN
                IF v_dblINTNMLOVD >= REC11.OVD THEN
                    v_dblPaidAmt:= REC11.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblINTNMLOVD;
                END IF;
                v_dblINTNMLOVD:= v_dblINTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC11.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC11.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTOVDREC IN
                    (SELECT AUTOID, round(INTOVD,0) INTOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTOVD > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTOVDREC.INTOVD THEN
                            v_dblPaidAmt:= INTOVDREC.INTOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTOVD = INTOVD - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = INTOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(INTOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

   -- Phan bo phi d.vu Margin qua han
    IF v_dblFEEINTNMLOVD > 0 THEN
        FOR REC11 IN
            (SELECT AUTOID, round(OVDFEEINT,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND OVDFEEINT > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEINTNMLOVD > 0 THEN
                IF v_dblFEEINTNMLOVD >= REC11.OVD THEN
                    v_dblPaidAmt:= REC11.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTNMLOVD;
                END IF;
                v_dblFEEINTNMLOVD:= v_dblFEEINTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVDFEEINT = OVDFEEINT - v_dblPaidAmt, PAIDFEEINT = PAIDFEEINT + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC11.AUTOID;
                INSERT INTO LNSCHDLOG
                  (AUTOID, TXNUM, TXDATE, NML, OVDFEEINT, PAIDFEEINT, INTNMLACR, FEE)
                VALUES
                  (REC11.AUTOID, pv_strTXNUM,
                   TO_DATE(pv_strTXDATE, 'dd/mm/rrrr'), 0, -v_dblPaidAmt,
                   v_dblPaidAmt, 0, 0);
                v_dblAmt := v_dblPaidAmt;
                FOR INTOVDREC IN
                    (SELECT AUTOID, round(FEEINTNMLOVD,0) FEEINTNMLOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTNMLOVD > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTOVDREC.FEEINTNMLOVD THEN
                            v_dblPaidAmt:= INTOVDREC.FEEINTNMLOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEINTNMLOVD = FEEINTNMLOVD - v_dblPaidAmt, FEEINTPAID = FEEINTPAID + v_dblPaidAmt WHERE AUTOID = INTOVDREC.AUTOID;
                    INSERT INTO LNSCHDLOG
                      (AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR,
                       FEE, INTDUE, FEEINTOVD, FEEDUE, FEEOVD, FEEINTPAID, FEEPAID)
                    VALUES
                      (INTOVDREC.AUTOID, pv_strTXNUM,
                       TO_DATE(pv_strTXDATE, 'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0,
                       -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai tren goc margin qua han
    IF v_dblINTOVDACR > 0 THEN
        FOR REC_MROVD IN
            (SELECT AUTOID, round(INTOVDPRIN,0) INTOVDPRIN FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTOVDPRIN > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTOVDACR > 0 THEN
                IF v_dblINTOVDACR >= REC_MROVD.INTOVDPRIN THEN
                    v_dblPaidAmt:= REC_MROVD.INTOVDPRIN;
                ELSE
                    v_dblPaidAmt:= v_dblINTOVDACR;
                END IF;
                v_dblINTOVDACR:= v_dblINTOVDACR - v_dblPaidAmt;
                UPDATE LNSCHD SET INTOVDPRIN = INTOVDPRIN - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC_MROVD.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTOVDPRIN, INTPAID)
                VALUES(REC_MROVD.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi d.vu tren goc margin qua han
    IF v_dblFEEINTOVDACR > 0 THEN
        FOR REC_MROVD IN
            (SELECT AUTOID, round(FEEINTOVDACR,0) FEEINTOVDACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTOVDACR > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEINTOVDACR > 0 THEN
                IF v_dblFEEINTOVDACR >= REC_MROVD.FEEINTOVDACR THEN
                    v_dblPaidAmt:= REC_MROVD.FEEINTOVDACR;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTOVDACR;
                END IF;
                v_dblFEEINTOVDACR:= v_dblFEEINTOVDACR - v_dblPaidAmt;

             UPDATE LNSCHD
                   SET FEEINTOVDACR = FEEINTOVDACR - v_dblPaidAmt,
                       FEEINTPAID    = FEEINTPAID + v_dblPaidAmt,
                       PAIDDATE   = TO_DATE(pv_strTXDATE, 'DD/MM/RRRR')
                 WHERE AUTOID = REC_MROVD.AUTOID;

            INSERT INTO LNSCHDLOG
              (AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,
               feeINTOVDPRIN, FEEINTPAID)
            VALUES
              (REC_MROVD.AUTOID, pv_strTXNUM,
               TO_DATE(pv_strTXDATE, 'dd/mm/rrrr'), 0, 0, 0, 0, 0,
               -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai Margin den han
    IF v_dblINTDUE > 0 THEN
        FOR REC12 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTDUE > 0 THEN
                IF v_dblINTDUE >= REC12.NML THEN
                    v_dblPaidAmt:= REC12.NML;
                ELSE
                    v_dblPaidAmt:= v_dblINTDUE;
                END IF;
                v_dblINTDUE:= v_dblINTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC12.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC12.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTDUEREC IN
                    (SELECT AUTOID, round(INTDUE,0) INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTDUE = INTDUE - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

-- Phan bo phi d.v? Margin den han
    IF v_dblFEEINTDUE > 0 THEN
        FOR REC12 IN
            (SELECT AUTOID, round(NMLFEEINT,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND NMLFEEINT > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEINTDUE > 0 THEN
                IF v_dblFEEINTDUE >= REC12.NML THEN
                    v_dblPaidAmt:= REC12.NML;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTDUE;
                END IF;
                v_dblFEEINTDUE:= v_dblFEEINTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NMLFEEINT = NMLFEEINT - v_dblPaidAmt, PAIDFEEINT = PAIDFEEINT + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC12.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAIDFEEINT, FEEINTNMLACR, FEE)
                VALUES(REC12.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTDUEREC IN
                    (SELECT AUTOID, round(FEEINTDUE,0) INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEINTDUE = FEEINTDUE - v_dblPaidAmt, FEEINTPAID = FEEINTPAID + v_dblPaidAmt WHERE AUTOID = INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,FEEINTDUE,INTOVD,FEEDUE,FEEOVD,FEEINTPAID,FEEPAID)
                        VALUES(INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai Margin trong han
    --IF pv_blnAUTO = 'N' AND v_dblINTNMLACR > 0 THEN
    IF v_dblINTNMLACR > 0 THEN
      -- neu la hop dong AF
      IF v_strFTYPE ='AF' THEN
        FOR REC13 IN
            (SELECT AUTOID, round(INTNMLACR,0) INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTNMLACR > 0 ORDER BY OVERDUEDATE)
        LOOP


              IF v_dblINTNMLACR > 0 THEN

                IF v_dblINTNMLACR >= REC13.INTNMLACR THEN
                    v_dblPaidAmt:= REC13.INTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblINTNMLACR;
                END IF;
                v_dblINTNMLACR:= v_dblINTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID, FEEPAID2)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, 0);

            END IF;
        END LOOP;
        ELSIF v_strFTYPE ='DF' THEN -- hop dong DF
        FOR REC13 IN
            (SELECT AUTOID, round(INTNMLACR,0) INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P'  ORDER BY OVERDUEDATE)
        LOOP
          v_dblPaidAmt:= v_dblINTNMLACR;
             v_dblINTNMLACR:= v_dblINTNMLACR - v_dblPaidAmt;
              /*  v_dblFeeAmt:= round(v_dblPaidAmt*pv_dblAdvFee/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;*/
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - round( v_dblPaidAmt*rec13.intnmlacr/v_dblINTNMLACRTERM,4), INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);
          END LOOP;
        END IF;
    END IF;

    -- Phan bo phi d.vu Margin trong han
    --IF pv_blnAUTO = 'N' AND v_dblINTNMLACR > 0 THEN
    IF v_dblFEEINTNMLACR > 0 THEN
      IF v_strFTYPE ='AF' THEN
        FOR REC13 IN
            (SELECT AUTOID, round(FEEINTNMLACR,0) FEEINTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTNMLACR > 0 ORDER BY OVERDUEDATE)
        LOOP

            IF v_dblFEEINTNMLACR > 0 THEN

                IF v_dblFEEINTNMLACR >= REC13.FEEINTNMLACR THEN
                    v_dblPaidAmt:= REC13.FEEINTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTNMLACR;
                END IF;
                v_dblFEEINTNMLACR:= v_dblFEEINTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET FEEINTNMLACR = FEEINTNMLACR - v_dblPaidAmt, FEEINTPAID = FEEINTPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, FEEINTNMLACR, FEE, FEEINTPAID, FEEPAID2)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, 0);


            END IF;
        END LOOP;
         ELSIF  v_strFTYPE ='DF' THEN -- hop dong DF
         FOR REC13 IN
            (SELECT AUTOID, round(FEEINTNMLACR,0) FEEINTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' ORDER BY OVERDUEDATE)
        LOOP
                    v_dblPaidAmt:= v_dblFEEINTNMLACR;

                v_dblFEEINTNMLACR:= v_dblFEEINTNMLACR - v_dblPaidAmt;
                /*v_dblFeeAmt:= round(v_dblPaidAmt*pv_dblAdvFee/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;*/
                UPDATE LNSCHD SET FEEINTNMLACR = FEEINTNMLACR - round(v_dblPaidAmt*rec13.feeintnmlacr/v_dblFEEINTNMLACRTERM,4),
                       FEEINTPAID = FEEINTPAID + v_dblPaidAmt WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, FEEINTNMLACR, FEE, FEEINTPAID)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);

                END LOOP;
            END IF;
    END IF;

    -- Thu hoi T0 da giai ngan theo thu tu uu tien, cap truoc thu hoi truoc
    v_dblT0RETRIEVED := pv_dblT0PRINOVD + pv_dblT0PRINNML;

      select trfacctno into l_afacctno from lnmast where acctno = pv_strACCTNO;
      plog.error (pkgctx, 'LINHLNB:l_afacctno:'||l_afacctno);

    IF v_dblT0RETRIEVED > 0 THEN
        FOR REC_T0 IN
            (
                SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT
                FROM (select * from T0LIMITSCHD
                        union all
                     select * from T0LIMITSCHDHIST)
                WHERE ACCTNO = l_afacctno AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                ORDER BY AUTOID
            )
        LOOP
            IF v_dblT0RETRIEVED > 0 THEN
                IF v_dblT0RETRIEVED > REC_T0.AMT THEN
                    v_dblAmt := REC_T0.AMT;
                ELSE
                    v_dblAmt := v_dblT0RETRIEVED;
                END IF;
                v_dblT0RETRIEVED := v_dblT0RETRIEVED - v_dblAmt;

                UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + v_dblAmt WHERE AUTOID = REC_T0.AUTOID;
                UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + v_dblAmt WHERE AUTOID = REC_T0.AUTOID;

                UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - v_dblAmt
                WHERE ACCTNO = l_afacctno AND TLIDUSER = REC_T0.TLID AND typereceive = 'T0';

                INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
                VALUES (pv_strTXNUM,TO_DATE(pv_strTXDATE,'DD/MM/RRRR'),l_afacctno,-v_dblAmt,REC_T0.TLID,REC_T0.TYPEALLOCATE,'T0');

                INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                VALUES(TO_DATE(pv_strTXDATE,'DD/MM/RRRR'),pv_strTXNUM, REC_T0.AUTOID, REC_T0.TLID, v_dblAmt);
            END IF;
        END LOOP;
    END IF;

    --Kiem tra xem co phai lan tra cuoi cung khong
     SELECT trunc(lns.nml)+trunc(lns.ovd)+trunc(lns.FEE)+trunc(lns.FEEOVD)+trunc(lns.FEEDUE)+trunc(lns.INTNMLACR)
            +trunc(lns.INTDUE)+trunc(lns.INTOVD)+trunc(lns.INTOVDPRIN)+trunc(lns.FEEINTNMLOVD)
            +trunc(lns.FEEINTOVDACR)+trunc(lns.FEEINTDUE)+trunc(lns.FEEINTNMLACR)
     INTO v_REMAINLNAMT
     FROM lnschd lns
     WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P';
     -- Neu la lan tra cuoi cung thi update vao LNSCHDLOG
     IF v_REMAINLNAMT <1 THEN
        UPDATE lnschdlog SET
            LASTPAID = 'Y'
        WHERE TXNUM = pv_strTXNUM AND txdate = TO_DATE(pv_strTXDATE,'DD/MM/RRRR');
     END IF;

    plog.debug (pkgctx, '<<END OF fn_Loanpaymentschd');
    plog.setendsection (pkgctx, 'fn_Loanpaymentschd');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_Loanpaymentschd');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_Loanpaymentschd;-- Procedure





 ---------------------------------fn_Loanpaymentschd_by_autoid------------------------------------------------
function fn_Loanpaymentschd_by_autoid
   (pv_strTXNUM IN VARCHAR2,
    pv_strTXDATE IN VARCHAR2,
    pv_strACCTNO IN VARCHAR2,
    pv_dblT0PRINOVD IN NUMBER,
    pv_dblT0PRINNML IN NUMBER,
    pv_dblPRINOVD IN NUMBER,
    pv_dblPRINNML IN NUMBER,
    pv_dblFEEOVD IN NUMBER,
    pv_dblFEEDUE IN NUMBER,
    pv_dblFEENML IN NUMBER,
    pv_dblT0INTNMLOVD IN NUMBER,
    pv_dblT0INTOVDACR IN NUMBER,
    pv_dblT0INTDUE IN NUMBER,
    pv_dblT0INTNMLACR IN NUMBER,
    pv_dblINTNMLOVD IN NUMBER,
    pv_dblINTOVDACR IN NUMBER,
    pv_dblINTDUE IN NUMBER,
    pv_dblINTNMLACR IN NUMBER,
    pv_dblADVFEE IN NUMBER,
    pv_dblADVPAYFEE IN NUMBER,
    pv_blnAUTO IN CHAR,
    pv_dblFEEINTNMLACR IN NUMBER,
    pv_dblFEEINTOVDACR IN NUMBER,
    pv_dblFEEINTNMLOVD IN NUMBER,
    pv_dblFEEINTDUE IN NUMBER,
    pv_dblINTFLOATAMT  IN NUMBER,
    pv_dblFEEINTFLOATAMT  IN NUMBER,
    pv_dblISFLOATINT   IN NUMBER,
    pv_dblISPAYINTIM   IN NUMBER,
    pv_dblACCRUALSAMT  IN NUMBER,
    pv_dblAUTOID        in number )

   return number
   IS
    l_lngErrCode    number(20,0);
    v_dblT0PRINOVD NUMBER(20,0);
    v_dblT0PRINNML NUMBER(20,0);
    v_dblPRINOVD NUMBER(20,0);
    v_dblPRINNML NUMBER(20,0);
    v_dblFEEOVD NUMBER(20,0);
    v_dblFEEDUE NUMBER(20,0);
    v_dblFEENML NUMBER(20,0);
    v_dblT0INTNMLOVD NUMBER(20,0);
    v_dblT0INTOVDACR NUMBER(20,0);
    v_dblT0INTDUE NUMBER(20,0);
    v_dblT0INTNMLACR NUMBER(20,0);
    v_dblINTNMLOVD NUMBER(20,0);
    v_dblINTOVDACR NUMBER(20,0);
    v_dblINTDUE NUMBER(20,0);
    v_dblINTNMLACR NUMBER(20,0);
    v_dblPaidAmt Number(20,0);
    v_dblFeeAmt Number(20,0);
    v_dblSumFee Number(20,0);
    v_dblAmt Number(20,0);
    v_dblT0RETRIEVED Number(20,0);
    --PhuongHT add
    v_dblFEEINTNMLOVD NUMBER(20,0);
    v_dblFEEINTOVDACR NUMBER(20,0);
    v_dblFEEINTDUE NUMBER(20,0);
    v_dblFEEINTNMLACR NUMBER(20,0);
    v_dblINTNMLACRTERM NUMBER (20,4);
    v_dblFEEINTNMLACRTERM NUMBER (20,4);
    v_strFTYPE VARCHAR2(10);
    v_dblADVFEE number(20,4);
    v_dblADVPAYFEE number(20,4);
    l_afacctno varchar2(100);
    v_REMAINLNAMT   NUMBER;
    v_dblACCRUALSAMT NUMBER (20,4);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_Loanpaymentschd_by_autoid');
    plog.debug (pkgctx, '<<BEGIN OF fn_Loanpaymentschd_by_autoid');
    plog.debug (pkgctx, 'chk:1');
    plog.debug (pkgctx, 'chk:2');
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    v_dblT0PRINOVD:= round(pv_dblT0PRINOVD,0);
    v_dblT0PRINNML:= round(pv_dblT0PRINNML,0);
    v_dblT0INTNMLOVD:= round(pv_dblT0INTNMLOVD,0);
    v_dblT0INTOVDACR:= round(pv_dblT0INTOVDACR,0);
    v_dblT0INTDUE:= round(pv_dblT0INTDUE,0);
    v_dblT0INTNMLACR:= round(pv_dblT0INTNMLACR,0);
    plog.debug (pkgctx, 'chk:3');
    v_dblPRINOVD:= round(pv_dblPRINOVD,0);
    v_dblPRINNML:= round(pv_dblPRINNML,0);
    v_dblINTNMLOVD:= round(pv_dblINTNMLOVD,0);
    v_dblINTOVDACR:= round(pv_dblINTOVDACR,0);
    v_dblINTDUE:= round(pv_dblINTDUE,0);
    v_dblINTNMLACR:= round(pv_dblINTNMLACR,0);
    plog.debug (pkgctx, 'chk:4');
    v_dblFEEOVD:= round(pv_dblFEEOVD,0);
    v_dblFEEDUE:= round(pv_dblFEEDUE,0);
    v_dblFEENML:= round(pv_dblFEENML,0);
    plog.debug (pkgctx, 'chk:5');
    v_dblFEEINTNMLOVD:= round(pv_dblFEEINTNMLOVD,0);
    v_dblFEEINTOVDACR:= round(pv_dblFEEINTOVDACR,0);
    v_dblFEEINTDUE:= round(pv_dblFEEINTDUE,0);
    v_dblFEEINTNMLACR:= round(pv_dblFEEINTNMLACR,0);
    v_dblADVPAYFEE:=round(pv_dblADVPAYFEE,0);
    v_dblACCRUALSAMT:=round(pv_dblACCRUALSAMT,0);
    -- xet xem hop dong thuoc loai nao
    SELECT ftype
        INTO v_strFTYPE
    FROM lnmast WHERE acctno =pv_strACCTNO;
    if(v_strFTYPE='DF' ) THEN
    -- tinh ti le  phi trong han thuc/phi TH theo term   : dung cho truong hop DF
    -- de neu tra truoc han chi tru paidint* no thuc/no theo term vao intnmlacr/feeintnmlacr

        SELECT  ROUND(GREATEST(
                (CASE WHEN  S.RLSDATE+m.minterm < S.DUEDATE THEN nml*S.RATE1*M.MINTERM/100/360
                ELSE nml*S.RATE1*(S.DUEDATE-S.RLSDATE)/100/360+NML*S.RATE2/100/360*(to_date(S.RLSDATE+m.minterm,'DD/MM/YYYY')-to_date(S.DUEDATE,'DD/MM/YYYY')) END)
                                  ,S.INTNMLACR) ,4) ,
                ROUND (GREATEST(
                (CASE WHEN  S.RLSDATE+m.minterm < S.DUEDATE THEN nml*S.cfRATE1*M.MINTERM/100/360
                ELSE nml*S.CFRATE1*(S.DUEDATE-S.RLSDATE)/100/360+NML*S.CFRATE2/100/360*(to_date(S.RLSDATE+m.minterm,'DD/MM/YYYY')-to_date(S.DUEDATE,'DD/MM/YYYY')) END)
                                  ,S.FEEINTNMLACR),4)
                    INTO v_dblINTNMLACRTERM,v_dblFEEINTNMLACRTERM

        FROM LNSCHD S, LNMAST M
        WHERE  S.REFTYPE IN ('P')  AND s.acctno=m.acctno
              AND s.acctno=pv_strACCTNO ;
    END IF ;




-- Phan bo goc T0
    -- Phan bo goc T0 qua han
    IF v_dblT0PRINOVD > 0 THEN
        FOR REC1 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND OVD > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0PRINOVD > 0 THEN
                IF v_dblT0PRINOVD >= REC1.OVD THEN
                    v_dblPaidAmt:= REC1.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblT0PRINOVD;
                END IF;
                v_dblT0PRINOVD:= v_dblT0PRINOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC1.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC1.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;
    plog.debug (pkgctx, 'chk:6');
    -- Phan bo goc T0 den han va trong han
    IF v_dblT0PRINNML > 0 THEN
        FOR REC2 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND NML > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0PRINNML > 0 THEN
                IF v_dblT0PRINNML >= REC2.NML THEN
                    v_dblPaidAmt:= REC2.NML;
                ELSE
                    v_dblPaidAmt:= v_dblT0PRINNML;
                END IF;
                v_dblT0PRINNML:= v_dblT0PRINNML - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC2.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;
    plog.debug (pkgctx, 'chk:7');
-- Phan bo goc Margin
    -- Phan bo goc Margin qua han
    IF v_dblPRINOVD > 0 THEN
        FOR REC3 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND OVD > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblPRINOVD > 0 THEN
                IF v_dblPRINOVD >= REC3.OVD THEN
                    v_dblPaidAmt:= REC3.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblPRINOVD;
                END IF;
                v_dblPRINOVD:= v_dblPRINOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC3.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC3.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;
    plog.debug (pkgctx, 'chk:8');
    -- Phan bo goc Margin den han
    IF v_dblPRINNML > 0 THEN
        FOR REC4_1 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND NML > 0 and AUTOID = pv_dblAUTOID AND OVERDUEDATE = TO_DATE(pv_strTXDATE,'dd/mm/rrrr'))
        LOOP
            IF v_dblPRINNML > 0 THEN
                IF v_dblPRINNML >= REC4_1.NML THEN
                    v_dblPaidAmt:= REC4_1.NML;
                ELSE
                    v_dblPaidAmt:= v_dblPRINNML;

                END IF;
                v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_1.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC4_1.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;

    END IF;

    v_dblADVFEE:= pv_dblADVFEE * (case when v_strFTYPE = 'AF' then 1 else 0 end);
    -- Phan bo goc Margin trong han
    IF v_dblPRINNML > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC4_2 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND NML > 0 and AUTOID = pv_dblAUTOID AND OVERDUEDATE > TO_DATE(pv_strTXDATE,'dd/mm/rrrr') ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblPRINNML > 0 THEN
                v_dblPaidAmt:=least(v_dblPRINNML,REC4_2.NML);
                v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt;
                v_dblFeeAmt:= least(v_dblPaidAmt*v_dblAdvFee/100,v_dblADVPAYFEE);
                v_dblADVPAYFEE:= v_dblADVPAYFEE - v_dblFeeAmt;

                --v_dblPaidAmt:= round(least(v_dblPRINNML, (least(v_dblPRINNML,REC4_2.NML) / (least(v_dblPRINNML,REC4_2.NML)*(1+v_dblADVFEE/100)) ) * least(v_dblPRINNML,REC4_2.NML)),0);
                --v_dblFeeAmt:= least(v_dblPaidAmt*(v_dblADVFEE/100),v_dblPRINNML-v_dblPaidAmt);
                --v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                --v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt - v_dblFeeAmt;

                If pv_blnAUTO = 'Y' THEN
                    UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, --FEE = FEE + v_dblFeeAmt,
                    FEEPAID = FEEPAID + v_dblFeeAmt,
                    PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_2.AUTOID;
                    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,FEEPAID)
                    VALUES(REC4_2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0,0, v_dblFeeAmt);
                ELSE
                    UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, --FEEPAID2 = FEEPAID2 + v_dblFeeAmt,
                    PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_2.AUTOID;
                    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEEPAID2)
                    VALUES(REC4_2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                END IF;
            END IF;
        END LOOP;
        /*IF pv_blnAUTO = 'Y' THEN
            UPDATE LNMAST SET FEE = FEE + v_dblSumFee WHERE ACCTNO = pv_strACCTNO;
        END IF;*/

    END IF;

-- Phan bo phi
    -- Phan bo phi qua han
    IF v_dblFEEOVD > 0 THEN
        FOR REC5 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'F' AND OVD > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEOVD > 0 THEN
                IF v_dblFEEOVD >= REC5.OVD THEN
                    v_dblPaidAmt:= REC5.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblFEEOVD;
                END IF;
                v_dblFEEOVD:= v_dblFEEOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC5.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC5.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR FEEOVDREC IN
                    (SELECT AUTOID, round(FEEOVD,0) FEEOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEOVD > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    If v_dblAmt > 0 THEN
                        If v_dblAmt >= FEEOVDREC.FEEOVD THEN
                            v_dblPaidAmt:= FEEOVDREC.FEEOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEOVD = FEEOVD - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt WHERE AUTOID = FEEOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(FEEOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi den han
    IF v_dblFEEDUE > 0 THEN
        FOR REC6 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'F' AND NML > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEDUE > 0 THEN
                IF v_dblFEEDUE >= REC6.NML THEN
                    v_dblPaidAmt:= REC6.NML;
                ELSE
                    v_dblPaidAmt:= v_dblFEEDUE;
                END IF;
                v_dblFEEDUE:= v_dblFEEDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC6.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC6.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR FEEDUEREC IN
                    (SELECT AUTOID, round(FEEDUE,0) FEEDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEDUE > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= FEEDUEREC.FEEDUE THEN
                            v_dblPaidAmt:= FEEDUEREC.FEEDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEDUE = FEEDUE - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt WHERE AUTOID = FEEDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(FEEDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi trong han
    --IF pv_blnAUTO = 'N' AND v_dblFEENML > 0 THEN
    IF v_dblFEENML > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC7 IN
            (SELECT AUTOID, round(FEE,0) FEE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE IN ('P','GP') AND FEE > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEENML > 0 THEN
                IF v_dblFEENML >= REC7.FEE THEN
                    v_dblPaidAmt:= REC7.FEE;
                ELSE
                    v_dblPaidAmt:= v_dblFEENML;
                END IF;
                v_dblFEENML:= v_dblFEENML - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET FEE = FEE - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC7.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, FEEPAID, FEEPAID2)
                VALUES(REC7.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt, 0);
            END IF;
        END LOOP;
    END IF;

-- Phan bo lai vay T0
    -- Phan bo lai T0 qua han
    IF v_dblT0INTNMLOVD > 0 THEN
        FOR REC8 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GI' AND OVD > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTNMLOVD > 0 THEN
                IF v_dblT0INTNMLOVD >= REC8.OVD THEN
                    v_dblPaidAmt:= REC8.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTNMLOVD;
                END IF;
                v_dblT0INTNMLOVD:= v_dblT0INTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC8.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC8.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR T0INTOVDREC IN
                    (SELECT AUTOID, round(INTOVD,0) INTOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTOVD > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= T0INTOVDREC.INTOVD THEN
                            v_dblPaidAmt:= T0INTOVDREC.INTOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTOVD = INTOVD - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = T0INTOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(T0INTOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai tren goc T0 qua han
    IF v_dblT0INTOVDACR > 0 THEN
        FOR REC_OVD IN
            (SELECT AUTOID, round(INTOVDPRIN,0) INTOVDPRIN FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTOVDPRIN > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTOVDACR > 0 THEN
                IF v_dblT0INTOVDACR >= REC_OVD.INTOVDPRIN THEN
                    v_dblPaidAmt:= REC_OVD.INTOVDPRIN;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTOVDACR;
                END IF;
                v_dblT0INTOVDACR:= v_dblT0INTOVDACR - v_dblPaidAmt;
                UPDATE LNSCHD SET INTOVDPRIN = INTOVDPRIN - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC_OVD.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTOVDPRIN, INTPAID)
                VALUES(REC_OVD.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai T0 den han
    IF v_dblT0INTDUE > 0 THEN
        FOR REC9 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GI' AND NML > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTDUE > 0 THEN
                IF v_dblT0INTDUE >= REC9.NML THEN
                    v_dblPaidAmt:= REC9.NML;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTDUE;
                END IF;
                v_dblT0INTDUE:= v_dblT0INTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC9.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC9.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR T0INTDUEREC IN
                    (SELECT AUTOID, round(INTDUE,0) INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTDUE > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= T0INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= T0INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTDUE = INTDUE - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = T0INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(T0INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai T0 trong han
    --IF pv_blnAUTO = 'N' AND v_dblT0INTNMLACR > 0 THEN
    IF v_dblT0INTNMLACR > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC10 IN
            (SELECT AUTOID, round(INTNMLACR,0) INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTNMLACR > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTNMLACR > 0 THEN
                IF v_dblT0INTNMLACR >= REC10.INTNMLACR THEN
                    v_dblPaidAmt:= REC10.INTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTNMLACR;
                END IF;
                v_dblT0INTNMLACR:= v_dblT0INTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC10.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID, FEEPAID2)
                VALUES(REC10.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, 0);
            END IF;
        END LOOP;
    END IF;

-- Phan bo lai vay Margin
    -- Phan bo lai Margin qua han
    IF v_dblINTNMLOVD > 0 THEN
        FOR REC11 IN
            (SELECT AUTOID, round(OVD,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND OVD > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTNMLOVD > 0 THEN
                IF v_dblINTNMLOVD >= REC11.OVD THEN
                    v_dblPaidAmt:= REC11.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblINTNMLOVD;
                END IF;
                v_dblINTNMLOVD:= v_dblINTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC11.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC11.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTOVDREC IN
                    (SELECT AUTOID, round(INTOVD,0) INTOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTOVD > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTOVDREC.INTOVD THEN
                            v_dblPaidAmt:= INTOVDREC.INTOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTOVD = INTOVD - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = INTOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(INTOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

   -- Phan bo phi d.vu Margin qua han
    IF v_dblFEEINTNMLOVD > 0 THEN
        FOR REC11 IN
            (SELECT AUTOID, round(OVDFEEINT,0) OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND OVDFEEINT > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEINTNMLOVD > 0 THEN
                IF v_dblFEEINTNMLOVD >= REC11.OVD THEN
                    v_dblPaidAmt:= REC11.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTNMLOVD;
                END IF;
                v_dblFEEINTNMLOVD:= v_dblFEEINTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVDFEEINT = OVDFEEINT - v_dblPaidAmt, PAIDFEEINT = PAIDFEEINT + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC11.AUTOID;
                INSERT INTO LNSCHDLOG
                  (AUTOID, TXNUM, TXDATE, NML, OVDFEEINT, PAIDFEEINT, INTNMLACR, FEE)
                VALUES
                  (REC11.AUTOID, pv_strTXNUM,
                   TO_DATE(pv_strTXDATE, 'dd/mm/rrrr'), 0, -v_dblPaidAmt,
                   v_dblPaidAmt, 0, 0);
                v_dblAmt := v_dblPaidAmt;
                FOR INTOVDREC IN
                    (SELECT AUTOID, round(FEEINTNMLOVD,0) FEEINTNMLOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTNMLOVD > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTOVDREC.FEEINTNMLOVD THEN
                            v_dblPaidAmt:= INTOVDREC.FEEINTNMLOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEINTNMLOVD = FEEINTNMLOVD - v_dblPaidAmt, FEEINTPAID = FEEINTPAID + v_dblPaidAmt WHERE AUTOID = INTOVDREC.AUTOID;
                    INSERT INTO LNSCHDLOG
                      (AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR,
                       FEE, INTDUE, FEEINTOVD, FEEDUE, FEEOVD, FEEINTPAID, FEEPAID)
                    VALUES
                      (INTOVDREC.AUTOID, pv_strTXNUM,
                       TO_DATE(pv_strTXDATE, 'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0,
                       -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai tren goc margin qua han
    IF v_dblINTOVDACR > 0 THEN
        FOR REC_MROVD IN
            (SELECT AUTOID, round(INTOVDPRIN,0) INTOVDPRIN FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTOVDPRIN > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTOVDACR > 0 THEN
                IF v_dblINTOVDACR >= REC_MROVD.INTOVDPRIN THEN
                    v_dblPaidAmt:= REC_MROVD.INTOVDPRIN;
                ELSE
                    v_dblPaidAmt:= v_dblINTOVDACR;
                END IF;
                v_dblINTOVDACR:= v_dblINTOVDACR - v_dblPaidAmt;
                UPDATE LNSCHD SET INTOVDPRIN = INTOVDPRIN - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC_MROVD.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTOVDPRIN, INTPAID)
                VALUES(REC_MROVD.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi d.vu tren goc margin qua han
    IF v_dblFEEINTOVDACR > 0 THEN
        FOR REC_MROVD IN
            (SELECT AUTOID, round(FEEINTOVDACR,0) FEEINTOVDACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTOVDACR > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEINTOVDACR > 0 THEN
                IF v_dblFEEINTOVDACR >= REC_MROVD.FEEINTOVDACR THEN
                    v_dblPaidAmt:= REC_MROVD.FEEINTOVDACR;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTOVDACR;
                END IF;
                v_dblFEEINTOVDACR:= v_dblFEEINTOVDACR - v_dblPaidAmt;

             UPDATE LNSCHD
                   SET FEEINTOVDACR = FEEINTOVDACR - v_dblPaidAmt,
                       FEEINTPAID    = FEEINTPAID + v_dblPaidAmt,
                       PAIDDATE   = TO_DATE(pv_strTXDATE, 'DD/MM/RRRR')
                 WHERE AUTOID = REC_MROVD.AUTOID;

            INSERT INTO LNSCHDLOG
              (AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,
               feeINTOVDPRIN, FEEINTPAID)
            VALUES
              (REC_MROVD.AUTOID, pv_strTXNUM,
               TO_DATE(pv_strTXDATE, 'dd/mm/rrrr'), 0, 0, 0, 0, 0,
               -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai Margin den han
    IF v_dblINTDUE > 0 THEN
        FOR REC12 IN
            (SELECT AUTOID, round(NML,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND NML > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTDUE > 0 THEN
                IF v_dblINTDUE >= REC12.NML THEN
                    v_dblPaidAmt:= REC12.NML;
                ELSE
                    v_dblPaidAmt:= v_dblINTDUE;
                END IF;
                v_dblINTDUE:= v_dblINTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC12.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC12.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTDUEREC IN
                    (SELECT AUTOID, round(INTDUE,0) INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTDUE > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTDUE = INTDUE - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

-- Phan bo phi d.v? Margin den han
    IF v_dblFEEINTDUE > 0 THEN
        FOR REC12 IN
            (SELECT AUTOID, round(NMLFEEINT,0) NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND NMLFEEINT > 0 and REFAUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEINTDUE > 0 THEN
                IF v_dblFEEINTDUE >= REC12.NML THEN
                    v_dblPaidAmt:= REC12.NML;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTDUE;
                END IF;
                v_dblFEEINTDUE:= v_dblFEEINTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NMLFEEINT = NMLFEEINT - v_dblPaidAmt, PAIDFEEINT = PAIDFEEINT + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC12.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAIDFEEINT, FEEINTNMLACR, FEE)
                VALUES(REC12.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTDUEREC IN
                    (SELECT AUTOID, round(FEEINTDUE,0) INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTDUE > 0 and AUTOID = pv_dblAUTOID ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEINTDUE = FEEINTDUE - v_dblPaidAmt, FEEINTPAID = FEEINTPAID + v_dblPaidAmt WHERE AUTOID = INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,FEEINTDUE,INTOVD,FEEDUE,FEEOVD,FEEINTPAID,FEEPAID)
                        VALUES(INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai Margin trong han
    --IF pv_blnAUTO = 'N' AND v_dblINTNMLACR > 0 THEN
    IF v_dblINTNMLACR > 0 THEN
      -- neu la hop dong AF
      IF v_strFTYPE ='AF' THEN
        FOR REC13 IN
            (SELECT AUTOID, round(INTNMLACR,0) INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTNMLACR > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP


              IF v_dblINTNMLACR > 0 THEN

                IF v_dblINTNMLACR >= REC13.INTNMLACR THEN
                    v_dblPaidAmt:= REC13.INTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblINTNMLACR;
                END IF;
                v_dblINTNMLACR:= v_dblINTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID, FEEPAID2)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, 0);

            END IF;
        END LOOP;
        ELSIF v_strFTYPE ='DF' THEN -- hop dong DF
        FOR REC13 IN
            (SELECT AUTOID, round(INTNMLACR,0) INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P'  ORDER BY OVERDUEDATE)
        LOOP
          v_dblPaidAmt:= v_dblINTNMLACR;
             v_dblINTNMLACR:= v_dblINTNMLACR - v_dblPaidAmt;
              /*  v_dblFeeAmt:= round(v_dblPaidAmt*pv_dblAdvFee/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;*/
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - round( v_dblPaidAmt*rec13.intnmlacr/v_dblINTNMLACRTERM,4), INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);
          END LOOP;
        END IF;
    END IF;

    -- Phan bo phi d.vu Margin trong han
    --IF pv_blnAUTO = 'N' AND v_dblINTNMLACR > 0 THEN
    IF v_dblFEEINTNMLACR > 0 THEN
      IF v_strFTYPE ='AF' THEN
        FOR REC13 IN
            (SELECT AUTOID, round(FEEINTNMLACR,0) FEEINTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEINTNMLACR > 0 and AUTOID = pv_dblAUTOID ORDER BY OVERDUEDATE)
        LOOP

            IF v_dblFEEINTNMLACR > 0 THEN

                IF v_dblFEEINTNMLACR >= REC13.FEEINTNMLACR THEN
                    v_dblPaidAmt:= REC13.FEEINTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblFEEINTNMLACR;
                END IF;
                v_dblFEEINTNMLACR:= v_dblFEEINTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= round(v_dblPaidAmt*v_dblADVFEE/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET FEEINTNMLACR = FEEINTNMLACR - v_dblPaidAmt, FEEINTPAID = FEEINTPAID + v_dblPaidAmt--, FEEPAID2 = FEEPAID2 + v_dblFeeAmt
                WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, FEEINTNMLACR, FEE, FEEINTPAID, FEEPAID2)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, 0);


            END IF;
        END LOOP;
         ELSIF  v_strFTYPE ='DF' THEN -- hop dong DF
         FOR REC13 IN
            (SELECT AUTOID, round(FEEINTNMLACR,0) FEEINTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' ORDER BY OVERDUEDATE)
        LOOP
                    v_dblPaidAmt:= v_dblFEEINTNMLACR;

                v_dblFEEINTNMLACR:= v_dblFEEINTNMLACR - v_dblPaidAmt;
                /*v_dblFeeAmt:= round(v_dblPaidAmt*pv_dblAdvFee/100,0);
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;*/
                UPDATE LNSCHD SET FEEINTNMLACR = FEEINTNMLACR - round(v_dblPaidAmt*rec13.feeintnmlacr/v_dblFEEINTNMLACRTERM,4),
                       FEEINTPAID = FEEINTPAID + v_dblPaidAmt WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, FEEINTNMLACR, FEE, FEEINTPAID)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);

                END LOOP;
            END IF;
    END IF;

    -- Thu hoi T0 da giai ngan theo thu tu uu tien, cap truoc thu hoi truoc
    v_dblT0RETRIEVED := pv_dblT0PRINOVD + pv_dblT0PRINNML;

    select trfacctno into l_afacctno from lnmast where acctno = pv_strACCTNO;

    IF v_dblT0RETRIEVED > 0 THEN
        FOR REC_T0 IN
            (
                SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT
                FROM (select * from T0LIMITSCHD
                        union all
                     select * from T0LIMITSCHDHIST)
                WHERE ACCTNO = l_afacctno AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                ORDER BY AUTOID
            )
        LOOP
            IF v_dblT0RETRIEVED > 0 THEN
                IF v_dblT0RETRIEVED > REC_T0.AMT THEN
                    v_dblAmt := REC_T0.AMT;
                ELSE
                    v_dblAmt := v_dblT0RETRIEVED;
                END IF;
                v_dblT0RETRIEVED := v_dblT0RETRIEVED - v_dblAmt;

                UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + v_dblAmt WHERE AUTOID = REC_T0.AUTOID;
                UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + v_dblAmt WHERE AUTOID = REC_T0.AUTOID;

                UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - v_dblAmt
                WHERE ACCTNO = l_afacctno AND TLIDUSER = REC_T0.TLID AND typereceive = 'T0';

                INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
                VALUES (pv_strTXNUM,TO_DATE(pv_strTXDATE,'DD/MM/RRRR'),l_afacctno,-v_dblAmt,REC_T0.TLID,REC_T0.TYPEALLOCATE,'T0');

                INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                VALUES(TO_DATE(pv_strTXDATE,'DD/MM/RRRR'),pv_strTXNUM, REC_T0.AUTOID, REC_T0.TLID, v_dblAmt);
            END IF;
        END LOOP;
    END IF;


      IF v_dblACCRUALSAMT> 0 THEN

                UPDATE LNSCHD SET ACCRUALSAMT = ACCRUALSAMT - v_dblACCRUALSAMT WHERE AUTOID = pv_dblAUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, ACCRUALSAMT)
                VALUES(pv_dblAUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'),- v_dblACCRUALSAMT);

      END IF;

    --Kiem tra xem co phai lan tra cuoi cung khong
     SELECT nvl(sum(trunc(lns.nml)+trunc(lns.ovd)+trunc(lns.FEE)+trunc(lns.FEEOVD)+trunc(lns.FEEDUE)+trunc(lns.INTNMLACR)
            +trunc(lns.INTDUE)+trunc(lns.INTOVD)+trunc(lns.INTOVDPRIN)+trunc(lns.FEEINTNMLOVD)
            +trunc(lns.FEEINTOVDACR)+trunc(lns.FEEINTDUE)+trunc(lns.FEEINTNMLACR)),0)
     INTO v_REMAINLNAMT
     FROM lnschd lns
     WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' and autoid = pv_dblAUTOID;
     -- Neu la lan tra cuoi cung thi update vao LNSCHDLOG
     IF v_REMAINLNAMT <1 THEN
        UPDATE lnschdlog SET
            LASTPAID = 'Y'
        WHERE TXNUM = pv_strTXNUM AND txdate = TO_DATE(pv_strTXDATE,'DD/MM/RRRR');
     END IF;

    plog.debug (pkgctx, '<<END OF fn_Loanpaymentschd_by_autoid');
    plog.setendsection (pkgctx, 'fn_Loanpaymentschd_by_autoid');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_Loanpaymentschd_by_autoid');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_Loanpaymentschd_by_autoid;-- Procedure

/*
*   fn_Gen_Prepaid_Payment: pre gen payment scheduler
*   p_afacctno: So tieu khoan.
*   p_avlpaidamt: So tien dung de tra no.
*   p_type: N: Normal, tra no binh thuong (Tra no den han qua han); L: Liquid, tra mon no truoc han; R: ReNew, dao mon no.
*   p_err_code: Error code
*/
---------------------------------fn_Gen_Prepaid_Payment------------------------------------------------
FUNCTION fn_Gen_Prepaid_Payment(p_afacctno varchar2,
                                p_avlpaidamt number,
                                p_type varchar2,
                                p_duepaid varchar2,
                                p_err_code  OUT varchar2)
RETURN VARCHAR2
IS
l_remain_avlamt number;
l_exec_avlamt number;
l_remain_avlamt_group number;
l_exec_avlamt_group number;
l_paidrate number;
l_temp_value_rate number;
l_default_date date;
l_busdate date;
l_margin_outstanding number;
l_margin_asset number;
l_margin_odamt number;
BEGIN
plog.setendsection(pkgctx, 'fn_Gen_Prepaid_Payment');
p_err_code:=systemnums.C_SUCCESS;
l_remain_avlamt:=p_avlpaidamt;
l_exec_avlamt := 0;
l_remain_avlamt_group := 0;
l_exec_avlamt_group := 0;
l_paidrate := 0;
l_temp_value_rate := 0;
l_default_date:=to_date('01/01/1999','DD/MM/RRRR');
l_busdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');

insert into lnpaidallochist
select autoid, lnacctno, amt, paidamt, status, txdate, lnschdid from lnpaidalloc;

delete lnpaidalloc;
delete lnpaidallocodr;


-- Phan con lai phan bo theo overduedate, phan bo deu theo nguon.
FOR REC IN
(
    select ls.odr,ls.autoid,ln.acctno, case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end overduedate,
        sum(
                round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                        case when p_type = 'N' then 0
                             when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                             when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                            else 0 end
                    end,0) +
                round(case when ls.overduedate = l_busdate then nvl(induenml,0) else 0 end,0) +
                round(nvl(ls.ovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.intdue,0),0) +
                round(nvl(ls.intovd,0),0) +
                round(nvl(ls.intovdprin,0),0) +
                round(nvl(ls.fee,0),0) +
                round(nvl(ls.feedue,0),0) +
                round(nvl(ls.feeovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.feeintovdacr,0),0) +
                round(nvl(ls.feeintnmlovd,0),0) +
                round(nvl(ls.feeintdue,0),0) +
                round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0)
            ) totalamt
    from lnmast ln, vw_lnschd_odr ls
    where ln.acctno = ls.acctno
    and ln.ftype = 'AF'
    and instr(ls.reftype,'P') > 0
    and ln.status NOT IN ('R','C','P')
    and ln.trfacctno = p_afacctno
    and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
    --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
    and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0

    group by  ln.acctno, ls.autoid, ls.reftype,ls.odr,ls.overduedate,ls.rate2,ls.rate3,ls.paid,ls.intpaid,ls.total
    order by ls.odr,
            case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end,
            ls.rate2 desc ,ls.rate3 desc,
            case when ls.paid + ls.intpaid >0 then 0 else 1 end,
            ls.total,
            ls.autoid


/*    1, 6 thu t? tr? n? d?u?c.
2, C?hua check :
N?u nhi?u m??ng tr?ng th?th?u ti?
o   1. Ng?d?n h?n s?m hon
o   2.M?c l?su?t cao hon
o   3.S? ti?n gi?i ng?kh?Du n? g?c (d??? n? 1 ph?n)
o   4.T?ng du n? nh? hon*/
)
LOOP --- REC
    -- Theo OVERDUEDATE:
    l_exec_avlamt_group:=0;
    l_remain_avlamt_group:= least(l_remain_avlamt, greatest(REC.totalamt,0));
    l_exec_avlamt:=0;

    /*-- Lay ti le phan bo:
    begin
    select  sum(round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                        case when p_type = 'N' then 0
                             when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                             when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                            else 0 end
                    end,0) +
                round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
                round(nvl(ls.ovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.intdue,0),0) +
                round(nvl(ls.intovd,0),0) +
                round(nvl(ls.intovdprin,0),0) +
                round(nvl(ls.fee,0),0) +
                round(nvl(ls.feedue,0),0) +
                round(nvl(ls.feeovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.feeintovdacr,0),0) +
                round(nvl(ls.feeintnmlovd,0),0) +
                round(nvl(ls.feeintdue,0),0) +
                round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0))
           into l_temp_value_rate
    from lnmast ln, lnschd ls
    where ln.acctno = ls.acctno
    and ln.ftype = 'AF'
    and instr(ls.reftype,'P') > 0
    and ln.status NOT IN ('R','C','P')
    and ln.trfacctno = p_afacctno
    and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
    --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
    and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0

    and case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end = rec.overduedate;

    l_paidrate:= l_remain_avlamt_group / l_temp_value_rate;

    exception when others then
        l_paidrate:= 0;
    end;*/

    /*-- Tren tung dong lich tra no:
    for rec_item in
    (
        select ls.autoid, ls.acctno,
            (round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end
                    end,0) +
            round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
            round(nvl(ls.ovd,0),0) +
            round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
            round(nvl(ls.intdue,0),0) +
            round(nvl(ls.intovd,0),0) +
            round(nvl(ls.intovdprin,0),0) +
            round(nvl(ls.fee,0),0) +
            round(nvl(ls.feedue,0),0) +
            round(nvl(ls.feeovd,0),0) +
            round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
            round(nvl(ls.feeintovdacr,0),0) +
            round(nvl(ls.feeintnmlovd,0),0) +
            round(nvl(ls.feeintdue,0),0) +
            round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0)
            ) amt
        from lnmast ln, lnschd ls
        where ln.acctno = ls.acctno
        and ln.ftype = 'AF'
        and instr(ls.reftype,'P') > 0
        and ln.status NOT IN ('R','C','P')
        and ln.trfacctno = p_afacctno
        and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
        --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
        and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0
        and case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end = rec.overduedate
        order by ls.autoid
    )
    loop --rec_item

        l_exec_avlamt_group:= least(l_remain_avlamt_group, greatest(round(rec_item.amt * l_paidrate,0),0));
        if l_exec_avlamt_group > 0 then
            insert into lnpaidalloc (autoid, lnacctno, amt, paidamt, status, txdate, lnschdid)
            values (seq_lnpaidalloc.nextval, rec_item.acctno, l_exec_avlamt_group, 0,'P',l_busdate, rec_item.autoid);
        end if;

        l_exec_avlamt:= l_exec_avlamt + l_exec_avlamt_group;
        l_remain_avlamt_group:= l_remain_avlamt_group - l_exec_avlamt_group;
        exit when l_remain_avlamt_group <= 0;
    end loop; --rec_item*/

    l_exec_avlamt_group:= least(l_remain_avlamt_group, greatest(round(rec.totalamt,0),0));
    if l_exec_avlamt_group > 0 then
        --Tong hop theo tung dong lich va thu tu uu tien
        insert into lnpaidallocodr (autoid, lnacctno, amt, paidamt, status, txdate, lnschdid,odr)
        values (seq_lnpaidalloc.nextval, rec.acctno, l_exec_avlamt_group, 0,'P',l_busdate, rec.autoid,rec.odr );
    end if;

    l_exec_avlamt:= l_exec_avlamt + l_exec_avlamt_group;
    l_remain_avlamt_group:= l_remain_avlamt_group - l_exec_avlamt_group;
    --exit when l_remain_avlamt_group <= 0;

    l_remain_avlamt:= l_remain_avlamt - l_exec_avlamt;
    exit when l_remain_avlamt <= 0;
END LOOP; ---REC
--Tong hop theo tung dong lich
insert into lnpaidalloc (autoid, lnacctno, amt, paidamt, status, txdate, lnschdid)
select max(autoid) autoid, lnacctno, sum(amt) amt, 0, 'P', l_busdate, lnschdid
from lnpaidallocodr
group by  lnacctno,lnschdid;

p_err_code:=systemnums.C_SUCCESS;
plog.setendsection(pkgctx, 'fn_Gen_Prepaid_Payment');
return systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
THEN
  p_err_code := errnums.C_SYSTEM_ERROR;
  plog.error (pkgctx, dbms_utility.format_error_backtrace);
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_Gen_Prepaid_Payment');
  RAISE errnums.E_SYSTEM_ERROR;
  return errnums.C_SYSTEM_ERROR;
END fn_Gen_Prepaid_Payment;

/*
---------------------------------fn_Gen_Prepaid_Payment------------------------------------------------
FUNCTION fn_Gen_Prepaid_Payment(p_afacctno varchar2,
                                p_avlpaidamt number,
                                p_type varchar2,
                                p_duepaid varchar2,
                                p_err_code  OUT varchar2)
RETURN VARCHAR2
IS
l_remain_avlamt number;
l_exec_avlamt number;
l_remain_avlamt_group number;
l_exec_avlamt_group number;
l_paidrate number;
l_temp_value_rate number;
l_default_date date;
l_busdate date;
l_margin_outstanding number;
l_margin_asset number;
l_margin_odamt number;
BEGIN
plog.setendsection(pkgctx, 'fn_Gen_Prepaid_Payment');
p_err_code:=systemnums.C_SUCCESS;
l_remain_avlamt:=p_avlpaidamt;
l_exec_avlamt := 0;
l_remain_avlamt_group := 0;
l_exec_avlamt_group := 0;
l_paidrate := 0;
l_temp_value_rate := 0;
l_default_date:=to_date('01/01/1999','DD/MM/RRRR');
l_busdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');

insert into lnpaidallochist
select autoid, lnacctno, amt, paidamt, status, txdate, lnschdid from lnpaidalloc;

delete lnpaidalloc;


-- Phan con lai phan bo theo overduedate, phan bo deu theo nguon.
FOR REC IN
(
    select case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end overduedate,
        sum(
                round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                        case when p_type = 'N' then 0
                             when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                             when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                            else 0 end
                    end,0) +
                round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
                round(nvl(ls.ovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.intdue,0),0) +
                round(nvl(ls.intovd,0),0) +
                round(nvl(ls.intovdprin,0),0) +
                round(nvl(ls.fee,0),0) +
                round(nvl(ls.feedue,0),0) +
                round(nvl(ls.feeovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.feeintovdacr,0),0) +
                round(nvl(ls.feeintnmlovd,0),0) +
                round(nvl(ls.feeintdue,0),0) +
                round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0)
            ) totalamt
    from lnmast ln, lnschd ls
    where ln.acctno = ls.acctno
    and ln.ftype = 'AF'
    and instr(ls.reftype,'P') > 0
    and ln.status NOT IN ('R','C','P')
    and ln.trfacctno = p_afacctno
    and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
    --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
    and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0

    group by ls.reftype,ls.overduedate
    order by case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end
)
LOOP --- REC
    -- Theo OVERDUEDATE:
    l_exec_avlamt_group:=0;
    l_remain_avlamt_group:= least(l_remain_avlamt, greatest(REC.totalamt,0));
    l_exec_avlamt:=0;

    -- Lay ti le phan bo:
    begin
    select  sum(round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                        case when p_type = 'N' then 0
                             when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                             when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                            else 0 end
                    end,0) +
                round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
                round(nvl(ls.ovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.intdue,0),0) +
                round(nvl(ls.intovd,0),0) +
                round(nvl(ls.intovdprin,0),0) +
                round(nvl(ls.fee,0),0) +
                round(nvl(ls.feedue,0),0) +
                round(nvl(ls.feeovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.feeintovdacr,0),0) +
                round(nvl(ls.feeintnmlovd,0),0) +
                round(nvl(ls.feeintdue,0),0) +
                round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0))
           into l_temp_value_rate
    from lnmast ln, lnschd ls
    where ln.acctno = ls.acctno
    and ln.ftype = 'AF'
    and instr(ls.reftype,'P') > 0
    and ln.status NOT IN ('R','C','P')
    and ln.trfacctno = p_afacctno
    and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
    --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
    and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0

    and case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end = rec.overduedate;

    l_paidrate:= l_remain_avlamt_group / l_temp_value_rate;

    exception when others then
        l_paidrate:= 0;
    end;

    -- Tren tung dong lich tra no:
    for rec_item in
    (
        select ls.autoid, ls.acctno,
            (round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end
                    end,0) +
            round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
            round(nvl(ls.ovd,0),0) +
            round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
            round(nvl(ls.intdue,0),0) +
            round(nvl(ls.intovd,0),0) +
            round(nvl(ls.intovdprin,0),0) +
            round(nvl(ls.fee,0),0) +
            round(nvl(ls.feedue,0),0) +
            round(nvl(ls.feeovd,0),0) +
            round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
            round(nvl(ls.feeintovdacr,0),0) +
            round(nvl(ls.feeintnmlovd,0),0) +
            round(nvl(ls.feeintdue,0),0) +
            round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0)
            ) amt
        from lnmast ln, lnschd ls
        where ln.acctno = ls.acctno
        and ln.ftype = 'AF'
        and instr(ls.reftype,'P') > 0
        and ln.status NOT IN ('R','C','P')
        and ln.trfacctno = p_afacctno
        and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
        --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
        and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0
        and case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end = rec.overduedate
        order by ls.autoid
    )
    loop --rec_item

        l_exec_avlamt_group:= least(l_remain_avlamt_group, greatest(round(rec_item.amt * l_paidrate,0),0));
        if l_exec_avlamt_group > 0 then
            insert into lnpaidalloc (autoid, lnacctno, amt, paidamt, status, txdate, lnschdid)
            values (seq_lnpaidalloc.nextval, rec_item.acctno, l_exec_avlamt_group, 0,'P',l_busdate, rec_item.autoid);
        end if;

        l_exec_avlamt:= l_exec_avlamt + l_exec_avlamt_group;
        l_remain_avlamt_group:= l_remain_avlamt_group - l_exec_avlamt_group;
        exit when l_remain_avlamt_group <= 0;
    end loop; --rec_item

    l_remain_avlamt:= l_remain_avlamt - l_exec_avlamt;
    exit when l_remain_avlamt <= 0;
END LOOP; ---REC
p_err_code:=systemnums.C_SUCCESS;
plog.setendsection(pkgctx, 'fn_Gen_Prepaid_Payment');
return systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
THEN
  p_err_code := errnums.C_SYSTEM_ERROR;
  plog.error (pkgctx, dbms_utility.format_error_backtrace);
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_Gen_Prepaid_Payment');
  RAISE errnums.E_SYSTEM_ERROR;
  return errnums.C_SYSTEM_ERROR;
END fn_Gen_Prepaid_Payment;*/

---------------------------------fn_Gen_Prepaid_Payment_tmp------------------------------------------------
FUNCTION fn_Gen_Prepaid_Payment_tmp(p_afacctno varchar2,
                                p_avlpaidamt number,
                                p_type varchar2,
                                p_duepaid varchar2,
                                p_err_code  OUT varchar2)
RETURN VARCHAR2
IS
l_remain_avlamt number;
l_exec_avlamt number;
l_remain_avlamt_group number;
l_exec_avlamt_group number;
l_paidrate number;
l_temp_value_rate number;
l_default_date date;
l_busdate date;
l_margin_outstanding number;
l_margin_asset number;
l_margin_odamt number;
BEGIN
plog.setendsection(pkgctx, 'fn_Gen_Prepaid_Payment_tmp');
p_err_code:=systemnums.C_SUCCESS;
l_remain_avlamt:=p_avlpaidamt;
l_exec_avlamt := 0;
l_remain_avlamt_group := 0;
l_exec_avlamt_group := 0;
l_paidrate := 0;
l_temp_value_rate := 0;
l_default_date:=to_date('01/01/1999','DD/MM/RRRR');
l_busdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');

--delete lnpaidalloc_tmp;


-- Phan con lai phan bo theo overduedate, phan bo deu theo nguon.
FOR REC IN
(
    select case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end overduedate,
        sum(
                round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                        case when p_type = 'N' then 0
                             when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                             when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                            else 0 end
                    end,0) +
                round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
                round(nvl(ls.ovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.intdue,0),0) +
                round(nvl(ls.intovd,0),0) +
                round(nvl(ls.intovdprin,0),0) +
                round(nvl(ls.fee,0),0) +
                round(nvl(ls.feedue,0),0) +
                round(nvl(ls.feeovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.feeintovdacr,0),0) +
                round(nvl(ls.feeintnmlovd,0),0) +
                round(nvl(ls.feeintdue,0),0) +
                round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0)
            ) totalamt
    from lnmast ln, lnschd ls
    where ln.acctno = ls.acctno
    and ln.ftype = 'AF'
    and instr(ls.reftype,'P') > 0
    and ln.status NOT IN ('R','C','P')
    and ln.trfacctno = p_afacctno
    and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
    and not exists (select 1 from lnpaidalloc_dtl where lnschdid = ls.autoid)
    --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
    and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0

    group by ls.reftype,ls.overduedate
    order by case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end
)
LOOP --- REC
    -- Theo OVERDUEDATE:
    l_exec_avlamt_group:=0;
    l_remain_avlamt_group:= least(l_remain_avlamt, greatest(REC.totalamt,0));
    l_exec_avlamt:=0;

    -- Lay ti le phan bo:
    begin
    select  sum(round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                        case when p_type = 'N' then 0
                             when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                             when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                        then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                            else 0 end
                    end,0) +
                round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
                round(nvl(ls.ovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.intdue,0),0) +
                round(nvl(ls.intovd,0),0) +
                round(nvl(ls.intovdprin,0),0) +
                round(nvl(ls.fee,0),0) +
                round(nvl(ls.feedue,0),0) +
                round(nvl(ls.feeovd,0),0) +
                round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
                round(nvl(ls.feeintovdacr,0),0) +
                round(nvl(ls.feeintnmlovd,0),0) +
                round(nvl(ls.feeintdue,0),0) +
                round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0))
           into l_temp_value_rate
    from lnmast ln, lnschd ls
    where ln.acctno = ls.acctno
    and ln.ftype = 'AF'
    and instr(ls.reftype,'P') > 0
    and ln.status NOT IN ('R','C','P')
    and ln.trfacctno = p_afacctno
    and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
    and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
    and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0
    and case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end = rec.overduedate;

    l_paidrate:= l_remain_avlamt_group / l_temp_value_rate;

    exception when others then
        l_paidrate:= 0;
    end;

    -- Tren tung dong lich tra no:
    for rec_item in
    (
        select ls.autoid, ls.acctno,
            (round(case when ls.reftype = 'GP' then
                    nvl(ls.nml,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end
                    end,0) +
            round(case when ls.overduedate = l_busdate then nvl(nml,0) else 0 end,0) +
            round(nvl(ls.ovd,0),0) +
            round(case when ls.reftype = 'GP' then
                    nvl(ls.intnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.intnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.intnmlacr,0)
                        else 0 end
                    end,0) +
            round(nvl(ls.intdue,0),0) +
            round(nvl(ls.intovd,0),0) +
            round(nvl(ls.intovdprin,0),0) +
            round(nvl(ls.fee,0),0) +
            round(nvl(ls.feedue,0),0) +
            round(nvl(ls.feeovd,0),0) +
            round(case when ls.reftype = 'GP' then
                    nvl(ls.feeintnmlacr,0)
                    else
                    case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S')) then nvl(ls.feeintnmlacr,0)
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S') then nvl(ls.feeintnmlacr,0)
                        else 0 end
                    end,0) +
            round(nvl(ls.feeintovdacr,0),0) +
            round(nvl(ls.feeintnmlovd,0),0) +
            round(nvl(ls.feeintdue,0),0) +
            round(case when ls.reftype = 'GP' then
                    0
                    else
                    case when p_type in ('R','L') then
                        (case when p_type = 'N' then 0
                         when p_type = 'R' and ((ln.prepaid = 'Y' and ln.advpay = 'Y') or (ln.lntype = 'S'))
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                         when p_type = 'L' and (ln.prepaid = 'Y' or ln.lntype = 'S')
                                    then case when ls.overduedate > l_busdate then nvl(nml,0) else 0 end
                        else 0 end)
                        * ln.ADVPAYFEE/100 else 0 end --ADVPAYFEE
                    end,0)
            ) amt
        from lnmast ln, lnschd ls
        where ln.acctno = ls.acctno
        and ln.ftype = 'AF'
        and instr(ls.reftype,'P') > 0
        and ln.status NOT IN ('R','C','P')
        and ln.trfacctno = p_afacctno
        and ((ls.reftype = 'P'  and ls.overduedate > l_busdate and p_duepaid ='NML')
         or
        (not(ls.reftype = 'P'  and ls.overduedate > l_busdate) and p_duepaid ='OVD'))
        --and case when ln.rrtype = 'B' then to_number(l_busdate - getduedate(ls.rlsdate, ln.lncldr, '000', minterm)) else 1 end >= 0
        and case when ln.rrtype = 'B' then to_number(l_busdate - (case when ln.lncldr ='B' then fn_get_nextdate(ls.rlsdate, minterm) else ls.rlsdate + minterm end )) else 1 end >= 0
        and case when ls.reftype = 'GP' then nvl(overduedate,l_default_date) - 36500 else nvl(overduedate,l_default_date) end = rec.overduedate
        order by ls.autoid
    )
    loop --rec_item

        l_exec_avlamt_group:= least(l_remain_avlamt_group, greatest(round(rec_item.amt * l_paidrate,0),0));
        if l_exec_avlamt_group > 0 then
            insert into lnpaidalloc_tmp (autoid, lnacctno, amt, paidamt, status, txdate, lnschdid)
            values (seq_lnpaidalloc.nextval, rec_item.acctno, l_exec_avlamt_group, 0,'P',l_busdate, rec_item.autoid);
        end if;

        l_exec_avlamt:= l_exec_avlamt + l_exec_avlamt_group;
        l_remain_avlamt_group:= l_remain_avlamt_group - l_exec_avlamt_group;
        exit when l_remain_avlamt_group <= 0;
    end loop; --rec_item

    l_remain_avlamt:= l_remain_avlamt - l_exec_avlamt;
    exit when l_remain_avlamt <= 0;
END LOOP; ---REC
p_err_code:=systemnums.C_SUCCESS;
plog.setendsection(pkgctx, 'fn_Gen_Prepaid_Payment_tmp');
return systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
THEN
  p_err_code := errnums.C_SYSTEM_ERROR;
  plog.error (pkgctx, dbms_utility.format_error_backtrace);
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_Gen_Prepaid_Payment_tmp');
  RAISE errnums.E_SYSTEM_ERROR;
  return errnums.C_SYSTEM_ERROR;
END fn_Gen_Prepaid_Payment_tmp;

FUNCTION fn_getOVDD_From_New(p_currOverDueDate varchar2, p_newOverDueDate varchar2 )
RETURN NUMBER
IS
BEGIN
    RETURN TO_DATE(p_newOverDueDate, systemnums.C_DATE_FORMAT) -  TO_DATE(p_currOverDueDate, systemnums.C_DATE_FORMAT);
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END fn_getOVDD_From_New ;
FUNCTION fn_getSEASS(p_afacctno varchar2 )  RETURN NUMBER
IS
    l_seass NUMBER(20,0);
BEGIN
    SELECT ROUND(nvl(seass,0),0) INTO l_seass FROM v_getsecmarginratio_74 WHERE afacctno = p_afacctno;
    RETURN l_seass;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END fn_getSEASS;

FUNCTION fn_getMRRATE74(p_afacctno varchar2 )  RETURN NUMBER
IS
    l_marginrate74 NUMBER(20,0);
BEGIN
    SELECT ROUND(nvl(marginrate74,100),2) INTO l_marginrate74 FROM v_getsecmarginratio_74 WHERE afacctno = p_afacctno;
    RETURN l_marginrate74;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END fn_getMRRATE74;

FUNCTION FN_GETMRRATE(p_afacctno varchar2 )  RETURN NUMBER
IS
    l_marginrate74 NUMBER(20,2);
BEGIN
    SELECT ROUND(nvl(MARGINRATE,100),2) INTO l_marginrate74 FROM  V_GETSECMARGINRATIO WHERE afacctno = p_afacctno;
    RETURN l_marginrate74;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END FN_GETMRRATE;
-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_lnproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;

-- End of DDL Script for Package Body HOST.CSPKS_LNPROC
/
