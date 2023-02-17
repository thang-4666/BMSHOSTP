SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1002 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   PV_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2,
   PV_CUSTODYCD           IN       VARCHAR2,
   PV_AFACCTNO            IN       VARCHAR2,
   TLID                   IN       VARCHAR2
  )
IS
--

-- BAO CAO SAO KE TIEN CUA TAI KHOAN KHACH HANG
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- TUNH        13-05-2010           CREATED
-- TUNH        31-08-2010           Lay dien giai chi tiet o cac table xxTRAN
-- HUNG.LB     03-11-2010           6.3.1
-- QUOCTA      12-01-2012           BVS - LAY THEO NGAY BACKDATE CUA GD
-- THENN       12-03-2012           SUA ORDER DE KO BI AM TIEN CUOI NGAY DO GD GIAI NGAN SAU GD TRA TIEN MUA

   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate     date;
   v_ToDate       date;
   v_CurrDate     date;
   v_CustodyCD    varchar2(20);
   v_AFAcctno     varchar2(20);
   v_TLID         varchar2(4);

   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;
   L_TRANS_OF_BANK VARCHAR2(3900);

BEGIN

   v_TLID := TLID;

   V_STROPTION := OPT;

   IF V_STROPTION = 'A' then
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(PV_BRID,1,2) || '__' ;
   else
    V_STRBRID:=PV_BRID;
   END IF;

   v_FromDate  :=     TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   v_ToDate    :=     TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

   v_CustodyCD :=     upper(replace(pv_custodycd,'.',''));
   v_AFAcctno  :=     upper(replace(PV_AFACCTNO,'.',''));

   if (v_AFAcctno = 'ALL' or v_AFAcctno is null) then
      v_AFAcctno := '%';
   else
      v_AFAcctno := v_AFAcctno;
   end if;

   select TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) into v_CurrDate from SYSVAR where grname='SYSTEM' and varname='CURRDATE';

   Begin
        select varvalue into L_TRANS_OF_BANK from sysvar where varname='TRANS_OF_BANK';
   EXCEPTION
        WHEN OTHERS THEN  L_TRANS_OF_BANK := '660';
   End;

OPEN PV_REFCURSOR FOR
with cfmast_tmp as
(
    select cf.custid, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, cf.idplace, NVL(CF.MOBILESMS,cf.mobile) mobile, cf.address,
           af.acctno, af.careby
    from cfmast cf
    inner join afmast af on cf.custid = af.custid
    where cf.custodycd = v_CustodyCD and af.acctno like v_AFAcctno
)
select 0 tmtracham, cf.custid, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.mobile, cf.address, PV_AFACCTNO S_AFACCTNO,

    tr.autoid, tr.afacctno, tr.bkdate busdate, nvl(tr.symbol,' ') tran_symbol,
    nvl(se_credit_amt,0) se_credit_amt, nvl(se_debit_amt,0) se_debit_amt,
    nvl(ci_credit_amt,0) ci_credit_amt, nvl(ci_debit_amt,0) ci_debit_amt,
    ci_balance,
    ci_balance - nvl(ci_total_move_frdt_amt,0) ci_begin_bal,
    CI_RECEIVING, CI_RECEIVING - nvl(ci_RECEIVING_move,0) ci_receiving_bal,
    CI_EMKAMT, CI_EMKAMT + CI_MBLOCK - nvl(ci_EMKAMT_move,0) -nvl(ci_MBLOCK_move,0) ci_EMKAMT_bal,
    CI_DFDEBTAMT - nvl(ci_DFDEBTAMT_move,0) ci_DFDEBTAMT_bal,
    nvl(secu.od_buy_secu,0) od_buy_secu,
    tr.txnum,
    case when tr.tltxcd = '1143' and tr.txcd = '0077' then ' So tien den han phai thanh toan '
         --when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then ' Phi ung truoc '
         --when tr.tltxcd = '5566' then  tr.tltxdesc
         when tr.tltxcd = '2266' then utf8nums.c_const_RPT_CF1000_2266
         when tr.tltxcd in ('3350','11A1','11A2') then tr.txdesc --TramNN 10/03/2022 PHSSUP-1797 them GD 11A1 11A2
         else to_char(decode(substr(tr.txnum,1,2),'68', tr.txdesc || ' (Online)',
                                                  '69',tr.txdesc || ' (Home)',
                                                  '99',tr.txdesc || ' (Auto)',
                                                  '70',tr.txdesc || ' (Mobile)',tr.txdesc))
    end
    ||(case when tr.tltxcd in ('8865','8855','8866','8856','1153','1120','3350') then ''
        when tr.tltxcd in ('5566') and tr.reftxnum is not null then '(Renew deal)'
        when tr.tltxcd in ('5567') and tr.reftxnum is not null then '(Transfer deal)'
        else '( ' ||  tr.en_txdesc || ' )'
        end) txdesc,
    tr.tltxcd,

    case when tr.tltxcd in ('2641','2642','2643','2660','2678','2670') then
            (case when trim(tr.description) is not null
                    then nvl(tr.description, ' ')
                else
                    tr.dealno
             end
            )
    end dfaccno

