SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1000 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2,
   TLID            IN VARCHAR2,
   PV_AFTYPE        IN     VARCHAR2
  )
IS
--

-- BAO CAO Sao ke tien cua tai khoan khach hang
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- TUNH        13-05-2010           CREATED
-- TUNH        31-08-2010           Lay dien giai chi tiet o cac table xxTRAN
-- HUNG.LB     03-11-2010           6.3.1
-- CHAUNH      11-04-2012           them tien mua tra cham
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate date;
   v_ToDate date;
   v_CurrDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   v_TLID varchar2(4);
   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;
   V_STRAFTYPE   varchar2(50);

BEGIN

-- return;

v_TLID := TLID;
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

if v_AFAcctno = 'ALL' or v_AFAcctno is null then
    v_AFAcctno := '%';
else
    v_AFAcctno := v_AFAcctno;
end if;

      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;

---------------------------------------------------------------------------------
select to_date(VARVALUE,'DD/MM/YYYY') into v_CurrDate from sysvar where grname='SYSTEM' and varname='CURRDATE';


OPEN PV_REFCURSOR FOR
select 0 tmtracham, v_AFAcctno v_AFAcctno,
    cf.custid, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.mobile, cf.address,
    tr.autoid, tr.afacctno, tr.busdate, nvl(tr.symbol,' ') tran_symbol,
    nvl(se_credit_amt,0) se_credit_amt, nvl(se_debit_amt,0) se_debit_amt,
    nvl(ci_credit_amt,0) ci_credit_amt, nvl(ci_debit_amt,0) ci_debit_amt,
    ci_balance, ci_balance - nvl(ci_total_move_frdt_amt,0)  ci_begin_bal,
    CI_RECEIVING, CI_RECEIVING - nvl(ci_RECEIVING_move,0) ci_receiving_bal,
    CI_EMKAMT, CI_EMKAMT - nvl(ci_EMKAMT_move,0) ci_EMKAMT_bal,
    nvl(secu.od_buy_secu,0) od_buy_secu,
    CI_DFDEBTAMT - nvl(ci_DFDEBTAMT_move,0) ci_DFDEBTAMT_bal,
    case when tr.tltxcd = '1143' and tr.txcd = '0077' then utf8nums.c_const_RPT_CF1000_1143
         when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then utf8nums.c_const_RPT_CF1000_1153
         when tr.tltxcd = '2266' then utf8nums.c_const_RPT_CF1000_2266
         else to_char(tr.txdesc)
    end txdesc

from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND custodycd = v_CustodyCD) cf
inner join (SELECT AF.* FROM AFMAST AF,AFTYPE AFT  WHERE  AF.ACTYPE=AFT.ACTYPE
                   AND AF.ACCTNO LIKE v_AFAcctno AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE ) af on cf.custid = af.custid
inner join
(
    -- Tong so du CI hien tai group by TK luu ky
    select cf.custid, cf.custodycd,
        sum(balance ) ci_balance,
        sum(RECEIVING ) CI_RECEIVING,
        sum(EMKAMT ) CI_EMKAMT,
        sum( DFDEBTAMT ) CI_DFDEBTAMT
    from cfmast cf, afmast af, cimast ci, aftype aft
    where cf.custid = af.custid and af.acctno = ci.afacctno
        and af.actype=aft.actype
        and aft.producttype like V_STRAFTYPE
        and cf.custodycd = v_CustodyCD
        and af.acctno like v_AFAcctno
    group by  cf.custid, cf.custodycd
) cibal on cf.custid = cibal.custid
left join
(
    -- Toan bo phat sinh CK, CI tu FromDate den Todate
    -- Toan bo phat sinh CK, CI tu FromDate den Todate
    select max(tse.autoid) orderid, tse.custid, tse.custodycd, tse.afacctno, max(tse.tllog_autoid) autoid, max(tse.txtype) txtype, max(tse.txcd) txcd ,
        tse.busdate,
      --  MAX(CASE WHEN TLTXCD = '3350' THEN tse.trdesc || ' ' || tse.txdesc ELSE nvl(tse.trdesc,tse.txdesc) END) txdesc,
       MAX(CASE WHEN TLTXCD = '3350' THEN  tse.txdesc ELSE nvl(tse.trdesc,tse.txdesc) END) txdesc,
       -- max( nvl(tse.trdesc,tse.txdesc))txdesc,
        to_char(max(tse.symbol)) symbol,
        sum(case when tse.txtype = 'C' and tse.field in ('TRADE','MORTAGE','BLOCKED') then tse.namt else 0 end) se_credit_amt,
        sum(case when tse.txtype = 'D' AND tse.field in ('TRADE','MORTAGE','BLOCKED') then tse.namt
                WHEN tltxcd = '2248' AND tse.field = 'DTOCLOSE' THEN tse.namt
                when tltxcd = '2266' AND tse.field = 'WITHDRAW' THEN tse.namt
                    when tltxcd = '2201' AND tse.field = 'WITHDRAW' THEN tse.namt
                else 0 end) se_debit_amt,
        0 ci_credit_amt, 0 ci_debit_amt,
        max(tse.tltxcd) tltxcd, max(tse.trdesc) trdesc
    from vw_setran_gen tse, aftype aft,afmast af
    where tse.busdate between v_FromDate and v_ToDate
        and af.actype=aft.actype
        and af.acctno=tse.afacctno
        and aft.producttype like V_STRAFTYPE
        and tse.custodycd = v_CustodyCD
        and tse.afacctno like v_AFAcctno
        and tse.field in ('TRADE','MORTAGE','BLOCKED','DTOCLOSE','WITHDRAW') -- Chaunh, them DTOCLOSE
        and sectype <> '004'
        AND tse.tltxcd not in ('2247','2244','2255') -- Chaunh, thay giao dich 2247 bang gd 2248
    group by tse.custid, tse.custodycd, tse.afacctno, tse.busdate, to_char(tse.symbol), tse.txdate, tse.txnum
    having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0

    union all

    select tci.autoid orderid,tci.custid, tci.custodycd, tci.acctno afacctno, tci.tllog_autoid autoid, tci.txtype , tci.txcd,
        tci.busdate,
--        CASE WHEN TLTXCD = '3350' THEN tci.trdesc || ' ' || tci.txdesc ELSE nvl(tci.trdesc,tci.txdesc) END txdesc,
          --CASE WHEN TLTXCD = '3350' THEN  tci.txdesc ELSE nvl(tci.trdesc,tci.txdesc) END txdesc,
         nvl(nvl(tci.trdesc,tci.txdesc),tl.txdesc)  txdesc, --ThangPV BMSSUP-91
        '' symbol, 0 se_credit_amt, 0 se_debit_amt,
        case when tci.txtype = 'C' or tci.field = 'HOLDBALANCE' then namt else 0 end ci_credit_amt,
        case when tci.txtype = 'D' and tci.field <> 'HOLDBALANCE' then namt else 0 end ci_debit_amt,
        tci.tltxcd, nvl(tci.trdesc,tl.txdesc)  trdesc
    from vw_citran_gen tci, afmast af, aftype aft, tltx tl
    where tci.busdate between v_FromDate and v_ToDate
        and tci.acctno = af.acctno
        and af.actype=aft.actype
        and tl.tltxcd = tci.tltxcd
        and aft.producttype like V_STRAFTYPE
        ---and af.corebank <> 'Y' -- khong lay nhung ps tien cua tk corebank.
        and tci.custodycd = v_CustodyCD
        and tci.acctno like v_AFAcctno
        and af.acctno like v_AFAcctno   -- LINHLNB Add 23-Apr-2012
        AND TCI.TLTXCD NOT IN ('6690','6691','6621','6660','6600','6601','6602')
      and tci.field in ('HOLDBALANCE','BALANCE')
) tr on cf.custid = tr.custid and af.acctno = tr.afacctno

