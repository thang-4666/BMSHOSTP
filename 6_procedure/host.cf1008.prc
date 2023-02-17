SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1008" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   PV_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2,
   PV_CUSTODYCD           IN       VARCHAR2,
   PV_AFACCTNO            IN       VARCHAR2,
   TLID                   IN       VARCHAR2,
   PV_AFTYPE              IN       VARCHAR2
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
   V_STRAFTYPE    VARCHAR2(100);

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

      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;

OPEN PV_REFCURSOR FOR


select 0 tmtracham, cf.custid, cf.custodycd, cf.fullname, NULL idcode, NULL iddate,
 NULL idplace, NULL mobile, NULL address, PV_AFACCTNO S_AFACCTNO,
    tr.autoid, tr.afacctno, tr.bkdate busdate, nvl(tr.symbol,' ') tran_symbol,
    nvl(se_credit_amt,0) se_credit_amt, nvl(se_debit_amt,0) se_debit_amt,
    nvl(ci_credit_amt,0) ci_credit_amt, nvl(ci_debit_amt,0) ci_debit_amt,
    ci_balance, ci_balance - nvl(ci_total_move_frdt_amt,0)  ci_begin_bal,
    CI_RECEIVING, CI_RECEIVING - nvl(ci_RECEIVING_move,0) ci_receiving_bal,
    CI_EMKAMT, CI_EMKAMT - nvl(ci_EMKAMT_move,0) ci_EMKAMT_bal,
    CI_DFDEBTAMT - nvl(ci_DFDEBTAMT_move,0) ci_DFDEBTAMT_bal,
    nvl(secu.od_buy_secu,0) od_buy_secu,
    tr.txnum,TR.PRO,tr.txtype,
    case when tr.tltxcd = '1143' and tr.txcd = '0077' then 'Số tiền đến hạn phải thanh toán'
         when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then 'Phí ứng trước'
         else to_char(decode(substr(tr.txnum,1,2),'68', tr.txdesc || ' (Online)',tr.txdesc))
         --else to_char(tr.txdesc)
    end txdesc,
    tr.tltxcd,

    case when tr.tltxcd in ('2641','2642','2643','2660','2678','2670') then
            (case when trim(tr.description) is not null
                    then nvl(tr.description, ' ')
                else
                    tr.dealno
             end
            )
    end dfaccno, (case when u.tokenid is null then '-' else SUBSTR(u.tokenid, instr(u.tokenid, '{', 1, 2) + 1, instr(u.tokenid, '}', 1, 1) - instr(u.tokenid, '{', 1, 2) - 1) end) tokenid

from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf

inner join (SELECT AF.* FROM afmast AF, AFTYPE AFT WHERE AF.ACTYPE=AFT.ACTYPE
                   AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE ) af on cf.custid = af.custid
