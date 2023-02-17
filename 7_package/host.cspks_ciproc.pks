SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_ciproc
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


  FUNCTION fn_PaidAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
  FUNCTION fn_PaidDayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
  FUNCTION fn_DayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
  FUNCTION fn_GenRemittanceTrans(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
  PROCEDURE pr_CIAutoAdvance(p_txmsg in tx.msg_rectype,p_orderid varchar,p_advamt number,p_rcvamt number,p_err_code  OUT varchar2);
  PROCEDURE pr_DFAutoAdvance(p_groupid varchar,p_vndselldf number,p_err_code  OUT varchar2);
  FUNCTION fn_OrderAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
  PROCEDURE pr_ETSOrderAdvancePayment(p_txmsg in tx.msg_rectype,p_orderid varchar,p_amount number,p_err_code  OUT varchar2);
FUNCTION fn_cimastcidfpofeeacr(strACCTNO IN varchar2, strTXDATE IN DATE, dblAMT IN NUMBER)
  RETURN  number;
FUNCTION fn_cidatefeeacr(strACCTNO IN varchar2, strNumDATE IN  NUMBER)
  RETURN  number;
PROCEDURE pr_CRBTXREQ1104(p_refcode IN varchar,p_err_code  OUT varchar2);
PROCEDURE pr_CRBBANKREQ1141(p_AUTOID IN varchar,p_err_code  OUT varchar2);
PROCEDURE pr_CRBBANKREQ1196(p_AUTOID IN varchar,p_err_code  OUT varchar2);
--PROCEDURE pr_CALCI1110(p_err_code  OUT varchar2);
PROCEDURE pr_CALCI1192(p_err_code  OUT varchar2);
PROCEDURE pr_CalBackdateFeeAmt(p_backdate IN VARCHAR2, p_afacctno in varchar2, p_amt in number, p_err_code  OUT varchar2);

FUNCTION fn_cidatedepofeeacr(strCLOSETYPE in varchar2,strCUSTODYCD IN varchar2, strAFACCTNO in varchar2, strNumDATE IN  NUMBER)
  RETURN  number;

FUNCTION pr_IRCalcCreditInterest(pv_ACType In VARCHAR2, pv_AMT in Number, pv_RuleType Out VARCHAR2)
RETURN NUMBER;

FUNCTION fn_ApproveAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;

FUNCTION fn_DrowdownAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;

FUNCTION fn_RejectAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_FeeDepoMaturityBackdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;

FUNCTION fn_FeeDepoDebit(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
PROCEDURE PR_LOGSEDEPOBAL(STRCODEID in varchar2,STRAFACCTNO VARCHAR2, strNumDATE IN  NUMBER,V_AMT IN NUMBER,V_QTTY NUMBER,V_TBALDATE DATE,V_ID VARCHAR2);
PROCEDURE PR_ADVRESALLOC(V_STRAFACCTNO in varchar2,V_DBLAMT IN NUMBER,V_TXDATE DATE,V_TXNUM VARCHAR2);
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_ciproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------------pr_ETSOrderAdvancePayment------------------------------------------------
  PROCEDURE pr_ETSOrderAdvancePayment(p_txmsg in tx.msg_rectype,p_orderid varchar,p_amount number,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      v_overdfqtty number(20,0);
      v_dfqtty number(20,0);
      v_dfrlsqtty   number(20,0);
      v_totalpaidamt number(20,4);
      v_paidamt number(20,4);
      v_advamt number(20,4);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_ETSOrderAdvancePayment');

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    v_overdfqtty:=0;
    v_dfqtty:=0;
    for rec in
    (
        select b.txdate, b.orderid,c.autoid,a.afacctno, a.codeid,a.trade-nvl(vse.SECUREAMT,0) trading,
            c.qtty orderqtty,
            nvl(vdf.overdftrading,0) overdfqtty,
            nvl(vdf.dftrading,0)    dfqtty
        from semast a, odmast b, stschd c,
            v_getsellorderinfo vse,
            (
                select v.afacctno,v.codeid,
                sum(case when overamt>0 or (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T') then v.dftrading else 0 end) overdftrading,
                sum(case when overamt>0 or (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T') then 0 else v.dftrading end) dftrading  from
                (SELECT v.*, nvl(NML,0) DUEAMT,v.prinovd + v.oprinovd + nvl(NML,0) overamt
                FROM v_getdealinfo v,
                (SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
                        WHERE S.OVERDUEDATE <= TO_DATE((select varvalue from sysvar where grname ='SYSTEM' and varname ='CURRDATE'),'DD/MM/YYYY')
                            AND S.NML > 0 AND S.REFTYPE IN ('P')
                            AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C')
                        GROUP BY S.ACCTNO, M.TRFACCTNO
                        ORDER BY S.ACCTNO) sts
                where v.lnacctno = sts.acctno (+)
                ) v WHERE v.status='A'
                group by v.afacctno,v.codeid
            ) vdf
        where a.acctno = b.seacctno and b.orderid = c.orgorderid
        and b.via ='W'   --Lenh quan ETS
        --and a.acctno='0021085668000103'
        and c.duetype='RM' and c.status='N' and c.deltd<>'Y'
        and a.acctno = vse.seacctno(+)
        and a.afacctno = vdf.afacctno(+)
        and a.codeid= vdf.codeid(+)
        and b.orderid =p_orderid
    )
    loop
        if rec.txdate =v_strCURRDATE then
            v_overdfqtty:=least(rec.orderqtty,rec.overdfqtty);
            plog.debug (pkgctx,'v_overdfqtty ' || v_overdfqtty);
            v_dfqtty:=least(rec.orderqtty-v_overdfqtty,rec.dfqtty,-v_overdfqtty-rec.trading);
            plog.debug (pkgctx,'v_dfqtty ' || v_dfqtty);
            v_totalpaidamt:=0;
            --1.Tra no cho cac deal den va qua han
            if v_overdfqtty>0 then
                for rec1 in
                (
                    select v.*
                    FROM v_getdealinfo v,LNSCHD S, LNMAST M
                    where v.lnacctno = m.acctno and m.acctno = s.acctno and s.REFTYPE IN ('P')
                    and (S.OVERDUEDATE <= TO_DATE((select varvalue from sysvar where grname ='SYSTEM' and varname ='CURRDATE'),'DD/MM/YYYY')
                        or v.prinovd + v.oprinovd>0 or (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T'))
                    and v.afacctno =rec.afacctno and v.codeid = rec.codeid
                    order by (case when (v.basicprice<=v.triggerprice or v.FLAGTRIGGER='T')
                                    then (v.triggerprice-v.basicprice)/greatest(v.basicprice ,1)
                                    else 0 end
                             ) desc,S.OVERDUEDATE
                )
                loop
                    if v_overdfqtty> rec1.dftrading then
                        v_dfrlsqtty:=rec1.dftrading;
                    else
                        v_dfrlsqtty:=v_overdfqtty;
                    end if;
                    cspks_dfproc.pr_DealAutoPayment(p_txmsg,rec1.acctno,rec.autoid ,v_dfrlsqtty,1,v_paidamt ,p_err_code);
                    plog.debug (pkgctx,'v_paidamt ' || v_paidamt);
                    v_totalpaidamt:=v_totalpaidamt+v_paidamt;

                    v_overdfqtty:=v_overdfqtty-v_dfrlsqtty;
                    if p_err_code <> 0 then
                        return;
                    end if;
                    exit when v_overdfqtty<=0;
                end loop;
            end if;
            --2.Tra no cho cac deal trong han
            if v_dfqtty>0 then
                for rec1 in
                (
                    select v.*
                    FROM v_getdealinfo v,LNSCHD S, LNMAST M
                    where v.lnacctno = m.acctno and m.acctno = s.acctno and s.REFTYPE IN ('P')
                    and S.OVERDUEDATE > TO_DATE((select varvalue from sysvar where grname ='SYSTEM' and varname ='CURRDATE'),'DD/MM/YYYY')
                    and v.prinovd + v.oprinovd<=0
                    and v.afacctno =rec.afacctno and v.codeid = rec.codeid
                    order by S.OVERDUEDATE
                )
                loop
                    if v_dfqtty> rec1.dftrading then
                        v_dfrlsqtty:=rec1.dftrading;
                    else
                        v_dfrlsqtty:=v_dfqtty;
                    end if;
                    cspks_dfproc.pr_DealAutoPayment(p_txmsg ,rec1.acctno,rec.autoid ,v_dfrlsqtty,1,v_paidamt ,p_err_code);
                    plog.debug (pkgctx,'v_paidamt ' || v_paidamt);
                    v_totalpaidamt:=v_totalpaidamt+v_paidamt;
                    v_dfqtty:=v_dfqtty-v_dfrlsqtty;
                    if p_err_code <> 0 then
                        return;
                    end if;
                    exit when v_dfqtty<=0;
                end loop;
            end if;
            --3.Ung truoc tien ban bu cho cac deal
            if p_amount>0 then
                plog.debug (pkgctx,'Begin advance amount ' || p_amount);
                cspks_ciproc.pr_CIAutoAdvance(p_txmsg,rec.orderid,p_amount,v_advamt,p_err_code);
                if p_err_code <> 0 then
                    return;
                end if;
                plog.debug (pkgctx,'End advance amount ' || v_advamt);
            end if;
        else
            if p_amount>0 then
                plog.debug (pkgctx,'Begin advance amount ' || p_amount);
                cspks_ciproc.pr_CIAutoAdvance(p_txmsg,rec.orderid,p_amount,v_advamt,p_err_code);
                if p_err_code <> 0 then
                    return;
                end if;
                plog.debug (pkgctx,'End advance amount ' || v_advamt);
            end if;
        end if;

    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_ETSOrderAdvancePayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_ETSOrderAdvancePayment');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ETSOrderAdvancePayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ETSOrderAdvancePayment;

 ---------------------------------fn_PaidAdvancedPayment------------------------------------------------
FUNCTION fn_PaidAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_PaidAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_PaidAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    if not v_blnREVERSAL then
        --CHieu lam thuan giao dich
        SELECT COUNT(*) INTO v_count FROM STSCHD WHERE AUTOID=p_txmsg.txfields('09').value;
        if v_count <=0 then
            plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_OD_STSCHD_NOTFOUND);
            p_err_code :=errnums.C_OD_STSCHD_NOTFOUND;
            return l_lngErrCode;
        else
            UPDATE STSCHD SET PAIDAMT=round(PAIDAMT + p_txmsg.txfields('10').value,0),
                            PAIDFEEAMT=round(PAIDFEEAMT + p_txmsg.txfields('11').value,0)
            WHERE AUTOID=p_txmsg.txfields('09').value;
        end if;
    else
        UPDATE STSCHD SET PAIDAMT=round(PAIDAMT - ( p_txmsg.txfields('10').value),0),
                        PAIDFEEAMT=round(PAIDFEEAMT -( p_txmsg.txfields('11').value),0)
        WHERE AUTOID=p_txmsg.txfields('09').value;
    end if;
    plog.debug (pkgctx, '<<END OF fn_PaidAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_PaidAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_PaidAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_PaidAdvancedPayment;



 ---------------------------------fn_GenRemittanceTrans------------------------------------------------
FUNCTION fn_GenRemittanceTrans(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_dblFEEAMT number(20,4);
v_dblTRFAMT number(20,4);
v_strREFAUTOID  number;
v_strBANKCODE varchar2(100);
v_strAccountName varchar2(200);
v_istcdt varchar2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_GenRemittanceTrans');
    plog.debug (pkgctx, '<<BEGIN OF fn_GenRemittanceTrans');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;

    if not v_blnREVERSAL then
        --CHieu lam thuan giao dich
/*        if p_txmsg.tltxcd in ('1108') THEN
            v_dblFEEAMT:=p_txmsg.txfields('11').value+p_txmsg.txfields('12').value;
            INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BANKID, BENEFBANK, BENEFACCT, BENEFCUSTNAME, BENEFLICENSE, AMT, FEEAMT, DELTD, BENEFIDDATE, BENEFIDPLACE,FEETYPE,CITYEF, CITYBANK)
              VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('03').value,
              p_txmsg.txfields('05').value,p_txmsg.txfields('80').value,p_txmsg.txfields('81').value,
              p_txmsg.txfields('82').value,p_txmsg.txfields('83').value,
              p_txmsg.txfields('10').value,p_txmsg.txfields('11').value, 'N',
              --TO_DATE(p_txmsg.txfields('95').value,systemnums.c_date_format),p_txmsg.txfields('96').value,to_char(p_txmsg.txfields('09').value),
              TO_DATE(p_txmsg.txfields('97').value,systemnums.c_date_format),p_txmsg.txfields('96').value,to_char(p_txmsg.txfields('09').value),
              to_char(p_txmsg.txfields('85').value),to_char(p_txmsg.txfields('84').value));
        ELS*/
        IF p_txmsg.tltxcd in ('1133') THEN
            --v_dblFEEAMT:=p_txmsg.txfields('11').value+p_txmsg.txfields('12').value;
            --81  1133    BENEFBANK
            --84  1133    CITYBANK
            v_dblFEEAMT:=0;
            INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BANKID, BENEFBANK, BENEFACCT, BENEFCUSTNAME, BENEFLICENSE, AMT, FEEAMT, DELTD, BENEFIDDATE, BENEFIDPLACE,FEETYPE,CITYEF, CITYBANK,DESCRIPTION)
                VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('03').value,
                p_txmsg.txfields('05').value,p_txmsg.txfields('81').value,'',
                replace(p_txmsg.txfields('82').value,'''''',''''),p_txmsg.txfields('83').value,
                p_txmsg.txfields('10').value,0, 'N',
                TO_DATE(p_txmsg.txfields('95').value,systemnums.c_date_format),p_txmsg.txfields('96').value,'0',
                to_char(p_txmsg.txfields('85').value),to_char(p_txmsg.txfields('84').value),p_txmsg.txfields('30').value);
        elsiF p_txmsg.tltxcd in ('1113') THEN

            v_dblFEEAMT:=p_txmsg.txfields('11').value+p_txmsg.txfields('12').value;

            INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BANKID, BENEFBANK, BENEFACCT, BENEFCUSTNAME, BENEFLICENSE, AMT, FEEAMT, DELTD, BENEFIDDATE, BENEFIDPLACE,FEETYPE,CITYEF, CITYBANK,VAT,DESCRIPTION)
                VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('03').value,
                p_txmsg.txfields('05').value,p_txmsg.txfields('81').value,'',
                replace(p_txmsg.txfields('82').value,'''''',''''),p_txmsg.txfields('83').value,
                p_txmsg.txfields('10').value,p_txmsg.txfields('11').value, 'N',
                TO_DATE(p_txmsg.txfields('95').value,systemnums.c_date_format),p_txmsg.txfields('96').value,to_char(p_txmsg.txfields('09').value),
                to_char(p_txmsg.txfields('85').value),to_char(p_txmsg.txfields('84').value),p_txmsg.txfields('12').value,p_txmsg.txfields('30').value);

        ELSIF p_txmsg.tltxcd in ('1120','1134') THEN -- GD CHUYEN KHOAN NOI BO, TRANG THAI = C
            INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BANKID, BENEFBANK, BENEFACCT, BENEFCUSTNAME, BENEFLICENSE,
                                        AMT, FEEAMT, DELTD, BENEFIDDATE, BENEFIDPLACE,FEETYPE,CITYEF, CITYBANK,RMSTATUS,DESCRIPTION)
               VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('03').value,
               p_txmsg.txfields('03').value,p_txmsg.txfields('89').value,p_txmsg.txfields('05').value,
               replace(p_txmsg.txfields('93').value,'''''',''''),p_txmsg.txfields('95').value,
               p_txmsg.txfields('10').value,0, 'N',
               TO_DATE(p_txmsg.txfields('98').value,systemnums.c_date_format),p_txmsg.txfields('99').value,'0','','','C',p_txmsg.txfields('30').value);
        elsif p_txmsg.tltxcd in ('1135') THEN

            INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BENEFBANK, BENEFACCT, BENEFCUSTNAME,  AMT, FEEAMT, DELTD, CITYEF, CITYBANK,FEETYPE,VAT,DESCRIPTION)
                      VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('01').value,
                      p_txmsg.txfields('80').value,p_txmsg.txfields('81').value,
                      replace(p_txmsg.txfields('82').value,'''''',''''),
                      p_txmsg.txfields('10').value,p_txmsg.txfields('11').value, 'N',
                      to_char(p_txmsg.txfields('85').value),to_char(p_txmsg.txfields('84').value),to_char(p_txmsg.txfields('09').value),p_txmsg.txfields('12').value,p_txmsg.txfields('30').value);
        ELSE

            v_dblFEEAMT:=p_txmsg.txfields('11').value+p_txmsg.txfields('12').value;
            if (p_txmsg.tltxcd in ('1106')) then
                INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BANKID, BENEFBANK, BENEFACCT, BENEFCUSTNAME, BENEFLICENSE, AMT, FEEAMT, DELTD, BENEFIDDATE, BENEFIDPLACE,FEETYPE,CITYEF, CITYBANK,VAT,DESCRIPTION,DIVIDENDVAT)
                      VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('03').value,
                      p_txmsg.txfields('05').value,p_txmsg.txfields('80').value,p_txmsg.txfields('81').value,
                      replace(p_txmsg.txfields('82').value,'''''',''''),p_txmsg.txfields('83').value,
                      p_txmsg.txfields('25').value,p_txmsg.txfields('11').value, 'N',
                      TO_DATE(p_txmsg.txfields('95').value,systemnums.c_date_format),p_txmsg.txfields('96').value,to_char(p_txmsg.txfields('09').value),
                      to_char(p_txmsg.txfields('85').value),to_char(p_txmsg.txfields('84').value),p_txmsg.txfields('12').value,p_txmsg.txfields('30').value,p_txmsg.txfields('22').value);
            else
                INSERT INTO CIREMITTANCE (TXDATE, TXNUM, ACCTNO,BANKID, BENEFBANK, BENEFACCT, BENEFCUSTNAME, BENEFLICENSE, AMT, FEEAMT, DELTD, BENEFIDDATE, BENEFIDPLACE,FEETYPE,CITYEF, CITYBANK,VAT,DESCRIPTION)
                      VALUES (TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum,p_txmsg.txfields('03').value,
                      p_txmsg.txfields('05').value,p_txmsg.txfields('80').value,p_txmsg.txfields('81').value,
                      replace(p_txmsg.txfields('82').value,'''''',''''),p_txmsg.txfields('83').value,
                      p_txmsg.txfields('10').value,p_txmsg.txfields('11').value, 'N',
                      TO_DATE(p_txmsg.txfields('95').value,systemnums.c_date_format),p_txmsg.txfields('96').value,to_char(p_txmsg.txfields('09').value),
                      to_char(p_txmsg.txfields('85').value),to_char(p_txmsg.txfields('84').value),p_txmsg.txfields('12').value,p_txmsg.txfields('30').value);
            end if;
            --Kiem tra neu Bankid ton tai trong bang CRBBANKTRFLIST thi gen
            if not p_txmsg.txfields('05').value is null then
                for rec in (
                    select * from crbbanklist where (case when BANKCODE='NULL' then BANKNAME else BANKCODE END) = p_txmsg.txfields('05').value
                )
                loop
                    select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                    if p_txmsg.tltxcd in ('1101','1111','1154') then
                        v_dblTRFAMT:= TO_NUMBER(p_txmsg.txfields('13').value) - TO_NUMBER(p_txmsg.txfields('11').value) - TO_NUMBER(p_txmsg.txfields('12').value);
                    ELSIF p_txmsg.tltxcd in ('1106') then
                        v_dblTRFAMT:= TO_NUMBER(p_txmsg.txfields('13').value) - TO_NUMBER(p_txmsg.txfields('22').value) - TO_NUMBER(p_txmsg.txfields('11').value) - TO_NUMBER(p_txmsg.txfields('12').value) ;
                    else
                        v_dblTRFAMT:= TO_NUMBER(p_txmsg.txfields('13').value);
                    end if;

                    /*if substr(p_txmsg.txfields('03').value,1,4) ='0101' then
                        v_strBANKCODE:='TCDTHCM';
                    elsif substr(p_txmsg.txfields('03').value,1,4) ='0001'   then
                        v_strBANKCODE:='TCDTHN';
                    else
                        v_strBANKCODE:='TCDT';
                    end if;*/

                    v_strBANKCODE:='BMSC';
                    Select UPPER(fn_convert_to_vn(p_txmsg.txfields('82').value)) into v_strAccountName from dual;

         SELECT VARVALUE INTO v_istcdt FROM  SYSVAR WHERE VARNAME ='ISTCDT';
          IF v_istcdt ='Y' THEN

                    INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES, VIA,DIRBANKCODE,DIRBANKNAME,DIRBANKCITY,DIRACCNAME)
                       VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, 'TCDT', to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(p_txmsg.txdate , 'dd/mm/rrrr'),
                               p_txmsg.txfields('03').value , v_dblTRFAMT , v_strBANKCODE,p_txmsg.txfields('81').value, 'P', NULL,p_txmsg.txfields('30').value,'DIR',p_txmsg.txfields('05').value,
                               p_txmsg.txfields('80').value,p_txmsg.txfields('85').value,v_strAccountName);

                    INSERT INTO VCBSEQMAP(VCBSEQ, REQID, TXDATE)
                        VALUES(SEQ_VCBSEQ.NEXTVAL, v_strREFAUTOID, TO_DATE(p_txmsg.txdate , 'dd/mm/rrrr'));
           END IF;
                    EXIT;
                end loop;
            end if;
        END IF;
    else
        SELECT count(1) into v_count FROM CIREMITTANCE WHERE TXDATE=TO_DATE(p_txmsg.txdate,systemnums.c_date_format) AND TXNUM=p_txmsg.txnum AND RMSTATUS not in ('C','R') and deltd <> 'Y';
        if not v_count>0 then
            plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_CI_REMITTANCE_CLOSE);
            p_err_code :=errnums.C_CI_REMITTANCE_CLOSE;
            return l_lngErrCode;
        else
            UPDATE CIREMITTANCE SET DELTD='Y' WHERE TXDATE=TO_DATE(p_txmsg.txdate,systemnums.c_date_format) AND TXNUM=p_txmsg.txnum;
            UPDATE CRBTXREQ SET STATUS = 'R', ERRORDESC = 'Xoa giao dich'  WHERE TXDATE=TO_DATE(p_txmsg.txdate,systemnums.c_date_format) AND objkey=p_txmsg.txnum;
        end if;
    end if;
    plog.debug (pkgctx, '<<END OF fn_GenRemittanceTrans');
    plog.setendsection (pkgctx, 'fn_GenRemittanceTrans');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_GenRemittanceTrans');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_GenRemittanceTrans;

/*---------------------------------fn_PaidDayAdvancedPayment------------------------------------------------
FUNCTION fn_PaidDayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_strSTSDATE varchar2(20);
v_dblStsID number(20,4);
v_dblSTSAMT number(20,4);
v_dbltSTSFAMT number(20,4);
v_dblAMT    number(20,4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_PaidDayAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_PaidDayAdvancedPayment');

    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_dblAMT:=round(p_txmsg.txfields('10').value,0);
    begin
        SELECT TO_CHAR(CLEARDT,'DD/MM/YYYY') TXDATE
        into v_strSTSDATE
        FROM ADSCHD WHERE AUTOID=p_txmsg.txfields('09').value;
    exception when others then
        plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_OD_STSCHD_NOTFOUND);
        p_err_code :=errnums.C_OD_STSCHD_NOTFOUND;
        return l_lngErrCode;
    end;
    if not v_blnREVERSAL then
        UPDATE ADSCHD
            SET PAIDAMT=round(PAIDAMT+v_dblAMT + p_txmsg.txfields('11').value,0),
            STATUS='C' WHERE AUTOID=p_txmsg.txfields('09').value;
        for rec in
        (
            SELECT AUTOID,STS.AFACCTNO,STS.AAMT-STS.PAIDAMT AMT,STS.FAMT-STS.PAIDFEEAMT FAMT
                 FROM STSCHD STS,ODMAST OD,SBSECURITIES SB
                 WHERE OD.CODEID=SB.CODEID AND STS.ORGORDERID=OD.ORDERID
                 AND STS.DELTD <> 'Y' AND STS.STATUS='C' AND STS.DUETYPE='RM'
                 --AND (CASE WHEN OD.EXECTYPE='MS' THEN 1 ELSE 0 END)=p_txmsg.txfields('60').value
                 AND STS.AFACCTNO=p_txmsg.txfields('03').value
                 AND GETDUEDATE(STS.TXDATE,STS.CLEARCD,SB.TRADEPLACE,STS.CLEARDAY) =TO_DATE(v_strSTSDATE,systemnums.c_date_format)
                 ORDER BY STS.AMT DESC
        )
        loop
            v_dblStsID := rec.AUTOID;
            v_dblSTSAMT := round(rec.AMT,0);
            v_dbltSTSFAMT := round(rec.FAMT,0);
            If v_dblSTSAMT > v_dblAMT Then
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT+  v_dblAMT,0) ,
                                  PAIDFEEAMT=round(FAMT*(PAIDAMT+  v_dblAMT )/AAMT)
                WHERE AUTOID=v_dblStsID;
                v_dblAMT := 0;
            else
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT+ v_dblSTSAMT,0) ,PAIDFEEAMT=FAMT
                WHERE AUTOID=v_dblStsID;
                v_dblAMT:=v_dblAMT-v_dblSTSAMT;
            end if;
            EXIT WHEN v_dblAMT <= 0;
        end loop;
    else
        UPDATE ADSCHD SET PAIDAMT=round(PAIDAMT-v_dblAMT - p_txmsg.txfields('11').value,0),
            STATUS='N'
        WHERE AUTOID=p_txmsg.txfields('09').value;
        for rec in
        (
            SELECT AUTOID,STS.AFACCTNO,STS.PAIDAMT AMT,PAIDFEEAMT FAMT
                  FROM STSCHD STS,ODMAST OD,SBSECURITIES SB
                  WHERE SB.CODEID=OD.CODEID AND STS.ORGORDERID=OD.ORDERID
                  AND STS.DELTD <> 'Y' AND STS.STATUS='C' AND STS.DUETYPE='RM'
                  --AND (CASE WHEN OD.EXECTYPE='MS' THEN 1 ELSE 0 END)=p_txmsg.txfields('60').value
                  AND STS.AFACCTNO=p_txmsg.txfields('03').value
                  AND GETDUEDATE(STS.TXDATE,STS.CLEARCD,SB.TRADEPLACE,STS.CLEARDAY) =TO_DATE(v_strSTSDATE,systemnums.c_date_format)
        )
        loop
            v_dblStsID := rec.AUTOID;
            v_dblSTSAMT := round(rec.AMT,0);
            v_dbltSTSFAMT := round(rec.FAMT,0);
            If v_dblSTSAMT > v_dblAMT Then
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT- v_dblAMT,0) ,
                                PAIDFEEAMT=round(FAMT*(PAIDAMT-  v_dblAMT )/AAMT,0)
                                WHERE AUTOID=v_dblStsID;
                v_dblAMT := 0;
            Else
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT-  v_dblSTSAMT,0) ,PAIDFEEAMT=FAMT  WHERE AUTOID=v_dblStsID;
                v_dblAMT := v_dblAMT - v_dblSTSAMT;
            End If;
            EXIT WHEN v_dblAMT <= 0;
        end loop;
    end if;
    plog.debug (pkgctx, '<<END OF fn_PaidDayAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_PaidDayAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_PaidDayAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_PaidDayAdvancedPayment;*/

---------------------------------fn_PaidDayAdvancedPayment------------------------------------------------
FUNCTION fn_PaidDayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_strSTSDATE varchar2(20);
v_dblStsID number(20,4);
v_dblSTSAMT number(20,4);
v_dbltSTSFAMT number(20,4);
v_dblAMT    number(20,4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_PaidDayAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_PaidDayAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_dblAMT:=round(p_txmsg.txfields('10').value,0) + round(p_txmsg.txfields('11').value,0);
    begin
        SELECT TO_CHAR(CLEARDT,'DD/MM/YYYY') TXDATE
        into v_strSTSDATE
        FROM ADSCHD WHERE AUTOID=p_txmsg.txfields('09').value;
    exception when others then
        plog.error(pkgctx,'l_lngErrCode: ' || errnums.C_OD_STSCHD_NOTFOUND);
        p_err_code :=errnums.C_OD_STSCHD_NOTFOUND;
        return l_lngErrCode;
    end;
    if not v_blnREVERSAL then
        UPDATE ADSCHD
            SET PAIDAMT=round(PAIDAMT+v_dblAMT,0), STATUS='C', PAIDDATE=TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)
        WHERE AUTOID=p_txmsg.txfields('09').value;
        for rec in
        (
            SELECT AUTOID,STS.AFACCTNO,STS.AAMT-STS.PAIDAMT AMT,STS.FAMT-STS.PAIDFEEAMT FAMT
                 FROM STSCHD STS,ODMAST OD,SBSECURITIES SB
                 WHERE OD.CODEID=SB.CODEID AND STS.ORGORDERID=OD.ORDERID
                 AND STS.DELTD <> 'Y' AND STS.STATUS='C' AND STS.DUETYPE='RM'
                 --AND (CASE WHEN OD.EXECTYPE='MS' THEN 1 ELSE 0 END)=p_txmsg.txfields('60').value
                 AND STS.AFACCTNO=p_txmsg.txfields('03').value
                 AND GETDUEDATE(STS.TXDATE,STS.CLEARCD,SB.TRADEPLACE,STS.CLEARDAY) =TO_DATE(v_strSTSDATE,systemnums.c_date_format)
                 ORDER BY STS.AMT DESC
        )
        loop
            v_dblStsID := rec.AUTOID;
            v_dblSTSAMT := round(rec.AMT,0);
            If v_dblSTSAMT > v_dblAMT Then
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT+  v_dblAMT,0)
                WHERE AUTOID=v_dblStsID;
                v_dblAMT := 0;
            else
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT+ v_dblSTSAMT,0)
                WHERE AUTOID=v_dblStsID;
                v_dblAMT:=v_dblAMT-v_dblSTSAMT;
            end if;
            EXIT WHEN v_dblAMT <= 0;
        end loop;
    else
        UPDATE ADSCHD SET PAIDAMT=round(PAIDAMT-v_dblAMT,0), STATUS='N', PAIDDATE= ''
        WHERE AUTOID=p_txmsg.txfields('09').value;
        for rec in
        (
            SELECT AUTOID,STS.AFACCTNO,STS.PAIDAMT AMT,PAIDFEEAMT FAMT
                  FROM STSCHD STS,ODMAST OD,SBSECURITIES SB
                  WHERE SB.CODEID=OD.CODEID AND STS.ORGORDERID=OD.ORDERID
                  AND STS.DELTD <> 'Y' AND STS.STATUS='C' AND STS.DUETYPE='RM'
                  --AND (CASE WHEN OD.EXECTYPE='MS' THEN 1 ELSE 0 END)=p_txmsg.txfields('60').value
                  AND STS.AFACCTNO=p_txmsg.txfields('03').value
                  AND GETDUEDATE(STS.TXDATE,STS.CLEARCD,SB.TRADEPLACE,STS.CLEARDAY) =TO_DATE(v_strSTSDATE,systemnums.c_date_format)
        )
        loop
            v_dblStsID := rec.AUTOID;
            v_dblSTSAMT := round(rec.AMT,0);
            If v_dblSTSAMT > v_dblAMT Then
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT- v_dblAMT,0)
                                WHERE AUTOID=v_dblStsID;
                v_dblAMT := 0;
            Else
                UPDATE STSCHD SET PAIDAMT=round(PAIDAMT-  v_dblSTSAMT,0)  WHERE AUTOID=v_dblStsID;
                v_dblAMT := v_dblAMT - v_dblSTSAMT;
            End If;
            EXIT WHEN v_dblAMT <= 0;
        end loop;
    end if;
    plog.debug (pkgctx, '<<END OF fn_PaidDayAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_PaidDayAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_PaidDayAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_PaidDayAdvancedPayment;

/*---------------------------------fn_DayAdvancedPayment------------------------------------------------
FUNCTION fn_DayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_dblMaxAdvanceAmount   number(20,4);
v_dblADAMT  number(20,4);
v_dblADFAMT  number(20,4);
v_dblADFeeRate number;
v_dblStsID  number(20,4);
v_dblSTSEXAMT number(20,4);
v_dblSTSAMT number(20,4);
v_dblSTSFAMT   number(20,4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_DayAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_DayAdvancedPayment');
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_dblADAMT:=round(p_txmsg.txfields('10').value,0);
    v_dblADFAMT:=round(p_txmsg.txfields('11').value + p_txmsg.txfields('14').value,0);
    v_dblADFeeRate:=v_dblADFAMT/v_dblADAMT;

    if not v_blnREVERSAL then
        insert into adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                       amt, feeamt, vatamt, bankfee, paidamt)
                SELECT seq_adschd.nextval autoid,0,--p_txmsg.txfields('60').value ismortage,
                        p_txmsg.txfields('03').value acctno,to_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                        p_txmsg.txnum txnum, '' refadno,to_date(p_txmsg.txfields('08').value,systemnums.c_date_format) cleardt,
                       p_txmsg.txfields('10').value amt,p_txmsg.txfields('11').value feeamt,0 vatamt,
                       p_txmsg.txfields('14').value bankfee,0 paidamt
                  FROM dual;

        for rec in
            (SELECT AUTOID,STS.AMT EXECAMT,
                STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT AMT,
                STS.FAMT FAMT
                FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC
                WHERE STS.CODEID=SEC.CODEID AND STS.ORGORDERID=OD.ORDERID AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                --AND (CASE WHEN OD.EXECTYPE='MS' THEN 1 ELSE 0 END)=p_txmsg.txfields('60').value
                AND STS.AFACCTNO=p_txmsg.txfields('03').value
                --AND ( OD.VIA <> 'W' or OD.txdate < p_txmsg.txdate)
                --AND GETDUEDATE(STS.TXDATE,STS.CLEARCD,SEC.TRADEPLACE,STS.CLEARDAY)=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                AND sts.cleardate=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                ORDER BY amt desc--(CASE WHEN OD.VIA='W' THEN 1 ELSE 0 END)
            )
        loop
            v_dblStsID:=rec.AUTOID;
            v_dblSTSEXAMT:=round(rec.EXECAMT,0);
            v_dblSTSAMT:=round(rec.AMT,0);
            v_dblSTSFAMT:=round(rec.FAMT,0);
            If v_dblSTSAMT > v_dblADAMT * (1 + v_dblADFeeRate) Then
                UPDATE STSCHD
                    SET AAMT=AAMT+ v_dblADAMT ,
                        FAMT=FAMT + ROUND( (p_txmsg.txfields('14').value + p_txmsg.txfields('11').value) * v_dblADAMT / p_txmsg.txfields('10').value ,0)
                        WHERE AUTOID= v_dblStsID;
                v_dblADAMT:=0;
            else
                UPDATE STSCHD
                    SET AAMT=AAMT+  round(v_dblSTSAMT / (1 + v_dblADFeeRate),0) ,
                        FAMT=FAMT + ROUND( v_dblSTSAMT / (1 + v_dblADFeeRate) * v_dblADFeeRate ,0)
                        WHERE AUTOID= v_dblStsID;
                v_dblADAMT:=round(v_dblADAMT-v_dblSTSAMT / (1 + v_dblADFeeRate),0);
            end if;
            exit when v_dblADAMT <= 0;
        end loop;
        --Neu con du tien khong phan bo het thi bao loi vuot qua so tien ung truoc
        if v_dblADAMT>2 then
             p_err_code := '-400101'; --Ung qua so tien duoc phep
             RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

    else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        p_err_code:=0;
    end if;
    plog.debug (pkgctx, '<<END OF fn_DayAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_DayAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_DayAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_DayAdvancedPayment;*/

/*---------------------------------fn_DayAdvancedPayment------------------------------------------------
FUNCTION fn_DayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL           boolean;
l_lngErrCode            number(20,0);
v_count                 number(20,0);
v_dblMaxAdvanceAmount   number(20,4);
v_dblADAMT              number(20,4);
v_dblADFAMT             number(20,4);
v_dblStsID              number(20,4);
v_dblSTSEXAMT           number(20,4);
v_dblSTSAMT             number(20,4);
v_dblSTSFAMT            number(20,4);
l_RRTYPE                VARCHAR2(1);
l_CIACCTNO              VARCHAR2(10);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_DayAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_DayAdvancedPayment');
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_dblADAMT:=round(p_txmsg.txfields('10').value,0) + round(p_txmsg.txfields('11').value + p_txmsg.txfields('14').value,0);

    plog.debug (pkgctx, 'reftxnum:' || p_txmsg.txfields('99').value);

    if not v_blnREVERSAL then

        for rec in
               (SELECT AUTOID,STS.AMT EXECAMT, OD.AFACCTNO, STS.cleardate, od.orderid,
                   STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT AMT,
                   STS.FAMT FAMT
                   FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC
                   WHERE STS.CODEID=SEC.CODEID AND STS.ORGORDERID=OD.ORDERID AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                   AND STS.AFACCTNO=p_txmsg.txfields('03').value
                   AND sts.cleardate=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                   AND sts.txdate=TO_DATE(p_txmsg.txfields('42').value,systemnums.c_date_format)
                   ORDER BY amt desc
               )
         loop
             v_dblStsID := rec.AUTOID;
             v_dblSTSEXAMT := round(rec.EXECAMT,0);
             v_dblSTSAMT := round(rec.AMT,0);
             If v_dblSTSAMT > v_dblADAMT Then
                -- Log thong tin lenh ung
                INSERT INTO adschddtl(autoid, acctno, txdate, txnum, cleardate, orderid, aamt, feeamt, vatamt, DELTD, STATUS)
                VALUES (SEQ_ADSCHDDTL.NEXTVAL , rec.AFACCTNO, TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, rec.cleardate, rec.orderid, v_dblADAMT, 0, 0, p_txmsg.deltd, 'A');

                UPDATE STSCHD
                     SET AAMT = AAMT + v_dblADAMT
                         WHERE AUTOID = v_dblStsID;
                v_dblADAMT := 0;
             else
                -- Log thong tin lenh ung
                INSERT INTO adschddtl(autoid, acctno, txdate, txnum, cleardate, orderid, aamt, feeamt, vatamt, DELTD, STATUS)
                VALUES (SEQ_ADSCHDDTL.NEXTVAL , rec.AFACCTNO, TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, rec.cleardate, rec.orderid, v_dblADAMT, 0, 0, p_txmsg.deltd, 'A');

                UPDATE STSCHD
                     SET AAMT=AAMT + v_dblSTSAMT
                         WHERE AUTOID= v_dblStsID;
                v_dblADAMT:=v_dblADAMT-v_dblSTSAMT;
             end if;
             exit when v_dblADAMT <= 0;
         end loop;
         --Neu con du tien khong phan bo het thi bao loi vuot qua so tien ung truoc
         if v_dblADAMT>2 then
              p_err_code := '-400101'; --Ung qua so tien duoc phep
              RETURN errnums.C_BIZ_RULE_INVALID;
         end if;

        -- TH Tu dong GN
        If to_char(p_txmsg.txfields('95').value) <> '0' Then
            INSERT INTO adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                        amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank, oddate)
            SELECT  seq_adschd.nextval autoid,
                    0 ismortage,
                    p_txmsg.txfields('03').value acctno,
                    To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                    p_txmsg.txnum txnum,
                    '' refadno,
                    To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                    p_txmsg.txfields('10').value amt,
                    p_txmsg.txfields('11').value feeamt,
                    p_txmsg.txfields('18').value vatamt,
                    p_txmsg.txfields('14').value bankfee,
                    0 paidamt,
                    p_txmsg.txfields('46').value adtype,
                    p_txmsg.txfields('44').value rrtype,
                    p_txmsg.txfields('43').value ciacctno ,
                    p_txmsg.txfields('05').value custbank ,
                    To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate
            FROM dual;
        Else -- TH khong tu dong GN

            INSERT INTO adschdtemp(autoid, ismortage, status, deltd, acctno, txdate, txnum, refadno, cleardt,
                        amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank, oddate, reftxdate, reftxnum)
            SELECT  seq_adschd.nextval autoid,
                    0 ismortage,
                    'P' status,
                    p_txmsg.deltd deltd,
                    p_txmsg.txfields('03').value acctno,
                    To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                    p_txmsg.txnum txnum, '' refadno,
                    To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                    p_txmsg.txfields('10').value amt,
                    p_txmsg.txfields('11').value feeamt,
                    p_txmsg.txfields('18').value vatamt,
                    p_txmsg.txfields('14').value bankfee,
                    0 paidamt,
                    p_txmsg.txfields('46').value adtype,
                    p_txmsg.txfields('44').value rrtype,
                    p_txmsg.txfields('43').value ciacctno,
                    p_txmsg.txfields('05').value custbank,
                    To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate,
                    To_date(p_txmsg.txdate, systemnums.c_date_format) reftxdate,
                    p_txmsg.txfields('99').value reftxnum
            From DUAL;

            Begin
                Select Count(1) into v_count
                from admast
                where txnum = p_txmsg.txfields('99').value
                        and txdate = To_date(p_txmsg.txdate, systemnums.c_date_format);
            EXCEPTION
            WHEN OTHERS THEN
                v_count := 0;
            End;

            If v_count = 0 then
               INSERT INTO admast(autoid, txnum, txdate, acctno, amt, feeamt, deltd, status, brid, tlid, DESCRIPTION)
               Select   seq_admast.nextval autoid,
                        p_txmsg.txfields('99').value txnum,
                        To_date(p_txmsg.txdate, systemnums.c_date_format) txdate,
                        p_txmsg.txfields('05').value acctno,
                        round(p_txmsg.txfields('10').value,0) amt,
                        round(p_txmsg.txfields('11').value + p_txmsg.txfields('14').value,0) feeamt,
                        p_txmsg.deltd deltd,
                        'P' status,
                        p_txmsg.brid brid,
                        p_txmsg.tlid tlid,
                        '' description
               From Dual;
            Else
                Update admast
                    Set amt = amt + round(p_txmsg.txfields('10').value,0),
                    feeamt = feeamt + round(p_txmsg.txfields('11').value + p_txmsg.txfields('14').value,0)
                Where txnum = p_txmsg.txfields('99').value and txdate = p_txmsg.txdate;
            End If;
        End If;
    else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        p_err_code:=0;
    end if;
    plog.debug (pkgctx, '<<END OF fn_DayAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_DayAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_DayAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_DayAdvancedPayment;*/


---------------------------------fn_DayAdvancedPayment------------------------------------------------
FUNCTION fn_DayAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL           boolean;
    l_lngErrCode            number(20,0);
    v_count                 number(20,0);
    v_dblMaxAdvanceAmount   number(20,4);
    v_dblADAMT              number(20,4);
    v_dblADFAMT             number(20,4);
    v_dblStsID              number(20,4);
    v_dblSTSEXAMT           number(20,4);
    v_dblSTSAMT             number(20,4);
    v_dblSTSFAMT            number(20,4);
    l_RRTYPE                VARCHAR2(1);
    l_CIACCTNO              VARCHAR2(10);
    v_strRRtype varchar2(10);
    v_strCIacctno varchar2(20);
    v_strCustbank varchar2(20);
    l_ISVSD     NUMBER;
    v_limit_adv number;
    v_orgamt_adv number;
    v_adtype varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_DayAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_DayAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_dblADAMT:=round(p_txmsg.txfields('10').value,0) + round(p_txmsg.txfields('11').value,0); --+ p_txmsg.txfields('14').value,0);

    --plog.debug (pkgctx, 'reftxnum:' || p_txmsg.txfields('99').value);

    if not v_blnREVERSAL THEN
        IF to_number(p_txmsg.txfields('60').value) = 0 THEN
            for rec in
               (
                   /*SELECT AUTOID,STS.AMT EXECAMT, OD.AFACCTNO, STS.cleardate, od.orderid,
                        STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT AMT,
                        STS.FAMT FAMT
                    FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC
                    WHERE STS.CODEID=SEC.CODEID AND STS.ORGORDERID=OD.ORDERID AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                        and od.errod ='N'
                        AND STS.AFACCTNO=p_txmsg.txfields('03').value
                        AND sts.cleardate=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                        AND sts.txdate=TO_DATE(p_txmsg.txfields('42').value,systemnums.c_date_format)
                    ORDER BY amt desc*/
                    --THENN SUA PHAN BO GIA TRI UNG TRUOC VAO TUNG LENH
                    -- GIA TRI PHAN BO MAX = GIA TRI KHOP - PHI GD - THUE BAN
                    SELECT AUTOID,STS.AMT EXECAMT, OD.AFACCTNO, STS.cleardate, od.orderid,
                        STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT
                        - CASE WHEN (OD.FEEACR<=0 and od.txdate=getcurrdate ) THEN round(ODT.DEFFEERATE*STS.AMT/100) ELSE OD.FEEACR END
                        - (case when cf.vat='Y' then (case when OD.TAXSELLAMT > 0 then OD.TAXSELLAMT else round(TO_NUMBER(SYS.VARVALUE)*STS.AMT/100) END)
                          else 0 end)
                        - STS.ARIGHT AMT,
                        STS.FAMT FAMT
                    FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC, ODTYPE ODT, SYSVAR SYS,ODMAPEXT ODM, AFMAST AF, CFMAST CF
                    WHERE STS.CODEID=SEC.CODEID AND STS.ORGORDERID=OD.ORDERID AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                        and od.actype = odt.actype and od.afacctno = af.acctno and af.custid = cf.custid
                        AND od.errod ='N'
                         AND OD.orderid = ODM.orderid (+) AND NVL(ODM.isvsd,'N') = 'N'
                        AND SYS.VARNAME = 'ADVSELLDUTY' AND SYS.GRNAME = 'SYSTEM'
                        AND STS.AFACCTNO=p_txmsg.txfields('03').value
                        AND sts.cleardate=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                        AND sts.txdate=TO_DATE(p_txmsg.txfields('42').value,systemnums.c_date_format)
                    ORDER BY amt DESC
                )
            loop
                v_dblStsID := rec.AUTOID;
                v_dblSTSEXAMT := round(rec.EXECAMT,0);
                v_dblSTSAMT := round(rec.AMT,0);
                If v_dblSTSAMT > v_dblADAMT Then
                    -- Log thong tin lenh ung
                    INSERT INTO adschddtl(autoid, acctno, txdate, txnum, cleardate, orderid, aamt, feeamt, vatamt, DELTD, STATUS)
                    VALUES (SEQ_ADSCHDDTL.NEXTVAL , rec.AFACCTNO, TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, rec.cleardate, rec.orderid, v_dblADAMT, 0, 0, p_txmsg.deltd, 'A');

                    UPDATE STSCHD
                         SET AAMT = AAMT + v_dblADAMT
                    WHERE AUTOID = v_dblStsID;

                    /*--- HaiLT them de cap nhap so tien da ung truoc vao ODMAPEXT doi voi ung truoc VSD (cap nhap vao dong dau tien lay dc)
                    if p_txmsg.txfields('60').value <> 0 then
                        for rec1 in (select * from odmapext where  ORDERID = rec.orderid and isvsd <> 'N' and deltd <> 'Y' and rownum =1 )
                        loop
                            UPDATE ODMAPEXT SET AAMT = AAMT + v_dblADAMT
                                WHERE ORDERID = rec1.orderid and refid = rec1.refid;
                        end loop;
                    end if;*/

                    v_dblADAMT := 0;
                else
                    -- Log thong tin lenh ung
                    INSERT INTO adschddtl(autoid, acctno, txdate, txnum, cleardate, orderid, aamt, feeamt, vatamt, DELTD, STATUS)
                    VALUES (SEQ_ADSCHDDTL.NEXTVAL , rec.AFACCTNO, TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, rec.cleardate, rec.orderid, v_dblSTSAMT, 0, 0, p_txmsg.deltd, 'A');

                    UPDATE STSCHD
                         SET AAMT=AAMT + v_dblSTSAMT
                     WHERE AUTOID= v_dblStsID;

                    /*--- HaiLT them de cap nhap so tien da ung truoc vao ODMAPEXT doi voi ung truoc VSD (cap nhap vao dong dau tien lay dc)
                    if p_txmsg.txfields('60').value <> 0 then
                        for rec2 in (select * from odmapext where  ORDERID = rec.orderid and isvsd <> 'N' and deltd <> 'Y' and rownum =1 )
                        loop
                            UPDATE ODMAPEXT SET AAMT = AAMT + v_dblSTSAMT
                                WHERE ORDERID = rec2.orderid and refid = rec2.refid;
                        end loop;
                    end if;*/

                    v_dblADAMT:=v_dblADAMT-v_dblSTSAMT;
                end if;
            exit when v_dblADAMT <= 0;
            end loop;
        ELSE
            for rec in
               (
                   /*SELECT AUTOID,STS.AMT EXECAMT, OD.AFACCTNO, STS.cleardate, od.orderid,
                        STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT AMT,
                        STS.FAMT FAMT
                    FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC
                    WHERE STS.CODEID=SEC.CODEID AND STS.ORGORDERID=OD.ORDERID AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                        and od.errod ='N'
                        AND STS.AFACCTNO=p_txmsg.txfields('03').value
                        AND sts.cleardate=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                        AND sts.txdate=TO_DATE(p_txmsg.txfields('42').value,systemnums.c_date_format)
                    ORDER BY amt desc*/
                    --THENN SUA PHAN BO GIA TRI UNG TRUOC VAO TUNG LENH
                    -- GIA TRI PHAN BO MAX = GIA TRI KHOP - PHI GD - THUE BAN
                    SELECT AUTOID,STS.AMT EXECAMT, OD.AFACCTNO, STS.cleardate, od.orderid,
                        STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT
                        - CASE WHEN (OD.FEEACR<=0 and od.txdate=getcurrdate ) THEN round(ODT.DEFFEERATE*STS.AMT/100) ELSE OD.FEEACR END
                        - case when cf.vat='Y' then (case when OD.TAXSELLAMT > 0 then OD.TAXSELLAMT else round(TO_NUMBER(SYS.VARVALUE)*STS.AMT/100) END )
                          else 0 end
                        - STS.ARIGHT AMT,
                        STS.FAMT FAMT
                    FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC, ODTYPE ODT, SYSVAR SYS, ODMAPEXT ODM, AFMAST AF,CFMAST CF
                    WHERE STS.CODEID=SEC.CODEID AND STS.ORGORDERID=OD.ORDERID AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                        and od.actype = odt.actype and od.afacctno = af.acctno and af.custid = cf.custid
                        AND od.errod ='N'
                        AND OD.orderid = ODM.orderid AND ODM.isvsd = 'Y'
                        AND SYS.VARNAME = 'ADVSELLDUTY' AND SYS.GRNAME = 'SYSTEM'
                        AND STS.AFACCTNO=p_txmsg.txfields('03').value
                        AND sts.cleardate=TO_DATE(p_txmsg.txfields('08').value,systemnums.c_date_format)
                        AND sts.txdate=TO_DATE(p_txmsg.txfields('42').value,systemnums.c_date_format)
                    ORDER BY amt DESC
                )
            loop
                v_dblStsID := rec.AUTOID;
                v_dblSTSEXAMT := round(rec.EXECAMT,0);
                v_dblSTSAMT := round(rec.AMT,0);
                If v_dblSTSAMT > v_dblADAMT Then
                    -- Log thong tin lenh ung
                    INSERT INTO adschddtl(autoid, acctno, txdate, txnum, cleardate, orderid, aamt, feeamt, vatamt, DELTD, STATUS)
                    VALUES (SEQ_ADSCHDDTL.NEXTVAL , rec.AFACCTNO, TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, rec.cleardate, rec.orderid, v_dblADAMT, 0, 0, p_txmsg.deltd, 'A');

                    UPDATE STSCHD
                         SET AAMT = AAMT + v_dblADAMT
                    WHERE AUTOID = v_dblStsID;

                    --- HaiLT them de cap nhap so tien da ung truoc vao ODMAPEXT doi voi ung truoc VSD (cap nhap vao dong dau tien lay dc)
                    if p_txmsg.txfields('60').value <> 0 then
                        for rec1 in (select * from odmapext where  ORDERID = rec.orderid and isvsd <> 'N' and deltd <> 'Y' and rownum =1 )
                        loop
                            UPDATE ODMAPEXT SET AAMT = AAMT + v_dblADAMT
                                WHERE ORDERID = rec1.orderid and refid = rec1.refid;
                        end loop;
                end if;

                v_dblADAMT := 0;
                else
                    -- Log thong tin lenh ung
                    INSERT INTO adschddtl(autoid, acctno, txdate, txnum, cleardate, orderid, aamt, feeamt, vatamt, DELTD, STATUS)
                    VALUES (SEQ_ADSCHDDTL.NEXTVAL , rec.AFACCTNO, TO_DATE(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, rec.cleardate, rec.orderid, v_dblSTSAMT, 0, 0, p_txmsg.deltd, 'A');

                    UPDATE STSCHD
                         SET AAMT=AAMT + v_dblSTSAMT
                             WHERE AUTOID= v_dblStsID;

                    --- HaiLT them de cap nhap so tien da ung truoc vao ODMAPEXT doi voi ung truoc VSD (cap nhap vao dong dau tien lay dc)
                    if p_txmsg.txfields('60').value <> 0 then
                        for rec2 in (select * from odmapext where  ORDERID = rec.orderid and isvsd <> 'N' and deltd <> 'Y' and rownum =1 )
                        loop
                            UPDATE ODMAPEXT SET AAMT = AAMT + v_dblSTSAMT
                                WHERE ORDERID = rec2.orderid and refid = rec2.refid;
                        end loop;
                    end if;

                    v_dblADAMT:=v_dblADAMT-v_dblSTSAMT;
                end if;
            exit when v_dblADAMT <= 0;
            end loop;
        END IF;

         --Neu con du tien khong phan bo het thi bao loi vuot qua so tien ung truoc
         if v_dblADAMT>2 then
              p_err_code := '-400101'; --Ung qua so tien duoc phep
              RETURN errnums.C_BIZ_RULE_INVALID;
         end if;



        if  p_txmsg.txfields('06').value='NULL' or p_txmsg.txfields('06').value is null then
            v_strRRtype :='';
            v_strCIacctno:='';
            v_strCustbank:='';
        else
            begin
                select rrtype, ciacctno, custbank into v_strRRtype,v_strCIacctno,v_strCustbank
                from adtype
                where actype =p_txmsg.txfields('06').value;
            exception when others then
                v_strRRtype :='';
                v_strCIacctno:='';
                v_strCustbank:='';
            end ;
        end if;

        v_dblADAMT:= p_txmsg.txfields('10').value;
        v_orgamt_adv := p_txmsg.txfields('10').value;

        IF p_txmsg.txfields('06').value = 'AUTO' THEN

        FOR REC IN ( select * from afidtype where objname ='AD.ADTYPE'
                       AND AFTYPE = p_txmsg.txfields('89').value
                       and  actype not in (select adtype from aftype ) order by odrnum )
        LOOP
           begin
                select rrtype, ciacctno, custbank into v_strRRtype,v_strCIacctno,v_strCustbank
                from adtype
                where actype = rec.actype;
            exception when others then
                v_strRRtype :='';
                v_strCIacctno:='';
                v_strCustbank:='';
            end ;

            if v_strRRtype ='C' then
             select min(lmamtmax)- nvl(min(amt),0) into v_limit_adv
            from cflimit,(SELECT SUM (AMT) amt FROM adschd where  rrtype ='C')ads,cfmast cf
            WHERE lmsubtype ='ADV'
            and cflimit.bankid = cf.custid
            AND cf.fullname='BMSCAD';

            elsif v_strRRtype ='B' then

            select min(lmamtmax)- nvl(min(amt),0) into v_limit_adv
            from cflimit,(SELECT SUM (AMT) amt FROM adschd where  custbank =v_strCustbank)ads
            WHERE lmsubtype ='ADV'
            AND BANKID =v_strCustbank ;

            end if;

        if v_dblADAMT< v_limit_adv then


           INSERT INTO adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                        amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank,oddate)
            SELECT  seq_adschd.nextval autoid,
                    0 ismortage,
                    p_txmsg.txfields('03').value acctno,
                    To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                    p_txmsg.txnum txnum,
                    '' refadno,
                    To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                    v_dblADAMT amt,
                   round( p_txmsg.txfields('11').value*v_dblADAMT/v_orgamt_adv) feeamt,
                    p_txmsg.txfields('18').value vatamt,
                    p_txmsg.txfields('14').value bankfee,
                    0 paidamt,
                   rec.actype adtype,
                    v_strRRtype rrtype,
                    v_strCiacctno ciacctno ,
                    v_strCustbank custbank,
                    To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate
            FROM dual;
                v_dblADAMT:=0;
         exit  ;


       else

       IF v_limit_adv >0 THEN
       INSERT INTO adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                        amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank,oddate)
            SELECT  seq_adschd.nextval autoid,
                    0 ismortage,
                    p_txmsg.txfields('03').value acctno,
                    To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                    p_txmsg.txnum txnum,
                    '' refadno,
                    To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                   v_limit_adv    amt,
                   round( p_txmsg.txfields('11').value*v_limit_adv/v_orgamt_adv)  feeamt,
                    p_txmsg.txfields('18').value vatamt,
                    p_txmsg.txfields('14').value bankfee,
                    0 paidamt,
                    rec.actype adtype,
                    v_strRRtype rrtype,
                    v_strCiacctno ciacctno ,
                    v_strCustbank custbank,
                    To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate
            FROM dual;
       END IF;
            v_dblADAMT:= v_dblADAMT - GREATEST( v_limit_adv,0) ;
     end if;
     end loop;

     -- con lai cho nguon cong ty

     if v_dblADAMT>0 then

     -- select MAX(ACTYPE) INTO v_adtype from adtype where rrtype ='C';
     select ADTYPE INTO v_adtype from AFTYPE where ACTYPE =p_txmsg.txfields('89').value;

       INSERT INTO adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                        amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank,oddate)
            SELECT  seq_adschd.nextval autoid,
                    0 ismortage,
                    p_txmsg.txfields('03').value acctno,
                    To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                    p_txmsg.txnum txnum,
                    '' refadno,
                    To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                    v_dblADAMT      amt,
                    round( p_txmsg.txfields('11').value*v_dblADAMT/v_orgamt_adv)   feeamt,
                    p_txmsg.txfields('18').value vatamt,
                    p_txmsg.txfields('14').value bankfee,
                    0 paidamt,
                    v_adtype adtype,
                    'C' rrtype,
                    '' ciacctno ,
                    '' custbank,
                    To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate
            FROM dual;

     end if;

     ELSE
            INSERT INTO adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                        amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank,oddate)
            SELECT  seq_adschd.nextval autoid,
                    0 ismortage,
                    p_txmsg.txfields('03').value acctno,
                    To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                    p_txmsg.txnum txnum,
                    '' refadno,
                    To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                    p_txmsg.txfields('10').value amt,
                    p_txmsg.txfields('11').value feeamt,
                    p_txmsg.txfields('18').value vatamt,
                    p_txmsg.txfields('14').value bankfee,
                    0 paidamt,
                    p_txmsg.txfields('06').value adtype,
                    v_strRRtype rrtype,
                    v_strCiacctno ciacctno ,
                    v_strCustbank custbank,
                    To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate
            FROM dual;


     end if;




    else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        update adschd set deltd ='Y' where txnum = p_txmsg.txnum and txdate =To_date(p_txmsg.txdate,systemnums.c_date_format);
        for rec in (select * from adschddtl where txnum = p_txmsg.txnum and txdate =To_date(p_txmsg.txdate,systemnums.c_date_format))
        loop
            update stschd set aamt = aamt-rec.aamt where orgorderid = rec.orderid and duetype ='RM';
            --- HaiLT them de cap nhap so tien da ung truoc vao ODMAPEXT doi voi ung truoc VSD (cap nhap vao dong dau tien lay dc)
            if p_txmsg.txfields('60').value <> 0 then
                for rec4 in (select * from odmapext where  ORDERID = rec.orderid and isvsd <> 'N' and deltd <> 'Y' and rownum =1 )
                loop
                    UPDATE ODMAPEXT SET AAMT = AAMT - rec.aamt
                        WHERE ORDERID = rec4.orderid and refid = rec4.refid;
                end loop;
            end if;

            update adschddtl set deltd ='Y' where autoid = rec.autoid;
        end loop;
        p_err_code:=0;
    end if;
    plog.debug (pkgctx, '<<END OF fn_DayAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_DayAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_DayAdvancedPayment' || dbms_utility.format_error_backtrace);
      RAISE errnums.E_SYSTEM_ERROR;
