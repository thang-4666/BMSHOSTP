SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8876ex
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
 **  System      20/10/2009     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out  tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in  out tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
  FUNCTION fn_txAftAppUpdate(p_txmsg in  tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
  FUNCTION fn_txPreAppUpdate(p_txmsg in  tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#8876ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
    l_STATUS varchar2(1);
    l_PP number(20,4);
    l_PPse number(20,4);
    l_AVLLIMIT number(20,4);
    l_margintype            CHAR (1);
    l_actype                VARCHAR2 (4);
    l_groupleader           VARCHAR2 (10);

    l_mrratiorate number(20,4);
    l_marginprice number(20,4);
    l_marginrefprice number(20,4);
    l_mrpriceloan number(20,4);
    l_orderprice number(20,4);
    l_deffeerate number(10,6);
    l_chksysctrl varchar2(1);
    l_ismarginallow varchar2(1);
    l_activests varchar2(1);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;

    l_remainamt number;
    l_PPMax number(20,0);
    l_istrfbuy char(1);
    l_seclimit number;
    V_STRISDISPOSAL VARCHAR2(5);
    V_STREXECTYPE   VARCHAR2(10);
    v_COUNT         NUMBER;
    V_ADVAMT        NUMBER;

    l_chkmarginbuy char(1);
   -- l_status varchar2(1);
   l_lngErrCode number(20,0);
    l_err_param varchar2(1000);
    l_count number(20,0);
    l_strCUSTID varchar2(30);
    l_strCODEID varchar2(30);
    l_strACTYPE varchar2(30);
    l_strAFACCTNO varchar2(30);
    l_strCIACCTNO varchar2(30);
    l_strAFSTATUS varchar2(30);
    l_strSEACCTNO varchar2(30);
    l_strCUSTODYCD varchar2(30);
    l_strTIMETYPE varchar2(30);
    l_strVOUCHER varchar2(30);
    l_strCONSULTANT varchar2(30);
    l_strORDERID varchar2(30);
    l_strBORS varchar2(30);
    l_strContrafirm varchar2(30);
    l_strContrafirm2 varchar2(30);
    l_strContraCus varchar2(30);
    l_strPutType varchar2(30);
    l_strEXPDATE varchar2(30);
    l_strEXECTYPE varchar2(30);
    l_strNORK varchar2(30);
    l_strMATCHTYPE varchar2(30);
    l_strVIA varchar2(30);
    l_strCLEARCD varchar2(30);
    l_strPRICETYPE varchar2(30);
    l_strDESC varchar2(300);
    l_strTRADEPLACE varchar2(30);
    l_strSYMBOL varchar2(30);
    l_strMarginType varchar2(30);
    l_strBUYIFOVERDUE varchar2(30);
    l_strAFTYPE varchar2(30);
    l_dblCLEARDAY number(30,4);
    l_dblQUOTEPRICE number(30,9);
    l_dblORDERQTTY number(30,4);
    l_dblBRATIO number(30,4);
    l_dblLIMITPRICE number(30,4);
    l_dblAFADVANCELIMIT number(30,4);
    l_dblODBALANCE  number(30,4);
    l_dblODTYPETRADELIMIT number(30,4);
    l_dblAFTRADELIMIT number(30,4);
    l_dblALLOWBRATIO number(30,4);
    l_dblDEFFEERATE number(30,4);
    l_dblMarginRate  number(30,4);
    l_dblMarginRatio number(30,4);
    l_dblSecuredRatioMin number(30,4);
    l_dblSecuredRatioMax number(30,4);
    l_dblTyp_Bratio number(30,4);
    l_dblAF_Bratio number(30,4);
    ml_dblSecureRatio number(30,4);
    l_dblRoom number(30,4);
    l_dblTraderID  number(30,4);
    l_blnReversal boolean;
    l_strHalt char(1);
    l_strCompanyFirm varchar2(50);
    l_dblTradeLot number(30,4);
    l_dblTradeUnit number(30,4);
    l_dblFloorPrice number(30,4);
    l_dblCeilingPrice number(30,4);
    l_dblTickSize number(30,4);
    l_dblFromPrice number(30,4);
    l_dblMarginMaxQuantity  number(30,4);
    l_dblBfAccoutMarginRate number(30,4);
    l_dblAfAccoutMarginRate number(30,4);
    l_dblLongPosision number(30,4);
    l_dblBuyMinAmount number(30,4);
    l_dblSellMinAmount number(30,4);
    l_dblCheckMinAmount number(30,4);
    l_strPreventMinOrder varchar2(30);
    l_strTRADEBUYSELL  varchar2(30);
    l_strOVRRQD varchar2(100);
    l_strSETYPE varchar2(10);
    Pl_REFCURSOR   PKG_REPORT.REF_CURSOR;
    l_dblAvlLimit number(30,4);
    l_ISMARGIN varchar2(1);
    l_strClientID varchar2(10);
    l_dblTradeStatus number;

    v_strORDERTRADEBUYSELL  Varchar2(10);
    l_strControlCode Varchar2(10);
    v_strTemp  Varchar2(100);
    v_strSysCheckBuySell Varchar2(100);

    L_SECTYPE VARCHAR2(6);

    l_CheckMaxSameOrd varchar2(10);
      l_isEXLOCKCOSTODYCD varchar2(10);
      l_isoddlot varchar2(10);
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
    l_isoddlot := 'N';--ThangPV chinh sua lo le HSX 19-05-2022
    l_remainamt:=0;
    V_STRISDISPOSAL:= p_txmsg.txfields('74').VALUE;
    V_STREXECTYPE:= p_txmsg.txfields('22').VALUE;
    IF p_txmsg.deltd = 'N' THEN


        select status into l_status from cimast where afacctno = p_txmsg.txfields('03').value;

        IF ( INSTR('G',l_STATUS) > 0) THEN
            p_err_code := '-400100';
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        l_CheckMaxSameOrd := fn_check_maxsameorder(p_txmsg.txfields('01').value, p_txmsg.txfields('03').value,p_txmsg.txfields('22').value, p_txmsg.txfields('24').value, p_txmsg.txfields('27').value, p_txmsg.txfields('11').value, p_txmsg.txfields('12').value);
        if l_CheckMaxSameOrd <> '0' then
            p_err_code := l_CheckMaxSameOrd;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if txpks_prchk.fn_RoomLimitCheck(p_txmsg.txfields('03').value, p_txmsg.txfields('01').value, to_number(p_txmsg.txfields('12').value), p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        SELECT cf.activests,cf.custodycd
            INTO l_activests,l_strCUSTODYCD
        FROM cfmast cf, afmast mst
        WHERE cf.custid = mst.custid
            AND mst.acctno = p_txmsg.txfields('03').value;

        if l_activests <> 'Y' then
            p_err_code := '-100139'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        SELECT mr.mrtype, af.actype, mst.groupleader, af.istrfbuy, af.chkmarginbuy
            INTO l_margintype, l_actype, l_groupleader, l_istrfbuy, l_chkmarginbuy
        FROM afmast mst, aftype af, mrtype mr
        WHERE mst.actype = af.actype
            AND af.mrtype = mr.actype
            AND mst.acctno = p_txmsg.txfields('03').value;

    l_isEXLOCKCOSTODYCD:='N';
    select count(1) into l_count from EXLOCKCOSTODYCD where custodycd =l_strCUSTODYCD  and TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) BETWEEN valdate and expdate  and deltd <>'Y' ;
    if l_count > 0 then
         l_isEXLOCKCOSTODYCD:='Y';
    end if;



        select nvl(rsk.mrratioloan,0),nvl(rsk.mrpriceloan,0), nvl(lnt.chksysctrl,'N'), nvl(rsk.ismarginallow,'N')
            into l_mrratiorate,l_mrpriceloan, l_chksysctrl, l_ismarginallow
        from afmast af, aftype aft, lntype lnt,
            (select * from afserisk where codeid = p_txmsg.txfields('01').value) rsk--,
            --(select * from v_getbuyorderinfo where afacctno = p_txmsg.txfields('03').value) b
        where af.actype = aft.actype
        and aft.lntype = lnt.actype(+)
        and af.actype = rsk.actype(+)
       -- and af.acctno = b.afacctno(+)
        and af.acctno = p_txmsg.txfields('03').value;

        select count(*) into v_COUNT
        from afmast af, aftype aft, lntype lnt,
            (select * from afserisk where codeid = p_txmsg.txfields('01').value) rsk
        where af.actype = aft.actype
        and aft.lntype = lnt.actype
        and af.actype = rsk.actype
        and af.acctno = p_txmsg.txfields('03').value;

        --Kiem tra neu tai khoan margin ma co tham so chan mua ngoai danh muc thi bao loi
        if l_chkmarginbuy='Y' and l_margintype in ('S','T') then
            if  v_COUNT <= 0 then --Chung khoan khong duoc margin
                p_err_code := '-400099';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;



        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');
        l_PP := l_CIMASTcheck_arr(0).PP;
        l_AVLLIMIT := l_CIMASTcheck_arr(0).AVLLIMIT;
        l_STATUS := l_CIMASTcheck_arr(0).STATUS;
        V_ADVAMT:=l_CIMASTcheck_arr(0).AVLADVANCE;
        select marginrefprice, marginprice into l_marginrefprice, l_marginprice from securities_info where codeid = p_txmsg.txfields('01').value;

        --Begin Lay thong tin Ham muc chung khoan con lai
        begin
            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end) into l_seclimit
            from securities_risk rsk,
                (select * from afselimit where afacctno = p_txmsg.txfields('03').value) selm
            where rsk.codeid = selm.codeid(+)
            and rsk.codeid = p_txmsg.txfields('01').value;
        exception when others then
            l_seclimit:=0;
        end;
        if l_seclimit>0 then
            begin
                select l_seclimit - nvl(aclm.seqtty,0)*  l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) into l_remainamt
                from v_getaccountseclimit aclm where afacctno = p_txmsg.txfields('03').value and codeid = p_txmsg.txfields('01').value;
            exception when others then
                l_remainamt:=l_seclimit;
            end;
        end if;
        l_remainamt:= greatest(l_remainamt,0);
        l_PPMax:= floor(l_PP + least(l_remainamt,p_txmsg.txfields('12').value * l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan)));
        --End Lay thong tin Ham muc chung khoan con lai
        --
        IF NOT ( INSTR('AT',l_STATUS) > 0) THEN
            p_err_code := '-400100';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        if l_margintype not in ('S','T') then
            IF NOT (ceil(to_number(l_PP)) >= to_number(ROUND(p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('13').value*p_txmsg.txfields('98').value/p_txmsg.txfields('99').value,0))) THEN
                p_err_code := '-400116';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else

            select deffeerate/100 into l_deffeerate from odtype where actype = p_txmsg.txfields('02').value;

            if (l_chksysctrl = 'Y' and l_ismarginallow = 'N') then
                l_PPse:=l_PP;
                IF NOT ceil(l_PPse) >= to_number(ROUND((1 + l_deffeerate)*p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('98').value,0)) THEN
                    p_err_code := '-400116';
                    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
            else
                if l_chksysctrl = 'Y' then
                    if l_PP > 0 then
                        l_PPse:= l_PP / (1 + l_deffeerate - l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) /(to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('98').value)));
                    else
                        l_PPse:=l_PP;
                    end if;
                else
                    if l_PP > 0 then
                        l_PPse:= l_PP / (1 + l_deffeerate - l_mrratiorate/100 * least(l_marginprice, l_mrpriceloan) /(to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('98').value)));
                    else
                        l_PPse:=l_PP;
                    end if;
                end if;
            l_PPse:= least(l_PPMax,l_PPse);
            IF NOT ceil(l_PPse) >= to_number(ROUND(p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('98').value,0)) THEN
                    p_err_code := '-400116';
                    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
            end if;
        end if;

        IF NOT (to_number(l_AVLLIMIT) >= to_number(p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('98').value+p_txmsg.txfields('40').value)) THEN
            p_err_code := '-400117';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        --Them rule chan han muc theo nhom
        if fn_checkMrlimitByGroup(p_txmsg.txfields('03').value, to_number(p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('98').value+p_txmsg.txfields('40').value)) <0 then
            p_err_code := '-400217';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if not cspks_odproc.fn_checkTradingAllow(p_txmsg.txfields('03').value, p_txmsg.txfields('01').value, 'B' , p_err_code) then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            Return errnums.C_BIZ_RULE_INVALID;
        end if;
         --PhuongHT edit: tieu khoan Margin trang thai CALL : ko duoc dat lenh ban thuong
         IF V_STRISDISPOSAL <> 'Y' AND l_strMATCHTYPE <> 'P' and l_isEXLOCKCOSTODYCD ='N' THEN
          IF v_strEXECTYPE='NS' THEN
             SELECT COUNT(*) INTO v_COUNT FROM VW_MR0003_ALL WHERE ACCTNO=p_txmsg.txfields('03').value;
             IF v_COUNT>0 THEN
                 p_err_code := '-180067';
                 plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                 RETURN errnums.C_BIZ_RULE_INVALID;
             END IF;
           ELSIF v_strEXECTYPE='NB' THEN
              SELECT COUNT(*) INTO v_COUNT
              FROM CIMAST CI
              WHERE CI.AFACCTNO=p_txmsg.txfields('03').VALUE
              AND CI.OVAMT-GREATEST(0,CI.BALANCE+NVL(V_ADVAMT,0)- CI.BUYSECAMT) >0;
              IF v_COUNT>0 THEN
                 p_err_code:= -180068;--ERR_SA_INVALID_SECSSION
                 plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                 RETURN errnums.C_BIZ_RULE_INVALID;
               END IF;
           END IF;
          END IF;
          -- end of PhuongHT
    END IF;

    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    if p_txmsg.deltd='Y' then
        l_blnReversal:=true;
    else
        l_blnReversal:=false;
    end if;
    if l_blnReversal then
        --Xoa giao dich thi check
        SELECT count(1) into l_count FROM ODMAST WHERE TXNUM=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND ORSTATUS IN ('1','2','8');
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_ODMAST_CANNOT_DELETE);
            p_err_code :=errnums.C_OD_ODMAST_CANNOT_DELETE;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        end if;
    else
        --Make giao dich thi check
        l_strCODEID := p_txmsg.txfields('01').value;
        l_strACTYPE := p_txmsg.txfields('02').value;
        l_strAFACCTNO := p_txmsg.txfields('03').value;
        l_strTIMETYPE := p_txmsg.txfields('20').value;
        l_strEXPDATE := p_txmsg.txfields('21').value;
        l_strEXECTYPE := p_txmsg.txfields('22').value;
        l_strNORK := p_txmsg.txfields('23').value;
        l_strMATCHTYPE := p_txmsg.txfields('24').value;
        l_strVIA := p_txmsg.txfields('25').value;
        l_strCLEARCD := p_txmsg.txfields('26').value;
        l_strPRICETYPE := p_txmsg.txfields('27').value;
        l_dblCLEARDAY := p_txmsg.txfields('10').value;
        l_dblQUOTEPRICE := p_txmsg.txfields('11').value;
        l_dblORDERQTTY := p_txmsg.txfields('12').value;
        l_dblBRATIO := p_txmsg.txfields('13').value;
        l_dblLIMITPRICE := p_txmsg.txfields('14').value;
        l_strVOUCHER := p_txmsg.txfields('28').value;
        l_strCONSULTANT := p_txmsg.txfields('29').value;
        l_strORDERID := p_txmsg.txfields('04').value;
        l_strDESC := p_txmsg.txfields('30').value;
        l_strContrafirm := p_txmsg.txfields('31').value;
        l_strContraCus := replace(p_txmsg.txfields('71').value,'.','');
        l_strPutType := replace(p_txmsg.txfields('72').value,'.','');
        l_strContrafirm2 := replace(p_txmsg.txfields('73').value,'.','');
        l_strClientID := substr(p_txmsg.txfields('33').value,1,10);
        l_dblTradeStatus := 0;--p_txmsg.txfields('90').value;
        l_dblALLOWBRATIO:=1;
        SELECT count(1) into l_count  FROM ODTYPE WHERE STATUS='Y' AND ACTYPE=l_strACTYPE;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_ODTYPE_NOTFOUND);
            p_err_code := errnums.C_OD_ODTYPE_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT TRADELIMIT,BRATIO/100,DEFFEERATE/100 into l_dblODTYPETRADELIMIT,l_dblALLOWBRATIO,l_dblDEFFEERATE  FROM ODTYPE WHERE STATUS='Y' AND ACTYPE=l_strACTYPE;
        end if;
        SELECT count(1) into l_count  FROM AFMAST af,AFTYPE aft, MRTYPE mrt WHERE ACCTNO=l_strAFACCTNO  AND af.ACTYPE=aft.ACTYPE and aft.MRTYPE=mrt.ACTYPE;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CF_AFMAST_NOTFOUND);
            p_err_code := errnums.C_CF_AFMAST_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        else
            l_strCIACCTNO := l_strAFACCTNO;
            l_strSEACCTNO := l_strAFACCTNO || l_strCODEID;
            SELECT af.CUSTID,af.STATUS,af.ADVANCELINE,af.BRATIO,af.MRIRATE,af.mriratio,mrt.MRTYPE,MRT.BUYIFOVERDUE,af.ACTYPE AFTYPE, case when mrt.mrtype = 'T' and nvl(lnt.chksysctrl,'N') = 'Y' then 'Y' else 'N' end
                into l_strCUSTID,l_strAFSTATUS,l_dblAFADVANCELIMIT,l_dblALLOWBRATIO,l_dblMarginRate,l_dblMarginRatio,l_strMarginType,l_strBUYIFOVERDUE,l_strAFTYPE, l_ISMARGIN
            FROM AFMAST af,AFTYPE aft, MRTYPE mrt, lntype lnt
            WHERE ACCTNO= l_strAFACCTNO  AND af.ACTYPE=aft.ACTYPE and aft.MRTYPE=mrt.ACTYPE and aft.lntype = lnt.actype(+);
        end if;
        --Kiem tra tai khoan Margin neu bi qua han va l_strBUYIFOVERDUE="N" thi khong cho dat lenh mua
        If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') And l_strBUYIFOVERDUE = 'N' Then
            SELECT count(1) into l_count FROM CIMAST CI WHERE OVAMT >0 AND CI.ACCTNO= l_strCIACCTNO;
            if l_count>0 then
                plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_MR_ACCTNO_OVERDUE);
                p_err_code :=errnums.C_MR_ACCTNO_OVERDUE;
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                return errnums.C_BIZ_RULE_INVALID;
            end if;
        End If;
        ---DungNH sua check tieu khoan phong toa khong duoc phep mua ba
        If l_strAFSTATUS = 'B' Then
                p_err_code := '-700086';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                return errnums.C_BIZ_RULE_INVALID;
        End If;
        ---end DungNH
        --Kiem tra tai khoan CI co ton tai hay khong
        SELECT count(1) into l_count FROM CIMAST WHERE ACCTNO=l_strCIACCTNO;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CI_CIMAST_NOTFOUND);
            p_err_code :=errnums.C_CI_CIMAST_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT (BALANCE-ODAMT) into l_dblODBALANCE FROM CIMAST WHERE ACCTNO=l_strCIACCTNO;
        end if;

        --kIEM TRA TAI KHOAN se co ton tai hay khong
        SELECT count(1) into l_count FROM SEMAST WHERE ACCTNO=l_strSEACCTNO;
        if l_count<=0 then
          --Neu khong co thi tu dong mo tai khoan
          SELECT TYP.SETYPE into l_strSETYPE FROM AFMAST AF, AFTYPE TYP WHERE AF.ACTYPE=TYP.ACTYPE AND AF.ACCTNO= l_strAFACCTNO;
          INSERT INTO SEMAST (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,
                            OPNDATE,LASTDATE,STATUS,IRTIED,IRCD,
                            COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,
                            STANDING,WITHDRAW,DEPOSIT,LOAN)
                      VALUES (l_strSETYPE, l_strCUSTID, l_strSEACCTNO , l_strCODEID , l_strAFACCTNO ,
                      p_txmsg.txdate,p_txmsg.txdate,'A','Y','001',
                      0,0,0,0,0,0,0,0,0);
        end IF;

        --Kiem tra ma khach hang co ton tai hay khong
        SELECT count(1) into l_count FROM CFMAST WHERE CUSTID=l_strCUSTID;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CF_CUSTOMER_NOTFOUND);
            p_err_code :=errnums.C_CF_CUSTOMER_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT CUSTODYCD into l_strCUSTODYCD FROM CFMAST WHERE CUSTID=l_strCUSTID;
            --Check xem co tieu khoan nao bi call khong
            if not cspks_cfproc.pr_check_Account_Call(l_strCUSTODYCD) then
                p_err_code := '-200900';
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
        SELECT HALT,TRADEPLACE,SYMBOL,sectype
            into l_strHalt,l_strTRADEPLACE,l_strSYMBOL, L_SECTYPE
            FROM SBSECURITIES WHERE CODEID= l_strCODEID;
        --LoLeHSX
        /*If l_strHalt = 'Y' Then
            p_err_code :=errnums.C_OD_CODEID_HALT;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        end if;*/
        --End LoLeHSX
        If (l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC Or l_strTRADEPLACE = errnums.gc_TRADEPLACE_HNCSTC) And Length(Trim(l_strCUSTODYCD)) = 0 Then
            p_err_code :=errnums.C_OD_LISTED_NEEDCUSTODYCD;
            Return errnums.C_BIZ_RULE_INVALID;
        End If;
        If l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC And (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'NS') Then
            --Tham so ham Check TraderID
            SELECT FNC_CHECK_TRADERID( l_strMATCHTYPE ,substr(l_strEXECTYPE ,2,1), l_strVIA ) TRD into l_dblTraderID FROM DUAL;
            If l_dblTraderID = 0 Then
                p_err_code :=errnums.C_OD_TRADERID_NOT_INVALID;
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                Return errnums.C_BIZ_RULE_INVALID;
            End If;
        End If;
        --Check contra sell order when place buy order (2PT)
        If (l_strTRADEPLACE = errnums.gc_TRADEPLACE_UPCOM) And (l_strMATCHTYPE = 'P') And (l_strPutType = 'N') Then
            select varvalue into l_strCompanyFirm from sysvar where grname ='SYSTEM' and varname='COMPANYCD';
            --Neu la lenh Upcom thoa thuan cung cong ty phai kiem tra
            If l_strEXECTYPE = 'NB' Then
                If (l_strContrafirm2 = l_strCompanyFirm Or l_strContrafirm2 = '') Then
                    l_strContrafirm2 := l_strCompanyFirm;
                    If l_strContraCus <> '' Then
                        SELECT COUNT(ROWNUM) into l_count FROM ODMAST OD,OOD OUTOD
                        WHERE OD.orderid = OUTOD.orgorderid AND OD.orstatus IN ('1','2','8')
                        AND OUTOD.oodstatus IN ('N','S') AND OD.orderid =  l_strContraCus  AND OD.EXECTYPE='NS'
                        AND OD.matchtype='P' AND OD.CODEID=l_strCODEID  AND OD.QUOTEPRICE=(l_dblQUOTEPRICE) * 1000
                        AND OD.ORDERQTTY= l_dblORDERQTTY  AND OD.PUTTYPE='N' AND OD.CODEID IN (SELECT CODEID FROM SBSECURITIES WHERE TRADEPLACE= l_strTRADEPLACE );

                        If l_count<=0 Then
                            p_err_code :=errnums.C_OD_CONTRA_ORDER_NOT_FOUND;
                            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                            Return errnums.C_BIZ_RULE_INVALID;
                        End If;
                    Else
                        p_err_code :=errnums.C_OD_CONTRA_ORDER_NOT_FOUND;
                        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                        Return errnums.C_BIZ_RULE_INVALID;
                    End If;
                End If;
            End If;
        End If;
        SELECT count(1) into l_count FROM SECURITIES_INFO INF, SECURITIES_RISK RSK WHERE INF.CODEID= l_strCODEID  AND INF.CODEID=RSK.CODEID(+);
        if l_count<=0 then
            p_err_code :=errnums.C_OD_SECURITIES_INFO_UNDEFINED;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            Return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT TRADELOT,TRADEUNIT,NVL(RSK.MRMAXQTTY,0) MRMAXQTTY,nvl(BMINAMT,0) BMINAMT,nvl(SMINAMT,0) SMINAMT,FLOORPRICE,CEILINGPRICE,CURRENT_ROOM,TRADEBUYSELL
            into l_dblTradeLot,l_dblTradeUnit,l_dblMarginMaxQuantity,l_dblBuyMinAmount,l_dblSellMinAmount,l_dblFloorPrice,l_dblCeilingPrice,l_dblRoom,l_strTRADEBUYSELL
            FROM SECURITIES_INFO INF, SECURITIES_RISK RSK WHERE INF.CODEID= l_strCODEID  AND INF.CODEID=RSK.CODEID(+);

            --'Kiem tra chan min,max amount
            select varvalue into l_strPreventMinOrder from sysvar where grname ='SYSTEM' and varname ='PREVENTORDERMIN';
            If l_strPreventMinOrder = 'Y' Then
                If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') Then
                    l_dblCheckMinAmount := l_dblBuyMinAmount;
                Else
                    l_dblCheckMinAmount := l_dblSellMinAmount;
                End If;
                If l_dblQUOTEPRICE * l_dblORDERQTTY * l_dblTradeUnit < l_dblCheckMinAmount Then
                    p_err_code :=errnums.C_OD_ORDER_UNDER_MIN_AMOUNT;
                    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    Return errnums.C_BIZ_RULE_INVALID;
                End If;
            End If;
            If l_dblTradeUnit > 0 Then
                l_dblQUOTEPRICE := Round(l_dblQUOTEPRICE * l_dblTradeUnit, 6);
            End If;
            --Kiem tra lenh mua nha dau tu nuoc ngoai co con ROOM
            If l_strEXECTYPE = 'NB' And (substr(l_strCUSTODYCD, 4, 1) = 'F' Or substr(l_strCUSTODYCD, 4, 1) = 'E') Then
                If l_dblORDERQTTY > l_dblRoom  Then

                    IF  substr(l_strClientID, 4, 1) = 'F'  AND l_strMATCHTYPE = 'P'  THEN
                       -- THOA THUAN CUNG CTY CUNG LA NGUOI NC NGOAI THI KHONG CHECK ROOM
                       NULL;
                   ELSE
                        if nvl(p_txmsg.txfields('85').value,'N') <> 'O' then
                            if not(L_SECTYPE in ('006','003') and l_strTRADEPLACE in ('007','008')) then
                               p_err_code :=errnums.C_OD_ROOM_NOT_ENOUGH;
                               plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                               Return errnums.C_BIZ_RULE_INVALID;
                            end if ;
                        end if;
                 END IF;
                End If;
            End If;
            --ThangPV chinh sua lo le HSX 27-04-2022
             /* If l_dblTradeLot > 0 And l_strMATCHTYPE <> 'P' Then
               if    l_strTRADEPLACE ='001' or (l_strTRADEPLACE in ('002','005') and l_dblORDERQTTY>l_dblTradeLot) then
                   If l_dblORDERQTTY Mod l_dblTradeLot <> 0 Then
                        p_err_code :=errnums.C_OD_QTTY_TRADELOT_INCORRECT;
                        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    Return errnums.C_BIZ_RULE_INVALID;
                    End If;
               end if ;
            End If; */
            --End ThangPV chinh sua lo le HSX 27-04-2022
                --Kiem tra voi lenh LO thi gia phai nam trong khoang tran san
            If l_strPRICETYPE = 'LO' and l_dblTradeStatus = 0 and instr('003,006',L_SECTYPE) <= 0  Then
                If l_dblQUOTEPRICE < l_dblFloorPrice Or l_dblQUOTEPRICE > l_dblCeilingPrice Then
                    p_err_code :=errnums.C_OD_LO_PRICE_ISNOT_FLOOR_CEIL;
                    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    Return errnums.C_BIZ_RULE_INVALID;
                End If;
            End If;
            --Voi lenh LO, stop limit thi kiem tra tick size cua gia
            If l_strPRICETYPE = 'LO' Or l_strPRICETYPE = 'SL' Then
                SELECT count(1) into l_count FROM SECURITIES_TICKSIZE WHERE CODEID=l_strCODEID  AND STATUS='Y'
                       AND TOPRICE>= l_dblQUOTEPRICE AND FROMPRICE<=l_dblQUOTEPRICE;
                if l_count<=0 then
                    --Chua dinh nghia TICKSIZE
                    p_err_code :=errnums.C_OD_TICKSIZE_UNDEFINED;
                    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    Return errnums.C_BIZ_RULE_INVALID;
                else
                    SELECT FROMPRICE, TICKSIZE into l_dblFromPrice,l_dblTickSize
                    FROM SECURITIES_TICKSIZE WHERE CODEID=l_strCODEID  AND STATUS='Y'
                       AND TOPRICE>= l_dblQUOTEPRICE AND FROMPRICE<=l_dblQUOTEPRICE;
                    If (l_dblQUOTEPRICE - l_dblFromPrice) Mod l_dblTickSize <> 0 And l_strMATCHTYPE <> 'P' Then
                        p_err_code :=errnums.C_OD_TICKSIZE_INCOMPLIANT;
                        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                        Return errnums.C_BIZ_RULE_INVALID;
                    End If;
                end if;
            End If;

          -- Bat dau kiem tra lenh doi ung
            --ThangPV chinh sua lo le HSX 19-05-2022
            IF l_strTRADEPLACE = '001' AND l_dblORDERQTTY < l_dblTradeLot THEN
                l_isoddlot := 'Y';
            END IF;
            --end ThangPV chinh sua lo le HSX 19-05-2022
            IF NOT fnc_pass_tradebuysell(l_strAFACCTNO,p_txmsg.txdate,l_strCODEID,l_strEXECTYPE,l_strPRICETYPE,l_strMATCHTYPE,l_strTRADEPLACE,l_strSYMBOL,l_isoddlot) THEN  --ThangPV chinh sua lo le HSX 19-05-2022 them l_isoddlot
              -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    p_err_code :=errnums.C_OD_ORTHER_ORDER_WAITING;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                    Return l_lngErrCode;
              END IF;
        -- Ket thuc chan lenh doi ung

        --Ngay 07/3/2017 CW NamTv them check chung quyen dao han
            if fn_check_cwsecurities(l_strSYMBOL) <> 0 then
                p_err_code:=-100128;
                plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                return errnums.C_BIZ_RULE_INVALID;
            end if;
        --NamTv End

            --TrungNQ 07/06/2022:TPDN - chan lenh PLO, MTL,MAK, MOK voi TPDN
            if l_strTRADEPLACE in ('002','005') and l_sectype='012' and l_strPRICETYPE in ('MTL','MAK','MOK','PLO','ATC') then
                p_err_code := '-700138';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
            --Chan gd lo le TPDN

            if l_strTRADEPLACE in ('002','005') and l_sectype='012' and p_txmsg.txfields('12').value <l_dblTradeLot and l_strMATCHTYPE <>'P' then
                p_err_code := '-700139';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
            --TrungNQ 07/06/2022:TPDN

        End if;
        /*plog.debug(pkgctx,'l_strOVRRQD2: ' || l_strOVRRQD);
        If l_dblBRATIO < l_dblALLOWBRATIO Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_ORDERSECURERATIO;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;
        plog.debug(pkgctx,'l_strOVRRQD3: ' || l_strOVRRQD);*/
        plog.debug(pkgctx,'l_strOVRRQD4: ' || l_strOVRRQD);
        If length(Trim(Replace(l_strOVRRQD, errnums.OVRRQS_CHECKER_CONTROL, ''))) > 0 And (length(p_txmsg.chkid) = 0 or p_txmsg.chkid is null) Then
            p_err_code :=errnums.C_CHECKER1_REQUIRED;
        Else
            If InStr(l_strOVRRQD, errnums.OVRRQS_CHECKER_CONTROL) > 0 And (Length(p_txmsg.offid)  = 0 or p_txmsg.offid is null) Then
                p_err_code :=errnums.C_CHECKER2_REQUIRED;
            End If;
        End If;
    end if;
    if p_err_code =errnums.C_CHECKER1_REQUIRED or p_err_code =errnums.C_CHECKER2_REQUIRED then
    FOR I IN (
       SELECT ERRDESC,EN_ERRDESC FROM deferror
       WHERE ERRNUM= p_err_code
    ) LOOP
       l_err_param := i.errdesc;
    END LOOP;
    p_txmsg.txException('ERRSOURCE').value := '';
    p_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
    p_txmsg.txException('ERRCODE').value := p_err_code;
    p_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
    p_txmsg.txException('ERRMSG').value := l_err_param;
    p_txmsg.txException('ERRMSG').TYPE := 'System.String';

    end if;

    if nvl(p_txmsg.txfields('85').value,'N') = 'P' then
        SELECT MAX(STATUS) INTO l_STATUS FROM  ORDERPTACK
        WHERE trim(confirmnumber) = trim(p_txmsg.txfields('86').value );
        L_STATUS := NVL(L_STATUS,'W');
        IF L_STATUS = 'A' THEN
            p_err_code := '-70056';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            Return errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
    l_lngErrCode number(20,0);
    l_err_param varchar2(1000);
    l_count number(20,0);
    l_strCUSTID varchar2(30);
    l_strCODEID varchar2(30);
    l_strACTYPE varchar2(30);
    l_strAFACCTNO varchar2(30);
    l_strCIACCTNO varchar2(30);
    l_strAFSTATUS varchar2(30);
    l_strSEACCTNO varchar2(30);
    l_strCUSTODYCD varchar2(30);
    l_strTIMETYPE varchar2(30);
    l_strVOUCHER varchar2(30);
    l_strCONSULTANT varchar2(30);
    l_strORDERID varchar2(30);
    l_strBORS varchar2(30);
    l_strContrafirm varchar2(30);
    l_strContrafirm2 varchar2(30);
    l_strContraCus varchar2(30);
    l_strPutType varchar2(30);
    l_strEXPDATE varchar2(30);
    l_strEXECTYPE varchar2(30);
    l_strNORK varchar2(30);
    l_strMATCHTYPE varchar2(30);
    l_strVIA varchar2(30);
    l_strCLEARCD varchar2(30);
    l_strPRICETYPE varchar2(30);
    l_strDESC varchar2(300);
    l_strTRADEPLACE varchar2(30);
    l_strSYMBOL varchar2(30);
    l_strMarginType varchar2(30);
    l_strBUYIFOVERDUE varchar2(30);
    l_strAFTYPE varchar2(30);
    l_dblCLEARDAY number(30,4);
    l_dblQUOTEPRICE number(30,9);
    l_dblORDERQTTY number(30,4);
    l_dblBRATIO number(30,4);
    l_dblLIMITPRICE number(30,4);
    l_dblAFADVANCELIMIT number(30,4);
    l_dblODBALANCE  number(30,4);
    l_dblODTYPETRADELIMIT number(30,4);
    l_dblAFTRADELIMIT number(30,4);
    l_dblALLOWBRATIO number(30,4);
    l_dblDEFFEERATE number(30,4);
    l_dblMarginRate  number(30,4);
    l_dblMarginRatio number(30,4);
    l_dblSecuredRatioMin number(30,4);
    l_dblSecuredRatioMax number(30,4);
    l_dblTyp_Bratio number(30,4);
    l_dblAF_Bratio number(30,4);
    ml_dblSecureRatio number(30,4);
    l_dblRoom number(30,4);
    l_dblTraderID  number(30,4);
    l_blnReversal boolean;
    l_strHalt char(1);
    l_strCompanyFirm varchar2(50);
    l_dblTradeLot number(30,4);
    l_dblTradeUnit number(30,4);
    l_dblFloorPrice number(30,4);
    l_dblCeilingPrice number(30,4);
    l_dblTickSize number(30,4);
    l_dblFromPrice number(30,4);
    l_dblMarginMaxQuantity  number(30,4);
    l_dblBfAccoutMarginRate number(30,4);
    l_dblAfAccoutMarginRate number(30,4);
    l_dblLongPosision number(30,4);
    l_dblBuyMinAmount number(30,4);
    l_dblSellMinAmount number(30,4);
    l_dblCheckMinAmount number(30,4);
    l_strPreventMinOrder varchar2(30);
    l_strTRADEBUYSELL  varchar2(30);
    l_strOVRRQD varchar2(100);
    l_strSETYPE varchar2(10);
    Pl_REFCURSOR   PKG_REPORT.REF_CURSOR;
    l_dblAvlLimit number(30,4);
    l_ISMARGIN varchar2(1);
    l_strClientID varchar2(10);
    l_dblTradeStatus number;

    v_strORDERTRADEBUYSELL  Varchar2(10);
    l_strControlCode Varchar2(10);
    v_strTemp  Varchar2(100);
    v_strSysCheckBuySell Varchar2(100);
    L_SECTYPE   VARCHAR2(6);

    l_CheckMaxSameOrd varchar2(10);
    v_strAlreadyListed   varchar2(100);
    --LoLeHSX
    l_strOddLotHalt      varchar2(2);
    l_strHalt_HoSecInfo varchar2(5);
    l_strOddLotHalt_HoSecInfo varchar2(5);
    --End LoLeHSX
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
    ---------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    if p_txmsg.deltd='Y' then
        l_blnReversal:=true;
    else
        l_blnReversal:=false;
    end if;
    if l_blnReversal then
        --Xoa giao dich thi check
        SELECT count(1) into l_count FROM ODMAST WHERE TXNUM=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND ORSTATUS IN ('1','2','8');
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_ODMAST_CANNOT_DELETE);
            p_err_code :=errnums.C_OD_ODMAST_CANNOT_DELETE;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        end if;
    else
        l_CheckMaxSameOrd := fn_check_maxsameorder(p_txmsg.txfields('01').value, p_txmsg.txfields('03').value,p_txmsg.txfields('22').value, p_txmsg.txfields('24').value, p_txmsg.txfields('27').value, p_txmsg.txfields('11').value, p_txmsg.txfields('12').value);
        if l_CheckMaxSameOrd <> '0' then
            p_err_code := l_CheckMaxSameOrd;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        --Make giao dich thi check
        l_strCODEID := p_txmsg.txfields('01').value;
        l_strACTYPE := p_txmsg.txfields('02').value;
        l_strAFACCTNO := p_txmsg.txfields('03').value;
        l_strTIMETYPE := p_txmsg.txfields('20').value;
        l_strEXPDATE := p_txmsg.txfields('21').value;
        l_strEXECTYPE := p_txmsg.txfields('22').value;
        l_strNORK := p_txmsg.txfields('23').value;
        l_strMATCHTYPE := p_txmsg.txfields('24').value;
        l_strVIA := p_txmsg.txfields('25').value;
        l_strCLEARCD := p_txmsg.txfields('26').value;
        l_strPRICETYPE := p_txmsg.txfields('27').value;
        l_dblCLEARDAY := p_txmsg.txfields('10').value;
        l_dblQUOTEPRICE := p_txmsg.txfields('11').value;
        l_dblORDERQTTY := p_txmsg.txfields('12').value;
        l_dblBRATIO := p_txmsg.txfields('13').value;
        l_dblLIMITPRICE := p_txmsg.txfields('14').value;
        l_strVOUCHER := p_txmsg.txfields('28').value;
        l_strCONSULTANT := p_txmsg.txfields('29').value;
        l_strORDERID := p_txmsg.txfields('04').value;
        l_strDESC := p_txmsg.txfields('30').value;
        l_strContrafirm := p_txmsg.txfields('31').value;
        l_strContraCus := replace(p_txmsg.txfields('71').value,'.','');
        l_strPutType := replace(p_txmsg.txfields('72').value,'.','');
        l_strContrafirm2 := replace(p_txmsg.txfields('73').value,'.','');
        l_strClientID := substr(p_txmsg.txfields('33').value,1,10);
        l_dblTradeStatus := 0;--p_txmsg.txfields('90').value;
        v_strAlreadyListed := '';
        /*l_strCIACCTNO := l_strAFACCTNO;
        l_strSEACCTNO := l_strAFACCTNO || l_strCODEID;

        --kIEM TRA TAI KHOAN se co ton tai hay khong
        SELECT count(1) into l_count FROM SEMAST WHERE ACCTNO=l_strSEACCTNO;
        if l_count<=0 then
          --Neu khong co thi tu dong mo tai khoan
          SELECT TYP.SETYPE, af.custid into l_strSETYPE, l_strCUSTID FROM AFMAST AF, AFTYPE TYP WHERE AF.ACTYPE=TYP.ACTYPE AND AF.ACCTNO= l_strAFACCTNO;
          INSERT INTO SEMAST (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,
                            OPNDATE,LASTDATE,STATUS,IRTIED,IRCD,
                            COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,
                            STANDING,WITHDRAW,DEPOSIT,LOAN)
                      VALUES (l_strSETYPE, l_strCUSTID, l_strSEACCTNO , l_strCODEID , l_strAFACCTNO ,
                      p_txmsg.txdate,p_txmsg.txdate,'A','Y','001',
                      0,0,0,0,0,0,0,0,0);
        end if;*/
        -- Sua lai, lenh GTC van phai check cac d/k nhu lenh thong thuong
        -- TheNN, 24-Apr-2012
        /*if p_txmsg.txfields('20').value='G' then
            --Lenh GTC khong phai check
            plog.debug(pkgctx,'Leng GTC: ');
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            Return systemnums.C_SUCCESS;
        end if;*/
        l_dblALLOWBRATIO:=1;
        SELECT count(1) into l_count  FROM ODTYPE WHERE STATUS='Y' AND ACTYPE=l_strACTYPE;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_ODTYPE_NOTFOUND);
            p_err_code := errnums.C_OD_ODTYPE_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT TRADELIMIT,BRATIO/100,DEFFEERATE/100 into l_dblODTYPETRADELIMIT,l_dblALLOWBRATIO,l_dblDEFFEERATE  FROM ODTYPE WHERE STATUS='Y' AND ACTYPE=l_strACTYPE;
        end if;
        SELECT count(1) into l_count  FROM AFMAST af,AFTYPE aft, MRTYPE mrt WHERE ACCTNO=l_strAFACCTNO  AND af.ACTYPE=aft.ACTYPE and aft.MRTYPE=mrt.ACTYPE;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CF_AFMAST_NOTFOUND);
            p_err_code := errnums.C_CF_AFMAST_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        else
            l_strCIACCTNO := l_strAFACCTNO;
            l_strSEACCTNO := l_strAFACCTNO || l_strCODEID;
            SELECT af.CUSTID,af.STATUS,af.ADVANCELINE,af.BRATIO,af.MRIRATE,af.mriratio,mrt.MRTYPE,MRT.BUYIFOVERDUE,af.ACTYPE AFTYPE, case when mrt.mrtype = 'T' and nvl(lnt.chksysctrl,'N') = 'Y' then 'Y' else 'N' end
                into l_strCUSTID,l_strAFSTATUS,l_dblAFADVANCELIMIT,l_dblALLOWBRATIO,l_dblMarginRate,l_dblMarginRatio,l_strMarginType,l_strBUYIFOVERDUE,l_strAFTYPE, l_ISMARGIN
            FROM AFMAST af,AFTYPE aft, MRTYPE mrt, lntype lnt
            WHERE ACCTNO= l_strAFACCTNO  AND af.ACTYPE=aft.ACTYPE and aft.MRTYPE=mrt.ACTYPE and aft.lntype = lnt.actype(+);
        end if;
        --Kiem tra tai khoan Margin neu bi qua han va l_strBUYIFOVERDUE="N" thi khong cho dat lenh mua
        If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') And l_strBUYIFOVERDUE = 'N' Then
            SELECT count(1) into l_count FROM CIMAST CI WHERE OVAMT >0 AND CI.ACCTNO= l_strCIACCTNO;
            if l_count>0 then
                plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_MR_ACCTNO_OVERDUE);
                p_err_code :=errnums.C_MR_ACCTNO_OVERDUE;
                plog.setendsection (pkgctx, 'fn_txAftAppCheck');
               Return errnums.C_BIZ_RULE_INVALID;
            end if;
        End If;
        ---DungNH sua check tieu khoan phong toa khong duoc phep mua ban
        If l_strAFSTATUS = 'B' Then
                p_err_code := '-700086';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                return errnums.C_BIZ_RULE_INVALID;
        End If;
        ---end DungNH
        --Kiem tra tai khoan CI co ton tai hay khong
        SELECT count(1) into l_count FROM CIMAST WHERE ACCTNO=l_strCIACCTNO;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CI_CIMAST_NOTFOUND);
            p_err_code :=errnums.C_CI_CIMAST_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT (BALANCE-ODAMT) into l_dblODBALANCE FROM CIMAST WHERE ACCTNO=l_strCIACCTNO;
        end if;

        --kIEM TRA TAI KHOAN se co ton tai hay khong
        SELECT count(1) into l_count FROM SEMAST WHERE ACCTNO=l_strSEACCTNO;
        if l_count<=0 then
          --Neu khong co thi tu dong mo tai khoan
          SELECT TYP.SETYPE into l_strSETYPE FROM AFMAST AF, AFTYPE TYP WHERE AF.ACTYPE=TYP.ACTYPE AND AF.ACCTNO= l_strAFACCTNO;
          INSERT INTO SEMAST (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,
                            OPNDATE,LASTDATE,STATUS,IRTIED,IRCD,
                            COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,
                            STANDING,WITHDRAW,DEPOSIT,LOAN)
                      VALUES (l_strSETYPE, l_strCUSTID, l_strSEACCTNO , l_strCODEID , l_strAFACCTNO ,
                      p_txmsg.txdate,p_txmsg.txdate,'A','Y','001',
                      0,0,0,0,0,0,0,0,0);
        end IF;

        --Kiem tra ma khach hang co ton tai hay khong
        SELECT count(1) into l_count FROM CFMAST WHERE CUSTID=l_strCUSTID;
        if l_count<=0 then
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CF_CUSTOMER_NOTFOUND);
            p_err_code :=errnums.C_CF_CUSTOMER_NOTFOUND;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT CUSTODYCD into l_strCUSTODYCD FROM CFMAST WHERE CUSTID=l_strCUSTID;
        end if;
        SELECT HALT,TRADEPLACE,SYMBOL, SECTYPE,
            ODD_LOT_HALT --LoLeHSX
        into l_strHalt,l_strTRADEPLACE,l_strSYMBOL, L_SECTYPE, l_strOddLotHalt
        FROM SBSECURITIES WHERE CODEID = l_strCODEID;
        --LoLe HSX
        /*If l_strHalt = 'Y' Then
            p_err_code :=errnums.C_OD_CODEID_HALT;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        end if;*/
        --End LoLeHSX
        If (l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC Or l_strTRADEPLACE = errnums.gc_TRADEPLACE_HNCSTC) And Length(Trim(l_strCUSTODYCD)) = 0 Then
            p_err_code :=errnums.C_OD_LISTED_NEEDCUSTODYCD;
           Return errnums.C_BIZ_RULE_INVALID;
        End If;
        If l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC And (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'NS') Then
            --Tham so ham Check TraderID
            SELECT FNC_CHECK_TRADERID( l_strMATCHTYPE ,substr(l_strEXECTYPE ,2,1), l_strVIA ) TRD into l_dblTraderID FROM DUAL;
            If l_dblTraderID = 0 Then
                p_err_code :=errnums.C_OD_TRADERID_NOT_INVALID;
                plog.setendsection (pkgctx, 'fn_txAftAppCheck');
               Return errnums.C_BIZ_RULE_INVALID;
            End If;
        End If;
        --Check contra sell order when place buy order (2PT)
        If (l_strTRADEPLACE = errnums.gc_TRADEPLACE_UPCOM) And (l_strMATCHTYPE = 'P') And (l_strPutType = 'N') Then
            select varvalue into l_strCompanyFirm from sysvar where grname ='SYSTEM' and varname='COMPANYCD';
            --Neu la lenh Upcom thoa thuan cung cong ty phai kiem tra
            If l_strEXECTYPE = 'NB' Then
                If (l_strContrafirm2 = l_strCompanyFirm Or l_strContrafirm2 = '') Then
                    l_strContrafirm2 := l_strCompanyFirm;
                    If l_strContraCus <> '' Then
                        SELECT COUNT(ROWNUM) into l_count FROM ODMAST OD,OOD OUTOD
                        WHERE OD.orderid = OUTOD.orgorderid AND OD.orstatus IN ('1','2','8')
                        AND OUTOD.oodstatus IN ('N','S') AND OD.orderid =  l_strContraCus  AND OD.EXECTYPE='NS'
                        AND OD.matchtype='P' AND OD.CODEID=l_strCODEID  AND OD.QUOTEPRICE=(l_dblQUOTEPRICE) * 1000
                        AND OD.ORDERQTTY= l_dblORDERQTTY  AND OD.PUTTYPE='N' AND OD.CODEID IN (SELECT CODEID FROM SBSECURITIES WHERE TRADEPLACE= l_strTRADEPLACE );

                        If l_count<=0 Then
                            p_err_code :=errnums.C_OD_CONTRA_ORDER_NOT_FOUND;
                            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                           Return errnums.C_BIZ_RULE_INVALID;
                        End If;
                    Else
                        p_err_code :=errnums.C_OD_CONTRA_ORDER_NOT_FOUND;
                        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                       Return errnums.C_BIZ_RULE_INVALID;
                    End If;
                End If;
            End If;
        End If;
        SELECT count(1) into l_count FROM SECURITIES_INFO INF, SECURITIES_RISK RSK WHERE INF.CODEID= l_strCODEID  AND INF.CODEID=RSK.CODEID(+);
        if l_count<=0 then
            p_err_code :=errnums.C_OD_SECURITIES_INFO_UNDEFINED;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
           Return errnums.C_BIZ_RULE_INVALID;
        else
            SELECT TRADELOT,TRADEUNIT,NVL(RSK.MRMAXQTTY,0) MRMAXQTTY,nvl(BMINAMT,0) BMINAMT,nvl(SMINAMT,0) SMINAMT,FLOORPRICE,CEILINGPRICE,CURRENT_ROOM,TRADEBUYSELL
            into l_dblTradeLot,l_dblTradeUnit,l_dblMarginMaxQuantity,l_dblBuyMinAmount,l_dblSellMinAmount,l_dblFloorPrice,l_dblCeilingPrice,l_dblRoom,l_strTRADEBUYSELL
            FROM SECURITIES_INFO INF, SECURITIES_RISK RSK WHERE INF.CODEID= l_strCODEID  AND INF.CODEID=RSK.CODEID(+);

            --'Kiem tra chan min,max amount
            select varvalue into l_strPreventMinOrder from sysvar where grname ='SYSTEM' and varname ='PREVENTORDERMIN';
            If l_strPreventMinOrder = 'Y' Then
                If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') Then
                    l_dblCheckMinAmount := l_dblBuyMinAmount;
                Else
                    l_dblCheckMinAmount := l_dblSellMinAmount;
                End If;
                If l_dblQUOTEPRICE * l_dblORDERQTTY * l_dblTradeUnit < l_dblCheckMinAmount Then
                    p_err_code :=errnums.C_OD_ORDER_UNDER_MIN_AMOUNT;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                   Return errnums.C_BIZ_RULE_INVALID;
                End If;
            End If;
            If l_dblTradeUnit > 0 Then
                l_dblQUOTEPRICE := Round(l_dblQUOTEPRICE * l_dblTradeUnit, 6);
            End If;
            --Kiem tra lenh mua nha dau tu nuoc ngoai co con ROOM
            If l_strEXECTYPE = 'NB' And (substr(l_strCUSTODYCD, 4, 1) = 'F' Or substr(l_strCUSTODYCD, 4, 1) = 'E') Then
                If l_dblORDERQTTY > l_dblRoom  Then

                    IF  substr(l_strClientID, 4, 1) = 'F'  AND l_strMATCHTYPE = 'P'  THEN
                       -- THOA THUAN CUNG CTY CUNG LA NGUOI NC NGOAI THI KHONG CHECK ROOM
                       NULL;
                    ELSE
                        if nvl(p_txmsg.txfields('85').value,'N') <> 'O' then
                            if not(L_SECTYPE in ('006','003') and l_strTRADEPLACE in ('007','008')) then
                                p_err_code := errnums.C_OD_ROOM_NOT_ENOUGH;
                                plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                                Return errnums.C_BIZ_RULE_INVALID;
                            end if;
                        end if;
                    END IF;
                End If;
            End If;
            --Kiem tra khoi luong co chia het cho trdelot hay khong
           /* If l_dblTradeLot > 0 And l_strMATCHTYPE <> 'P' Then
                If (l_dblORDERQTTY Mod l_dblTradeLot <> 0) Then
                    p_err_code :=errnums.C_OD_QTTY_TRADELOT_INCORRECT;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                   Return errnums.C_BIZ_RULE_INVALID;
                End If;
            End If;
             */ --Kiem tra khoi luong co chia het cho trdelot hay khong
             --ThangPV chinh sua lo le HSX 27-04-2022
            /*  If l_dblTradeLot > 0 And l_strMATCHTYPE <> 'P' Then
               if    l_strTRADEPLACE ='001' or (l_strTRADEPLACE in ('002','005') and l_dblORDERQTTY>l_dblTradeLot) then
                   If l_dblORDERQTTY Mod l_dblTradeLot <> 0 Then
                        p_err_code :=errnums.C_OD_QTTY_TRADELOT_INCORRECT;
                        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                   Return errnums.C_BIZ_RULE_INVALID;
                    End If;
               end if ;
            End If;*/
            l_strControlCode:=fn_get_controlcode(l_strSYMBOL);
            If l_dblTradeLot > 0 And l_strMATCHTYPE <> 'P' and l_strTRADEPLACE in ('001','002','005') Then
                If l_dblORDERQTTY >= l_dblTradeLot Then
                  If l_dblORDERQTTY Mod l_dblTradeLot <> 0 Then
                    p_err_code :=errnums.C_OD_QTTY_TRADELOT_INCORRECT;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                    Return l_lngErrCode;
                  End If;
                ELSE
                  If l_strPRICETYPE <> 'LO' Then
                    p_err_code := -700114;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                    Return l_lngErrCode;
                  End if;
                End if ;
                --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3

                IF l_strTRADEPLACE = '001' AND l_dblORDERQTTY < l_dblTradeLot AND l_strControlCode = 'A' AND l_strPRICETYPE = 'LO' THEN
                   p_err_code := -100113;
                   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                   Return l_lngErrCode;
                END IF;
                --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
             End If;
            --End ThangPV chinh sua lo le HSX 27-04-2022
            --ThangPV chinh sua lo le HSX 05-12-2022
            IF l_strTRADEPLACE = '001' THEN
                  BEGIN
                    SELECT  Case when nvl(security_number_old,'--') = nvl(security_number_new,'--') THEN 'Y' ELSE 'N' END,
                            NVL(HALT_RESUME_FLAG,' '), NVL(ODD_LOT_HALT_RESUME_FLAG,' ')
                        INTO  v_strAlreadyListed, l_strHalt_HoSecInfo, l_strOddLotHalt_HoSecInfo
                    FROM Ho_Sec_info WHERE CODE= l_strSYMBOL;
                EXCEPTION WHEN OTHERS THEN
                    v_strAlreadyListed:='N';
                    l_strHalt_HoSecInfo:=' ';
                    l_strOddLotHalt_HoSecInfo:=' ';
                END;
                IF l_dblORDERQTTY < l_dblTradeLot and v_strAlreadyListed = 'N' THEN --Ma ck niem yet moi chang lo le
                        p_err_code := -700006;
                        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                        Return l_lngErrCode;
                END IF;
                  IF l_dblORDERQTTY < l_dblTradeLot THEN--Lo le
                    IF l_strMATCHTYPE <> 'P' THEN -- Lenh thuong
                        If l_strOddLotHalt_HoSecInfo IN ('H','A') Then
                            --p_err_code := errnums.C_OD_CODEID_HALT;
                            p_err_code := -700007; --TanPN 07/09/2022 LoLeHSX Doi ma loi lo le khi dat lenh truoc phien LO
                            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                            return l_lngErrCode;
                        end if;
                    ELSE --Lenh thoa thuan
                        If l_strOddLotHalt_HoSecInfo IN ('H','P') Then
                            --p_err_code := errnums.C_OD_CODEID_HALT;
                            p_err_code := -700007; --DieuNDA: 07/09/2022 LoLeHSX Doi ma loi lo le khi dat lenh truoc phien LO
                            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                            return l_lngErrCode;
                        end if;
                    END IF;
                ELSE --Lo chan
                    IF l_strMATCHTYPE <> 'P' THEN --Lenh thuong
                        If l_strHalt_HoSecInfo IN ('H','A') Then
                            p_err_code := errnums.C_OD_CODEID_HALT;
                            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                            return l_lngErrCode;
                        end if;
                    ELSE --Lenh thoa thuan
                        If l_strHalt_HoSecInfo IN ('H','P') Then
                            p_err_code := errnums.C_OD_CODEID_HALT;
                            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                            return l_lngErrCode;
                        end if;
                    END IF;
                END IF;
            ELSE --San khac
              If l_strHalt = 'Y' Then
                p_err_code := errnums.C_OD_CODEID_HALT;
                plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                return l_lngErrCode;
              end if;
            END IF;
            --end ThangPV chinh sua lo le HSX 05-12-2022



                --Kiem tra voi lenh LO thi gia phai nam trong khoang tran san
            If l_strPRICETYPE = 'LO' and l_dblTradeStatus = 0 AND instr('003,006',L_SECTYPE) <= 0 Then
                If l_dblQUOTEPRICE < l_dblFloorPrice Or l_dblQUOTEPRICE > l_dblCeilingPrice Then
                    p_err_code :=errnums.C_OD_LO_PRICE_ISNOT_FLOOR_CEIL;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                   Return errnums.C_BIZ_RULE_INVALID;
                End If;
            End If;
            --Voi lenh LO, stop limit thi kiem tra tick size cua gia
            If l_strPRICETYPE = 'LO' Or l_strPRICETYPE = 'SL' Then
                SELECT count(1) into l_count FROM SECURITIES_TICKSIZE WHERE CODEID=l_strCODEID  AND STATUS='Y'
                       AND TOPRICE>= l_dblQUOTEPRICE AND FROMPRICE<=l_dblQUOTEPRICE;
                if l_count<=0 then
                    --Chua dinh nghia TICKSIZE
                    p_err_code :=errnums.C_OD_TICKSIZE_UNDEFINED;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                   Return errnums.C_BIZ_RULE_INVALID;
                else
                    SELECT FROMPRICE, TICKSIZE into l_dblFromPrice,l_dblTickSize
                    FROM SECURITIES_TICKSIZE WHERE CODEID=l_strCODEID  AND STATUS='Y'
                       AND TOPRICE>= l_dblQUOTEPRICE AND FROMPRICE<=l_dblQUOTEPRICE;
                    If (l_dblQUOTEPRICE - l_dblFromPrice) Mod l_dblTickSize <> 0 And l_strMATCHTYPE <> 'P' Then
                        p_err_code :=errnums.C_OD_TICKSIZE_INCOMPLIANT;
                        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                       Return errnums.C_BIZ_RULE_INVALID;
                    End If;
                end if;
            End If;
  /*
         --Kiem tra chung khoan khong duoc vua mua vua ban trong ngay
            If l_strTRADEBUYSELL = 'N' Then
                If l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC' Then
                    SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= l_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                    AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY+EXECQTTY>0;
                Else
                    SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= l_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                    AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY+EXECQTTY>0;
                End If;
                If l_count > 0 Then
                    --Bao loi khong duoc mua ban mot chung khoan trong cuang 1 ngay
                    p_err_code :=errnums.C_OD_BUYSELL_SAME_SECURITIES;
                   Return errnums.C_BIZ_RULE_INVALID;
                End If;
            End If;*/


             --Kiem tra chung khoan khong duoc vua mua vua ban trong ngay
             -- quyet.kieu : Ghep them phan mua ban chung khoan cung phien theo thong tu 74
          -- Bat dau kiem tra lenh doi ung
            /*IF NOT fnc_pass_tradebuysell(l_strAFACCTNO,p_txmsg.txdate,l_strCODEID,l_strEXECTYPE,l_strPRICETYPE,l_strMATCHTYPE,l_strTRADEPLACE,l_strSYMBOL) THEN
              -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    p_err_code :=errnums.C_OD_ORTHER_ORDER_WAITING;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                    Return l_lngErrCode;
              END IF;*/
        -- Ket thuc chan lenh doi ung
        End if;
      /*  plog.debug(pkgctx,'l_strOVRRQD1: ' || l_strOVRRQD);
        --Kiem tra vuot han muc yeu cau checker duyet
        If l_dblQUOTEPRICE * l_dblORDERQTTY > l_dblODTYPETRADELIMIT Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_ORDERTRADELIMIT;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;*/

       /* plog.debug(pkgctx,'l_strOVRRQD2: ' || l_strOVRRQD);
        If l_dblBRATIO < l_dblALLOWBRATIO Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_ORDERSECURERATIO;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;
        plog.debug(pkgctx,'l_strOVRRQD3: ' || l_strOVRRQD);*/
        /*
        --Neu vuot qua han muc giao dich cua HD
        SELECT SUM(QUOTEPRICE*ORDERQTTY) AMT into l_count FROM ODMAST WHERE AFACCTNO=l_strAFACCTNO;
        If l_dblQUOTEPRICE * l_dblORDERQTTY + l_count > l_dblAFTRADELIMIT Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_AFTRADELIMIT;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;
        */
        --Kiem tra neu gia tri ung truoc vuot qua han muc ung truoc trong hop dong thi yeu cau checker duyet
