SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1019" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2,
   PV_AFACCTNO       IN       VARCHAR2,
   TLID IN VARCHAR2
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
--------------------------------------------------------------------
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

BEGIN

-- return;

    v_TLID := TLID;
    V_STROPTION := OPT;
    IF V_STROPTION = 'A' then
        V_STRBRID := '%%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(pv_BRID,1,2) || '__' ;
    else
        V_STRBRID:=pv_BRID;
    END IF;

    v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
    v_ToDate:= to_date(T_DATE,'DD/MM/RRRR');
    v_CustodyCD:= upper(replace(pv_custodycd,'.',''));
    v_AFAcctno:= upper(replace(PV_AFACCTNO,'.',''));

    if v_AFAcctno = 'ALL' or v_AFAcctno is null then
        v_AFAcctno := '%%';
    else
        v_AFAcctno := v_AFAcctno;
    end if;

    select to_date(VARVALUE,'DD/MM/YYYY') into v_CurrDate from sysvar where grname='SYSTEM' and varname='CURRDATE';



    OPEN PV_REFCURSOR FOR
        select 0 tmtracham,
            cf.custid, cf.custodycd, cf.fullname, NULL idcode, NULL iddate, NULL idplace, NULL mobile, NULL address,
            tr.autoid, tr.afacctno, tr.busdate, nvl(tr.symbol,' ') tran_symbol,
            sum(nvl(se_credit_amt,0)) se_credit_amt,sum(nvl(se_debit_amt,0)) se_debit_amt,
            (nvl(ci_credit_amt,0)) ci_credit_amt,(nvl(ci_debit_amt,0)) ci_debit_amt,
            ci_balance, ci_balance - nvl(ci_total_move_frdt_amt,0)  ci_begin_bal,
            CI_RECEIVING, CI_RECEIVING - nvl(ci_RECEIVING_move,0) ci_receiving_bal,
            CI_EMKAMT, CI_EMKAMT - nvl(ci_EMKAMT_move,0) ci_EMKAMT_bal,
            nvl(secu.od_buy_secu,0) od_buy_secu,
            CI_DFDEBTAMT - nvl(ci_DFDEBTAMT_move,0) ci_DFDEBTAMT_bal,
            MAX(case when tr.tltxcd = '1143' and tr.txcd = '0077' then utf8nums.c_const_RPT_CF1000_1143
                 when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then utf8nums.c_const_RPT_CF1000_1153
                 when tr.tltxcd = '2266' then utf8nums.c_const_RPT_CF1000_2266
                 else to_char(tr.txdesc)
            END) txdesc, tr.tltxcd

        from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
        inner join afmast af on cf.custid = af.custid
        inner join
        (
            -- Tong so du CI hien tai group by TK luu ky
            select cf.custid, cf.custodycd,
                sum(case when af.corebank = 'Y' then 0 else balance + emkamt end) ci_balance,
                sum(case when af.corebank = 'Y' then 0 else RECEIVING end) CI_RECEIVING,
                sum(case when af.corebank = 'Y' then 0 else EMKAMT end) CI_EMKAMT,
                sum(case when af.corebank = 'Y' then 0 else DFDEBTAMT end) CI_DFDEBTAMT
            from  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, cimast ci
            where cf.custid = af.custid and af.acctno = ci.afacctno
                and cf.custodycd = v_CustodyCD
                and af.acctno like v_AFAcctno
            group by  cf.custid, cf.custodycd
        ) cibal on cf.custid = cibal.custid

        left join
        (
            -- Toan bo phat sinh CK, CI tu FromDate den Todate
            select max(tse.autoid) orderid, tse.custid, tse.afacctno, max(tse.tllog_autoid) autoid, tse.txtype,tse.txcd,
                tse.busdate,
                --max(nvl(tse.trdesc,tse.txdesc)) txdesc,
                MAX(CASE WHEN TLTXCD = '3350' THEN  tse.txdesc ELSE nvl(tse.trdesc,tse.txdesc) END) txdesc,
                to_char(max(tse.symbol)) symbol,
                sum(case when tse.txtype = 'C' and tse.field in ('TRADE','MORTAGE','BLOCKED') then tse.namt
                         else 0 end) se_credit_amt,
                sum(case when tse.txtype = 'D' and tse.field in ('TRADE','MORTAGE','BLOCKED') then tse.namt
                         WHEN tltxcd = '2248' AND tse.field = 'DTOCLOSE' THEN tse.namt
                         when tltxcd = '2266' AND tse.field = 'WITHDRAW' THEN tse.namt
                         else 0 end) se_debit_amt,
                0 ci_credit_amt, 0 ci_debit_amt,
                max(tse.tltxcd) tltxcd, max(tse.trdesc) trdesc
            from vw_setran_gen tse
            where tse.busdate >= v_FromDate and tse.busdate <= v_ToDate
                and tse.custodycd = v_CustodyCD
                and tse.afacctno like v_AFAcctno
                and tse.field in ('TRADE','MORTAGE','BLOCKED','DTOCLOSE','WITHDRAW')
                and sectype <> '004'
                and tse.tltxcd NOT IN ('8867','8868','2247','2290','2244','2255') --CHAUNH bo gd 2247,2290
            group by tse.custid, tse.afacctno, tse.busdate, tse.tltxcd, tse.symbol, tse.txtype,tse.txcd,-- tse.ref
                     CASE WHEN tse.tltxcd = '3356' THEN to_char(tse.autoid) ELSE tse.REF end
            having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0

            union all
            ---- Gop cat CK ban, nhan CK mua theo ngay, ma CK
            select max(tse.autoid) orderid, tse.custid, tse.afacctno, max(tse.tllog_autoid) autoid,tse.txtype,tse.txcd,
                tse.busdate, case when tse.TLTXCD = '8867' then 'B�n ' || trim(to_char(sum(tse.namt),'999,999,999,999,999,999')) || ' ' || max(tse.symbol) || ' ng�y ' || TO_CHAR(tse.busdate,'DD/MM/RRRR')
                             else  'Mua ' || trim(to_char(sum(tse.namt),'999,999,999,999,999,999')) || ' ' || max(tse.symbol) || ' ng�y ' || TO_CHAR(max(od.TXDATE),'DD/MM/RRRR') end TXDESC,
                 to_char(max(tse.symbol)) symbol,
                sum(case when tse.txtype = 'C' and tse.field in ('TRADE','MORTAGE','BLOCKED') then tse.namt else 0 end) se_credit_amt,
                sum(case when tse.txtype = 'D' and tse.field in ('TRADE','MORTAGE','BLOCKED') then tse.namt
                         WHEN tltxcd = '2248' AND tse.field = 'DTOCLOSE' THEN tse.namt
                         else 0 end) se_debit_amt,
                0 ci_credit_amt, 0 ci_debit_amt,
                max(tse.tltxcd) tltxcd, max(tse.trdesc) trdesc
            from vw_setran_gen tse, vw_odmast_all od
            where tse.busdate >= v_FromDate and tse.busdate <= v_todate
                and tse.acctref = od.ORDERID
                and tse.custodycd = v_CustodyCD
                and tse.afacctno like v_AFAcctno
                and tse.field in ('TRADE','MORTAGE','BLOCKED','DTOCLOSE')
                and sectype <> '004'
                and tse.tltxcd IN ('8867','8868','2247','2290')
            group by tse.custid, tse.afacctno, tse.busdate, tse.symbol, tse.tltxcd,tse.txtype,tse.txcd
            having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0

            union all
            select tci.autoid orderid, se.custid, tci.msgacct afacctno, tci.autoid+1 autoid, 'C' txtype, '0028' txcd,
                tci.busdate,
               -- nvl(tci.trdesc,tci.txdesc) txdesc,
                TCI.txdesc,
                se.symbol symbol, TCI.msgamt se_credit_amt, 0 se_debit_amt,
                0 ci_credit_amt,
                0 ci_debit_amt,
                tci.tltxcd, '' trdesc
            from vw_tllog_all tci, vw_setran_gen se
            where tci.busdate >= v_FromDate AND tci.busdate <= v_todate
              AND se.txdate = tci.txdate AND se.txnum = tci.txnum
              AND se.field = 'RECEIVING'
              and se.custodycd = v_CustodyCD
              and tci.msgacct like v_AFAcctno
              --and af.corebank <> 'Y' --khong lay ps tien cua tk corebank.
              and tci.tltxcd ='3324'
              AND NOT EXISTS(SELECT TLTXCD FROM TLTX WHERE TLTXCD IN ('8855','8865','8856','8866','1144','1145','8889') AND TLTX.TLTXCD = TCI.TLTXCD)




            union all

            select tci.autoid orderid, tci.custid, tci.acctno afacctno, tci.tllog_autoid autoid,tci.txtype,tci.txcd,
                tci.busdate,
               nvl(tci.trdesc,tci.txdesc) txdesc,
                --CASE WHEN TLTXCD = '3350' THEN tci.txdesc ELSE nvl(tci.trdesc,tci.txdesc) END txdesc,
                '' symbol, 0 se_credit_amt, 0 se_debit_amt,
                case when tci.txtype = 'C' then namt else 0 end ci_credit_amt,
                case when tci.txtype = 'D' then namt else 0 end ci_debit_amt,
                tci.tltxcd, tci.trdesc trdesc
            from vw_citran_gen tci, afmast af
            where tci.busdate >= v_FromDate AND tci.busdate <= v_ToDate
              and tci.custodycd = v_CustodyCD
              and tci.acctno like v_AFAcctno
              and af.acctno like v_AFAcctno    -- LINHLNB Add 23-Apr-2012
              and tci.custid = af.custid
              and af.corebank <> 'Y' --khong lay ps tien cua tk corebank.
              and tci.field ='BALANCE'
              AND NOT EXISTS(SELECT TLTXCD FROM TLTX WHERE TLTXCD IN ('8855','8865','8856','8866','1144','1145','8889') AND TLTX.TLTXCD = TCI.TLTXCD)

              union all

              ------ Thanh toan phi mua , thanh toan tien mua, tra phi ban, nhan tien ban: group theo ngay va ma GD
              select  max(tci.autoid) orderid, tci.custid, tci.acctno afacctno,max(tci.tllog_autoid) autoid,tci.txtype,tci.txcd,
                 tci.busdate,
                 case when TCI.TLTXCD = '8865' then utf8nums.c_const_RPT_CF1007_8865 || to_char(max(od.txdate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                    when TCI.TLTXCD = '8889' then utf8nums.c_const_RPT_CF1007_8865 || to_char(max(od.txdate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                    when TCI.TLTXCD = '8855' then utf8nums.c_const_RPT_CF1007_8855 || to_char(max(od.txdate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                    when TCI.TLTXCD = '8866' then utf8nums.c_const_RPT_CF1007_8866 || to_char(max(od.txdate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                    else  utf8nums.c_const_RPT_CF1007_8866_2 || to_char(max(od.txdate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                    end TXDESC,
                '' symbol, 0 se_credit_amt, 0 se_debit_amt,
                SUM(case when tci.txtype = 'C' then namt else 0 end) ci_credit_amt ,
                SUM(case when tci.txtype = 'D' then namt else 0 end) ci_debit_amt,
                tci.tltxcd, '' trdesc
            from vw_citran_gen tci, vw_odmast_all od, afmast af
               where tci.busdate >= v_FromDate AND tci.busdate <= v_ToDate
                and tci.custodycd = v_CustodyCD
                and tci.custid = af.custid
                and af.corebank <> 'Y' --khong lay ps tien cua tk corebank.
                and tci.acctno like v_AFAcctno
                and af.acctno like v_AFAcctno    -- LINHLNB Add 23-Apr-2012
                and tci.field ='BALANCE'
                and tci.ref=od.orderid
                AND EXISTS(SELECT TLTXCD FROM TLTX WHERE TLTXCD IN ('8855','8865','8856','8866','8889') AND TLTX.TLTXCD = TCI.TLTXCD)
                GROUP BY tci.custid, tci.acctno, tci.busdate,tci.tltxcd,tci.txtype,tci.txcd

        ) tr on cf.custid = tr.custid and af.acctno = tr.afacctno

        left join
        (
            -- Tong phat sinh CI tu From date den ngay hom nay
            select tr.custid,
                sum(case when tr.txtype = 'D' then -tr.namt else tr.namt end) ci_total_move_frdt_amt
            from vw_citran_gen tr, afmast af
            where tr.busdate >= v_FromDate and tr.busdate <= v_CurrDate
                and tr.custodycd = v_CustodyCD
                and tr.custid = af.custid
                and af.corebank <> 'Y' --khong lay ps tien cua tk corebank.
                and tr.acctno like v_AFAcctno
                and af.acctno like v_AFAcctno    -- LINHLNB Add 23-Apr-2012
                and tr.field ='BALANCE'
                AND tr.tltxcd NOT IN ('1144','1145')
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
                    case when field ='EMKAMT' then
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
            from vw_citran_gen tr, afmast af
            where tr.busdate > v_ToDate and tr.busdate <= v_CurrDate
                and tr.custodycd = v_CustodyCD
                and tr.acctno like v_AFAcctno
                and af.acctno like v_AFAcctno    -- LINHLNB Add 23-Apr-2012
                and tr.custid = af.custid
                and af.corebank <> 'Y' --khong lay ps tien cua tk corebank.
                and tr.field in ('RECEIVING','EMKAMT','DFDEBTAMT')
            group by tr.custid
        ) ci_RECEIV on cf.custid = ci_RECEIV.custid

        left join
        (
            select cf.custid, cf.custodycd,
                case when v_CurrDate = v_ToDate then  SUM(secureamt + advamt) else 0 end od_buy_secu
            from v_getbuyorderinfo V, afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
            where v.afacctno = af.acctno and af.custid = cf.custid
                and cf.custodycd = v_CustodyCD and af.acctno like v_AFAcctno
            group by cf.custid, cf.custodycd
        ) secu on cf.custid = secu.custid
        where
            cf.custodycd = v_CustodyCD
            --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = v_TLID )   -- check careby
        GROUP BY cf.custid, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.mobile, cf.address,
            tr.autoid, tr.afacctno, tr.busdate, nvl(tr.symbol,' '),
            --sum(nvl(se_credit_amt,0)) se_credit_amt,sum(nvl(se_debit_amt,0)) se_debit_amt,
            (nvl(ci_credit_amt,0)) ,(nvl(ci_debit_amt,0)) ,
            ci_balance, ci_balance - nvl(ci_total_move_frdt_amt,0)  ,
            CI_RECEIVING, CI_RECEIVING - nvl(ci_RECEIVING_move,0) ,
            CI_EMKAMT, CI_EMKAMT - nvl(ci_EMKAMT_move,0) ,
            tr.txtype, tr.orderid, ---CHAUNH add
            nvl(secu.od_buy_secu,0) ,
            CI_DFDEBTAMT - nvl(ci_DFDEBTAMT_move,0) ,
            case when tr.tltxcd = '1143' and tr.txcd = '0077' then utf8nums.c_const_RPT_CF1000_1143
                 when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then utf8nums.c_const_RPT_CF1000_1153
                 else to_char(tr.txdesc)
            end,tr.tltxcd
       --HAVING sum(nvl(se_credit_amt,0)) - sum(nvl(se_debit_amt,0)) + (nvl(ci_credit_amt,0)) + (nvl(ci_debit_amt,0))  <> 0
        order by --tr.busdate, tr.autoid,(nvl(se_debit_amt,0)) ,(nvl(se_credit_amt,0))  --tr.txtype
                tr.busdate,tr.autoid, tr.txtype, tr.orderid, -- CHAUNH add
                 case when tr.tltxcd = '1143' and tr.txcd = '0077' then utf8nums.c_const_RPT_CF1000_1143
                 when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then utf8nums.c_const_RPT_CF1000_1153
                 else to_char(tr.txdesc)
                end
        ;      -- Chu y: Khong thay doi thu tu Order by


EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