END fn_DayAdvancedPayment;


---------------------------------fn_DrowdownAdvancedPayment------------------------------------------------
FUNCTION fn_DrowdownAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL           boolean;
l_lngErrCode            number(20,0);
v_count                 number(20,0);
v_dblMaxAdvanceAmount   number(20,4);
v_dblADAMT              number(20,4);
v_dblADFAMT             number(20,4);
v_dblStsID              number(20,4);
v_dblSTSEXAMT           number(20,4);
v_dblSTSAMT             number(20,4);
v_dblSTSFAMT            number(20,4);
l_RRTYPE                VARCHAR2(1);
l_CIACCTNO              VARCHAR2(10);
l_autoid                number(20);
l_txnum                 VARCHAR2(10);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_DrowdownAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_DrowdownAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    -- v_dblADAMT:=round(p_txmsg.txfields('10').value,0) + round(p_txmsg.txfields('11').value + p_txmsg.txfields('14').value,0);
    Begin
        select txnum into l_txnum from ADSCHDTEMP
            where acctno = p_txmsg.txfields('03').value
                and rrtype =  p_txmsg.txfields('44').value
                and cleardt =  To_date(p_txmsg.txfields('08').value, systemnums.c_date_format)
                and oddate = To_date(p_txmsg.txfields('42').value, systemnums.c_date_format)
                and reftxnum = p_txmsg.txfields('99').value;
    EXCEPTION
        WHEN OTHERS THEN    l_txnum := '';
    END;

    if not v_blnREVERSAL then
        INSERT INTO adschd (autoid, ismortage, acctno, txdate, txnum, refadno, cleardt,
                    amt, feeamt, vatamt, bankfee, paidamt, adtype, rrtype, ciacctno, custbank, oddate)
        SELECT  seq_adschd.nextval autoid,
                0 ismortage,
                p_txmsg.txfields('03').value acctno,
                To_date(p_txmsg.txdate,systemnums.c_date_format) txdate,
                --p_txmsg.txnum txnum,
                l_txnum,
                '' refadno,
                To_date(p_txmsg.txfields('08').value, systemnums.c_date_format) cleardt,
                p_txmsg.txfields('10').value amt,
                p_txmsg.txfields('11').value feeamt,
                p_txmsg.txfields('18').value vatamt,
                p_txmsg.txfields('14').value bankfee,
                0 paidamt,
                p_txmsg.txfields('46').value adtype,
                p_txmsg.txfields('44').value rrtype,
                p_txmsg.txfields('43').value ciacctno ,
                p_txmsg.txfields('05').value custbank ,
                To_date(p_txmsg.txfields('42').value, systemnums.c_date_format) oddate
        FROM dual;
    else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        p_err_code:=0;
    end if;
    plog.debug (pkgctx, '<<END OF fn_DrowdownAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_DrowdownAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_DrowdownAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_DrowdownAdvancedPayment;

FUNCTION fn_ApproveAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

l_txmsg                 tx.msg_rectype;
v_blnREVERSAL           boolean;
l_lngErrCode            number(20,0);
v_count                 number(20,0);
v_dblMaxAdvanceAmount   number(20,4);
v_dblADAMT              number(20,4);
v_dblADFAMT             number(20,4);
v_dblStsID              number(20,4);
v_dblSTSEXAMT           number(20,4);
v_dblSTSAMT             number(20,4);
v_dblSTSFAMT            number(20,4);
l_RRTYPE                VARCHAR2(1);
l_CIACCTNO              VARCHAR2(10);
v_strDesc               VARCHAR2(1000);
v_strEN_Desc            VARCHAR2(1000);
l_AdvDays               Number;
l_err_param             varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_ApproveAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_ApproveAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1156';

    l_txmsg.msgtype     :='T';
    l_txmsg.local       :='N';
    l_txmsg.tlid        := p_txmsg.tlid;
    l_txmsg.brid        := p_txmsg.brid;
    l_txmsg.wsname      := p_txmsg.wsname;
    l_txmsg.ipaddress   := p_txmsg.ipaddress;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := p_txmsg.deltd;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := '1155';
    l_txmsg.txdate      := to_date(p_txmsg.txdate,systemnums.c_date_format);
    l_txmsg.busdate     := to_date(p_txmsg.txdate,systemnums.c_date_format);
    l_txmsg.tltxcd      := '1156';

    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;

    If Not v_blnREVERSAL then

        For rec in
        (
            Select  SCH.AUTOID, SCH.ISMORTAGE, SCH.STATUS, SCH.DELTD, SCH.ACCTNO, SCH.TXDATE, SCH.TXNUM,
                    SCH.REFADNO, SCH.CLEARDT, SCH.AMT, SCH.FEEAMT, SCH.VATAMT, SCH.BANKFEE, SCH.PAIDAMT,
                    SCH.ODDATE, SCH.ADTYPE, SCH.RRTYPE, SCH.CUSTBANK, SCH.CIACCTNO, SCH.PAIDDATE, SCH.REFTXDATE, SCH.REFTXNUM,
                    TYP.ADVRATE, TYP.VATRATE, TYP.ADVBANKRATE, TYP.ADVMINFEE, TYP.ADVMINFEEBANK,
                    CF.FULLNAME, 0 CIDRAWNDOWN, 1 BANKDRAWNDOWN, 0 CMPDRAWNDOWN, 1 AUTODRAWNDOWN,
                    'Giai ngan UTTB giao dich ngay ' || to_char(SCH.ODDATE,systemnums.c_date_format) || ' thanh toan ngay '  || to_char(SCH.CLEARDT,systemnums.c_date_format) || '''' DES
            FROM ADMAST AD, ADSCHDTEMP SCH, ADTYPE TYP, CFMAST CF, AFMAST AF
            WHERE AD.TXNUM = SCH.REFTXNUM AND AD.TXDATE = SCH.REFTXDATE
                  AND SCH.ADTYPE = TYP.ACTYPE  AND CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SCH.ACCTNO
                  AND AD.AUTOID = P_TXMSG.TXFIELDS('02').VALUE

            )
        Loop
            --Set txnum
            plog.debug(pkgctx, 'Loop for account:' || rec.ACCTNO || ' ngay' || to_char(rec.CLEARDT));
            SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;

            l_AdvDays := To_date(rec.CLEARDT,systemnums.c_date_format) - To_date(rec.TXDATE,systemnums.c_date_format);

            --Set cac field giao dich
            --03   ACCTNO       C
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := REC.ACCTNO;
            --05    BANKID      C
            l_txmsg.txfields ('05').defname   := 'BANKID';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := REC.CUSTBANK;
            --08    ORDATE      C
            l_txmsg.txfields ('08').defname   := 'ORDATE';
            l_txmsg.txfields ('08').TYPE      := 'C';
            l_txmsg.txfields ('08').VALUE     := to_char(REC.CLEARDT,systemnums.c_date_format);
             --09   ADVAMT          N
            l_txmsg.txfields ('09').defname   := 'ADVAMT';
            l_txmsg.txfields ('09').TYPE      := 'N';
            l_txmsg.txfields ('09').VALUE     := ROUND(REC.AMT + REC.FEEAMT + REC.BANKFEE,0);
            --10    AMT         N
            l_txmsg.txfields ('10').defname   := 'AMT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := ROUND(REC.AMT,0);
            --11    FEEAMT      N
            l_txmsg.txfields ('11').defname   := 'FEEAMT';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := ROUND(REC.FEEAMT,0);

            --12    INTRATE     N
            l_txmsg.txfields ('12').defname   := 'INTRATE';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := REC.ADVRATE;
            --13    DAYS        N
            l_txmsg.txfields ('13').defname   := 'DAYS';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := l_AdvDays;
            --14    BNKFEEAMT   N
            l_txmsg.txfields ('14').defname   := 'BNKFEEAMT';
            l_txmsg.txfields ('14').TYPE      := 'N';
            l_txmsg.txfields ('14').VALUE     := ROUND(REC.BANKFEE,0);
            --15    BNKRATE     N
            l_txmsg.txfields ('15').defname   := 'BNKRATE';
            l_txmsg.txfields ('15').TYPE      := 'N';
            l_txmsg.txfields ('15').VALUE     := REC.ADVBANKRATE;
            --16    CMPMINBAL   N
            l_txmsg.txfields ('16').defname   := 'CMPMINBAL';
            l_txmsg.txfields ('16').TYPE      := 'N';
            l_txmsg.txfields ('16').VALUE     := REC.ADVMINFEE;
            --17    BNKMINBAL   N
            l_txmsg.txfields ('17').defname   := 'BNKMINBAL';
            l_txmsg.txfields ('17').TYPE      := 'N';
            l_txmsg.txfields ('17').VALUE     := REC.ADVMINFEEBANK;
            --18    VATAMT  N
            l_txmsg.txfields ('18').defname   := 'VATAMT';
            l_txmsg.txfields ('18').TYPE      := 'N';
            l_txmsg.txfields ('18').VALUE     := REC.VATAMT;
            --19    VAT     N
            l_txmsg.txfields ('19').defname   := 'VAT';
            l_txmsg.txfields ('19').TYPE      := 'N';
            l_txmsg.txfields ('19').VALUE     := ROUND(REC.BANKFEE,0);
            --20    MAXAMT      N
            l_txmsg.txfields ('20').defname   := 'MAXAMT';
            l_txmsg.txfields ('20').TYPE      := 'N';
            l_txmsg.txfields ('20').VALUE     := ROUND(REC.AMT + REC.FEEAMT + REC.BANKFEE,0);
            --30    DESC        C
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := REC.DES;
            --40    3600        C
            l_txmsg.txfields ('40').defname   := '3600';
            l_txmsg.txfields ('40').TYPE      := 'C';
            l_txmsg.txfields ('40').VALUE     := 3600;
            --41    100         C
            l_txmsg.txfields ('41').defname   := '100';
            l_txmsg.txfields ('41').TYPE      := 'C';
            l_txmsg.txfields ('41').VALUE     := 100;
            --90    CUSTNAME    C
            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

            -- TruongLD Add 21/09/2011
            --42    TXDATE     C
            l_txmsg.txfields ('42').defname   := 'TXDATE';
            l_txmsg.txfields ('42').TYPE      := 'C';
            l_txmsg.txfields ('42').VALUE     := rec.ODDATE;

            --43    CIACCTNO     C
            l_txmsg.txfields ('43').defname   := 'CIACCTNO';
            l_txmsg.txfields ('43').TYPE      := 'C';
            l_txmsg.txfields ('43').VALUE     := rec.CIACCTNO;

            --44    RRTYPE     C
            l_txmsg.txfields ('44').defname   := 'RRTYPE';
            l_txmsg.txfields ('44').TYPE      := 'C';
            l_txmsg.txfields ('44').VALUE     := rec.RRTYPE;

            --46    ACTYPE     C
            l_txmsg.txfields ('46').defname   := 'ACTYPE';
            l_txmsg.txfields ('46').TYPE      := 'C';
            l_txmsg.txfields ('46').VALUE     := rec.ADTYPE;


            --96    CIDRAWNDOWN     C
            l_txmsg.txfields ('96').defname   := 'CIDRAWNDOWN';
            l_txmsg.txfields ('96').TYPE      := 'C';
            l_txmsg.txfields ('96').VALUE     := rec.CIDRAWNDOWN;

            --97    BANKDRAWNDOWN     C
            l_txmsg.txfields ('97').defname   := 'BANKDRAWNDOWN';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE     := rec.BANKDRAWNDOWN;

             --98    CMPDRAWNDOWN     C
            l_txmsg.txfields ('98').defname   := 'CMPDRAWNDOWN';
            l_txmsg.txfields ('98').TYPE      := 'C';
            l_txmsg.txfields ('98').VALUE     := rec.CMPDRAWNDOWN;

             --95    AUTODRAWNDOWN     C
            l_txmsg.txfields ('95').defname   := 'AUTODRAWNDOWN';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE     := rec.AUTODRAWNDOWN;

             --99    ADTXNUM     C
            l_txmsg.txfields ('99').defname   := 'ADTXNUM';
            l_txmsg.txfields ('99').TYPE      := 'C';
            l_txmsg.txfields ('99').VALUE     := rec.REFTXNUM;
            -- End TruongLD
            BEGIN
                IF txpks_#1156.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 1156: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN errnums.C_SYSTEM_ERROR;
                END IF;

                Update ADSCHDTEMP set Status ='C' where acctno = rec.acctno and reftxnum = rec.reftxnum;

            END;
        End Loop;

        Update admast set status='C' where autoid = P_TXMSG.TXFIELDS('02').VALUE;

    Else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        p_err_code:=0;
    End If;

    plog.debug (pkgctx, '<<END OF fn_ApproveAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_ApproveAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_ApproveAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_ApproveAdvancedPayment;


FUNCTION fn_RejectAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

l_txmsg                 tx.msg_rectype;
v_blnREVERSAL           boolean;
l_lngErrCode            number(20,0);
v_count                 number(20,0);
v_dblMaxAdvanceAmount   number(20,4);
v_dblADAMT              number(20,4);
v_dblADFAMT             number(20,4);
v_dblStsID              number(20,4);
v_dblSTSEXAMT           number(20,4);
v_dblSTSAMT             number(20,4);
v_dblSTSFAMT            number(20,4);
l_RRTYPE                VARCHAR2(1);
l_CIACCTNO              VARCHAR2(10);
v_strDesc               VARCHAR2(1000);
v_strEN_Desc            VARCHAR2(1000);
l_AdvDays               Number;
l_err_param             varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_RejectAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_RejectAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;

    If Not v_blnREVERSAL then

        For RootRec in
        (
            Select  SCH.AUTOID, SCH.ISMORTAGE, SCH.STATUS, SCH.DELTD, SCH.ACCTNO, SCH.TXDATE, SCH.TXNUM,
                    SCH.REFADNO, SCH.CLEARDT, SCH.AMT, SCH.FEEAMT, SCH.VATAMT, SCH.BANKFEE, SCH.PAIDAMT,
                    SCH.ODDATE, SCH.ADTYPE, SCH.RRTYPE, SCH.CUSTBANK, SCH.CIACCTNO, SCH.PAIDDATE, SCH.REFTXDATE, SCH.REFTXNUM,
                    'Giai ngan UTTB giao dich ngay ' || to_char(SCH.ODDATE,systemnums.c_date_format) || ' thanh toan ngay '  || to_char(SCH.CLEARDT,systemnums.c_date_format) || '''' DES
            FROM ADMAST AD, ADSCHDTEMP SCH
            WHERE AD.TXNUM = SCH.REFTXNUM AND AD.TXDATE = SCH.REFTXDATE
                  AND AD.AUTOID = P_TXMSG.TXFIELDS('02').VALUE
            )
        Loop

            Update ADSCHDTEMP set Status = 'R'
            where REFTXNUM = RootRec.REFTXNUM
                    and RefTxdate = TO_DATE(RootRec.REFTXDATE,systemnums.c_date_format);

            v_dblADAMT := RootRec.AMT;

            for rec in
               (
                    SELECT AUTOID,STS.AMT EXECAMT, STS.AAMT-STS.FAMT AMT,STS.FAMT FAMT, OD.AFACCTNO, STS.cleardate, od.orderid
                    FROM STSCHD STS,ODMAST OD,SBSECURITIES SEC
                    WHERE STS.CODEID = SEC.CODEID AND STS.ORGORDERID = OD.ORDERID
                          AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                          AND STS.AFACCTNO = RootRec.Acctno
                          AND sts.cleardate = TO_DATE(RootRec.CLEARDT,systemnums.c_date_format)
                          AND sts.txdate = TO_DATE(RootRec.ODDATE,systemnums.c_date_format)
                    ORDER BY amt desc
               )
             loop

                 v_dblStsID := rec.AUTOID;
                 v_dblSTSEXAMT := round(rec.EXECAMT,0);
                 v_dblSTSAMT := round(rec.AMT,0);

                 plog.debug (pkgctx,'v_dblStsID =' || v_dblStsID);
                 plog.debug (pkgctx,'v_dblSTSEXAMT =' || v_dblSTSEXAMT);
                 plog.debug (pkgctx,'v_dblSTSAMT =' || v_dblSTSAMT);
                 plog.debug (pkgctx,'v_dblADAMT =' || v_dblADAMT);

                 If v_dblSTSAMT >= v_dblADAMT Then

                    Update ADSCHDDTL Set AAMT = AAMT - v_dblADAMT, STATUS ='R' where ORDERID = rec.ORDERID and CLEARDATE = to_date(rec.cleardate, systemnums.c_date_format);

                    UPDATE STSCHD
                         SET AAMT = AAMT - v_dblADAMT
                             WHERE AUTOID = v_dblStsID;
                    v_dblADAMT:=0;
                 else

                    Update ADSCHDDTL Set AAMT = AAMT - v_dblADAMT, STATUS ='R' where ORDERID= rec.ORDERID and CLEARDATE = to_date(rec.cleardate, systemnums.c_date_format);

                    UPDATE STSCHD
                         SET AAMT = AAMT - v_dblSTSAMT
                             WHERE AUTOID = v_dblStsID;
                    v_dblADAMT:= v_dblADAMT - v_dblSTSAMT;

                 end if;
                 exit when v_dblADAMT <= 0;
             end loop;
        End Loop; -- Rootrec

        Update ADMAST Set Status = 'R' where AUTOID = P_TXMSG.TXFIELDS('02').VALUE;
    Else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        p_err_code:=0;
    End If;

    plog.debug (pkgctx, '<<END OF fn_RejectAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_RejectAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_RejectAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_RejectAdvancedPayment;


 ---------------------------------fn_OrderAdvancedPayment------------------------------------------------
FUNCTION fn_OrderAdvancedPayment(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_dblMaxAdvanceAmount   number(20,4);
v_dblADAMT  number(20,4);
v_dblADFAMT  number(20,4);
v_dblADFeeRate number(20,4);
v_dblStsID  number(20,4);
v_dblSTSEXAMT number(20,4);
v_dblSTSAMT number(20,4);
v_dblSTSFAMT   number(20,4);
v_dblautoid number(20,0);
v_DealPaid number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_OrderAdvancedPayment');
    plog.debug (pkgctx, '<<BEGIN OF fn_OrderAdvancedPayment');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    if not v_blnREVERSAL then
        select autoid into v_dblautoid from stschd where STATUS='N' AND DUETYPE='RM' AND DELTD='N' and ORGORDERID=p_txmsg.txfields('05').value;
        UPDATE STSCHD SET AAMT=round(AAMT+p_txmsg.txfields('10').value+p_txmsg.txfields('15').value,0), FAMT=round(FAMT+p_txmsg.txfields('11').value,0)
        WHERE autoid=v_dblautoid;

        v_DealPaid:=round(to_number(p_txmsg.txfields('15').value)+to_number(p_txmsg.txfields('22').value)+to_number(p_txmsg.txfields('23').value)-to_number(p_txmsg.txfields('25').value),0);
        plog.debug (pkgctx, 'begin fn_OrderAdvancedPayment');
        if v_DealPaid>0 then
            CSPKS_DFPROC.pr_ADVDFPayment(p_txmsg,v_dblautoid,v_DealPaid,p_err_code);
        end if;
    else
        --Giao dich batch khong thuc hien revert.
        --Neu muon giao dich bang tay di qua day thi viet them phan revert tai day
        p_err_code:=0;
    end if;
    plog.debug (pkgctx, '<<END OF fn_OrderAdvancedPayment');
    plog.setendsection (pkgctx, 'fn_OrderAdvancedPayment');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_OrderAdvancedPayment');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_OrderAdvancedPayment;

  ---------------------------------pr_CIAutoAdvance------------------------------------------------
  PROCEDURE pr_CIAutoAdvance(p_txmsg in tx.msg_rectype,p_orderid varchar,p_advamt number,p_rcvamt number,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      l_dblamount number(20,0);
      l_dblbalance number(20,0);
      l_dblfee number(20,0);
      l_dbladvamt number(20,0);
      --l_dblDEBTAMT number(20,0);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_CIAutoAdvance');


    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1143';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';

    begin
        l_txmsg.tlid        := p_txmsg.tlid;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.txtime      := to_char(sysdate,'HH24:MM:SS');
    begin
        l_txmsg.batchname   := p_txmsg.TXNUM;
    exception when others then
        l_txmsg.batchname   := 'ADV';
    end;

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1143';
    plog.debug(pkgctx, 'Begin loop');
    l_dblamount:=0;


    --Xac dinh xem lenh co lich ung truoc ma CI khong du thanh toan
    for rec in
    (
       SELECT ISMORTAGE,AFACCTNO,AMT,QTTY,FULLNAME,ADDRESS,LICENSE,FAMT,CUSTODYCD,SYMBOL,AAMT,ORGORDERID,PAIDAMT,
            PAIDFEEAMT,FEERATE,MINBAL,TXDATE,DES,CLEARDATE,DAYS,
            GREATEST(LEAST(ROUND(ADVAMT/(1+FEERATE*DAYS/100/360)), ADVAMT-MINBAL),0) DEPOAMT,
            GREATEST(LEAST(ROUND(ADVAMT/(1+FEERATE*DAYS/100/360)), ADVAMT-MINBAL),0) MAXDEPOAMT,
            GREATEST(ADVAMT,0) ADVAMT
        FROM (
            SELECT  1 ISMORTAGE,STSCHD.AFACCTNO,AMT,QTTY,CFMAST.FULLNAME,CFMAST.ADDRESS,CFMAST.idcode LICENSE,FAMT,
                    CUSTODYCD,STSCHD.SYMBOL,AAMT,ORGORDERID,PAIDAMT,PAIDFEEAMT,
                    SYSVAR1.VARVALUE FEERATE,SYSVAR2.VARVALUE MINBAL,STSCHD.TXDATE,
                    'UTTB cua lenh ' || STSCHD.SYMBOL || ' so ' || substr(ORGORDERID,11,6) || ' khop ngay ' || STSCHD.TXDATE  DES, STSCHD.CLEARDATE,
                (CASE WHEN CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY') ELSE CLEARDATE END)=0 THEN 1 ELSE   CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY') ELSE CLEARDATE END)END) DAYS,
                ROUND(LEAST(AMT*(100-ODTYPE.DEFFEERATE-STSCHD.SECDUTY)/100,
                      AMT*(100-STSCHD.SECDUTY)/100-ODTYPE.MINFEEAMT)-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) ADVAMT
            FROM
            (SELECT STS.ORGORDERID,STS.TXDATE,MAX(STS.AFACCTNO) AFACCTNO, MAX(STS.CODEID) CODEID,
                    MAX(STS.CLEARDAY) CLEARDAY,MAX(STS.CLEARCD) CLEARCD,SUM(STS.AMT) AMT,
                    SUM(STS.QTTY) QTTY,SUM(STS.FAMT) FAMT,SUM(STS.AAMT) AAMT,SUM(STS.PAIDAMT) PAIDAMT,
                    SUM(STS.PAIDFEEAMT) PAIDFEEAMT,MAX(MST.actype) ACTYPE,MAX(MST.EXECTYPE) EXECTYPE,
                    MAX(AF.custid) CUSTID,max(sts.CLEARDATE) CLEARDATE,MAX(SEC.SYMBOL) SYMBOL,
                   (CASE WHEN( MAX(cf.VAT)='Y' OR MAX(cf.whtax)='Y') THEN TO_NUMBER(MAX(SYS.VARVALUE)+ MAX(SYS3.VARVALUE)) ELSE 0 END) SECDUTY
                FROM STSCHD STS,ODMAST MST,AFMAST AF,SBSECURITIES SEC, AFTYPE TYP, SYSVAR SYS, cfmast cf,SYSVAR SYS3
                WHERE STS.codeid=SEC.codeid AND STS.orgorderid=MST.orderid and mst.afacctno=af.acctno and af.custid = cf.custid
                AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                    AND AF.ACTYPE=TYP.ACTYPE AND SYS.VARNAME='ADVSELLDUTY' AND SYS.GRNAME='SYSTEM'
                    AND SYS3.VARNAME='WHTAX' AND SYS3.GRNAME='SYSTEM'
                    GROUP BY STS.ORGORDERID,STS.TXDATE
             ) STSCHD,SYSVAR,SYSVAR SYSVAR1,SYSVAR SYSVAR2,ODTYPE,CFMAST
            WHERE AMT+PAIDAMT-AAMT>0
            AND SYSVAR.VARNAME='CURRDATE' AND SYSVAR.GRNAME='SYSTEM'
            AND SYSVAR1.VARNAME='AINTRATE' AND SYSVAR1.GRNAME='SYSTEM'
            AND SYSVAR2.VARNAME='AMINBAL' AND SYSVAR2.GRNAME='SYSTEM'
            AND STSCHD.CUSTID=CFMAST.CUSTID
            AND STSCHD.ACTYPE=ODTYPE.ACTYPE
        ) A WHERE DAYS>0 AND ADVAMT>0 AND ORGORDERID=p_orderid
    )
    loop
        if rec.DEPOAMT + 2 < p_advamt then
            p_err_code := '-700061'; --Ung qua so tien duoc phep
            RETURN;
        end if;
        l_dblamount :=round(least(rec.DEPOAMT,p_advamt),0);
        l_dblfee:=round(greatest(l_dblamount*(rec.days*rec.feerate/36000),rec.MINBAL),0);
        l_dbladvamt:=round(l_dblamount+l_dblfee,0);
        IF l_dblamount>0 THEN
            --Set txnum
            plog.debug(pkgctx, 'Loop for account:' || rec.AFACCTNO || ' ngay' || to_char(rec.cleardate));
            SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            --l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
            begin
                l_txmsg.brid        := p_txmsg.BRID;
            exception when others then
                l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
            end;

            --Set cac field giao dich
            --03   ACCTNO       C
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
            --05    ORGORDERID  C
            l_txmsg.txfields ('05').defname   := 'ORGORDERID';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := rec.ORGORDERID;
             --07   ADVAMT          N
            l_txmsg.txfields ('07').defname   := 'ADVAMT';
            l_txmsg.txfields ('07').TYPE      := 'N';
            l_txmsg.txfields ('07').VALUE     := round(l_dbladvamt,0);
            --08    ORDATE      C
            l_txmsg.txfields ('08').defname   := 'ORDATE';
            l_txmsg.txfields ('08').TYPE      := 'C';
            l_txmsg.txfields ('08').VALUE     := to_char(rec.CLEARDATE,'DD/MM/RRRR');
            --09    DUEDATE      C
            l_txmsg.txfields ('09').defname   := 'DUEDATE';
            l_txmsg.txfields ('09').TYPE      := 'C';
            l_txmsg.txfields ('09').VALUE     := to_char(rec.TXDATE,'DD/MM/RRRR');
            --10    AMT         N
            l_txmsg.txfields ('10').defname   := 'AMT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := round(l_dblamount,0);
            --11    FEEAMT      N
            l_txmsg.txfields ('11').defname   := 'FEEAMT';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := round(l_dblfee,0);

            --12    INTRATE     N
            l_txmsg.txfields ('12').defname   := 'INTRATE';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := rec.FEERATE;
            --13    DAYS        N
            l_txmsg.txfields ('13').defname   := 'DAYS';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := rec.DAYS;
            --15    ODAMT       N
            l_txmsg.txfields ('15').defname   := 'ODAMT';
            l_txmsg.txfields ('15').TYPE      := 'N';
            l_txmsg.txfields ('15').VALUE     := 0;
            --16    MINBAL      N
            l_txmsg.txfields ('16').defname   := 'MINBAL';
            l_txmsg.txfields ('16').TYPE      := 'N';
            l_txmsg.txfields ('16').VALUE     := round(rec.MINBAL,0);
            --17  ALLPAID     N
            l_txmsg.txfields ('17').defname   := 'ALLPAID';
            l_txmsg.txfields ('17').TYPE      := 'N';
            l_txmsg.txfields ('17').VALUE     := 0;
            --18  PRINTPAID   N
            l_txmsg.txfields ('18').defname   := 'PRINTPAID';
            l_txmsg.txfields ('18').TYPE      := 'N';
            l_txmsg.txfields ('18').VALUE     := 0;
            --19  INTPAID     N
            l_txmsg.txfields ('19').defname   := 'INTPAID';
            l_txmsg.txfields ('19').TYPE      := 'N';
            l_txmsg.txfields ('19').VALUE     := 0;
            --21  RLSDATE     C
            l_txmsg.txfields ('21').defname   := 'RLSDATE';
            l_txmsg.txfields ('21').TYPE      := 'C';
            l_txmsg.txfields ('21').VALUE     := v_strCURRDATE;
            --22  DEBTAMT     N
            l_txmsg.txfields ('22').defname   := 'DEBTAMT';
            l_txmsg.txfields ('22').TYPE      := 'N';
            l_txmsg.txfields ('22').VALUE     := 0;
            --23  CASHAMT     N
            l_txmsg.txfields ('23').defname   := 'CASHAMT';
            l_txmsg.txfields ('23').TYPE      := 'N';
            l_txmsg.txfields ('23').VALUE     := 0;
            --25  PAIDDEBTAMT N
            l_txmsg.txfields ('25').defname   := 'PAIDDEBTAMT';
            l_txmsg.txfields ('25').TYPE      := 'N';
            l_txmsg.txfields ('25').VALUE     := 0;
            --26  MAXADVAMT   N
            l_txmsg.txfields ('26').defname   := 'MAXADVAMT';
            l_txmsg.txfields ('26').TYPE      := 'N';
            l_txmsg.txfields ('26').VALUE     := round(rec.ADVAMT,0);
            --20    MAXAMT      N
            l_txmsg.txfields ('20').defname   := 'MAXAMT';
            l_txmsg.txfields ('20').TYPE      := 'N';
            l_txmsg.txfields ('20').VALUE     := round(rec.MAXDEPOAMT,0);
            --30    DESC        C
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := rec.DES;
            --40    3600        C
            l_txmsg.txfields ('40').defname   := '3600';
            l_txmsg.txfields ('40').TYPE      := 'C';
            l_txmsg.txfields ('40').VALUE     := 36000;
            --41    ZERO        C
            l_txmsg.txfields ('41').defname   := 'ZERO';
            l_txmsg.txfields ('41').TYPE      := 'C';
            l_txmsg.txfields ('41').VALUE     := 0;
            --90    CUSTNAME    C
            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;
            --91    ADDRESS     C
            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;
            --92    LICENSE     C
            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

            BEGIN
                IF txpks_#1143.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 1143: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;

        END IF;

    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_CIAutoAdvance');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on release pr_CIAutoAdvance');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CIAutoAdvance');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CIAutoAdvance;




PROCEDURE pr_DFAutoAdvance (p_groupid varchar,p_vndselldf number,p_err_code  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      l_dblamount number(20,0);
      l_dblbalance number(20,0);
      l_dblfee number(20,0);
      l_dbladvamt number(20,0);
      l_vnselldf number(20,0);
      --l_dblDEBTAMT number(20,0);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_DFAutoAdvance');

    l_vnselldf  := p_vndselldf;

    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1143';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;

    plog.debug(pkgctx, 'l_txmsg.tlid: 1143');
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.txtime      := to_char(sysdate,'HH24:MM:SS');

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1143';
    plog.debug(pkgctx, 'Begin loop');
    l_dblamount:=0;


    --Xac dinh xem lenh co lich ung truoc ma CI khong du thanh toan
    for rec in
    (
       SELECT C.GROUPID, B.refid DFACCTNO, A.ISMORTAGE,A.AFACCTNO,A.AMT,A.QTTY,B.EXECQTTY,A.FULLNAME,A.ADDRESS,A.LICENSE,A.FAMT,A.CUSTODYCD,A.SYMBOL,A.AAMT,A.ORGORDERID,A.PAIDAMT,
            A.PAIDFEEAMT,A.FEERATE,A.MINBAL,A.TXDATE,A.DES,A.CLEARDATE,A.DAYS,
            GREATEST(LEAST(ROUND(A.ADVAMT/(1+A.FEERATE*A.DAYS/100/360)), A.ADVAMT-A.MINBAL),0) DEPOAMT,
            GREATEST(LEAST(ROUND(A.ADVAMT/(1+A.FEERATE*A.DAYS/100/360)), A.ADVAMT-A.MINBAL),0) MAXDEPOAMT,
            GREATEST(A.ADVAMT,0) ADVAMT
        FROM (
            SELECT  1 ISMORTAGE,STSCHD.AFACCTNO,AMT,QTTY,CFMAST.FULLNAME,CFMAST.ADDRESS,CFMAST.idcode LICENSE,FAMT,
                    CUSTODYCD,STSCHD.SYMBOL,AAMT,ORGORDERID,PAIDAMT,PAIDFEEAMT,
                    SYSVAR1.VARVALUE FEERATE,SYSVAR2.VARVALUE MINBAL,STSCHD.TXDATE,
                    'UTTB cua lenh ' || STSCHD.SYMBOL || ' so ' || substr(ORGORDERID,11,6) || ' khop ngay ' || STSCHD.TXDATE  DES, STSCHD.CLEARDATE,
                (CASE WHEN CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY') ELSE CLEARDATE END)=0 THEN 1 ELSE   CLEARDATE -(CASE WHEN LENGTH(SYSVAR.VARVALUE)=10 THEN TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY') ELSE CLEARDATE END)END) DAYS,
                ROUND(LEAST(AMT*(100-ODTYPE.DEFFEERATE-STSCHD.SECDUTY)/100,
                      AMT*(100-STSCHD.SECDUTY)/100-ODTYPE.MINFEEAMT)-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) ADVAMT
            FROM
            (SELECT STS.ORGORDERID,STS.TXDATE,MAX(STS.AFACCTNO) AFACCTNO, MAX(STS.CODEID) CODEID,
                    MAX(STS.CLEARDAY) CLEARDAY,MAX(STS.CLEARCD) CLEARCD,SUM(STS.AMT) AMT,
                    SUM(STS.QTTY) QTTY,SUM(STS.FAMT) FAMT,SUM(STS.AAMT) AAMT,SUM(STS.PAIDAMT) PAIDAMT,
                    SUM(STS.PAIDFEEAMT) PAIDFEEAMT,MAX(MST.actype) ACTYPE,MAX(MST.EXECTYPE) EXECTYPE,
                    MAX(AF.custid) CUSTID,max(sts.CLEARDATE) CLEARDATE,MAX(SEC.SYMBOL) SYMBOL,
                   (CASE WHEN MAX(cf.VAT)='Y' THEN TO_NUMBER(MAX(SYS.VARVALUE)) ELSE 0 END) SECDUTY
                FROM STSCHD STS,ODMAST MST,AFMAST AF,SBSECURITIES SEC, AFTYPE TYP, SYSVAR SYS, cfmast cf
                WHERE STS.codeid=SEC.codeid AND STS.orgorderid=MST.orderid and mst.afacctno=af.acctno and af.custid = cf.custid
                AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                    AND AF.ACTYPE=TYP.ACTYPE AND SYS.VARNAME='ADVSELLDUTY' AND SYS.GRNAME='SYSTEM'
                    GROUP BY STS.ORGORDERID,STS.TXDATE
             ) STSCHD,SYSVAR,SYSVAR SYSVAR1,SYSVAR SYSVAR2,ODTYPE,CFMAST
            WHERE AMT+PAIDAMT-AAMT>0
            AND SYSVAR.VARNAME='CURRDATE' AND SYSVAR.GRNAME='SYSTEM'
            AND SYSVAR1.VARNAME='AINTRATE' AND SYSVAR1.GRNAME='SYSTEM'
            AND SYSVAR2.VARNAME='AMINBAL' AND SYSVAR2.GRNAME='SYSTEM'
            AND STSCHD.CUSTID=CFMAST.CUSTID
            AND STSCHD.ACTYPE=ODTYPE.ACTYPE
            AND STSCHD.txdate=to_date((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/YYYY')
        ) A , ODMAPEXT B, DFMAST C

        WHERE A.DAYS>0 AND A.ADVAMT>0 AND B.ORDERID=A.ORGORDERID AND B.REFID=C.ACCTNO
        AND C.GROUPID= p_groupid
    )
    loop

        exit when l_vnselldf = 0;

        if rec.DEPOAMT + 2 < p_vndselldf then
            p_err_code := '-700061'; --Ung qua so tien duoc phep
            RETURN;
        end if;
        l_dblamount :=round(least(rec.DEPOAMT,l_vnselldf),0);
        l_dblfee:=round(greatest(l_dblamount*(rec.days*rec.feerate/36000),rec.MINBAL),0);
        l_dbladvamt:=round(l_dblamount+l_dblfee,0);

        l_vnselldf:=  l_vnselldf - round(least(rec.DEPOAMT,l_vnselldf),0);

        IF l_dblamount>0 THEN
            --Set txnum
            plog.debug(pkgctx, 'Loop for account:' || rec.AFACCTNO || ' ngay' || to_char(rec.cleardate));
            SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

            --Set cac field giao dich
            --03   ACCTNO       C
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;
            --05    ORGORDERID  C
            l_txmsg.txfields ('05').defname   := 'ORGORDERID';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := rec.ORGORDERID;
             --07   ADVAMT          N
            l_txmsg.txfields ('07').defname   := 'ADVAMT';
            l_txmsg.txfields ('07').TYPE      := 'N';
            l_txmsg.txfields ('07').VALUE     := round(l_dbladvamt,0);
            --08    ORDATE      C
            l_txmsg.txfields ('08').defname   := 'ORDATE';
            l_txmsg.txfields ('08').TYPE      := 'C';
            l_txmsg.txfields ('08').VALUE     := to_char(rec.CLEARDATE,'DD/MM/RRRR');
            --09    DUEDATE      C
            l_txmsg.txfields ('09').defname   := 'DUEDATE';
            l_txmsg.txfields ('09').TYPE      := 'C';
            l_txmsg.txfields ('09').VALUE     := to_char(rec.TXDATE,'DD/MM/RRRR');
            --10    AMT         N
            l_txmsg.txfields ('10').defname   := 'AMT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := round(l_dblamount,0);
            --11    FEEAMT      N
            l_txmsg.txfields ('11').defname   := 'FEEAMT';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := round(l_dblfee,0);

            --12    INTRATE     N
            l_txmsg.txfields ('12').defname   := 'INTRATE';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := rec.FEERATE;
            --13    DAYS        N
            l_txmsg.txfields ('13').defname   := 'DAYS';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := rec.DAYS;
            --15    ODAMT       N
            l_txmsg.txfields ('15').defname   := 'ODAMT';
            l_txmsg.txfields ('15').TYPE      := 'N';
            l_txmsg.txfields ('15').VALUE     := 0;
            --16    MINBAL      N
            l_txmsg.txfields ('16').defname   := 'MINBAL';
            l_txmsg.txfields ('16').TYPE      := 'N';
            l_txmsg.txfields ('16').VALUE     := round(rec.MINBAL,0);
            --17  ALLPAID     N
            l_txmsg.txfields ('17').defname   := 'ALLPAID';
            l_txmsg.txfields ('17').TYPE      := 'N';
            l_txmsg.txfields ('17').VALUE     := 0;
            --18  PRINTPAID   N
            l_txmsg.txfields ('18').defname   := 'PRINTPAID';
            l_txmsg.txfields ('18').TYPE      := 'N';
            l_txmsg.txfields ('18').VALUE     := 0;
            --19  INTPAID     N
            l_txmsg.txfields ('19').defname   := 'INTPAID';
            l_txmsg.txfields ('19').TYPE      := 'N';
            l_txmsg.txfields ('19').VALUE     := 0;
            --21  RLSDATE     C
            l_txmsg.txfields ('21').defname   := 'RLSDATE';
            l_txmsg.txfields ('21').TYPE      := 'C';
            l_txmsg.txfields ('21').VALUE     := v_strCURRDATE;
            --22  DEBTAMT     N
            l_txmsg.txfields ('22').defname   := 'DEBTAMT';
            l_txmsg.txfields ('22').TYPE      := 'N';
            l_txmsg.txfields ('22').VALUE     := 0;
            --23  CASHAMT     N
            l_txmsg.txfields ('23').defname   := 'CASHAMT';
            l_txmsg.txfields ('23').TYPE      := 'N';
            l_txmsg.txfields ('23').VALUE     := 0;
            --25  PAIDDEBTAMT N
            l_txmsg.txfields ('25').defname   := 'PAIDDEBTAMT';
            l_txmsg.txfields ('25').TYPE      := 'N';
            l_txmsg.txfields ('25').VALUE     := 0;
            --26  MAXADVAMT   N
            l_txmsg.txfields ('26').defname   := 'MAXADVAMT';
            l_txmsg.txfields ('26').TYPE      := 'N';
            l_txmsg.txfields ('26').VALUE     := round(rec.ADVAMT,0);
            --20    MAXAMT      N
            l_txmsg.txfields ('20').defname   := 'MAXAMT';
            l_txmsg.txfields ('20').TYPE      := 'N';
            l_txmsg.txfields ('20').VALUE     := round(rec.MAXDEPOAMT,0);
            --30    DESC        C
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := rec.DES;
            --40    3600        C
            l_txmsg.txfields ('40').defname   := '3600';
            l_txmsg.txfields ('40').TYPE      := 'C';
            l_txmsg.txfields ('40').VALUE     := 36000;
            --41    ZERO        C
            l_txmsg.txfields ('41').defname   := 'ZERO';
            l_txmsg.txfields ('41').TYPE      := 'C';
            l_txmsg.txfields ('41').VALUE     := 0;
            --90    CUSTNAME    C
            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;
            --91    ADDRESS     C
            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;
            --92    LICENSE     C
            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

            BEGIN
                IF txpks_#1143.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 1143: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;

        END IF;

    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DFAutoAdvance');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on release pr_DFAutoAdvance');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.debug(pkgctx,'pr_DFAutoAdvance: ' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_DFAutoAdvance');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DFAutoAdvance;



FUNCTION fn_cimastcidfpofeeacr(strACCTNO IN varchar2, strTXDATE IN DATE, dblAMT IN NUMBER)
  RETURN  number
  IS
  v_strCURRDATE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_cimastcidfpofeeacr');
    plog.debug (pkgctx, '<<BEGIN OF fn_cimastcidfpofeeacr');

    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    select round(mst.cidepofee,4) into v_Result
    from
      (
          select af.acctno,ic.ICFLAT,
          (dblAMT*ic.ICFLAT*(v_strCURRDATE-TO_DATE(strTXDATE,'DD/MM/YYYY'))/30) cidepofee
          from cfmast cf, afmast af,
               (
                       SELECT actype, ICFLAT FROM ICCFTYPEDEF WHERE EVENTCODE='FEEDEPOSITSE'
                ) ic, cimast ci
          where cf.custid = af.custid
              and cf.custatcom='Y'
              and af.status not in ('N','C')
              and ci.afacctno = af.acctno
              and ci.actype = ic.actype
             and af.acctno=strACCTNO
      ) mst
      ;

    plog.debug (pkgctx, '<<END OF fn_cimastcidfpofeeacr');
    plog.setendsection (pkgctx, 'fn_cimastcidfpofeeacr');
    RETURN v_result;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_cimastcidfpofeeacr');
      RETURN 0;
END fn_CIMastcidfPOfeeacr;

FUNCTION fn_CIDateFeeacr(strACCTNO IN varchar2, strNumDATE IN  NUMBER)
  RETURN  number
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_CIDateFeeacr');
    plog.debug (pkgctx, '<<BEGIN OF fn_CIDateFeeacr');

    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';

    SELECT SBDATE into v_strDATEFEE
    FROM (
          SELECT ROWNUM DAY, SBDATE
          FROM
            (
                 SELECT * FROM SBCLDR
                 WHERE CLDRTYPE='000'
                       AND SBDATE>=v_strCURRDATE
                       AND SBDATE < v_strCURRDATE+15
                       AND HOLIDAY='N'
                 ORDER BY SBDATE
            ) CLDR
          ) RL
    WHERE DAY=strNumDATE+1;

      select round(mst.cidepofee,4)  into v_Result
      from
      (
        select af.acctno, sum((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw)*ic.ICFLAT*(TO_DATE(v_strDATEFEE,'DD/MM/YYYY')-TO_DATE(v_strCURRDATE,'DD/MM/YYYY'))/30) cidepofee
        from cfmast cf, afmast af,  semast se, sbsecurities sb,
             (
                     SELECT actype, ICFLAT FROM ICCFTYPEDEF WHERE EVENTCODE='FEEDEPOSITSE' AND modcode ='CI'
              ) ic, cimast ci
        where cf.custid = af.custid and af.acctno = se.afacctno
            and se.codeid = sb.codeid
            and sb.sectype in ('001','002','003','006','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
            and sb.tradeplace in ('001','002','005')
            and cf.custatcom='Y'
            and af.status not in ('N','C')
            and ci.afacctno = af.acctno
            and ci.actype = ic.actype
            and af.acctno=strACCTNO
        group by af.acctno
        having sum(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw) >0
      ) mst
      ;

    plog.debug (pkgctx, '<<END OF fn_CIDateFeeacr');
    plog.setendsection (pkgctx, 'fn_CIDateFeeacr');
    RETURN v_result;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CIDateFeeacr');
      RETURN 0;
END fn_CIDateFeeacr;



PROCEDURE pr_CalBackdateFeeAmt(p_backdate IN VARCHAR2, p_afacctno in varchar2, p_amt in number, p_err_code  OUT varchar2)
  IS
    v_strCURRDATE DATE;
    v_Result  number(20);
    v_errcode NUMBER;
    l_err_param varchar2(300);
    v_icrate number;
    v_sumintamt number;

BEGIN
    plog.setbeginsection (pkgctx, 'pr_CalBackdateFeeAmt');
    plog.debug (pkgctx, '<<BEGIN OF pr_CalBackdateFeeAmt');

    p_err_code:= systemnums.C_SUCCESS;

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';

    -- Tru lai~ sai ra khoi truong CRINTACR
    select sum(intamt) into v_sumintamt from ciinttran where acctno = p_afacctno and frdate between to_date(p_backdate,'dd/mm/rrrr') and getcurrdate;

    update cimast set crintacr=crintacr - nvl(v_sumintamt,0) where acctno = p_afacctno;


    -- Lay lai~ hien tai danh cho dong lich lai~ khong co' trong CIINTTRAN
    select icdef.icrate into v_icrate
    from cimast mst,citype typ,iccftypedef icdef--, CFMAST CF
    where mst.actype=typ.actype and mst.status <>'C' and mst.status <>'N'
        and typ.actype=icdef.actype
        and icdef.modcode ='CI' and eventcode='CRINTACR'
        and icdef.ruletype='F' and icdef.deltd='N'
        --AND CF.CUSTID=MST.CUSTID AND CF.CUSTATCOM='Y'
        and mst.acctno= p_afacctno;


    -- Insert cac dong tinh lai~ vao bang tam
    INSERT INTO ciinttrana
    (AUTOID,ACCTNO,INTTYPE,FRDATE,TODATE,ICRULE,IRRATE,INTBAL,INTAMT)

        select seq_ciinttrana.NEXTVAL, p_afacctno acctno, 'CR' inttype, a.frdate, a.todate, 'F' icrule, nvl(ci.irrate,v_icrate) irrate, nvl(ci.intbal,0) + p_amt intbal,
         round((nvl(ci.intbal,0) + p_amt)*nvl(ci.irrate,v_icrate)/100/360*(a.TODATE-a.FRDATE),4) intamt
          from
        (
            select sb.sbdate frdate , getduedate (sb.sbdate, 'B','000',1) todate from sbcldr sb
            where sb.cldrtype = '000' and holiday <> 'Y' and sb.sbdate between to_date(p_backdate,'dd/mm/rrrr') and getcurrdate -1
        ) a left join ciinttran ci
        on a.frdate=ci.frdate and ci.acctno = p_afacctno
        where nvl(ci.intbal,0) + p_amt > 0
        ;

    -- Xoa dong tinh lai sai
    delete from ciinttran where acctno = p_afacctno and frdate between to_date(p_backdate,'dd/mm/rrrr') and getcurrdate;

    -- Insert lai cac dong tinh lai vao CIINTTRAN
    INSERT INTO ciinttran
    (AUTOID,ACCTNO,INTTYPE,FRDATE,TODATE,ICRULE,IRRATE,INTBAL,INTAMT)
    select seq_ciinttran.NEXTVAL, acctno, inttype , frdate, todate, icrule,irrate,intbal, intamt from
    (
     select * from ciinttrana where  acctno = p_afacctno and frdate between to_date(p_backdate,'dd/mm/rrrr') and getcurrdate order by frdate

    )
    ;

    delete from ciinttrana where  acctno = p_afacctno;

    commit;
    plog.debug (pkgctx, '<<END OF pr_CalBackdateFeeAmt');
    plog.setendsection (pkgctx, 'pr_CalBackdateFeeAmt');

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CalBackdateFeeAmt');
END pr_CalBackdateFeeAmt;



PROCEDURE pr_CRBTXREQ1104(p_refcode IN varchar,p_err_code  OUT varchar2)
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  v_POTXNUM varchar2(20);
  v_strAutoID varchar2(100);
  v_strBankId varchar2(5);
  v_strBankGL varchar2(20);
  v_strBankName varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CRBTXREQ1104');
    plog.debug (pkgctx, '<<BEGIN OF pr_CRBTXREQ1104');

    p_err_code:= systemnums.C_SUCCESS;

    --GET TDMAST ATRIBUTES

    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';

    for rec in (
           select CR.reqid,cr.txdate, cf.custodycd, cr.afacctno, cf.fullname, cf.address, cf.idcode, cf.iddate,
              fn_gettcdtdesbankacc(substr(cr.AFACCTNO,1,4)) BANKACC,
              --fn_gettcdtdesbankname(substr(cr.AFACCTNO,1,4)) BANKNAME,
              --fn_gettcdtdesbankname(substr(cr.AFACCTNO,1,4)) BANKACCNAME,
              --fn_gettcdtdesbankacc(substr(cr.AFACCTNO,1,4)) GLMAST,
              --NVL(ci.BANKID,'') BANKID,
              cr.bankacct RECACCTNO,  CR.dirbankcode recbankcode, cr.dirbankname recbankname,
              cr.dirbankcity recbankcity, cr.diraccname recacctname, '' RECEIVLICENSE,
              '' RECEIVIDDATE, ci.feetype, ci.amt, ci.vat, ci.feeamt, ci.txnum,
              getcurrdate POTXDATE, '001' POTYPE, CR.NOTES
          from crbtxreq cr, cfmast cf, afmast af, ciremittance ci
          where cf.custid = af.custid and cr.afacctno = af.acctno
              and cr.refcode = to_char(ci.txdate,'dd/mm/rrrr')||ci.txnum
              and cr.status = 'W' AND CR.OBJNAME in ('1101','1111','1154') AND CR.VIA='DIR'
              and exists (Select shortname From banknostro Where bankacctno = fn_gettcdtdesbankacc(substr(cr.AFACCTNO,1,4)))


             -- and cr.refcode = p_refcode
    )
    loop

        plog.debug (pkgctx, '<<BEGIN OF pr_CRBTXREQ1104_ IN LOOP');

        SELECT shortname, glaccount, fullname into v_strBankId, v_strBankGL, v_strBankName FROM banknostro Where bankacctno = rec.BANKACC;

        UPDATE crbtxreq SET STATUS = 'C' WHERE REQID = REC.REQID;

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='1104';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(REC.afacctno,1,4);


      --Set cac field giao dich

       --06  TXDATE          D
        l_txmsg.txfields ('06').defname   := 'TXDATE';
        l_txmsg.txfields ('06').TYPE      := 'D';
        l_txmsg.txfields ('06').VALUE     := rec.TXDATE;

        --04  CUSTODYCD       C
        l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.CUSTODYCD;

        --03  ACCTNO          C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90  CUSTNAME        C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.fullname;

        --91  ADDRESS         C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92  LICENSE         C
        l_txmsg.txfields ('92').defname   := 'ADDRESS';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.IDCODE;

        --67  IDDATE          C
        l_txmsg.txfields ('67').defname   := 'IDDATE';
        l_txmsg.txfields ('67').TYPE      := 'C';
        l_txmsg.txfields ('67').VALUE     := rec.IDDATE;

        --08  BANKACC         C
        l_txmsg.txfields ('08').defname   := 'IDDATE';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.BANKACC;

        --85  BANKNAME        C
        l_txmsg.txfields ('85').defname   := 'BANKNAME';
        l_txmsg.txfields ('85').TYPE      := 'C';
        l_txmsg.txfields ('85').VALUE     := v_strBankName;
        --l_txmsg.txfields ('85').VALUE     := rec.BANKNAME;

        --86  BANKACCNAME     C
        l_txmsg.txfields ('86').defname   := 'BANKACCNAME';
        l_txmsg.txfields ('86').TYPE      := 'C';
        l_txmsg.txfields ('86').VALUE     := v_strBankName;
        --l_txmsg.txfields ('86').VALUE     := rec.BANKACCNAME;

        --15  GLMAST          C
        l_txmsg.txfields ('15').defname   := 'GLMAST';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := v_strBankGL;
        --l_txmsg.txfields ('15').VALUE     := rec.GLMAST;

        --05  BANKID          C
        l_txmsg.txfields ('05').defname   := 'BANKID';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := v_strBankId;
        --l_txmsg.txfields ('05').VALUE     := rec.BANKID;

        --80  BENEFBANK       C
        l_txmsg.txfields ('80').defname   := 'BENEFBANK';
        l_txmsg.txfields ('80').TYPE      := 'C';
        l_txmsg.txfields ('80').VALUE     := rec.recbankname;

        --82  BENEFCUSTNAME   C
        l_txmsg.txfields ('82').defname   := 'BENEFBANK';
        l_txmsg.txfields ('82').TYPE      := 'C';
        l_txmsg.txfields ('82').VALUE     := rec.recacctname;

        --83  RECEIVLICENSE   C   S? gi?y t? KH th? hu?ng
        l_txmsg.txfields ('83').defname   := 'RECEIVLICENSE';
        l_txmsg.txfields ('83').TYPE      := 'C';
        l_txmsg.txfields ('83').VALUE     := rec.RECEIVLICENSE;

        --95  RECEIVIDDATE    C
        l_txmsg.txfields ('95').defname   := 'RECEIVIDDATE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.RECEIVIDDATE;

        --81  BENEFACCT       C
        l_txmsg.txfields ('81').defname   := 'BENEFACCT';
        l_txmsg.txfields ('81').TYPE      := 'C';
        l_txmsg.txfields ('81').VALUE     := rec.RECACCTNO;

        --32  CITYBANK        C
        l_txmsg.txfields ('32').defname   := 'CITYBANK';
        l_txmsg.txfields ('32').TYPE      := 'C';
        l_txmsg.txfields ('32').VALUE     := rec.recbankcity;

        --33  CITYEF          C
        l_txmsg.txfields ('33').defname   := 'CITYBANK';
        l_txmsg.txfields ('33').TYPE      := 'C';
        l_txmsg.txfields ('33').VALUE     := rec.recbankcity;

        --09  IORO            C
        l_txmsg.txfields ('09').defname   := 'IORO';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.feetype;

        --10  AMT             N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.amt;

        --12  TRFAMT          N
        l_txmsg.txfields ('12').defname   := 'TRFAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.amt + rec.feeamt;

        --11  FEEAMT          N
        l_txmsg.txfields ('11').defname   := 'FEEAMT';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.FEEAMT;

        --13  VATAMT          N
        l_txmsg.txfields ('13').defname   := 'VATAMT';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.vat;

        --07  TXNUM           C
        l_txmsg.txfields ('07').defname   := 'TXNUM';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.TXNUM;

        --98  POTXDATE        D
        l_txmsg.txfields ('98').defname   := 'POTXDATE';
        l_txmsg.txfields ('98').TYPE      := 'D';
        l_txmsg.txfields ('98').VALUE     := v_strCURRDATE;

        --99  POTXNUM         C
       SELECT NVL(MAX(ODR)+1,1) INTO v_strAutoID  FROM
                   (SELECT ROWNUM ODR, INVACCT
                   FROM (SELECT TXNUM INVACCT FROM POMAST WHERE BRID = substr(REC.afacctno,1,4) ORDER BY TXNUM) DAT
                   ) INVTAB;

        v_POTXNUM := substr(REC.afacctno,1,4) || LPAD(v_strAutoID,6,'0');

        l_txmsg.txfields ('99').defname   := 'POTXNUM';
        l_txmsg.txfields ('99').TYPE      := 'C';
        l_txmsg.txfields ('99').VALUE     := v_POTXNUM;

        --17  POTYPE          C
        l_txmsg.txfields ('17').defname   := 'POTYPE';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := rec.POTYPE;

        --30  DESC            C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.NOTES;

        --96  RECEIVIDPLACE   C
        l_txmsg.txfields ('96').defname   := 'RECEIVIDPLACE';
        l_txmsg.txfields ('96').TYPE      := 'C';
        l_txmsg.txfields ('96').VALUE     := '';

        BEGIN
            IF txpks_#1104.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1104: ' || v_errcode
               );
               p_err_code:=v_errcode;
               ROLLBACK;
               RETURN;
            END IF;
        END;


    end loop;



    commit;
    plog.debug (pkgctx, '<<END OF pr_CRBTXREQ1104');
    plog.setendsection (pkgctx, 'pr_CRBTXREQ1104');

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CRBTXREQ1104');
END pr_CRBTXREQ1104;


/*
PROCEDURE pr_CALCI1110( p_err_code  OUT varchar2)
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  v_POTXNUM varchar2(20);
  v_strAutoID varchar2(100);
  l_OrgDesc varchar2(100);
  l_EN_OrgDesc varchar2(100);

BEGIN
    plog.setbeginsection (pkgctx, 'pr_CALCI1110');
    plog.debug (pkgctx, '<<BEGIN OF pr_CALCI1110');
    p_err_code:= systemnums.C_SUCCESS;
    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';


    for rec in (
         SELECT CF.CUSTODYCD,CF.CUSTID,AF.Acctno afacctno,CF.FULLNAME,CF.ADDRESS,
        TRF.AMT,TRF.FEECD,TRF.TXDATE,trf.autoid,trf.bankacctno,
        (TO_DATE(SYS1.VARVALUE,'DD/MM/RRRR')-TRF.TXDATE)*FN_GETFEEAMT2669(TRF.FEECD,TRF.AMT) INTAMT,
        a1.cdcontent FORP,decode(fee.forp,'P',fee.feerate,fee.feeamt)feeamt, decode ( cf.vat,'Y', FEE.VATRATE,'N',0) VATRATE,

       DECODE(cf.vat,'Y', ROUND((TO_DATE(SYS1.VARVALUE,'DD/MM/RRRR')-TRF.TXDATE)*FN_GETFEEAMT2669(TRF.FEECD,TRF.AMT)*FEE.VATRATE/100),'N',0)  VATAMT
        FROM CFMAST CF, AFMAST af,CITRFEOD TRF,(SELECT VARVALUE FROm SYSVAR WHERE VARNAME='CURRDATE') SYS1,
        feemaster fee,allcode a1
        WHERE CF.CUSTID=AF.CUSTID AND AF.ACCTNO=TRF.AFACCTNO
        AND TRF.DELTD <> 'Y' AND TRF.STATUS='P'
        AND TRF.TXDATE <>TO_DATE(SYS1.VARVALUE,'DD/MM/RRRR')
        and trf.feecd=fee.feecd
        and a1.cdtype='SA' and a1.cdname='FORP' and a1.cdval=fee.forp
    )
    loop

  SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='1110';

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='1110';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(REC.afacctno,1,4);


      --Set cac field giao dich

--      01  AUTOID
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.AUTOID;
     --88  CUSTODYCD   C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

     --03  ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

           --90  CUSTNAME    C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --65  ADDRESS     C
        l_txmsg.txfields ('65').defname   := 'ADDRESS';
        l_txmsg.txfields ('65').TYPE      := 'C';
        l_txmsg.txfields ('65').VALUE     := rec.ADDRESS;


        --66  FEECD     C
        l_txmsg.txfields ('66').defname   := 'ADDRESS';
        l_txmsg.txfields ('66').TYPE      := 'C';
        l_txmsg.txfields ('66').VALUE     := rec.FEECD;

        --11  INTAMT         N
        l_txmsg.txfields ('11').defname   := 'INTAMT';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.INTAMT;

        --10  AMT         N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.AMT;

        --12  VATAMT         N
        l_txmsg.txfields ('12').defname   := 'VATAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.VATAMT;

        --81  BANKACCTNO     C
        l_txmsg.txfields ('81').defname   := 'BANKACCTNO';
        l_txmsg.txfields ('81').TYPE      := 'C';
        l_txmsg.txfields ('81').VALUE     := rec.BANKACCTNO;

        --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := l_OrgDesc;



        BEGIN
            IF txpks_#1110.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1110: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;
               RETURN;
            END IF;
        END;

    end loop;




EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CALCI1110');
END pr_CALCI1110 ;
*/
PROCEDURE pr_CALCI1192( p_err_code  OUT varchar2)
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  v_POTXNUM varchar2(20);
  v_strAutoID varchar2(100);
  l_OrgDesc varchar2(100);
  l_EN_OrgDesc varchar2(100);

BEGIN
    plog.setbeginsection (pkgctx, 'pr_CALCI1192');
    plog.debug (pkgctx, '<<BEGIN OF pr_CALCI1192');
    p_err_code:= systemnums.C_SUCCESS;
    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';


    for rec in (
        SELECT AF.ACCTNO AFACCTNO ,case when exectype ='NB' THEN '001' ELSE '002' END TRANTYPE,CF.FULLNAME ,SUM (OD.feeacr) feeacr, SUM(taxsellamt)taxsellamt
        FROM ODMAST OD,AFMAST AF,CFMAST CF
        WHERE TXDATE =GETCURRDATE ()
        AND OD.afacctno = AF.acctno
        AND AF.custid = CF.custid
        AND CF.custatcom ='N'
        AND od.deltd <>'Y'
        GROUP BY ACCTNO ,exectype,CF.FULLNAME
        having sum ((OD.feeacr))>0
    )
    loop

  SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='1192';

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='1192';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(REC.afacctno,1,4);


      --Set cac field giao dich

     --03  ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

           --95  FULLNAME    C
        l_txmsg.txfields ('95').defname   := 'CUSTNAME';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.FULLNAME;

        --09  TRANTYPE     C
        l_txmsg.txfields ('09').defname   := 'TRANTYPE';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := rec.TRANTYPE;

        --10  feeacr         N
        l_txmsg.txfields ('10').defname   := 'feeacr';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.feeacr;

        --11  taxsellamt   N
        l_txmsg.txfields ('11').defname   := 'taxsellamt';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.taxsellamt;

        --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := l_OrgDesc;

        BEGIN
            IF txpks_#1192.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1192: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;
               RETURN;
            END IF;
        END;

    end loop;




EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CALCI1192');
END pr_CALCI1192 ;

PROCEDURE pr_CRBBANKREQ1141(p_AUTOID IN varchar,p_err_code  OUT varchar2)
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  v_POTXNUM varchar2(20);
  v_strAutoID varchar2(100);
  v_strBankId varchar2(5);
  v_strBankGL varchar2(20);
  v_strBankName varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CRBBANKREQ1141');
    plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1141');
    p_err_code:= systemnums.C_SUCCESS;
    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';


FOR recCRB in (select * from crbbankrequest where status = 'N' )
loop

    plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1141_ IN LOOP recCRB');

    update crbbankrequest set status = 'E', ERRORDESC = 'Sai thong tin khach hang thu huong'
        where autoid = recCRB.AUTOID
            And (KEYACCT1 IS NULL OR KEYACCT1 = ''
                OR Not Exists (Select custodycd From cfmast where custodycd = recCRB.KEYACCT1
                    And UPPER(fn_convert_to_vn(fullname)) = UPPER(recCRB.ACCNAME))
                OR Not Exists (Select shortname from banknostro where bankacctno = recCRB.DESBANKACCOUNT));

    Update crbbankrequest set status = 'E', ERRORDESC = 'Ton tai yeu cau nop tien bi trung so tien'
        where autoid = recCRB.AUTOID
            And Exists (Select txnum From tllog where msgacct in (Select af.acctno from afmast af, cfmast cf where af.custid = cf.custid and cf.custodycd = recCRB.Keyacct1)
                And msgamt = recCRB.amount and tltxcd = '1141');

    for rec in (
            select * from (
                SELECT  CASE WHEN mr.mrtype ='N' THEN 1 else 0 end ord,
                mr.mrtype, cr.autoid, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME, CF.MNEMONIC,
                    CF.ADDRESS, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.BANKCODE BANKID,
                    --fn_gettcdtdesbankacc(substr(AF.ACCTNO,1,4)) BANKACC,
                    CR.desbankaccount BANKACC,
                    --fn_gettcdtdesbankacc(substr(AF.ACCTNO,1,4)) GLMAST,
                    --fn_gettcdtdesbankname(substr(AF.ACCTNO,1,4)) BANKNAME,
                    --fn_gettcdtdesbankname(substr(AF.ACCTNO,1,4)) BANKACCNAME,
                    CR.AMOUNT, CR.TRNREF REFNUM, CR.TRANSACTIONDESCRIPTION,
                    TO_DATE(CR.TRN_DT,'DD/MM/RRRR') TRN_DT
                FROM crbbankrequest CR, CFMAST CF, AFMAST AF, AFTYPE AFT, MRTYPE MR
                WHERE AF.ACTYPE = AFT.ACTYPE AND AFT.MRTYPE = MR.ACTYPE
                    AND CR.AUTOID = recCRB.AUTOID
                    AND CR.KEYACCT1 = CF.CUSTODYCD
                    AND CF.CUSTID = AF.CUSTID
                    AND AF.STATUS ='A'
                    AND CR.status = 'N'
                 --  AND AFT.MNEMONIC <> 'T3'
                    AND AF.COREBANK <> 'Y'
                    AND exists (Select shortname From banknostro Where bankacctno = fn_gettcdtdesbankacc(substr(AF.ACCTNO,1,4)))
                ORDER BY ord
            ) where ord>0
    )
    loop

        plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1141_ IN LOOP rec');

        /*if not (UPPER(rec.CUSTODYCD) = UPPER(REPLACE(recCRB.KEYACCT1,'K','C')) and UPPER(rec.MNEMONIC) = UPPER(recCRB.KEYACCT2)) then
            update crbbankrequest set status = 'E', ERRORDESC = 'Sai thong tin khach hang thu huong' where autoid = recCRB.AUTOID;
            exit;
        end if;*/

        SELECT shortname, glaccount, fullname into v_strBankId, v_strBankGL, v_strBankName FROM banknostro Where bankacctno = rec.BANKACC;

        update crbbankrequest set status = 'W' where autoid = recCRB.AUTOID;

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='1141';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(REC.afacctno,1,4);


      --Set cac field giao dich

        --82  CUSTODYCD   C
        l_txmsg.txfields ('82').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('82').TYPE      := 'C';
        l_txmsg.txfields ('82').VALUE     := rec.CUSTODYCD;

        --00  AUTOID      C
        l_txmsg.txfields ('00').defname   := 'AUTOID';
        l_txmsg.txfields ('00').TYPE      := 'C';
        l_txmsg.txfields ('00').VALUE     := rec.AUTOID;

        --03  ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90  CUSTNAME    C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --91  ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92  LICENSE     C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.IDCODE;

        --93  IDDATE      C
        l_txmsg.txfields ('93').defname   := 'IDDATE';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := rec.IDDATE;

        --94  IDPLACE     C
        l_txmsg.txfields ('94').defname   := 'IDPLACE';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := rec.IDPLACE;

        --02  BANKID      C
        l_txmsg.txfields ('02').defname   := 'BANKID';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := v_strBankId;
        --l_txmsg.txfields ('02').VALUE     := rec.BANKID;

        --05  BANKACCTNO  C
        l_txmsg.txfields ('05').defname   := 'BANKACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.BANKACC;

        --06  GLMAST      C
        l_txmsg.txfields ('06').defname   := 'GLMAST';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := v_strBankGL;
        --l_txmsg.txfields ('06').VALUE     := rec.GLMAST;

        --10  AMT         N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.AMOUNT;

        --31  REFNUM      C
        l_txmsg.txfields ('31').defname   := 'REFNUM';
        l_txmsg.txfields ('31').TYPE      := 'C';
        l_txmsg.txfields ('31').VALUE     := rec.REFNUM;

        --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.TRANSACTIONDESCRIPTION;

        l_txmsg.txfields ('32').defname   := 'REFDATE';
        l_txmsg.txfields ('32').TYPE      := 'D';
        l_txmsg.txfields ('32').VALUE     := rec.TRN_DT;

        plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1141_ CAll 1141 ' || recCRB.AUTOID);

        BEGIN
            IF txpks_#1141.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.error (pkgctx,
                           'got error 1141: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;
               RETURN;
            END IF;
        END;

        EXIT;

    end loop;

end loop;


    commit;
    plog.debug (pkgctx, '<<END OF pr_CRBBANKREQ1141');
    plog.setendsection (pkgctx, 'pr_CRBBANKREQ1141');

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_CRBBANKREQ1141');
END pr_CRBBANKREQ1141;

PROCEDURE pr_CRBBANKREQ1196(p_AUTOID IN varchar,p_err_code  OUT varchar2)
  IS
  v_strCURRDATE DATE;
  v_strDATEFEE DATE;
  v_strCOMPANYCD varchar2(10);
  v_Result  number(20);
  l_txmsg               tx.msg_rectype;
  v_errcode NUMBER;
  l_err_param varchar2(300);
  v_POTXNUM varchar2(20);
  v_strAutoID varchar2(100);
  v_strBankId varchar2(5);
  v_strBankGL varchar2(20);
  v_strBankName varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CRBBANKREQ1196');
    plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1196');
    p_err_code:= systemnums.C_SUCCESS;
    --GET TDMAST ATRIBUTES
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';
    SELECT VARVALUE || '%' into v_strCOMPANYCD FROM SYSVAR  WHERE VARNAME='COMPANYCD';

    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into v_strCURRDATE FROM SYSVAR  WHERE VARNAME='CURRDATE';


FOR recCRB in (select * from crbbankrequest where status = 'L' )
loop

    plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1196 IN LOOP recCRB');

    update crbbankrequest set status = 'B', ERRORDESC = 'Sai thong tin khach hang thu huong'
        where autoid = recCRB.AUTOID And Status = 'L'
            And (KEYACCT1 IS NULL OR KEYACCT1 = ''
                OR Not Exists (Select custodycd From cfmast where custodycd = recCRB.KEYACCT1
                    And UPPER(fn_convert_to_vn(fullname)) = UPPER(recCRB.ACCNAME))
                OR Not Exists (Select shortname from banknostro where bankacctno = recCRB.DESBANKACCOUNT));

    for rec in (
            select * from (
                SELECT  CASE WHEN mr.mrtype ='N' THEN 1 else 0 end ord,
                mr.mrtype, cr.autoid, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME, CF.MNEMONIC, CF.ADDRESS, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.BANKCODE BANKID,
                    --fn_gettcdtdesbankacc(substr(AF.ACCTNO,1,4)) BANKACC,
                    CR.desbankaccount BANKACC,
                    --fn_gettcdtdesbankacc(substr(AF.ACCTNO,1,4)) GLMAST,
                    --fn_gettcdtdesbankname(substr(AF.ACCTNO,1,4)) BANKNAME,
                    --fn_gettcdtdesbankname(substr(AF.ACCTNO,1,4)) BANKACCNAME,
                    CR.AMOUNT, CR.TRNREF REFNUM, CR.TRANSACTIONDESCRIPTION,
                    CR.DESBANKACCOUNT, TO_DATE(CR.TRN_DT,'DD/MM/RRRR') TRN_DT
                FROM crbbankrequest CR, CFMAST CF, AFMAST AF, AFTYPE AFT, MRTYPE MR
                WHERE AF.ACTYPE = AFT.ACTYPE AND AFT.MRTYPE = MR.ACTYPE
                    AND CR.AUTOID = recCRB.AUTOID
                    AND CR.KEYACCT1 = CF.CUSTODYCD
                    AND CF.CUSTID = AF.CUSTID
                    AND AF.STATUS ='A'
                    AND CR.status = 'L'
                 --  AND AFT.MNEMONIC <> 'T3'
                    AND AF.COREBANK <> 'Y'
                    AND EXISTS (Select shortname From banknostro Where bankacctno = fn_gettcdtdesbankacc(substr(AF.ACCTNO,1,4)))
                ORDER BY ord
            ) where ord>0
    )
    loop

        plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1196 IN LOOP rec');

        /*if not (UPPER(rec.CUSTODYCD) = UPPER(REPLACE(recCRB.KEYACCT1,'K','C')) and UPPER(rec.MNEMONIC) = UPPER(recCRB.KEYACCT2)) then
            update crbbankrequest set status = 'E', ERRORDESC = 'Sai thong tin khach hang thu huong' where autoid = recCRB.AUTOID;
            exit;
        end if;*/

        SELECT shortname, glaccount, fullname into v_strBankId, v_strBankGL, v_strBankName FROM banknostro Where bankacctno = rec.BANKACC;

        update crbbankrequest set status = 'O' where autoid = recCRB.AUTOID;

        SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='1196';

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(REC.afacctno,1,4);


      --Set cac field giao dich

        --82  CUSTODYCD   C
        l_txmsg.txfields ('82').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('82').TYPE      := 'C';
        l_txmsg.txfields ('82').VALUE     := rec.CUSTODYCD;

        --00  AUTOID      C
        l_txmsg.txfields ('00').defname   := 'AUTOID';
        l_txmsg.txfields ('00').TYPE      := 'C';
        l_txmsg.txfields ('00').VALUE     := rec.AUTOID;

        --03  ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90  CUSTNAME    C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --91  ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92  LICENSE     C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.IDCODE;

        --93  IDDATE      C
        l_txmsg.txfields ('93').defname   := 'IDDATE';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := rec.IDDATE;

        --94  IDPLACE     C
        l_txmsg.txfields ('94').defname   := 'IDPLACE';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := rec.IDPLACE;

        --02  BANKID      C
        l_txmsg.txfields ('02').defname   := 'BANKID';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := v_strBankId;
        --l_txmsg.txfields ('02').VALUE     := rec.BANKID;

        --05  BANKACCTNO  C
        l_txmsg.txfields ('05').defname   := 'BANKACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.BANKACC;
        --l_txmsg.txfields ('05').VALUE     := rec.DESBANKACCOUNT;

        --06  GLMAST      C
        l_txmsg.txfields ('06').defname   := 'GLMAST';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := v_strBankGL;
        --l_txmsg.txfields ('06').VALUE     := rec.GLMAST;

        --10  AMT         N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.AMOUNT;

        --31  REFNUM      C
        l_txmsg.txfields ('31').defname   := 'REFNUM';
        l_txmsg.txfields ('31').TYPE      := 'C';
        l_txmsg.txfields ('31').VALUE     := rec.REFNUM;

        l_txmsg.txfields ('32').defname   := 'REFDATE';
        l_txmsg.txfields ('32').TYPE      := 'D';
        l_txmsg.txfields ('32').VALUE     := rec.TRN_DT;

        --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := rec.TRANSACTIONDESCRIPTION;

        plog.debug (pkgctx, '<<BEGIN OF pr_CRBBANKREQ1196_ CAll 1196 ' || recCRB.AUTOID);

        BEGIN
            IF txpks_#1196.fn_autotxprocess (l_txmsg,
                                             v_errcode,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1196: ' || v_errcode
               );
               p_err_code:= v_errcode;
               ROLLBACK;
               RETURN;
            END IF;
        END;

        EXIT;

    end loop;

end loop;


    commit;
    plog.debug (pkgctx, '<<END OF pr_CRBBANKREQ1196');
    plog.setendsection (pkgctx, 'pr_CRBBANKREQ1196');

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CRBBANKREQ1196');
END pr_CRBBANKREQ1196;

---------------------------------fn_FeeDepositoryMaturityBackdate------------------------------------------------
FUNCTION fn_FeeDepoMaturityBackdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_afacctno VARCHAR2(10);
v_dblAMT NUMBER;
v_todate DATE;
v_frdatetemp DATE;
v_todatetemp DATE;
v_dblamttemp NUMBER;
v_dblamtacr NUMBER;
v_dateEOMtemp DATE;
v_TBALDT DATE;
v_count_days NUMBER;
V_txdate DATE;
l_txnum VARCHAR2(30);
V_seacctno VARCHAR2(20);
L_QTTY NUMBER(20,0);
--PhuongHT edit
V_TYPE VARCHAR2(10);
V_FEEAMT   NUMBER(20);
V_LOTDAY   NUMBER(20);
V_LOTVAL   NUMBER(20);
V_FORP     VARCHAR2(10);
V_Ref   VARCHAR2(20);
--end of PhuongHT
BEGIN
    plog.setbeginsection (pkgctx, 'fn_FeeDepositoryMaturityBackdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_FeeDepositoryMaturityBackdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    -- case cac truong cho cac jao dich
    if( p_txmsg.tltxcd='2246') THEN
     v_afacctno:=p_txmsg.txfields('02').VALUE;
     v_seacctno:=p_txmsg.txfields('03').VALUE;
     L_QTTY:=TO_NUMBER(p_txmsg.txfields('12').VALUE);
     ELSIF(p_txmsg.tltxcd='8879') THEN
        v_afacctno:=p_txmsg.txfields('07').VALUE;
        v_seacctno:=p_txmsg.txfields('08').VALUE;
        L_QTTY:=TO_NUMBER(p_txmsg.txfields('10').VALUE);
     ELSIF(p_txmsg.tltxcd='2205') THEN
        v_afacctno := p_txmsg.txfields('04').VALUE;
        v_seacctno := p_txmsg.txfields('03').VALUE;
        L_QTTY     := TO_NUMBER(p_txmsg.txfields('10').VALUE);
     ELSIF(p_txmsg.tltxcd='2245') THEN
        v_afacctno := p_txmsg.txfields('04').VALUE;
        v_seacctno := p_txmsg.txfields('05').VALUE;
        L_QTTY     := TO_NUMBER(p_txmsg.txfields('12').VALUE);
    ELSE
    v_afacctno:=p_txmsg.txfields('04').VALUE;
     v_seacctno:=p_txmsg.txfields('05').VALUE;
     L_QTTY:=TO_NUMBER(p_txmsg.txfields('10').VALUE);
    END IF;
    IF (p_txmsg.tltxcd='8879') THEN
       v_dblAMT:=p_txmsg.txfields('17').VALUE;
      ELSE
    v_dblAMT:=p_txmsg.txfields('15').VALUE;
    END IF;

    v_todate:= to_date (p_txmsg.txfields('32').VALUE,'DD/MM/RRRR');
    v_frdatetemp:=to_date( p_txmsg.busdate,'DD/MM/RRRR');
    v_dblamtacr:=0;

    -- khai cac bien de log vao sedepobal
    v_TBALDT:= Greatest(to_date ( p_txmsg.txfields('32').value,'DD/MM/RRRR')+1, p_txmsg.busdate);
    V_txdate:=TO_DATE(p_txmsg.txdate,'DD/MM/RRRR');
    l_txnum:=p_txmsg.txnum;
    if not v_blnREVERSAL THEN
      --CHieu  thuan giao dich
      -- select ra cac moc thu phi lk den han
      plog.debug(pkgctx,'busdate ' || to_date(p_txmsg.busdate,'DD/MM/RRRR') || ' todate '||to_date(v_todate,'DD/MM/RRRR'));
      FOR rec IN
      (SELECT to_date(sbdate,'DD/MM/RRRR') sbdate FROM sbcldr WHERE sbdate >=to_date(p_txmsg.busdate,'DD/MM/RRRR') AND sbdate<= to_date(v_todate,'DD/MM/RRRR')
      AND sbeom='Y' AND cldrtype='000' ORDER BY sbdate)
      LOOP
         plog.debug(pkgctx,'first' || rec.sbdate || ' busdate ' || to_date(p_txmsg.busdate,'DD/MM/RRRR') ||' to_Date' ||  to_date(v_todate,'DD/MM/RRRR'));
        -- lay ra ngay cuoi cung cua thang
          SELECT ADD_MONTHS(TRUNC(rec.sbdate, 'MM'), 1) -1 INTO v_dateEOMtemp FROM DUAL;
        v_todatetemp:=to_Date(v_dateEOMtemp,'DD/MM/RRRR');

        if(v_todatetemp <> v_todate) THEN
        v_dblamttemp:=round( (v_todatetemp-v_frdatetemp+1)/(v_todate-p_txmsg.busdate+1)* v_dblAMT,0);
        v_dblamtacr:=v_dblamtacr+v_dblamttemp;
        ELSE -- neu la thang backdate gan nhat: lay tong- cac thang truoc: tranh sai so
          v_dblamttemp:=round (v_dblAMT-v_dblamtacr,0);
        END IF;
        if(v_todatetemp > v_frdatetemp) then
          /*  INSERT INTO CIFEESCHD (AUTOID, AFACCTNO, FEETYPE, TXNUM, TXDATE, NMLAMT, PAIDAMT, FLOATAMT, FRDATE, TODATE, REFACCTNO, DELTD)
            VALUES (SEQ_CIFEESCHD.nextval,v_afacctno,'VSDDEP',p_txmsg.txnum,to_date(p_txmsg.txdate,'DD/MM/RRRR'),v_dblamttemp,0,0,v_frdatetemp,v_todatetemp,'','N');
            PR_LOGSEDEPOBAL(SUBSTR(v_seacctno,11,6),v_afacctno,v_todatetemp-v_frdatetemp+1,
                                   v_dblamttemp,L_QTTY ,v_frdatetemp,to_char(v_txdate)||L_TXNUM)    ;*/

        INSERT INTO CIFEESCHD (AUTOID, AFACCTNO, FEETYPE, TXNUM, TXDATE, NMLAMT, PAIDAMT, FLOATAMT, FRDATE, TODATE, REFACCTNO, DELTD)
         VALUES (SEQ_CIFEESCHD.nextval,v_afacctno,'VSDDEP',p_txmsg.txnum,to_date(p_txmsg.txdate,'DD/MM/RRRR'),0,0,0,v_frdatetemp,v_todatetemp,'','N');
            PR_LOGSEDEPOBAL(SUBSTR(v_seacctno,11,6),v_afacctno,v_todatetemp-v_frdatetemp+1,
                                   v_dblamttemp,L_QTTY ,v_frdatetemp,to_char(v_txdate)||L_TXNUM) ;

        end if;
         plog.debug(pkgctx,'insert into CIFEESCHD' || rec.sbdate );
         v_frdatetemp:=to_Date(v_todatetemp,'DD/MM/RRRR')+1;
        END LOOP;
    else
       -- xoa giao dich
       UPDATE cifeeschd SET deltd='Y'  WHERE TXNUM = p_txmsg.txnum AND TXDATE = to_date(p_txmsg.txdate,'DD/MM/RRRR');
       UPDATE sedepobal SET deltd='Y' WHERE id=to_char(V_txdate)||l_txnum ;
       UPDATE SEDEPOBAL_HIST SET deltd='Y' WHERE id=to_char(V_txdate)||l_txnum ;
    end if;
    plog.debug (pkgctx, '<<END OF fn_FeeDepositoryMaturityBackdate');
    plog.setendsection (pkgctx, 'fn_FeeDepositoryMaturityBackdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_FeeDepositoryMaturityBackdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_FeeDepoMaturityBackdate;

FUNCTION fn_FeeDepoDebit(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_count number(20,0);
v_afacctno VARCHAR2(10);
v_dblAMT NUMBER;

V_txdate DATE;
l_txnum VARCHAR2(30);
V_seacctno VARCHAR2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_FeeDepoDebit');
    plog.debug (pkgctx, '<<BEGIN OF fn_FeeDepoDebit');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    v_dblAMT:=0;
    -- case cac truong cho cac jao dich
    v_afacctno:=p_txmsg.txfields('04').VALUE;
    v_seacctno:=p_txmsg.txfields('05').VALUE;

    V_txdate:=TO_DATE(p_txmsg.txdate,'DD/MM/RRRR');
    l_txnum:=p_txmsg.txnum;
    v_dblAMT:=p_txmsg.txfields('45').VALUE+p_txmsg.txfields('55').VALUE;

  IF  P_TXMSG.DELTD <> 'Y' THEN

   INSERT INTO CIFEESCHD (AUTOID, AFACCTNO, FEETYPE, TXNUM, TXDATE, NMLAMT, PAIDAMT, FLOATAMT,  REFACCTNO, DELTD)
   VALUES (SEQ_CIFEESCHD.nextval,v_afacctno,'FEEDR',p_txmsg.txnum,to_date(p_txmsg.txdate,'DD/MM/RRRR'),v_dblAMT,0,0,'','N');

  ELSE
       -- xoa giao dich
       UPDATE cifeeschd SET deltd='Y'  WHERE TXNUM = p_txmsg.txnum AND TXDATE = to_date(p_txmsg.txdate,'DD/MM/RRRR');

 END IF;
    plog.debug (pkgctx, '<<END OF fn_FeeDepositoryMaturityBackdate');
    plog.setendsection (pkgctx, 'fn_FeeDepositoryMaturityBackdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_FeeDepositoryMaturityBackdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_FeeDepoDebit;
FUNCTION fn_cidatedepofeeacr(strCLOSETYPE in varchar2,strCUSTODYCD IN varchar2, strAFACCTNO in varchar2, strNumDATE IN  NUMBER)
  RETURN  number
  IS

  v_Result  number(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_cidatedepofeeacr');
    plog.debug (pkgctx, '<<BEGIN OF fn_cidatedepofeeacr');
    if strCLOSETYPE = '001' then
        /*SELECT nvl(sum(nvl(FEEACR,0)),0)
        INTO v_Result
        FROM CFMAST CF, AFMAST AF,
            (SELECT A2.AFACCTNO,
                SUM(DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*strNumDATE/(A2.LOTDAY*A2.LOTVAL)) FEEACR
                FROM
                (SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,
                VW_SEMAST_VSDDEP_FEETERM A2 WHERE A1.ACCTNO=A2.ACCTNO AND A1.RFNUM=A2.ODRNUM GROUP BY A2.AFACCTNO) T2
        WHERE CF.custid = af.custid and af.acctno = T2.AFACCTNO AND CF.CUSTODYCD = strCUSTODYCD;*/
        --PhuongHT edit
        SELECT nvl(sum(nvl(FEEACR,0)),0)
        INTO v_Result
        FROM CFMAST CF, AFMAST AF,
            (SELECT A2.AFACCTNO,
                SUM(DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*strNumDATE/(A2.LOTDAY*A2.LOTVAL)) FEEACR
                FROM
                (SELECT T.*,ROWNUM ODR
                FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T  ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
                ) A2,
                (
                SELECT ACCTNO,MIN(ODR) ODR
                FROM
                (SELECT T.*,ROWNUM ODR
                FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
                )
                GROUP BY ACCTNO
                )A3
                WHERE A2.ACCTNO=A3.ACCTNO
                AND A2.ODR=A3.ODR
                GROUP BY A2.AFACCTNO) T2
        WHERE CF.custid = af.custid and af.acctno = T2.AFACCTNO AND CF.CUSTODYCD = strCUSTODYCD;
        -- end of PhuongHT edit
    else
        SELECT nvl(sum(nvl(FEEACR,0)),0)
        INTO v_Result
        FROM (SELECT A2.AFACCTNO,
                SUM(DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*strNumDATE/(A2.LOTDAY*A2.LOTVAL)) FEEACR
                FROM
                  (SELECT T.*,ROWNUM ODR
                  FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T  ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
                  ) A2,
                  (
                  SELECT ACCTNO,MIN(ODR) ODR
                  FROM
                  (SELECT T.*,ROWNUM ODR
                  FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
                  )
                  GROUP BY ACCTNO
                  )A3
                WHERE A2.ACCTNO=A3.ACCTNO
                AND A2.ODR=A3.ODR
                GROUP BY A2.AFACCTNO) T2
        WHERE T2.AFACCTNO = strAFACCTNO;
    end if;
    plog.debug (pkgctx, '<<END OF fn_cidatedepofeeacr');
    plog.setendsection (pkgctx, 'fn_cidatedepofeeacr');
    RETURN v_result;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_cidatedepofeeacr');
      RETURN 0;
END fn_cidatedepofeeacr;
--PhuongHT add
-- log vao sedepobal cho cac giao dich backdate phi luu ky trong han
PROCEDURE PR_LOGSEDEPOBAL(STRCODEID in varchar2,STRAFACCTNO VARCHAR2, strNumDATE IN  NUMBER,V_AMT IN NUMBER,V_QTTY NUMBER,V_TBALDATE DATE,V_ID VARCHAR2)
IS
v_strTRADEPLACE  varchar2(10);
v_strSECTYPEEXT  varchar2(10);
v_strSECTYPE    varchar2(10);
l_issedepofee char(1);
v_Result  number(20);
V_TXDATE  DATE;
V_VSDDEPOFEE_111 NUMBER;
V_VSDDEPOFEE_222 NUMBER;
V_VSDDEPOFEE_011 NUMBER; --Ngay 28/03/2017 CW NamTv them sysvar phi luu ky chung quyen
V_VSDDEPOFEE     NUMBER;
V_NUMDATE NUMBER;
V_INDATE DATE ;
V_NEXT_DATE DATE ;
l_reacctno  varchar2(30);
l_reacctnord varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'PR_LOGSEDEPOBAL');
    plog.debug (pkgctx, '<<BEGIN OF PR_LOGSEDEPOBAL');
   -- V_TXDATE:=GETCURRDATE;
    SELECT TRADEPLACE, SECTYPE ,issedepofee
    INTO v_strTRADEPLACE, V_STRSECTYPE,l_issedepofee
    FROM SBSECURITIES WHERE CODEID=strCODEID;
    if(l_issedepofee='N') THEN
     RETURN ;
    END IF;
    SELECT TO_NUMBER (VARVALUE) INTO V_VSDDEPOFEE_111
    FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'VSDDEPOFEE_111';
    SELECT TO_NUMBER (VARVALUE) INTO V_VSDDEPOFEE_222
    FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'VSDDEPOFEE_222';
    --Ngay 28/03/2017 CW NamTv them sysvar phi luu ky chung quyen
    SELECT TO_NUMBER (VARVALUE) INTO V_VSDDEPOFEE_011
    FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'VSDDEPOFEE_011';
    --NamTv End
    IF v_strSECTYPE='001' OR v_strSECTYPE='002' OR v_strSECTYPE='007' OR v_strSECTYPE='008' THEN
     v_strSECTYPEEXT := '111'; --Co phieu va chung chi quy
    ELSIF v_strSECTYPE='003' OR v_strSECTYPE='006' THEN
     v_strSECTYPEEXT := '222'; --Trai phieu
    ELSE
     v_strSECTYPEEXT := v_strSECTYPE;
    END IF;
    IF v_strSECTYPEEXT='111' THEN
       V_VSDDEPOFEE:=V_VSDDEPOFEE_111;
    ELSIF v_strSECTYPEEXT='222' THEN
       V_VSDDEPOFEE:=V_VSDDEPOFEE_222;
    --Ngay 28/03/2017 CW NamTv them sysvar phi luu ky chung quyen
    ELSIF v_strSECTYPEEXT='011' THEN
       V_VSDDEPOFEE:=V_VSDDEPOFEE_011;
    --NamTv End
    ELSE
       V_VSDDEPOFEE:=0;
    END IF;
       FOR REC IN
       (SELECT T.*,ROWNUM ODR FROM
       ( SELECT * FROM
          (-- bieu phi dac biet
          SELECT RF.ACTYPE AUTOID, RF.FORP, RF.FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP, 1 ODRNUM,
          ROUND((DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8) AMT_TEMP,
          'E' TYPE, AF.CUSTID
          FROM CIMAST MST, CITYPE TYP, CIFEEDEF_EXT RF,AFMAST AF,CIFEEDEF_EXTLNK LNK
          WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE  AND MST.AFACCTNO=STRAFACCTNO
          AND RF.CODEID=strCODEID AND rf.status='A'
          AND MST.ACCTNO=AF.ACCTNO
          AND AF.STATUS IN ('A','P')
          AND RF.ACTYPE=LNK.ACTYPE AND LNK.Afacctno=AF.ACCTNO AND LNK.STATUS='A'
          UNION ALL
          SELECT RF.ACTYPE AUTOID, RF.FORP, RF.FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP, 1 ODRNUM,
          ROUND((DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8) AMT_TEMP,
          'E' TYPE, AF.CUSTID
          FROM CIMAST MST, CITYPE TYP, CIFEEDEF_EXT RF, AFMAST AF,CIFEEDEF_EXTLNK LNK
          WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND MST.AFACCTNO=STRAFACCTNO
          AND RF.CODEID IS NULL AND (RF.SECTYPE=v_strSECTYPE or RF.SECTYPE=v_strSECTYPEEXT) AND RF.TRADEPLACE=v_strTRADEPLACE
          AND rf.status='A'
          AND MST.ACCTNO=AF.ACCTNO
          AND AF.STATUS IN ('A','P')
          AND RF.ACTYPE=LNK.ACTYPE AND LNK.Afacctno=AF.ACCTNO AND LNK.STATUS='A'
          UNION ALL
          SELECT RF.ACTYPE AUTOID, RF.FORP, RF.FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP, 1 ODRNUM,
          ROUND((DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8) AMT_TEMP,
          'E' TYPE, AF.CUSTID
          FROM CIMAST MST, CITYPE TYP, CIFEEDEF_EXT RF,AFMAST AF,CIFEEDEF_EXTLNK LNK
          WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE  AND MST.AFACCTNO=STRAFACCTNO
          AND rf.status='A'
          AND MST.ACCTNO=AF.ACCTNO
          AND AF.STATUS IN ('A','P')
          AND RF.CODEID IS NULL AND (RF.SECTYPE=v_strSECTYPE or RF.SECTYPE=v_strSECTYPEEXT) AND RF.TRADEPLACE='000'
           AND RF.ACTYPE=LNK.ACTYPE AND LNK.Afacctno=AF.ACCTNO AND LNK.STATUS='A'
          --bieu phi thuong
          UNION ALL
          SELECT TO_CHar(RF.AUTOID) AUTOID, RF.FORP, RF.FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP, 2 ODRNUM,
          ROUND((DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8) AMT_TEMP,
          'N' TYPE, AF.CUSTID
          FROM CIMAST MST, CITYPE TYP, CIFEEDEF RF,AFMAST AF
          WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND RF.FEETYPE='VSDDEP' AND MST.AFACCTNO=STRAFACCTNO
          AND RF.CODEID=strCODEID AND rf.status='A'
          AND MST.ACCTNO=AF.ACCTNO
          AND AF.STATUS IN ('A','P')
          UNION ALL
          SELECT TO_CHar(RF.AUTOID) AUTOID, RF.FORP, RF.FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP, 2 ODRNUM,
          ROUND((DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8) AMT_TEMP,
          'N' TYPE, AF.CUSTID
          FROM CIMAST MST, CITYPE TYP, CIFEEDEF RF, AFMAST AF
          WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND RF.FEETYPE='VSDDEP' AND MST.AFACCTNO=STRAFACCTNO
          AND RF.CODEID IS NULL AND (RF.SECTYPE=v_strSECTYPE or RF.SECTYPE=v_strSECTYPEEXT) AND RF.TRADEPLACE=v_strTRADEPLACE
          AND rf.status='A'
          AND MST.ACCTNO=AF.ACCTNO
          AND AF.STATUS IN ('A','P')
          UNION ALL
          SELECT TO_CHar(RF.AUTOID) AUTOID, RF.FORP, RF.FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP, 2 ODRNUM,
          ROUND((DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8) AMT_TEMP,
          'N' TYPE, AF.CUSTID
          FROM CIMAST MST, CITYPE TYP, CIFEEDEF RF,AFMAST AF
          WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND RF.FEETYPE='VSDDEP' AND MST.AFACCTNO=STRAFACCTNO
          AND rf.status='A'
          AND MST.ACCTNO=AF.ACCTNO
          AND AF.STATUS IN ('A','P')
          AND RF.CODEID IS NULL AND (RF.SECTYPE=v_strSECTYPE or RF.SECTYPE=v_strSECTYPEEXT) AND RF.TRADEPLACE='000'
          )
       ORDER BY ODRNUM,AMT_TEMP
       ) T
       )
       LOOP

         IF REC.ODR='1' THEN

     /*      INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,ID,amt,
                                  Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,USED,VSDFEEAMT)
           VALUES (SEQ_SEDEPOBAL.NEXTVAL,STRAFACCTNO||STRCODEID,V_TBALDATE,strNumDATE,
                   V_QTTY, 'N',V_ID,V_AMT,
                   REC.TYPE,REC.AUTOID,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,'Y',V_VSDDEPOFEE);*/


     for rec1 IN ( SELECT sbdate
                 FROM sbcldr
                 where sbdate   BETWEEN  V_TBALDATE and V_TBALDATE+strNumDATE-1
                 AND  cldrtype ='000' AND holiday ='N'   ORDER BY sbdate  )
      loop

      select getduedate ( REC1.sbdate,'B','000',1) INTO V_NEXT_DATE FROM DUAL ;
      V_NUMDATE:= V_NEXT_DATE- REC1.sbdate;


          /*IF REC1.sbdate =V_TBALDATE THEN
              V_NUMDATE:= V_TBALDATE-V_PRV_DATE;

              V_INDATE:= REC1.sbdate ;

            ELSE
              V_NUMDATE:=REC1.sbdate  - V_INDATE;
              V_INDATE:=REC1.sbdate;
            END IF;*/
        SELECT max(CASE WHEN RET.REROLE = 'RD' THEN RL.REACCTNO ELSE ' ' END) REACCTNORD,
            max(CASE WHEN RET.REROLE IN ('RM', 'CS') THEN RL.REACCTNO ELSE ' ' END) REACCTNO
            into l_reacctnord, l_reacctno
        FROM REAFLNK RL, REMAST RE, RETYPE RET
        WHERE RL.REACCTNO = RE.ACCTNO
            AND RE.ACTYPE = RET.ACTYPE AND RL.AFACCTNO = rec.CUSTID
            ANd RL.FRDATE  <= rec1.sbdate  and NVL(RL.CLSTXDATE, RL.TODATE) >= rec1.sbdate
            AND RET.REROLE IN ('RM' ,'CS' ,'RD');


          INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,ID,amt,
                                  Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,USED,VSDFEEAMT,reacctno, reacctnord)
           VALUES (SEQ_SEDEPOBAL.NEXTVAL,STRAFACCTNO||STRCODEID,rec1.sbdate,V_NUMDATE,
                   V_QTTY, 'N',V_ID,0,
                   REC.TYPE,REC.AUTOID,0,REC.LOTDAY,REC.LOTVAL,REC.FORP,'Y',V_VSDDEPOFEE,l_reacctno,l_reacctnord);
        end loop;

         ELSE
            SELECT max(CASE WHEN RET.REROLE = 'RD' THEN RL.REACCTNO ELSE ' ' END) REACCTNORD,
                max(CASE WHEN RET.REROLE IN ('RM', 'CS') THEN RL.REACCTNO ELSE ' ' END) REACCTNO
                into l_reacctnord, l_reacctno
            FROM REAFLNK RL, REMAST RE, RETYPE RET
            WHERE RL.REACCTNO = RE.ACCTNO
                AND RE.ACTYPE = RET.ACTYPE AND RL.AFACCTNO = rec.CUSTID
                ANd RL.FRDATE  <= V_TBALDATE  and NVL(RL.CLSTXDATE, RL.TODATE) >= V_TBALDATE
                AND RET.REROLE IN ('RM' ,'CS' ,'RD');

            INSERT INTO SEDEPOBAL_HIST (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,ID,amt,
                                  Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,USED,VSDFEEAMT,reacctno, reacctnord)
           VALUES (SEQ_SEDEPOBAL.NEXTVAL,STRAFACCTNO||STRCODEID,V_TBALDATE,strNumDATE,
                   V_QTTY, 'N',V_ID,ROUND(REC.AMT_TEMP*V_QTTY*strNumDATE,4),
                   REC.TYPE,REC.AUTOID,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,'N',V_VSDDEPOFEE,l_reacctno,l_reacctnord);
         END IF;
       END LOOP;

    plog.debug (pkgctx, '<<END OF PR_LOGSEDEPOBAL');
    plog.setendsection (pkgctx, 'PR_LOGSEDEPOBAL');

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'PR_LOGSEDEPOBAL');
      RETURN ;
END PR_LOGSEDEPOBAL;

---------------------------------pr_IRCreditInterestAccure------------------------------------------------
FUNCTION pr_IRCalcCreditInterest(pv_ACType In VARCHAR2, pv_AMT in Number, pv_RuleType Out VARCHAR2)
RETURN NUMBER
IS
    l_delta         Number(20,6);
    l_intrate       Number(20,6);
    l_ACType        VARCHAR2(4);
    l_RATEID        VARCHAR2(4);
    l_RATETERMCD    VARCHAR2(4);
    l_RateTerm      Number;
    l_RateType      VARCHAR2(4);
    l_RuleType      VARCHAR2(4);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_IRCalcCreditInterest');
    plog.debug (pkgctx, '<<BEGIN OF pr_IRCalcCreditInterest');
    /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    l_ACType := pv_ACType;
    plog.debug (pkgctx, 'l_ACType:' || l_ACType);
    l_intrate   := 0;
    l_delta     := 0;
    BEGIN
        SELECT IR.RATEID, IR.RATE, IR.RATETERMCD, IR.RATETERM, IR.RATETYPE
        into l_RATEID, l_intrate, l_RATETERMCD, l_RateTerm, l_RuleType
        FROM IRRATE IR, CITYPE CI
        WHERE IR.RATEID = CI.RATEID AND CI.ACTYPE = l_ACType;
    EXCEPTION
        WHEN OTHERS THEN RETURN 0;
    END;

    pv_RuleType := l_RuleType;

    If l_RuleType = 'T' THEN
       Begin
           select Delta into l_delta
           from irrateschm
           where rateid = l_RATEID and framt < pv_AMT and toamt > pv_AMT;
       EXCEPTION
           WHEN OTHERS
           THEN l_delta := 0;
       END;
    End If;

    plog.debug (pkgctx, 'l_intrate:' || l_intrate);
    plog.debug (pkgctx, 'l_delta:' || l_delta);
    plog.debug (pkgctx, 'pv_RuleType:' || pv_RuleType);

    l_intrate := l_intrate + l_delta;


    plog.debug (pkgctx, '<<END OF pr_IRCalcCreditInterest');
    plog.setendsection (pkgctx, 'pr_IRCalcCreditInterest');

    RETURN l_intrate;


EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_IRCalcCreditInterest');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_IRCalcCreditInterest;
--PhuongHT add
-- Phan bo gia tri UTTB vao cac nguon
PROCEDURE PR_ADVRESALLOC(V_STRAFACCTNO in varchar2,V_DBLAMT IN NUMBER,V_TXDATE DATE,V_TXNUM VARCHAR2)
IS
L_CUSTID VARCHAR2(10);
L_ISUSEOADVRES CHAR(1);
L_BANKID       VARCHAR2(10);
L_LMAMT        NUMBER(20);
L_BANKRATE     NUMBER(20,4);
L_AMT          NUMBER(20);
L_AMTTEMP      NUMBER(20);
L_USED         NUMBER(20);
l_advrate      NUMBER(20,4);

l_day          NUMBER(20);
l_feeadv       NUMBER(20); -- tong phi advresallog
l_feeadvc      NUMBER(20); -- phi cong ty advresallog
l_feeadvb      NUMBER(20); -- phi ngan hang advresallog
l_vat          NUMBER(20); -- thue advresallog
l_sfeeamt      NUMBER(20); -- tong tien phi = adsch
BEGIN
    plog.setbeginsection (pkgctx, 'PR_ADVRESALLOC');
    plog.debug (pkgctx, '<<BEGIN OF PR_ADVRESALLOC');

    select least(ad.advrate,nvl(adpr.feerate,1000)), ads.cleardt -ads.txdate ,ads.feeamt into l_advrate,l_day, l_sfeeamt
    from adschd ads, adtype ad,
        (
            select cf.afacctno, min(mst.feerate) feerate from adprmfeecf cf, adprmfeemst mst
            where cf.promotionid = mst.autoid
                and cf.status = 'A' and getcurrdate between cf.valdate and cf.expdate
                group by cf.afacctno
        ) adpr
    where ads.adtype = ad.actype
    and ads.txnum = V_TXNUM
    and ads.txdate = V_TXDATE
    and ads.acctno = adpr.afacctno(+)
    and ads.deltd ='N'  ;

/*      ,ROUND( SUM(    ad.amt* ad.bankrate*(ads.cleardt -ads.txdate)/(360*100) /(1 + ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100) ) )) fee ,
     max(adtype.advrate) advrate,
     ROUND( SUM(ad.amt* (adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100)/ (1+(adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100))     ))-
     ROUND( SUM(ad.amt* ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100) /( 1+ ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100)  )   ))feec,
     ROUND( SUM(ad.amt* (adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100)/(1+(adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100))  ))feea,
*/


    SELECT CUSTID INTO L_CUSTID FROM AFMAST WHERE ACCTNO=V_STRAFACCTNO;
    SELECT ISUSEOADVRES INTO L_ISUSEOADVRES FROM CFMAST WHERE CUSTID=L_CUSTID;
    L_AMT:=V_DBLAMT;
    IF L_ISUSEOADVRES='N' THEN-- khach hang chi dung nguon Cong ty
       BEGIN
         SELECT BANKID,LMAMTMAX ,BANKRATE
         INTO L_BANKID,L_LMAMT ,L_BANKRATE
         FROM CFLIMIT WHERE LMSUBTYPE='ADV' AND RRTYPE='C';
       EXCEPTION WHEN OTHERS THEN
         L_BANKID:='a';
         L_LMAMT:=0;
       END ;
       BEGIN
         SELECT NVL(SUM(AMT),0)
         INTO L_USED
         FROM ADVRESLOG WHERE CUSTBANK=L_BANKID;
       EXCEPTION WHEN OTHERS THEN
         L_USED:=0;
       END ;

   l_feeadv:= l_sfeeamt;
   l_feeadvc:= l_sfeeamt;
   l_feeadvb:= 0;
   l_vat:= 0;

      IF L_BANKID <> 'a' THEN
          --UPDATE CFLIMIT SET LMAMTMAX=LMAMTMAX-L_AMT WHERE LMSUBTYPE='ADV' AND RRTYPE='C' AND BANKID=L_BANKID;
          INSERT INTO ADVRESLOG (AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AMT,RESREMAIN,BANKRATE,AFACCTNO,ADVRATE,feeadv,feeadvb,feeadvc,vat)
          VALUES(SEQ_ADVRESLOG.NEXTVAL,V_TXDATE,V_TXNUM,'C',L_BANKID,L_AMT,L_LMAMT-L_USED,L_BANKRATE,V_STRAFACCTNO,l_advrate,l_feeadv,l_feeadvb,l_feeadvc,l_vat );
       ENd IF;
    ELSE-- khach hang dung nguon ben thu 3
        FOR REC IN
        (SELECT * FROM (   SELECT CFL.*,(CFL.LMAMTMAX-NVL(LOG.USED,0)) REMAINAMT
                           FROM CFLIMIT CFL, (SELECT SUM(AMT) USED,CUSTBANK FROM ADVRESLOG GROUP BY CUSTBANK) LOG
                           WHERE CFL.BANKID=LOG.CUSTBANK(+)
                           AND CFL.RRTYPE='C'
                           AND CFL.LMSUBTYPE='ADV'
                           AND CFL.LMAMTMAX - NVL(LOG.USED,0)>0
                        UNION ALL
                           SELECT CFL.*,(CFL.LMAMTMAX-NVL(LOG.USED,0)) REMAINAMT
                           FROM ADVRESLNK LNK, CFLIMIT CFL,
                           (SELECT SUM(AMT) USED,CUSTBANK FROM ADVRESLOG GROUP BY CUSTBANK) LOG
                           WHERE (LNK.CUSTID=L_CUSTID )
                           AND CFL.BANKID=LNK.CUSTBANK
                           and  getcurrdate >= lnk.valdate
                           and  getcurrdate < lnk.expdate
                           AND CFL.LMSUBTYPE='ADV' and nvl(LNK.chstatus,'C') <> 'A'
                           AND CFL.LMAMTMAX - NVL(LOG.USED,0)>0
                           AND CFL.BANKID=LOG.CUSTBANK(+)
                           AND CFL.RRTYPE <> 'C')
           ORDER BY ODR)
        LOOP
          L_AMTTEMP:=LEAST(REC.REMAINAMT,L_AMT);


        /*  UPDATE CFLIMIT SET LMAMTMAX=LMAMTMAX-L_AMTTEMP
          WHERE AUTOID=REC.AUTOID;*/

         if L_AMTTEMP = L_AMT then
             l_feeadv :=l_sfeeamt;
              l_feeadvc:= l_feeadv -
                     ROUND(  L_AMTTEMP* REC.BANKRATE*l_day/(360*100) /(1 + l_advrate*l_day/(360*100)));
         else
             l_feeadv:=   ROUND(L_AMTTEMP* l_advrate*l_day/(360*100)/(1+l_advrate*l_day/(360*100)) )  ;
              l_feeadvc:= ROUND(L_AMTTEMP* l_advrate*l_day/(360*100)/(1+l_advrate*l_day/(360*100)) ) -
                     ROUND(  L_AMTTEMP* REC.BANKRATE*l_day/(360*100) /(1 + l_advrate*l_day/(360*100)));
         end if;


         l_feeadvb:= ROUND(  L_AMTTEMP* REC.BANKRATE*l_day/(360*100) /(1 + l_advrate*l_day/(360*100)));
         l_vat:= case when REC.RRTYPE='C' THEN 0 ELSE  round(l_feeadvc*10/110) END ;

         l_sfeeamt :=l_sfeeamt-l_feeadv;

         L_AMT:=L_AMT-L_AMTTEMP;

          INSERT INTO ADVRESLOG (AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AMT,RESREMAIN,BANKRATE,AFACCTNO,ADVRATE,feeadv,feeadvb,feeadvc,vat)
          VALUES(SEQ_ADVRESLOG.NEXTVAL,V_TXDATE,V_TXNUM,REC.RRTYPE,REC.BANKID,L_AMTTEMP,REC.REMAINAMT,REC.BANKRATE,V_STRAFACCTNO,l_advrate,l_feeadv,l_feeadvb,l_feeadvc,l_vat);
        EXIT WHEN L_AMT<=0;
        END LOOP;
        IF L_AMT>0 THEN-- NEU VAN CHUA PHAN BO HET-> DAY VAO NGUON vcbs
             BEGIN
                SELECT BANKID,LMAMTMAX ,BANKRATE
                INTO L_BANKID,L_LMAMT ,L_BANKRATE
                FROM CFLIMIT WHERE LMSUBTYPE='ADV' AND RRTYPE='C';
             EXCEPTION WHEN OTHERS THEN
                L_BANKID:='a';
                L_LMAMT:=0;
             END ;
             IF L_BANKID <> 'a' THEN
                BEGIN
                    SELECT SUM(AMT)
                    INTO L_USED
                    FROM ADVRESLOG WHERE CUSTBANK=L_BANKID;
                EXCEPTION WHEN OTHERS THEN
                   L_USED:=0;
                END ;

         l_feeadv := l_sfeeamt ;
         l_feeadvc:= l_sfeeamt;
         l_feeadvb:= 0;
         l_vat:= 0;



              --UPDATE CFLIMIT SET LMAMTMAX=LMAMTMAX-L_AMT WHERE LMSUBTYPE='ADV' AND RRTYPE='C' AND BANKID=L_BANKID;
              INSERT INTO ADVRESLOG (AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AMT,RESREMAIN,BANKRATE,AFACCTNO,ADVRATE,FEEADV,FEEADVB,FEEADVC,VAT)
              VALUES(SEQ_ADVRESLOG.NEXTVAL,V_TXDATE,V_TXNUM,'C',L_BANKID,L_AMT,L_LMAMT-L_USED,L_BANKRATE,V_STRAFACCTNO,l_advrate,l_feeadv,l_feeadvb,l_feeadvc,l_vat);
            ENd IF;
        END IF;

    END IF;

    plog.debug (pkgctx, '<<END OF PR_ADVRESALLOC');
    plog.setendsection (pkgctx, 'PR_ADVRESALLOC');

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'PR_ADVRESALLOC');
      RETURN ;
END PR_ADVRESALLOC;
-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_ciproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