/*        If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') And l_strMarginType = 'N' Then
            SELECT SUM(QUOTEPRICE*REMAINQTTY*(1+TYP.DEFFEERATE/100)+EXECAMT) ODAMT into l_count
            FROM ODMAST OD, ODTYPE TYP
            WHERE OD.ACTYPE=TYP.ACTYPE
            AND  OD.AFACCTNO= l_strAFACCTNO
            AND OD.TXDATE= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)
            AND DELTD <>'Y' AND OD.EXECTYPE IN ('NB','BC') ;
            if l_dblQUOTEPRICE * l_dblORDERQTTY + l_count > l_dblAFADVANCELIMIT + l_dblODBALANCE Then
                p_err_code :=errnums.C_OD_ADVANCELINE_OVER_LIMIT;
               Return errnums.C_BIZ_RULE_INVALID;
            End If;
        End If;*/
        plog.debug(pkgctx,'l_strOVRRQD4: ' || l_strOVRRQD);
        If length(Trim(Replace(l_strOVRRQD, errnums.OVRRQS_CHECKER_CONTROL, ''))) > 0 And (length(p_txmsg.chkid) = 0 or p_txmsg.chkid is null) Then
            p_err_code :=errnums.C_CHECKER1_REQUIRED;
        Else
            If InStr(l_strOVRRQD, errnums.OVRRQS_CHECKER_CONTROL) > 0 And (Length(p_txmsg.offid)  = 0 or p_txmsg.offid is null) Then
                p_err_code :=errnums.C_CHECKER2_REQUIRED;
            End If;
        End If;
    end if;
    if p_err_code =errnums.C_CHECKER1_REQUIRED or p_err_code =errnums.C_CHECKER2_REQUIRED then
    FOR I IN (
       SELECT ERRDESC,EN_ERRDESC FROM deferror
       WHERE ERRNUM= p_err_code
    ) LOOP
       l_err_param := i.errdesc;
    END LOOP;
    p_txmsg.txException('ERRSOURCE').value := '';
    p_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
    p_txmsg.txException('ERRCODE').value := p_err_code;
    p_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
    p_txmsg.txException('ERRMSG').value := l_err_param;
    p_txmsg.txException('ERRMSG').TYPE := 'System.String';

    end if;

    ---------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------
   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in  tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
    l_count number(20,0);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    /*If p_txmsg.deltd <> 'Y' Then
        if nvl(p_txmsg.txfields('85').value,'N') = 'P' then
            l_count := 0;
            UPDATE ORDERPTACK SET status = 'W'
            WHERE trim(confirmnumber) = trim(p_txmsg.txfields('86').value );
        END IF;
    Else
        if nvl(p_txmsg.txfields('85').value,'N') = 'P' then
            l_count := 0;
            UPDATE ORDERPTACK SET status = 'N'
            WHERE trim(confirmnumber) = trim(p_txmsg.txfields('86').value );
        END IF;
    END IF;*/
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

