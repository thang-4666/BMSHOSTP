SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8883ex
/**----------------------------------------------------------------------------------------------------
 ** Module: COMMODITY SYSTEM
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      22/10/2009     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#8883ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
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
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
    v_lngErrCode number(20,0);
    v_count number(20,0);
    v_dblQTTY number(20,0);
    v_strCODEID varchar2(30);
    v_strORGORDERID varchar2(30);
    v_strEXECTYPE varchar2(30);
    v_strMATCHTYPE varchar2(30);
    v_strContraCus varchar2(30);
    v_strPUTTYPE    varchar2(30);
    v_strContrafirm2    varchar2(30);
    v_blnReversal boolean;
    v_strTRADEPLACE    varchar2(30);
    v_strCompanyFirm varchar2(100);
    v_strOrgExectype varchar2(30);
    v_dblEXECQTTY   number(20);
    v_dblREMAINQTTY number(20);
    v_strVALUE varchar2(100);
    v_strTradingID_HA VARCHAR2(30);
    v_strPRICETYPE odmast.PRICETYPE%type;


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
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    v_lngErrCode:=errnums.C_BIZ_RULE_INVALID;
    if p_txmsg.deltd='Y' then
        v_blnReversal:=true;
    else
        v_blnReversal:=false;
    end if;
    v_strCODEID := p_txmsg.txfields('01').value;
    v_dblQTTY := p_txmsg.txfields('12').value;
    v_strORGORDERID := p_txmsg.txfields('08').value;
    v_strMATCHTYPE := p_txmsg.txfields('24').value;
    v_strEXECTYPE := p_txmsg.txfields('22').value;
    v_strContraCus :='';-- p_txmsg.txfields('71').value;
    --v_strContraCus:='';--replace(v_strContraCus,'.','');
    v_strPUTTYPE :='';-- p_txmsg.txfields('72').value;
    v_strContrafirm2 :='';-- p_txmsg.txfields('73').value;
    v_strPRICETYPE := p_txmsg.txfields('27').value;


    --thunt-03/06/2021:Check Gio Huy/Sua
    IF fn_check_cancel_time(v_strCODEID, v_strORGORDERID) <> systemnums.C_SUCCESS THEN
      p_err_code := -700087;
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    
    begin
    plog.debug (pkgctx, 'v_strCODEID:' || v_strCODEID);
    SELECT TRADEPLACE into v_strTRADEPLACE FROM SBSECURITIES WHERE CODEID=v_strCODEID;
        --plog.debug (pkgctx, 'v_strTRADEPLACE:' || v_strTRADEPLACE);
          -- chan huy sua lenh cuoi phien ATC
          IF v_strTRADEPLACE ='002' THEN
               SELECT sysvalue
                       INTO v_strTradingID_HA
                       FROM ordersys_ha
                       WHERE sysname = 'TRADINGID';
               If v_strTradingID_HA = 'CLOSE_BL' and v_strPriceType <> 'PLO' Then --16/10/2018 DieuNDA: Lenh PLO duoc phep Huy/Sua o phien CLOSE_BL
                  p_err_code := '-100113';
                  plog.setendsection (pkgctx, 'fn_txAftAppCheck');
               RETURN errnums.C_BIZ_RULE_INVALID;
               End If;
           END IF;
        If v_strTRADEPLACE = errnums.gc_TRADEPLACE_UPCOM
            And (p_txmsg.tltxcd = '8882' Or p_txmsg.tltxcd = '8883' Or p_txmsg.tltxcd = '8884' Or p_txmsg.tltxcd = '8885')
            And v_strMATCHTYPE = 'P'
        Then
            --Cac lenh da khop khong cho phep huy sua
            begin
                SELECT PUTTYPE  into v_strPUTTYPE
                FROM ODMAST
                WHERE ORDERID=v_strORGORDERID
                AND MATCHTYPE = 'P' AND DELTD='N'
                AND EXECQTTY=0 AND REMAINQTTY>0
                AND CODEID IN (SELECT CODEID FROM SBSECURITIES WHERE TRADEPLACE=v_strTRADEPLACE );
            exception
            when no_data_found then
                --Lenh da khop
                p_err_code := errnums.C_OD_ERROR_ORDER_MATCHED;
                Return v_lngErrCode;
            end;
            --Cac lenh view o man hinh send thi ko cho huy sua (trang thai OOD=B)
            /*SELECT COUNT(OOD.orgorderid) into v_count  FROM OOD,ODMAST OD WHERE OD.orderid = OOD.orgorderid AND OD.orderid = v_strORGORDERID  AND OOD.oodstatus IN ('N','S') AND OD.deltd='N' AND OOD.DELTD='N';
            if v_count <=0 then
                p_err_code := errnums.C_OD_ERROR_ORDER_BLOCKED;
                Return v_lngErrCode;
            end if;*/
            --Kiem tra neu la upcom thoa thuan thi check ko cho phep sua, chi cho phep huy
            If v_strPUTTYPE = 'N' Then
                If (p_txmsg.tltxcd = '8884' Or p_txmsg.tltxcd = '8885') Then
                    p_err_code := errnums.C_OD_ERROR_UPCOM_CANNOT_AMEND;
                    Return v_lngErrCode;
                End If;
                --Check phai huy lenh mua truoc,huy lenh ban sau doi voi lenh thoa thuan cung cong ty
                begin
                    select varvalue into v_strCompanyFirm from sysvar where grname ='SYSTEM' and varname='COMPANYCD';
                exception
                when no_data_found then
                    --Lenh da khop
                    p_err_code := errnums.C_SA_VARIABLE_NOTFOUND;
                    Return v_lngErrCode;
                end;
                --Lay thong tin firm2 cua lenh goc
                begin
                    SELECT nvl(EXECTYPE,'') EXECTYPE,nvl(CONTRAFRM,'') CONTRAFRM,CONTRAORDERID
                    into v_strOrgExectype,v_strContrafirm2,v_strContraCus
                    FROM ODMAST WHERE ORDERID=v_strORGORDERID  AND ROWNUM<=1;
                exception
                when no_data_found then
                    --Lenh da khop
                    p_err_code := errnums.C_OD_ORDER_NOT_FOUND;
                    Return v_lngErrCode;
                end;
                --Neu la lenh cung cong ty phai kiem tra huy lenh mua truoc
                If (v_strContrafirm2 = v_strCompanyFirm Or nvl(v_strContrafirm2,'$X$')='$X$' or v_strContrafirm2='') Then
                    If (v_strOrgExectype = 'NS') Then
                        begin
                            SELECT EXECQTTY,REMAINQTTY into v_dblEXECQTTY,v_dblREMAINQTTY FROM ODMAST WHERE CONTRAORDERID=v_strORGORDERID;
                                If v_dblEXECQTTY > 0 Or v_dblREMAINQTTY > 0 Then
                                    p_err_code := errnums.C_OD_UPCOM_CANCEL_BUY_FIRST;
                                    Return v_lngErrCode;

                                End If;
                        exception
                        when no_data_found then
                            null;
                        end;
                    End If;
                End If;
            end if;
        end if;
        --GianhVG bo check, cho phep sua lenh HOSE
        /*plog.debug (pkgctx, 'Check amend order for Hose tradeplace');
        begin
            SELECT VARVALUE into v_strVALUE FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME ='HOSEGW';
        exception
            when no_data_found then
                --Lenh da khop
                p_err_code := errnums.C_SA_VARIABLE_NOTFOUND;
                Return v_lngErrCode;
        end;
        plog.debug (pkgctx, 'TRADEPLACE,HOSEGW' || v_strTRADEPLACE || ',' || v_strVALUE);
        If v_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC And v_strVALUE = 'Y' And (p_txmsg.tltxcd = '8885' Or p_txmsg.tltxcd = '8884') Then
            p_err_code := errnums.C_OD_TRADEPLACE_HOSE_NOT_AMEND;
            Return v_lngErrCode;
        end if;*/
    exception
    when no_data_found then
        --khogn co lenh nay
        p_err_code := errnums.C_OD_ORDER_NOT_FOUND;
        Return v_lngErrCode;
    end;
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
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

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
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

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
    v_lngErrCode number(20,0);
    v_count number(20,0);
    v_blnReversal boolean;
    v_strCODEID  odmast.codeid%type;
    v_strACTYPE  odmast.ACTYPE%type;
    v_strAFACCTNO odmast.AFACCTNO%type;
    v_strTIMETYPE odmast.TIMETYPE%type;
    v_strEFFDATE varchar2(30);
    v_strEXPDATE varchar2(30);
    v_strEXECTYPE odmast.EXECTYPE%type;
    v_strOLDEXECTYPE odmast.EXECTYPE%type;
    v_strNORK odmast.NORK%type;
    v_strMATCHTYPE odmast.MATCHTYPE%type;
    v_strVIA odmast.VIA%type;
    v_strCLEARCD odmast.CLEARCD%type;
    v_strPRICETYPE odmast.PRICETYPE%type;
    v_dblCLEARDAY odmast.CLEARDAY%type;
    v_dblQUOTEPRICE odmast.QUOTEPRICE%type;
    v_dblORDERQTTY odmast.ORDERQTTY%type;
    v_dblBRATIO odmast.BRATIO%type;
    v_dblLIMITPRICE odmast.LIMITPRICE%type;
    v_dblAdvanceAmount number(20,4);
    v_strVOUCHER odmast.VOUCHER%type;
    v_strCONSULTANT odmast.CONSULTANT%type;
    v_strORDERID odmast.ORDERID%type;
    v_strSymbol sbsecurities.symbol%type;
    v_strCancelOrderID odmast.ORDERID%type;
    v_strCUSTODYCD cfmast.custodycd%type;
    v_strDESC varchar2(300);
    v_dblIsMortage number(20);
    v_strOutPriceAllow char(1);
    v_strTLTXCD tltx.tltxcd%type;
    v_strFEEDBACKMSG varchar2(1000);
    v_dblTradeUnit number(20,4);
    v_strBORS char(1);
    v_strOODStatus char(1);
    v_strEDSTATUS char(1);
    v_strWASEDSTATUS char(1);
    v_strCUROODSTATUS char(1);
    v_dblCorrecionNumber number(10);
    v_strSEACCTNO odmast.seacctno%type;
    v_strCIACCTNO odmast.ciacctno%type;
    v_strSecuredAmt number(20,0);
    v_strCUSTID varchar2(200);
    --</ TruongLD Add
    v_strTLID VARCHAR2(30);
    --/>
    v_dblQuoteqtty ODMAST.quoteqtty%type;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    v_lngErrCode:=errnums.C_BIZ_RULE_INVALID;

    --</ TruongLD Add
    v_strTLID := p_txmsg.tlid;
    --/>

    if p_txmsg.deltd='Y' then
        v_blnReversal:=true;
    else
        v_blnReversal:=false;
    end if;
    plog.debug (pkgctx, 'v_blnReversal:' || case when v_blnReversal= true then 'TRUE' else 'FALSE' end);
    v_strTLTXCD:=p_txmsg.tltxcd;
    v_strCODEID := p_txmsg.txfields('01').value;
    v_strACTYPE := p_txmsg.txfields('02').value;
    v_strAFACCTNO := p_txmsg.txfields('03').value;
    v_strTIMETYPE := p_txmsg.txfields('20').value;
    if v_strTLTXCD='8884' or v_strTLTXCD='8885' then
        v_strEFFDATE := p_txmsg.txfields('19').value;
    else
        v_strEFFDATE :='';-- p_txmsg.txfields('19').value;
    end if;

    v_strEXPDATE := p_txmsg.txfields('21').value;
    v_strEXECTYPE := p_txmsg.txfields('22').value;
    v_strNORK := p_txmsg.txfields('23').value;
    v_strMATCHTYPE := p_txmsg.txfields('24').value;
    v_strVIA := p_txmsg.txfields('25').value;
    v_strCLEARCD := p_txmsg.txfields('26').value;
    v_strPRICETYPE := p_txmsg.txfields('27').value;
    v_dblCLEARDAY := p_txmsg.txfields('10').value;
    v_dblQUOTEPRICE := p_txmsg.txfields('11').value;
    v_dblORDERQTTY := p_txmsg.txfields('12').value;
    v_dblBRATIO := p_txmsg.txfields('13').value;
    v_dblLIMITPRICE := p_txmsg.txfields('14').value;
    if v_strTLTXCD='8884' then
        v_dblAdvanceAmount := p_txmsg.txfields('18').value;
    else
        v_dblAdvanceAmount :='';-- p_txmsg.txfields('18').value;
    end if;
    v_strVOUCHER := p_txmsg.txfields('28').value;
    v_strCONSULTANT := p_txmsg.txfields('29').value;
    v_strORDERID := p_txmsg.txfields('04').value;
    v_strSymbol := p_txmsg.txfields('07').value;
    v_strCancelOrderID := p_txmsg.txfields('08').value;
    v_strCUSTODYCD := p_txmsg.txfields('09').value;
    v_strDESC := p_txmsg.txfields('30').value;
    --v_dblIsMortage := p_txmsg.txfields('60').value;
    v_strOutPriceAllow := p_txmsg.txfields('34').value;
    v_strCUSTID := p_txmsg.txfields('50').value;

     begin
       v_dblQuoteqtty :=  p_txmsg.txfields('80').value;
     exception
     when no_data_found then
       v_dblQuoteqtty := 0;
     end;


    If v_strTIMETYPE = 'G' Then
        If Not v_blnREVERSAL Then
            plog.debug (pkgctx, 'v_strTIMETYPE,v_strTLTXCD:' || v_strTIMETYPE || ',' || v_strTLTXCD);
            --Giao dich
            If v_strTLTXCD = '8882' Or v_strTLTXCD = '8883' Or v_strTLTXCD = '8884' Or v_strTLTXCD = '8885' Then
                begin
                    select A,EXECTYPE,EFFDATE into v_count,v_strOLDEXECTYPE,v_strEFFDATE from
                    (SELECT 1 A,EXECTYPE,to_char(EFFDATE,'DD/MM/RRRR') EFFDATE FROM FOMAST WHERE ACCTNO=v_strCancelOrderID  AND DELTD<>'Y' AND STATUS<> 'A'
                     UNION SELECT 0 A,EXECTYPE,'' EFFDATE FROM ODMAST WHERE ORDERID= v_strCancelOrderID) ;
                     if v_count=1 then
                        --Lenh GTO trong FOMAST chua duoc day vao he thong
                        plog.debug (pkgctx, 'Order in FOMAST only');
                        If v_strTLTXCD = '8882' Or v_strTLTXCD = '8883' Then
                            --Lenh huy
                            UPDATE FOMAST SET DELTD='Y',REFACCTNO=v_strORDERID WHERE ACCTNO=v_strCancelOrderID;
                            Return systemnums.C_SUCCESS;
                        else
                            --LENH SUA
                            UPDATE FOMAST SET DELTD='Y',REFACCTNO=v_strORDERID WHERE ACCTNO=v_strCancelOrderID;

                            v_strFEEDBACKMSG:= v_strDESC;
                            INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE,
                            PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                                CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT,
                                CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE,
                                TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,TXDATE,TXNUM,EFFDATE,EXPDATE,
                                BRATIO,VIA,OUTPRICEALLOW)
                                VALUES (
                                     v_strORDERID , v_strORDERID , v_strACTYPE , v_strAFACCTNO ,'P',
                                     v_strOLDEXECTYPE, v_strPRICETYPE , v_strTIMETYPE , v_strMATCHTYPE ,
                                     v_strNORK , v_strCLEARCD , v_strCODEID , v_strSymbol ,
                                     'N','A', v_strFEEDBACKMSG ,TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),
                                     v_dblCLEARDAY , v_dblORDERQTTY , v_dblLIMITPRICE , v_dblQUOTEPRICE , 0 , 0 , 0 ,
                                     v_dblORDERQTTY ,p_txmsg.txdate, p_txmsg.txnum ,
                                     TO_DATE( v_strEFFDATE ,  'DD/MM/RRRR' ),TO_DATE( v_strEXPDATE ,  'DD/MM/RRRR' ),
                                     v_dblBRATIO , v_strVIA , v_strOutPriceAllow
                                 );
                            Return systemnums.C_SUCCESS;
                        end if;
                     else --=0
                        plog.debug (pkgctx, 'Order in FOMAST and already send to ODMAST');
                        --Lenh GTO cua ODMAST
                        --Khong xu ly gi, xu ly nhu lenh binh thuong o phan sau
                        null;
                     end if;
                exception
                when no_data_found then
                    --Lenh da khop
                    p_err_code := errnums.C_OD_ORDER_SENDING;
                    Return v_lngErrCode;
                end;
            end if;
        else --Xoa Giao dich
            If v_strTLTXCD = '8882' Or v_strTLTXCD = '8883' Or v_strTLTXCD = '8884' Or v_strTLTXCD = '8885' Then
                begin
                    select A into v_count from
                    (SELECT 1 A FROM FOMAST WHERE ACCTNO= v_strCancelOrderID  AND DELTD='Y' AND STATUS<>'A'
                    UNION SELECT 0 A FROM ODMAST WHERE ORDERID=v_strCancelOrderID);
                    if v_count=1 then
                        plog.debug (pkgctx, 'Order in FOMAST only');
                        --Lenh GTC trong FOMAST chua duoc day vao he thong
                        If v_strTLTXCD = '8882' Or v_strTLTXCD = '8883' Then
                            --Lenh huy
                            UPDATE FOMAST SET DELTD='N',REFACCTNO='' WHERE ACCTNO= v_strCancelOrderID;
                        else
                            --KIEM TRA XEM LENH SUA MOI DA SEND DI CHUA
                            SELECT count(1)  into v_count FROM FOMAST WHERE ACCTNO= v_strORDERID  AND DELTD <> 'Y' AND STATUS='P';
                            if v_count>0 then
                                --LENH SUA
                                UPDATE FOMAST SET DELTD='N',REFACCTNO='' WHERE ACCTNO=v_strCancelOrderID;
                                DELETE FROM FOMAST WHERE ACCTNO=v_strORDERID;
                            else
                                --Lenh GTC tu FOMAST da duoc day vao ODMAST
                                p_err_code := errnums.C_OD_ORDER_SENDING;
                                Return v_lngErrCode;
                            end if;

                        end if;
                    Else --=0
                        plog.debug (pkgctx, 'Order in FOMAST and already send to ODMAST');
                        null;
                        --Lenh GTO cua ODMAST
                        --Khong xu ly gi, xu ly nhu lenh binh thuong o phan sau
                    End If;
                exception
                when no_data_found then
                    --Lenh da khop
                    p_err_code := errnums.C_OD_ORDER_SENDING;
                    Return v_lngErrCode;
                end;
            end if;

        end if;
    end if;
    --LENH KHAC GTC
    --HOAC LENH GTC DA DAY VAO HE THONG
    If Not v_blnREVERSAL Then
        --Lenh yeu cau
        --Kiem tra xem neu lenh huy chua doc ma dang o trang thai block cho doc thi khong cho phep huy
        If v_strTLTXCD = '8882' Or v_strTLTXCD = '8883' Or v_strTLTXCD = '8884' Or v_strTLTXCD = '8885' Then
            begin
                SELECT A.OODSTATUS into v_strCUROODSTATUS FROM OOD A, ODQUEUE B WHERE A.ORGORDERID=B.ORGORDERID  AND A.ORGORDERID=v_strCancelOrderID;
                If v_strCUROODSTATUS = 'B' Then
                    plog.debug (pkgctx, 'Order is pending to send');
                    --Lenh dang view de send khong huy duoc, doi khi send xong hoac reject lai roi huy.
                    p_err_code := errnums.C_OD_ORDER_SENDING;
                    Return v_lngErrCode;
                ElsIf v_strCUROODSTATUS = 'D' Then
                    plog.debug (pkgctx, 'Order is was not send then block to D');
                    --Lenh chua Send, khi view block ve trang thai D
                    v_strCUROODSTATUS := 'N';
                End If;
            exception
            when no_data_found then
                v_strCUROODSTATUS := 'N';
            end;
        end if;
        --Kiem tra xem lenh da vuot qua so lan cho phep huy sua hay chua. Neu vuot qua bao loi
        --Lay ra so lan duoc phep
        begin
            SELECT to_number(VARVALUE) into v_dblCorrecionNumber FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME ='CORRECTIONNUMBER';
        exception
            when no_data_found then
                p_err_code := errnums.C_SA_VARIABLE_NOTFOUND;
                Return v_lngErrCode;
        end;
        begin
            SELECT CORRECTIONNUMBER into v_count FROM ODMAST WHERE ORDERID= v_strCancelOrderID;
            plog.debug (pkgctx, 'Number of corection from original:' || v_count);
            If v_dblCorrecionNumber <= v_count Then
                p_err_code := errnums.C_OD_OVER_NUMBER_CORRECTION;
                Return v_lngErrCode;
            end if;
        exception
            when no_data_found then
                p_err_code := errnums.C_OD_ORDER_NOT_FOUND;
                Return v_lngErrCode;
        end;
        --Kiem tra xem so luong yeu cau huy co phu hop khong
        SELECT count(1) into v_count
                    FROM ODMAST WHERE ORDERID=v_strCancelOrderID
                    AND ADJUSTQTTY=0 AND CANCELQTTY=0 OR REMAINQTTY>= v_dblORDERQTTY;
        if not v_count>0 then
            --So luong huy khong hop le: Lenh da bi HUY, SUA hoac So luong yeu cau huy lon hon so luong con lai
            p_err_code := errnums.C_OD_INVALID_CANCELQTTY;
            Return v_lngErrCode;
        end if;
        --Xac dinh gia
        SELECT TRADEUNIT into v_dblTradeUnit FROM SECURITIES_INFO WHERE CODEID=v_strCODEID;
        v_dblQUOTEPRICE := v_dblQUOTEPRICE * v_dblTradeUnit;
        v_dblLIMITPRICE := v_dblLIMITPRICE * v_dblTradeUnit;
        --Tao lenh huy
        --Neu la lenh mua thi BORS = 'D', ban BORS = 'E'
        v_strBORS := 'D';
        v_strOODStatus := 'S';
        v_strEDSTATUS := 'N';
        v_strWASEDSTATUS := 'N';
        v_strOODStatus := 'N';
        if v_strTLTXCD='8882' then
            v_strBORS := 'D';
            v_strEDSTATUS := 'C';
            v_strWASEDSTATUS := 'W';
        elsif v_strTLTXCD='8884' then
            v_strBORS := 'D';
            v_strEDSTATUS := 'A';
            v_strWASEDSTATUS := 'S';
        elsif v_strTLTXCD='8883' then
            v_strBORS := 'E';
            v_strEDSTATUS := 'C';
            v_strWASEDSTATUS := 'W';
        elsif v_strTLTXCD='8885' then
            v_strBORS := 'E';
            v_strEDSTATUS := 'A';
            v_strWASEDSTATUS := 'S';
        end if;
        v_strSEACCTNO := v_strAFACCTNO || v_strCODEID;
        v_strCIACCTNO := v_strAFACCTNO;
        v_strSecuredAmt := v_dblQUOTEPRICE * v_dblORDERQTTY * v_dblBRATIO / 100;
        plog.debug (pkgctx, 'Insert into ODMAST & OOD');
        --Ghi nhan vao so lenh ODMAST voi trang thai la send
        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                        TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                        EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                        QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                                        EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,REFORDERID,EDSTATUS, TLID,Quoteqtty)
                        VALUES ( v_strORDERID , v_strCUSTID , v_strACTYPE , v_strCODEID , v_strAFACCTNO , v_strSEACCTNO , v_strCIACCTNO
                                        , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  'DD/MM/RRRR' ), to_char(sysdate,'HH24:MI:SS')
                                        ,TO_DATE( v_strEXPDATE ,  'DD/MM/RRRR' ), v_dblBRATIO , v_strTIMETYPE
                                        , v_strEXECTYPE , v_strNORK , v_strMATCHTYPE , v_strVIA
                                        , v_dblCLEARDAY , v_strCLEARCD ,'7','7', v_strPRICETYPE
                                        , v_dblQUOTEPRICE ,0, v_dblLIMITPRICE , v_dblORDERQTTY
                                        , v_dblORDERQTTY , v_dblQUOTEPRICE , v_dblORDERQTTY
                                        ,0,0,0,0,0,0,'001', v_strVOUCHER , v_strCONSULTANT ,
                                        v_strCancelOrderID , v_strEDSTATUS, v_strTLID ,v_dblQuoteqtty);
        --Neu la lenh sua chua Send thi sinh them lenh moi vao trong he thong voi trang thai la send
        --Ghi nhan vao so lenh day di
        INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                        BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,
                        OODSTATUS,TXDATE,TXNUM,DELTD,BRID,reforderid)
        VALUES          ( v_strORDERID , v_strCODEID , v_strSymbol , replace(v_strCUSTODYCD,'.', '') , v_strBORS , v_strMATCHTYPE
                        , v_strNORK , v_dblQUOTEPRICE , v_dblORDERQTTY , v_dblBRATIO , v_strOODStatus ,
                        TO_DATE( p_txmsg.txdate ,  'DD/MM/RRRR' ), p_txmsg.txnum ,'N', p_txmsg.brid , v_strCancelOrderID );

        --Ghi nhan vao ODCHANING de ngan khong cho lenh HUY/SUA khac nhap vao
        begin
            plog.debug (pkgctx, 'Insert into ODCHANGING');
            INSERT INTO ODCHANGING (ORGORDERID, ORDERID) VALUES ( v_strCancelOrderID , v_strORDERID);
        exception
        when others then
            plog.debug (pkgctx, 'ODCHANGING invalid keys');
            p_err_code := errnums.C_OOD_STATUS_INVALID;
            Return v_lngErrCode;
        end;
        If v_strCUROODSTATUS = 'N' Then
            --'Tao ban ghi trong ODQUEUE de ngan khong cho day len san: E-Huy, Sua ban, D-Huy,Sua mua
            BEGIN
                INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = v_strCancelOrderID;
            EXCEPTION
            WHEN OTHERS THEN
                plog.error (pkgctx, v_strCancelOrderID || ': Lenh da vao queue');
                p_err_code := errnums.C_OOD_STATUS_INVALID;
                Return v_lngErrCode;
            END;
            plog.debug (pkgctx, 'Status=N so prevent from Cancel, amend');
            Update OOD SET OODSTATUS =  v_strBORS
                        WHERE ORGORDERID= v_strCancelOrderID
                        AND OODSTATUS = 'N';
            If v_strTLTXCD = '8882' Or v_strTLTXCD = '8883' Then
                --Lenh huy se complete luon: TRANG THAI OOD CUA LENH HUY se la (E-Huy ban, D-Huy mua) luon
                UPDATE OOD SET OODSTATUS =  v_strBORS
                            WHERE ORGORDERID= v_strORDERID;
            end if;
            If v_strTLTXCD= '8882' Then
                UPDATE ODMAST SET REMAINQTTY=0, CANCELQTTY=ORDERQTTY, EDSTATUS= v_strWASEDSTATUS,CANCELSTATUS='X'  WHERE ORDERID= v_strCancelOrderID;
                If v_strTIMETYPE = 'G' Then
                    --4.Neu lenh GTC thi huy luon lenh yeu cau
                    --UPDATE FOMAST SET DELTD='Y',REFACCTNO=v_strORDERID  WHERE ORGACCTNO=v_strCancelOrderID;
                    UPDATE FOMAST SET REMAINQTTY=REMAINQTTY - v_dblORDERQTTY ,CANCELQTTY=CANCELQTTY + v_dblORDERQTTY , REFACCTNO=v_strORDERID
                         WHERE ACCTNO = (SELECT FOACCTNO FROM ODMAST WHERE ORDERID=v_strCancelOrderID);
                End If;

            elsIf v_strTLTXCD= '8883' Then
                UPDATE ODMAST SET REMAINQTTY=0, CANCELQTTY=ORDERQTTY, EDSTATUS=v_strWASEDSTATUS,CANCELSTATUS='X' WHERE ORDERID=v_strCancelOrderID;
                If v_strTIMETYPE = 'G' Then
                    --4.Neu lenh GTC thi huy luon lenh yeu cau
                    --UPDATE FOMAST SET DELTD='Y',REFACCTNO=v_strORDERID  WHERE ORGACCTNO= v_strCancelOrderID;
                    UPDATE FOMAST SET REMAINQTTY=REMAINQTTY - v_dblORDERQTTY ,CANCELQTTY=CANCELQTTY + v_dblORDERQTTY , REFACCTNO=v_strORDERID
                         WHERE ACCTNO = (SELECT FOACCTNO FROM ODMAST WHERE ORDERID=v_strCancelOrderID);
                End If;
            end if;
        end if;
    Else
        --Xoa lenh day di
        plog.debug (pkgctx, 'Delete correcttion request!');
        UPDATE OOD SET DELTD='Y' WHERE TXNUM=p_txmsg.txnum AND TXDATE=to_date(p_txmsg.txdate,'DD/MM/RRRR');
        --Xoa  ODCHANGING
        DELETE FROM ODCHANGING WHERE ORGORDERID=v_strCancelOrderID;
        --Neu truoc day da Block lenh goc khong cho day thi phai Unblock
        UPDATE OOD SET OODSTATUS = 'N'
                    WHERE ORGORDERID= v_strCancelOrderID
                    AND (OODSTATUS = 'E' OR OODSTATUS = 'D');
        --Xoa trong ODQUEUE, ODQUEUE.OODSTATUS=v_strBORS
        DELETE FROM ODQUEUE
                    WHERE ORGORDERID= v_strCancelOrderID
                    AND (OODSTATUS = 'E' OR OODSTATUS = 'D');
        If v_strTIMETYPE = 'G' Then
            --4.Neu lenh GTC thi huy luon lenh yeu cau
            --UPDATE FOMAST SET DELTD='N',REFACCTNO='' WHERE ORGACCTNO=v_strCancelOrderID;
            UPDATE FOMAST SET REMAINQTTY=REMAINQTTY + v_dblORDERQTTY ,CANCELQTTY=CANCELQTTY - v_dblORDERQTTY , REFACCTNO=''
                         WHERE ACCTNO = (SELECT FOACCTNO FROM ODMAST WHERE ORDERID=v_strCancelOrderID);
        End If;
    end if;
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

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
         plog.init ('TXPKS_#8883EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8883EX;
/