from cfmast_tmp cf
--inner join afmast af on cf.custid = af.custid
inner join
(
    -- Tong so du CI hien tai group by TK luu ky
    select cf.custid, cf.custodycd,
        /*sum(case when af.corebank = 'Y' then 0 else balance end) ci_balance,
        sum(case when af.corebank = 'Y' then 0 else RECEIVING end) CI_RECEIVING,
        sum(case when af.corebank = 'Y' then 0 else EMKAMT end) CI_EMKAMT,
        sum(case when af.corebank = 'Y' then 0 else DFDEBTAMT end) CI_DFDEBTAMT*/
        sum(ci.balance-ci.holdbalance) ci_balance,
        sum(RECEIVING) CI_RECEIVING,
        sum(EMKAMT) CI_EMKAMT,
        sum(MBLOCK) CI_MBLOCK,
        sum(DFDEBTAMT) CI_DFDEBTAMT,
        Sum(holdbalance) holdbalance
    from cfmast_tmp cf, /*afmast af,*/ cimast ci
    where /*cf.custid = af.custid and*/ cf.acctno = ci.afacctno
        and cf.custodycd = v_CustodyCD
        and cf.acctno like v_AFAcctno
    group by  cf.custid, cf.custodycd
) cibal on cf.custid = cibal.custid

left join
(
    -- Danh sach giao dich CI: tu From Date den ToDate
    select tci.custid, tci.custodycd, tci.acctno afacctno,
        (case when tci.tltxcd = '1153' and tci.txtype = 'C' then tci.autoid-1 else tci.autoid+1 end) autoid, tllog_autoid,tci.txtype,
        tci.busdate,
        nvl(tci.trdesc,tci.txdesc) txdesc,
        --CASE WHEN tci.TLTXCD = '3350' THEN  tci.txdesc ELSE nvl(tci.trdesc,tci.txdesc) END txdesc,
         '' symbol, 0 se_credit_amt, 0 se_debit_amt,
        case when tci.txtype = 'C' then namt else 0 end ci_credit_amt,
        case when tci.txtype = 'D' then namt else 0 end ci_debit_amt,
        tci.txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, tci.dfacctno dealno,
        tci.old_dfacctno description, tci.trdesc, tci.bkdate,--,
        tci.txdesc tltxdesc, tl.en_txdesc, tci.reftxnum
        /*CASE WHEN tci.tltxcd in ('1140') THEN 0
            WHEN substr(tci.tltxcd,1,2) = '55' THEN 1 ELSE 2 END txorder*/
    from   (select ci.autoid, cf.custodycd, cf.custid,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, (case when tl.tltxcd in ('1134','1101','1111') and app.txcd = '0028' then 'Thue VAT' else nvl(tl.txdesc,t.txdesc) end) txdesc
            , tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate, tl.reftxnum
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                    (select * from tllog where deltd <> 'Y' union all select * from tllogall where deltd <> 'Y') TL, cfmast_tmp cf, /*afmast af,*/ apptx app, tltx t --, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            --and     cf.custid       =    af.custid
            and     ci.acctno       =    cf.acctno
            and     ci.txcd         =    app.txcd
            and     tl.tltxcd = t.tltxcd
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
            --and     tl.TLTXCD NOT IN ('6690','6691','6621','6660','6600','6601','6602','6692','6693','6674','6642')
            -- '9100/2635/2651/2653/2656/6621/6660/6600/6601/6602/6690/6692/6691/6693/6674/6642/1144/1145'
            and instr(L_TRANS_OF_BANK, tl.tltxcd) = 0
            and ci.corebank <> 'Y'
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0

            UNION ALL

            SELECT 0 AUTOID, CF.custodycd, cf.custid, TL.txnum, TL.txdate, TL.MSGacct acctno, 'D' txcd,
            case when tl.TLTXCD IN ('6668','6650') then tl.msgamt else 0 end namt,
            '' camt, '' ref, nvl(TL.deltd, 'N') deltd, TL.MSGacct acctref,
            tl.tltxcd, tl.busdate, nvl(tl.txdesc,t.txdesc) txdesc
            , tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            '' dfacctno,' ' old_dfacctno,
            case when tl.TLTXCD IN ('6668','6650') then 'C' else 'D' end txtype, 'BALANCE' field,
             tl.autoid+1 tllog_autoid,
            '' trdesc, TL.txdate bkdate, tl.reftxnum
            FROM (select * from tllog where deltd <> 'Y' union all select * from tllogall where deltd <> 'Y') TL, cfmast_tmp cf, tltx t /*, afmast af */
            where   /*cf.custid       =    af.custid
            and     */ TL.MSGacct       =    cf.acctno
            and     tl.tltxcd = t.tltxcd
            --and af.corebank <> 'Y'
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
             AND TL.TLTXCD in ('3324','6668','6650')
            ) tci, tltx tl
    where tci.tltxcd = tl.tltxcd and tci.bkdate between v_FromDate and v_ToDate
       and tci.custodycd = v_CustodyCD
       and tci.acctno like v_AFAcctno
       and tci.field = 'BALANCE'

) tr on cf.custid = tr.custid and cf.acctno = tr.afacctno

