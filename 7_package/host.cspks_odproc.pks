SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_odproc
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

    FUNCTION fn_checkTradingAllow(p_afacctno varchar2, p_codeid varchar2, p_bors varchar2, p_err_code in out varchar2)
    RETURN boolean;
    Procedure pr_MortgageSellAllocate(p_Orderid varchar2,p_afacctno varchar2, p_codeid varchar2, p_dfacctno varchar2, p_orderqtty number);
    Procedure pr_MortgageSellRelease(p_Orderid varchar2,p_afacctno varchar2, p_codeid varchar2, p_dfacctno varchar2, p_orderqtty number,p_qtty number);
    Procedure pr_MortgageSellMatch(p_Orderid varchar2,p_qtty number, p_amount number, p_afacctno varchar2, p_CodeID varchar2);
    Procedure pr_CancelGroupOrder(p_Orderid varchar2);
    Procedure pr_RM_UnholdCancelOD( pv_strORDERID varchar2,pv_dblCancelQtty number,pv_strErrorCode in out varchar2);
    Procedure pr_SEMarginInfoUpdate(p_Afacctno varchar2, p_Codeid varchar2, p_Qtty number);
    FUNCTION fn_OD_ClearOrder(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
    RETURN NUMBER;
    PROCEDURE pr_ConfirmOrder(p_Orderid varchar2,p_userId VARCHAR2,p_custid VARCHAR2,p_Ipadrress VARCHAR2,pv_strErrorCode in out varchar2, p_via VARCHAR2, p_validationtype in varchar2 default '', p_devicetype IN varchar2 default '', p_device IN varchar2 default '');
    FUNCTION fn_OD_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2; -- HAM THUC HIEN LAY SO HIEU LENH GOC CUA LENH

    procedure pr_CancelOrderAfterDay(pv_exectype varchar2, p_err_code in out varchar2);
    procedure pr_CancelOrderid(pv_orderid varchar2, p_err_code in out varchar2);
    procedure pr_ODProcessFeeCalculate(p_err_code in out varchar2);
    /*PROCEDURE pr_update_secinfo ( pv_Symbol  VARCHAR2, pv_ceilingprice  VARCHAR2,pv_floorprice  varchar2 ,pv_basicprice  VARCHAR2, pv_tradeplace  varchar2,pv_haltflag  varchar2, p_err_code in out varchar2,
    pv_odd_lot_haltflag in VARCHAR2 DEFAULT 'N', pv_issuer in varchar2 default ''); --LoLeHSX*/
    PROCEDURE pr_update_secinfo ( pv_Symbol  VARCHAR2, pv_ceilingprice  VARCHAR2,pv_floorprice  varchar2 ,pv_basicprice  VARCHAR2, pv_tradeplace  varchar2,pv_haltflag  varchar2, p_err_code in out varchar2,
    pv_security_name IN VARCHAR2 DEFAULT NULL, p_securitytype IN varchar2,p_SecurituGroupID FILE_INSTRUMENT_SBR.Securitygroupid%TYPE,p_Isincode sbsecurities.isincode%TYPE); --LoLeHSX

    procedure pr_odfeecalculate_for_acctno(p_afacctno   varchar, p_err_code out varchar2 ) ;
END;
/


CREATE OR REPLACE PACKAGE BODY cspks_odproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------------pr_OpenLoanAccount------------------------------------------------
  FUNCTION fn_checkTradingAllow(p_afacctno varchar2, p_codeid varchar2, p_bors varchar2, p_err_code in out varchar2)
  RETURN boolean
  IS
  l_cfmarginallow varchar2(1);
  l_chksysctrl varchar2(1);
  l_policycd varchar2(1);
  l_actype varchar2(4);
  l_foa varchar2(20);
  l_bors varchar2(20);
  l_count number(10);
  l_isMarginAccount varchar2(1);
  l_busdate date;
  v_ALLOWSESSION varchar2(20);
  v_tradeplace varchar2(20);
  v_CONTROLCODE varchar2(20);
  BEGIN
    plog.setbeginsection(pkgctx, 'fn_checkTradingAllow');
    --Kiem tra xem chung khoan co bi chan boi phien giao dich hay khong
    begin
        select nvl(ALLOWSESSION,'AL'), tradeplace into v_ALLOWSESSION,v_tradeplace from sbsecurities where codeid =p_codeid;
        if v_tradeplace = '001' and v_ALLOWSESSION <> 'AL' then
            select sysvalue into v_CONTROLCODE from ordersys where sysname ='CONTROLCODE';
            if v_ALLOWSESSION ='OP' and v_CONTROLCODE<>'P' then --Chung khoan chi duoc dat lenh phien mo cua
                p_err_code:= '-700071';
                plog.setendsection(pkgctx, 'fn_checkTradingAllow');
                return false;
            end if;
            if v_ALLOWSESSION ='CO' and v_CONTROLCODE<>'O' then --Chung khoan chi duoc dat lenh phien lien tuc
                p_err_code:= '-700072';
                plog.setendsection(pkgctx, 'fn_checkTradingAllow');
                return false;
            end if;
            if v_ALLOWSESSION ='CL' and v_CONTROLCODE<>'A' then --Chung khoan chi duoc dat lenh phien dong cua
                p_err_code:= '-700073';
                plog.setendsection(pkgctx, 'fn_checkTradingAllow');
                return false;
            end if;
        end if;
    exception when others then
        plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    end;
    select to_date(varvalue,'DD/MM/RRRR') into l_busdate from sysvar where varname = 'CURRDATE';
    -- Day co phai tieu khoan margin hay khong?
    select cf.marginallow, aft.policycd, aft.actype, nvl(lnt.chksysctrl,'N')
        into l_cfmarginallow, l_policycd, l_actype, l_chksysctrl
    from cfmast cf, afmast af, aftype aft, lntype lnt
    where cf.custid = af.custid and af.actype = aft.actype and aft.lntype = lnt.actype(+)
    and af.acctno = p_afacctno;

    select count(1) into l_count from afmast af where af.acctno = p_afacctno
    and (exists (select 1 from aftype aft1, lntype lnt1 where aft1.lntype = lnt1.actype and lnt1.chksysctrl = 'Y' and to_char(aft1.actype) = af.actype)
        or
        exists (select 1 from afidtype afi, lntype lnt2 where afi.objname = 'LN.LNTYPE' and afi.aftype = af.actype and afi.actype = lnt2.actype and lnt2.chksysctrl = 'Y')
        );
    if l_count > 0 then
        l_isMarginAccount:= 'Y';
    else
        l_isMarginAccount:= 'N';
    end if;

    -- He thong co chan khong.
    if cspks_system.fn_get_sysvar('MARGIN', 'MARGINALLOW') = 'N' AND l_isMarginAccount = 'Y'  then
        p_err_code:= '-700062';
        plog.setendsection(pkgctx, 'fn_checkTradingAllow');
        return false;
    end if;

    if l_isMarginAccount = 'Y' and trim(l_cfmarginallow) = 'N' and l_chksysctrl = 'Y' then
        p_err_code:= '-700063';
        plog.setendsection(pkgctx, 'fn_checkTradingAllow');
        return false;
    end if;

    -- Kiem tra tren tang loai hinh. Khai bao chan giao dich.
    if l_policycd = 'L' then
        --Tuan theo AFSERULE. Neu cho phep moi thuc hien. Ko thi thoi.
        select count(1) into l_count
        from afserule
        where ((typormst = 'M' and refid = p_afacctno) or (typormst = 'T' and refid = l_actype)) and codeid = p_codeid
        and l_busdate between effdate and expdate
        and (bors = p_bors or bors = 'A');

        if not l_count > 0 then
            p_err_code:= '-700069';
            plog.setendsection(pkgctx, 'fn_checkTradingAllow');
            return false;
        end if;
    elsif l_policycd = 'E' then
        --Neu ko nam trong AFSERULE--> Binh thuong. Nguoc lai--> theo AFSERULE.
        select count(1) into l_count
        from afserule where ((typormst = 'M' and refid = p_afacctno) or (typormst = 'T' and refid = l_actype)) and codeid = p_codeid
        and l_busdate between effdate and expdate
        and (bors = p_bors or bors = 'A');

        if l_count > 0 then
            p_err_code:= '-700069';
            plog.setendsection(pkgctx, 'fn_checkTradingAllow');
            return false;
        end if;
    end if;

    plog.setendsection(pkgctx, 'fn_checkTradingAllow');
    return true;
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_checkTradingAllow');
      RAISE errnums.E_SYSTEM_ERROR;
      return false;
  END fn_checkTradingAllow;

Procedure pr_MortgageSellAllocate(p_Orderid varchar2,p_afacctno varchar2, p_codeid varchar2, p_dfacctno varchar2, p_orderqtty number)
  IS
    l_alqtty number;
    l_i number;
    l_dealwaningovd number;
    v_isvsd varchar2(1);
  BEGIN
    plog.setendsection(pkgctx, 'pr_MortgageSellAllocate');
    plog.info(pkgctx, 'p_dfacctno' || p_dfacctno);
    plog.info(pkgctx, 'p_Orderid' || p_Orderid);
    plog.info(pkgctx, 'p_afacctno + p_codeid' || p_afacctno || p_codeid);
    plog.info(pkgctx, 'p_orderqtty' || p_orderqtty);
    l_dealwaningovd:=10;
    begin
    l_dealwaningovd:=to_number(cspks_system.fn_get_sysvar('SYSTEM','DEALWARNINGOVD'));
    exception when others then
        l_dealwaningovd:=10;
    end;
    if p_dfacctno is null or length(nvl(p_dfacctno,'X'))<=1 then
         --Lenh cam co tong
         l_alqtty:=p_orderqtty;
         l_i:=1;
         for rec in
         (
             select ACCTNO,DFTRADING,nvl(dfg.rtt,1000) rtt,nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) overduedate, ISVSD
                 from (
                        select DFT.ISVSD,df.afacctno, df.codeid,df.groupid,acctno,dfqtty + DF.dfstanding - nvl(v.secureamt,0) dftrading
                                from DFTYPE DFT,dfmast df,
                                (
                                    SELECT dfacctno,SUM(SECUREAMT) SECUREAMT
                                 FROM (SELECT map.refid dfacctno,
                                           to_number(nvl(sy.varvalue,0)) * map.qtty  SECUREAMT,
                                           map.execqtty SECUREMAT
                                        FROM ODMAPEXT MAP, SYSVAR SY
                                       WHERE MAP.deltd <> 'Y' and map.TYPE='D'
                                           and sy.grname='SYSTEM' and sy.varname='HOSTATUS'

                                           ) GROUP BY dfacctno
                                ) v
                            where DFT.ACTYPE = DF.ACTYPE AND df.acctno = v.dfacctno (+)
                      ) df,
                    sysvar sys,
                     (SELECT DFG.GROUPID,DFG.IRATE, DFG.MRATE, DFG.LRATE,
                          dff.tadf/(ln.PRINNML + ln.PRINOVD + round(ln.INTNMLACR,0) + round(ln.INTOVDACR,0) +round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                            ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+
                            round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0)
                            +  round(ln.FEEINTNMLACR,0) + round(ln.FEEINTOVDACR,0) +round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)) * 100
                            RTT,
                          ln.prinovd+ln.intnmlovd+ln.feeintnmlovd OVDAMT,
                          nvl(chd.overduedate,to_date('01/01/3000','DD/MM/YYYY')) overduedate, ln.lncldr
                     FROM DFGROUP DFG, LNMAST LN,
                          (select groupid,sum((dfqtty+bqtty+ carcvqtty+ rcvqtty) * inf.dfrefprice * df.dfrate / 100 + cacashqtty * df.dfrate / 100) tadf
                                from dfmast df, securities_info inf
                                where df.codeid = inf.codeid
                                group by df.groupid
                          ) dff,
                          (select acctno, max(overduedate) overduedate from lnschd where reftype ='P' group by acctno) chd,
                          (SELECT LNACCTNO,SUM(DFRATE* (DFQTTY+BLOCKQTTY+CARCVQTTY)* SB.BASICPRICE/100) COLAMT
                             FROM DFMAST DF,SECURITIES_INFO SB
                             WHERE DF.CODEID=SB.CODEID GROUP BY LNACCTNO
                          ) DF
                     WHERE DFG.LNACCTNO=LN.ACCTNO AND DF.LNACCTNO=LN.ACCTNO and dfg.groupid= dff.groupid and ln.acctno = chd.acctno(+)
                            and ln.PRINNML + ln.PRINOVD + round(ln.INTNMLACR,0) + round(ln.INTOVDACR,0) +round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                              ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+
                              round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0)
                              +  round(ln.FEEINTNMLACR,0) + round(ln.FEEINTOVDACR,0) +round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0) >0) dfg
                 where df.DFTRADING>0  and df.afacctno = p_AFACCTNO and df.codeid =p_CODEID
                 and df.groupid= dfg.groupid (+)
                 and sys.grname ='SYSTEM' and sys.varname='CURRDATE'
                 order by (case when nvl(dfg.rtt,1000)<DFG.LRATE then nvl(dfg.rtt,1000) else 10000000000 end), --Order by theo cac deal vi pham ty le xu ly, Rtt nho truoc
                          (case when nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) <=to_date(sys.varvalue,'DD/MM/RRRR') then nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) else to_date(sys.varvalue,'DD/MM/RRRR') end), --Cac deal bi qua han
                          --(case when nvl(dfg.rtt,1000)<=DFG.MRATE then nvl(dfg.rtt,1000) else 10000000000 end), --Order by theo cac bi call -- BSC ko lay thu tu nay
                          (case when nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY'))  > to_date(sys.varvalue,'DD/MM/RRRR')
                                        and getduedate(to_date(sys.varvalue,'DD/MM/RRRR'), dfg.lncldr, '000', 5) >= nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY'))
                                then nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) else nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) + 1 end), --Cac deal bi den han trong vong 5 ngay
                          --(case when nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) < to_date(sys.varvalue,'DD/MM/RRRR') + l_dealwaningovd then nvl(dfg.overduedate,to_date('01/01/3000','DD/MM/YYYY')) else to_date(sys.varvalue,'DD/MM/RRRR') + l_dealwaningovd end), -- BSC ko theo thu tu nay
                          nvl(dfg.rtt,1000)
         )
         loop
             plog.info(pkgctx, 'Lenh ban cam co tong' || p_orderqtty);

             if l_alqtty>rec.DFTRADING then
                 INSERT INTO ODMAPEXT (ORDERID,REFID,QTTY,ORDERNUM,TYPE,ISVSD)
                 VALUES (p_Orderid,rec.ACCTNO,rec.DFTRADING,l_i,'D',rec.ISVSD);
                 l_alqtty:=l_alqtty-rec.DFTRADING;
                 plog.info(pkgctx, 'dfactno+qtty:' || rec.ACCTNO || '+' || rec.DFTRADING);
             else
                 INSERT INTO ODMAPEXT (ORDERID,REFID,QTTY,ORDERNUM,TYPE,ISVSD)
                 VALUES (p_Orderid,rec.ACCTNO,l_alqtty,l_i,'D',rec.ISVSD);
                 l_alqtty:=0;
                 plog.info(pkgctx, 'dfactno+qtty:' || rec.ACCTNO || '+' || l_alqtty);
             end if;
             l_i:=l_i+1;
             exit when l_alqtty<=0;
         end loop;

     else
        -- HaiLT them de phan biet phan bo lenh cam co VSD hay thuong
        select isvsd into v_isvsd from dfmast df, dftype dft where df.actype = dft.actype and df.acctno = p_dfacctno;
         --Lenh cam co theo deal chi ro
         INSERT INTO ODMAPEXT (ORDERID,REFID,QTTY,ORDERNUM,TYPE,ISVSD)
         VALUES (p_Orderid,p_dfacctno,p_orderqtty,1,'D',nvl(v_isvsd,'N'));
     end if;
    plog.setendsection(pkgctx, 'pr_MortgageSellAllocate');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_MortgageSellAllocate');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_MortgageSellAllocate;


