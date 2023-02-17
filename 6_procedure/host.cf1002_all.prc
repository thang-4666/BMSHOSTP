SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1002_ALL" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2
  )
IS
--

-- BAO CAO Sao ke tien cua tai khoan khach hang
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- TUNH        13-05-2010           CREATED
--
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate date;
   v_ToDate date;
   v_CurrDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   v_TLID varchar2(4);

BEGIN


V_STROPTION := OPT;
IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(PV_BRID,1,2) || '__' ;
else
    V_STRBRID:=PV_BRID;
END IF;

v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
v_ToDate:= to_date(T_DATE,'DD/MM/RRRR');
v_CustodyCD:= upper(replace(pv_custodycd,'.',''));
v_AFAcctno:= upper(replace(PV_AFACCTNO,'.',''));


if v_CustodyCD = 'ALL' or v_CustodyCD is null then
    v_CustodyCD := '%';
else
    v_CustodyCD := v_CustodyCD;
end if;

if v_AFAcctno = 'ALL' or v_AFAcctno is null then
    v_AFAcctno := '%';
else
    v_AFAcctno := v_AFAcctno;
end if;


select to_date(VARVALUE,'DD/MM/YYYY') into v_CurrDate from sysvar where grname='SYSTEM' and varname='CURRDATE';

OPEN PV_REFCURSOR FOR
select cf.custid, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.mobile, cf.address,
    tr.autoid, tr.afacctno, tr.busdate, tr.txdesc, nvl(tr.symbol,' ') tran_symbol,
    nvl(se_credit_amt,0) se_credit_amt, nvl(se_debit_amt,0) se_debit_amt,
    nvl(ci_credit_amt,0) ci_credit_amt, nvl(ci_debit_amt,0) ci_debit_amt,
    ci_balance, ci_balance - nvl(ci_total_move_frdt_amt,0)  ci_begin_bal,
    CI_RECEIVING, CI_RECEIVING - nvl(ci_RECEIVING_move,0) ci_receiving_bal,
    CI_EMKAMT, CI_EMKAMT - nvl(ci_EMKAMT_move,0) ci_EMKAMT_bal,
    nvl(secu.od_buy_secu,0) od_buy_secu,
    tr.txnum, tr.tltx_name, tr.tltxcd

from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
inner join afmast af on cf.custid = af.custid
inner join
(
    -- Tong so du CI hien tai group by TK luu ky
    select cf.custid, cf.custodycd, sum(balance+EMKAMT) ci_balance,
        sum(RECEIVING) CI_RECEIVING,
        sum(EMKAMT) CI_EMKAMT
    from cfmast cf, afmast af, cimast ci
    where cf.custid = af.custid and af.acctno = ci.afacctno
        and cf.custodycd like v_CustodyCD
        and af.acctno like v_AFAcctno
    group by  cf.custid, cf.custodycd
) cibal on cf.custid = cibal.custid

left join
(
    select tci.custid, tci.custodycd, tci.afacctno, tl.autoid, tci.txtype ,
        tci.busdate, tl.txdesc, '' symbol, 0 se_credit_amt, 0 se_debit_amt, ci_credit_amt, ci_debit_amt,
        tl.txnum, tx.txdesc tltx_name, tl.tltxcd
    from vw_tllog_all tl, tltx tx,
    (
        -- Danh sach giao dich CI: tu From Date den ToDate
        select cf.custid, cf.custodycd, ci.afacctno, tr.txnum, tr.txdate, busdate,
            max(txtype) txtype,
            sum(case when apptx.txtype = 'D' then tr.namt else 0 end) ci_debit_amt,
            sum(case when apptx.txtype = 'C' then tr.namt else 0 end) ci_credit_amt
        from cfmast cf, afmast af, cimast ci, vw_tllog_citran_all tr, apptx
        where cf.custid = af.custid and af.acctno = ci.afacctno and ci.acctno = tr.acctno
            and tr.txcd = apptx.txcd
            and tr.busdate between v_FromDate and v_ToDate
            and cf.custodycd like v_CustodyCD
            and af.acctno like v_AFAcctno
            and apptx.field in ('BALANCE','EMKAMT') and apptx.txtype in ('D','C')
            and apptx.apptype = 'CI'
        group by cf.custid, cf.custodycd, ci.afacctno, tr.txnum, tr.txdate, busdate
        having sum(case when apptx.txtype = 'D' then tr.namt else -tr.namt end) <> 0
    ) tci
    where tl.txdate = tci.txdate and tl.txnum = tci.txnum and tl.tltxcd = tx.tltxcd
) tr on cf.custid = tr.custid and af.acctno = tr.afacctno

left join
(
    -- Tong phat sinh CI tu From date den ngay hom nay
    select cf.custid, cf.custodycd,
        sum(case when apptx.txtype = 'D' then -tr.namt else tr.namt end) ci_total_move_frdt_amt
    from cfmast cf, afmast af, cimast ci, vw_tllog_citran_all tr, apptx
    where cf.custid = af.custid and af.acctno = ci.afacctno and ci.acctno = tr.acctno
        and tr.txcd = apptx.txcd
        and tr.busdate >= v_FromDate
        and cf.custodycd like v_CustodyCD
        and af.acctno like v_AFAcctno
        and apptx.field in ('BALANCE','EMKAMT') and apptx.txtype in ('D','C')
        and apptx.apptype = 'CI'
    group by cf.custid, cf.custodycd
) ci_move_fromdt on cf.custid = ci_move_fromdt.custid

left join
(
    -- Tong phat sinh CI.RECEIVING tu Todate + 1 den ngay hom nay
    select cf.custid, cf.custodycd,
        sum(
            case when field = 'RECEIVING' then
                case when apptx.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_RECEIVING_move,

        sum(
            case when field = 'EMKAMT' then
                case when apptx.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_EMKAMT_move
    from cfmast cf, afmast af, cimast ci, vw_tllog_citran_all tr, apptx
    where cf.custid = af.custid and af.acctno = ci.afacctno and ci.acctno = tr.acctno
        and tr.txcd = apptx.txcd
        and tr.busdate > v_ToDate
        and cf.custodycd like v_CustodyCD
        and af.acctno like v_AFAcctno
        and apptx.field in ('RECEIVING','EMKAMT') and apptx.txtype in ('D','C')
        and apptx.apptype = 'CI'
    group by cf.custid, cf.custodycd
) ci_RECEIV on cf.custid = ci_RECEIV.custid

left join
(
    select cf.custid, cf.custodycd,SUM(secureamt + advamt) od_buy_secu
    from v_getbuyorderinfo V, afmast af, cfmast cf
    where v.afacctno = af.acctno and af.custid = cf.custid
        and cf.custodycd like v_CustodyCD and af.acctno like v_AFAcctno
    group by cf.custid, cf.custodycd
) secu on cf.custid = secu.custid
where
    cf.custodycd like v_CustodyCD
    -- and exists (select gu.grpid from tlgrpusers gu where cf.careby = gu.grpid and gu.tlid = v_TLID)   -- check careby
order by tr.busdate, tr.txtype asc, tr.autoid;      -- Chu y: Khong thay doi thu tu Order by

EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;  -- PROCEDURE

 
 
 
 
/