left join
(
    -- Tong phat sinh CI tu From date den ngay hom nay
    select tr.custid,

        sum(case when tr.txtype = 'D' then -tr.namt else tr.namt end) ci_total_move_frdt_amt
    from   (select (case when tl.tltxcd = '1153' and app.txtype = 'C'
                         then ci.autoid-1 else ci.autoid+1 end) autoid,
            cf.custodycd, cf.custid,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc
            , tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            ci.ref dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field,
            (case when tl.tltxcd = '1153' and app.txtype = 'C'
                  then tl.autoid-1 else tl.autoid+1 end) tllog_autoid,
            ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                    VW_TLLOG_ALL TL, cfmast_tmp cf, /*afmast af, */apptx app--, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            --and     cf.custid       =    af.custid
            and     ci.acctno       =    cf.acctno
            and     ci.txcd         =    app.txcd
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
            --and     tl.TLTXCD NOT IN ('6690','6691','6621','6660','6600','6601','6602','6692','6693','6674','6642')
            and instr(L_TRANS_OF_BANK, tl.tltxcd) = 0
            and ci.corebank <> 'Y'
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0

            UNION ALL

            -- 12/05/2015 TruongLD Add  --> Lay them ca GD --> dong bo voi doan lay tu ngay ... den ngay
            SELECT 0 AUTOID, CF.custodycd, cf.custid, TL.txnum, TL.txdate, TL.MSGacct acctno, 'D' txcd,
            case when tl.TLTXCD IN ('6668','6650') then tl.msgamt else 0 end namt,
            '' camt, '' ref, nvl(TL.deltd, 'N') deltd, TL.MSGacct acctref,
            tl.tltxcd, tl.busdate, tl.txdesc
            , tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            '' dfacctno,' ' old_dfacctno,
            case when tl.TLTXCD IN ('6668','6650') then 'C' else 'D' end txtype, 'BALANCE' field,
             tl.autoid+1 tllog_autoid,
            '' trdesc, TL.txdate bkdate
            FROM VW_TLLOG_ALL TL, cfmast_tmp cf /*, afmast af*/
            where   /*cf.custid       =    af.custid
            and     */TL.MSGacct       =    cf.acctno
            and     tl.deltd        <>  'Y'
             AND TL.TLTXCD in ('3324','6668','6650')

                ) tr
    where
        tr.bkdate >= v_FromDate and tr.bkdate <= v_CurrDate
        and tr.custodycd = v_CustodyCD
        and tr.acctno like v_AFAcctno
        and tr.field in ('BALANCE')
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
            case when field IN ('MBLOCK') then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_MBLOCK_move,

        sum(
            case when field = 'DFDEBTAMT' then
                case when tr.txtype = 'D' then -tr.namt else tr.namt end
            else 0
            end
            ) ci_DFDEBTAMT_move
    from   (select ci.autoid, cf.custodycd, cf.custid,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc
            , tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                    VW_TLLOG_ALL TL, cfmast_tmp cf, /* afmast af,*/ apptx app--, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            --and     cf.custid       =    af.custid
            and     ci.acctno       =    cf.acctno
            and     ci.txcd         =    app.txcd
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
            and ci.corebank <> 'Y'
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0 ) tr
    where
        tr.bkdate > v_ToDate and tr.bkdate <= v_CurrDate
        and tr.custodycd = v_CustodyCD
        and tr.acctno like v_AFAcctno
        and tr.field in ('RECEIVING','EMKAMT','DFDEBTAMT')
    group by tr.custid
) ci_RECEIV on cf.custid = ci_RECEIV.custid

left join
(
    select cf.custid, cf.custodycd,
        case when v_CurrDate = v_ToDate then SUM(secureamt + advamt) else 0 end od_buy_secu
    from v_getbuyorderinfo V, /*afmast af, */cfmast_tmp cf
    where v.afacctno = cf.acctno and cf.custid = cf.custid
        and cf.custodycd = v_CustodyCD and cf.acctno like v_AFAcctno
    group by cf.custid, cf.custodycd
) secu on cf.custid = secu.custid

where cf.custodycd = v_CustodyCD
    and exists (select gu.grpid from tlgrpusers gu where cf.careby = gu.grpid and gu.tlid = v_TLID)   -- check careby cf.careby = gu.grpid
order by --tr.bkdate,/*tr.txorder,*/-- tr.autoid,
         --tr.txtype, tr.txnum,
         tr.bkdate, tr.tllog_autoid,  tr.txnum, tr.txtype, tr.autoid,
         case when tr.tltxcd = '1143' and tr.txcd = '0077' then ' So tien den han phai thanh toan '
              when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then ' Phi ung truoc '
              else to_char(tr.txdesc)
         end

          ;      -- Chu y: Khong thay doi thu tu Order by


EXCEPTION
  WHEN OTHERS
   THEN
        plog.error( sqlerrm|| dbms_utility.format_error_backtrace);
        Return;
End;
 
/