Procedure pr_MortgageSellRelease(p_Orderid varchar2,p_afacctno varchar2, p_codeid varchar2, p_dfacctno varchar2, p_orderqtty number,p_qtty number)
  IS
  l_allqtty number;
  BEGIN
    plog.setendsection(pkgctx, 'pr_MortgageSellRelease');
    if p_qtty>0 then
        l_allqtty:=p_qtty;
        for rec in (select * from odmapext where orderid = p_Orderid and deltd <> 'Y' and qtty-execqtty>0 order by ORDERNUM desc)
        loop
            if rec.qtty-rec.execqtty>l_allqtty THEN
                update odmapext set qtty= qtty - l_allqtty where orderid = rec.orderid and refid = rec.refid and deltd <> 'Y';
                l_allqtty:=0;
            else
                update odmapext set qtty=execqtty where orderid = rec.orderid and refid = rec.refid and deltd <> 'Y';
                l_allqtty:=l_allqtty-(rec.qtty-rec.execqtty);
                if rec.execqtty=0 then
                    --Neu trong odmapext qtty=execqtty= 0 thi remove
                    delete from odmapext where orderid = rec.orderid and refid = rec.refid;
                end if;
            end if;
            exit when l_allqtty<=0;
        end loop;
    else
        delete from odmapext where orderid =p_Orderid;
        cspks_odproc.pr_MortgageSellAllocate(p_Orderid,p_afacctno,p_codeid,p_dfacctno,p_orderqtty);
    end if;
    plog.setendsection(pkgctx, 'pr_MortgageSellRelease');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_MortgageSellRelease');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_MortgageSellRelease;

  Procedure pr_CancelGroupOrder(p_Orderid varchar2)
  IS
  BEGIN
    plog.setendsection(pkgctx, 'pr_CancelGroupOrder');
    for rec in (SELECT * FROM ODMAPEXT WHERE ORDERID=p_orderid AND DELTD<>'Y')
    LOOP
        if rec.type='S'  then
            UPDATE SEMAST SET TRADE=TRADE+rec.QTTY, GRPORDAMT=GRPORDAMT-rec.qtty where  acctno= rec.refid;
        END IF;
        if rec.type='D' THEN
            UPDATE DFMAST SET DFQTTY=DFQTTY+rec.QTTY, GRPORDAMT=GRPORDAMT-rec.qtty where  acctno= rec.refid;
            UPDATE SEMAST SET MORTAGE = MORTAGE + rec.QTTY WHERE ACCTNO IN (SELECT AFACCTNO||CODEID FROM DFMAST WHERE ACCTNO=rec.refid);
        end if;

        UPDATE ODMAPEXT SET DELTD='Y' WHERE ORDERID=p_orderid AND ORDERNUM=rec.ordernum;

    END LOOP;
    plog.setendsection(pkgctx, 'pr_CancelGroupOrder');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CancelGroupOrder');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CancelGroupOrder;

  Procedure pr_MortgageSellMatch(p_Orderid varchar2, p_qtty number, p_amount number, p_afacctno varchar2, p_CodeID varchar2)
  IS
  p_ALLqtty number;
  l_rlsamt number;
  l_actype varchar2(20);
  l_BrID varchar2(20);
  l_totalrlsamt number;
  BEGIN
    plog.setendsection(pkgctx, 'pr_MortgageSellMatch');
    l_totalrlsamt:=0;
    if p_qtty>0 then
        p_ALLqtty:=p_qtty;
        for rec in (select * from odmapext where orderid = p_Orderid and deltd <> 'Y' and qtty-execqtty>0 order by ORDERNUM)
        loop
            if rec.qtty-rec.execqtty>p_ALLqtty THEN
                update odmapext set execqtty= execqtty + p_ALLqtty where orderid = rec.orderid and refid = rec.refid and deltd <> 'Y';

                -- << Update Room
                update securities_info
                set syroomused = nvl(syroomused,0) - p_ALLqtty
                where codeid = p_CodeID;
                -- >> Update Room
                -- << Update Pool
                /*select p_ALLqtty*dfprice into l_rlsamt from dfmast where acctno = rec.refid;*/
                begin
                    select greatest(round(((p_ALLqtty*sec.dfrlsprice*df.dfrate/100)/ dfg.dfamt) * dfg.lnamt,0),nvl(lnovdamt,0))
                        into l_rlsamt
                    from dfmast df,
                    (select df.groupid, sum((df.dfqtty+df.blockqtty+df.rcvqtty+df.carcvqtty)*se.dfrlsprice*df.dfrate/100) dfamt,
                    max(ln.prinnml+prinovd) lnamt, max(ln.prinovd+nvl(ls.nml,0)) lnovdamt
                    from dfmast df, securities_info se, lnmast ln,
                    (select ls.acctno, sum(nml) nml
                        from lnschd ls
                        where ls.reftype = 'P' and ls.overduedate = (select to_date(varvalue,'DD//MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by ls.acctno)
                        ls
                    where df.codeid = se.codeid and df.lnacctno = ln.acctno
                    and ln.acctno = ls.acctno(+)
                    group by df.groupid) dfg,
                    securities_info sec
                    where df.groupid = dfg.groupid
                    and df.codeid = sec.codeid
                    and df.acctno = rec.refid;
                exception when others then
                    l_rlsamt:=0;
                end;

                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_afacctno;

                FOR rec_pr IN (
                    SELECT DISTINCT pm.prcode
                    FROM prmaster pm, /* prtype prt,*/ prtypemap prtm, /*typeidmap tpm,*/ bridmap brm
                    WHERE pm.prcode = brm.prcode
                        AND pm.prcode = prtm.prcode
                      --  AND prt.actype = prtm.prtype
                       -- AND prt.actype = tpm.prtype
                        AND pm.prtyp = 'P'
                      --  AND prt.TYPE = 'AFTYPE'
                        AND pm.prstatus = 'A'
                        AND PRTM.PRTYPE = decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                        AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                           )
                LOOP
                    insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                    values(rec_pr.prcode, -l_rlsamt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, null,null );
                end loop;
                l_totalrlsamt:= l_totalrlsamt + l_rlsamt;
                -- >> Update Pool
                p_ALLqtty:=0;
            else
                update odmapext set execqtty =qtty where orderid = rec.orderid and refid = rec.refid and deltd <> 'Y';

                -- << Update Room
                update securities_info
                set syroomused = nvl(syroomused,0) - (rec.qtty-rec.execqtty)
                where codeid = p_CodeID;
                -- >> Update Room
                -- << Update Pool
                /*select (rec.qtty-rec.execqtty)*dfprice into l_rlsamt from dfmast where acctno = rec.refid;*/
                begin
                    select greatest(round((((rec.qtty-rec.execqtty)*sec.dfrlsprice*df.dfrate/100)/ dfg.dfamt) * dfg.lnamt,0),nvl(lnovdamt,0))
                        into l_rlsamt
                    from dfmast df,
                    (select df.groupid, sum((df.dfqtty+df.blockqtty+df.rcvqtty+df.carcvqtty)*se.dfrlsprice*df.dfrate/100) dfamt,
                    max(ln.prinnml+prinovd) lnamt, max(ln.prinovd+nvl(ls.nml,0)) lnovdamt
                    from dfmast df, securities_info se, lnmast ln,
                    (select ls.acctno, sum(nml) nml
                        from lnschd ls
                        where ls.reftype = 'P' and ls.overduedate = (select to_date(varvalue,'DD//MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by ls.acctno)
                        ls
                    where df.codeid = se.codeid and df.lnacctno = ln.acctno
                    and ln.acctno = ls.acctno(+)
                    group by df.groupid) dfg,
                    securities_info sec
                    where df.groupid = dfg.groupid
                    and df.codeid = sec.codeid
                    and df.acctno = rec.refid;
                exception when others then
                    l_rlsamt:=0;
                end;
                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_afacctno;

                FOR rec_pr IN (
                    SELECT DISTINCT pm.prcode
                    FROM prmaster pm,  /*prtype prt,*/ prtypemap prtm/*, typeidmap tpm*/, bridmap brm
                    WHERE pm.prcode = brm.prcode
                        AND pm.prcode = prtm.prcode
                       -- AND prt.actype = prtm.prtype
                        --AND prt.actype = tpm.prtype
                        AND pm.prtyp = 'P'
                       -- AND prt.TYPE = 'AFTYPE'
                        AND pm.prstatus = 'A'
                        AND PRTM.PRTYPE = decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                        AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                           )
                LOOP
                    insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                    values(rec_pr.prcode, -l_rlsamt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, null,null );
                end loop;
                l_totalrlsamt:= l_totalrlsamt + l_rlsamt;
                -- >> Update Pool
                p_ALLqtty:=p_ALLqtty-(rec.qtty-rec.execqtty);
            end if;
            exit when p_ALLqtty<=0;
        end loop;

        -- Log df release amount.
        insert into afprinusedlog (afacctno, preexecamt)
        values (p_afacctno, least(p_amount,l_totalrlsamt));
    else
        p_ALLqtty:=-p_qtty;
        for rec in (select * from odmapext where orderid = p_Orderid and deltd <> 'Y' and execqtty>0 order by ORDERNUM desc)
        loop
            if rec.execqtty>p_ALLqtty THEN
                update odmapext set execqtty= execqtty - p_ALLqtty where orderid = rec.orderid and refid = rec.refid and deltd <> 'Y';

                -- << Update Room
                update securities_info
                set syroomused = nvl(syroomused,0) + p_ALLqtty
                where codeid = p_CodeID;
                -- >> Update Room
                -- << Update Pool
                /*select p_ALLqtty*dfprice into l_rlsamt from dfmast where acctno = rec.refid;*/
                begin
                    select greatest(round(((p_ALLqtty*sec.dfrlsprice*df.dfrate/100)/ dfg.dfamt) * dfg.lnamt,0),nvl(lnovdamt,0))
                        into l_rlsamt
                    from dfmast df,
                    (select df.groupid, sum((df.dfqtty+df.blockqtty+df.rcvqtty+df.carcvqtty)*se.dfrlsprice*df.dfrate/100) dfamt,
                    max(ln.prinnml+prinovd) lnamt, max(ln.prinovd+nvl(ls.nml,0)) lnovdamt
                    from dfmast df, securities_info se, lnmast ln,
                    (select ls.acctno, sum(nml) nml
                        from lnschd ls
                        where ls.reftype = 'P' and ls.overduedate = (select to_date(varvalue,'DD//MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by ls.acctno)
                        ls
                    where df.codeid = se.codeid and df.lnacctno = ln.acctno
                    and ln.acctno = ls.acctno(+)
                    group by df.groupid) dfg,
                    securities_info sec
                    where df.groupid = dfg.groupid
                    and df.codeid = sec.codeid
                    and df.acctno = rec.refid;
                exception when others then
                    l_rlsamt:=0;
                end;
                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_afacctno;

                FOR rec_pr IN (
                    SELECT DISTINCT pm.prcode
                    FROM prmaster pm,  /*prtype prt,*/ prtypemap prtm, /*typeidmap tpm,*/ bridmap brm
                    WHERE pm.prcode = brm.prcode
                        AND pm.prcode = prtm.prcode
                       -- AND prt.actype = prtm.prtype
                        --AND prt.actype = tpm.prtype
                        AND pm.prtyp = 'P'
                       -- AND prt.TYPE = 'AFTYPE'
                        AND pm.prstatus = 'A'
                        AND PRTM.PRTYPE = decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                        AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                           )
                LOOP
                    insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                    values(rec_pr.prcode, l_rlsamt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, null,null );
                end loop;
                -- >> Update Pool
                p_ALLqtty:=0;
            else
                update odmapext set  execqtty =0 where orderid = rec.orderid and refid = rec.refid and deltd <> 'Y';

                -- << Update Room
                update securities_info
                set syroomused = nvl(syroomused,0) + rec.execqtty
                where codeid = p_CodeID;
                -- >> Update Room
                -- << Update Pool
                /*select rec.execqtty*dfprice into l_rlsamt from dfmast where acctno = rec.refid;*/
                begin
                    select greatest(round(((rec.execqtty*sec.dfrlsprice*df.dfrate/100)/ dfg.dfamt) * dfg.lnamt,0),nvl(lnovdamt,0))
                        into l_rlsamt
                    from dfmast df,
                    (select df.groupid, sum((df.dfqtty+df.blockqtty+df.rcvqtty+df.carcvqtty)*se.dfrlsprice*df.dfrate/100) dfamt,
                    max(ln.prinnml+prinovd) lnamt, max(ln.prinovd+nvl(ls.nml,0)) lnovdamt
                    from dfmast df, securities_info se, lnmast ln,
                    (select ls.acctno, sum(nml) nml
                        from lnschd ls
                        where ls.reftype = 'P' and ls.overduedate = (select to_date(varvalue,'DD//MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by ls.acctno)
                        ls
                    where df.codeid = se.codeid and df.lnacctno = ln.acctno
                    and ln.acctno = ls.acctno(+)
                    group by df.groupid) dfg,
                    securities_info sec
                    where df.groupid = dfg.groupid
                    and df.codeid = sec.codeid
                    and df.acctno = rec.refid;
                exception when others then
                    l_rlsamt:=0;
                end;
                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_afacctno;

                FOR rec_pr IN (
                    SELECT DISTINCT pm.prcode
                    FROM prmaster pm, /* prtype prt,*/ prtypemap prtm, /*typeidmap tpm,*/ bridmap brm
                    WHERE pm.prcode = brm.prcode
                        AND pm.prcode = prtm.prcode
                       -- AND prt.actype = prtm.prtype
                     --   AND prt.actype = tpm.prtype
                        AND pm.prtyp = 'P'
                      --  AND prt.TYPE = 'AFTYPE'
                        AND pm.prstatus = 'A'
                        AND PRTM.PRTYPE= decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                        AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                           )
                LOOP
                    insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                    values(rec_pr.prcode, l_rlsamt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, null,null );
                end loop;
                -- >> Update Pool
                p_ALLqtty:=p_ALLqtty-rec.execqtty;
            end if;
            exit when p_ALLqtty<=0;
        end loop;

        -- << Delete Order
        for rec in (select * from odmapext where orderid = p_Orderid and deltd = 'Y' and execqtty>0 order by ORDERNUM desc)
        loop

            -- << Update Room
            update securities_info
            set syroomused = nvl(syroomused,0) + rec.execqtty
            where codeid = p_CodeID;
            -- >> Update Room
            -- << Update Pool
            /*select rec.execqtty*dfprice into l_rlsamt from dfmast where acctno = rec.refid;*/
            begin
                select greatest(round(((rec.execqtty*sec.dfrlsprice*df.dfrate/100)/ dfg.dfamt) * dfg.lnamt,0),nvl(lnovdamt,0))
                    into l_rlsamt
                from dfmast df,
                    (select df.groupid, sum((df.dfqtty+df.blockqtty+df.rcvqtty+df.carcvqtty)*se.dfrlsprice*df.dfrate/100) dfamt,
                    max(ln.prinnml+prinovd) lnamt, max(ln.prinovd+nvl(ls.nml,0)) lnovdamt
                    from dfmast df, securities_info se, lnmast ln,
                    (select ls.acctno, sum(nml) nml
                        from lnschd ls
                        where ls.reftype = 'P' and ls.overduedate = (select to_date(varvalue,'DD//MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by ls.acctno)
                        ls
                    where df.codeid = se.codeid and df.lnacctno = ln.acctno
                    and ln.acctno = ls.acctno(+)
                    group by df.groupid) dfg,
                    securities_info sec
                where df.groupid = dfg.groupid
                and df.codeid = sec.codeid
                and df.acctno = rec.refid;
            exception when others then
                l_rlsamt:=0;
            end;

            select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_afacctno;

            FOR rec_pr IN (
                SELECT DISTINCT pm.prcode
                FROM prmaster pm,  /*prtype prt,*/ prtypemap prtm, /*typeidmap tpm,*/ bridmap brm
                WHERE pm.prcode = brm.prcode
                    AND pm.prcode = prtm.prcode
                  --  AND prt.actype = prtm.prtype
                  --  AND prt.actype = tpm.prtype
                    AND pm.prtyp = 'P'
                   -- AND prt.TYPE = 'AFTYPE'
                    AND pm.prstatus = 'A'
                    AND PRTM.PRTYPE= decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                    AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                       )
            LOOP
                insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                values(rec_pr.prcode, l_rlsamt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, null,null );
            end loop;
            -- >> Update Pool
        end loop;
        -- >> Delete Order
    end if;
    plog.setendsection(pkgctx, 'pr_MortgageSellMatch');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_MortgageSellMatch');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_MortgageSellMatch;

PROCEDURE pr_RM_UnholdCancelOD( pv_strORDERID varchar2,pv_dblCancelQtty number,pv_strErrorCode in out varchar2)
IS
   l_txmsg tx.msg_rectype;
   v_dblCount NUMBER(20,0);
   v_strAFAcctNo VARCHAR2(10);
   v_strCOREBANK VARCHAR2(10);
   v_strBANKCODE  VARCHAR2(10);
   v_dblBratio  NUMBER(20,4);
   v_dblQuotePrice NUMBER(20,4);
   v_dblRemainHold NUMBER(20,0);
   v_dblUnholdBalance NUMBER(20,0);
   v_tltxcd VARCHAR2(4);
   v_strDesc VARCHAR2(250);
   v_strEN_Desc VARCHAR2(250);
   v_strNotes VARCHAR2(250);
   v_strCURRDATE VARCHAR2(10);
   l_err_param VARCHAR2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_RM_UnholdCancelOD');
    plog.error (pkgctx, 'pv_strORDERID' || pv_strORDERID);
    plog.error (pkgctx, 'pv_dblCancelQtty' || pv_dblCancelQtty);
    plog.error (pkgctx, 'pv_strErrorCode' || pv_strErrorCode);
    v_dblUnholdBalance:=0;
    --Check thong tin lenh co phai lenh mua hay ko
    BEGIN
        SELECT NVL(COUNT(OD.ORDERID),0) INTO v_dblCount FROM ODMAST OD
        WHERE OD.ORDERID=pv_strORDERID AND OD.EXECTYPE='NB';

        IF v_dblCount=0 THEN
            BEGIN
                pv_strErrorCode:='0';
                RETURN;
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_dblUnholdBalance:=0;
    END;
    --Lay thong tin lenh, gia, ti le ky quy va check luon tk do co phai corebank hay ko
    SELECT OD.AFACCTNO,CI.COREBANK,AF.BANKNAME BANKCODE,OD.BRATIO,OD.QUOTEPRICE,GREATEST(CI.HOLDBALANCE - CI.depofeeamt,0),
    DECODE(OD.EXECTYPE,'NB','CB','NS','CS','MS','CS') || '.' || SI.SYMBOL || ': '
    || TO_CHAR(pv_dblCancelQtty) || '@' || DECODE(OD.PRICETYPE,'LO',
    TO_CHAR(OD.QUOTEPRICE), OD.PRICETYPE) NOTES
    INTO v_strAFAcctNo,v_strCOREBANK,v_strBANKCODE,v_dblBratio,v_dblQuotePrice,v_dblRemainHold,v_strNotes
    FROM ODMAST OD,CIMAST CI,AFMAST AF,CFMAST CF,SECURITIES_INFO SI
    WHERE OD.AFACCTNO=CI.AFACCTNO AND OD.CODEID=SI.CODEID
    AND OD.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
    AND OD.ORDERID=pv_strORDERID AND OD.EXECTYPE IN ('NB');
    --Neu tk la corebank thi tinh gia tri can huy
    plog.debug(pkgctx, 'Afacctno: ' || v_strAFAcctNo || ' - Corebank: ' || v_strCOREBANK || ' - Cancel Order ID: ' || pv_strORDERID || ' - Cancel Qtty: ' || pv_dblCancelQtty);
    IF v_strCOREBANK='Y' THEN
        v_dblUnholdBalance := LEAST(pv_dblCancelQtty*v_dblQuotePrice*v_dblBratio/100,v_dblRemainHold);
        plog.error (pkgctx, 'v_dblUnholdBalance' || v_dblUnholdBalance);
        --Generate lenh unhold doi voi tk corebank
        IF v_dblUnholdBalance>0 THEN
            v_tltxcd:='6600';
            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;

            SELECT varvalue
            INTO v_strCURRDATE
            FROM sysvar
            WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

            SELECT systemnums.C_BATCH_PREFIXED
            || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;

            l_txmsg.brid := substr(v_strAFAcctNo,1,4);

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
            l_txmsg.batchname   := 'BANK';
            l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.tltxcd:=v_tltxcd;
            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;

            FOR rec IN
            (
                SELECT CF.CUSTODYCD,CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,AF.CAREBY,
                AF.BANKACCTNO,AF.BANKNAME BANKNAME,0 BANKAVAIL,
                CI.HOLDBALANCE BANKHOLDED,getavlpp(AF.ACCTNO) AVLRELEASE,CI.HOLDBALANCE HOLDAMT
                FROM AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB
                WHERE AF.CUSTID=CF.CUSTID AND CI.AFACCTNO=AF.ACCTNO
                AND AF.BANKNAME=CRB.BANKCODE AND AF.ACCTNO=v_strAFAcctNo
            )
            LOOP
                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

                l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := v_strAFAcctNo;

                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                l_txmsg.txfields ('90').TYPE      := 'C';
                l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                l_txmsg.txfields ('91').TYPE      := 'C';
                l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

                l_txmsg.txfields ('92').defname   := 'LICENSE';
                l_txmsg.txfields ('92').TYPE      := 'C';
                l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

                l_txmsg.txfields ('97').defname   := 'CAREBY';
                l_txmsg.txfields ('97').TYPE      := 'C';
                l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

                l_txmsg.txfields ('93').defname   := 'BANKACCT';
                l_txmsg.txfields ('93').TYPE      := 'C';
                l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

                l_txmsg.txfields ('95').defname   := 'BANKNAME';
                l_txmsg.txfields ('95').TYPE      := 'C';
                l_txmsg.txfields ('95').VALUE     := rec.BANKNAME;

                l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec.BANKAVAIL;

                l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
                l_txmsg.txfields ('12').TYPE      := 'N';
                l_txmsg.txfields ('12').VALUE     := rec.BANKHOLDED;

                l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
                l_txmsg.txfields ('13').TYPE      := 'N';
                l_txmsg.txfields ('13').VALUE     := rec.AVLRELEASE;

                l_txmsg.txfields ('96').defname   := 'HOLDAMT';
                l_txmsg.txfields ('96').TYPE      := 'N';
                l_txmsg.txfields ('96').VALUE     := rec.HOLDAMT;

                l_txmsg.txfields ('10').defname   := 'AMOUNT';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := least(v_dblUnholdBalance,rec.AVLRELEASE);

                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := v_strNotes;
            END LOOP;

            plog.debug(pkgctx,'Begin call 6600');
            BEGIN
                IF txpks_#6600.fn_AutoTxProcess (l_txmsg,
                                                 pv_strErrorCode,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   BEGIN
                       plog.error(pkgctx,'Error when call 6600 , Error code : ' || pv_strErrorCode);
                       ROLLBACK;
                       plog.setendsection (pkgctx, 'pr_RM_UnholdCancelOD');
                       RETURN;
                   END;
                END IF;
            END;

            plog.debug(pkgctx,'End call 6600 , Error code : ' || pv_strErrorCode);

            /*--Tao yeu cau UNHOLD gui sang Bank. REFCODE=ORDERID
            INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, TRFCODE, REFCODE, OBJKEY, TXDATE,
                BANKCODE, BANKACCT, AFACCTNO, TXAMT, STATUS, REFTXNUM, REFTXDATE, REFVAL, NOTES)
            SELECT SEQ_CRBTXREQ.NEXTVAL, 'V', 'ODMAST', 'UNHOLD', pv_strORDERID, pv_strORDERID,
                TO_DATE(v_strCURRDATE,systemnums.c_date_format),v_strBANKCODE, l_txmsg.txfields ('93').VALUE,
                v_strAFAcctNo, v_dblUnholdBalance, 'P', null, null, null, v_strNotes
            FROM DUAL;*/
        END IF;
    END IF;
    pv_strErrorCode:=0;
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RM_UnholdCancelOD');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_RM_UnholdCancelOD;

  Procedure pr_SEMarginInfoUpdate(p_Afacctno varchar2, p_Codeid varchar2, p_Qtty number)
  IS
    l_count number;
  BEGIN
    plog.setendsection(pkgctx, 'pr_SEMarginInfoUpdate');

    update semargininfo
    set syodqtty = syodqtty + p_Qtty
    where codeid = p_Codeid;

    select count(1) into l_count
    from afmast af, aftype aft, mrtype mrt, lntype lnt
    where af.acctno = p_Afacctno
        and af.actype = aft.actype
        and aft.mrtype = mrt.actype
        and mrt.mrtype = 'T'
        and aft.lntype = lnt.actype(+)
        and (   nvl(lnt.chksysctrl,'N') = 'Y'
            or exists (select 1 from afidtype afi, lntype lnt1 where afi.objname = 'LN.LNTYPE' and afi.aftype = af.actype and afi.actype = lnt1.actype and lnt1.chksysctrl='Y'));
    if l_count > 0 then
        update semargininfo
        set odqtty = odqtty + p_Codeid
        where codeid = p_Codeid;
    end if;

    plog.setendsection(pkgctx, 'pr_SEMarginInfoUpdate');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_SEMarginInfoUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_SEMarginInfoUpdate;
---------------------------------fn_OD_ClearOrder------------------------------------------------
FUNCTION fn_OD_ClearOrder(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_blnREVERSAL boolean;
l_lngErrCode    number(20,0);
v_strTIMETYPE   VARCHAR2(10);
v_dblRemainQtty NUMBER(20,4);
v_dblEXECQTTY NUMBER(20,4);
v_dblEXECAMT  NUMBER(20,4);
v_dblCANCELQTTY NUMBER(20,4);
v_dblADJUSTQTTY NUMBER(20,4);
v_dblQuotePrice NUMBER(20,4);
v_dblUnholdAmt NUMBER(20,4);
l_count NUMBER(20);
v_strORGORDERID VARCHAR2(20);
v_strCIACCTNO VARCHAR2(20);
v_strCoreBank VARCHAR(1);
v_dblHOLDBALANCE NUMBER(20,4);
v_dblAVLCANCELQTTY NUMBER(20,4);
V_FOACCTNO VARCHAR2(50);
V_DBLDIFFQTTY NUMBER(20,4);
V_STRAFACCTNO VARCHAR2(20);
v_strSEACCTNO VARCHAR2(20);
v_strDeltd    VARCHAR2(1);
v_dblIsMortage NUMBER(20);
v_dblAVLCANCELAMT NUMBER(20,4);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_OD_ClearOrder');
    plog.debug (pkgctx, '<<BEGIN OF fn_OD_ClearOrder');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_blnREVERSAL:= case when p_txmsg.deltd ='Y' then true else false end;
    p_err_code:=0;
    v_strORGORDERID:=p_txmsg.txfields ('03').VALUE;
    v_strCIACCTNO:=p_txmsg.txfields ('05').VALUE;
    v_dblAVLCANCELQTTY:=TO_NUMBER(p_txmsg.txfields ('10').VALUE);
    V_STRAFACCTNO:=p_txmsg.txfields ('07').VALUE;

    if(p_txmsg.tltxcd='8807' OR p_txmsg.tltxcd='8810') THEN
       v_dblIsMortage:=to_number(p_txmsg.txfields ('60').VALUE);
    END IF;

    v_strSEACCTNO:=to_number(p_txmsg.txfields ('06').VALUE);
    v_dblAVLCANCELAMT:=to_number(p_txmsg.txfields ('11').VALUE);
    SELECT COUNT(*) INTO l_count FROM ODMAST WHERE ORDERID =v_strORGORDERID;
    v_dblQuotePrice:=0;
    if(l_count <=0 ) THEN
      p_err_code:='-700037';
      plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
      RETURN errnums.C_BIZ_RULE_INVALID;
    ELSE
      SELECT   TIMETYPE,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
      INTO    v_strTIMETYPE,v_dblRemainQtty,v_dblEXECQTTY,v_dblEXECAMT,v_dblCANCELQTTY,v_dblADJUSTQTTY
      FROM ODMAST
      WHERE ORDERID =v_strORGORDERID;
    END IF;

    if not v_blnREVERSAL THEN
    --CHieu  thuan giao dich
      if(p_txmsg.tltxcd='8808' OR p_txmsg.tltxcd='8811') THEN
         SELECT upper(COREBANK),HOLDBALANCE
         INTO v_strCoreBank,v_dblHOLDBALANCE
         FROM CIMAST WHERE ACCTNO=v_strCIACCTNO ;
         if(v_strCoreBank='Y') THEN
          --Chi giai toa phan gia tri chua khop, phan phi thi phai cho tinh va giai toa sau
              v_dblUnholdAmt:= v_dblAVLCANCELQTTY * v_dblQuotePrice;
              IF(v_dblHOLDBALANCE<v_dblUnholdAmt) THEN
                   p_err_code:='-670064';
                   plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                   RETURN errnums.C_BIZ_RULE_INVALID;
              /*ELSE-- thuc hien jai  toa

                 cspks_odproc.pr_RM_UnholdCancelOD( v_strORGORDERID ,v_dblAVLCANCELQTTY ,p_err_code) ;
                 if p_err_code <> '0' then
                    plog.error (pkgctx, 'Loi khi thuc hien Unhold 6600 p_err_code=' || p_err_code);
                    plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                 end if;*/
              END IF;
           END IF;
       END IF;



      --Kiem tra so luong yeu cau huy co phu hop khong
      SELECT COUNT(*) INTO l_count
      FROM ODMAST
      WHERE ORDERID=v_strORGORDERID AND ORDERQTTY-ADJUSTQTTY-CANCELQTTY-EXECQTTY>=v_dblAVLCANCELQTTY;
      if(l_count <=0 ) THEN
          p_err_code:='-700018';
          plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
          RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;

      --Ghi nhan vao so lenh day di, trang thai OOD la E, Error khong cho phep day di
      SELECT COUNT(*) INTO L_COUNT
      FROM OOD WHERE ORGORDERID=v_strORGORDERID AND OODSTATUS <>'E';
      IF(L_COUNT>0) THEN
          --Cap nhat trang thai cua OOD
            UPDATE OOD SET OODSTATUS='E' WHERE ORGORDERID=v_strORGORDERID AND OODSTATUS <>'E';
          --CAP NHAT TRANG THAI CUA ODQUEUE
            UPDATE ODQUEUE SET DELTD='Y' WHERE ORGORDERID=v_strORGORDERID;
      END IF;
      If v_strTIMETYPE = 'G' Then
                    --Cap nhat tro lai voi lenh GTC
            SELECT COUNT(*) INTO L_COUNT FROM FOMAST
            WHERE ORGACCTNO= v_strORGORDERID  AND DELTD<>'Y' AND TIMETYPE='G';

            If L_COUNT > 0 THEN
                SELECT ACCTNO INTO V_FOACCTNO
                FROM FOMAST WHERE ORGACCTNO= v_strORGORDERID
                AND DELTD<>'Y' AND TIMETYPE='G';

                UPDATE FOMAST
                SET STATUS='P',REMAINQTTY=v_dblRemainQtty ,
                EXECQTTY= v_dblEXECQTTY,EXECAMT= v_dblEXECAMT,
                CANCELQTTY=v_dblCANCELQTTY,AMENDQTTY= v_dblADJUSTQTTY
                WHERE ACCTNO=V_FOACCTNO;

            End IF;
     End If ;
    else
       -- xoa giao dich
       IF(p_txmsg.tltxcd='8808') THEN
            --TungNT added, neu la lenh mua corebank thi ko cho phep xoa
            If p_txmsg.tltxcd='8808' Or p_txmsg.tltxcd='8811' Then
               SELECT upper(COREBANK),HOLDBALANCE
               INTO v_strCoreBank,v_dblHOLDBALANCE
               FROM CIMAST WHERE ACCTNO=v_strCIACCTNO ;

                If v_strCoreBank = 'Y' Then
                    p_err_code:='-100017';
                    plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                End IF;

            End IF;
           --TungNT End
           --xoa phai kiem tra balance
             SELECT  COUNT(*)
             INTO L_COUNT
             FROM CIMAST WHERE ACCTNO =  V_STRAFACCTNO
             AND BALANCE >= v_dblAVLCANCELAMT;
            If L_COUNT <= 0 Then
                --So luong huy khong hop le
                p_err_code:='-700044';
                plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                RETURN errnums.C_BIZ_RULE_INVALID;
            End IF;
       ELSIF(p_txmsg.tltxcd='8807') THEN
        --xoa phai kiem tra TRADE , MORTAGE
          SELECT COUNT(*)
          INTO L_COUNT
          FROM SEMAST
          WHERE ACCTNO =  v_strSEACCTNO
          AND (
              (v_dblIsMortage = 0 AND TRADE >= v_dblAVLCANCELQTTY)
              OR (v_dblIsMortage <> 0 AND MORTAGE >= v_dblAVLCANCELQTTY )
              ) ;
          If L_COUNT <= 0 Then
                --So luong huy khong hop le
                p_err_code:='-700045';
                plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                RETURN errnums.C_BIZ_RULE_INVALID;
           End IF;

         --Tra lai trang thai cho lenh outgoing
           SELECT COUNT(*) INTO L_COUNT FROM OOD WHERE ORGORDERID= v_strORGORDERID  AND OODSTATUS='E';

                If L_COUNT > 0 Then
                   --Lenh da duoc giai toa hoac chua duoc day di thi khong can cap nhat lai trang thai OOD

                    --Cap nhat trang thai cua OOD
                    SELECT COUNT(*) INTO L_COUNT
                    FROM ODQUEUE WHERE ORGORDERID= v_strORGORDERID ;

                    If L_COUNT<= 0 Then
                        --NEU LENH GIAI TOA LA CHUA SEND THI VAO ODSEND
                        UPDATE OOD SET OODSTATUS='N'
                        WHERE ORGORDERID= v_strORGORDERID  AND OODSTATUS='E';

                    Else
                        --LENH SAU KHI GIAI TOA MA DA SEND THI KHONG DUOC XOA
                        SELECT deltd INTO v_strDeltd
                        FROM ODQUEUE WHERE ORGORDERID= v_strORGORDERID ;
                        If v_strDeltd <> 'Y' Then
                           --'LENH DA SEND, KHONG DUOC XOA
                            p_err_code:='-700027';
                            plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                            RETURN errnums.C_BIZ_RULE_INVALID;

                        Else
                            --NEU LENH DA DAY ROI THI DUA VAO ODMATCH
                            UPDATE OOD SET OODSTATUS='S'
                            WHERE ORGORDERID= v_strORGORDERID  AND OODSTATUS='E';

                            UPDATE ODQUEUE SET DELTD='N' WHERE ORGORDERID= v_strORGORDERID ;

                        End IF;

                    End IF;

                End If ;
                If v_strTIMETYPE = 'G' Then
                   --Cap nhat tro lai voi lenh GTC
                    SELECT COUNT(*) INTO l_count
                    FROM FOMAST WHERE ORGACCTNO= v_strORGORDERID
                    AND DELTD<>'Y' AND TIMETYPE='G' AND STATUS='P';

                    If l_count > 0 THEN
                        SELECT acctno INTO V_FOACCTNO
                        FROM FOMAST WHERE ORGACCTNO= v_strORGORDERID
                        AND DELTD<>'Y' AND TIMETYPE='G' AND STATUS='P';

                        UPDATE FOMAST SET STATUS='A',
                        REMAINQTTY=v_dblRemainQtty ,EXECQTTY= v_dblEXECQTTY ,
                        EXECAMT=v_dblEXECAMT ,CANCELQTTY= v_dblCANCELQTTY ,
                        AMENDQTTY= v_dblADJUSTQTTY
                        WHERE ACCTNO= V_FOACCTNO;

                    Else
                        --Lenh yeu cau GTC da bi send di roi
                         p_err_code:='-700004';
                         plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
                         RETURN errnums.C_BIZ_RULE_INVALID;
                    End IF;
                End IF;
            END IF;

       END IF;

    plog.debug (pkgctx, '<<END OF fn_OD_ClearOrder');
    plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_OD_ClearOrder');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_OD_ClearOrder;

 Procedure pr_ConfirmOrder(p_Orderid varchar2,
                           p_userId VARCHAR2,
                           p_custid VARCHAR2,
                           p_Ipadrress VARCHAR2,
                           pv_strErrorCode in out varchar2,
                           p_via VARCHAR2,
                           p_validationtype in varchar2 default '',
                           p_devicetype     IN varchar2 default '',
                           p_device         IN varchar2 default '')
  IS
  l_reforderid VARCHAR2(20);
  l_count      NUMBER;
  l_confirmed  char(1);
  l_suborderid VARCHAR2(20);
  v_refcursor  pkg_report.ref_cursor;
  l_input      varchar2(2500);
  BEGIN
    plog.setendsection(pkgctx, 'fn_ConfirmOrder');
    pv_strErrorCode:='0';
    -- check xem lenh da dc xac nhan chua
    SELECT COUNT(*) INTO l_count FROM confirmodrsts
    WHERE orderid=p_Orderid;
    IF l_count=1 THEN
        SELECT nvl(confirmed,'N' ) INTO l_confirmed
        FROM confirmodrsts
        WHERE orderid=p_Orderid;

        IF l_confirmed = 'Y' THEN
            pv_strErrorCode:= '-700085';
            plog.setendsection(pkgctx, 'fn_checkTradingAllow');
            RETURN;
        END IF;
    END IF;

    -- insert dong xac nhan cho lenh
    insert into confirmodrsts (ORDERID, CONFIRMED, USERID, custid, CFMTIME, IPADRRESS)
    values (p_Orderid, 'Y', p_userId, p_custid,systimestamp, p_Ipadrress );

    -- VCBSDEPII-1870: 1.1.4.10
    --DungTD
    OPEN v_refcursor for
        SELECT p_Orderid Orderid, p_userId userId, p_custid custid, p_Ipadrress ipAddress, p_via via,
               p_validationtype validationtype,p_devicetype devicetype, p_device device
        FROM DUAL;
    l_input := FN_GETINPUT(v_refcursor);
    --END
    pr_insertiplog( p_Orderid,  systimestamp, p_Ipadrress, p_via, p_validationtype, p_devicetype, p_device, 'CONFIRMORDER', l_input); --1.0.6.1
    -- End VCBSDEPII-1870: 1.1.4.10

    SELECT nvl(reforderid,'a') INTO l_reforderid FROM
    (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist)
    where orderid=p_Orderid;
    -- xac nhan cho lenh con
    SELECT COUNT(*) INTO l_count
    FROM
       (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist) OD
    WHERE reforderid=l_reforderid AND orderid <> p_Orderid;
    IF (l_count = 1) THEN
        SELECT orderid INTO l_suborderid
          FROM
         (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist) OD
        WHERE reforderid=l_reforderid AND orderid <> p_Orderid;
        -- check xem lenh con da duoc confirm chua
        SELECT COUNT(*)
        INTO l_count
        FROM confirmodrsts
        WHERE confirmed='Y' AND orderid= l_suborderid;
        -- insert dong xac nhan cho lenh con
        IF ( l_count = 0)  THEN
            insert into confirmodrsts (ORDERID, CONFIRMED, USERID, custid, CFMTIME, IPADRRESS)
            values (l_suborderid, 'Y', p_userId, p_custid,systimestamp, p_Ipadrress );
        END IF;
    END IF;
    plog.setendsection(pkgctx, 'fn_ConfirmOrder');

  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_ConfirmOrder');
      pv_strErrorCode:='1';
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ConfirmOrder;

 FUNCTION fn_OD_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2
AS
    v_Found     BOOLEAN;
    v_TempOrderid   varchar2(20);
    v_TempRootOrderID varchar2(20);

BEGIN
    v_Found := FALSE;
    v_TempOrderid := p_OrderID;

    WHILE v_Found = FALSE
    LOOP
        SELECT NVL(OD.REFORDERID, '0000')
        INTO v_TempRootOrderID
        FROM (SELECT * FROM ODMAST UNION ALL SELECT * FROM odmasthist) OD
         WHERE OD.ORDERID = v_TempOrderid;
        IF v_TempRootOrderID <> '0000' THEN
            v_TempOrderid := v_TempRootOrderID;
            v_Found := FALSE;
        ELSE
            v_Found := TRUE;
        END IF;
    END LOOP;

    RETURN v_TempOrderid;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'fn_GetRootOrderID');
    RETURN '0000';
END;

procedure pr_CancelOrderid(pv_orderid varchar2, p_err_code in out varchar2)
  IS
    v_strcorebank char(1);
    v_stralternateacct char(1);
    l_remainqtty    number;
    l_status varchar2(10);
    l_CONTROLCODE varchar2(10);
    l_exectype varchar2(10);
    l_afacctno varchar2(10);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_CancelOrderid');
         select remainqtty, (case when od.remainqtty < od.orderqtty then '4' when od.remainqtty = od.orderqtty then '5' else od.orstatus end) status,
               af.corebank,af.alternateacct,od.exectype,od.afacctno
               into l_remainqtty, l_status, v_strcorebank,v_stralternateacct,l_exectype,l_afacctno
        from odmast od, afmast af where od.afacctno = af.acctno and od.orderid = pv_orderid;

        UPDATE ODMAST
         SET
           PORSTATUS=PORSTATUS||ORSTATUS,ORSTATUS=l_status,
           REMAINQTTY = REMAINQTTY- l_remainqtty,
           CANCELSTATUS = 'X', --Huy do het phien giao dich
           CANCELQTTY = CANCELQTTY + l_remainqtty, LAST_CHANGE = SYSTIMESTAMP
        WHERE ORDERID=pv_orderid;
        --Voi lenh mua tai khaon ngan hang se thuc hien Unhold luon
        if l_exectype ='NB' then
            if v_strcorebank ='Y' then
                  BEGIN
                    cspks_odproc.pr_RM_UnholdCancelOD(pv_orderid, l_remainqtty, p_err_code);
                  EXCEPTION WHEN OTHERS THEN
                    plog.error(pkgctx,'Error when gen unhold for cancel order : ' || pv_orderid || ' qtty : ' || l_remainqtty);
                    plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace );
                  END;
             elsif v_stralternateacct='Y' then
                   BEGIN
                     cspks_rmproc.pr_RM_UnholdAccount(l_afacctno, p_err_code);
                   EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when gen unhold for modify order : ' || l_afacctno);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
                   END;
             end if;
        end if;

    plog.setendsection(pkgctx, 'pr_CancelOrderid');
    p_err_code :='0';
    return;
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CancelOrderid');
      p_err_code :='-1';
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CancelOrderid;

PROCEDURE pr_update_secinfo
   ( pv_Symbol IN VARCHAR2,
   pv_ceilingprice IN VARCHAR2,
   pv_floorprice in varchar2 ,
   pv_basicprice IN VARCHAR2,
   pv_tradeplace IN varchar2,
   pv_haltflag IN varchar2,
   p_err_code in out varchar2,
   --pv_odd_lot_haltflag in VARCHAR2 DEFAULT 'N',
   pv_security_name IN VARCHAR2 DEFAULT NULL,
   p_securitytype IN varchar2,
   p_SecurituGroupID FILE_INSTRUMENT_SBR.Securitygroupid%TYPE,
   p_Isincode sbsecurities.isincode%TYPE)
IS

-- Purpose: update securities info
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- NAMNT     22/07/2014
-- ---------   ------  -------------------------------------------
l_tradeplace_old varchar2(10);
l_codeid_old varchar2(10);
l_symbol varchar2(50);
l_codeid_new varchar2(10);
l_issuer_new varchar2(10);
l_ticksize_count_1 NUMBER;
l_ticksize_count_2 NUMBER;
l_ticksize_count_3 NUMBER;
l_ticksizeSum_count NUMBER;
l_trdelot_count  NUMBER;
l_status varchar2(10);
v_strWFTcodeid varchar2(10);
 v_AUTOIDSR         NUMBER;

L_SECTYPE       VARCHAR2(10);
l_tradelot number;
l_securitytype  varchar2(10);
l_count     number(10);
l_topiceTPDN  number;
pv_CheckProcess   BOOLEAN;

v_sb_info NUMBER;--1.0.9.0 TPDN
v_parvalue NUMBER;--1.0.10.7
l_security_name  VARCHAR2(2000);
l_ceilling NUMBER; -- VCB.2021.03.0.03
l_floor NUMBER; -- VCB.2021.03.0.03
   -- Declare program variables as shown above
BEGIN

    plog.setbeginsection (pkgctx, 'pr_update_secinfo');
      l_symbol:=pv_Symbol;
      BEGIN
        SELECT tradeplace, codeid
          INTO l_tradeplace_old, l_codeid_old
          FROM sbsecurities
         WHERE symbol = pv_Symbol;
      EXCEPTION
         WHEN OTHERS THEN
         l_tradeplace_old:='';
         l_codeid_old:='';
      END ;
      BEGIN
        SELECT fn_get_tradelot(pv_tradeplace)
          INTO l_tradelot
          FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
         l_tradelot:='100';
      END ;
      SELECT count(*) into l_count FROM sbsecurities WHERE symbol = pv_Symbol;
        --Ngay 12/04/2021 NamTv them toprice cho trai phieu doanh nghiep TPDN
          select TO_NUMBER(varvalue) into l_topiceTPDN
          from sysvar
          where varname = 'TPDNCEIL' and grname='SYSTEM';

        l_status:='N';
        --1 THIEU MA CK
        IF nvl(l_codeid_old,'ZZZ') ='ZZZ' and l_count = 0 THEN
        l_status:='Y';
        plog.error(pkgctx,'Them ma ck : ' || pv_Symbol);
        --tao codeid new
         SELECT lpad((MAX(TO_NUMBER(INVACCT)) + 1), 6, '0')
           INTO l_codeid_new
           FROM (SELECT ROWNUM ODR, INVACCT
                   FROM (SELECT CODEID INVACCT
                           FROM SBSECURITIES
                          WHERE SUBSTR(CODEID, 1, 1) <> 9
                          ORDER BY CODEID) DAT) INVTAB;
        --tao ck codeid wft
        SELECT TO_CHAR(lpad(MAX(TO_NUMBER(INVACCT)) + 2, 6, 0)) AUTOINV
          into v_strWFTcodeid
          FROM (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT CODEID INVACCT
                          FROM SBSECURITIES
                         WHERE SUBSTR(CODEID, 1, 1) <> 9
                         ORDER BY CODEID) DAT) INVTAB;
        --tao issuer new

         SELECT lpad((MAX(TO_NUMBER(ISSUERID)) + 1), 10, '0')
           INTO l_issuer_new
           FROM ISSUERS;
            -- 1.1.4.3:VCBSDEPII-1018 Them Ten CK lay tu msg cua so
        l_security_name := l_symbol||'-AUTO';

        IF pv_security_name IS NOT NULL AND length(pv_security_name) > 0 THEN
          l_security_name := pv_security_name;
        END IF;

        INSERT INTO ISSUERS (ISSUERID,SHORTNAME,FULLNAME,OFFICENAME,CUSTID,ADDRESS,PHONE,FAX,ECONIMIC,BUSINESSTYPE,BANKACCOUNT,BANKNAME,LICENSENO,LICENSEDATE,LINCENSEPLACE,OPERATENO,OPERATEDATE,OPERATEPLACE,LEGALCAPTIAL,SHARECAPITAL,MARKETSIZE,PRPERSON,INFOADDRESS,DESCRIPTION,STATUS,PSTATUS)
        VALUES(l_issuer_new,l_symbol,l_security_name||'-AUTO','',NULL,'','','','002','001','0','0','',TO_DATE('01/01/2000','DD/MM/RRRR'),'7','8',TO_DATE('01/01/2000','DD/MM/RRRR'),'So KHDT',0,0,'001',NULL,NULL,NULL,'A',NULL);

        INSERT INTO securities_risk (CODEID,MRMAXQTTY,MRRATIORATE,MRRATIOLOAN,MRPRICERATE,MRPRICELOAN,ISMARGINALLOW)
        VALUES(l_codeid_new,10000000,0,0,10000000,10000000,'N');


        --Lay SECTYPE theo cong tai lieu moi dua vao SecurityGroupID
        /*    BS: Trái phi?u
        EF: Ch?ng ch? qu?
        EW: Ch?ng quy?n
        MF: Qu? tuong h?
        ST là C? phi?u*/
        BEGIN
          SELECT (CASE WHEN p_SecurituGroupID='ST' THEN '001' -- Co phieu thuong
                       WHEN p_SecurituGroupID='BS' THEN '006' -- Trai phieu
                       WHEN p_SecurituGroupID='EW' THEN '011' -- Chung quyen
                       WHEN p_SecurituGroupID='EF' THEN '008' -- Chung chi quy
                  ELSE '001' END) INTO L_SECTYPE
          FROM DUAL;
        EXCEPTION WHEN OTHERS THEN
          L_SECTYPE:= 001;
        END;


        IF pv_tradeplace ='001' THEN
                --sFPT
                /*BEGIN
                    SELECT MAX(CASE WHEN TRIM(STOCK_TYPE) = '3' THEN '007'
                        WHEN TRIM(STOCK_TYPE) = '2' THEN '006'
                        WHEN TRIM(STOCK_TYPE) = '4' THEN '011'
                        WHEN TRIM(STOCK_TYPE) = '12' THEN '012'
                        ELSE '001' END) INTO L_SECTYPE
                    FROM Ho_sec_info WHERE CODE = l_symbol;
                EXCEPTION WHEN OTHERS THEN
                    L_SECTYPE := '001';
                END ;*/

                INSERT INTO sbsecurities (CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSQTTY,BONDTYPE,MARKETTYPE,ALLOWSESSION,ISSEDEPOFEE) --LoLeHSX
                VALUES(l_codeid_new,l_issuer_new,l_symbol ,L_SECTYPE,'002','001',10000,49,'Y','001','001',0,0,0,getcurrdate(),getcurrdate(),0,0,pv_haltflag,'001','0017',0,NULL,0,'000','000','AL','Y');  --LoLeHSX

                IF L_SECTYPE ='011' THEN
                    UPDATE SBSECURITIES SET
                           CWTERM              = 6,
                           settlementprice     = 1,
                           settlementtype      = 'CWMS',
                           underlyingtype      = 'S',
                           nvalue              = 1
                    WHERE SYMBOL = l_symbol;
                END IF;


                INSERT INTO securities_info (AUTOID,CODEID,SYMBOL,TXDATE,LISTINGQTTY,TRADEUNIT,LISTINGSTATUS,ADJUSTQTTY,LISTTINGDATE,REFERENCESTATUS,ADJUSTRATE,REFERENCERATE,REFERENCEDATE,STATUS,BASICPRICE,OPENPRICE,PREVCLOSEPRICE,CURRPRICE,CLOSEPRICE,AVGPRICE,CEILINGPRICE,FLOORPRICE,MTMPRICE,MTMPRICECD,INTERNALBIDPRICE,INTERNALASKPRICE,PE,EPS,DIVYEILD,DAYRANGE,YEARRANGE,TRADELOT,TRADEBUYSELL,TELELIMITMIN,TELELIMITMAX,ONLINELIMITMIN,ONLINELIMITMAX,REPOLIMITMIN,REPOLIMITMAX,ADVANCEDLIMITMIN,ADVANCEDLIMITMAX,MARGINLIMITMIN,MARGINLIMITMAX,SECURERATIOTMIN,SECURERATIOMAX,DEPOFEEUNIT,DEPOFEELOT,MORTAGERATIOMIN,MORTAGERATIOMAX,SECUREDRATIOMIN,SECUREDRATIOMAX,CURRENT_ROOM,BMINAMT,SMINAMT,MARGINPRICE,MARGINREFPRICE,ROOMLIMIT,ROOMLIMITMAX,DFREFPRICE,SYROOMLIMIT,SYROOMUSED,MARGINCALLPRICE,MARGINREFCALLPRICE,DFRLSPRICE,ROOMLIMITMAX_SET,SYROOMLIMIT_SET)
                VALUES(seq_securities_info.nextval,l_codeid_new,l_symbol,getcurrdate(),0,1000,'N',1,getcurrdate(),'001',1,1,getcurrdate(),'001',pv_basicprice,0,0,0,0,0,pv_ceilingprice,pv_floorprice,1,'002',0,0,1,1,1,1,1,l_tradelot,'Y',1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,102,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

                /*INSERT INTO SECURITIES_TICKSIZE (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_new ,l_symbol,100,0,49900,'Y');
                INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_new,l_symbol,500,50000,99500,'Y');
                INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_new,l_symbol,1000,100000,100000000000,'Y');*/
          ELSE
                --sFPT
                /*begin
                    select securitytype into l_securitytype from hasecurity_req where symbol = l_symbol;
                EXCEPTION WHEN OTHERS THEN
                    l_securitytype := 'ZZZZ';
                end;*/
                --Ngay 01/02/2019 NamTv chinh sua insert dung sectype trai phieu

                l_floor := TO_NUMBER(pv_floorprice);
                l_ceilling := TO_NUMBER(pv_ceilingprice);
              IF (p_securitytype = 'HCX' AND p_SecurituGroupID ='BS') THEN -- neu la trai phieu doanh nghiep
                -- VCB.2021.03.0.03
                IF (l_floor = 0) THEN
                  BEGIN
                    SELECT to_number(a.varvalue) INTO l_floor FROM SYSVAR A WHERE A.GRNAME='SYSTEM' AND a.varname='TPDNFLOOR';
                  EXCEPTION WHEN OTHERS THEN
                    l_floor := 1;
                  END;
                END IF;
                IF (l_ceilling = 0) THEN
                  BEGIN
                    SELECT to_number(a.varvalue) INTO l_ceilling FROM SYSVAR A WHERE A.GRNAME='SYSTEM' AND a.varname='TPDNCEIL';
                  EXCEPTION WHEN OTHERS THEN
                    l_ceilling := 2000000000;
                  END;
                END IF;
                -- end VCB.2021.03.0.03
                l_sectype:= '012';
                v_parvalue := 100000;
              ELSE
                l_sectype:= '001';
                v_parvalue := 10000;
              END IF;


               if l_securitytype = 'EF' then
                   INSERT INTO sbsecurities (CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSQTTY,BONDTYPE,MARKETTYPE,ALLOWSESSION,ISSEDEPOFEE)
                   VALUES(l_codeid_new,l_issuer_new,l_symbol,'008','002','001',10000,49,'Y',pv_tradeplace,'001',0,0,0,NULL,NULL,0,0,pv_haltflag,'001','0023',0,NULL,0,'000','000','AL','Y');
               elsif l_securitytype = 'CORP' then --TPDN
                    INSERT INTO sbsecurities (CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSQTTY,BONDTYPE,MARKETTYPE,ALLOWSESSION,ISSEDEPOFEE)
                   VALUES(l_codeid_new,l_issuer_new,l_symbol,'012','002','001',10000,49,'Y',pv_tradeplace,'001',0,0,0,NULL,NULL,0,0,pv_haltflag,'001','0023',0,NULL,0,'005','000','AL','Y');
               ELSE
                   INSERT INTO sbsecurities (CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSQTTY,BONDTYPE,MARKETTYPE,ALLOWSESSION,ISSEDEPOFEE)
                   VALUES(l_codeid_new,l_issuer_new,l_symbol,'001','002','001',10000,49,'Y',pv_tradeplace,'001',0,0,0,NULL,NULL,0,0,pv_haltflag,'001','0023',0,NULL,0,'000','000','AL','Y');
               END IF;

               if l_securitytype = 'CORP' then
                   l_tradelot:=1;
                   INSERT INTO securities_info (AUTOID,CODEID,SYMBOL,TXDATE,LISTINGQTTY,TRADEUNIT,LISTINGSTATUS,ADJUSTQTTY,LISTTINGDATE,REFERENCESTATUS,ADJUSTRATE,REFERENCERATE,REFERENCEDATE,STATUS,BASICPRICE,OPENPRICE,PREVCLOSEPRICE,CURRPRICE,CLOSEPRICE,AVGPRICE,CEILINGPRICE,FLOORPRICE,MTMPRICE,MTMPRICECD,INTERNALBIDPRICE,INTERNALASKPRICE,PE,EPS,DIVYEILD,DAYRANGE,YEARRANGE,TRADELOT,TRADEBUYSELL,TELELIMITMIN,TELELIMITMAX,ONLINELIMITMIN,ONLINELIMITMAX,REPOLIMITMIN,REPOLIMITMAX,ADVANCEDLIMITMIN,ADVANCEDLIMITMAX,MARGINLIMITMIN,MARGINLIMITMAX,SECURERATIOTMIN,SECURERATIOMAX,DEPOFEEUNIT,DEPOFEELOT,MORTAGERATIOMIN,MORTAGERATIOMAX,SECUREDRATIOMIN,SECUREDRATIOMAX,CURRENT_ROOM,BMINAMT,SMINAMT,MARGINPRICE,MARGINREFPRICE,ROOMLIMIT,ROOMLIMITMAX,DFREFPRICE,SYROOMLIMIT,SYROOMUSED,MARGINCALLPRICE,MARGINREFCALLPRICE,DFRLSPRICE,ROOMLIMITMAX_SET,SYROOMLIMIT_SET)
                   VALUES(seq_securities_info.NEXTVAL,l_codeid_new,l_symbol,getcurrdate(),0,1000,'N',1,getcurrdate(),'001',1,1,getcurrdate(),'001',pv_basicprice,0,0,0,0,0,pv_ceilingprice,pv_floorprice,1,'002',0,0,1,1,1,1,1,l_tradelot,'Y',1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,102,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
               else
                   INSERT INTO securities_info (AUTOID,CODEID,SYMBOL,TXDATE,LISTINGQTTY,TRADEUNIT,LISTINGSTATUS,ADJUSTQTTY,LISTTINGDATE,REFERENCESTATUS,ADJUSTRATE,REFERENCERATE,REFERENCEDATE,STATUS,BASICPRICE,OPENPRICE,PREVCLOSEPRICE,CURRPRICE,CLOSEPRICE,AVGPRICE,CEILINGPRICE,FLOORPRICE,MTMPRICE,MTMPRICECD,INTERNALBIDPRICE,INTERNALASKPRICE,PE,EPS,DIVYEILD,DAYRANGE,YEARRANGE,TRADELOT,TRADEBUYSELL,TELELIMITMIN,TELELIMITMAX,ONLINELIMITMIN,ONLINELIMITMAX,REPOLIMITMIN,REPOLIMITMAX,ADVANCEDLIMITMIN,ADVANCEDLIMITMAX,MARGINLIMITMIN,MARGINLIMITMAX,SECURERATIOTMIN,SECURERATIOMAX,DEPOFEEUNIT,DEPOFEELOT,MORTAGERATIOMIN,MORTAGERATIOMAX,SECUREDRATIOMIN,SECUREDRATIOMAX,CURRENT_ROOM,BMINAMT,SMINAMT,MARGINPRICE,MARGINREFPRICE,ROOMLIMIT,ROOMLIMITMAX,DFREFPRICE,SYROOMLIMIT,SYROOMUSED,MARGINCALLPRICE,MARGINREFCALLPRICE,DFRLSPRICE,ROOMLIMITMAX_SET,SYROOMLIMIT_SET)
                   VALUES(seq_securities_info.NEXTVAL,l_codeid_new,l_symbol,getcurrdate(),0,1000,'N',1,getcurrdate(),'001',1,1,getcurrdate(),'001',pv_basicprice,0,0,0,0,0,pv_ceilingprice,pv_floorprice,1,'002',0,0,1,1,1,1,1,100,'Y',1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,102,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
               end if;


                if l_securitytype = 'EF' then
                    INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_new,l_symbol,1,0,1000000000,'Y');
                elsif l_securitytype = 'CORP' then --TPDN
                    INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_new,l_symbol,1,0,l_topiceTPDN,'Y');
                else
                    INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_new,l_symbol,100,0,10000000,'Y');
                end if;
           END IF;

        IF pv_tradeplace ='001' THEN
            BEGIN
                SELECT NVL(MAX(CASE WHEN TRIM(STOCK_TYPE) = '3' THEN '008'
                        WHEN TRIM(STOCK_TYPE) = '2' THEN '006'
                        WHEN TRIM(STOCK_TYPE) = '4' THEN '011'
                        WHEN TRIM(STOCK_TYPE) = '12' THEN '012'
                    ELSE '001' END),'001') INTO L_SECTYPE
                FROM Ho_sec_info WHERE CODE = l_symbol;
            EXCEPTION WHEN OTHERS THEN
                L_SECTYPE := '001';
            END ;
            if L_SECTYPE <> '011' then
               --CK cho giao dich
              INSERT INTO SBSECURITIES(CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSEDEPOFEE)
              vALUES( TO_CHAR( v_strWFTcodeid) ,  l_issuer_new, l_symbol||'_WFT' , '001', '', '', 10000, 49, 'Y','006' ,'002' , 0, 0, 0, getcurrdate(), getcurrdate(), 0, 0, 'N', '001','0017', 0,  l_codeid_new,'Y' );


              INSERT INTO SECURITIES_INFO (
                                AUTOID, CODEID, SYMBOL, TXDATE, LISTINGQTTY, TRADEUNIT, LISTINGSTATUS, ADJUSTQTTY, LISTTINGDATE, REFERENCESTATUS,
                                ADJUSTRATE, REFERENCERATE, REFERENCEDATE, STATUS, BASICPRICE, OPENPRICE, PREVCLOSEPRICE, CURRPRICE, CLOSEPRICE,
                                AVGPRICE, CEILINGPRICE, FLOORPRICE, MTMPRICE, MTMPRICECD, INTERNALBIDPRICE, INTERNALASKPRICE, PE, EPS, DIVYEILD,
                                DAYRANGE, YEARRANGE, TRADELOT, TRADEBUYSELL, TELELIMITMIN, TELELIMITMAX, ONLINELIMITMIN, ONLINELIMITMAX,
                                REPOLIMITMIN, REPOLIMITMAX, ADVANCEDLIMITMIN, ADVANCEDLIMITMAX, MARGINLIMITMIN, MARGINLIMITMAX, SECURERATIOTMIN,
                                SECURERATIOMAX, DEPOFEEUNIT, DEPOFEELOT, MORTAGERATIOMIN, MORTAGERATIOMAX, SECUREDRATIOMIN, SECUREDRATIOMAX,
                                CURRENT_ROOM, BMINAMT, SMINAMT, MARGINPRICE)
                         VALUES (
                                SEQ_SECURITIES_INFO.NEXTVAL, v_strWFTcodeid, l_symbol||'_WFT',getcurrdate(),
                                1, 1000, 'N', 1, getcurrdate(), '001', 1, 1,
                                getcurrdate(), '001', 0, 0, 0, 0, 0, 0, 1, 1, 0, '001',
                                0, 0, 1, 1, 1, 1, 1, 10, 'Y', 0, 1000000000, 0,
                                1000000000, 0, 1000000000, 0, 1000000000, 0, 1000000000, 0, 0, 1, 1, 0, 1000000000, 1, 1, 0, 0, 0, 0);
            end if;
        else
              INSERT INTO SBSECURITIES(CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSEDEPOFEE)
              vALUES( TO_CHAR( v_strWFTcodeid) ,  l_issuer_new, l_symbol||'_WFT' , '001', '', '', 10000, 49, 'Y','006' ,'002' , 0, 0, 0, getcurrdate(), getcurrdate(), 0, 0, 'N', '001','0017', 0,  l_codeid_new,'Y' );


              INSERT INTO SECURITIES_INFO (
                                AUTOID, CODEID, SYMBOL, TXDATE, LISTINGQTTY, TRADEUNIT, LISTINGSTATUS, ADJUSTQTTY, LISTTINGDATE, REFERENCESTATUS,
                                ADJUSTRATE, REFERENCERATE, REFERENCEDATE, STATUS, BASICPRICE, OPENPRICE, PREVCLOSEPRICE, CURRPRICE, CLOSEPRICE,
                                AVGPRICE, CEILINGPRICE, FLOORPRICE, MTMPRICE, MTMPRICECD, INTERNALBIDPRICE, INTERNALASKPRICE, PE, EPS, DIVYEILD,
                                DAYRANGE, YEARRANGE, TRADELOT, TRADEBUYSELL, TELELIMITMIN, TELELIMITMAX, ONLINELIMITMIN, ONLINELIMITMAX,
                                REPOLIMITMIN, REPOLIMITMAX, ADVANCEDLIMITMIN, ADVANCEDLIMITMAX, MARGINLIMITMIN, MARGINLIMITMAX, SECURERATIOTMIN,
                                SECURERATIOMAX, DEPOFEEUNIT, DEPOFEELOT, MORTAGERATIOMIN, MORTAGERATIOMAX, SECUREDRATIOMIN, SECUREDRATIOMAX,
                                CURRENT_ROOM, BMINAMT, SMINAMT, MARGINPRICE)
                         VALUES (
                                SEQ_SECURITIES_INFO.NEXTVAL, v_strWFTcodeid, l_symbol||'_WFT',getcurrdate(),
                                1, 1000, 'N', 1, getcurrdate(), '001', 1, 1,
                                getcurrdate(), '001', 0, 0, 0, 0, 0, 0, 1, 1, 0, '001',
                                0, 0, 1, 1, 1, 1, 1, l_tradelot, 'Y', 0, 1000000000, 0,
                                1000000000, 0, 1000000000, 0, 1000000000, 0, 1000000000, 0, 0, 1, 1, 0, 1000000000, 1, 1, 0, 0, 0, 0);
        end if;

        SELECT MAX(AUTOID) + 1
          INTO v_AUTOIDSR
          FROM SECURITIES_RATE;
        insert into SECURITIES_RATE (AUTOID, CODEID, SYMBOL, FROMPRICE, TOPRICE, MRRATIORATE, MRRATIOLOAN, STATUS)
               values (v_AUTOIDSR, l_codeid_new, l_symbol, 1, 1000000, 99, 99, 'Y');
         END IF;
                --tao SECURITIES_RATE  new

        IF l_status='N' THEN
        --2 KHAC SAN THI DOI SAN
        IF nvl(l_tradeplace_old,pv_tradeplace) <> pv_tradeplace THEN
            l_status:='Y';
            plog.error(pkgctx,'Doi san ma ck : ' || pv_Symbol);
            --update ma san, co halt
            UPDATE SBSECURITIES
                SET TRADEPLACE =pv_tradeplace, Halt =pv_haltflag
            WHERE SYMBOL=pv_Symbol;
            --Update buoc gia
            DELETE SECURITIES_TICKSIZE WHERE CODEID = l_codeid_old;
                IF pv_tradeplace ='001' THEN

                    /*INSERT INTO SECURITIES_TICKSIZE (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                    VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_old ,l_symbol,100,0,49900,'Y');
                    INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                    VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_old,l_symbol,500,50000,99500,'Y');
                    INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                    VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_old,l_symbol,1000,100000,100000000000,'Y');*/

                    UPDATE SECURITIES_INFO --Do Su chi goi cap nhat gia voi mod CN (cap nhat AVG)
                    set TRADELOT =l_tradelot,
                      BASICPRICE=  pv_basicprice,
                      CEILINGPRICE=   pv_ceilingprice,
                      FLOORPRICE =    pv_floorprice
                      WHERE SYMBOL=pv_Symbol;

                    INSERT INTO setradeplace (AUTOID,TXDATE,CODEID,CTYPE,FRTRADEPLACE,TOTRADEPLACE)
                    VALUES(seq_setradeplace.NEXTVAL ,getcurrdate(),l_codeid_old,'CA',l_tradeplace_old,pv_tradeplace);
                ELSE
                    --sFTP
                    /*begin
                        select securitytype into l_securitytype from hasecurity_req where symbol = l_symbol;
                    EXCEPTION WHEN OTHERS THEN
                        l_securitytype := 'ZZZZ';
                    end;*/
                    if l_securitytype = 'EF' then
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_old,l_symbol,1,0,1000000000,'Y');
                    elsif l_securitytype = 'CORP' then --TPDN
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_old,l_symbol,1,0,l_topiceTPDN,'Y');
                    ELSE
                        INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                        VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL,l_codeid_old,l_symbol,100,0,10000000,'Y');
                    END IF;
                    --thangpv TPDN
                    --UPDATE SECURITIES_INFO set TRADELOT ='100' WHERE SYMBOL=pv_Symbol;
                    if l_securitytype = 'CORP' then
                       UPDATE SECURITIES_INFO set TRADELOT =1 WHERE SYMBOL=pv_Symbol;
                    else
                        UPDATE SECURITIES_INFO set TRADELOT =100 WHERE SYMBOL=pv_Symbol;
                    end if;
                    --end thangpv TPDN
                    INSERT INTO setradeplace (AUTOID,TXDATE,CODEID,CTYPE,FRTRADEPLACE,TOTRADEPLACE)
                    VALUES(seq_setradeplace.NEXTVAL ,getcurrdate(),l_codeid_old,'CA',l_tradeplace_old,pv_tradeplace);
                END IF;
          END IF ;
        END IF;
        ----------------------------------
        -- LAY RA CAC LENH SAI sau chay batch(tran san, buoc gia, ck bi tam dung) DE GIAI TOA (da v?odmast)
         ----------------------------------

        --Sai  lo (san)
        FOR REC
        IN (
               SELECT od.orderid, sb.tradeplace,od.remainqtty
                 FROM ODMAST od, securities_info seif, sbsecurities sb, ood ood
                WHERE od.CODEID = seif.CODEID
                  AND seif.codeid = sb.codeid
                  and od.orderid=ood.orgorderid
                  and ood.oodstatus='N'--Chua gui So
                  AND od.codeid = l_codeid_old
                  and od.remainqtty > 0
                  and od.ORSTATUS not in ('6','5','7')--lenh da het hieu luc
                  and
                    --ThangPV chinh sua lo le HSX 05-12-2022
                  /*( -- cac lenh sai lo
                           (CASE
                             WHEN sb.tradeplace = '001' or
                                  (sb.tradeplace in ('002', '005') and
                                  od.orderqtty > seif.TRADELOT) THEN
                              Mod(od.orderqtty, seif.TRADELOT)
                             ELSE
                              0
                           END) <> 0
                         )
                       ) */

                   (
                           (CASE WHEN
                                  (sb.tradeplace in ('002', '005','001') and
                                  od.orderqtty > seif.TRADELOT) THEN
                              Mod(od.orderqtty, seif.TRADELOT)
                             ELSE
                              0
                           END) <> 0
                     )
                    )--end ThangPV chinh sua lo le HSX 05-12-2022
         LOOP
          BEGIN
            /*if rec.tradeplace ='001' then
                  pck_hogw.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty );
                 else
                   pck_hagw.confirm_cancel_normal_order(rec.orderid, rec.remainqtty);
                   end if;*/
               --HSX04: tong hop 2 san ve chung 1 ham
                pck_gw_common.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty,pv_CheckProcess );
             --Cap nhat trang thai bi tu choi
             --Cap nhat trang thai bi tu choi
               Update odmast--
                 set REMAINQTTY = 0,
                     ORSTATUS   = '6',
                     FEEDBACKMSG= FEEDBACKMSG ||'Sai lo giao dich'
               Where Orderid = rec.orderid;
               UPDATE OOD --
                 SET OODSTATUS = 'E',--
                     TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS')
               WHERE ORGORDERID =  rec.orderid
                 and OODSTATUS = 'N';
               EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.ORDERID);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
        --Sai buoc gia
        FOR REC
        IN ( SELECT od.orderid, sb.tradeplace,od.remainqtty
                 FROM ODMAST od, securities_info seif, sbsecurities sb, ood ood
                WHERE od.CODEID = seif.CODEID
                  AND seif.codeid = sb.codeid
                  and od.orderid=ood.orgorderid
                  and ood.oodstatus='N'--Chua gui So
                  AND od.codeid = l_codeid_old
                  and od.remainqtty > 0
                  and od.ORSTATUS not in ('6','5','7')--lenh da het hieu luc
                  and(
                      ( -- cac lenh sai lo
                          -- cac lenh sai ticksize
                           ((SELECT count(1)
                               FROM SECURITIES_TICKSIZE
                              WHERE CODEID = sb.codeid
                                AND STATUS = 'Y'
                                AND TOPRICE >= od.QUOTEPRICE
                                AND FROMPRICE <= od.QUOTEPRICE
                                and  mod( od.QUOTEPRICE,ticksize) =0) = 0
                           ))
                         )
                       )
         LOOP
          BEGIN
          /*  if rec.tradeplace ='001' then
                   pck_hogw.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty );
                 else
                   pck_hagw.confirm_cancel_normal_order(rec.orderid, rec.remainqtty);
                   end if;*/
           --HSX04: tong hop 2 san ve chung 1 ham
                pck_gw_common.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty,pv_CheckProcess );
             --Cap nhat trang thai bi tu choi
             --Cap nhat trang thai bi tu choi
               Update odmast--
                 set REMAINQTTY = 0,
                     ORSTATUS   = '6',--
                     FEEDBACKMSG=FEEDBACKMSG|| 'Sai buoc gia'
               Where Orderid = rec.orderid;
               UPDATE OOD --
                 SET OODSTATUS = 'E',--
                     TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS')
               WHERE ORGORDERID =  rec.orderid
                 and OODSTATUS = 'N';
               EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.ORDERID);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
        --Sai gia
        FOR REC
        IN ( SELECT od.orderid, sb.tradeplace,od.remainqtty
                 FROM ODMAST od, securities_info seif, sbsecurities sb, ood ood
                WHERE od.CODEID = seif.CODEID
                  AND seif.codeid = sb.codeid
                  and od.orderid=ood.orgorderid
                  and ood.oodstatus='N'--Chua gui So
                  AND od.codeid = l_codeid_old
                  and od.remainqtty > 0
                  and od.ORSTATUS not in ('6','5','7')--lenh da het hieu luc
                   and( pv_ceilingprice <od.quoteprice  or pv_floorprice > od.quoteprice)--Gia tran san
                       )
         LOOP
          BEGIN
           /* if rec.tradeplace ='001' then
                  pck_hogw.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty );
                 else
                   pck_hagw.confirm_cancel_normal_order(rec.orderid, rec.remainqtty);
                   end if;*/
             --HSX04: tong hop 2 san ve chung 1 ham
                pck_gw_common.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty,pv_CheckProcess );
             --Cap nhat trang thai bi tu choi
             --Cap nhat trang thai bi tu choi
               Update odmast--
                 set REMAINQTTY = 0,
                     ORSTATUS   = '6',--
                     FEEDBACKMSG=FEEDBACKMSG|| 'Gia nam ngoai khoang tran - san'
               Where Orderid = rec.orderid;
               UPDATE OOD --
                 SET OODSTATUS = 'E',--
                     TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS')
               WHERE ORGORDERID =  rec.orderid
                 and OODSTATUS = 'N';
               EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.ORDERID);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
        --TRang thai giao dich sai
        FOR REC
        IN ( SELECT od.orderid, sb.tradeplace,od.remainqtty
                 FROM ODMAST od, securities_info seif, sbsecurities sb, ood ood
                WHERE od.CODEID = seif.CODEID
                  AND seif.codeid = sb.codeid
                  and od.orderid=ood.orgorderid
                  and ood.oodstatus='N'--Chua gui So
                  AND od.codeid = l_codeid_old
                  and od.remainqtty > 0
                  and od.ORSTATUS not in ('6','5','7')--lenh da het hieu luc
                  --LoLeHSX
                  --and sb.halt <>'N'
                  and ( (sb.halt <>'N' And od.orderqtty >= seif.tradelot)
                     --OR (sb.odd_lot_halt <> 'N' And od.orderqtty < seif.tradelot ) --26/12/2022: Rao lai doan nay vi HOSE check halt dua vao bang ho_sec_info
                     )
                  --End LoLeHSX
                       )
         LOOP
          BEGIN
           /* if rec.tradeplace ='001' then
                  pck_hogw.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty );
                 else
                   pck_hagw.confirm_cancel_normal_order(rec.orderid, rec.remainqtty);
                   end if;*/
               --HSX04: tong hop 2 san ve chung 1 ham
                pck_gw_common.CONFIRM_CANCEL_NORMAL_ORDER(rec.orderid,rec.remainqtty,pv_CheckProcess );
             --Cap nhat trang thai bi tu choi
             --Cap nhat trang thai bi tu choi
               Update odmast--
                 set REMAINQTTY = 0,
                     ORSTATUS   = '6',--
                     FEEDBACKMSG= FEEDBACKMSG ||'CK dung giao dich'
               Where Orderid = rec.orderid;
               UPDATE OOD --
                 SET OODSTATUS = 'E',--
                     TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS')
               WHERE ORGORDERID =  rec.orderid
                 and OODSTATUS = 'N';
               EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.ORDERID);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
        -----------------------------------------
        --Lenh ngoai gio  truoc chay batch
        -----------------------------------------
        --Sai Gia

         FOR REC
        IN (
              SELECT bo.autoid
                 FROM borqslog bo, securities_info seif, sbsecurities sb
                WHERE bo.description = sb.symbol
                  AND seif.symbol = sb.symbol
                  AND  bo.description = pv_Symbol
                  and bo.rqstyp='APL'
                  and bo.status='P'
                 and  ( pv_ceilingprice<bo.msgamt  or pv_floorprice > bo.msgamt)--Gia tran san
             )
         LOOP
          BEGIN
               --Cap nhat trang thai bi huy
               Update borqslog--Th?tin chi ti?t l?nh HUY
                 set STATUS   = 'E',
                 errmsg=errmsg||'Gia nam ngoai khoang tran - san'
               Where autoid = rec.autoid
                        and Status ='P';
                  EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.autoid);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
       --Sai Lo
         FOR REC
        IN (
              SELECT bo.autoid
                 FROM borqslog bo, securities_info seif, sbsecurities sb
                WHERE bo.description = sb.symbol
                  AND seif.symbol = sb.symbol
                  AND  bo.description = pv_Symbol
                  and bo.rqstyp='APL'
                  and bo.status='P'
                  and  (CASE
                               WHEN sb.tradeplace = '001' or
                                    (sb.tradeplace in ('002', '005') and
                                    bo.msgqtty > seif.TRADELOT) THEN
                                Mod(bo.msgqtty, seif.TRADELOT)
                               ELSE
                                0
                             END) <> 0
             )
         LOOP
          BEGIN
               --Cap nhat trang thai bi huy
               Update borqslog--Th?tin chi ti?t l?nh HUY
                 set STATUS   = 'E',
                 errmsg=errmsg||'Sai lo giao dich'
               Where autoid = rec.autoid
                        and Status ='P';
                  EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.autoid);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
        --Sai Buoc Gia
         FOR REC
        IN (
              SELECT bo.autoid
                 FROM borqslog bo, securities_info seif, sbsecurities sb
                WHERE bo.description = sb.symbol
                  AND seif.symbol = sb.symbol
                  AND  bo.description = pv_Symbol
                  and bo.rqstyp='APL'
                  and bo.status='P'
                  and   ((SELECT count(1)
                                 FROM SECURITIES_TICKSIZE
                                WHERE CODEID = sb.codeid
                                  AND STATUS = 'Y'
                                  AND TOPRICE >= bo.msgamt
                                  AND FROMPRICE <= bo.msgamt
                                  and  mod(  bo.msgamt,ticksize) =0) = 0
                             )
             )
         LOOP
          BEGIN
               --Cap nhat trang thai bi huy
               Update borqslog--Th?tin chi ti?t l?nh HUY
                 set STATUS   = 'E',
                 errmsg=errmsg||'Sai buoc gia'
               Where autoid = rec.autoid
                        and Status ='P';
                  EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.autoid);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
         --Sai trang thai ck
         FOR REC
        IN (
              SELECT bo.autoid
                 FROM borqslog bo, securities_info seif, sbsecurities sb
                WHERE bo.description = sb.symbol
                  AND seif.symbol = sb.symbol
                  AND  bo.description = pv_Symbol
                  and bo.rqstyp='APL'
                  and bo.status='P'
                  --LoLeHSX
                  --and     sb.halt <>'N'
                  and     ( (sb.halt <>'N' And bo.msgqtty >= seif.tradelot)
                     --OR (sb.odd_lot_halt <> 'N' And bo.msgqtty < seif.tradelot ) --26/12/2022: Rao lai doan nay vi HOSE check halt dua vao bang ho_sec_info
                     )
                  --End LoLeHSX
             )
         LOOP
          BEGIN
               --Cap nhat trang thai bi huy
               Update borqslog--Th?tin chi ti?t l?nh HUY
                 set STATUS   = 'E',
                 errmsg=errmsg||'Chung khoan dung giao dich'
               Where autoid = rec.autoid
                        and Status ='P';
                  EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when cancel order : ' || rec.autoid);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
          END;
        END LOOP;
     p_err_code:='0';
    plog.setendsection (pkgctx, 'pr_update_secinfo');

