SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_getppse (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, p_afacctno IN VARCHAR2, p_symbol in varchar2, p_quoteprice in number, p_via in varchar2 default 'O')
  IS
    l_DefFeeRate number(20,8);
    l_count number;
    l_AvlLimit number;
    l_AvlLimitref number;
    l_MarginType varchar2(1);
    l_ChkSysCtrl varchar2(1);
    l_RskMarginRate number(20,8);
    l_RskMarginPrice number(20,0);
    l_IsMarginAllow varchar2(1);
    l_MarginPrice number(20,0);
    l_MarginRefPrice number(20,0);
    l_SysMarginRate number(20,8);
    l_FloorPrice number(20,0);
    l_quoteprice number(20,0);
    l_pp0 number(25,0);
    l_ppSE number(25,0);
    l_pp0Ref number(25,0);
    l_ppSERef number(25,0);
    l_codeid varchar2(10);
    l_avlroomqtty number;
    l_avlsyroomqtty number;
    l_avlqtty number;
    l_avlsyqtty number;
    l_PP0_add number;
    l_RskMarginRate_in_basket number;
    l_RskMarginPrice_in_basket number;
    l_TradeLot number(20,0);
    l_T0SecureAmt number(25,4);
    l_SecType varchar2(100);
    l_Aftype varchar2(4);

    l_remainamt number;
    l_PPMax number(25,0);
    l_PPrefMax number(25,0);
    l_istrfbuy char(1);
    l_seclimit number;
    l_MaxQtty   number; --14/09/2022 DieuNDA Lo le HSX
BEGIN
    l_RskMarginRate_in_basket:=0;
    l_RskMarginPrice_in_basket:=0;
    l_remainamt:=0;

    begin
        select pp, ppref
        into l_pp0, l_pp0Ref
        from buf_ci_account where afacctno = p_afacctno;
    exception when others then
        l_pp0:=0;
        l_pp0Ref:=0;
    end;

    select se.marginprice, se.marginrefprice, se.floorprice, se.codeid, se.tradelot, sb.sectype
        into l_MarginPrice, l_MarginRefPrice, l_FloorPrice, l_codeid, l_TradeLot, l_SecType
    from securities_info se, sbsecurities sb
    where se.codeid = sb.codeid and se.symbol = p_symbol;

    select actype into l_Aftype from afmast where acctno = p_afacctno;

    begin
       SELECT deffeerate/100
       into l_DefFeeRate
       FROM (   SELECT a.deffeerate, b.ODRNUM
               FROM odtype a, afidtype b
               WHERE     a.status = 'Y'
                     AND (a.via = p_via OR a.via = 'A') --VIA
                     /*AND a.clearcd = l_build_msg (indx).fld26       --CLEARCD
                     AND (a.exectype = l_strEXECTYPE           --l_build_msg (indx).fld22
                          OR a.exectype = 'AA')                    --EXECTYPE
                     AND (a.timetype = l_build_msg (indx).fld20
                          OR a.timetype = 'A')                     --TIMETYPE
                     AND (a.pricetype = l_build_msg (indx).fld27
                          OR a.pricetype = 'AA')                  --PRICETYPE
                     AND (a.matchtype = l_build_msg (indx).fld24
                          OR a.matchtype = 'A')                   --MATCHTYPE
                     AND (a.tradeplace = l_build_msg (indx).tradeplace
                          OR a.tradeplace = '000')*/
                     AND (instr(case when l_SecType in ('001','002') then l_SecType || ',' || '111,333'
                                     when l_SecType in ('003','006') then l_SecType || ',' || '222,333,444'
                                     when l_SecType in ('008') then l_SecType || ',' || '111,444'
                                     else l_SecType end , a.sectype)>0 OR a.sectype = '000')
                     /*AND (a.nork = l_build_msg (indx).fld23 OR a.nork = 'A') --NORK*/
                     AND (CASE WHEN A.CODEID IS NULL THEN l_codeid ELSE A.CODEID END)=l_codeid
                     AND a.actype = b.actype and b.aftype=l_Aftype and b.objname='OD.ODTYPE'
                     order BY A.deffeerate, B.ACTYPE DESC
             ) where rownum<=1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        begin
            select nvl(fn_getmaxdeffeerate(p_afacctno),0) into l_DefFeeRate from dual;
        exception when others then
            l_DefFeeRate:=0;
        end;
    END;
