SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8874ex
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
 **  System      21/10/2009     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
/


CREATE OR REPLACE PACKAGE BODY txpks_#8874ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
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
    l_marginrefprice number(20,4);
    l_marginprice number(20,4);
    l_mrpriceloan number(20,4);
    l_orderprice number(20,4);
    l_deffeerate number(10,6);
    l_chksysctrl varchar2(1);
    l_ismarginallow varchar2(1);
    l_PP0_add number;

    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_activests varchar2(1);

    l_remainamt number;
    l_PPMax number(20,0);
    l_istrfbuy char(1);
    l_seclimit number;

    l_chkmarginbuy char(1);
    l_CheckMaxSameOrd varchar2(10);

    l_strTRADEPLACE varchar2(30);
    l_strSYMBOL varchar2(100);
    l_isoddlot          varchar2(10);
    l_tradlot      number;

    --TrungNQ 07/06/2022: TPDN
    l_sectype varchar2(100);
    l_strPRICETYPE varchar2(30);
    l_strMATCHTYPE varchar2(10);
    --End TrungNQ
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

    --TrungNQ 07/06/2022: TPDN
    l_strPRICETYPE := p_txmsg.txfields('27').value;
    l_strMATCHTYPE := p_txmsg.txfields('24').value;
    --End TrungNQ

    --HSX04|iss:103 check market domain
        IF NOT fn_checkdomain(p_txmsg.txfields('03').value, p_txmsg.txfields('01').value,false) THEN
            p_err_code := -701117;--ERR_SA_INVALID_SECSSION
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
        end IF;

    l_remainamt:=0;
    l_isoddlot := 'N';
    IF p_txmsg.deltd = 'N' THEN

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

        SELECT cf.activests
            INTO l_activests
        FROM cfmast cf, afmast mst
        WHERE cf.custid = mst.custid
            AND mst.acctno = p_txmsg.txfields('03').value;
        /* Ducnv rao, VCBS ko check kich hoat VSD khi dat lenh
        if l_activests <> 'Y' then
            p_err_code := '-100139'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/

        SELECT mr.mrtype, af.actype, mst.groupleader, af.istrfbuy, af.chkmarginbuy
            INTO l_margintype, l_actype, l_groupleader, l_istrfbuy, l_chkmarginbuy
        FROM afmast mst, aftype af, mrtype mr
        WHERE mst.actype = af.actype
            AND af.mrtype = mr.actype
            AND mst.acctno = p_txmsg.txfields('03').value;


        select nvl(rsk.mrratioloan,0),nvl(rsk.mrpriceloan,0), nvl(lnt.chksysctrl,'N'), nvl(rsk.ismarginallow,'N')
            into l_mrratiorate,l_mrpriceloan, l_chksysctrl, l_ismarginallow
        from afmast af, aftype aft, lntype lnt,
            (select * from afserisk where codeid = p_txmsg.txfields('01').value) rsk,
            (select * from v_getbuyorderinfo where afacctno = p_txmsg.txfields('03').value) b
        where af.actype = aft.actype
        and aft.lntype = lnt.actype(+)
        and af.actype = rsk.actype(+)
        and af.acctno = b.afacctno(+)
        and af.acctno = p_txmsg.txfields('03').value;

        --Kiem tra neu tai khoan margin ma co tham so chan mua ngoai danh muc thi bao loi
        if l_chkmarginbuy='Y' and l_margintype in ('S','T') then
            if  l_mrratiorate * l_mrpriceloan = 0 then --Chung khoan khong duoc margin
                p_err_code := '-400099';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;

        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('03').value,'CIMAST','ACCTNO');
        l_PP := l_CIMASTcheck_arr(0).PP;
        l_AVLLIMIT := l_CIMASTcheck_arr(0).AVLLIMIT;
        l_STATUS := l_CIMASTcheck_arr(0).STATUS;

        --TPDN
        begin
            select marginrefprice, marginprice,tradelot into l_marginrefprice, l_marginprice,l_tradlot from securities_info where codeid = p_txmsg.txfields('01').value;
        exception when others then
            p_err_code:=-100025;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        end;
        --End TPDN
        /*--Begin Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua
        BEGIN
            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)/(case when inf.basicprice<=0 then 1 else inf.basicprice end) - nvl(aclm.seqtty,0)
            into l_remainamt
            from securities_risk rsk, securities_info inf,
                (select * from afselimit where afacctno = p_txmsg.txfields('03').value) selm,
                (select * from v_getaccountseclimit where afacctno = p_txmsg.txfields('03').value) aclm
            where rsk.codeid = selm.codeid(+) and rsk.codeid = aclm.codeid(+)
            and rsk.codeid= inf.codeid
            and rsk.codeid = p_txmsg.txfields('01').value;
        exception when others then
            l_remainamt := 0;
        END;
        l_remainamt:= greatest(l_remainamt,0);
        l_PPMax:= floor(l_PP + least(l_remainamt,p_txmsg.txfields('12').value) * l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan));
        --End Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua*/
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
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        if l_margintype not in ('S','T') then
            IF NOT (ceil(to_number(l_PP)) >= to_number(ROUND(p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('13').value*p_txmsg.txfields('98').value/p_txmsg.txfields('99').value,0))) THEN
                p_err_code := '-400116';
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else


            select deffeerate/100 into l_deffeerate from odtype where actype = p_txmsg.txfields('02').value;

            if (l_chksysctrl = 'Y' and l_ismarginallow = 'N') then
                l_PPse:=l_PP;
                IF NOT ceil(l_PPse) >= to_number(ROUND((1 + l_deffeerate)*p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('98').value,0)) THEN
                    p_err_code := '-400116';
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
            else
                if l_chksysctrl = 'Y' then
                    if l_PP > 0 then
                        l_PPse:= l_PP / (1 + l_deffeerate - l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) /(to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('98').value)) );
                    else
                        l_PPse:=l_PP;
                    end if;
                else
                    if l_PP > 0 then
                        l_PPse:= l_PP / (1 + l_deffeerate - l_mrratiorate/100 * least(l_marginprice, l_mrpriceloan) /(to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('98').value)) );
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
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        --Them rule chan han muc theo nhom
        if fn_checkMrlimitByGroup(p_txmsg.txfields('03').value, to_number(p_txmsg.txfields('96').value*p_txmsg.txfields('12').value*p_txmsg.txfields('11').value*p_txmsg.txfields('98').value+p_txmsg.txfields('40').value)) <0 then
            p_err_code := '-400217';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if not cspks_odproc.fn_checkTradingAllow(p_txmsg.txfields('03').value, p_txmsg.txfields('01').value, 'B' , p_err_code) then
            Return errnums.C_BIZ_RULE_INVALID;
        end if;
        -- Bat dau kiem tra lenh doi ung
        begin
            select symbol, tradeplace, sectype into l_strSYMBOL, l_strTRADEPLACE, l_sectype from sbsecurities where codeid = p_txmsg.txfields('01').value;
        exception when others then
            p_err_code:=-100025;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            return errnums.C_BIZ_RULE_INVALID;
        end;
        --ThangPV chinh sua lo le HSX 19-05-2022
        IF l_strTRADEPLACE = '001' AND p_txmsg.txfields('12').value < l_tradlot THEN
           l_isoddlot := 'Y';
        END IF;
        --end ThangPV chinh sua lo le HSX 19-05-2022
            IF NOT fnc_pass_tradebuysell(p_txmsg.txfields('03').value,p_txmsg.txdate,p_txmsg.txfields('01').value,p_txmsg.txfields('22').value,p_txmsg.txfields('27').value,p_txmsg.txfields('24').value,l_strTRADEPLACE,l_strSYMBOL,l_isoddlot) THEN   --ThangPV chinh sua lo le HSX 19-05-2022 them l_isoddlot
              -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    p_err_code :=errnums.C_OD_ORTHER_ORDER_WAITING;
                    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                    Return errnums.C_BIZ_RULE_INVALID;
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

        if l_strTRADEPLACE in ('002','005') and l_sectype='012' and p_txmsg.txfields('12').value <l_tradlot and l_strMATCHTYPE <>'P' then
            p_err_code := '-700139';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        --TrungNQ 07/06/2022:TPDN

    END IF;
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
    l_dblQUOTEPRICE number(30,9); --Sua lai de nhap duoc 6 so sau dau phay
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
    l_index VARCHAR2(6);
    l_dblAvlLimit number(30,4);
    l_ISMARGIN varchar2(1);

    v_strORDERTRADEBUYSELL  Varchar2(10);
    l_strControlCode Varchar2(10);
    v_strTemp  Varchar2(100);
    v_strSysCheckBuySell Varchar2(100);
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
    plog.debug(pkgctx,'Delete: ' || p_txmsg.deltd);
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
            p_err_code := errnums.C_OD_ODMAST_CANNOT_DELETE;
            return l_lngErrCode;
        end if;

    else
        --Make giao dich thi CHECK
        plog.debug(pkgctx,'GET FLD');
        /*FOR i IN p_txmsg.txfields.FIRST .. p_txmsg.txfields.LAST
        LOOP
            l_index := lpad(i,2,'0');
            plog.debug(pkgctx,'l_index: ' || l_index);
            IF p_txmsg.txfields(l_index).defname = 'CODEID' THEN
                plog.debug(pkgctx,'CODEID: ' || p_txmsg.txfields(l_index).value);
                l_strCODEID := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'ACTYPE' THEN
                plog.debug(pkgctx,'ACTYPE: ' || p_txmsg.txfields(l_index).value);
                l_strACTYPE := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'AFACCTNO' THEN
                plog.debug(pkgctx,'AFACCTNO: ' || p_txmsg.txfields(l_index).value);
                l_strAFACCTNO := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'TIMETYPE' THEN
                plog.debug(pkgctx,'TIMETYPE: ' || p_txmsg.txfields(l_index).value);
                l_strTIMETYPE := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'EXPDATE' THEN
                plog.debug(pkgctx,'EXPDATE: ' || p_txmsg.txfields(l_index).value);
                l_strEXPDATE := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'EXECTYPE' THEN
                plog.debug(pkgctx,'EXECTYPE: ' || p_txmsg.txfields(l_index).value);
                l_strEXECTYPE := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'NORK' THEN
                plog.debug(pkgctx,'NORK: ' || p_txmsg.txfields(l_index).value);
                l_strNORK := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'MATCHTYPE' THEN
                plog.debug(pkgctx,'MATCHTYPE: ' || p_txmsg.txfields(l_index).value);
                l_strMATCHTYPE := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'VIA' THEN
                plog.debug(pkgctx,'VIA: ' || p_txmsg.txfields(l_index).value);
                l_strVIA := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'CLEARCD' THEN
                plog.debug(pkgctx,'CLEARCD: ' || p_txmsg.txfields(l_index).value);
                l_strCLEARCD := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'CLEARDAY' THEN
                plog.debug(pkgctx,'CLEARDAY: ' || p_txmsg.txfields(l_index).value);
                l_dblCLEARDAY := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'CONTRACUS' THEN
                plog.debug(pkgctx,'ContraCus: ' || p_txmsg.txfields(l_index).value);
                l_strContraCus := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'CONTRAFIRM' THEN
                plog.debug(pkgctx,'Contrafirm: ' || p_txmsg.txfields(l_index).value);
                l_strContrafirm := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'PUTTYPE' THEN
                plog.debug(pkgctx,'PutType: ' || p_txmsg.txfields(l_index).value);
                l_strPutType := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'DESC' THEN
                plog.debug(pkgctx,'DESC: ' || p_txmsg.txfields(l_index).value);
                l_strDESC := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'ORDERID' THEN
                plog.debug(pkgctx,'ORDERID: ' || p_txmsg.txfields(l_index).value);
                l_strORDERID := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'CONSULTANT' THEN
                plog.debug(pkgctx,'CONSULTANT: ' || p_txmsg.txfields(l_index).value);
                l_strCONSULTANT := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'VOUCHER' THEN
                plog.debug(pkgctx,'VOUCHER: ' || p_txmsg.txfields(l_index).value);
                l_strVOUCHER := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'LIMITPRICE' THEN
                plog.debug(pkgctx,'LIMITPRICE: ' || p_txmsg.txfields(l_index).value);
                l_dblLIMITPRICE := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'BRATIO' THEN
                plog.debug(pkgctx,'l_dblBRATIO: ' || p_txmsg.txfields(l_index).value);
                l_dblBRATIO := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'ORDERQTTY' THEN
                plog.debug(pkgctx,'l_dblORDERQTTY: ' || p_txmsg.txfields(l_index).value);
                l_dblORDERQTTY := p_txmsg.txfields(l_index).value;
            ELSIF p_txmsg.txfields(l_index).defname = 'CONTRAFIRM2' THEN
                plog.debug(pkgctx,'Contrafirm2: ' || p_txmsg.txfields(l_index).value);
                l_strContrafirm2 := p_txmsg.txfields(l_index).value;
            END IF;
        END LOOP;*/

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
        l_strContrafirm := '';
        l_strContraCus := '';
        l_strPutType := '';
        l_strContrafirm2 := '';
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
            Return systemnums.C_SUCCESS;
        end if;*/
        l_dblALLOWBRATIO:=1;

        plog.debug(pkgctx,'abt to check ODTYPE exists or not');
        begin
            SELECT TRADELIMIT,BRATIO/100,DEFFEERATE/100
            into l_dblODTYPETRADELIMIT,l_dblALLOWBRATIO,l_dblDEFFEERATE
            FROM ODTYPE WHERE STATUS='Y' AND ACTYPE=l_strACTYPE;
        EXCEPTION
        WHEN no_data_found THEN
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_ODTYPE_NOTFOUND);
            p_err_code := errnums.C_OD_ODTYPE_NOTFOUND;
            return l_lngErrCode;
        END;


        plog.debug(pkgctx,'abt to check AFMAST exists or not');
        begin
            l_strCIACCTNO := l_strAFACCTNO;
            l_strSEACCTNO := l_strAFACCTNO || l_strCODEID;
            SELECT af.CUSTID,af.STATUS,af.ADVANCELINE,af.BRATIO,af.MRIRATE,af.MRIRATIO,mrt.MRTYPE,MRT.BUYIFOVERDUE,af.ACTYPE AFTYPE, case when mrt.mrtype = 'T' and nvl(lnt.chksysctrl,'N') = 'Y' then 'Y' else 'N' end
                into l_strCUSTID,l_strAFSTATUS,l_dblAFADVANCELIMIT,l_dblALLOWBRATIO,l_dblMarginRate, l_dblMarginRatio,l_strMarginType,l_strBUYIFOVERDUE,l_strAFTYPE, l_ISMARGIN
            FROM AFMAST af,AFTYPE aft, MRTYPE mrt, lntype lnt
            WHERE ACCTNO= l_strAFACCTNO  AND af.ACTYPE=aft.ACTYPE and aft.MRTYPE=mrt.ACTYPE and aft.lntype = lnt.actype(+);
        EXCEPTION
        WHEN no_data_found THEN
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CF_AFMAST_NOTFOUND);
            p_err_code := errnums.C_CF_AFMAST_NOTFOUND;
            return l_lngErrCode;
        end;

        --Kiem tra tai khoan Margin neu bi qua han va l_strBUYIFOVERDUE="N" thi khong cho dat lenh mua
        If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') And l_strBUYIFOVERDUE = 'N'  Then
            SELECT count(1) into l_count FROM CIMAST CI WHERE OVAMT >0 AND CI.ACCTNO= l_strCIACCTNO;
            if l_count>0 then
                plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_MR_ACCTNO_OVERDUE);
                p_err_code := errnums.C_MR_ACCTNO_OVERDUE;
                return l_lngErrCode;
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
        plog.debug(pkgctx,'abt to check CIMAST exists or not');
        begin
            SELECT (BALANCE-ODAMT) into l_dblODBALANCE FROM CIMAST WHERE ACCTNO=l_strCIACCTNO;
        EXCEPTION
        WHEN no_data_found THEN
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CI_CIMAST_NOTFOUND);
            p_err_code := errnums.C_CI_CIMAST_NOTFOUND;
            return l_lngErrCode;
        end;
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
        end if;

        --Kiem tra ma khach hang co ton tai hay khong
        plog.debug(pkgctx,'abt to check CFMAST exists or not');
        begin
            SELECT CUSTODYCD into l_strCUSTODYCD FROM CFMAST WHERE CUSTID=l_strCUSTID;
            --Check xem co tieu khoan nao bi call khong
            if not cspks_cfproc.pr_check_Account_Call(l_strCUSTODYCD) then
                p_err_code := '-200900';
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        EXCEPTION
        WHEN no_data_found THEN
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_CF_CUSTOMER_NOTFOUND);
            p_err_code := errnums.C_CF_CUSTOMER_NOTFOUND;
            return l_lngErrCode;
        end;
        plog.debug(pkgctx,'abt to check SBSECURITIES exists or not');
        begin
            SELECT HALT,TRADEPLACE,SYMBOL,
                ODD_LOT_HALT --LoLeHSX
                into l_strHalt,l_strTRADEPLACE,l_strSYMBOL, l_strOddLotHalt
            FROM SBSECURITIES WHERE CODEID= l_strCODEID;
        EXCEPTION
        WHEN no_data_found THEN
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_SECURITIES_INFO_UNDEFINED);
            p_err_code := errnums.C_OD_SECURITIES_INFO_UNDEFINED;
            return l_lngErrCode;
        end;
        --LoLeHSX
        /*If l_strHalt = 'Y' Then
            p_err_code := errnums.C_OD_CODEID_HALT;
            return l_lngErrCode;
        end if;*/
        --End LoLeHSX
        If (l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC Or l_strTRADEPLACE = errnums.gc_TRADEPLACE_HNCSTC) And Length(Trim(l_strCUSTODYCD)) = 0 Then
            p_err_code := errnums.C_OD_LISTED_NEEDCUSTODYCD;
            Return l_lngErrCode;
        End If;
        If l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC And (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'NS') Then
            --Tham so ham Check TraderID
            SELECT FNC_CHECK_TRADERID( l_strMATCHTYPE ,substr(l_strEXECTYPE ,2,1), l_strVIA ) TRD into l_dblTraderID FROM DUAL;
            If l_dblTraderID = 0 Then
                p_err_code := errnums.C_OD_TRADERID_NOT_INVALID;
                Return l_lngErrCode;
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
                            p_err_code := errnums.C_OD_CONTRA_ORDER_NOT_FOUND;
                            Return l_lngErrCode;
                        End If;
                    Else
                        p_err_code := errnums.C_OD_CONTRA_ORDER_NOT_FOUND;
                        Return l_lngErrCode;
                    End If;
                End If;
            End If;
        End If;

        plog.debug(pkgctx,'abt to check SBSECURITIES_INFO exists or not');
        begin
            SELECT TRADELOT,TRADEUNIT,NVL(RSK.MRMAXQTTY,0) MRMAXQTTY,nvl(BMINAMT,0) BMINAMT,nvl(SMINAMT,0) SMINAMT,FLOORPRICE,CEILINGPRICE,CURRENT_ROOM,TRADEBUYSELL
            into l_dblTradeLot,l_dblTradeUnit,l_dblMarginMaxQuantity,l_dblBuyMinAmount,l_dblSellMinAmount,l_dblFloorPrice,l_dblCeilingPrice,l_dblRoom,l_strTRADEBUYSELL
            FROM SECURITIES_INFO INF, SECURITIES_RISK RSK WHERE INF.CODEID= l_strCODEID  AND INF.CODEID=RSK.CODEID(+);

            --'Kiem tra chan min,max amount
            plog.debug(pkgctx,'Check min amount');
            select varvalue into l_strPreventMinOrder from sysvar where grname ='SYSTEM' and varname ='PREVENTORDERMIN';
            plog.debug(pkgctx,'Check min amount' || l_strPreventMinOrder);
            If l_strPreventMinOrder = 'Y' Then
                If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') Then
                    l_dblCheckMinAmount := l_dblBuyMinAmount;
                Else
                    l_dblCheckMinAmount := l_dblSellMinAmount;
                End If;
                If l_dblQUOTEPRICE * l_dblORDERQTTY * l_dblTradeUnit < l_dblCheckMinAmount Then
                    p_err_code := errnums.C_OD_ORDER_UNDER_MIN_AMOUNT;
                    Return l_lngErrCode;
                End If;
            End If;
            If l_dblTradeUnit > 0 Then
                l_dblQUOTEPRICE := Round(l_dblQUOTEPRICE * l_dblTradeUnit, 6);
            End If;
            --Kiem tra lenh mua nha dau tu nuoc ngoai co con ROOM
            plog.debug(pkgctx,'Check room custodycode:' || l_strCUSTODYCD);
            If l_strEXECTYPE = 'NB' And (substr(l_strCUSTODYCD, 4, 1) = 'F' Or substr(l_strCUSTODYCD, 4, 1) = 'E') Then
                If l_dblORDERQTTY > l_dblRoom Then
                   p_err_code := errnums.C_OD_ROOM_NOT_ENOUGH;
                   Return l_lngErrCode;
               End If;
                null;
            End If;
            --ThangPV chinh sua lo le HSX 27-04-2022
            --Kiem tra khoi luong co chia het cho trdelot hay khong
               /*If l_dblTradeLot > 0 And l_strMATCHTYPE <> 'P' Then
               if    l_strTRADEPLACE ='001' or (l_strTRADEPLACE in ('002','005') and l_dblORDERQTTY>l_dblTradeLot) then
                   If l_dblORDERQTTY Mod l_dblTradeLot <> 0 Then
                        p_err_code :=errnums.C_OD_QTTY_TRADELOT_INCORRECT;
                        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                    Return l_lngErrCode;
                    End If;
               end if ;
            End If;*/
            l_strControlCode:=fn_get_controlcode(l_strSYMBOL);
            If l_dblTradeLot > 0 And l_strMATCHTYPE <> 'P' AND l_strTRADEPLACE in ('001','002','005')  Then
              IF l_dblORDERQTTY >= l_dblTradeLot THEN
                If l_dblORDERQTTY Mod l_dblTradeLot <> 0 Then
                  p_err_code :=errnums.C_OD_QTTY_TRADELOT_INCORRECT;
                  plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                  Return l_lngErrCode;
                End If;
              ELSE
                If l_strPRICETYPE <> 'LO'   Then
                  p_err_code := -700114;
                  plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                  Return l_lngErrCode;
                End if;
              END IF;

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
        /*IF l_strTRADEPLACE = '001' THEN
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

        END IF;*/
        --end ThangPV chinh sua lo le HSX 05-12-2022
        If l_strHalt = 'Y' Then
            p_err_code := errnums.C_OD_CODEID_HALT;
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            return l_lngErrCode;
        end if;

            --Kiem tra voi lenh LO thi gia phai nam trong khoang tran san
            plog.debug(pkgctx,'Check floor ceiling:' || l_dblQUOTEPRICE || ' floor:' || l_dblFloorPrice || ' Ceil:' || l_dblCeilingPrice);
            If l_strPRICETYPE = 'LO' Then
                If l_dblQUOTEPRICE < l_dblFloorPrice Or l_dblQUOTEPRICE > l_dblCeilingPrice Then
                    p_err_code := errnums.C_OD_LO_PRICE_ISNOT_FLOOR_CEIL;
                    Return l_lngErrCode;
                End If;
            End If;
            --Voi lenh LO, stop limit thi kiem tra tick size cua gia
            plog.debug(pkgctx,'Check ticksize:' || l_dblQUOTEPRICE);
            If l_strPRICETYPE = 'LO' Or l_strPRICETYPE = 'SL' Then
                SELECT count(1) into l_count FROM SECURITIES_TICKSIZE WHERE CODEID=l_strCODEID  AND STATUS='Y'
                       AND TOPRICE>= l_dblQUOTEPRICE AND FROMPRICE<=l_dblQUOTEPRICE;

                if l_count<=0 then
                    --Chua dinh nghia TICKSIZE
                    p_err_code := errnums.C_OD_TICKSIZE_UNDEFINED;
                    Return l_lngErrCode;
                else
                    SELECT FROMPRICE, TICKSIZE into l_dblFromPrice,l_dblTickSize
                    FROM SECURITIES_TICKSIZE WHERE CODEID=l_strCODEID  AND STATUS='Y'
                       AND TOPRICE>= l_dblQUOTEPRICE AND FROMPRICE<=l_dblQUOTEPRICE;
                    If (l_dblQUOTEPRICE - l_dblFromPrice) Mod l_dblTickSize <> 0 And l_strMATCHTYPE <> 'P' Then
                        p_err_code := errnums.C_OD_TICKSIZE_INCOMPLIANT;
                        Return l_lngErrCode;
                    End If;
                end if;
            End If;
            /*--Kiem tra chung khoan khong duoc vua mua vua ban trong ngay
            plog.debug(pkgctx,'Check trade buy/sell:' || l_strTRADEBUYSELL);
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
                    p_err_code := errnums.C_OD_BUYSELL_SAME_SECURITIES;
                    Return l_lngErrCode;
                End If;
            End If;*/

             --Kiem tra chung khoan khong duoc vua mua vua ban trong ngay
             -- quyet.kieu : Ghep them phan mua ban chung khoan cung phien theo thong tu 74

          Select VARVALUE Into v_strORDERTRADEBUYSELL from sysvar where GRNAME ='SYSTEM' and VARNAME ='ORDERTRADEBUYSELL' ;

          If v_strORDERTRADEBUYSELL = 'N'  Then
               -- quyet.kieu : khong duoc phep dat lenh cho ( check tat ca cac loai lenh )
               -- kiem tra tat ca cac loai lenh( LO, ATO , ATC ) neu co lenh nguoc chieu chua khop thi khong cho dat lenh

                If l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC' Then
                    SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= l_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                    AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0;
                Else
                    SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= l_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                    AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                End If;

                If l_count > 0 Then
                   -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    p_err_code :=errnums.C_OD_ORTHER_ORDER_WAITING;
                    Return l_lngErrCode;
                End If;

         End if ;

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
                    Return l_lngErrCode;
                End If;

            Elsif l_strTRADEBUYSELL = 'Y' And l_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC Then

                 Begin
                   Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
                 Exception When OTHERS Then
                   v_strSysCheckBuySell:='N';
                 End;

                 If v_strSysCheckBuySell ='N' Then

                                      --Lay thong tin phien
                                      Select sysvalue into l_strControlCode  from ordersys where sysname ='CONTROLCODE';

                                      --Neu dat LO thi check d?? ATC doi ung o phien 2 va LO, ATC doi ung o phien 3.
                                      --Neu dat ATO thi check LO, ATO d?i ?ng.
                                      --?t ATC th?heck ch?n ATC, LO d?i ?ng
                                      If l_strPRICETYPE IN ('LO') And l_strMATCHTYPE <> 'P'   Then

                                            If l_strControlCode ='O' Then
                                                v_strTemp:='ATC';
                                            Elsif l_strControlCode ='A' Then
                                                v_strTemp:='LO,ATC';
                                            End if;

                                      ELSIF l_strPRICETYPE IN ('LO') And l_strMATCHTYPE = 'P'   Then --Lenh thoa thuan thi chan tat ca lenh doi ung.

                                            v_strTemp:='LO,ATO,ATC';

                                      Elsif l_strPRICETYPE IN ('ATO') Then
                                            v_strTemp:='LO,ATO';
                                      Elsif l_strPRICETYPE IN ('ATC') Then
                                            v_strTemp:='LO,ATC';
                                      End if;

                                    If l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC' Then

                                         SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= l_strCODEID
                                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                                         AND INSTR(v_strTemp,PRICETYPE)>0
                                         AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N'
                                         AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY>0;
                                     Else
                                         SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= l_strCODEID
                                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                                         AND INSTR(v_strTemp,PRICETYPE)>0
                                         AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N'
                                         AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                                     End If;
                                     plog.debug(pkgctx,'v_strTemp: ' || v_strTemp);
                                     If l_count > 0 Then
                                         --Bao loi khong duoc mua ban mot chung khoan trong cuang 1 ngay
                                         p_err_code :=errnums.C_OD_BUYSELL_SAME_SECURITIES;
                                         Return l_lngErrCode;
                                     End If;
            End if; --Sysbuysell
        Elsif l_strTRADEBUYSELL = 'Y' And l_strTRADEPLACE = errnums.gc_TRADEPLACE_HNCSTC Then
        --Neu san HNX thi chi check thoan thuan
          Begin
             Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
           Exception When OTHERS Then
             v_strSysCheckBuySell:='N';
           End;

           If v_strSysCheckBuySell ='N' And l_strMATCHTYPE = 'P'   Then
               v_strTemp:='LO,ATO,ATC';
           End if;
           If l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC' Then

                 SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= l_strCODEID
                     AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                     AND INSTR(v_strTemp,PRICETYPE)>0
                     AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N'
                     AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY>0;
                 Else
                     SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= l_strCODEID
                     AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
                     AND INSTR(v_strTemp,PRICETYPE)>0
                     AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N'
                     AND EXPDATE >= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                 End If;
                 plog.debug(pkgctx,'v_strTemp: ' || v_strTemp);
                 If l_count > 0 Then
                     --Bao loi khong duoc mua ban mot chung khoan trong cuang 1 ngay
                     p_err_code :=errnums.C_OD_BUYSELL_SAME_SECURITIES;
                     Return l_lngErrCode;
                 End If;
        End if;
      -- End kiem tra chung khoan khong duoc vua mua vua ban trong ngay


        EXCEPTION
        WHEN no_data_found THEN
            plog.debug(pkgctx,'l_lngErrCode: ' || errnums.C_OD_SECURITIES_INFO_UNDEFINED);
            p_err_code := errnums.C_OD_SECURITIES_INFO_UNDEFINED;
            Return l_lngErrCode;
        end;

       /* plog.debug(pkgctx,'l_strOVRRQD1: ' || l_strOVRRQD);
        --Kiem tra vuot han muc yeu cau checker duyet
        If l_dblQUOTEPRICE * l_dblORDERQTTY > l_dblODTYPETRADELIMIT Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_ORDERTRADELIMIT;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;*/

        plog.debug(pkgctx,'l_strOVRRQD2: ' || l_strOVRRQD);
        If l_dblBRATIO < l_dblALLOWBRATIO Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_ORDERSECURERATIO;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;
        /*
        plog.debug(pkgctx,'l_strOVRRQD3: ' || l_strOVRRQD);
        --Neu vuot qua han muc giao dich cua HD
        SELECT SUM(QUOTEPRICE*ORDERQTTY) AMT into l_count FROM ODMAST WHERE AFACCTNO=l_strAFACCTNO;
        If l_dblQUOTEPRICE * l_dblORDERQTTY + l_count > l_dblAFTRADELIMIT Then
            l_strOVRRQD := l_strOVRRQD || errnums.OVRRQS_AFTRADELIMIT;
            p_txmsg.ovrrqd := l_strOVRRQD;
        End If;
        */
        --Kiem tra neu gia tri ung truoc vuot qua han muc ung truoc trong hop dong thi yeu cau checker duyet
        /*If (l_strEXECTYPE = 'NB' Or l_strEXECTYPE = 'BC') And l_strMarginType = 'N' Then
            SELECT SUM(QUOTEPRICE*REMAINQTTY*(1+TYP.DEFFEERATE/100)+EXECAMT) ODAMT into l_count
            FROM ODMAST OD, ODTYPE TYP
            WHERE OD.ACTYPE=TYP.ACTYPE
            AND  OD.AFACCTNO= l_strAFACCTNO
            AND OD.TXDATE= TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)
            AND DELTD <>'Y' AND OD.EXECTYPE IN ('NB','BC') ;
            if l_dblQUOTEPRICE * l_dblORDERQTTY + l_count > l_dblAFADVANCELIMIT + l_dblODBALANCE Then
                p_err_code := errnums.C_OD_ADVANCELINE_OVER_LIMIT;
                Return l_lngErrCode;
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
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_return_code number(20,0);
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
    l_dblQUOTEPRICE number(30,9); --Sua lai de nhap 6 so sau dau phay
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
    l_strTLID VARCHAR2(30);
    --/>
    l_strSSAFACCTNO varchar2(10);
    Pl_REFCURSOR   PKG_REPORT.REF_CURSOR;
    --<QuyetKD add update HNX
     l_dblQuoteQtty number(30,4);
     l_strPtDeal varchar2(10);
    --/>
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    ---------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------
    --</ TruongLD Add
    l_strTLID := p_txmsg.tlid;
    --/>
    l_strBRID :=p_txmsg.BRID;
    l_strTXDATE :=p_txmsg.TXDATE;
    l_strTXNUM :=p_txmsg.TXNUM;
    l_strTXTIME :=p_txmsg.TXTIME;
    l_strTXDESC :=p_txmsg.TXDESC;
    l_strOVRRQD :=p_txmsg.OVRRQd;
    l_strCHKID:= p_txmsg.CHKID;
    l_strOFFID:= p_txmsg.OFFID;
    l_strDELTD :=p_txmsg.DELTD;
    l_return_code:=errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;
    if p_txmsg.deltd='Y' then
        l_blnReversal:=true;
    else
        l_blnReversal:=false;
    end if;
    l_strCODEID := p_txmsg.txfields('01').value;
    l_strACTYPE := p_txmsg.txfields('02').value;
    l_strAFACCTNO := p_txmsg.txfields('03').value;
    plog.debug (pkgctx, 'l_strAFACCTNO' || l_strAFACCTNO);
    l_strTIMETYPE := p_txmsg.txfields('20').value;
    l_strEFFDATE:= p_txmsg.txfields('19').value;
    l_strEXPDATE := p_txmsg.txfields('21').value;
    l_strEXECTYPE := p_txmsg.txfields('22').value;
    l_strNORK := p_txmsg.txfields('23').value;
    plog.debug (pkgctx, 'l_strNORK' || l_strNORK);
    l_strMATCHTYPE := p_txmsg.txfields('24').value;
    l_strVIA := p_txmsg.txfields('25').value;
    l_strCLEARCD := p_txmsg.txfields('26').value;
    l_strPRICETYPE := p_txmsg.txfields('27').value;
    l_dblCLEARDAY := p_txmsg.txfields('10').value;
    plog.debug (pkgctx, 'l_dblCLEARDAY' || l_dblCLEARDAY);
    l_dblQUOTEPRICE := p_txmsg.txfields('11').value;
    l_dblORDERQTTY := p_txmsg.txfields('12').value;
    l_dblBRATIO := p_txmsg.txfields('13').value;
    l_dblLIMITPRICE := p_txmsg.txfields('14').value;
    l_strVOUCHER := p_txmsg.txfields('28').value;
    plog.debug (pkgctx, 'l_strCONSULTANT' || l_strCONSULTANT);
    l_strCONSULTANT := p_txmsg.txfields('29').value;
    l_strORDERID := p_txmsg.txfields('04').value;
    l_strDESC := p_txmsg.txfields('30').value;
    l_strMember:= p_txmsg.txfields('50').value;
    l_strContrafirm := '';
    l_strTraderid := '';
    l_strClientID := '';
    l_strOutPriceAllow := p_txmsg.txfields('34').value;
    l_strContraCus := replace(p_txmsg.txfields('71').value,'.','');
    l_strPutType := replace(p_txmsg.txfields('72').value,'.','');
    l_strContrafirm2 := replace(p_txmsg.txfields('73').value,'.','');

    l_dblQuoteQtty:= p_txmsg.txfields('80').value;


    If l_strMATCHTYPE ='P' then
        l_strPtDeal:= p_txmsg.txfields('81').value;
        else
        l_strPtDeal:=null;
    end if;
    begin
        l_strSSAFACCTNO:=p_txmsg.txfields('94').value;
    exception when others then
        l_strSSAFACCTNO:='';
    end;

    if l_strPRICETYPE ='MP' then
        l_strPRICETYPE := 'MTL';
    end if;


    plog.debug (pkgctx, 'l_strORDERID' || l_strORDERID);
    If l_strTIMETYPE = 'G' And substr(l_strORDERID,1, 2) <> errnums.C_FO_PREFIXED Then
        --Neu la lenh Good till cancel, ma la lenh dat
        If l_blnReversal Then
            SELECT count(1) into l_count FROM FOMAST WHERE ACCTNO =l_strORDERID  AND STATUS <> 'P';
            If l_count > 0 Then
                --Khong the xoa lenh nay
                p_err_code := errnums.C_ERRCODE_FO_INVALID_STATUS;
                Return l_return_code;
            End If;
            --Xoa giao dich
            DELETE FROM FOMAST WHERE ACCTNO =l_strORDERID ;
        Else
            --Day lenh vao FOMAST
            --Lay ra ma chung khoan
            l_strSYMBOL:='';
            SELECT SYMBOL into l_strSYMBOL
            FROM SBSECURITIES WHERE CODEID =l_strCODEID ;

            l_strFEEDBACKMSG := l_strDESC;
            INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE,
                MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE,
                TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,EFFDATE,EXPDATE,BRATIO,VIA,OUTPRICEALLOW,TXNUM,TXDATE, QUOTEQTTY,LIMITPRICE)
                VALUES ( l_strORDERID , l_strORDERID, l_strACTYPE, l_strAFACCTNO,'P',
                 l_strEXECTYPE, l_strPRICETYPE, l_strTIMETYPE, l_strMATCHTYPE,
                 l_strNORK, l_strCLEARCD, l_strCODEID, l_strSYMBOL,
                'N','A', l_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),
                 l_dblCLEARDAY , l_dblORDERQTTY , l_dblLIMITPRICE , l_dblQUOTEPRICE , 0 , 0 , 0 ,
                 l_dblORDERQTTY ,TO_DATE( l_strEFFDATE ,  systemnums.C_DATE_FORMAT ),TO_DATE( l_strEXPDATE , systemnums.C_DATE_FORMAT),
                 l_dblBRATIO , l_strVIA , l_strOutPriceAllow , p_txmsg.txnum ,
                 TO_DATE( p_txmsg.txdate,  systemnums.C_DATE_FORMAT ),l_dblQuoteQtty,l_dblLIMITPRICE);
        End If;
        Return systemnums.C_SUCCESS;
    End If;
    --Lenh today hoac Intemediate or cancel
    --Hoac lenh GTC tu dong day vao he thong
    if l_blnReversal then
        plog.debug (pkgctx, 'l_strORDERID2' || l_strORDERID);
        SELECT COUNT(1) into l_count FROM ODMAST WHERE REFORDERID =l_strORDERID ;
        If l_count > 0 Then
            --khogn the xoa lenh nay
            p_err_code := errnums.C_OD_ODMAST_CANNOT_DELETE;
            Return l_return_code;
        End If;
        --Kiem tra lenh co dc xoa hay khong
        plog.debug (pkgctx, 'txnum,txdate: ' || p_txmsg.txnum || p_txmsg.txdate);
        SELECT COUNT(1) into l_count FROM ODMAST
        WHERE TXNUM=p_txmsg.txnum  AND TXDATE=TO_DATE( p_txmsg.txdate , systemnums.C_DATE_FORMAT)
        AND ORSTATUS IN ('1','2','8');
        plog.debug (pkgctx, 'l_count: ' || l_count);
        If l_count <= 0 Then
            --Khong dc xoa lenh nay
            plog.debug (pkgctx, '11');
            p_err_code := errnums.C_OD_ODMAST_CANNOT_DELETE;
            plog.debug (pkgctx, '12 ' || l_return_code);
            Return l_return_code;
        End If;
        --Xoa giao dich
        plog.debug (pkgctx, 'p_txmsg.txnum.txdate2' || p_txmsg.txnum || p_txmsg.txdate);
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
            l_dblQUOTEPRICE := Round(l_dblQUOTEPRICE * l_dblTradeUnit,6);
            l_dblLIMITPRICE := Round(l_dblLIMITPRICE * l_dblTradeUnit,6);
        End If;
        If Length(l_strMember) > 0 Then
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
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,
                                         CONSULTANT,CONTRAFIRM, TRADERID,CLIENTID,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,QUOTEQTTY,PTDEAL)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'1','1', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY ,0,0,0,0,0,0,'001', l_strVOUCHER
                                         , l_strCONSULTANT , l_strContrafirm , l_strTraderid , l_strClientID , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID ,l_dblQuoteQtty,l_strPtDeal);
        elsif p_txmsg.tltxcd='8874' then
        --Ghi nhan vao so lenh
                        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO,QUOTEQTTY,PTDEAL)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'8','9', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,0,'001', l_strVOUCHER
                                         , l_strCONSULTANT , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID,l_strSSAFACCTNO ,l_dblQuoteQtty,l_strPtDeal);
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
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,'001', l_strVOUCHER , l_strCONSULTANT , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID,l_strSSAFACCTNO );

                        INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                                       BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
                        VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,'S', l_strMATCHTYPE
                                       , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'N',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );
        elsif p_txmsg.tltxcd='8876' then
                        INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                                         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                                         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                                         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                                         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,CONTRAFIRM, TRADERID,CLIENTID,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO)
                         VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                                         , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                                         ,TO_DATE( l_strEXPDATE ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , l_strTIMETYPE
                                         , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , l_strVIA
                                         , l_dblCLEARDAY , l_strCLEARCD ,'8','8', l_strPRICETYPE
                                         , l_dblQUOTEPRICE ,0, l_dblLIMITPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE , l_dblORDERQTTY ,0,0,0,0,0,0,'001', l_strVOUCHER , l_strCONSULTANT , l_strContrafirm , l_strTraderid , l_strClientID , l_strFOACCTNO , l_strPutType , l_strContraCus , l_strContrafirm2, l_strTLID,l_strSSAFACCTNO );
                         INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                                        BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
                        VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,'B', l_strMATCHTYPE
                                        , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'N',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );

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

        end if;
    end if;

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
         plog.init ('TXPKS_#8874EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8874EX;
/