EXCEPTION
   WHEN OTHERS THEN
         plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_update_secinfo');
      p_err_code :='0';
      RAISE errnums.E_SYSTEM_ERROR;
        return;
END;

 procedure pr_CancelOrderAfterDay(pv_exectype varchar2, p_err_code in out varchar2)
  IS
    v_strcorebank char(1);
    v_stralternateacct char(1);
    l_remainqtty    number;
    l_status varchar2(10);
    l_CONTROLCODE varchar2(10);
    l_exectype varchar2(10);

  BEGIN
    plog.setendsection(pkgctx, 'pr_CancelOrderAfterDay');
    if pv_exectype ='ALL' then
        l_exectype:='%';
    else
        l_exectype:=pv_exectype;
    end if;
    --01 Kiem tra xem da het phien Giao dich chua
    --Chi cho phep thuc hien khi da het phien giao dich
    --khi nao chay that thi check
    if to_char(sysdate, 'hh24:mi')<='15:00' then
        --Bao loi chua het gio giao dich, chua den gio giai toa lenh
        p_err_code :='-2';
        return;
    end if;
    ---end
    --Check phien HO <> 'O,A,P'
    select trim(sysvalue) into l_CONTROLCODE from ordersys where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('P','O','A') then
        --Bao loi dang trong gio giao dich khong duoc phep giai toa
        p_err_code :='-3';
        return;
    end if;
    --Check phien HA <> '1'
    select trim(sysvalue) into l_CONTROLCODE from ordersys_ha where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('1') then
        --Bao loi dang trong gio giao dich khong duoc phep giai toa
        p_err_code :='-4';
        return;
    end if;
    --02 Thuc hien giai toa lenh
    for rec in (
        select od.orderid , od.afacctno, od.exectype
        from odmast od , ood
        where od.orderid = ood.orgorderid
            and od.exectype like l_exectype and od.txdate = getcurrdate
            and od.exectype in ('NB','NS')
            and od.matchtype <>'P' and timetype <> 'G'
            and od.deltd <> 'Y' and od.remainqtty>0
            and ood.oodstatus in ('N','S')
    )
    loop
        select remainqtty, (case when od.remainqtty < od.orderqtty then '4' when od.remainqtty = od.orderqtty then '5' else od.orstatus end) status,
               af.corebank,af.alternateacct
               into l_remainqtty, l_status, v_strcorebank,v_stralternateacct
        from odmast od, afmast af where od.afacctno = af.acctno and od.orderid = rec.orderid;

        UPDATE ODMAST
         SET
           PORSTATUS=PORSTATUS||ORSTATUS,ORSTATUS=l_status,
           REMAINQTTY = REMAINQTTY- l_remainqtty,
           CANCELSTATUS = 'F', --Huy do het phien giao dich
           CANCELQTTY = CANCELQTTY + l_remainqtty, LAST_CHANGE = SYSTIMESTAMP
        WHERE ORDERID=rec.orderid;
        --Voi lenh mua tai khaon ngan hang se thuc hien Unhold luon
        if rec.exectype ='NB' then
            if v_strcorebank ='Y' then
                  BEGIN
                    cspks_odproc.pr_RM_UnholdCancelOD(rec.orderid, l_remainqtty, p_err_code);
                  EXCEPTION WHEN OTHERS THEN
                    plog.error(pkgctx,'Error when gen unhold for cancel order : ' || rec.orderid || ' qtty : ' || l_remainqtty);
                    plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace );
                  END;
             elsif v_stralternateacct='Y' then
                   BEGIN
                     cspks_rmproc.pr_RM_UnholdAccount(rec.afacctno, p_err_code);
                   EXCEPTION WHEN OTHERS THEN
                     plog.error(pkgctx,'Error when gen unhold for modify order : ' || rec.afacctno);
                     plog.error(pkgctx, SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
                   END;
             end if;
        end if;
    end loop;
    plog.setendsection(pkgctx, 'pr_CancelOrderAfterDay');
    p_err_code :='0';
    return;
  EXCEPTION
  WHEN OTHERS
   THEN
       plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_CancelOrderAfterDay');
      p_err_code :='-1';
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CancelOrderAfterDay;



procedure pr_ODProcessFeeCalculate(p_err_code in out varchar2)
  IS
    v_strcorebank char(1);
    v_stralternateacct char(1);
    l_remainqtty    number;
    l_status varchar2(10);
    l_CONTROLCODE varchar2(10);
    l_afacctno varchar2(10);
    l_lastRun varchar2(10);
  BEGIN
    plog.setendsection(pkgctx, 'pr_CancelOrderAfterDay');

    --01 Kiem tra xem da het phien Giao dich chua
    --Chi cho phep thuc hien khi da het phien giao dich
    --- khi nao chay that moi check
    if to_char(sysdate, 'hh24:mi')<='15:00' then
        --Bao loi chua het gio giao dich, chua den gio giai toa lenh
        p_err_code :='-2';
        return;
    end if;
    --end
    --Check phien HO <> 'O,A,P'
    select trim(sysvalue) into l_CONTROLCODE from ordersys where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('P','O','A') then
        --Bao loi dang trong gio giao dich khong duoc phep giai toa
        p_err_code :='-3';
        return;
    end if;
    --Check phien HA <> '1'
    select trim(sysvalue) into l_CONTROLCODE from ordersys_ha where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('1') then
        --Bao loi dang trong gio giao dich khong duoc phep giai toa
        p_err_code :='-4';
        return;
    end if;
    --02 Thuc hien tinh phi lenh
    txpks_batch.pr_ODFeeCalculate('ODFEECAL',p_err_code,0,100000000, l_lastRun);

    plog.setendsection(pkgctx, 'pr_ODProcessFeeCalculate');
    p_err_code :='0';
    return;
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_ODProcessFeeCalculate');
      p_err_code :='-1';
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ODProcessFeeCalculate;

   ---------------------------------pr_ODFeeCalculate------------------------------------------------
  PROCEDURE PR_ODFEECALCULATE_FOR_ACCTNO(P_AFACCTNO   VARCHAR, P_ERR_CODE OUT VARCHAR2 ) IS
    V_DATE     DATE;
    L_MAXROW   NUMBER(20, 0);
    L_ICRATE   NUMBER;
    V_DELTA    NUMBER;
    L_RULETYPE VARCHAR2(10);
    L_ICCFBAL  NUMBER;
    L_AMOUNT   NUMBER;
    L_ORDER    NUMBER;
    L_FEEAMT   NUMBER;
    L_FEE_EX   NUMBER;

    L_OPNDATE     DATE;
    L_CALFEETYPE  CHAR(1);
    L_CALDATETYPE CHAR(1);
    L_MONTHVAL    NUMBER;
    L_AFACCTNO  VARCHAR2(20);
  BEGIN
    PLOG.SETBEGINSECTION(PKGCTX, 'PR_ODFEECALCULATE_FOR_ACCTNO');

    IF P_AFACCTNO ='ALL' OR P_AFACCTNO IS NULL THEN
    L_AFACCTNO :='%';
    ELSE
     L_AFACCTNO:=P_AFACCTNO;
    END IF;



    SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
      INTO V_DATE
      FROM SYSVAR
     WHERE GRNAME = 'SYSTEM'
      AND VARNAME = 'CURRDATE';

    PLOG.DEBUG(PKGCTX, 'Begin loop');
    L_ICRATE := 0;
    V_DELTA  := 0;



    /*    -- Tinh phi theo loai hinh: Cho tinh cho truong hop khai ICCF trong loai hinh va BRKFEETYPE='G': Tinh phi nhom theo loai hinh
        -- Tinh cho loai hinh gan truc tiep voi lenh
        for rec in
        (
            select od.afacctno, od.actype, sum(od.execamt) totalexec, ictd.icrate, ictd.ruletype, count(od.orderid) totalorder
                    from odmast od, odtype typ, iccftypedef ictd
                    where od.deltd <> 'Y' and od.execqtty > 0
                          and od.exectype in ('NB','BC','SS','NS','MS')
                          and od.actype = typ.actype and typ.brkfeetype='G'
                          and od.actype = ictd.actype
                          and ictd.modcode = 'OD'
                          and ictd.eventcode = 'ODTYPEFEE' --su kien Tinh phi theo loai hinh
                          and ictd.iccfstatus = 'A'
                          and od.feeacr = 0
                          and od.txdate = v_DATE
                    group by od.afacctno, od.actype, ictd.icrate, ictd.ruletype
                    order by od.afacctno, od.actype
        )
        loop
            l_iccfbal:=rec.totalexec;
            l_iccfbal:=fn_gettradingamount(rec.afacctno,rec.actype);
            l_icrate:=rec.icrate;
            l_ruletype:=rec.ruletype;
            l_order:=rec.totalorder;
            if l_iccfbal>0 then
                if l_ruletype<>'C' then
                    --Luat tinh theo fixed hoac tier
                    --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
                    begin
                    --Xac dinh tier
                        if l_ruletype ='T' then
                            select delta into v_delta from iccftier
                            where actype =rec.actype and modcode ='OD'
                            and eventcode='ODTYPEFEE' and deltd <> 'Y'
                            and framt < l_iccfbal and toamt >= l_iccfbal;
                        else
                            v_delta:=0;
                        end if;
                        l_icrate:=l_icrate+v_delta;
                    exception when others then
                        l_icrate:=l_icrate;
                    end;
                    l_amount:=l_iccfbal;

                    --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
                    insert into odbrkfee (orderid,txdate, eventcode,refcode, feeamt)
                    select orderid, txdate, 'ODTYPEFEE', rec.actype, round((l_icrate/100)*EXECAMT, 0)
                    from odmast od
                    WHERE od.AFACCTNO = rec.afacctno AND od.ACTYPE = rec.actype
                        and od.deltd <> 'Y' and od.execqtty > 0
                        and od.exectype in ('NB','BC','SS','NS','MS')
                        AND od.TXDATE = v_DATE;
                else
                    --Luat tinh theo cluster
                    --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
                    l_feeamt:=0;
                    for rec_tier in
                    (
                        select delta, framt, toamt
                        from iccftier
                            where actype =rec.actype and modcode ='OD'
                            and eventcode='ODTYPEFEE' and deltd <> 'Y'
                            order by framt
                    )
                    loop
                        exit when l_iccfbal<rec_tier.framt;
                        if l_iccfbal>rec_tier.framt and l_iccfbal<rec_tier.toamt then
                            l_amount:=l_iccfbal-rec_tier.framt;
                        ELSE
                            l_amount:=rec_tier.toamt-rec_tier.framt;
                        end if;
                        l_icrate:=rec.icrate+rec_tier.delta;
                        l_feeamt:=l_feeamt+round(l_amount*(l_icrate/100),0);
                    end loop;
                    --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
                    insert into odbrkfee (orderid,txdate, eventcode,refcode, feeamt)
                    select orderid, txdate, 'ODTYPEFEE', rec.actype, round(((l_feeamt/l_iccfbal)/100)*EXECAMT, 0)
                    from odmast od
                    WHERE od.AFACCTNO = rec.afacctno AND od.ACTYPE = rec.actype
                        and od.deltd <> 'Y' and od.execqtty > 0
                        and od.exectype in ('NB','BC','SS','NS','MS')
                        AND od.TXDATE = v_DATE;
                end if;

            end if;
        end loop;
    */

    -- Tinh phi theo loai hinh: Cho tinh cho truong hop khai ICCF trong loai hinh va BRKFEETYPE='G': Tinh phi nhom theo loai hinh
    -- Tinh cho loai hinh khong gan truc tiep voi lenh
    FOR REC IN (SELECT OD.AFACCTNO,
                       TYP.ACTYPE,
                       SUM(OD.EXECAMT) TOTALEXEC,
                       ICTD.ICRATE,
                       ICTD.RULETYPE,
                       COUNT(OD.ORDERID) TOTALORDER
                  FROM ODMAST       OD,
                       AFMAST       AF,
                       ODTYPE       TYP,
                       AFIDTYPE     ID,
                       ICCFTYPEDEF  ICTD,
                       SBSECURITIES SB
                 WHERE OD.AFACCTNO = AF.ACCTNO
                   AND OD.AFACCTNO LIKE L_AFACCTNO
                   AND OD.DELTD <> 'Y'
                   AND OD.EXECQTTY > 0
                   AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                   AND OD.CODEID = SB.CODEID
                      --and od.actype = typ.actype
                      --and od.actype <> typ.actype
                   AND (TYP.VIA = OD.VIA OR TYP.VIA = 'A') --VIA
                   AND TYP.CLEARCD = OD.CLEARCD --CLEARCD
                   AND (TYP.EXECTYPE = OD.EXECTYPE OR TYP.EXECTYPE = 'AA') --EXECTYPE
                   AND (TYP.TIMETYPE = OD.TIMETYPE OR TYP.TIMETYPE = 'A') --TIMETYPE
                   AND (TYP.PRICETYPE = OD.PRICETYPE OR TYP.PRICETYPE = 'AA') --PRICETYPE
                   AND (TYP.MATCHTYPE = OD.MATCHTYPE OR TYP.MATCHTYPE = 'A') --MATCHTYPE
                   AND (TYP.TRADEPLACE = SB.TRADEPLACE OR
                       TYP.TRADEPLACE = '000')
                   AND (INSTR(CASE
                                WHEN SB.SECTYPE IN ('001', '002') THEN
                                 SB.SECTYPE || ',' || '111,333'
                                WHEN SB.SECTYPE IN ('003', '006') THEN
                                 SB.SECTYPE || ',' || '222,333,444'
                                WHEN SB.SECTYPE IN ('008') THEN
                                 SB.SECTYPE || ',' || '111,444'
                                ELSE
                                 SB.SECTYPE
                              END,
                              TYP.SECTYPE) > 0 OR TYP.SECTYPE = '000')
                   AND (TYP.NORK = OD.NORK OR TYP.NORK = 'A') --NORK
                   AND (CASE
                         WHEN TYP.CODEID IS NULL THEN
                          OD.CODEID
                         ELSE
                          TYP.CODEID
                       END) = OD.CODEID
                   AND TYP.ACTYPE = ID.ACTYPE
                   AND ID.AFTYPE = AF.ACTYPE
                   AND ID.OBJNAME = 'OD.ODTYPE'
                   AND TYP.STATUS = 'Y'
                   AND TO_DATE(TYP.VALDATE, 'DD/MM/RRRR') <= V_DATE
                   AND TO_DATE(TYP.EXPDATE, 'DD/MM/RRRR') >= V_DATE
                      --------
                   AND TYP.BRKFEETYPE = 'G'
                   AND TYP.ACTYPE = ICTD.ACTYPE
                   AND ICTD.MODCODE = 'OD'
                   AND ICTD.EVENTCODE = 'ODTYPEFEE' --su kien Tinh phi theo loai hinh
                   AND ICTD.ICCFSTATUS = 'A'
                   AND OD.FEEACR = 0
                   AND OD.TXDATE = V_DATE
                   AND OD.orderid NOT IN (SELECT nvl(ORDERID,'01010101') FROM bondrepo WHERE  TXDATE = V_DATE)
                 GROUP BY OD.AFACCTNO,
                          TYP.ACTYPE,
                          ICTD.ICRATE,
                          ICTD.RULETYPE
                 ORDER BY OD.AFACCTNO, TYP.ACTYPE) LOOP
      L_ICCFBAL  := REC.TOTALEXEC;
      L_ICCFBAL  := FN_GETTRADINGAMOUNT(REC.AFACCTNO, REC.ACTYPE);
      L_ICRATE   := REC.ICRATE;
      L_RULETYPE := REC.RULETYPE;
      L_ORDER    := REC.TOTALORDER;
      IF L_ICCFBAL > 0 THEN
        IF L_RULETYPE <> 'C' THEN
          --Luat tinh theo fixed hoac tier
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          BEGIN
            --Xac dinh tier
            IF L_RULETYPE = 'T' THEN
              SELECT DELTA
                INTO V_DELTA
                FROM ICCFTIER
               WHERE ACTYPE = REC.ACTYPE
                 AND MODCODE = 'OD'
                 AND EVENTCODE = 'ODTYPEFEE'
                 AND DELTD <> 'Y'
                 AND FRAMT <= L_ICCFBAL
                 AND TOAMT > L_ICCFBAL;
            ELSE
              V_DELTA := 0;
            END IF;
            L_ICRATE := L_ICRATE + V_DELTA;
          EXCEPTION
            WHEN OTHERS THEN
              L_ICRATE := L_ICRATE;
          END;
          L_AMOUNT := L_ICCFBAL;

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          INSERT INTO ODBRKFEE
            (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
            SELECT ORDERID,
                   TXDATE,
                   'ODTYPEFEE',
                   REC.ACTYPE,
                   FLOOR((L_ICRATE / 100) * EXECAMT)
              FROM ODMAST OD
             WHERE OD.ORDERID IN
                   (SELECT OD.ORDERID
                      FROM ODMAST       OD,
                           AFMAST       AF,
                           ODTYPE       TYP,
                           AFIDTYPE     ID,
                           ICCFTYPEDEF  ICTD,
                           SBSECURITIES SB
                     WHERE OD.AFACCTNO = AF.ACCTNO
                       AND OD.AFACCTNO LIKE L_AFACCTNO
                       AND OD.DELTD <> 'Y'
                       AND OD.EXECQTTY > 0
                       AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                       AND OD.CODEID = SB.CODEID
                          --and od.actype = typ.actype
                          --and od.actype <> typ.actype
                       AND (TYP.VIA = OD.VIA OR TYP.VIA = 'A') --VIA
                       AND TYP.CLEARCD = OD.CLEARCD --CLEARCD
                       AND (TYP.EXECTYPE = OD.EXECTYPE OR
                           TYP.EXECTYPE = 'AA') --EXECTYPE
                       AND (TYP.TIMETYPE = OD.TIMETYPE OR TYP.TIMETYPE = 'A') --TIMETYPE
                       AND (TYP.PRICETYPE = OD.PRICETYPE OR
                           TYP.PRICETYPE = 'AA') --PRICETYPE
                       AND (TYP.MATCHTYPE = OD.MATCHTYPE OR
                           TYP.MATCHTYPE = 'A') --MATCHTYPE
                       AND (TYP.TRADEPLACE = SB.TRADEPLACE OR
                           TYP.TRADEPLACE = '000')
                       AND (INSTR(CASE
                                    WHEN SB.SECTYPE IN ('001', '002') THEN
                                     SB.SECTYPE || ',' || '111,333'
                                    WHEN SB.SECTYPE IN ('003', '006') THEN
                                     SB.SECTYPE || ',' || '222,333,444'
                                    WHEN SB.SECTYPE IN ('008') THEN
                                     SB.SECTYPE || ',' || '111,444'
                                    ELSE
                                     SB.SECTYPE
                                  END,
                                  TYP.SECTYPE) > 0 OR TYP.SECTYPE = '000')
                       AND (TYP.NORK = OD.NORK OR TYP.NORK = 'A') --NORK
                       AND (CASE
                             WHEN TYP.CODEID IS NULL THEN
                              OD.CODEID
                             ELSE
                              TYP.CODEID
                           END) = OD.CODEID
                       AND TYP.ACTYPE = ID.ACTYPE
                       AND ID.AFTYPE = AF.ACTYPE
                       AND ID.OBJNAME = 'OD.ODTYPE'
                       AND TYP.STATUS = 'Y'
                       AND TO_DATE(TYP.VALDATE, 'DD/MM/RRRR') <= V_DATE
                       AND TO_DATE(TYP.EXPDATE, 'DD/MM/RRRR') >= V_DATE
                          --------
                       AND TYP.BRKFEETYPE = 'G'
                       AND TYP.ACTYPE = ICTD.ACTYPE
                       AND ICTD.MODCODE = 'OD'
                       AND ICTD.EVENTCODE = 'ODTYPEFEE' --su kien Tinh phi theo loai hinh
                       AND ICTD.ICCFSTATUS = 'A'
                       AND OD.FEEACR = 0
                       AND OD.TXDATE = V_DATE
                       AND OD.AFACCTNO = REC.AFACCTNO
                       AND TYP.ACTYPE = REC.ACTYPE);
        ELSE
          --Luat tinh theo cluster
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          L_FEEAMT := 0;
          FOR REC_TIER IN (SELECT DELTA, FRAMT, TOAMT
                             FROM ICCFTIER
                            WHERE ACTYPE = REC.ACTYPE
                              AND MODCODE = 'OD'
                              AND EVENTCODE = 'ODTYPEFEE'
                              AND DELTD <> 'Y'
                            ORDER BY FRAMT) LOOP
            EXIT WHEN L_ICCFBAL < REC_TIER.FRAMT;
            IF L_ICCFBAL > REC_TIER.FRAMT AND L_ICCFBAL < REC_TIER.TOAMT THEN
              L_AMOUNT := L_ICCFBAL - REC_TIER.FRAMT;
            ELSE
              L_AMOUNT := REC_TIER.TOAMT - REC_TIER.FRAMT;
            END IF;
            L_ICRATE := REC.ICRATE + REC_TIER.DELTA;
            L_FEEAMT := L_FEEAMT + FLOOR(L_AMOUNT * (L_ICRATE / 100));
          END LOOP;

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          INSERT INTO ODBRKFEE
            (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
            SELECT ORDERID,
                   TXDATE,
                   'ODTYPEFEE',
                   REC.ACTYPE,
                   FLOOR(((L_FEEAMT / L_ICCFBAL) / 100) * EXECAMT)
              FROM ODMAST OD
             WHERE OD.ORDERID IN
                   (SELECT OD.ORDERID
                      FROM ODMAST       OD,
                           AFMAST       AF,
                           ODTYPE       TYP,
                           AFIDTYPE     ID,
                           ICCFTYPEDEF  ICTD,
                           SBSECURITIES SB
                     WHERE OD.AFACCTNO = AF.ACCTNO
                       AND OD.AFACCTNO LIKE L_AFACCTNO
                       AND OD.DELTD <> 'Y'
                       AND OD.EXECQTTY > 0
                       AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                       AND OD.CODEID = SB.CODEID
                          --and od.actype = typ.actype
                          --and od.actype <> typ.actype
                       AND (TYP.VIA = OD.VIA OR TYP.VIA = 'A') --VIA
                       AND TYP.CLEARCD = OD.CLEARCD --CLEARCD
                       AND (TYP.EXECTYPE = OD.EXECTYPE OR
                           TYP.EXECTYPE = 'AA') --EXECTYPE
                       AND (TYP.TIMETYPE = OD.TIMETYPE OR TYP.TIMETYPE = 'A') --TIMETYPE
                       AND (TYP.PRICETYPE = OD.PRICETYPE OR
                           TYP.PRICETYPE = 'AA') --PRICETYPE
                       AND (TYP.MATCHTYPE = OD.MATCHTYPE OR
                           TYP.MATCHTYPE = 'A') --MATCHTYPE
                       AND (TYP.TRADEPLACE = SB.TRADEPLACE OR
                           TYP.TRADEPLACE = '000')
                       AND (INSTR(CASE
                                    WHEN SB.SECTYPE IN ('001', '002') THEN
                                     SB.SECTYPE || ',' || '111,333'
                                    WHEN SB.SECTYPE IN ('003', '006') THEN
                                     SB.SECTYPE || ',' || '222,333,444'
                                    WHEN SB.SECTYPE IN ('008') THEN
                                     SB.SECTYPE || ',' || '111,444'
                                    ELSE
                                     SB.SECTYPE
                                  END,
                                  TYP.SECTYPE) > 0 OR TYP.SECTYPE = '000')
                       AND (TYP.NORK = OD.NORK OR TYP.NORK = 'A') --NORK
                       AND (CASE
                             WHEN TYP.CODEID IS NULL THEN
                              OD.CODEID
                             ELSE
                              TYP.CODEID
                           END) = OD.CODEID
                       AND TYP.ACTYPE = ID.ACTYPE
                       AND ID.AFTYPE = AF.ACTYPE
                       AND ID.OBJNAME = 'OD.ODTYPE'
                       AND TYP.STATUS = 'Y'
                       AND TO_DATE(TYP.VALDATE, 'DD/MM/RRRR') <= V_DATE
                       AND TO_DATE(TYP.EXPDATE, 'DD/MM/RRRR') >= V_DATE
                          --------
                       AND TYP.BRKFEETYPE = 'G'
                       AND TYP.ACTYPE = ICTD.ACTYPE
                       AND ICTD.MODCODE = 'OD'
                       AND ICTD.EVENTCODE = 'ODTYPEFEE' --su kien Tinh phi theo loai hinh
                       AND ICTD.ICCFSTATUS = 'A'
                       AND OD.FEEACR = 0
                       AND OD.TXDATE = V_DATE
                       AND OD.AFACCTNO = REC.AFACCTNO
                       AND TYP.ACTYPE = REC.ACTYPE);
        END IF;

      END IF;
    END LOOP;

    -- Tinh phi theo lenh: Cho tinh cho truong hop khai ICCF trong loai hinh va BRKFEETYPE='N': Tinh phi theo tung lenh
    --TInh cho loai hinh gan voi lenh
    FOR REC IN (SELECT OD.ORDERID,
                       MAX(OD.AFACCTNO) AFACCTNO,
                       TYP.ACTYPE ACTYPE,
                       MAX(OD.EXECAMT) TOTALEXEC,
                       MAX(ICTD.ICRATE) ICRATE,
                       MAX(ICTD.RULETYPE) RULETYPE
                  FROM ODMAST OD, ODTYPE TYP, ICCFTYPEDEF ICTD
                 WHERE OD.DELTD <> 'Y'
                   AND OD.AFACCTNO LIKE L_AFACCTNO
                   AND OD.EXECQTTY > 0
                   AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                   AND OD.ACTYPE = TYP.ACTYPE
                   AND TYP.BRKFEETYPE = 'N'
                   AND OD.ACTYPE = ICTD.ACTYPE
                   AND ICTD.MODCODE = 'OD'
                   AND ICTD.EVENTCODE = 'ODTRADEFEE' --Event tinh phi theo lenh
                   AND ICTD.ICCFSTATUS = 'A'
                   AND OD.FEEACR = 0
                   AND OD.TXDATE = V_DATE
                   AND OD.orderid NOT IN (SELECT nvl(ORDERID,'01010101') FROM bondrepo WHERE TXDATE = V_DATE)
                 GROUP BY OD.ORDERID, TYP.ACTYPE
                 ORDER BY OD.ORDERID) LOOP
      L_ICCFBAL  := REC.TOTALEXEC;
      L_ICRATE   := REC.ICRATE;
      L_RULETYPE := REC.RULETYPE;
      IF L_ICCFBAL > 0 THEN
        IF L_RULETYPE <> 'C' THEN
          --Luat tinh theo fixed hoac tier
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          BEGIN
            --Xac dinh tier
            IF L_RULETYPE = 'T' THEN
              SELECT DELTA
                INTO V_DELTA
                FROM ICCFTIER
               WHERE ACTYPE = REC.ACTYPE
                 AND MODCODE = 'OD'
                 AND EVENTCODE = 'ODTRADEFEE'
                 AND DELTD <> 'Y'
                 AND FRAMT <= L_ICCFBAL
                 AND TOAMT > L_ICCFBAL;
            ELSE
              V_DELTA := 0;
            END IF;
            L_ICRATE := L_ICRATE + V_DELTA;
          EXCEPTION
            WHEN OTHERS THEN
              L_ICRATE := L_ICRATE;
          END;
          L_AMOUNT := L_ICCFBAL;

          /*--Cap nhat fee cho tung lenh
          UPDATE ODMAST SET FEEACR = round((l_icrate/100)*EXECAMT, 0)
          WHERE orderid = rec.orderid;*/

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          INSERT INTO ODBRKFEE
            (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
            SELECT ORDERID,
                   TXDATE,
                   'ODTRADEFEE',
                   REC.ACTYPE,
                   FLOOR((L_ICRATE / 100) * EXECAMT)
              FROM ODMAST
             WHERE ORDERID = REC.ORDERID;
        ELSE
          --Luat tinh theo cluster
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          L_FEEAMT := 0;
          FOR REC_TIER IN (SELECT DELTA, FRAMT, TOAMT
                             FROM ICCFTIER
                            WHERE ACTYPE = REC.ACTYPE
                              AND MODCODE = 'OD'
                              AND EVENTCODE = 'ODTRADEFEE'
                              AND DELTD <> 'Y'
                            ORDER BY FRAMT) LOOP
            EXIT WHEN L_ICCFBAL < REC_TIER.FRAMT;
            IF L_ICCFBAL > REC_TIER.FRAMT AND L_ICCFBAL < REC_TIER.TOAMT THEN
              L_AMOUNT := L_ICCFBAL - REC_TIER.FRAMT;
            ELSE
              L_AMOUNT := REC_TIER.TOAMT - REC_TIER.FRAMT;
            END IF;
            L_ICRATE := REC.ICRATE + REC_TIER.DELTA;
            L_FEEAMT := L_FEEAMT + FLOOR(L_AMOUNT * (L_ICRATE / 100));
          END LOOP;
          /*--Cap nhat fee cho tung lenh bang cach lay trung binh
          UPDATE ODMAST SET FEEACR = l_feeamt
          WHERE orderid = rec.orderid;*/

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          INSERT INTO ODBRKFEE
            (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
            SELECT ORDERID, TXDATE, 'ODTRADEFEE', REC.ACTYPE, L_FEEAMT
              FROM ODMAST
             WHERE ORDERID = REC.ORDERID;
        END IF;
      END IF;
    END LOOP;

    -- Tinh phi theo lenh: Cho tinh cho truong hop khai ICCF trong loai hinh va BRKFEETYPE='N': Tinh phi theo tung lenh
    --TInh theo su kien cua loai hinh lenh khong gan voi lenh ma thoa man cac tieu chi
    FOR REC IN (SELECT OD.ORDERID,
                       MAX(OD.AFACCTNO) AFACCTNO,
                       TYP.ACTYPE ACTYPE,
                       MAX(OD.EXECAMT) TOTALEXEC,
                       MAX(ICTD.ICRATE) ICRATE,
                       MAX(ICTD.RULETYPE) RULETYPE
                  FROM ODMAST       OD,
                       AFMAST       AF,
                       ODTYPE       TYP,
                       AFIDTYPE     ID,
                       ICCFTYPEDEF  ICTD,
                       SBSECURITIES SB
                 WHERE OD.AFACCTNO = AF.ACCTNO
                   AND OD.AFACCTNO LIKE L_AFACCTNO
                   AND OD.DELTD <> 'Y'
                   AND OD.EXECQTTY > 0
                   AND OD.CODEID = SB.CODEID
                   AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                      --and od.actype = typ.actype
                   AND OD.ACTYPE <> TYP.ACTYPE
                   AND (TYP.VIA = OD.VIA OR TYP.VIA = 'A') --VIA
                   AND TYP.CLEARCD = OD.CLEARCD --CLEARCD
                   AND (TYP.EXECTYPE = OD.EXECTYPE OR TYP.EXECTYPE = 'AA') --EXECTYPE
                   AND (TYP.TIMETYPE = OD.TIMETYPE OR TYP.TIMETYPE = 'A') --TIMETYPE
                   AND (TYP.PRICETYPE = OD.PRICETYPE OR TYP.PRICETYPE = 'AA') --PRICETYPE
                   AND (TYP.MATCHTYPE = OD.MATCHTYPE OR TYP.MATCHTYPE = 'A') --MATCHTYPE
                   AND (TYP.TRADEPLACE = SB.TRADEPLACE OR
                       TYP.TRADEPLACE = '000')
                   AND (INSTR(CASE
                                WHEN SB.SECTYPE IN ('001', '002') THEN
                                 SB.SECTYPE || ',' || '111,333'
                                WHEN SB.SECTYPE IN ('003', '006') THEN
                                 SB.SECTYPE || ',' || '222,333,444'
                                WHEN SB.SECTYPE IN ('008') THEN
                                 SB.SECTYPE || ',' || '111,444'
                                ELSE
                                 SB.SECTYPE
                              END,
                              TYP.SECTYPE) > 0 OR TYP.SECTYPE = '000')
                   AND (TYP.NORK = OD.NORK OR TYP.NORK = 'A') --NORK
                   AND (CASE
                         WHEN TYP.CODEID IS NULL THEN
                          OD.CODEID
                         ELSE
                          TYP.CODEID
                       END) = OD.CODEID
                   AND TYP.ACTYPE = ID.ACTYPE
                   AND ID.AFTYPE = AF.ACTYPE
                   AND ID.OBJNAME = 'OD.ODTYPE'
                   AND TYP.STATUS = 'Y'
                   AND TO_DATE(TYP.VALDATE, 'DD/MM/RRRR') <= V_DATE
                   AND TO_DATE(TYP.EXPDATE, 'DD/MM/RRRR') >= V_DATE
                      ---------------------
                   AND TYP.BRKFEETYPE = 'N'
                   AND TYP.ACTYPE = ICTD.ACTYPE
                   AND ICTD.MODCODE = 'OD'
                   AND ICTD.EVENTCODE = 'ODTRADEFEE' --Event tinh phi theo lenh
                   AND ICTD.ICCFSTATUS = 'A'
                   AND OD.FEEACR = 0
                   AND OD.TXDATE = V_DATE
                   AND OD.orderid NOT IN (SELECT nvl(ORDERID,'01010101') FROM bondrepo WHERE TXDATE = V_DATE)
                 GROUP BY OD.ORDERID, TYP.ACTYPE
                 ORDER BY OD.ORDERID) LOOP
      L_ICCFBAL  := REC.TOTALEXEC;
      L_ICRATE   := REC.ICRATE;
      L_RULETYPE := REC.RULETYPE;
      IF L_ICCFBAL > 0 THEN
        IF L_RULETYPE <> 'C' THEN
          --Luat tinh theo fixed hoac tier
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          BEGIN
            --Xac dinh tier
            IF L_RULETYPE = 'T' THEN
              SELECT DELTA
                INTO V_DELTA
                FROM ICCFTIER
               WHERE ACTYPE = REC.ACTYPE
                 AND MODCODE = 'OD'
                 AND EVENTCODE = 'ODTRADEFEE'
                 AND DELTD <> 'Y'
                 AND FRAMT <= L_ICCFBAL
                 AND TOAMT > L_ICCFBAL;
            ELSE
              V_DELTA := 0;
            END IF;
            L_ICRATE := L_ICRATE + V_DELTA;
          EXCEPTION
            WHEN OTHERS THEN
              L_ICRATE := L_ICRATE;
          END;
          L_AMOUNT := L_ICCFBAL;

          /*--Cap nhat fee cho tung lenh
          UPDATE ODMAST SET FEEACR = round((l_icrate/100)*EXECAMT, 0)
          WHERE orderid = rec.orderid;*/

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          INSERT INTO ODBRKFEE
            (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
            SELECT ORDERID,
                   TXDATE,
                   'ODTRADEFEE',
                   REC.ACTYPE,
                   FLOOR((L_ICRATE / 100) * EXECAMT)
              FROM ODMAST
             WHERE ORDERID = REC.ORDERID;
        ELSE
          --Luat tinh theo cluster
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          L_FEEAMT := 0;
          FOR REC_TIER IN (SELECT DELTA, FRAMT, TOAMT
                             FROM ICCFTIER
                            WHERE ACTYPE = REC.ACTYPE
                              AND MODCODE = 'OD'
                              AND EVENTCODE = 'ODTRADEFEE'
                              AND DELTD <> 'Y'
                            ORDER BY FRAMT) LOOP
            EXIT WHEN L_ICCFBAL < REC_TIER.FRAMT;
            IF L_ICCFBAL > REC_TIER.FRAMT AND L_ICCFBAL < REC_TIER.TOAMT THEN
              L_AMOUNT := L_ICCFBAL - REC_TIER.FRAMT;
            ELSE
              L_AMOUNT := REC_TIER.TOAMT - REC_TIER.FRAMT;
            END IF;
            L_ICRATE := REC.ICRATE + REC_TIER.DELTA;
            L_FEEAMT := L_FEEAMT + FLOOR(L_AMOUNT * (L_ICRATE / 100));
          END LOOP;
          /*--Cap nhat fee cho tung lenh bang cach lay trung binh
          UPDATE ODMAST SET FEEACR = l_feeamt
          WHERE orderid = rec.orderid;*/

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          INSERT INTO ODBRKFEE
            (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
            SELECT ORDERID, TXDATE, 'ODTRADEFEE', REC.ACTYPE, L_FEEAMT
              FROM ODMAST
             WHERE ORDERID = REC.ORDERID;
        END IF;
      END IF;
    END LOOP;

    /*-- Tinh phi theo lenh: Cho tinh cho truong hop khai ICCF trong loai hinh va ISSUMMARIZED='Y': Tinh phi theo tong gia tri lenh trong ngay
    for rec in
    (
        select od.afacctno afacctno, max(af.actype) actype , sum(od.execamt) totalexec, max(ictd.icrate) icrate,
                     max(ictd.ruletype) ruletype
                from odmast od, odtype typ,afmast af,aftype aft, iccftypedef ictd
                where od.deltd <> 'Y' and od.execqtty > 0
                      and od.exectype in ('NB','BC','SS','NS','MS')
                      and od.actype = typ.actype and typ.issummarized='Y'
                      and od.afacctno = af.acctno
                      and af.actype = aft.actype
                      and aft.actype = ictd.actype
                      and ictd.modcode = 'CF'
                      and ictd.eventcode = 'DTRADEFEE' --Event tinh phi theo ngay
                      and ictd.iccfstatus = 'A'
                      and od.feeacr = 0
                      and od.txdate = v_DATE
                group by od.afacctno
                order by od.afacctno
    )
    loop
        l_iccfbal:=rec.totalexec;
        l_icrate:=rec.icrate;
        l_ruletype:=rec.ruletype;
        if l_iccfbal>0 then
            if l_ruletype<>'C' then
                --Luat tinh theo fixed hoac tier
                --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
                begin
                --Xac dinh tier
                    if l_ruletype ='T' then
                        select delta into v_delta from iccftier
                        where actype =rec.actype and modcode ='CF'
                        and eventcode='DTRADEFEE' and deltd <> 'Y'
                        and framt < l_iccfbal and toamt >= l_iccfbal;
                    else
                        v_delta:=0;
                    end if;
                    l_icrate:=l_icrate+v_delta;
                exception when others then
                    l_icrate:=l_icrate;
                end;
                l_amount:=l_iccfbal;

                --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
                insert into odbrkfee (orderid,txdate, eventcode,refcode, feeamt)
                select orderid, txdate, 'DTRADEFEE', rec.afacctno, round((l_icrate/100)*EXECAMT, 0)
                from odmast od
                WHERE od.afacctno = rec.afacctno and od.actype in (select actype from odtype where issummarized='Y')
                      and od.deltd <> 'Y' and od.execqtty > 0
                      and od.exectype in ('NB','BC','SS','NS','MS')
                      AND od.TXDATE = v_DATE;
            else
                --Luat tinh theo cluster
                --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
                l_feeamt:=0;
                for rec_tier in
                (
                    select delta, framt, toamt
                    from iccftier
                        where actype =rec.actype and modcode ='CF'
                        and eventcode='DTRADEFEE' and deltd <> 'Y'
                        order by framt
                )
                loop
                    exit when l_iccfbal<rec_tier.framt;
                    if l_iccfbal>rec_tier.framt and l_iccfbal<rec_tier.toamt then
                        l_amount:=l_iccfbal-rec_tier.framt;
                    ELSE
                        l_amount:=rec_tier.toamt-rec_tier.framt;
                    end if;
                    l_icrate:=rec.icrate+rec_tier.delta;
                    l_feeamt:=l_feeamt+round(l_amount*(l_icrate/100),0);
                end loop;
                --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
                insert into odbrkfee (orderid,txdate, eventcode,refcode, feeamt)
                select orderid, txdate, 'DTRADEFEE', rec.afacctno, round((l_feeamt/l_iccfbal)*EXECAMT, 0)
                from odmast od
                WHERE od.afacctno = rec.afacctno and od.actype in (select actype from odtype where issummarized='Y')
                      and od.deltd <> 'Y' and od.execqtty > 0
                      and od.exectype in ('NB','BC','SS','NS','MS')
                      AND TXDATE = v_DATE;
            end if;
        end if;
    end loop;*/

    -- Tinh phi theo su kien: mien giam phi theo chinh sach trong ODPROBRKMST
    FOR REC IN (SELECT SUM(OD.EXECAMT) TOTALEXEC,
                       MAX(MST.FEETYPE) RULETYPE,
                       MAX(MST.FEERATE) ICRATE,
                       MAX(MST.MINAMT) MINAMT,
                       MAX(MST.MAXAMT) MAXAMT,
                       PAF.AFACCTNO,
                       MST.AUTOID,
                       MAX(PAF.OPNDATE) OPNDATE,
                       MAX(MST.CALFEETYPE) CALFEETYPE,
                       MAX(MST.CALDATETYPE) CALDATETYPE,
                       MAX(CASE
                             WHEN CALDATETYPE = '1' THEN
                              (TO_NUMBER(TO_CHAR(V_DATE, 'RRRR')) -
                              TO_NUMBER(TO_CHAR(MST.VALDATE, 'RRRR'))) * 12 +
                              (TO_NUMBER(TO_CHAR(V_DATE, 'MM')) -
                              TO_NUMBER(TO_CHAR(MST.VALDATE, 'MM')))
                             ELSE
                              (TO_NUMBER(TO_CHAR(V_DATE, 'RRRR')) -
                              TO_NUMBER(TO_CHAR(PAF.OPNDATE, 'RRRR'))) * 12 +
                              (TO_NUMBER(TO_CHAR(V_DATE, 'MM')) -
                              TO_NUMBER(TO_CHAR(PAF.OPNDATE, 'MM')))
                           END) MONTHVAL,
                       MAX(CASE
                             WHEN CALDATETYPE = '1' THEN
                              TO_NUMBER(V_DATE - PAF.VALDATE)
                             ELSE
                              TO_NUMBER(V_DATE - PAF.OPNDATE)
                           END) DATEVAL
                  FROM ODPROBRKAF PAF, ODPROBRKMST MST, ODMAST OD
                 WHERE MST.AUTOID = PAF.REFAUTOID
                   AND OD.AFACCTNO LIKE L_AFACCTNO
                   AND NVL(PAF.VALDATE, TO_DATE('01/01/2014', 'DD/MM/RRRR')) <=
                       V_DATE
                   AND NVL(PAF.EXPDATE, TO_DATE('01/01/2014', 'DD/MM/RRRR')) >=
                       V_DATE
                   AND PAF.AFACCTNO = OD.AFACCTNO
                   AND OD.DELTD <> 'Y'
                   AND OD.EXECQTTY > 0
                   AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                   AND OD.TXDATE = V_DATE
                   AND OD.orderid NOT IN (SELECT nvl(ORDERID,'01010101') FROM bondrepo WHERE  TXDATE = V_DATE)
                   AND PAF.STATUS = 'A'
                 GROUP BY MST.AUTOID, PAF.AFACCTNO) LOOP
      L_ICCFBAL     := REC.TOTALEXEC;
      L_ICRATE      := REC.ICRATE;
      L_RULETYPE    := REC.RULETYPE;
      L_OPNDATE     := REC.OPNDATE;
      L_CALFEETYPE  := REC.CALFEETYPE;
      L_CALDATETYPE := REC.CALDATETYPE;
      IF L_ICCFBAL > 0 THEN
        IF L_CALFEETYPE = 'D' THEN
          --Kieu tinh Direct theo bieu phi
          IF L_RULETYPE <> 'C' THEN
            --Luat tinh theo fixed hoac tier
            --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
            BEGIN
              --Xac dinh tier
              IF L_RULETYPE = 'T' THEN
                SELECT VALAMT
                  INTO V_DELTA
                  FROM ODPROBRKSCHM
                 WHERE REFAUTOID = REC.AUTOID
                   AND FRAMT <= L_ICCFBAL
                   AND TOAMT > L_ICCFBAL;
              ELSE
                V_DELTA := 0;
              END IF;
              L_ICRATE := L_ICRATE + V_DELTA;
            EXCEPTION
              WHEN OTHERS THEN
                L_ICRATE := L_ICRATE;
            END;
            L_AMOUNT := L_ICCFBAL;
            L_FEEAMT := L_ICRATE / 100 * L_ICCFBAL;
            L_FEEAMT := LEAST(L_FEEAMT, REC.MAXAMT);
            L_FEEAMT := GREATEST(L_FEEAMT, REC.MINAMT);
            --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
            INSERT INTO ODBRKFEE
              (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
              SELECT ORDERID,
                     TXDATE,
                     'ODPROBRKMST',
                     TO_CHAR(REC.AUTOID),
                     FLOOR(L_FEEAMT / L_ICCFBAL * EXECAMT)
                FROM ODMAST OD
               WHERE OD.AFACCTNO = REC.AFACCTNO
                 AND OD.DELTD <> 'Y'
                 AND OD.EXECQTTY > 0
                 AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                 AND OD.TXDATE = V_DATE;
          ELSE
            --Luat tinh theo cluster
            --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
            L_FEEAMT := 0;
            FOR REC_TIER IN (SELECT VALAMT DELTA, FRAMT, TOAMT
                               FROM ODPROBRKSCHM
                              WHERE REFAUTOID = REC.AUTOID
                              ORDER BY FRAMT) LOOP
              EXIT WHEN L_ICCFBAL < REC_TIER.FRAMT;
              IF L_ICCFBAL > REC_TIER.FRAMT AND L_ICCFBAL < REC_TIER.TOAMT THEN
                L_AMOUNT := L_ICCFBAL - REC_TIER.FRAMT;
              ELSE
                L_AMOUNT := REC_TIER.TOAMT - REC_TIER.FRAMT;
              END IF;
              L_ICRATE := REC.ICRATE + REC_TIER.DELTA;
              L_FEEAMT := L_FEEAMT + FLOOR(L_AMOUNT * (L_ICRATE / 100));
            END LOOP;
            L_FEEAMT := LEAST(L_FEEAMT, REC.MAXAMT);
            L_FEEAMT := GREATEST(L_FEEAMT, REC.MINAMT);
            --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
            INSERT INTO ODBRKFEE
              (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
              SELECT ORDERID,
                     TXDATE,
                     'ODPROBRKMST',
                     TO_CHAR(REC.AUTOID),
                     FLOOR((L_FEEAMT / L_ICCFBAL) * EXECAMT)
                FROM ODMAST OD
               WHERE OD.AFACCTNO = REC.AFACCTNO
                 AND OD.DELTD <> 'Y'
                 AND OD.EXECQTTY > 0
                 AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                 AND OD.TXDATE = V_DATE;
          END IF;
        ELSE
          --l_calfeetype= 'I' --Kieu tinh Indirect theo bac thang thoi gian
          --Tinh so thang hien tai de tinh bac thang thoi gian
          L_MONTHVAL := REC.MONTHVAL;
          --Luat tinh theo fixed hoac tier (Cluster tinh giong voi Tier)
          --Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
          BEGIN
            --Xac dinh tier
            IF L_RULETYPE = 'T' OR L_RULETYPE = 'C' THEN
              SELECT VALAMT
                INTO V_DELTA
                FROM ODPROBRKSCHM2
               WHERE REFAUTOID = REC.AUTOID
                 AND FRDATE <= REC.DATEVAL
                 AND TODATE > REC.DATEVAL;
            ELSE
              V_DELTA := 0;
            END IF;
            L_ICRATE := L_ICRATE + V_DELTA;
          EXCEPTION
            WHEN OTHERS THEN
              L_ICRATE := L_ICRATE;
          END;

          --Them vao bang ODBRKFEE luu lai cac cach tinh phi cho lenh trong ngay
          --So phi tinh = ty le mien giam phi * So phi da tinh tren loai hinh.
          insert into odbrkfee (orderid,txdate, eventcode,refcode, feeamt)
          select br.orderid, br.txdate, 'ODPROBRKMST', to_char(rec.autoid), floor(br.feeamt*l_icrate/100)
          from odbrkfee br,odmast od
          WHERE br.eventcode = 'ODTYPEFEE' --Chi tinh mien giam tren bieu phi chung cua loai hinh
              and br.orderid = od.orderid
              and od.afacctno = rec.afacctno
              and od.deltd <> 'Y' and od.execqtty > 0
              and od.exectype in ('NB','BC','SS','NS','MS')
              and od.txdate = v_DATE;
          --Lay ra tong phi min theo loai hinh
          SELECT NVL(SUM(FEE_EX), 0) FEE_EX
            INTO L_FEE_EX
            FROM (SELECT BR.ORDERID,
                         BR.TXDATE,
                         'ODPROBRKMST',
                         TO_CHAR(REC.AUTOID) AUTOID,
                         FLOOR(MIN(BR.FEEAMT) * L_ICRATE / 100) FEE_EX
                    FROM ODBRKFEE BR, ODMAST OD
                   WHERE BR.EVENTCODE = 'ODTYPEFEE' --Chi tinh mien giam tren bieu phi chung cua loai hinh
                     AND BR.ORDERID = OD.ORDERID
                     AND OD.AFACCTNO = REC.AFACCTNO
                     AND OD.DELTD <> 'Y'
                     AND OD.EXECQTTY > 0
                     AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                     AND OD.TXDATE = V_DATE
                   GROUP BY BR.ORDERID, BR.TXDATE);
          L_FEEAMT := L_FEE_EX;
          L_FEEAMT := LEAST(L_FEEAMT, REC.MAXAMT);
          L_FEEAMT := GREATEST(L_FEEAMT, REC.MINAMT);

          IF L_FEE_EX > 0 THEN
            INSERT INTO ODBRKFEE
              (ORDERID, TXDATE, EVENTCODE, REFCODE, FEEAMT)
              SELECT BR.ORDERID,
                     BR.TXDATE,
                     'ODPROBRKMST',
                     TO_CHAR(REC.AUTOID),
                     FLOOR(MIN(BR.FEEAMT) * L_ICRATE / 100 * L_FEEAMT /
                           L_FEE_EX)
                FROM ODBRKFEE BR, ODMAST OD
               WHERE BR.EVENTCODE = 'ODTYPEFEE' --Chi tinh mien giam tren bieu phi chung cua loai hinh
                 AND BR.ORDERID = OD.ORDERID
                 AND OD.AFACCTNO = REC.AFACCTNO
                 AND OD.DELTD <> 'Y'
                 AND OD.EXECQTTY > 0
                 AND OD.EXECTYPE IN ('NB', 'BC', 'SS', 'NS', 'MS')
                 AND OD.TXDATE = V_DATE
               GROUP BY BR.ORDERID, BR.TXDATE;
          END IF;

        END IF;

      END IF;
    END LOOP;

    --Ap muc phi toi thieu cho lenh
    FOR REC IN (SELECT O.ORDERID, MIN(O.FEEAMT) FEEAMT
                FROM ODBRKFEE O,  ODMAST OD
                 WHERE O.TXDATE = V_DATE
                 AND OD.AFACCTNO LIKE L_AFACCTNO
                 AND OD.ORDERID =O.ORDERID
                 AND O.ORDERID NOT IN (SELECT nvl(ORDERID,'01010101') FROM bondrepo WHERE TXDATE = V_DATE)
                 GROUP BY O.ORDERID) LOOP
      UPDATE ODMAST SET FEEACR = REC.FEEAMT WHERE ORDERID = REC.ORDERID;
      PR_ALLOCATE_IOD_FEE(REC.ORDERID); --Gianh VG moi them
    END LOOP;
    -- call cal_odmast_excfeeamt proc
    -- CAL_ODMAST_EXCFEEAMT;

    UPDATE ODMAST T1
    SET EXCFEEAMT = (
      SELECT DECODE(T2.FORP,'P',FEEAMT/100,FEEAMT)*T1.EXECAMT/(T2.LOTDAY*T2.LOTVAL)
      FROM VW_ODMAST_EXC_FEETERM T2
      WHERE T1.ORDERID = T2.ORDERID)
    WHERE AFACCTNO LIKE L_AFACCTNO;
    --ID THAM CHI?U
    UPDATE ODMAST T1
    SET EXCFEEREFID = (
      SELECT T2.AUTOID
      FROM VW_ODMAST_EXC_FEETERM T2
      WHERE T1.ORDERID = T2.ORDERID)
    WHERE AFACCTNO LIKE L_AFACCTNO;
   -- COMMIT;

   ---DungNH cap nhat phi trong IOD cho lenh repo
    FOR RECrepo IN (SELECT ORDERID, (FEEACR)  FEEACR FROM ODMAST
                 WHERE TXDATE = V_DATE AND AFACCTNO LIKE L_AFACCTNO
                 and ORDERID in (SELECT nvl(ORDERID,'01010101') FROM bondrepo WHERE TXDATE = V_DATE)
               )
    LOOP
      update iod set iodfeeacr = RECrepo.FEEACR where iod.orgorderid=recrepo.ORDERID;
    END LOOP;
    ---End DungNH.

    P_ERR_CODE := 0;
    PLOG.SETENDSECTION(PKGCTX, 'pr_ODFeeCalculate');
  EXCEPTION
    WHEN OTHERS THEN
      PLOG.DEBUG(PKGCTX, 'got error on pr_ODFeeCalculate');
      ROLLBACK;
      P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
      PLOG.ERROR(PKGCTX, SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      PLOG.SETENDSECTION(PKGCTX, 'pr_ODFeeCalculate');
      RAISE ERRNUMS.E_SYSTEM_ERROR;
  END pr_odfeecalculate_for_acctno;



-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_odproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