inner join
(
    -- Tong so du CI hien tai group by TK luu ky
    select cf.custid, cf.custodycd,
        /*sum(case when af.corebank = 'Y' then 0 else balance + emkamt end) ci_balance, --them emkamt GianhVG
        sum(case when af.corebank = 'Y' then 0 else RECEIVING end) CI_RECEIVING,
        sum(case when af.corebank = 'Y' then 0 else EMKAMT end) CI_EMKAMT,
        sum(case when af.corebank = 'Y' then 0 else DFDEBTAMT end) CI_DFDEBTAMT*/
        sum(balance + emkamt-holdbalance) ci_balance, --them emkamt GianhVG
        sum(RECEIVING) CI_RECEIVING,
        sum(EMKAMT) CI_EMKAMT,
        sum(DFDEBTAMT) CI_DFDEBTAMT
    from cfmast cf, afmast af, cimast ci,AFTYPE AFT
    where cf.custid = af.custid and af.acctno = ci.afacctno AND AF.ACTYPE=AFT.ACTYPE
          AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        and cf.custodycd = v_CustodyCD
        and af.acctno like v_AFAcctno
    group by  cf.custid, cf.custodycd
) cibal on cf.custid = cibal.custid
left join  (select distinct username,tokenid from userlogin where status ='A') u on cf.username = u.username
left join
(
    -- Danh sach giao dich CI: tu From Date den ToDate
    select tci.autoid orderid, tci.custid, tci.custodycd, tci.acctno afacctno, tci.tllog_autoid autoid, tci.txtype,
        tci.busdate,
        nvl(tci.trdesc,tci.txdesc) txdesc,
        --CASE WHEN TLTXCD = '3350' THEN tci.txdesc ELSE nvl(tci.trdesc,tci.txdesc) END txdesc,
        '' symbol, 0 se_credit_amt, 0 se_debit_amt,
        case when tci.txtype = 'C' then namt else 0 end ci_credit_amt,
        case when tci.txtype = 'D' then namt else 0 end ci_debit_amt,
        tci.txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, tci.dfacctno dealno,
        tci.old_dfacctno description, tci.trdesc, tci.bkdate,TCI.PRO
    from   (
            select ci.autoid, cf.custodycd, cf.custid,A0.CDCONTENT PRO,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,ALLCODE A0,
                    VW_TLLOG_ALL TL, cfmast cf, afmast af,AFTYPE AFT, apptx app --, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
                 AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
            and     ci.txnum        =    tl.txnum
            and     cf.custid       =    af.custid
            and     ci.acctno       =    af.acctno
            and     ci.txcd         =    app.txcd
            and CI.corebank <> 'Y'
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0
            and tl.tltxcd not in ('6690','6691','6621','6660','6600','6601','6602')
            UNION ALL
            SELECT 0 AUTOID, CF.custodycd, cf.custid,A0.CDCONTENT PRO, TL.txnum, TL.txdate, TL.MSGacct acctno,'D' txcd,
            (case when TL.TLTXCD IN ('6668','6650') then tl.msgamt else 0 end) namt,
            '' camt, '' ref, nvl(TL.deltd, 'N') deltd, TL.MSGacct acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            '' dfacctno,' ' old_dfacctno,
            (case when TL.TLTXCD IN ('6668','6650') then 'C' else 'D' end) txtype, 'BALANCE' field,
             tl.autoid+1 tllog_autoid,
            '' trdesc, TL.txdate bkdate
            FROM VW_TLLOG_ALL TL, cfmast cf, afmast af, AFTYPE AFT,ALLCODE A0
            where   cf.custid       =    af.custid
            and     TL.MSGacct       =    af.acctno
               AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
                AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
           -- and af.corebank <> 'Y'
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
             AND TL.TLTXCD in ('3324','6668','6650')
            ) tci
    where  tci.bkdate between v_FromDate and v_ToDate
       and tci.custodycd = v_CustodyCD
       and tci.acctno like v_AFAcctno
       and tci.field = 'BALANCE'
       AND TCI.TLTXCD NOT IN ('8855','8865','8856','8866','0066','1144','1145','8889')  -- them 2 giao dich '1144','1145' phong toa, GianhVG

       union all
       -------Tach giao dich mua ban
       select  max(tci.autoid) orderid, tci.custid, tci.custodycd, tci.acctno afacctno, max(tci.tllog_autoid) autoid, tci.txtype,
        tci.busdate, case when TCI.TLTXCD = '8865' then 'Trả tiền mua CK ngày' || to_char(max(tci.oddate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                        when TCI.TLTXCD = '8889' then 'Trả tiền mua CK ngày' || to_char(max(tci.oddate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                        when TCI.TLTXCD = '8856' then 'Trả phí bán CK ngày' || to_char(max(tci.oddate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                        when TCI.TLTXCD = '8866' then 'Nhận tiền bán CK ngày' || to_char(max(tci.oddate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                        else  'Trả phí mua CK ngày' || to_char(max(tci.oddate),'dd/mm/rrrr')--TO_CHAR(tci.busdate)
                        end TXDESC,
         '' symbol, 0 se_credit_amt, 0 se_debit_amt,
        SUM(case when tci.txtype = 'C' then namt else 0 end) ci_credit_amt,
        SUM(case when tci.txtype = 'D' then namt else 0 end) ci_debit_amt,
        '' txnum, '' tltx_name, tci.tltxcd,  tci.txdate, tci.txcd, '' dealno,
        '' description, '' trdesc, tci.bkdate,TCI.PRO
    from   (select ci.autoid, cf.custodycd, cf.custid,A0.CDCONTENT PRO,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate, od.txdate oddate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,ALLCODE A0,
                    vw_odmast_all od,
                    VW_TLLOG_ALL TL, cfmast cf, afmast af,AFTYPE AFT, apptx app --, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            and     cf.custid       =    af.custid
            and     ci.acctno       =    af.acctno
            and     ci.txcd         =    app.txcd
                    AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
            and     app.apptype     =    'CI'
               AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
            and CI.corebank <> 'Y'
            and     app.txtype      in   ('D','C')
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.ref= od.orderid
            and     ci.namt         <>  0) tci
    where  tci.bkdate between v_FromDate and v_ToDate
       and tci.custodycd = v_CustodyCD
       and tci.acctno like v_AFAcctno
       and tci.field = 'BALANCE'
         AND TCI.TLTXCD IN ('8855','8865','8856','8866','8889')
         GROUP BY tci.custid, tci.custodycd, tci.acctno ,  tci.txtype, tci.busdate, tci.tltxcd, tci.txcd,tci.txdate,tci.bkdate,TCI.PRO

      union all
       -----Thue TNCN:
     SELECT max(tci.autoid) orderid,  tci.custid, tci.custodycd, tci.acctno afacctno, max(tci.tllog_autoid) autoid, tci.txtype,
        tci.busdate, tci.description TXDESC,
        /*case when TCI.TXCD = '0011' then tci.txdesc--'Thu? TNCN CK B?ng?' || TO_CHAR(tci.busdate)
                        else  'Thu? TNCN b?CK c? t?c B?ng CP ng?' || TO_CHAR(tci.busdate) end TXDESC */
         '' symbol, 0 se_credit_amt, 0 se_debit_amt,
        SUM(case when tci.txtype = 'C' then namt else 0 end) ci_credit_amt,
        SUM(case when tci.txtype = 'D' then namt else 0 end) ci_debit_amt,
        '' txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, '' dealno,
        '' description, '' trdesc, tci.bkdate,TCI.PRO
    from   (
           select ci.autoid, cf.custodycd, cf.custid,A0.CDCONTENT PRO,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate,
            CASE WHEN ci.txcd = '0011' THEN tl.txdesc
                 WHEN ci.txcd = '0028' THEN ci.trdesc || ' Ngày' || substr(tl.txdesc, length(tl.txdesc) -10, 10)
                 END description
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,ALLCODE A0,
                    VW_TLLOG_ALL TL, cfmast cf, afmast af,AFTYPE AFT, apptx app--, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            and     cf.custid       =    af.custid
            and     ci.acctno       =    af.acctno
            and     ci.txcd         =    app.txcd
            and     app.apptype     =    'CI'
               AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
            and     app.txtype      in   ('D','C')
               AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
            and CI.corebank <> 'Y'
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0


            ) tci
    where  tci.bkdate between v_FromDate and v_ToDate
       and tci.custodycd = v_CustodyCD
       and tci.acctno like v_AFAcctno
       and tci.field = 'BALANCE'
       AND TCI.TLTXCD IN ('0066')
       GROUP BY tci.custid, tci.custodycd, tci.acctno ,  tci.txtype, tci.busdate, tci.tltxcd, tci.txcd,tci.txdate,tci.bkdate, tci.description,TCI.PRO
) tr on cf.custid = tr.custid and af.acctno = tr.afacctno

left join
(
    -- Tong phat sinh CI tu From date den ngay hom nay
    select tr.custid,
        sum(case when tr.field = 'HOLDBALANCE' then tr.namt else
            (case when tr.txtype = 'D' then -tr.namt else tr.namt end) end) ci_total_move_frdt_amt
    from   (select ci.autoid, cf.custodycd, cf.custid,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                    VW_TLLOG_ALL TL, cfmast cf, afmast af,AFTYPE AFT, apptx app--, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            and     cf.custid       =    af.custid
            and     ci.acctno       =    af.acctno
            and     ci.txcd         =    app.txcd
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
               AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and CI.corebank <> 'Y'
            and     ci.namt         <>  0) tr
    where
        tr.bkdate >= v_FromDate and tr.bkdate <= v_CurrDate
        and tr.custodycd = v_CustodyCD
        and tr.acctno like v_AFAcctno
        and tr.field in ('HOLDBALANCE','BALANCE')
        AND tr.tltxcd NOT IN ('1144','1145','6690','6691','6621','6660','6600','6601','6602') -- bo giao dich phong toa , GianhVG
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
    from   (select ci.autoid, cf.custodycd, cf.custid,
            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            --(case when tl.tltxcd in ('2670') then ci.ref else df.acctno end) dfacctno,
            ci.ref dfacctno,
            --(case when df.txdate <= '31-may-2010' then nvl(df.description, ' ') else '' end) old_dfacctno,
            ' ' old_dfacctno,
            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                    VW_TLLOG_ALL TL, cfmast cf, afmast af, AFTYPE AFT, apptx app--, VW_DFMAST_ALL df
            where   ci.txdate       =    tl.txdate
            and     ci.txnum        =    tl.txnum
            and     cf.custid       =    af.custid
            and     ci.acctno       =    af.acctno
            and     ci.txcd         =    app.txcd
            and     app.apptype     =    'CI'
            and     app.txtype      in   ('D','C')
               AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
            and CI.corebank <> 'Y'
            --and     ci.ref          =    df.lnacctno (+)
            and     tl.deltd        <>  'Y'
            and     ci.deltd        <>  'Y'
            and     ci.namt         <>  0) tr
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
    from v_getbuyorderinfo V, afmast af, cfmast cf,AFTYPE AFT
    where v.afacctno = af.acctno and af.custid = cf.custid
       AND     AF.ACTYPE       =     AFT.ACTYPE
            AND     AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        and cf.custodycd = v_CustodyCD and af.acctno like v_AFAcctno
    group by cf.custid, cf.custodycd
) secu on cf.custid = secu.custid

where
    cf.custodycd = v_CustodyCD

order by --tr.bkdate, tr.autoid, tr.txtype, tr.txnum,
         --tr.autoid, tr.bkdate, tr.txnum, tr.txtype, tr.orderid,
          tr.bkdate, tr.autoid, tr.txnum, tr.txtype, tr.orderid,
         case when tr.tltxcd = '1143' and tr.txcd = '0077' then 'Số tiền đến hạn phải thanh toán'
              when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then 'Phí ứng trước'
              else to_char(tr.txdesc)
    end ;      -- Chu y: Khong thay doi thu tu Order by


EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;

 
 
 
 
/
