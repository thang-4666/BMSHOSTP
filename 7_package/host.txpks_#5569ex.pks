SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5569ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#5569EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      27/06/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#5569ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_lnschdid         CONSTANT CHAR(2) := '01';
   c_olntype          CONSTANT CHAR(2) := '02';
   c_lnacctno         CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_prinamt          CONSTANT CHAR(2) := '21';
   c_pprinamt         CONSTANT CHAR(2) := '31';
   c_intamt           CONSTANT CHAR(2) := '22';
   c_pintamt          CONSTANT CHAR(2) := '32';
   c_feeintamt        CONSTANT CHAR(2) := '23';
   c_pfeeintamt       CONSTANT CHAR(2) := '33';
   c_feeintovdacr     CONSTANT CHAR(2) := '24';
   c_pfeeintovdacr    CONSTANT CHAR(2) := '34';
   c_amt              CONSTANT CHAR(2) := '10';
   c_avlbal           CONSTANT CHAR(2) := '35';
   c_actype           CONSTANT CHAR(2) := '06';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count number;
    l_currdate date;
    l_avlbal number;

    l_rrtype varchar2(1);
    l_custbank  varchar2(100);
    l_custid varchar2(100);
    l_avlamt number(20,0);
    l_afavlamt number;
    l_mriratio number;
    l_marginrate number;
    l_advanceline number;

    l_MAXDEBTCF number;
    l_MAXDEBT   number;
    l_margin74amt number;
    l_totalmargin74amt number;
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
    l_currdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');
    select count(1) into l_count from lnschd where autoid = p_txmsg.txfields(c_lnschdid).value and rlsdate = p_txmsg.txdate;
    IF NOT l_count = 0 THEN
        p_txmsg.txWarningException('-5402301').value:= cspks_system.fn_get_errmsg('-540230');
        p_txmsg.txWarningException('-5402301').errlev:= '1';
    END IF;

    -- Kiem tra so tien thanh ly va so tien tai ki + so tien kha dung.
    select nvl(greatest(getbaldefovd(p_txmsg.txfields(c_acctno).value)),0)
        into l_avlbal
    from dual;
    if NOT (l_avlbal + to_number(p_txmsg.txfields(c_amt).value) >= to_number(p_txmsg.txfields(c_pprinamt).value)
                                                                + to_number(p_txmsg.txfields(c_pintamt).value)
                                                                + to_number(p_txmsg.txfields(c_pfeeintamt).value)
                                                                + to_number(p_txmsg.txfields(c_pfeeintovdacr).value)) then
        p_err_code := '-540231'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    select count(1) into l_count from lnmast ln, lnschd ls
    where ln.acctno = ls.acctno and ls.autoid = p_txmsg.txfields(c_lnschdid).value and ln.trfacctno = p_txmsg.txfields(c_acctno).value;
    IF NOT l_count > 0 THEN
        p_err_code := '-540232'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- Check nguon tuan thu?
    select count(1) into l_count from lntype where actype = p_txmsg.txfields(c_actype).value and status <> 'N' and chksysctrl = 'Y';

    if l_count > 0 then

       select custid into l_custid from afmast where acctno = p_txmsg.txfields(c_acctno).value;
       select TO_NUMBER(VARVALUE) into l_MAXDEBTCF from sysvar where grname = 'MARGIN' AND VARNAME = 'MAXDEBTCF';
       select TO_NUMBER(VARVALUE) into l_MAXDEBT from sysvar where grname = 'MARGIN' AND VARNAME = 'MAXDEBT';

       select nvl(sum(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd),0)
           into l_margin74amt
       from afmast af, lnmast ln, lntype lnt
       where ln.actype = lnt.actype and lnt.chksysctrl = 'Y'
       and af.acctno = ln.trfacctno and af.custid = l_custid;

       if not l_MAXDEBTCF >= l_margin74amt + to_number(p_txmsg.txfields(c_amt).value) then
           p_err_code := '-540235'; -- Pre-defined in DEFERROR table
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
       end if;

       select nvl(sum(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd),0)
           into l_totalmargin74amt
       from afmast af, lnmast ln, lntype lnt
       where ln.actype = lnt.actype and lnt.chksysctrl = 'Y'
       and af.acctno = ln.trfacctno;

       if not l_MAXDEBT >= l_totalmargin74amt + to_number(p_txmsg.txfields(c_amt).value) then
           p_err_code := '-540235'; -- Pre-defined in DEFERROR table
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
       end if;
    end if;

    begin
        select rrtype, custbank into l_rrtype, l_custbank from lntype where actype = p_txmsg.txfields(c_actype).value;
    exception when others then
        l_rrtype:= 'X';
        l_custbank:= 'XXXXXXXXXXXX';
    end;
    select custid into l_custid from afmast where acctno = p_txmsg.txfields(c_acctno).value;
    if l_rrtype = 'B' then
        begin
            l_avlamt:= cspks_cfproc.fn_getavlcflimit(l_custbank, l_custid, 'DFMR');
        exception when others then
            l_avlamt:= 0;
        end;
        if p_txmsg.txfields(c_actype).value <> p_txmsg.txfields(c_olntype).value then
            IF NOT l_avlamt >= TO_NUMBER(p_txmsg.txfields(c_amt).value) THEN
                p_err_code := '-100423'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;
    end if;

    if p_txmsg.txfields(c_actype).value <> p_txmsg.txfields(c_olntype).value then
        select 100 - mriratio into l_mriratio from afmast where acctno = p_txmsg.txfields(c_acctno).value;
        for rec_ln in
        (
          select * from (
              select lnt.*, nvl(cf.mnemonic,cf.shortname) cfmnemonic,af.custid cfcustid, odrnum, 'Y' IsSubResource
                  from afmast af, aftype aft, afidtype afid, lntype lnt, cfmast cf
                  where aft.actype = afid.aftype
                      and afid.actype = lnt.actype
                      and af.actype = aft.actype
                      and lnt.custbank = cf.custid(+)
                      and af.acctno = p_txmsg.txfields(c_acctno).value
                      and objname = 'LN.LNTYPE' and lnt.status <> 'N'
              union all
              select lnt.*, nvl(cf.mnemonic,cf.shortname) cfmnemonic,af.custid cfcustid, 999 odrnum, 'N' IsSubResource
                  from afmast af, aftype aft, lntype lnt, cfmast cf
                  where af.actype = aft.actype
                      and lnt.custbank = cf.custid(+)
                      and af.acctno = p_txmsg.txfields(c_acctno).value
                      and aft.lntype = lnt.actype and lnt.status <> 'N'
                      )
          where actype = p_txmsg.txfields(c_actype).value
          order by case when IsSubResource = 'Y' then 0 else 1 end, odrnum
        )
        loop -- rec_ln
            begin
                select greatest(least(af.mrcrlimitmax - mst.dfodamt,nvl(afavlamt,0)/*+mrcrlimit*/) - decode(rec_ln.chksysctrl,'Y',nvl(ln.margin74amt,0),nvl(ln.marginamt,0))
,0)
                    into l_afavlamt
                from cimast mst, afmast af,
                    (select  se.afacctno, nvl(sum(case when rec_ln.chksysctrl = 'Y' then
                                    (se.trade + nvl(sts.receiving,0)) * nvl(rsk.MRRATE,0)/100 * nvl(rsk.MRPRICE,0)
                                    else
                                    (se.trade + nvl(sts.receiving,0)) * nvl(rsk.MRRATE,0)/100 * nvl(rsk.MRPRICE,0)
                                    end)
                            ,0) afavlamt
                    from semast se,
                        (select acctno, sum(qtty-aqtty) receiving
                            from stschd
                            where duetype = 'RS' and deltd <> 'Y' and status <> 'C'
                            group by acctno) sts,
                        (SELECT SB.CODEID,LNB.ACTYPE,
                              LEAST(SEC.MRRATIOLOAN,RATE.MRRATIOLOAN, decode(rec_ln.chksysctrl,'Y',l_mriratio,100))*(case when ismarginallow = 'N' and rec_ln.chksysctrl = 'Y' then 0 else 1 end) MRRATE,
                              LEAST(SEC.MRPRICELOAN,RSK.MRPRICELOAN, decode(rec_ln.chksysctrl,'Y',SB.MARGINREFPRICE,SB.MARGINPRICE)) MRPRICE
                            FROM (select * from lnsebasket
                                      where effdate = (select max(effdate)
                                                      from LNSEBASKET
                                                      where effdate <= (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE')
                                                            and actype = rec_ln.actype
                                                      group by actype)
                                      and actype = rec_ln.actype) LNB,
                                SECBASKET SEC, SECURITIES_INFO SB,
                                SECURITIES_RISK RSK, SECURITIES_RATE RATE
                            WHERE RSK.CODEID=RATE.CODEID AND RATE.FROMPRICE<=SB.FLOORPRICE AND RATE.TOPRICE>SB.FLOORPRICE
                                  AND LNB.BASKETID=SEC.BASKETID AND TRIM(SEC.SYMBOL)=TRIM(SB.SYMBOL)
                                  AND SB.CODEID=RSK.CODEID) rsk
                    where se.acctno = sts.acctno(+)
                    and se.codeid = rsk.codeid(+)
                    and se.afacctno = p_txmsg.txfields(c_acctno).value
                    group by se.afacctno
                ) se,
                (select trfacctno,
                            sum(decode(lnt.chksysctrl,'Y',1,0)*(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) margin74amt,
                            sum((prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd)) marginamt
                    from lnmast ln, lntype lnt
                    where trfacctno = p_txmsg.txfields(c_acctno).value
                    and ln.ftype = 'AF' and ln.actype = rec_ln.actype
                    and ln.actype = lnt.actype
                    group by trfacctno) ln
                where mst.acctno = se.afacctno(+)
                and mst.acctno = ln.trfacctno(+)
                and mst.acctno = af.acctno
                and mst.acctno = p_txmsg.txfields(c_acctno).value;
            exception when others then
                l_afavlamt:=0;
            end;

            IF NOT l_afavlamt >= TO_NUMBER(p_txmsg.txfields(c_amt).value) THEN
                p_err_code := '-100423'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end loop;
    end if;

    -- Giai ngan CL, chi giai ngan khi >= ti le an toan.
    select count(1) into l_count
    from afmast af, aftype aft
    where af.actype = aft.actype and af.acctno = p_txmsg.txfields(c_acctno).value
    and aft.t0lntype = p_txmsg.txfields(c_actype).value;

    if NOT l_count > 0 then
        select mrirate into l_marginrate from afmast where acctno = p_txmsg.txfields(c_acctno).value;

        select count(1) into l_count from v_getsecmarginratio where afacctno = p_txmsg.txfields(c_acctno).value and marginrate >= l_marginrate;
        if not l_count > 0 then
            p_err_code := '-540233'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    else
        select greatest(max(af.advanceline),0)
            into l_advanceline
        from afmast af
        where af.acctno = p_txmsg.txfields(c_acctno).value;
        if not l_advanceline >= to_number(p_txmsg.txfields(c_amt).value) then
            p_err_code := '-540234'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    end if;



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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_currdate date;
l_lnacctno varchar2(100);
l_brid varchar2(10);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_currdate
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    plog.error('5569:'||'c_acctno:'||p_txmsg.txfields(c_acctno).value);
    plog.error('5569:'||'c_actype:'||p_txmsg.txfields(c_actype).value);
    FOR REC IN
        (
        SELECT p_txmsg.txfields(c_acctno).value ACCTNO, LNT.CCYCD, LNT.LNTYPE, LNT.LNCLDR, LNT.PRINFRQ, LNT.PRINPERIOD,
            LNT.INTFRQCD, LNT.INTDAY, LNT.INTPERIOD, LNT.NINTCD, LNT.OINTCD, LNT.RATE1, LNT.RATE2, LNT.RATE3,
            LNT.OPRINFRQ, LNT.OPRINPERIOD, LNT.OINTFRQCD, LNT.OINTDAY, LNT.ORATE1, LNT.ORATE2, LNT.ORATE3,
            LNT.ADVPAY, LNT.ADVPAYFEE, LNT.DRATE, LNT.ACTYPE, LNT.PRINTFRQ1, LNT.PRINTFRQ2, LNT.PRINTFRQ3, LNT.PREPAID,
            LNT.CFRATE1,LNT.CFRATE2,LNT.CFRATE3,LNT.MINTERM,LNT.INTPAIDMETHOD,LNT.AUTOAPPLY,lnt.rrtype,lnt.custbank,lnt.ciacctno, lnt.intovdcd,
            LNT.Bankpaidmethod

        FROM LNTYPE LNT
        WHERE LNT.actype=p_txmsg.txfields(c_actype).value
        and not exists (select 1 from lnmast where trfacctno = p_txmsg.txfields(c_acctno).value and actype = p_txmsg.txfields(c_actype).value)
        )
    LOOP
        l_brid:= SUBSTR(REC.ACCTNO,0,4);
        SELECT SEQ_LNMAST.NEXTVAL
            into l_lnacctno
        FROM DUAL;
        l_lnacctno:=substr('000000' || l_lnacctno,length('000000' || l_lnacctno)-5,6);
        l_lnacctno:=l_brid    || substr(to_char(l_currdate,systemnums.c_date_format),1,2)
                                  || substr(to_char(l_currdate,systemnums.c_date_format),4,2)
                                  || substr(to_char(l_currdate,systemnums.c_date_format),9,2)
                                  || l_lnacctno;
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
          (REC.ACTYPE, l_lnacctno, REC.CCYCD, NULL, NULL, l_currdate,
           l_currdate, NULL, NULL, l_currdate, NULL, l_currdate,
           l_currdate, 'N', '', REC.ACCTNO, 'Y', 'Y', REC.LNTYPE,
           REC.LNCLDR, REC.PRINFRQ, REC.PRINPERIOD, REC.INTFRQCD, REC.INTDAY,
           REC.INTPERIOD, REC.NINTCD, REC.OINTCD, REC.RATE1, REC.RATE2,
           REC.RATE3, REC.OPRINFRQ, REC.OPRINPERIOD, REC.OINTFRQCD,
           REC.OINTDAY, REC.ORATE1, REC.ORATE2, REC.ORATE3, REC.DRATE, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 'I', REC.ADVPAY,
           REC.ADVPAYFEE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'AF',
           REC.PRINTFRQ1, REC.PRINTFRQ2, REC.PRINTFRQ3, REC.PREPAID,
           REC.CFRATE1,REC.CFRATE2,REC.CFRATE3,REC.Minterm,
           rec.intpaidmethod,rec.autoapply,0,0,
           0,0,0,0,0,0,rec.rrtype,rec.custbank,rec.ciacctno, rec.intovdcd,rec.bankpaidmethod);
        plog.error('5569:'||'Create LNMAST.l_lnacctno:'||l_lnacctno);
        plog.error('5569:'||'Create LNMAST.REC.ACTYPE:'||REC.ACTYPE);
        plog.error('5569:'||'Create LNMAST.REC.ACCTNO:'||REC.ACCTNO);
    END LOOP;
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

    l_txmsg               tx.msg_rectype;
    l_CURRDATE date;
    l_Desc varchar2(1000);
    l_EN_Desc varchar2(1000);
    l_OrgDesc varchar2(1000);
    l_EN_OrgDesc varchar2(1000);
    l_err_param varchar2(300);
    l_T0PRINDUE number(20,0);
    l_T0PRINNML number(20,0);
    l_T0PRINOVD number(20,0);
    l_AvlAmt    number(20,0);
    l_FEEOVD number(20,0);
    l_T0INTNMLOVD number(20,0);
    l_INTNMLOVD number(20,0);
    l_T0INTOVDACR number(20,0);
    l_INTOVDACR number(20,0);
    l_FEEDUE number(20,0);
    l_T0INTDUE number(20,0);
    l_INTDUE number(20,0);
    l_FEENML number(20,0);
    l_T0INTNMLACR number(20,0);
    l_INTNMLACR number(20,0);
    l_PRINOVD number(20,0);
    l_PRINDUE number(20,0);
    l_PRINNML number(20,0);
    l_FEEINTNMLOVD number(20,0);
    l_FEEINTNMLACR number(20,0);
    l_FEEINTOVDACR number(20,0);
    l_FEEINTDUE number(20,0);
    l_ADVPAYFEE number(20,0);

    l_count number;
    l_mramt number(20,0);
    l_t0amt number(20,0);
    l_LNACCTNO varchar2(30);
    l_rrtype varchar2(1);
    l_custbank varchar2(30);
    l_ciacctno varchar2(30);
    l_cfmnemonic varchar2(30);

    l_pprinamt number;
    l_pintamt number;
    l_pfeeintamt number;
    l_pfeeintovdacr number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/



    /*
    -- Tra no Margin: 5567
    */
    l_pprinamt:= to_number(p_txmsg.txfields(c_pprinamt).value);
    l_pintamt:= to_number(p_txmsg.txfields(c_pintamt).value);
    l_pfeeintamt:= to_number(p_txmsg.txfields(c_pfeeintamt).value);
    l_pfeeintovdacr:= to_number(p_txmsg.txfields(c_pfeeintovdacr).value);
    l_AvlAmt:= l_pprinamt + l_pintamt + l_pfeeintamt + l_pfeeintovdacr;

    SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='5567';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
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
    l_txmsg.batchname   := '';
    l_txmsg.txdate:=l_CURRDATE;
    l_txmsg.busdate:=l_CURRDATE;
    l_txmsg.tltxcd:='5567';
    l_DESC:=l_OrgDesc;

    for rec_rls in
    (
        select ln.trfacctno, ln.acctno, ls.autoid lnschdid,
                (case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                (ln.ADVPAYFEE) ADVPAYFEE,

                (case when reftype = 'GP' then ls.intovd else 0 end) T0INTNMLOVD,
                (case when reftype = 'GP' then ls.intovdprin else 0 end) T0INTOVDACR,
                (case when reftype = 'GP' then ls.ovd else 0 end) T0PRINOVD,
                (case when reftype = 'GP' then ls.intdue else 0 end) T0INTDUE,
                (case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml else 0 end) T0PRINDUE,
                (case when reftype = 'GP' then ls.intnmlacr else 0 end) T0INTNMLACR,
                (case when reftype = 'GP' then ls.nml else 0 end) T0PRINNML,

                (case when reftype = 'P' then ls.feeovd else 0 end) FEEOVD,
                (case when reftype = 'P' then ls.intovd else 0 end) INTNMLOVD,
                (case when reftype = 'P' then ls.feeintnmlovd else 0 end) FEEINTNMLOVD,
                (case when reftype = 'P' then ls.intovdprin else 0 end) INTOVDACR,
                (case when reftype = 'P' then ls.feeintovdacr else 0 end) FEEINTOVDACR,
                (case when reftype = 'P' then ls.ovd else 0 end) PRINOVD,
                (case when reftype = 'P' then ls.feedue else 0 end) FEEDUE,
                (case when reftype = 'P' then ls.intdue else 0 end) INTDUE,
                (case when reftype = 'P' then ls.feeintdue else 0 end) FEEINTDUE,
                (case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml else 0 end) PRINDUE,
                (case when reftype = 'P' then ls.fee else 0 end) FEENML,
                (case when reftype = 'P' then ls.intnmlacr else 0 end) INTNMLACR,
                (case when reftype = 'P' then ls.feeintnmlacr else 0 end) FEEINTNMLACR,
                (case when reftype = 'P' then ls.nml else 0 end) PRINNML

            from lnmast ln, lnschd ls
            where ln.trfacctno = p_txmsg.txfields(c_acctno).value and ls.reftype in ('P','GP')
            and ls.autoid = p_txmsg.txfields(c_lnschdid).value
            and ls.acctno = ln.acctno

    )
    loop
        exit when l_AvlAmt =0;
        --So tien phai tra cho tung khoan
        -- Bao lanh
        --01.T0INTNMLOVD
        l_T0INTNMLOVD := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
            l_T0INTNMLOVD := round(least(l_AvlAmt, l_pintamt, rec_rls.T0INTNMLOVD),0);
            l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            l_pintamt:= l_pintamt - l_T0INTNMLOVD;
        End If;
        --02.T0INTOVDACR
        l_T0INTOVDACR := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
            l_T0INTOVDACR := round(least(l_AvlAmt, l_pintamt, rec_rls.T0INTOVDACR),0);
            l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            l_pintamt:= l_pintamt - l_T0INTOVDACR;
        End If;
        --03.T0PRINOVD
        l_T0PRINOVD := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_T0PRINOVD := round(least(l_AvlAmt, l_pprinamt, rec_rls.T0PRINOVD),0);
            l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            l_pprinamt:= l_pprinamt - l_T0PRINOVD;
        end if;
        --04.T0INTDUE
        l_T0INTDUE := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
             l_T0INTDUE := round(least(l_AvlAmt, l_pintamt, rec_rls.T0INTDUE),0);
             l_AvlAmt := l_AvlAmt - l_T0INTDUE;
             l_pintamt:= l_pintamt - l_T0INTDUE;
        End If;
        --05.T0PRINDUE
        l_T0PRINDUE := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_T0PRINDUE := round(least(l_AvlAmt, rec_rls.T0PRINDUE),0);
            l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            l_pprinamt:= l_pprinamt - l_T0PRINDUE;
        End If;
        --06.T0INTNMLACR
        l_T0INTNMLACR := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
            l_T0INTNMLACR := round(least(l_AvlAmt, l_pintamt, rec_rls.T0INTNMLACR),0);
            l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            l_pintamt:= l_pintamt - l_T0INTNMLACR;
        End If;
        --07.T0PRINNML
        l_T0PRINNML := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_T0PRINNML := round(least(l_AvlAmt, l_pprinamt, rec_rls.T0PRINNML),0);
            l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            l_pprinamt:= l_pprinamt - l_T0PRINNML;
        End If;

        -- CL
        -- Phi
        --08.FEEINTNMLOVD
        l_FEEINTNMLOVD := 0;
        If l_AvlAmt > 0 and l_pfeeintamt > 0 Then
            l_FEEINTNMLOVD := round(least(l_AvlAmt, l_pfeeintamt, rec_rls.FEEINTNMLOVD),0);
            l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            l_pfeeintamt:= l_pfeeintamt - l_FEEINTNMLOVD;
        End If;
        --09.FEEINTDUE
        l_FEEINTDUE := 0;
        If l_AvlAmt > 0 and l_pfeeintamt > 0 Then
             l_FEEINTDUE := round(least(l_AvlAmt, l_pfeeintamt, rec_rls.FEEINTDUE),0);
             l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
             l_pfeeintamt:= l_pfeeintamt - l_FEEINTDUE;
        End If;
        --10.FEEINTNMLACR
        l_FEEINTNMLACR := 0;
        If l_AvlAmt > 0 and l_pfeeintamt > 0 Then
            l_FEEINTNMLACR := round(least(l_AvlAmt, l_pfeeintamt, rec_rls.FEEINTNMLACR),0);
            l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            l_pfeeintamt:= l_pfeeintamt - l_FEEINTNMLACR;
        End If;

        -- Lai

        --11.INTNMLOVD
        l_INTNMLOVD := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
            l_INTNMLOVD := round(least(l_AvlAmt, l_pintamt, rec_rls.INTNMLOVD),0);
            l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            l_pintamt:= l_pintamt - l_INTNMLOVD;
        End If;
        --12.INTOVDACR
        l_INTOVDACR := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
             l_INTOVDACR := round(least(l_AvlAmt, l_pintamt, rec_rls.INTOVDACR),0);
             l_AvlAmt := l_AvlAmt - l_INTOVDACR;
             l_pintamt:= l_pintamt - l_INTOVDACR;
        End If;
        --13.INTDUE
        l_INTDUE := 0;
        If l_AvlAmt > 0 and l_pintamt> 0 Then
             l_INTDUE := round(least(l_AvlAmt, l_pintamt, rec_rls.INTDUE),0);
             l_AvlAmt := l_AvlAmt - l_INTDUE;
             l_pintamt:= l_pintamt - l_INTDUE;
        End If;
        --14.INTNMLACR
        l_INTNMLACR := 0;
        If l_AvlAmt > 0 and l_pintamt > 0 Then
            l_INTNMLACR := round(least(l_AvlAmt,l_pintamt, rec_rls.INTNMLACR),0);
            l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            l_pintamt:= l_pintamt - l_INTNMLACR;
        End If;

        --15.FEEOVD
        l_FEEOVD := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_FEEOVD := round(least(l_AvlAmt,l_pprinamt, rec_rls.FEEOVD),0);
            l_AvlAmt := l_AvlAmt - l_FEEOVD;
            l_pprinamt:= l_pprinamt - l_FEEOVD;
        End If;
        --16.FEEDUE
        l_FEEDUE := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_FEEDUE := round(least(l_AvlAmt, l_pprinamt, rec_rls.FEEDUE),0);
            l_AvlAmt := l_AvlAmt - l_FEEDUE;
            l_pprinamt:= l_pprinamt - l_FEEDUE;
        End If;
        --17.FEENML
        l_FEENML := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_FEENML := round(least(l_AvlAmt, l_pprinamt, rec_rls.FEENML),0);
            l_AvlAmt := l_AvlAmt - l_FEENML;
            l_pprinamt:= l_pprinamt - l_FEENML;
        End If;

        -- Goc
        --18.PRINOVD
        l_PRINOVD := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
            l_PRINOVD := round(least(l_AvlAmt, l_pprinamt, rec_rls.PRINOVD),0);
            l_AvlAmt := l_AvlAmt - l_PRINOVD;
            l_pprinamt:= l_pprinamt - l_PRINOVD;
        End If;
        --19.PRINDUE
        l_PRINDUE := 0;
        If l_AvlAmt > 0 and l_pprinamt > 0 Then
           l_PRINDUE := round(least(l_AvlAmt, l_pprinamt, rec_rls.PRINDUE),0);
           l_AvlAmt := l_AvlAmt - l_PRINDUE;
           l_pprinamt:= l_pprinamt - l_PRINDUE;
        End If;
        --20.PRINNML
        l_PRINNML := 0;
        if rec_rls.PRINNML > 0 then
            If l_AvlAmt > 0 and l_pprinamt > 0 Then
                 l_PRINNML := trunc(least(rec_rls.PRINNML, least(l_AvlAmt,l_pprinamt) * 1 / (1+rec_rls.ADVPAYFEE/100)));
                 l_AvlAmt := l_AvlAmt - l_PRINNML;
                 l_pprinamt:= l_pprinamt - l_PRINNML;
            End If;
        end if;
        --21.ADVPAYFEE
        l_ADVPAYFEE := 0;
        if l_PRINNML > 0 then
            If l_AvlAmt > 0 and l_pprinamt > 0 Then
                 l_ADVPAYFEE := rec_rls.FINANCETYPE * trunc(least(least(l_AvlAmt,l_pprinamt), l_PRINNML * rec_rls.ADVPAYFEE / 100 ),0);
                 l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                 l_pprinamt:= l_pprinamt - l_ADVPAYFEE;
            End If;
        end if;

        -- Lai & Phi
        --22.FEEINTOVDACR
        l_FEEINTOVDACR := 0;
        If l_AvlAmt > 0 and l_pfeeintovdacr > 0 Then
             l_FEEINTOVDACR := round(least(l_AvlAmt, l_pfeeintovdacr, rec_rls.FEEINTOVDACR),0);
             l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
             l_pfeeintovdacr:= l_pfeeintovdacr - l_FEEINTOVDACR;
        End If;

        --set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
        l_txmsg.brid        := substr(p_txmsg.txfields(c_acctno).value,1,4);


        --Set cac field giao dich
        --01   C   AUTOID
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec_rls.lnschdid;

        --03   C   ACCTNO
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec_rls.acctno;

        --05   C   CIACCTNO
        l_txmsg.txfields ('05').defname   := 'CIACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := p_txmsg.txfields(c_acctno).value;

        --09   N   T0ODAMT
        l_txmsg.txfields ('09').defname   := 'T0ODAMT';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := 0;

         --45   N   PRINAMT
        l_txmsg.txfields ('45').defname   := 'PRINAMT';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := l_T0PRINOVD + l_T0PRINNML + l_T0PRINDUE + l_PRINOVD + l_PRINDUE + l_PRINNML;
        --46   N   INTAMT
        l_txmsg.txfields ('46').defname   := 'INTAMT';
        l_txmsg.txfields ('46').TYPE      := 'N';
        l_txmsg.txfields ('46').VALUE     := l_ADVPAYFEE + l_FEEOVD + l_T0INTNMLOVD + l_INTNMLOVD + l_FEEINTNMLOVD+ l_FEEDUE + l_T0INTDUE + l_INTDUE + l_FEEINTDUE+ l_T0INTOVDACR + l_INTOVDACR + l_FEEINTOVDACR+ l_FEENML + l_T0INTNMLACR + l_INTNMLACR+l_FEEINTNMLACR ;

        --47   N   ADVFEE
        l_txmsg.txfields ('47').defname   := 'ADVFEE';
        l_txmsg.txfields ('47').TYPE      := 'N';
        l_txmsg.txfields ('47').VALUE     := rec_rls.FINANCETYPE * round(rec_rls.ADVPAYFEE,0);

        --60   N   PT0PRINOVD
        l_txmsg.txfields ('60').defname   := 'PT0PRINOVD';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').VALUE     := l_T0PRINOVD;
        --61   N   PT0PRINDUE
        l_txmsg.txfields ('61').defname   := 'PT0PRINDUE';
        l_txmsg.txfields ('61').TYPE      := 'N';
        l_txmsg.txfields ('61').VALUE     := l_T0PRINDUE;
        --62   N   PT0PRINNML
        l_txmsg.txfields ('62').defname   := 'PT0PRINNML';
        l_txmsg.txfields ('62').TYPE      := 'N';
        l_txmsg.txfields ('62').VALUE     := l_T0PRINNML;
        --63   N   PPRINOVD
        l_txmsg.txfields ('63').defname   := 'PPRINOVD';
        l_txmsg.txfields ('63').TYPE      := 'N';
        l_txmsg.txfields ('63').VALUE     := l_PRINOVD;
        --64   N   PPRINDUE
        l_txmsg.txfields ('64').defname   := 'PPRINDUE';
        l_txmsg.txfields ('64').TYPE      := 'N';
        l_txmsg.txfields ('64').VALUE     := l_PRINDUE;
        --65   N   PPRINNML
        l_txmsg.txfields ('65').defname   := 'PT0PRINOVD';
        l_txmsg.txfields ('65').TYPE      := 'N';
        l_txmsg.txfields ('65').VALUE     := l_PRINNML;
        --70   N   PFEEOVD
        l_txmsg.txfields ('70').defname   := 'PFEEOVD';
        l_txmsg.txfields ('70').TYPE      := 'N';
        l_txmsg.txfields ('70').VALUE     := l_FEEOVD;
        --71   N   PT0INTNMLOVD
        l_txmsg.txfields ('71').defname   := 'PT0INTNMLOVD';
        l_txmsg.txfields ('71').TYPE      := 'N';
        l_txmsg.txfields ('71').VALUE     := l_T0INTNMLOVD;
        --72   N   PINTNMLOVD
        l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
        l_txmsg.txfields ('72').TYPE      := 'N';
        l_txmsg.txfields ('72').VALUE     := l_INTNMLOVD;
        --52   N   PFEEINTNMLOVD
        l_txmsg.txfields ('52').defname   := 'PFEEINTNMLOVD';
        l_txmsg.txfields ('52').TYPE      := 'N';
        l_txmsg.txfields ('52').VALUE     := l_FEEINTNMLOVD;
        --73   N   PT0INTOVDACR
        l_txmsg.txfields ('73').defname   := 'PT0INTOVDACR';
        l_txmsg.txfields ('73').TYPE      := 'N';
        l_txmsg.txfields ('73').VALUE     := l_T0INTOVDACR;
        --74   N   PINTOVDACR
        l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
        l_txmsg.txfields ('74').TYPE      := 'N';
        l_txmsg.txfields ('74').VALUE     := l_INTOVDACR;
        --54   N   PFEEINTOVDACR
        l_txmsg.txfields ('54').defname   := 'PFEEINTOVDACR';
        l_txmsg.txfields ('54').TYPE      := 'N';
        l_txmsg.txfields ('54').VALUE     := l_FEEINTOVDACR;
        --75   N   PFEEDUE
        l_txmsg.txfields ('75').defname   := 'PFEEDUE';
        l_txmsg.txfields ('75').TYPE      := 'N';
        l_txmsg.txfields ('75').VALUE     := l_FEEDUE;
        --76   N   PT0INTDUE
        l_txmsg.txfields ('76').defname   := 'PT0INTDUE';
        l_txmsg.txfields ('76').TYPE      := 'N';
        l_txmsg.txfields ('76').VALUE     := l_T0INTDUE;
        --77   N   PINTDUE
        l_txmsg.txfields ('77').defname   := 'PINTDUE';
        l_txmsg.txfields ('77').TYPE      := 'N';
        l_txmsg.txfields ('77').VALUE     := l_INTDUE;
        --57   N   PFEEINTDUE
        l_txmsg.txfields ('57').defname   := 'PFEEINTDUE';
        l_txmsg.txfields ('57').TYPE      := 'N';
        l_txmsg.txfields ('57').VALUE     := l_FEEINTDUE;
        --78   N   PFEE
        l_txmsg.txfields ('78').defname   := 'PFEE';
        l_txmsg.txfields ('78').TYPE      := 'N';
        l_txmsg.txfields ('78').VALUE     := l_FEENML;
        --79   N   PT0INTNMLACR
        l_txmsg.txfields ('79').defname   := 'PT0INTNMLACR';
        l_txmsg.txfields ('79').TYPE      := 'N';
        l_txmsg.txfields ('79').VALUE     := l_T0INTNMLACR;
        --80   N   PINTNMLACR
        l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').VALUE     := l_INTNMLACR;
        --50   N   PFEEINTNMLACR
        l_txmsg.txfields ('50').defname   := 'PFEEINTNMLACR';
        l_txmsg.txfields ('50').TYPE      := 'N';
        l_txmsg.txfields ('50').VALUE     := l_FEEINTNMLACR;
        --81   N   ADVPAYAMT
        l_txmsg.txfields ('81').defname   := 'ADVPAYAMT';
        l_txmsg.txfields ('81').TYPE      := 'N';
        l_txmsg.txfields ('81').VALUE     := l_PRINNML;
        --82   N   FEEAMT
        l_txmsg.txfields ('82').defname   := 'FEEAMT';
        l_txmsg.txfields ('82').TYPE      := 'N';
        l_txmsg.txfields ('82').VALUE     := Round(l_ADVPAYFEE, 0); --Round(l_PRINNML * rec_rls.ADVPAYFEE / 100, 0);
        --83   N   PAYAMT
        l_txmsg.txfields ('83').defname   := 'PAYAMT';
        l_txmsg.txfields ('83').TYPE      := 'N';
        l_txmsg.txfields ('83').VALUE     := l_T0PRINOVD + l_T0PRINNML + l_T0PRINDUE + l_PRINOVD + l_PRINDUE + l_PRINNML + l_ADVPAYFEE + l_FEEOVD + l_T0INTNMLOVD + l_INTNMLOVD + l_FEEINTNMLOVD+ l_FEEDUE + l_T0INTDUE + l_INTDUE + l_FEEINTDUE + l_T0INTOVDACR + l_INTOVDACR + l_FEEINTOVDACR + l_FEENML + l_T0INTNMLACR + l_INTNMLACR + l_FEEINTNMLACR;
        --plog.debug(pkgctx, 'Balance check:' || l_txmsg.txfields ('83').VALUE);
        --20    N   FINANCETYPE
        l_txmsg.txfields ('20').defname   := 'FINANCETYPE';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := rec_rls.FINANCETYPE;

        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE :=l_DESC;

        BEGIN
            IF txpks_#5567.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 5567: ' || p_err_code
               );
               ROLLBACK;
               RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        END;
    end loop;



    /*
    -- Giai ngan Margin: 5566
    */
    select ln.acctno, ln.rrtype, ln.custbank, ln.ciacctno, nvl(cf.mnemonic,cf.shortname) cfmnemonic
        into l_LNACCTNO, l_rrtype, l_custbank,  l_ciacctno, l_cfmnemonic
    from lnmast ln, cfmast cf where ln.custbank = cf.custid(+) and ln.actype = p_txmsg.txfields(c_actype).value
    and ln.trfacctno = p_txmsg.txfields(c_acctno).value and ln.STATUS NOT IN ('P','R','C') AND ln.FTYPE='AF';

    select count(1) into l_count
    from afmast af, aftype aft
    where af.actype = aft.actype and af.acctno = p_txmsg.txfields(c_acctno).value
    and aft.t0lntype = p_txmsg.txfields(c_actype).value;

    if l_count > 0 then
        l_t0amt:=to_number(p_txmsg.txfields(c_amt).value);
        l_mramt:=0;
    else
        l_t0amt:=0;
        l_mramt:=to_number(p_txmsg.txfields(c_amt).value);
    end if;

    SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='5566';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
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
    l_txmsg.batchname   := '';
    l_txmsg.txdate:=l_CURRDATE;
    l_txmsg.busdate:=l_CURRDATE;
    l_txmsg.tltxcd:='5566';


    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_txmsg.txfields(c_acctno).value,1,4);

    select 'Giai ngan '||decode(l_rrtype,'C',cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'),'B',nvl(l_cfmnemonic,''),'')||decode(l_count,0,'/CL/','/BL/')||to_char(l_CURRDATE,'DD.MM.RRRR')||'/' || to_char(l_mramt+l_t0amt) || ' VND'
        into l_OrgDesc
        from dual;
    --Set cac field giao dich
    --03   C   ACCTNO
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := l_LNACCTNO;

    --05   C   ACCTNO
    l_txmsg.txfields ('05').defname   := 'ACCTNO';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_txmsg.txfields(c_acctno).value;

    --10   N   MRODAMT
    l_txmsg.txfields ('10').defname   := 'MRODAMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := l_mramt;
    --11   N   T0ODAMT
    l_txmsg.txfields ('11').defname   := 'T0ODAMT';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := l_t0amt;
    --20    N   FINANCETYPE
    l_txmsg.txfields ('20').defname   := 'FINANCETYPE';
    l_txmsg.txfields ('20').TYPE      := 'N';
    l_txmsg.txfields ('20').VALUE     := '1';
    --30   C   DESC
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := l_OrgDesc;
    --90   N   ISCIDRAWNDOWN
    l_txmsg.txfields ('90').defname   := 'ISCIDRAWNDOWN';
    l_txmsg.txfields ('90').TYPE      := 'N';
    l_txmsg.txfields ('90').VALUE     := case when l_rrtype = 'O' then 1 else 0 end;
    --91   N   CIACCTNO
    l_txmsg.txfields ('91').defname   := 'CIACCTNO';
    l_txmsg.txfields ('91').TYPE      := 'N';
    l_txmsg.txfields ('91').VALUE     := case when l_rrtype = 'O' then l_ciacctno else '' end;

    BEGIN
        IF txpks_#5566.fn_batchtxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 5566: ' || p_err_code
           );
           ROLLBACK;
           RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END;

    --Luu lai thong tin xuat bao cao giai ngan
    if not fn_gen_cl_drawndown_report then
        p_err_code:='-540229';
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

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
         plog.init ('TXPKS_#5569EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#5569EX;

/