left join
(
    -- Tong phat sinh CI tu From date den ngay hom nay
    select tr.custid,
        sum(case when  tr.field = 'HOLDBALANCE' then tr.namt else (case when tr.txtype = 'D' then -tr.namt else tr.namt end) end) ci_total_move_frdt_amt
    from vw_citran_gen tr, afmast af,aftype aft
    where tr.busdate >= v_FromDate and tr.busdate <= v_CurrDate
        and tr.ACCTNO = af.ACCTNO
        and af.actype=aft.actype
        and aft.producttype like V_STRAFTYPE
        ---and af.corebank <> 'Y' -- khong lay nhung ps tien cua tk corebank.
        and tr.custodycd = v_CustodyCD
        and tr.acctno like v_AFAcctno
        and af.acctno like v_AFAcctno   -- LINHLNB Add 23-Apr-2012
        and tr.field in ('HOLDBALANCE','BALANCE')
        AND tr.TLTXCD NOT IN ('6690','6691','6621','6660','6600','6601','6602')
    group by tr.custid
) ci_move_fromdt on cf.custid = ci_move_fromdt.custid

left join
(
    -- Tong phat sinh CI.RECEIVING tu Todate + 1 den ngay hom nay
    select tr.custid,
        sum(
            case when field = 'RECEIVING' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_RECEIVING_move,

        sum(
            case when field IN ('EMKAMT') then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_EMKAMT_move,
        sum(
            case when field = 'DFDEBTAMT' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_DFDEBTAMT_move
    from vw_citran_gen tr, afmast af,aftype aft
    where tr.busdate > v_ToDate and tr.busdate <= v_CurrDate
        ---and af.corebank <> 'Y' -- khong lay nhung ps tien cua tk corebank.
        and tr.custid = af.custid
        and af.actype=aft.actype
        and aft.producttype like V_STRAFTYPE
        and tr.custodycd = v_CustodyCD
        and tr.acctno like v_AFAcctno
        and af.acctno like v_AFAcctno -- LINHLNB Add 23-Apr-2012
        and tr.field in ('RECEIVING','EMKAMT','DFDEBTAMT')
    group by tr.custid
) ci_RECEIV on cf.custid = ci_RECEIV.custid

left join
(
    select cf.custid, cf.custodycd,
        case when v_CurrDate = v_ToDate then  SUM(secureamt + advamt) else 0 end od_buy_secu
    from v_getbuyorderinfo V, afmast af, cfmast cf,aftype aft
    where v.afacctno = af.acctno and af.custid = cf.custid
            and af.actype=aft.actype
        and aft.producttype like V_STRAFTYPE
        and cf.custodycd = v_CustodyCD and af.acctno like v_AFAcctno
    group by cf.custid, cf.custodycd
) secu on cf.custid = secu.custid
where
    cf.custodycd = v_CustodyCD
    and afacctno like v_AFAcctno
order by --tr.busdate, tr.autoid, tr.txtype,
         tr.afacctno,  tr.busdate,tr.autoid, tr.txtype, tr.orderid,
         case when tr.tltxcd = '1143' and tr.txcd = '0077' then utf8nums.c_const_RPT_CF1000_1143
             when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then utf8nums.c_const_RPT_CF1000_1153
             else to_char(tr.txdesc)
             END
          ;      -- Chu y: Khong thay doi thu tu Order by


EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;
 
/