/*    begin
        select nvl(fn_getmaxdeffeerate(p_afacctno),0) into l_DefFeeRate from dual;
    exception when others then
        l_DefFeeRate:=0;
    end;*/

    if p_quoteprice is null then
        l_quoteprice:= l_FloorPrice;
    else
        l_quoteprice:= greatest(p_quoteprice,l_FloorPrice);
    end if;

    select mrt.mrtype, nvl(chksysctrl,'N'),aft.istrfbuy
        into l_MarginType, l_ChkSysCtrl, l_istrfbuy
    from afmast af, aftype aft, lntype lnt, mrtype mrt
    where af.actype  = aft.actype and aft.lntype = lnt.actype(+) and aft.mrtype = mrt.actype and af.acctno = p_afacctno;

    if l_MarginType IN ( 'T','F') then

        begin
            select rsk.mrratioloan/100, rsk.mrpriceloan, rsk.ismarginallow
                into l_RskMarginRate, l_RskMarginPrice, l_IsMarginAllow
            from afmast af, afserisk rsk
            where af.actype = rsk.actype and af.acctno = p_afacctno and rsk.codeid = l_codeid;
        exception when others then
            l_RskMarginRate:=0;
            l_RskMarginPrice:=0;
            l_IsMarginAllow:='N';
            l_RskMarginRate_in_basket:=null;
            l_RskMarginPrice_in_basket:=null;
        end;


        if l_ChkSysCtrl = 'Y' then
            if l_IsMarginAllow = 'N' then
                l_RskMarginRate:=0;
            else
                l_MarginPrice:= least(l_MarginPrice, l_MarginRefPrice, l_RskMarginPrice);
            end if;
            select (1-to_number(varvalue)/100) into l_SysMarginRate from sysvar where varname = 'IRATIO' and grname = 'MARGIN';
            l_RskMarginRate:=least(l_RskMarginRate,l_SysMarginRate);
        else
            l_MarginPrice:= least(l_MarginPrice, l_RskMarginPrice);
        end if;

        /*--Begin Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua
        BEGIN
            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)/(case when inf.basicprice<=0 then 1 else inf.basicprice end) - nvl(aclm.seqtty,0)
            into l_remainamt
            from securities_risk rsk, securities_info inf,
                (select * from afselimit where afacctno = p_afacctno) selm,
                (select * from v_getaccountseclimit where afacctno = p_afacctno) aclm
            where rsk.codeid = selm.codeid(+) and rsk.codeid = aclm.codeid(+)
            and rsk.codeid= inf.codeid
            and rsk.codeid = l_codeid;
        exception when others then
            l_remainamt := 0;
        END;
        l_remainamt:= greatest(l_remainamt,0);
        l_PPMax:= floor(l_pp0 + l_remainamt * l_RskMarginRate * l_MarginPrice);
        l_PPrefMax:= floor(l_pp0Ref + l_remainamt * l_RskMarginRate * l_MarginPrice);
        --End Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua*/
        --Begin Lay thong tin Ham muc chung khoan con lai
        begin
            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end) into l_seclimit
            from securities_risk rsk,
                (select * from afselimit where afacctno = p_afacctno) selm
            where rsk.codeid = selm.codeid(+)
            and rsk.codeid = l_codeid;
        exception when others then
            l_seclimit:=0;
        end;
        if l_seclimit>0 then
            begin
                select l_seclimit - nvl(aclm.seqtty,0)* l_RskMarginRate * l_MarginPrice into l_remainamt
                from v_getaccountseclimit aclm where afacctno = p_afacctno and codeid = l_codeid;
            exception when others then
                l_remainamt:=l_seclimit;
            end;
        end if;
        --End Lay thong tin Ham muc chung khoan con lai
        l_remainamt:= greatest(l_remainamt,0);
        l_PPMax:= floor(l_pp0 + l_remainamt);
        l_PPrefMax:= floor(l_pp0Ref + l_remainamt);

        --pr_error('pr_getPPSE', 'l_remainamt:' || l_remainamt);
        --pr_error('pr_getPPSE', 'l_PPMax:' || l_PPMax);
        --pr_error('pr_getPPSE', 'l_PPrefMax:' || l_PPrefMax);
    else
        open PV_REFCURSOR for
        select l_pp0 PPSE, l_pp0Ref PPSEREF, '---' MRRATIOLOAN, '---' MRPRICELOAN,
                --14/09/2022 DieuNDA: LoLeHSX
                --trunc(floor( l_pp0ref / l_quoteprice/(1+l_DefFeeRate))/l_TradeLot)*l_TradeLot MAXQTTY
                trunc(floor( l_pp0ref / l_quoteprice/(1+l_DefFeeRate))) MAXQTTY
                --End 14/09/2022 DieuNDA: LoLeHSX
                from dual;
        return;
    end if;

    select round(nvl(adv.avladvance,0) + nvl(balance,0)- nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0)  - nvl (overamt,0) -nvl(secureamt,0) + nvl(af.advanceline,0) - nvl(ramt,0)/* - nvl(depofeeamt,0)*/ + AF.mrcrlimitmax+nvl(AF.mrcrlimit,0)+nvl(AF.clamtlimit,0)  - dfodamt,0),
           round(nvl(adv.avladvance,0) + nvl(balance,0)+ nvl(bankavlbal,0)- nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0)  - nvl (overamt,0) -nvl(secureamt,0) + nvl(af.advanceline,0) - nvl(ramt,0)/* - nvl(depofeeamt,0)*/ + AF.mrcrlimitmax+nvl(AF.mrcrlimit,0)+nvl(AF.clamtlimit,0) - dfodamt,0)
        into l_AvlLimit,l_AvlLimitref
    from cimast ci inner join afmast af on ci.acctno=af.acctno
        left join
        (select * from v_getbuyorderinfo where afacctno = p_afacctno) b
        on  ci.acctno = b.afacctno
        LEFT JOIN
        (select sum(depoamt) avladvance, sum(paidamt) paidamt, sum(advamt) advanceamount,afacctno, sum(aamt) aamt from v_getAccountAvlAdvance where afacctno = p_afacctno group by afacctno) adv
        on adv.afacctno=ci.acctno
        LEFT JOIN
        (select * from v_getdealpaidbyaccount p where p.afacctno = p_afacctno) pd
        on pd.afacctno=ci.acctno
        where ci.acctno = p_afacctno;
    --pr_error('pr_getPPSE', 'l_RskMarginRate:' || l_RskMarginRate);
    --pr_error('pr_getPPSE', 'l_MarginPrice:' || l_MarginPrice);
    --pr_error('pr_getPPSE', 'l_quoteprice:' || l_quoteprice);
    --pr_error('pr_getPPSE', 'l_DefFeeRate:' || l_DefFeeRate);
    --pr_error('pr_getPPSE', 'l_pp0:' || l_pp0);
    if l_pp0 > 0 and (1 + l_DefFeeRate - l_RskMarginRate * l_MarginPrice/l_quoteprice) <> 0 and l_RskMarginRate * l_MarginPrice>0 then
        l_ppSE:=(L_PP0 *(1 + L_DEFFEERATE) / (1 + l_DefFeeRate - l_RskMarginRate * l_MarginPrice/l_quoteprice));
    else
        l_ppSE:=l_pp0;
    end if;
    if l_pp0Ref > 0 and (1 + l_DefFeeRate - l_RskMarginRate * l_MarginPrice/l_quoteprice) <> 0 and l_RskMarginRate * l_MarginPrice>0 then
        l_ppSERef:=(L_PP0REF *(1 + L_DEFFEERATE) / (1 + l_DefFeeRate - l_RskMarginRate * l_MarginPrice/l_quoteprice));
    else
        l_ppSERef:=l_pp0Ref;
    end if;


    -- Lay min voi han muc:
    l_ppSE:= least(l_ppSE,l_AvlLimit,l_ppMax);
    l_ppSERef:= least(l_ppSERef,l_AvlLimitref,l_ppRefMax);
    --pr_error('pr_getPPSE', 'l_ppSE:' || l_ppSE);
    open PV_REFCURSOR for
    select l_ppSE PPSE, l_ppSERef PPSEREF,
        decode(l_RskMarginRate_in_basket, null, '---', l_RskMarginRate * 100) MRRATIOLOAN,
        decode(l_RskMarginPrice_in_basket, null, '---', l_MarginPrice * 100) MRPRICELOAN,
        --14/09/2022 DieuNDA: LoLeHSX
        --trunc(floor(l_ppSERef / l_quoteprice/(1+l_DefFeeRate))/l_TradeLot)*l_TradeLot MAXQTTY
        trunc(floor(l_ppSERef / l_quoteprice/(1+l_DefFeeRate))) MAXQTTY
        --End 14/09/2022 DieuNDA: LoLeHSX
    from dual;
    --pr_error('pr_getPPSE', 'l_ppSE:' || l_quoteprice);
    --pr_error('pr_getPPSE', 'l_ppSE:' || l_DefFeeRate);
    --pr_error('pr_getPPSE', 'l_ppSE:' || l_TradeLot);
    return;
EXCEPTION WHEN others THEN
    --plog.error('PPSE.EXCEPTION WHEN others THEN:'||dbms_utility.format_error_backtrace);
    open PV_REFCURSOR for
    select 0 PPSE,0 PPSEREF, '---' MRRATIOLOAN,'---' MRPRICELOAN, 0 MAXQTTY from dual;
    return;
END;
/
