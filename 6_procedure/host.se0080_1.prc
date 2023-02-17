SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0080_1 (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   PV_BRID          IN       VARCHAR2,
   TLGOUPS          IN       VARCHAR2,
   TLSCOPE          IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2
        )
   IS
-- created by NGOCVTT at 22-07-2015
-- ---------   ------  -------------------------------------------

    V_INDATE      date;
    V_FROMDATE     DATE;
    V_CURDATE       date;
    V_INBRID        VARCHAR2(4);
    V_STRBRID      VARCHAR2 (50);
    V_STROPTION    VARCHAR2(5);

    V_TPNH_CN        NUMBER;
    V_TPTH_CN        NUMBER;
    V_TPDH_CN        NUMBER;
    V_CPNY_CN        NUMBER;
    V_CPDC_CN        NUMBER;
    V_AMT            NUMBER;

    V_TPNH_CN1        NUMBER;
    V_TPTH_CN1        NUMBER;
    V_TPDH_CN1        NUMBER;
    V_CPNY_CN1        NUMBER;
    V_CPDC_CN1        NUMBER;
    V_AMT1           NUMBER;
   -- Declare program variables as shown above
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
   select varvalue into V_CURDATE from sysvar where varname = 'CURRDATE';
   V_INDATE := to_date(T_DATE, 'DD/MM/RRRR');
   V_FROMDATE  := to_date(F_DATE, 'DD/MM/RRRR');

       --TIEN MAT CUA KHACH HANG NUOC NGOAI CA NHAN
    SELECT ROUND(SUM(CI_CURR.BALANCE - NVL(CI_TR2.TR_BALANCE, 0) - NVL(SECU2.OD_BUY_SECU, 0))) AMT,
    ROUND(SUM(CI_CURR.BALANCE - NVL(CI_TR.TR_BALANCE, 0) - NVL(SECU.OD_BUY_SECU, 0))) AMT1 INTO V_AMT, V_AMT1
    FROM CIMAST CI_CURR, AFMAST AF, CFMAST CF,
        (   --- LAY CAC PHAT SINH BALANCE, EMKAMT, TRFAMT, FLOATAMT LON HON NGAY GIAO DICH THEO NGAY BKDATE(CHI CO TRONG VW_CITRAN_ALL)
            SELECT TR.ACCTNO,
                   ROUND(SUM(CASE WHEN TX.FIELD = 'BALANCE' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                            ELSE 0 END)) TR_BALANCE

            FROM  VW_CITRAN_ALL TR, APPTX TX
            WHERE TR.TXCD      =    TX.TXCD
            AND   TX.APPTYPE   =    'CI' and TR.DELTD <> 'Y'
            AND   TX.TXTYPE    IN   ('C','D')
            AND   TX.FIELD     IN   ('BALANCE')
            AND   NVL(TR.BKDATE, TR.TXDATE) > V_INDATE
            GROUP BY TR.ACCTNO
        ) CI_TR2,
        (   --- LAY GIA TRI KI QUY LENH MUA (CHI LAY DUOC NEU NGAY GD LA NGAY HIEN TAI)
            SELECT   V.afacctno,
                     (CASE WHEN V_CURDATE = V_INDATE THEN SUM(V.secureamt + V.advamt)
                      ELSE 0 END) OD_BUY_SECU
            FROM     v_getbuyorderinfo V
            GROUP BY V.afacctno
        ) SECU2,
         (   --- LAY CAC PHAT SINH BALANCE, EMKAMT, TRFAMT, FLOATAMT LON HON NGAY GIAO DICH THEO NGAY BKDATE(CHI CO TRONG VW_CITRAN_ALL)
            SELECT TR.ACCTNO,
                   ROUND(SUM(CASE WHEN TX.FIELD = 'BALANCE' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                            ELSE 0 END)) TR_BALANCE

            FROM  VW_CITRAN_ALL TR, APPTX TX
            WHERE TR.TXCD      =    TX.TXCD
            AND   TX.APPTYPE   =    'CI' and TR.DELTD <> 'Y'
            AND   TX.TXTYPE    IN   ('C','D')
            AND   TX.FIELD     IN   ('BALANCE')
            AND   NVL(TR.BKDATE, TR.TXDATE) > V_FROMDATE
            GROUP BY TR.ACCTNO
        ) CI_TR,
        (   --- LAY GIA TRI KI QUY LENH MUA (CHI LAY DUOC NEU NGAY GD LA NGAY HIEN TAI)
            SELECT   V.afacctno,
                     (CASE WHEN V_CURDATE = V_FROMDATE THEN SUM(V.secureamt + V.advamt)
                      ELSE 0 END) OD_BUY_SECU
            FROM     v_getbuyorderinfo V
            GROUP BY V.afacctno
        ) SECU
    WHERE    AF.ACCTNO               =     CI_CURR.AFACCTNO
    AND      AF.CUSTID               =     CF.CUSTID
    AND      CI_CURR.ACCTNO          =     CI_TR2.ACCTNO  (+)
    AND      CI_CURR.ACCTNO          =     SECU2.AFACCTNO (+)
    AND      CI_CURR.ACCTNO          =     CI_TR.ACCTNO  (+)
    AND      CI_CURR.ACCTNO          =     SECU.AFACCTNO (+)
    AND      CI_CURR.COREBANK        =     'N'
    AND      CF.CUSTATCOM            =      'Y'
    and      V_CURDATE             >=    V_INDATE
    AND      V_CURDATE             >=    V_FROMDATE
    AND      SUBSTR(CF.CUSTODYCD,4,1) =    'F'
    AND      CF.CUSTTYPE              =    'I';



        -- SO LUONG TRAI PHIEU, CO PHIEU  KHACH HANG NUOC NGOAI CA NHAN
       SELECT
               SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE < 365  THEN QTTY*PARVALUE ELSE 0 END) TP_NH,
               SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE >= 365  AND NUMBER_DATE <= 730 THEN QTTY*PARVALUE ELSE 0 END) TP_TH,
               SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE > 730  THEN QTTY*PARVALUE ELSE 0 END) TP_DH,
               SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
               AND TRADEPLACE IN ('001','002','005','006')  THEN QTTY*PARVALUE ELSE 0 END) CP_NY,
               SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
               AND TRADEPLACE NOT IN ('001','002','005','006')  THEN QTTY*PARVALUE ELSE 0 END) CP_DC,
               --KY TRUOC
               SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE < 365  THEN QTTY1*PARVALUE ELSE 0 END) TP_NH1,
               SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE >= 365  AND NUMBER_DATE <= 730 THEN QTTY1*PARVALUE ELSE 0 END) TP_TH1,
               SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE > 730  THEN QTTY1*PARVALUE ELSE 0 END) TP_DH1,
               SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
               AND TRADEPLACE IN ('001','002','005','006')  THEN QTTY1*PARVALUE ELSE 0 END) CP_NY1,
               SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
               AND TRADEPLACE NOT IN ('001','002','005','006')  THEN QTTY1*PARVALUE ELSE 0 END) CP_DC1
               INTO V_TPNH_CN,V_TPTH_CN,V_TPDH_CN,V_CPNY_CN,V_CPDC_CN,V_TPNH_CN1,V_TPTH_CN1,V_TPDH_CN1,V_CPNY_CN1,V_CPDC_CN1
       FROM( SELECT SEBAL.CUSTID,  NVL(TO_NUMBER(SB.EXPDATE- SB.ISSUEDATE),0) NUMBER_DATE, SB.SYMBOL,SB.SECTYPE,SB.TRADEPLACE,SB.PARVALUE,
          (case when sebal.refcodeid is null then
            (
             abs(nvl(sebal.STANDING,0)- nvl(se_field_move2.se_STANDING_move_amt,0)) --END_STANDING_BAL+
            + nvl(khop_qtty2.execqtty,0)--EXECQTTY
            + nvl(se_block.curr_block_qtty,0) - nvl(se_field_move2.se_BLOCKED_move_HCCN,0)--END_BLOCKED_BAL
            + 0 --SL_CK_CHO_RUT
            + 0 --CK_CHO_GD
            + trade - nvl(se_field_move2.se_trade_move_amt,0) +
                mortage - nvl(se_field_move2.se_MORTAGE_move_amt,0) +
                (BLOCKED-nvl(se_block.curr_block_qtty,0))
                - nvl(se_field_move2.se_BLOCKED_move_amt,0) +
                nvl(sebal.STANDING,0)- nvl(se_field_move2.se_STANDING_move_amt,0) + --Tru them cua Block
                WITHDRAW - nvl(se_field_move2.se_WITHDRAW_move_amt,0) +
                DTOCLOSE - nvl(se_field_move2.se_DTOCLOSE_move_amt,0) +
                secured - NVL(se_field_move2.se_SECURED_move_amt,0)--END_TRADE_BAL
            )
        else
            (
            nvl(trade,0) - nvl(se_field_move2.se_trade_move_amt,0) -
            nvl(order_today2.trade_sell_qtty,0) - nvl(order_today2.mtg_sell_qtty,0) +
            nvl(mortage,0) - nvl(se_field_move2.se_mortage_move_amt,0) -
            (nvl(STANDING,0) - nvl(se_field_move2.se_STANDING_move_amt,0)) +
            nvl(netting,0) - nvl(se_field_move2.se_netting_move_amt,0) +
            nvl(WITHDRAW,0) - nvl(se_field_move2.se_WITHDRAW_move_amt,0) +
            nvl(DTOCLOSE,0) - nvl(se_field_move2.se_DTOCLOSE_move_amt,0) +
            NVL(sebal.blocked,0) - nvl(se_field_move2.se_BLOCKED_move_wft,0)
            )
        end ) QTTY,
         (case when sebal.refcodeid is null then
        ( abs(nvl(sebal.STANDING,0)- nvl(se_field_move.se_STANDING_move_amt,0)) --END_STANDING_BAL+
        + nvl(khop_qtty.execqtty,0)--EXECQTTY
        + nvl(se_block.curr_block_qtty,0) - nvl(se_field_move.se_BLOCKED_move_HCCN,0)--END_BLOCKED_BAL
        + 0 --SL_CK_CHO_RUT
        + 0 --CK_CHO_GD
        + trade - nvl(se_field_move.se_trade_move_amt,0) +
            mortage - nvl(se_field_move.se_MORTAGE_move_amt,0) +
            (BLOCKED-nvl(se_block.curr_block_qtty,0))
            - nvl(se_field_move.se_BLOCKED_move_amt,0) +
            nvl(sebal.STANDING,0)- nvl(se_field_move.se_STANDING_move_amt,0) + --Tru them cua Block
            WITHDRAW - nvl(se_field_move.se_WITHDRAW_move_amt,0) +
            DTOCLOSE - nvl(se_field_move.se_DTOCLOSE_move_amt,0) +
            secured - NVL(se_field_move.se_SECURED_move_amt,0)--END_TRADE_BAL
        )
    else
        (
        nvl(trade,0) - nvl(se_field_move.se_trade_move_amt,0) -
        nvl(order_today.trade_sell_qtty,0) - nvl(order_today.mtg_sell_qtty,0) +
        nvl(mortage,0) - nvl(se_field_move.se_mortage_move_amt,0) -
        (nvl(STANDING,0) - nvl(se_field_move.se_STANDING_move_amt,0)) +
        nvl(netting,0) - nvl(se_field_move.se_netting_move_amt,0) +
        nvl(WITHDRAW,0) - nvl(se_field_move.se_WITHDRAW_move_amt,0) +
        nvl(DTOCLOSE,0) - nvl(se_field_move.se_DTOCLOSE_move_amt,0) +
        NVL(sebal.blocked,0) - nvl(se_field_move.se_BLOCKED_move_wft,0)
        )
    end ) QTTY1
    from  sbsecurities sb, issuers iss,
    (
        -- Tong so du CK hien tai group by tieu khoan, Symbol
        select se.acctno, sb.codeid, sb.refcodeid,CF.CUSTID,
            sum(trade + blocked + mortage + netting + receiving) se_balance,
            sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
            sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW,
            sum(DTOCLOSE) DTOCLOSE, SUM(secured) secured
        from semast se, (SELECT * FROM CFMAST /*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/) cf, afmast af, sbsecurities sb
        where cf.custid = af.custid and af.acctno = se.afacctno
            and cf.custatcom = 'Y'
            and SUBSTR(cf.custodycd,4,1) = 'F'
            and se.codeid = sb.codeid
            and sb.sectype <> '004'
            AND CF.CUSTTYPE='I'
        group by  se.acctno , sb.codeid, sb.refcodeid,CF.CUSTID
        --order by sb.tradeplace, nvl(sb.refcodeid,sb.codeid)
    ) sebal
    left join
( -- Tong phat sinh field cac loai so du CK tu Txdate den ngay hom nay
  select tr.acctno,
        sum(case when field = 'TRADE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end ) se_trade_move_amt,            -- Phat sinh CK giao dich
        sum(case when field = 'MORTAGE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end) se_MORTAGE_move_amt ,         -- Phat sinh CK Phong toa gom ca STANDING
        sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') <> '002' then
                                            (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_amt   ,      -- Phat sinh CK tam giu
        sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') = '002' then
                                            (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_HCCN   ,      -- Phat sinh CK tam giu
        sum(case when field = 'BLOCKED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_wft   ,      -- Phat sinh CK tam giu
        sum(case when field = 'NETTING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_NETTING_move_amt ,         -- Phat sinh CK cho giao
        sum(case when field = 'STANDING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_STANDING_move_amt,         -- Phat sinh CK cam co len TT Luu ky
        sum(case when field = 'WITHDRAW' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
        sum(case when field = 'DTOCLOSE' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_DTOCLOSE_move_amt,
        SUM(case when field = 'SECURED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_SECURED_move_amt
    from vw_setran_gen tr, afmast af
    where tr.busdate > V_FROMDATE and tr.busdate <= V_CURDATE
        and tr.sectype <> '004'
        and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE','SECURED')
        AND tr.afacctno=af.acctno
    group by tr.acctno
    ) se_field_move on sebal.acctno = se_field_move.acctno
left join
( -- so luong chung khoan ban cho giao
    select seacctno, sum(execqtty) execqtty
    from
    (
    select codeid, afacctno, seacctno, execqtty, txdate from odmast, afmast af
    where execqtty > 0
        and exectype in ('MS','NS') and odmast.deltd <> 'Y'
        and txdate <= V_FROMDATE
        AND odmast.afacctno=af.acctno
    union all
    select od.codeid, od.afacctno, od.seacctno, od.execqtty, od.txdate from odmasthist od, stschdhist sts,afmast af
    where execqtty > 0
        and od.txdate <= V_FROMDATE and od.deltd <> 'Y'
        and exectype in ('MS','NS')
        and od.orderid = sts.orgorderid and duetype = 'RM'
        and sts.deltd <> 'Y'
        and sts.cleardate > V_FROMDATE
        AND od.afacctno=af.acctno
    )
    group by seacctno
) khop_qtty on sebal.acctno = khop_qtty.seacctno
left join   -- So du chung khoan han che chuyen nhuong
    (
    select se.acctno, se.blocked curr_block_qtty
    from semast se, sbsecurities sb, afmast af
    where se.codeid = sb.codeid
        and sb.sectype <>'004'
        AND sb.tradeplace <> '005'
        AND se.afacctno=af.acctno
    ) se_block on sebal.acctno = se_block.acctno
-----------------------
left join
    (   -- Phat sinh ban chung khoan ngay hom nay
    SELECT SEACCTNO, SUM(case when V_FROMDATE = V_CURDATE then SECUREAMT else 0 end) trade_sell_qtty,
        SUM(case when V_FROMDATE = V_CURDATE then SECUREMTG else 0 end) mtg_sell_qtty,
        SUM(case when V_FROMDATE = V_CURDATE then RECEIVING else 0 end) SERECEIVING,
        SUM(case when V_FROMDATE = V_CURDATE then EXECQTTY else 0 end) khop_qtty
     FROM (
        SELECT OD.SEACCTNO,
               CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
               CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
               0 RECEIVING, CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN OD.EXECQTTY ELSE 0 END EXECQTTY
           FROM ODMAST OD, ODTYPE TYP, SYSVAR SY, afmast af
           WHERE OD.EXECTYPE IN ('NS', 'SS','MS')
               and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
               And OD.ACTYPE = TYP.ACTYPE
               AND OD.TXDATE = V_CURDATE
               AND NVL(OD.GRPORDER,'N') <> 'Y'
               AND OD.afacctno=af.acctno
        )
    GROUP BY SEACCTNO
    ) order_today on sebal.acctno = order_today.seacctno

         --------SL KY BAO CAO
      LEFT JOIN
      ( -- Tong phat sinh field cac loai so du CK tu Txdate den ngay hom nay
        select tr.acctno,
              sum(case when field = 'TRADE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end ) se_trade_move_amt,            -- Phat sinh CK giao dich
              sum(case when field = 'MORTAGE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end) se_MORTAGE_move_amt ,         -- Phat sinh CK Phong toa gom ca STANDING
              sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') <> '002' then
                                                  (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_amt   ,      -- Phat sinh CK tam giu
              sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') = '002' then
                                                  (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_HCCN   ,      -- Phat sinh CK tam giu
              sum(case when field = 'BLOCKED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_wft   ,      -- Phat sinh CK tam giu
              sum(case when field = 'NETTING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_NETTING_move_amt ,         -- Phat sinh CK cho giao
              sum(case when field = 'STANDING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_STANDING_move_amt,         -- Phat sinh CK cam co len TT Luu ky
              sum(case when field = 'WITHDRAW' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
              sum(case when field = 'DTOCLOSE' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_DTOCLOSE_move_amt,
              SUM(case when field = 'SECURED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_SECURED_move_amt
          from vw_setran_gen tr, afmast af
          where tr.busdate > V_INDATE and tr.busdate <= V_CURDATE
                 AND tr.afacctno=af.acctno
              and tr.sectype <> '004'
              and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE','SECURED')
          group by tr.acctno
          ) se_field_move2 on sebal.acctno = se_field_move2.acctno
      left join
      ( -- so luong chung khoan ban cho giao
          select seacctno, sum(execqtty) execqtty
          from
          (
          select codeid, afacctno, seacctno, execqtty, txdate from odmast, afmast af
          where execqtty > 0
              and exectype in ('MS','NS') and odmast.deltd <> 'Y'
              and txdate <= V_INDATE
              AND odmast.afacctno=af.acctno
          union all
          select od.codeid, od.afacctno, od.seacctno, od.execqtty, od.txdate
          from odmasthist od, stschdhist sts,
          afmast af
          where execqtty > 0
              and od.txdate <= V_INDATE and od.deltd <> 'Y'
              and exectype in ('MS','NS')
              and od.orderid = sts.orgorderid and duetype = 'RM'
              and sts.deltd <> 'Y'
              and sts.cleardate > V_INDATE
              AND od.afacctno=af.acctno
          )
          group by seacctno
      ) khop_qtty2 on sebal.acctno = khop_qtty2.seacctno

      left join
          (   -- Phat sinh ban chung khoan ngay hom nay
          SELECT SEACCTNO, SUM(case when V_INDATE = V_CURDATE then SECUREAMT else 0 end) trade_sell_qtty,
              SUM(case when V_INDATE = V_CURDATE then SECUREMTG else 0 end) mtg_sell_qtty,
              SUM(case when V_INDATE = V_CURDATE then RECEIVING else 0 end) SERECEIVING,
              SUM(case when V_INDATE = V_CURDATE then EXECQTTY else 0 end) khop_qtty
           FROM (
              SELECT OD.SEACCTNO,
                     CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
                     CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
                     0 RECEIVING, CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN OD.EXECQTTY ELSE 0 END EXECQTTY
                 FROM ODMAST OD, ODTYPE TYP, SYSVAR SY, afmast af
                 WHERE OD.EXECTYPE IN ('NS', 'SS','MS')
                     and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
                     And OD.ACTYPE = TYP.ACTYPE
                     AND OD.TXDATE = V_CURDATE
                     AND NVL(OD.GRPORDER,'N') <> 'Y'
                     AND od.afacctno=af.acctno
              )
          GROUP BY SEACCTNO
          ) order_today2 on sebal.acctno = order_today2.seacctno
      where sb.codeid = nvl( sebal.refcodeid,sebal.codeid)
          and sb.issuerid = iss.issuerid
          and V_CURDATE >= V_INDATE
          and V_CURDATE >= V_FROMDATE);
-------------------------------------------------------


  OPEN PV_REFCURSOR
    FOR
        SELECT 'IN' ky, V_INDATE INDATE, CF.CUSTID,CF.CUSTODYCD, CF.FULLNAME,CF.CUSTTYPE, NVL(CP_TP.TP_NH,0) TP_NH, NVL(CP_TP.TP_TH,0) TP_TH, NVL(CP_TP.TP_DH,0) TP_DH,
         NVL(CP_TP.CP_NY,0) CP_NY, NVL(CP_TP.CP_DC,0) CP_DC, NVL(TIEN.AMT,0) AMT
        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF ,
              (-- SO LUONG TRAI PHIEU, CO PHIEU
                 SELECT CUSTID,
                         SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE < 365  THEN QTTY*PARVALUE ELSE 0 END) TP_NH,
                         SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE >= 365  AND NUMBER_DATE <= 730 THEN QTTY*PARVALUE ELSE 0 END) TP_TH,
                         SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE > 730  THEN QTTY*PARVALUE ELSE 0 END) TP_DH,
                         SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                         AND TRADEPLACE IN ('001','002','005','006')  THEN QTTY*PARVALUE ELSE 0 END) CP_NY,
                         SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                         AND TRADEPLACE NOT IN ('001','002','005','006')  THEN QTTY*PARVALUE ELSE 0 END) CP_DC

                 FROM( SELECT SEBAL.CUSTID,  NVL(TO_NUMBER(SB.EXPDATE- SB.ISSUEDATE),0) NUMBER_DATE, SB.SYMBOL,SB.SECTYPE,SB.TRADEPLACE,SB.PARVALUE,
                    (case when sebal.refcodeid is null then
                      (
                       abs(nvl(sebal.STANDING,0)- nvl(se_field_move2.se_STANDING_move_amt,0)) --END_STANDING_BAL+
                      + nvl(khop_qtty2.execqtty,0)--EXECQTTY
                      + nvl(se_block.curr_block_qtty,0) - nvl(se_field_move2.se_BLOCKED_move_HCCN,0)--END_BLOCKED_BAL
                      + 0 --SL_CK_CHO_RUT
                      + 0 --CK_CHO_GD
                      + trade - nvl(se_field_move2.se_trade_move_amt,0) +
                          mortage - nvl(se_field_move2.se_MORTAGE_move_amt,0) +
                          (BLOCKED-nvl(se_block.curr_block_qtty,0))
                          - nvl(se_field_move2.se_BLOCKED_move_amt,0) +
                          nvl(sebal.STANDING,0)- nvl(se_field_move2.se_STANDING_move_amt,0) + --Tru them cua Block
                          WITHDRAW - nvl(se_field_move2.se_WITHDRAW_move_amt,0) +
                          DTOCLOSE - nvl(se_field_move2.se_DTOCLOSE_move_amt,0) +
                          secured - NVL(se_field_move2.se_SECURED_move_amt,0)--END_TRADE_BAL
                      )
                  else
                      (
                      nvl(trade,0) - nvl(se_field_move2.se_trade_move_amt,0) -
                      nvl(order_today2.trade_sell_qtty,0) - nvl(order_today2.mtg_sell_qtty,0) +
                      nvl(mortage,0) - nvl(se_field_move2.se_mortage_move_amt,0) -
                      (nvl(STANDING,0) - nvl(se_field_move2.se_STANDING_move_amt,0)) +
                      nvl(netting,0) - nvl(se_field_move2.se_netting_move_amt,0) +
                      nvl(WITHDRAW,0) - nvl(se_field_move2.se_WITHDRAW_move_amt,0) +
                      nvl(DTOCLOSE,0) - nvl(se_field_move2.se_DTOCLOSE_move_amt,0) +
                      NVL(sebal.blocked,0) - nvl(se_field_move2.se_BLOCKED_move_wft,0)
                      )
                  end ) QTTY
              from  sbsecurities sb, issuers iss,
              (
                  -- Tong so du CK hien tai group by tieu khoan, Symbol
                  select se.acctno, sb.codeid, sb.refcodeid,CF.CUSTID,
                      sum(trade + blocked + mortage + netting + receiving) se_balance,
                      sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
                      sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW,
                      sum(DTOCLOSE) DTOCLOSE, SUM(secured) secured
                  from semast se, CFMAST cf, afmast af, sbsecurities sb
                  where cf.custid = af.custid and af.acctno = se.afacctno
                      and cf.custatcom = 'Y'
                      and SUBSTR(cf.custodycd,4,1) = 'F'
                      and se.codeid = sb.codeid
                      and sb.sectype <> '004'
                      AND CF.CUSTTYPE='B'
                  group by  se.acctno , sb.codeid, sb.refcodeid,CF.CUSTID
                  --order by sb.tradeplace, nvl(sb.refcodeid,sb.codeid)
              ) sebal
              left join   -- So du chung khoan han che chuyen nhuong
                  (
                  select se.acctno, se.blocked curr_block_qtty
                  from semast se, sbsecurities sb, afmast af
                  where se.codeid = sb.codeid
                      and sb.sectype <>'004'
                      AND sb.tradeplace <> '005'
                      AND se.afacctno=af.acctno
                  ) se_block on sebal.acctno = se_block.acctno
              --------SL KY BAO CAO
              LEFT JOIN
              ( -- Tong phat sinh field cac loai so du CK tu Txdate den ngay hom nay
                select tr.acctno,
                      sum(case when field = 'TRADE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end ) se_trade_move_amt,            -- Phat sinh CK giao dich
                      sum(case when field = 'MORTAGE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end) se_MORTAGE_move_amt ,         -- Phat sinh CK Phong toa gom ca STANDING
                      sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') <> '002' then
                                                          (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_amt   ,      -- Phat sinh CK tam giu
                      sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') = '002' then
                                                          (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_HCCN   ,      -- Phat sinh CK tam giu
                      sum(case when field = 'BLOCKED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_wft   ,      -- Phat sinh CK tam giu
                      sum(case when field = 'NETTING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_NETTING_move_amt ,         -- Phat sinh CK cho giao
                      sum(case when field = 'STANDING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_STANDING_move_amt,         -- Phat sinh CK cam co len TT Luu ky
                      sum(case when field = 'WITHDRAW' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
                      sum(case when field = 'DTOCLOSE' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_DTOCLOSE_move_amt,
                      SUM(case when field = 'SECURED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_SECURED_move_amt
                  from vw_setran_gen tr, afmast af
                  where tr.busdate > V_INDATE and tr.busdate <= V_CURDATE
                         AND tr.afacctno=af.acctno
                      and tr.sectype <> '004'
                      and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE','SECURED')
                  group by tr.acctno
                  ) se_field_move2 on sebal.acctno = se_field_move2.acctno
              left join
              ( -- so luong chung khoan ban cho giao
                  select seacctno, sum(execqtty) execqtty
                  from
                  (
                  select codeid, afacctno, seacctno, execqtty, txdate from odmast, afmast af
                  where execqtty > 0
                      and exectype in ('MS','NS') and odmast.deltd <> 'Y'
                      and txdate <= V_INDATE
                      AND odmast.afacctno=af.acctno
                  union all
                  select od.codeid, od.afacctno, od.seacctno, od.execqtty, od.txdate
                  from odmasthist od, stschdhist sts,
                  afmast af
                  where execqtty > 0
                      and od.txdate <= V_INDATE and od.deltd <> 'Y'
                      and exectype in ('MS','NS')
                      and od.orderid = sts.orgorderid and duetype = 'RM'
                      and sts.deltd <> 'Y'
                      and sts.cleardate > V_INDATE
                      AND od.afacctno=af.acctno
                  )
                  group by seacctno
              ) khop_qtty2 on sebal.acctno = khop_qtty2.seacctno

              left join
                  (   -- Phat sinh ban chung khoan ngay hom nay
                  SELECT SEACCTNO, SUM(case when V_INDATE = V_CURDATE then SECUREAMT else 0 end) trade_sell_qtty,
                      SUM(case when V_INDATE = V_CURDATE then SECUREMTG else 0 end) mtg_sell_qtty,
                      SUM(case when V_INDATE = V_CURDATE then RECEIVING else 0 end) SERECEIVING,
                      SUM(case when V_INDATE = V_CURDATE then EXECQTTY else 0 end) khop_qtty
                   FROM (
                      SELECT OD.SEACCTNO,
                             CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
                             CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
                             0 RECEIVING, CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN OD.EXECQTTY ELSE 0 END EXECQTTY
                         FROM ODMAST OD, ODTYPE TYP, SYSVAR SY, afmast af
                         WHERE OD.EXECTYPE IN ('NS', 'SS','MS')
                             and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
                             And OD.ACTYPE = TYP.ACTYPE
                             AND OD.TXDATE = V_CURDATE
                             AND NVL(OD.GRPORDER,'N') <> 'Y'
                             AND od.afacctno=af.acctno
                      )
                  GROUP BY SEACCTNO
                  ) order_today2 on sebal.acctno = order_today2.seacctno
              --------------------------------------------------------------------------------------
              where sb.codeid = nvl( sebal.refcodeid,sebal.codeid)
                  and sb.issuerid = iss.issuerid
                  and V_CURDATE >= V_INDATE
               ) GROUP BY CUSTID  ) CP_TP,

               --TIEN MAT

              (SELECT  CF.CUSTID,
                      ROUND(SUM(CI_CURR.BALANCE - NVL(CI_TR2.TR_BALANCE, 0) - NVL(SECU2.OD_BUY_SECU, 0))) AMT
              FROM CIMAST CI_CURR, AFMAST AF, CFMAST CF,
                  (   --- LAY CAC PHAT SINH BALANCE, EMKAMT, TRFAMT, FLOATAMT LON HON NGAY GIAO DICH THEO NGAY BKDATE(CHI CO TRONG VW_CITRAN_ALL)
                      SELECT TR.ACCTNO,
                             ROUND(SUM(CASE WHEN TX.FIELD = 'BALANCE' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                                      ELSE 0 END)) TR_BALANCE

                      FROM  VW_CITRAN_ALL TR, APPTX TX
                      WHERE TR.TXCD      =    TX.TXCD
                      AND   TX.APPTYPE   =    'CI' and TR.DELTD <> 'Y'
                      AND   TX.TXTYPE    IN   ('C','D')
                      AND   TX.FIELD     IN   ('BALANCE')
                      AND   NVL(TR.BKDATE, TR.TXDATE) > TO_DATE(V_INDATE,'DD/MM/RRRR')
                      GROUP BY TR.ACCTNO
                  ) CI_TR2,
                  (   --- LAY GIA TRI KI QUY LENH MUA (CHI LAY DUOC NEU NGAY GD LA NGAY HIEN TAI)
                      SELECT   V.afacctno,
                               (CASE WHEN V_CURDATE = V_INDATE THEN SUM(V.secureamt + V.advamt)
                                ELSE 0 END) OD_BUY_SECU
                      FROM     v_getbuyorderinfo V
                      GROUP BY V.afacctno
                  ) SECU2
                  ----------------------------------------------------------------
              WHERE    AF.ACCTNO               =     CI_CURR.AFACCTNO
              AND      AF.CUSTID               =     CF.CUSTID
              AND      CI_CURR.ACCTNO          =     CI_TR2.ACCTNO  (+)
              AND      CI_CURR.ACCTNO          =     SECU2.AFACCTNO (+)
              AND      CI_CURR.COREBANK        =     'N'
              AND      CF.CUSTATCOM            =     'Y'
              and      V_CURDATE             >=    V_INDATE
              AND      SUBSTR(CF.CUSTODYCD,4,1) =    'F'
              AND      CF.CUSTTYPE              =    'B'
              GROUP BY CF.CUSTID) TIEN
        WHERE CF.CUSTTYPE='B'
        AND SUBSTR(CF.CUSTODYCD,4,1) =    'F'
        AND CF.CUSTID=CP_TP.CUSTID(+)
        AND CF.CUSTID=TIEN.CUSTID(+)
        AND CF.OPNDATE<= V_INDATE
        AND CF.CUSTATCOM='Y'

        UNION ALL

        SELECT 'IN' KY, V_INDATE INDATE,'' CUSTID,'' CUSTODYCD, '' FULLNAME,'I' CUSTTYPE, NVL(V_TPNH_CN,0) TP_NH, NVL(V_TPTH_CN,0) TP_TH,
          NVL(V_TPDH_CN,0) TP_DH,NVL(V_CPNY_CN,0) CP_NY, NVL(V_CPDC_CN,0) CP_DC, NVL(V_AMT,0) AMT
        FROM DUAL

        UNION ALL

      SELECT 'AOUT' ky, V_FROMDATE INDATE, CF.CUSTID,CF.CUSTODYCD, CF.FULLNAME,CF.CUSTTYPE, NVL(CP_TP.TP_NH,0) TP_NH, NVL(CP_TP.TP_TH,0) TP_TH, NVL(CP_TP.TP_DH,0) TP_DH,
         NVL(CP_TP.CP_NY,0) CP_NY, NVL(CP_TP.CP_DC,0) CP_DC, NVL(TIEN.AMT,0) AMT
        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF ,
              (-- SO LUONG TRAI PHIEU, CO PHIEU
                 SELECT CUSTID,
                         SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE < 365  THEN QTTY*PARVALUE ELSE 0 END) TP_NH,
                         SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE >= 365  AND NUMBER_DATE <= 730 THEN QTTY*PARVALUE ELSE 0 END) TP_TH,
                         SUM(CASE WHEN SECTYPE IN ('003','006','222') AND NUMBER_DATE > 730  THEN QTTY*PARVALUE ELSE 0 END) TP_DH,
                         SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                         AND TRADEPLACE IN ('001','002','005','006')  THEN QTTY*PARVALUE ELSE 0 END) CP_NY,
                         SUM(CASE WHEN SECTYPE IN ('001','002','007','008','111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                         AND TRADEPLACE NOT IN ('001','002','005','006')  THEN QTTY*PARVALUE ELSE 0 END) CP_DC

                 FROM( SELECT SEBAL.CUSTID,  NVL(TO_NUMBER(SB.EXPDATE- SB.ISSUEDATE),0) NUMBER_DATE, SB.SYMBOL,SB.SECTYPE,SB.TRADEPLACE,SB.PARVALUE,
                    (case when sebal.refcodeid is null then
                      (
                       abs(nvl(sebal.STANDING,0)- nvl(se_field_move2.se_STANDING_move_amt,0)) --END_STANDING_BAL+
                      + nvl(khop_qtty2.execqtty,0)--EXECQTTY
                      + nvl(se_block.curr_block_qtty,0) - nvl(se_field_move2.se_BLOCKED_move_HCCN,0)--END_BLOCKED_BAL
                      + 0 --SL_CK_CHO_RUT
                      + 0 --CK_CHO_GD
                      + trade - nvl(se_field_move2.se_trade_move_amt,0) +
                          mortage - nvl(se_field_move2.se_MORTAGE_move_amt,0) +
                          (BLOCKED-nvl(se_block.curr_block_qtty,0))
                          - nvl(se_field_move2.se_BLOCKED_move_amt,0) +
                          nvl(sebal.STANDING,0)- nvl(se_field_move2.se_STANDING_move_amt,0) + --Tru them cua Block
                          WITHDRAW - nvl(se_field_move2.se_WITHDRAW_move_amt,0) +
                          DTOCLOSE - nvl(se_field_move2.se_DTOCLOSE_move_amt,0) +
                          secured - NVL(se_field_move2.se_SECURED_move_amt,0)--END_TRADE_BAL
                      )
                  else
                      (
                      nvl(trade,0) - nvl(se_field_move2.se_trade_move_amt,0) -
                      nvl(order_today2.trade_sell_qtty,0) - nvl(order_today2.mtg_sell_qtty,0) +
                      nvl(mortage,0) - nvl(se_field_move2.se_mortage_move_amt,0) -
                      (nvl(STANDING,0) - nvl(se_field_move2.se_STANDING_move_amt,0)) +
                      nvl(netting,0) - nvl(se_field_move2.se_netting_move_amt,0) +
                      nvl(WITHDRAW,0) - nvl(se_field_move2.se_WITHDRAW_move_amt,0) +
                      nvl(DTOCLOSE,0) - nvl(se_field_move2.se_DTOCLOSE_move_amt,0) +
                      NVL(sebal.blocked,0) - nvl(se_field_move2.se_BLOCKED_move_wft,0)
                      )
                  end ) QTTY
              from  sbsecurities sb, issuers iss,
              (
                  -- Tong so du CK hien tai group by tieu khoan, Symbol
                  select se.acctno, sb.codeid, sb.refcodeid,CF.CUSTID,
                      sum(trade + blocked + mortage + netting + receiving) se_balance,
                      sum(trade) trade, sum(blocked) blocked, sum(mortage) mortage, sum(netting) netting,
                      sum(STANDING) STANDING, sum(RECEIVING) RECEIVING, sum(WITHDRAW) WITHDRAW,
                      sum(DTOCLOSE) DTOCLOSE, SUM(secured) secured
                  from semast se, CFMAST cf, afmast af, sbsecurities sb
                  where cf.custid = af.custid and af.acctno = se.afacctno
                      and cf.custatcom = 'Y'
                      and SUBSTR(cf.custodycd,4,1) = 'F'
                      and se.codeid = sb.codeid
                      and sb.sectype <> '004'
                      AND CF.CUSTTYPE='B'
                  group by  se.acctno , sb.codeid, sb.refcodeid,CF.CUSTID
                  --order by sb.tradeplace, nvl(sb.refcodeid,sb.codeid)
              ) sebal
              left join   -- So du chung khoan han che chuyen nhuong
                  (
                  select se.acctno, se.blocked curr_block_qtty
                  from semast se, sbsecurities sb, afmast af
                  where se.codeid = sb.codeid
                      and sb.sectype <>'004'
                      AND sb.tradeplace <> '005'
                      AND se.afacctno=af.acctno
                  ) se_block on sebal.acctno = se_block.acctno
              --------SL KY BAO CAO
              LEFT JOIN
              ( -- Tong phat sinh field cac loai so du CK tu Txdate den ngay hom nay
                select tr.acctno,
                      sum(case when field = 'TRADE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end ) se_trade_move_amt,            -- Phat sinh CK giao dich
                      sum(case when field = 'MORTAGE' then case when tr.txtype = 'D' then -tr.namt else tr.namt end else 0 end) se_MORTAGE_move_amt ,         -- Phat sinh CK Phong toa gom ca STANDING
                      sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') <> '002' then
                                                          (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_amt   ,      -- Phat sinh CK tam giu
                      sum(case when field = 'BLOCKED' and nvl(tr.REF,' ') = '002' then
                                                          (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_HCCN   ,      -- Phat sinh CK tam giu
                      sum(case when field = 'BLOCKED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_BLOCKED_move_wft   ,      -- Phat sinh CK tam giu
                      sum(case when field = 'NETTING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_NETTING_move_amt ,         -- Phat sinh CK cho giao
                      sum(case when field = 'STANDING' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_STANDING_move_amt,         -- Phat sinh CK cam co len TT Luu ky
                      sum(case when field = 'WITHDRAW' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_WITHDRAW_move_amt,         -- Phat sinh CK cho nhan ve
                      sum(case when field = 'DTOCLOSE' then (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_DTOCLOSE_move_amt,
                      SUM(case when field = 'SECURED' THEN (case when tr.txtype = 'D' then -tr.namt else tr.namt end) else 0 end) se_SECURED_move_amt
                  from vw_setran_gen tr, afmast af
                  where tr.busdate > V_FROMDATE and tr.busdate <= V_CURDATE
                         AND tr.afacctno=af.acctno
                      and tr.sectype <> '004'
                      and tr.field in ('TRADE','MORTAGE','BLOCKED','NETTING','STANDING','RECEIVING','WITHDRAW','DTOCLOSE','SECURED')
                  group by tr.acctno
                  ) se_field_move2 on sebal.acctno = se_field_move2.acctno
              left join
              ( -- so luong chung khoan ban cho giao
                  select seacctno, sum(execqtty) execqtty
                  from
                  (
                  select codeid, afacctno, seacctno, execqtty, txdate from odmast, afmast af
                  where execqtty > 0
                      and exectype in ('MS','NS') and odmast.deltd <> 'Y'
                      and txdate <= V_FROMDATE
                      AND odmast.afacctno=af.acctno
                  union all
                  select od.codeid, od.afacctno, od.seacctno, od.execqtty, od.txdate
                  from odmasthist od, stschdhist sts,
                  afmast af
                  where execqtty > 0
                      and od.txdate <= V_FROMDATE and od.deltd <> 'Y'
                      and exectype in ('MS','NS')
                      and od.orderid = sts.orgorderid and duetype = 'RM'
                      and sts.deltd <> 'Y'
                      and sts.cleardate > V_FROMDATE
                      AND od.afacctno=af.acctno
                  )
                  group by seacctno
              ) khop_qtty2 on sebal.acctno = khop_qtty2.seacctno

              left join
                  (   -- Phat sinh ban chung khoan ngay hom nay
                  SELECT SEACCTNO, SUM(case when V_FROMDATE = V_CURDATE then SECUREAMT else 0 end) trade_sell_qtty,
                      SUM(case when V_FROMDATE = V_CURDATE then SECUREMTG else 0 end) mtg_sell_qtty,
                      SUM(case when V_FROMDATE = V_CURDATE then RECEIVING else 0 end) SERECEIVING,
                      SUM(case when V_FROMDATE = V_CURDATE then EXECQTTY else 0 end) khop_qtty
                   FROM (
                      SELECT OD.SEACCTNO,
                             CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
                             CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
                             0 RECEIVING, CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN OD.EXECQTTY ELSE 0 END EXECQTTY
                         FROM ODMAST OD, ODTYPE TYP, SYSVAR SY, afmast af
                         WHERE OD.EXECTYPE IN ('NS', 'SS','MS')
                             and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
                             And OD.ACTYPE = TYP.ACTYPE
                             AND OD.TXDATE = V_CURDATE
                             AND NVL(OD.GRPORDER,'N') <> 'Y'
                             AND od.afacctno=af.acctno
                      )
                  GROUP BY SEACCTNO
                  ) order_today2 on sebal.acctno = order_today2.seacctno
              --------------------------------------------------------------------------------------
              where sb.codeid = nvl( sebal.refcodeid,sebal.codeid)
                  and sb.issuerid = iss.issuerid
                  and V_CURDATE >= V_FROMDATE
               ) GROUP BY CUSTID  ) CP_TP,

               --TIEN MAT

              (SELECT  CF.CUSTID,
                      ROUND(SUM(CI_CURR.BALANCE - NVL(CI_TR2.TR_BALANCE, 0) - NVL(SECU2.OD_BUY_SECU, 0))) AMT
              FROM CIMAST CI_CURR, AFMAST AF, CFMAST CF,
                  (   --- LAY CAC PHAT SINH BALANCE, EMKAMT, TRFAMT, FLOATAMT LON HON NGAY GIAO DICH THEO NGAY BKDATE(CHI CO TRONG VW_CITRAN_ALL)
                      SELECT TR.ACCTNO,
                             ROUND(SUM(CASE WHEN TX.FIELD = 'BALANCE' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                                      ELSE 0 END)) TR_BALANCE

                      FROM  VW_CITRAN_ALL TR, APPTX TX
                      WHERE TR.TXCD      =    TX.TXCD
                      AND   TX.APPTYPE   =    'CI' and TR.DELTD <> 'Y'
                      AND   TX.TXTYPE    IN   ('C','D')
                      AND   TX.FIELD     IN   ('BALANCE')
                      AND   NVL(TR.BKDATE, TR.TXDATE) > TO_DATE(V_FROMDATE,'DD/MM/RRRR')
                      GROUP BY TR.ACCTNO
                  ) CI_TR2,
                  (   --- LAY GIA TRI KI QUY LENH MUA (CHI LAY DUOC NEU NGAY GD LA NGAY HIEN TAI)
                      SELECT   V.afacctno,
                               (CASE WHEN V_CURDATE = V_FROMDATE THEN SUM(V.secureamt + V.advamt)
                                ELSE 0 END) OD_BUY_SECU
                      FROM     v_getbuyorderinfo V
                      GROUP BY V.afacctno
                  ) SECU2
                  ----------------------------------------------------------------
              WHERE    AF.ACCTNO               =     CI_CURR.AFACCTNO
              AND      AF.CUSTID               =     CF.CUSTID
              AND      CI_CURR.ACCTNO          =     CI_TR2.ACCTNO  (+)
              AND      CI_CURR.ACCTNO          =     SECU2.AFACCTNO (+)
              AND      CI_CURR.COREBANK        =     'N'
              AND      CF.CUSTATCOM            =     'Y'
              and      V_CURDATE             >=    V_FROMDATE
              AND      SUBSTR(CF.CUSTODYCD,4,1) =    'F'
              AND      CF.CUSTTYPE              =    'B'
              GROUP BY CF.CUSTID) TIEN
        WHERE CF.CUSTTYPE='B'
        AND SUBSTR(CF.CUSTODYCD,4,1) =    'F'
        AND CF.CUSTID=CP_TP.CUSTID(+)
        AND CF.CUSTID=TIEN.CUSTID(+)
        AND CF.OPNDATE<= V_FROMDATE
        AND CF.CUSTATCOM='Y'

        UNION ALL

        SELECT 'AOUT' KY, V_FROMDATE INDATE,'' CUSTID,'' CUSTODYCD, '' FULLNAME,'I' CUSTTYPE, NVL(V_TPNH_CN1,0) TP_NH, NVL(V_TPTH_CN1,0) TP_TH,
          NVL(V_TPDH_CN1,0) TP_DH,NVL(V_CPNY_CN1,0) CP_NY, NVL(V_CPDC_CN1,0) CP_DC, NVL(V_AMT1,0) AMT
        FROM DUAL


        ORDER BY    KY, CUSTTYPE, CUSTODYCD
        ;

EXCEPTION
    WHEN OTHERS
   THEN
      RETURN;
END; -- Procedure
 
/