FUNCTION fn_txAftAppUpdate(p_txmsg in  tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
    l_lngErrCode number(20,0);
    l_count number(20,0);
    l_strCUSTID varchar2(30);
    l_strCODEID varchar2(30);
    l_strACTYPE varchar2(30);
    l_strAFACCTNO varchar2(30);
    l_strCIACCTNO varchar2(30);
    l_strAFSTATUS varchar2(30);
    l_strSEACCTNO varchar2(30);
    l_strCUSTODYCD varchar2(30);
    l_strTIMETYPE varchar2(30);
    l_strVOUCHER varchar2(30);
    l_strCONSULTANT varchar2(30);
    l_strORDERID varchar2(30);
    l_strBORS varchar2(30);
    l_strContrafirm varchar2(30);
    l_strContrafirm2 varchar2(30);
    l_strContraCus varchar2(30);
    l_strPutType varchar2(30);
    l_strEXPDATE varchar2(30);
    l_strEXECTYPE varchar2(30);
    l_strNORK varchar2(30);
    l_strMATCHTYPE varchar2(30);
    l_strVIA varchar2(30);
    l_strCLEARCD varchar2(30);
    l_strPRICETYPE varchar2(30);
    l_strDESC varchar2(300);
    l_strTRADEPLACE varchar2(30);
    l_strSYMBOL varchar2(30);
    l_strMarginType varchar2(30);
    l_strBUYIFOVERDUE varchar2(30);
    l_strAFTYPE varchar2(30);
    l_dblCLEARDAY number(30,4);
    l_dblQUOTEPRICE number(30,9);
    l_dblORDERQTTY number(30,4);
    l_dblBRATIO number(30,4);
    l_dblLIMITPRICE number(30,4);
    l_dblAFADVANCELIMIT number(30,4);
    l_dblODBALANCE  number(30,4);
    l_dblODTYPETRADELIMIT number(30,4);
    l_dblAFTRADELIMIT number(30,4);
    l_dblALLOWBRATIO number(30,4);
    l_dblDEFFEERATE number(30,4);
    l_dblMarginRate  number(30,4);
    l_dblSecuredRatioMin number(30,4);
    l_dblSecuredRatioMax number(30,4);
    l_dblTyp_Bratio number(30,4);
    l_dblAF_Bratio number(30,4);
    ml_dblSecureRatio number(30,4);
    l_dblRoom number(30,4);
    l_dblTraderID  number(30,4);
    l_blnReversal boolean;
    l_strHalt char(1);
    l_strCompanyFirm varchar2(50);
    l_dblTradeLot number(30,4);
    l_dblTradeUnit number(30,4);
    l_dblFloorPrice number(30,4);
    l_dblCeilingPrice number(30,4);
    l_dblTickSize number(30,4);
    l_dblFromPrice number(30,4);
    l_dblMarginMaxQuantity  number(30,4);
    l_dblBfAccoutMarginRate number(30,4);
    l_dblAfAccoutMarginRate number(30,4);
    l_dblLongPosision number(30,4);
    l_dblBuyMinAmount number(30,4);
    l_dblSellMinAmount number(30,4);
    l_dblCheckMinAmount number(30,4);
    l_strPreventMinOrder varchar2(30);
    l_strTRADEBUYSELL  varchar2(30);
    l_strOVRRQD varchar2(100);
    l_strFEEDBACKMSG varchar2(1000);
    l_strBRID varchar2(30);
    l_strTXDATE varchar2(30);
    l_strTXNUM varchar2(30);
    l_strTXTIME varchar2(30);
    l_strTXDESC varchar2(300);
    l_strCHKID varchar2(30);
    l_strOFFID varchar2(30);
    l_strDELTD varchar2(30);
    l_strEFFDATE varchar2(30);
    l_strMember varchar2(200);
    l_strFOACCTNO varchar2(200);
    l_strTraderid varchar2(30);
    l_strClientID varchar2(30);
    l_strOutPriceAllow varchar2(30);
    --</ TruongLD Add
    l_strTLID  varchar2(30);
    --/>
    --<QuyetKD add update HNX
     l_dblQuoteQtty number(30,4);
     l_strPtDeal varchar2(10);
     --/>
    l_strSSAFACCTNO varchar2(10);
    Pl_REFCURSOR   PKG_REPORT.REF_CURSOR;

    L_TXDATE    DATE;
    L_CLEARDATE DATE;
    L_BILLPIRCE NUMBER(20,4);
    L_YIELDS    NUMBER(20,4);
    L_COUPON    NUMBER(20,4);
    L_PARTNER   VARCHAR2(1000);
    l_term      number(20);
    l_enddate   date;
    l_busdate2  date;
    l_leg       varchar2(1);
    l_interrestrate number(20,4);
    l_amt2      number(20);
    L_FEEAMT    NUMBER(20);
    l_refrepoacc    varchar2(40);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    ---------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------
    l_strBRID :=p_txmsg.BRID;
    l_strTXDATE :=p_txmsg.TXDATE;
    l_strTXNUM :=p_txmsg.TXNUM;
    l_strTXTIME :=p_txmsg.TXTIME;
    l_strTXDESC :=p_txmsg.TXDESC;
    l_strOVRRQD :=p_txmsg.OVRRQd;
    l_strCHKID:= p_txmsg.CHKID;
    l_strOFFID:= p_txmsg.OFFID;
    l_strDELTD :=p_txmsg.DELTD;
    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    if p_txmsg.deltd='Y' then
        l_blnReversal:=true;
    else
        l_blnReversal:=false;
    end if;
    l_strCODEID := p_txmsg.txfields('01').value;
    l_strACTYPE := p_txmsg.txfields('02').value;
    l_strAFACCTNO := p_txmsg.txfields('03').value;
    l_strTIMETYPE := p_txmsg.txfields('20').value;
    l_strEFFDATE:= p_txmsg.txfields('19').value;
    l_strEXPDATE := p_txmsg.txfields('21').value;
    l_strEXECTYPE := p_txmsg.txfields('22').value;
    l_strNORK := p_txmsg.txfields('23').value;
    l_strMATCHTYPE := p_txmsg.txfields('24').value;
    l_strVIA := p_txmsg.txfields('25').value;
    l_strCLEARCD := p_txmsg.txfields('26').value;
    l_strPRICETYPE := p_txmsg.txfields('27').value;
    l_dblCLEARDAY := p_txmsg.txfields('10').value;
    l_dblQUOTEPRICE := p_txmsg.txfields('11').value;
    l_dblORDERQTTY := p_txmsg.txfields('12').value;
    l_dblBRATIO := p_txmsg.txfields('13').value;
    l_dblLIMITPRICE := p_txmsg.txfields('14').value;
    l_strVOUCHER := p_txmsg.txfields('28').value;
    l_strCONSULTANT := p_txmsg.txfields('29').value;
    l_strORDERID := p_txmsg.txfields('04').value;
    l_strDESC := p_txmsg.txfields('30').value;
    l_strMember:= p_txmsg.txfields('50').value;
    l_strContrafirm := p_txmsg.txfields('31').value;
    l_strTraderid := p_txmsg.txfields('32').value;
    l_strClientID := substr(p_txmsg.txfields('33').value,1,10);
    l_strOutPriceAllow := p_txmsg.txfields('34').value;
    l_strContraCus := replace(p_txmsg.txfields('71').value,'.','');
    l_strPutType := replace(p_txmsg.txfields('72').value,'.','');
    l_strContrafirm2 := replace(p_txmsg.txfields('73').value,'.','');
    --</ TruongLD Add
    l_strTLID := p_txmsg.tlid;
    --/>


    l_dblQuoteQtty:= p_txmsg.txfields('80').value;

    If l_strMATCHTYPE ='P' then

        begin
        l_strPtDeal:= p_txmsg.txfields('81').value;

        exception when others then
        l_strPtDeal:='';
        end;

        else
        l_strPtDeal:=null;
    end if;
    begin
        l_strSSAFACCTNO:=p_txmsg.txfields('94').value;
    exception when others then
        l_strSSAFACCTNO:='';
    end;

    --HNX_UPDATE: PLO lay gia theo tham so cau hinh
    IF l_strPRICETYPE IN ('PLO') THEN
       l_strSYMBOL:='';
       SELECT SYMBOL into l_strSYMBOL FROM SBSECURITIES
       WHERE CODEID =l_strCODEID ;
        l_dblLIMITPRICE := FNC_GET_PRICE_PLO(l_strSYMBOL, l_strEXECTYPE);
        l_dblQUOTEPRICE := FNC_GET_PRICE_PLO(l_strSYMBOL, l_strEXECTYPE);
      END IF;
    --End HNX_UPDATE: PLO lay gia theo tham so cau hinh

    If l_strTIMETYPE = 'G' And substr(l_strORDERID,1, 2) <> errnums.C_FO_PREFIXED Then
        --Neu la lenh Good till cancel, ma la lenh dat
        If l_blnReversal Then
            SELECT count(1) into l_count FROM FOMAST WHERE ACCTNO =l_strORDERID  AND STATUS <> 'P';
            If l_count > 0 Then
                --Khong the xoa lenh nay
                p_err_code :=errnums.C_ERRCODE_FO_INVALID_STATUS;
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
               Return errnums.C_BIZ_RULE_INVALID;
            End If;
            --Xoa giao dich
            DELETE FROM FOMAST WHERE ACCTNO =l_strORDERID ;
        Else
            --Day lenh vao FOMAST
            --Lay ra ma chung khoan
            l_strSYMBOL:='';
            SELECT SYMBOL into l_strSYMBOL FROM SBSECURITIES WHERE CODEID =l_strCODEID ;
            l_strFEEDBACKMSG := l_strDESC;
            INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE,
                MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE,
                TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,EFFDATE,EXPDATE,BRATIO,VIA,OUTPRICEALLOW,TXNUM,TXDATE,QUOTEQTTY,LIMITPRICE)
                VALUES ( l_strORDERID , l_strORDERID, l_strACTYPE, l_strAFACCTNO,'P',
                 l_strEXECTYPE, l_strPRICETYPE, l_strTIMETYPE, l_strMATCHTYPE,
                 l_strNORK, l_strCLEARCD, l_strCODEID, l_strSYMBOL,
                'N','A', l_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),
                 l_dblCLEARDAY , l_dblORDERQTTY , l_dblLIMITPRICE , l_dblQUOTEPRICE , 0 , 0 , 0 ,
                 l_dblORDERQTTY ,TO_DATE( l_strEFFDATE ,  systemnums.C_DATE_FORMAT ),TO_DATE( l_strEXPDATE , systemnums.C_DATE_FORMAT),
                 l_dblBRATIO , l_strVIA , l_strOutPriceAllow , p_txmsg.txnum ,
                 TO_DATE( p_txmsg.txdate,  systemnums.C_DATE_FORMAT ),l_dblQUOTEQTTY,l_dblLIMITPRICE);
        End If;
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        Return systemnums.C_SUCCESS;
    End If;
    --Lenh today hoac Intemediate or cancel
    --Hoac lenh GTC tu dong day vao he thong
    if l_blnReversal then
        SELECT count(1) into l_count FROM ODMAST WHERE REFORDERID =l_strORDERID ;
        If l_count > 0 Then
            --khogn the xoa lenh nay
            p_err_code :=errnums.C_OD_ODMAST_CANNOT_DELETE;
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
           Return errnums.C_BIZ_RULE_INVALID;
        End If;
        --Kiem tra lenh co dc xoa hay khong
        SELECT count(1) into l_count FROM ODMAST WHERE TXNUM=p_txmsg.txnum  AND TXDATE=TO_DATE( p_txmsg.txdate , systemnums.C_DATE_FORMAT) AND ORSTATUS IN ('1','2','8');
        If l_count <= 0 Then
            --Khong dc xoa lenh nay
            p_err_code :=errnums.C_OD_ODMAST_CANNOT_DELETE;
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
           Return errnums.C_BIZ_RULE_INVALID;
        End If;
        --Xoa giao dich
        UPDATE ODMAST SET DELTD='Y' WHERE TXNUM=p_txmsg.txnum  AND TXDATE=TO_DATE( p_txmsg.txdate , systemnums.C_DATE_FORMAT);
        UPDATE OOD SET DELTD='Y' WHERE TXNUM=p_txmsg.txnum  AND TXDATE=TO_DATE( p_txmsg.txdate , systemnums.C_DATE_FORMAT);
    else
        --Make giao dich
        l_dblALLOWBRATIO := 1;
        SELECT TRADELIMIT,BRATIO into l_dblODTYPETRADELIMIT,l_dblTyp_Bratio  FROM ODTYPE WHERE STATUS='Y' AND ACTYPE=l_strACTYPE ;
        l_dblALLOWBRATIO:=l_dblTyp_Bratio/100;
        SELECT ACCTNO,CUSTID,STATUS,ADVANCELINE,BRATIO
        into l_strCIACCTNO,l_strCUSTID,l_strAFSTATUS,l_dblAFADVANCELIMIT,l_dblAF_Bratio
        FROM AFMAST WHERE ACCTNO=l_strAFACCTNO;
        l_strSEACCTNO := l_strAFACCTNO || l_strCODEID;
        l_dblALLOWBRATIO:=l_dblAF_Bratio/100;
        SELECT CUSTODYCD into l_strCUSTODYCD FROM CFMAST WHERE CUSTID= l_strCUSTID;
        SELECT TRADELOT,TRADEUNIT,FLOORPRICE,CEILINGPRICE,SECURERATIOMAX,SECURERATIOTMIN,CURRENT_ROOM,SYMBOL
        into l_dblTradeLot,l_dblTradeUnit,l_dblFloorPrice,l_dblCeilingPrice,l_dblSecuredRatioMax,l_dblSecuredRatioMin,l_dblRoom,l_strSYMBOL
        FROM SECURITIES_INFO WHERE CODEID=l_strCODEID;
        If l_dblTradeUnit > 0 Then
            l_dblQUOTEPRICE := Round(l_dblQUOTEPRICE * l_dblTradeUnit, 6);
            l_dblLIMITPRICE := Round(l_dblLIMITPRICE * l_dblTradeUnit, 6);
        End If;
        If Length(l_strMember) = 10 Then
            l_strCUSTID := l_strMember;
        End If;
        SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') into l_strTXTIME FROM DUAL;
        if l_strTIMETYPE <> 'G' then
            l_strMember:='';
        ELSE --lENH gtc
            BEGIN
                SELECT FOACCTNO INTO l_strMember FROM rootordermap WHERE ORDERID=l_strORDERID;
            EXCEPTION WHEN OTHERS THEN
                l_strMember:= l_strMember;
            END;
        end if;
        -- GET FOACCTNO
        BEGIN
            SELECT FOACCTNO INTO l_strFOACCTNO FROM rootordermap WHERE ORDERID=l_strORDERID;
        EXCEPTION WHEN OTHERS THEN
                l_strFOACCTNO:= '';
        END;

        if p_txmsg.tltxcd='8870' then
        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,CONTRAFIRM, TRADERID,CLIENTID,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'1','1', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY ,0,0,0,0,0,0,'001', l_strVOUCHER , l_strCONSULTANT , l_strContrafirm , l_strTraderid , l_strClientID , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID );
        elsif p_txmsg.tltxcd='8874' then
        --Ghi nhan vao so lenh
                        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'8','9', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,0,'001', l_strVOUCHER , l_strCONSULTANT , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID,l_strSSAFACCTNO );
                        --Ghi nhan vao OOD
                        INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                                         BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
                         VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,'B', l_strMATCHTYPE
                                         , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'N',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );

        elsif p_txmsg.tltxcd='8875' then
                        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'8','9', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,'001', l_strVOUCHER , l_strCONSULTANT , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID ,l_strSSAFACCTNO);

                        INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                                       BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
                        VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,'S', l_strMATCHTYPE
                                       , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'N',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );
        elsif p_txmsg.tltxcd='8876' then
                        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,
                                         CONSULTANT,CONTRAFIRM, TRADERID,CLIENTID,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO,QUOTEQTTY,PTDEAL)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'8','8', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,0,'001', l_strVOUCHER
                                         , l_strCONSULTANT , l_strContrafirm , l_strTraderid , l_strClientID , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID,l_strSSAFACCTNO, l_dblQuoteQtty,l_strPtDeal );
                         INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                                        BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
                        VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,'B', l_strMATCHTYPE
                                        , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'N',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );
                if nvl(p_txmsg.txfields('85').value,'N') = 'Y' then
                    FOR REC IN (
                           SELECT ID, STR FROM
                            (
                                select ROWNUM ID, TRIM(regexp_substr(p_txmsg.txfields('86').value ,'[^#]+', 1, level)) STR from dual
                                connect by regexp_substr(p_txmsg.txfields('86').value , '[^#]+', 1, level) is not null
                            )TL
                        ) LOOP
                        IF (REC.ID = 1) THEN
                            L_TXDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 2) THEN
                            L_CLEARDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 3) THEN
                            L_BILLPIRCE := REC.STR;
                        END IF;
                        IF (REC.ID = 4) THEN
                            L_YIELDS := TO_NUMBER(REC.STR, '99,999,999,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 5) THEN
                            L_COUPON := TO_NUMBER(REC.STR, '99,999,999,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 6) THEN
                            L_PARTNER := REC.STR;
                        END IF;
                    END LOOP;
                    INSERT INTO BONDTRANSACTPT (ORDERID,TXDATE,BUSDATE,BILLPIRCE,YIELDS,COUPON,PARTNER,DESCRIPTION)
                        VALUES ( l_strORDERID, TO_DATE( p_txmsg.txdate ,systemnums.C_DATE_FORMAT),L_CLEARDATE,L_BILLPIRCE,L_YIELDS,L_COUPON,L_PARTNER,p_txmsg.txfields('30').value );
                end if;
                if nvl(p_txmsg.txfields('85').value,'N') = 'R' then
                    FOR REC IN (
                           SELECT ID, STR FROM
                            (
                                select ROWNUM ID, TRIM(regexp_substr(p_txmsg.txfields('86').value ,'[^#]+', 1, level)) STR from dual
                                connect by regexp_substr(p_txmsg.txfields('86').value , '[^#]+', 1, level) is not null
                            )TL
                        ) LOOP
                        IF (REC.ID = 1) THEN
                            L_TXDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 2) THEN
                            L_CLEARDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 3) THEN
                            l_term := TO_NUMBER(REC.STR, '99,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 4) THEN
                            l_enddate := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 5) THEN
                            l_busdate2 := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 6) THEN
                            l_leg := REC.STR;
                        END IF;
                        IF (REC.ID = 7) THEN
                            l_interrestrate := TO_NUMBER(REC.STR, '99,999,999,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 8) THEN
                            l_amt2 := REC.STR;
                        END IF;
                        IF (REC.ID = 9) THEN
                            L_PARTNER := REC.STR;
                        END IF;
                        IF (REC.ID = 10) THEN
                            L_FEEAMT := REC.STR;
                        END IF;
                        if (rec.id = 11) then
                            l_refrepoacc := rec.str;
                        end if;
                    END LOOP;
                    if (l_leg = 'D') then
                        INSERT INTO bondrepo (ORDERID,REPOACCTNO,TXDATE,BUSDATE1,TERM,ENDDATE,BUSDATE2,INTERRESTRATE,AMT2,PARTNER,DESCRIPTION,REFREPOACCTNO,STATUS,leg,qtty,amt1,FEEAMT)
                            VALUES ( l_strORDERID, to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, TO_DATE( p_txmsg.txdate ,systemnums.C_DATE_FORMAT),L_CLEARDATE,l_term,l_enddate,l_busdate2, l_interrestrate,l_amt2,l_partner,p_txmsg.txfields('30').value,null,'A',l_leg,l_dblORDERQTTY,l_dblORDERQTTY*l_dblQUOTEPRICE,L_FEEAMT);
                        if L_FEEAMT > 0 then
                            update odmast set feeacr = L_FEEAMT where orderid = l_strORDERID;
                        end if;
                    else
                        INSERT INTO bondrepo (ORDERID,REPOACCTNO,TXDATE,BUSDATE1,TERM,ENDDATE,BUSDATE2,INTERRESTRATE,AMT2,PARTNER,DESCRIPTION,REFREPOACCTNO,STATUS,leg,qtty,amt1,FEEAMT)
                            VALUES ( l_strORDERID, to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, TO_DATE( p_txmsg.txdate ,systemnums.C_DATE_FORMAT),L_CLEARDATE,l_term,l_enddate,l_busdate2, l_interrestrate,0,l_partner,p_txmsg.txfields('30').value,l_refrepoacc,'C',l_leg,l_dblORDERQTTY,l_amt2,L_FEEAMT);
                        update bondrepo set REFREPOACCTNO = to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, status = 'C'
                        where REPOACCTNO = l_refrepoacc;
                    end if;
                end if;
                if nvl(p_txmsg.txfields('85').value,'N') = 'P' then
                    l_count := 0;
                    SELECT COUNT(*) INTO l_count FROM ODMAST A,ORDERPTACK B,OOD WHERE A.ORDERID=OOD.ORGORDERID
                        AND A.ORDERID = l_strORDERID  AND B.CONFIRMNUMBER=  p_txmsg.txfields('86').value
                        AND A.ORDERQTTY=B.VOLUME AND A.MATCHTYPE='P' AND OOD.BORS=B.SIDE;
                    IF l_count > 0 THEN
                        UPDATE ORDERPTACK SET status = 'A', TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'), TLID = l_strTLID,
                            IPADDRESS = p_txmsg.ipaddress, BRID = p_txmsg.brid, ORDERNUMBER = l_strORDERID
                        WHERE trim(confirmnumber) = trim(p_txmsg.txfields('86').value );
                        UPDATE ODMAST SET CONFIRM_NO =  trim(p_txmsg.txfields('86').value )
                        WHERE ORDERID = l_strORDERID;
                    END IF;
                END IF;
        elsif p_txmsg.tltxcd='8877' then
                        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,CONTRAFIRM, TRADERID,CLIENTID,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'8','8', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,'001', l_strVOUCHER , l_strCONSULTANT , l_strContrafirm , l_strTraderid , l_strClientID , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID,l_strSSAFACCTNO );
                        INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                                        BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
                        VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,'S', l_strMATCHTYPE
                                        , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'N',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );
                if nvl(p_txmsg.txfields('85').value,'N') = 'Y' then
                    FOR REC IN (
                           SELECT ID, STR FROM
                            (
                                select ROWNUM ID, TRIM(regexp_substr(p_txmsg.txfields('86').value ,'[^#]+', 1, level)) STR from dual
                                connect by regexp_substr(p_txmsg.txfields('86').value , '[^#]+', 1, level) is not null
                            )TL
                        ) LOOP
                        IF (REC.ID = 1) THEN
                            L_TXDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 2) THEN
                            L_CLEARDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 3) THEN
                            L_BILLPIRCE := REC.STR;
                        END IF;
                        IF (REC.ID = 4) THEN
                            L_YIELDS := TO_NUMBER(REC.STR, '99,999,999,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 5) THEN
                            L_COUPON := TO_NUMBER(REC.STR, '99,999,999,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 6) THEN
                            L_PARTNER := REC.STR;
                        END IF;
                    END LOOP;
                    INSERT INTO BONDTRANSACTPT (ORDERID,TXDATE,BUSDATE,BILLPIRCE,YIELDS,COUPON,PARTNER,DESCRIPTION)
                        VALUES ( l_strORDERID, TO_DATE( p_txmsg.txdate ,systemnums.C_DATE_FORMAT),L_CLEARDATE,L_BILLPIRCE,L_YIELDS,L_COUPON,L_PARTNER,p_txmsg.txfields('30').value );
                end if;
                if nvl(p_txmsg.txfields('85').value,'N') = 'R' then
                    FOR REC IN (
                           SELECT ID, STR FROM
                            (
                                select ROWNUM ID, TRIM(regexp_substr(p_txmsg.txfields('86').value ,'[^#]+', 1, level)) STR from dual
                                connect by regexp_substr(p_txmsg.txfields('86').value , '[^#]+', 1, level) is not null
                            )TL
                        ) LOOP
                        IF (REC.ID = 1) THEN
                            L_TXDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 2) THEN
                            L_CLEARDATE := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 3) THEN
                            l_term := TO_NUMBER(REC.STR, '99,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 4) THEN
                            l_enddate := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 5) THEN
                            l_busdate2 := TO_DATE(REC.STR,'DD/MM/RRRR');
                        END IF;
                        IF (REC.ID = 6) THEN
                            l_leg := REC.STR;
                        END IF;
                        IF (REC.ID = 7) THEN
                            l_interrestrate := TO_NUMBER(REC.STR, '99,999,999,999,999,999.99999');
                        END IF;
                        IF (REC.ID = 8) THEN
                            l_amt2 := REC.STR;
                        END IF;
                        IF (REC.ID = 9) THEN
                            L_PARTNER := REC.STR;
                        END IF;
                        IF (REC.ID = 10) THEN
                            L_FEEAMT := REC.STR;
                        END IF;
                        if (rec.id = 11) then
                            l_refrepoacc := rec.str;
                        end if;
                    END LOOP;
                    if (l_leg = 'D') then
                        INSERT INTO bondrepo (ORDERID,REPOACCTNO,TXDATE,BUSDATE1,TERM,ENDDATE,BUSDATE2,INTERRESTRATE,AMT2,PARTNER,DESCRIPTION,REFREPOACCTNO,STATUS,leg,qtty,amt1,FEEAMT)
                            VALUES ( l_strORDERID, to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, TO_DATE( p_txmsg.txdate ,systemnums.C_DATE_FORMAT),L_CLEARDATE,l_term,l_enddate,l_busdate2, l_interrestrate,l_amt2,l_partner,p_txmsg.txfields('30').value,null,'A',l_leg,l_dblORDERQTTY,l_dblORDERQTTY*l_dblQUOTEPRICE,L_FEEAMT);
                        if L_FEEAMT > 0 then
                            update odmast set feeacr = L_FEEAMT where orderid = l_strORDERID;
                        end if;
                    else
                        INSERT INTO bondrepo (ORDERID,REPOACCTNO,TXDATE,BUSDATE1,TERM,ENDDATE,BUSDATE2,INTERRESTRATE,AMT2,PARTNER,DESCRIPTION,REFREPOACCTNO,STATUS,leg,qtty,amt1,FEEAMT)
                            VALUES ( l_strORDERID, to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, TO_DATE( p_txmsg.txdate ,systemnums.C_DATE_FORMAT),L_CLEARDATE,l_term,l_enddate,l_busdate2, l_interrestrate,0,l_partner,p_txmsg.txfields('30').value,l_refrepoacc,'C',l_leg,l_dblORDERQTTY,l_amt2,L_FEEAMT);
                        update bondrepo set REFREPOACCTNO = to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, status = 'C'
                        where REPOACCTNO = l_refrepoacc;
                    end if;
                end if;
                if nvl(p_txmsg.txfields('85').value,'N') = 'P' then
                    l_count := 0;
                    SELECT COUNT(*) INTO l_count FROM ODMAST A,ORDERPTACK B,OOD WHERE A.ORDERID=OOD.ORGORDERID
                        AND A.ORDERID = l_strORDERID  AND B.CONFIRMNUMBER=  p_txmsg.txfields('86').value
                        AND A.ORDERQTTY=B.VOLUME AND A.MATCHTYPE='P' AND OOD.BORS=B.SIDE;
                    IF l_count > 0 THEN
                        UPDATE ORDERPTACK SET status = 'A', TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'), TLID = l_strTLID,
                            IPADDRESS = p_txmsg.ipaddress, BRID = p_txmsg.brid, ORDERNUMBER = l_strORDERID
                        WHERE trim(confirmnumber) = trim(p_txmsg.txfields('86').value );
                        UPDATE ODMAST SET CONFIRM_NO =  trim(p_txmsg.txfields('86').value )
                        WHERE ORDERID = l_strORDERID;
                    END IF;
                END IF;
        end if;
    end if;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
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
         plog.init ('TXPKS_#8876EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8876EX;
/
