SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE1000" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2,
   TLID IN VARCHAR2,
   PV_AFTYPE       IN     VARCHAR2
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
   V_STRAFTYPE   VARCHAR2(100);

BEGIN

-- return;

v_TLID := TLID;
V_STROPTION := OPT;
IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(BRID,1,2) || '__' ;
else
    V_STRBRID:=BRID;
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
/*
SELECT  F_DATE INFDATE, T_DATE INTDATE, PV_CUSTODYCD INCUSTODYCD,
   PV_AFACCTNO INAFACCTNO, TLID INTLID,
   v_TLID VINTLID,
   v_FromDate VINFDATE, v_ToDate VINTDATE, v_CustodyCD VINCustodyCD,
    v_AFAcctno VINAFACCTNO
FROM DUAL; */

select 0 tmtracham,tr.txdate ,
    cf.custid, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.mobile, cf.address,
    tr.autoid, PV_AFACCTNO ACCTNO, TR.afacctno,TR.PRODUC, tr.busdate, nvl(tr.symbol,' ') tran_symbol,
    nvl(se_credit_amt,0) se_credit_amt, nvl(se_debit_amt,0) se_debit_amt,
    nvl(secu.od_buy_secu,0) od_buy_secu,
    case when tr.tltxcd = '1143' and tr.txcd = '0077' then utf8nums.c_const_RPT_CF1000_1143
         when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then utf8nums.c_const_RPT_CF1000_1153
         when tr.tltxcd = '2266' then utf8nums.c_const_RPT_CF1000_2266
         else to_char(tr.txdesc)
    end txdesc

FROM (select * from cfmast where custodycd = v_CustodyCD and  FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BRID, TLGOUPS)=0) cf
inner join (select AF.* from afmast AF,AFTYPE AFT where AF.acctno like v_AFAcctno
 and AF.actype not in ('0000') AND AFT.ACTYPE=AF.ACTYPE AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE) af on cf.custid = af.custid
inner join
(
    -- Tong so du CI hien tai group by TK luu ky
    select cf.custid, cf.custodycd,
        sum(case when af.corebank = 'Y' then 0 else balance end) ci_balance,
        sum(case when af.corebank = 'Y' then 0 else RECEIVING end) CI_RECEIVING,
        sum(case when af.corebank = 'Y' then 0 else EMKAMT end) CI_EMKAMT,
        sum(case when af.corebank = 'Y' then 0 else DFDEBTAMT end) CI_DFDEBTAMT
    from (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf, afmast af, cimast ci,AFTYPE AFT
    where cf.custid = af.custid and af.acctno = ci.afacctno
        and cf.custodycd = v_CustodyCD
        and af.acctno like v_AFAcctno
        AND AF.ACTYPE=AFT.ACTYPE
        AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        and af.actype not in ('0000')
    group by  cf.custid, cf.custodycd
) cibal on cf.custid = cibal.custid
left join
(
    -- Toan bo phat sinh CK tu FromDate den Todate
    select max(tse.autoid) orderid, tse.custid, tse.custodycd, tse.afacctno, max(tse.tllog_autoid) autoid, max(tse.txtype) txtype, max(tse.txcd) txcd ,
        tse.busdate, tse.txdate,
       MAX(CASE WHEN tse.TLTXCD in ('3350','2205') THEN  tse.txdesc ELSE nvl(tse.trdesc,tse.txdesc) END) txdesc,
        to_char(max(tse.symbol)) symbol,
        sum(case when tse.txtype = 'C' and tse.field in ('TRADE','MORTAGE','BLOCKED','EMKQTTY') then tse.namt else 0 end) se_credit_amt,
        sum(case when tse.txtype = 'D' AND tse.field in ('TRADE','MORTAGE','BLOCKED','EMKQTTY') then tse.namt
                WHEN tse.tltxcd = '2248' AND tse.field in ('DTOCLOSE','BLOCKDTOCLOSE') THEN tse.namt
                when tse.tltxcd = '2266' AND tse.field in ('WITHDRAW','BLOCKWITHDRAW') THEN tse.namt
                else 0 end) se_debit_amt,
        max(tse.tltxcd) tltxcd, max(tse.trdesc) trdesc,A0.CDCONTENT PRODUC
    from vw_setran_gen tse, vw_tllog_all tl, AFMAST AF, AFTYPE AFT,ALLCODE A0
    where tse.busdate between v_FromDate and v_ToDate
          AND AF.ACCTNO=tse.afacctno
          AND AF.ACTYPE=AFT.ACTYPE
             AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
          AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        and tse.custodycd = v_CustodyCD
        and tse.afacctno like v_AFAcctno
        and tse.txnum = tl.txnum and tse.txdate = tl.TXDATE
        and tse.field in ('TRADE','MORTAGE','BLOCKED','DTOCLOSE','WITHDRAW','EMKQTTY','BLOCKWITHDRAW','BLOCKDTOCLOSE') -- Chaunh, them DTOCLOSE
        and sectype <> '004'
        and tl.deltd <> 'Y'
        AND tse.tltxcd not in ('2247','2244','2255') -- Chaunh, thay giao dich 2247 bang gd 2248
    group by tse.custid, tse.custodycd, tse.afacctno, tse.busdate, to_char(tse.symbol), tse.txdate, tse.txnum,A0.CDCONTENT
    having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0
) tr on cf.custid = tr.custid and af.acctno = tr.afacctno
left join
(
    select cf.custid, cf.custodycd,
        case when v_CurrDate = v_ToDate then  SUM(secureamt + advamt) else 0 end od_buy_secu
    from v_getbuyorderinfo V, afmast af, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf,AFTYPE AFT
    where v.afacctno = af.acctno and af.custid = cf.custid AND AF.ACTYPE=AFT.ACTYPE
          AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        and cf.custodycd = v_CustodyCD and af.acctno like v_AFAcctno
        and af.actype not in ('0000')
    group by cf.custid, cf.custodycd
) secu on cf.custid = secu.custid
where
    cf.custodycd = v_CustodyCD
    and afacctno like v_AFAcctno
    --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = v_TLID )   -- check careby
order by --tr.busdate, tr.autoid, tr.txtype,
          tr.busdate,tr.autoid, tr.txtype, tr.orderid,
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
