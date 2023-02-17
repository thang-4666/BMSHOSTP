SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5568ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#5568EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      07/05/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#5568ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_rlstxnum         CONSTANT CHAR(2) := '40';
   c_rlstxdate        CONSTANT CHAR(2) := '41';
   c_lnacctno         CONSTANT CHAR(2) := '03';
   c_lnschdid         CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_actype           CONSTANT CHAR(2) := '06';
   c_amt              CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count number;
l_rrtype varchar2(100);
l_custbank varchar2(100);
l_custid varchar2(10);
l_avlamt number;
l_afavlamt number;
l_currdate  date;
l_mriratio number;
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
    -- Giao dich con phai la trong ngay hay khong.
    select count(1) into l_count
    from tllog
    where txnum = p_txmsg.txfields(c_rlstxnum).value
    and txdate = p_txmsg.txfields(c_rlstxdate).value
    and deltd <> 'Y';
    if l_count = 0 then
        p_err_code := '-540226'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    -- Mon giai ngan con nguyen hay khong.
    select count(1) into l_count
    from lnschd
    where autoid = p_txmsg.txfields(c_lnschdid).value and (paid > 0 or intpaid > 0 or feeintpaid > 0);
    if l_count > 0 then
        p_err_code := '-540227'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    -- Mon vay chuyen doi moi.
    select count(1) into l_count
    from afmast af, aftype aft
    where af.actype = aft.actype
    and af.acctno = p_txmsg.txfields(c_acctno).value
    and (aft.t0lntype = p_txmsg.txfields(c_actype).value
    or aft.lntype = p_txmsg.txfields(c_actype).value
    or exists (select 1 from afidtype afi where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = p_txmsg.txfields(c_actype).value));
    if l_count = 0 then
        p_err_code := '-540228'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    select count(1) into l_count
    from lnmast
    where trfacctno = p_txmsg.txfields(c_acctno).value
    and acctno = p_txmsg.txfields(c_lnacctno).value;
    if l_count = 0 then
        p_err_code := '-540209'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
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

        IF NOT l_avlamt >= TO_NUMBER(p_txmsg.txfields(c_amt).value) THEN
            p_err_code := '-100423'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;

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
            select greatest(least(af.mrcrlimitmax - mst.dfodamt,nvl(afavlamt,0)/*+mrcrlimit*/) - decode(rec_ln.chksysctrl,'Y',nvl(ln.margin74amt,0),nvl(ln.marginamt,0)),0)
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
    l_err_param varchar2(1000);
    l_txmsg tx.msg_rectype;
    l_LNACCTNO varchar2(100);
    l_CurrDate date;
    l_desc varchar2(1000);
    l_EN_desc varchar2(1000);
    l_rrtype varchar2(100);

    l_mramt number;
    l_t0amt number;
    l_count number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    /*-- Huy giao dich giai ngan cu 5566:*/
    IF txpks_#5566.fn_txrevert (p_txmsg.txfields(c_rlstxnum).value,
                                to_date(p_txmsg.txfields(c_rlstxdate).value, systemnums.c_date_format),
                                p_err_code,
                                l_err_param
       ) <> systemnums.c_success
    THEN
       plog.debug (pkgctx,
                   'got error when rollback 5566: ' || p_err_code
       );
        ROLLBACK;
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    delete lnschd where autoid = p_txmsg.txfields(c_lnschdid).value;
    delete lnschdlog where autoid = p_txmsg.txfields(c_lnschdid).value;
    delete rlsrptlog_eod where lnschdid = p_txmsg.txfields(c_lnschdid).value;


    /*-- Tao moi giao dich giai ngan 5566:*/
    select acctno, rrtype
        into l_LNACCTNO, l_rrtype
    from lnmast
    where trfacctno = p_txmsg.txfields(c_acctno).value
    and ftype = 'AF'
    and actype = p_txmsg.txfields(c_actype).value;

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

    SELECT TXDESC,EN_TXDESC into l_desc, l_EN_desc FROM  TLTX WHERE TLTXCD='5566';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CurrDate
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
    l_txmsg.batchname   := 'LNDRAWNDOWN';
    l_txmsg.txdate:=l_CURRDATE;
    l_txmsg.busdate:=l_CURRDATE;
    l_txmsg.tltxcd:='5566';

    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_txmsg.txfields(c_acctno).value,1,4);

    l_desc:= p_txmsg.txdesc;

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
    l_txmsg.txfields ('30').VALUE     := l_DESC;
    --90   N   ISCIDRAWNDOWN
    l_txmsg.txfields ('90').defname   := 'ISCIDRAWNDOWN';
    l_txmsg.txfields ('90').TYPE      := 'N';
    l_txmsg.txfields ('90').VALUE     := case when l_rrtype = 'O' then 1 else 0 end;
    --91   N   CIACCTNO
    l_txmsg.txfields ('91').defname   := 'CIACCTNO';
    l_txmsg.txfields ('91').TYPE      := 'N';
    l_txmsg.txfields ('91').VALUE     := case when l_rrtype = 'O' then p_txmsg.txfields(c_acctno).value else '' end;

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
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
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
         plog.init ('TXPKS_#5568EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#5568EX;

/
