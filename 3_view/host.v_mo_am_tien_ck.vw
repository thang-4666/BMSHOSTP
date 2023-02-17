SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_MO_AM_TIEN_CK
(TODAY, CUSTODYCD, SYMBOL, MARKET, HAN_CHE_CN, 
 GIAO_DICH, SAN_PHAM, PHONG_TOA, CHO_RUT, CHO_GIAO, 
 CAM_CO, CHO_VE, SOLIEU_VSD)
BEQUEATH DEFINER
AS 
SELECT TO_DATE (SYSDATE),
            sebal.custodycd,
            sebal.symbol,
            a.cdcontent MARKET,
              NVL (se_block.curr_block_qtty, 0)
            - NVL (se_block_move.cr_block_amt, 0)
            + NVL (se_block_move.dr_block_amt, 0)
               AS Han_Che_CN,                         -- Han che chuyen nhuong
              NVL (trade, 0)
            - NVL (se_trade_move_amt, 0)
            - NVL (trade_sell_qtty, 0)
               AS Giao_Dich,
              NVL (mortage, 0)
            + NVL (STANDING, 0)
            - NVL (mtg_sell_qtty, 0)
            - NVL (se_mortage_move_amt, 0)
            - NVL (se_STANDING_move_amt, 0)
               AS San_Pham,
              NVL (blocked, 0)
            - NVL (se_blocked_move_amt, 0)
            - (  NVL (se_block.curr_block_qtty, 0)
               - NVL (se_block_move.cr_block_amt, 0)
               + NVL (se_block_move.dr_block_amt, 0))
               AS Phong_toa,
            NVL (WITHDRAW, 0) - NVL (se_WITHDRAW_move_amt, 0) AS Cho_Rut,
              NVL (netting, 0)
            - NVL (se_netting_move_amt, 0)
            + NVL (trade_sell_qtty, 0)
            + NVL (mtg_sell_qtty, 0)
               AS Cho_Giao,                                          -- Cho TT
            - (NVL (STANDING, 0) - NVL (se_STANDING_move_amt, 0)) AS Cam_Co, -- Do standing luon <=0
              NVL (RECEIVING, 0)
            - NVL (se_RECEIVING_move_amt, 0)
            + NVL (order_buy_today.receiving_qtty, 0)
               AS Cho_Ve,
              (  NVL (trade, 0)
               - NVL (se_trade_move_amt, 0)
               - NVL (trade_sell_qtty, 0))                   -- Flex Giao dich
            + (  NVL (mortage, 0)
               + NVL (STANDING, 0)
               - NVL (mtg_sell_qtty, 0)
               - NVL (se_mortage_move_amt, 0)
               - NVL (se_STANDING_move_amt, 0)
               + (  NVL (blocked, 0)
                  - NVL (se_blocked_move_amt, 0)
                  - (  NVL (se_block.curr_block_qtty, 0)
                     - NVL (se_block_move.cr_block_amt, 0)
                     + NVL (se_block_move.dr_block_amt, 0))) --- phong toa khac
                                                            )     -- Phong_Toa
            + NVL (WITHDRAW, 0)
            - NVL (se_WITHDRAW_move_amt, 0)                         -- Cho rut
               AS solieu_VSD           -- So luong giao dich tuong ung voi VSD
       FROM (            -- Tong so du CK hien tai group by tieu khoan, Symbol
             SELECT   cf.custodycd,
                      sb.symbol,
                      se.acctno seacctno,
                      SUM (trade + blocked + mortage + netting + receiving)
                         se_balance,
                      SUM (trade) trade,
                      SUM (blocked) blocked,
                      SUM (mortage) mortage,
                      SUM (netting) netting,
                      SUM (STANDING) STANDING,
                      SUM (RECEIVING) RECEIVING,
                      SUM (WITHDRAW) WITHDRAW
                 FROM semast se,
                      sbsecurities sb,
                      cfmast cf,
                      (                                           -- DS TK vay
                       SELECT cf.custodycd, af.acctno
                         FROM vw_lnmast_all LN, afmast af, cfmast cf
                        WHERE     ftype = 'AF'
                              AND LN.orlsamt - LN.oprinpaid <> 0
                              AND af.custid = cf.custid
                              AND LN.trfacctno = af.acctno) LN
                WHERE     cf.custid = se.custid
                      AND LN.custodycd = cf.custodycd
                      AND se.codeid = sb.codeid
                      AND sb.sectype <> '004'
             GROUP BY cf.custodycd, sb.symbol, se.acctno) sebal
            INNER JOIN sbsecurities sb ON sebal.symbol = sb.symbol
            INNER JOIN allcode a
               ON     sb.tradeplace = a.cdval
                  AND a.cdname = 'TRADEPLACE'
                  AND a.cdtype = 'SE'
            LEFT JOIN
            (                        -- Phat sinh ban chung khoan ngay hom nay
             SELECT   se.afacctno,
                      symbol,
                      se.acctno seacctno,
                      SUM (SECUREAMT) trade_sell_qtty,
                      SUM (SECUREMTG) mtg_sell_qtty
                 FROM semast se, v_getsellorderinfo v, sbsecurities sb
                WHERE     se.acctno = v.seacctno
                      AND se.codeid = sb.codeid
                      AND sb.sectype <> '004'
             GROUP BY se.afacctno, symbol, se.acctno) order_today
               ON sebal.seacctno = order_today.seacctno
            LEFT JOIN
            (                        -- Phat sinh mua chung khoan ngay hom nay
             SELECT   se.afacctno,
                      symbol,
                      se.acctno seacctno,
                      SUM (qtty) receiving_qtty
                 FROM semast se, sbsecurities sb, stschd st
                WHERE     se.codeid = sb.codeid
                      AND se.acctno = st.acctno
                      AND st.duetype = 'RS'
                      AND st.status = 'N'
                      AND sb.sectype <> '004'
                      AND st.txdate =
                             (SELECT TO_DATE (varvalue, 'DD/MM/RRRR')
                                FROM sysvar
                               WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
             GROUP BY se.afacctno, symbol, se.acctno) order_buy_today
               ON sebal.seacctno = order_buy_today.seacctno
            LEFT JOIN
            ( -- Tong phat sinh field cac loai so du CK tu Ondate den ngay hom nay
             SELECT   se.afacctno,
                      symbol,
                      se.acctno seacctno,
                      SUM (
                         CASE
                            WHEN field = 'TRADE'
                            THEN
                               CASE
                                  WHEN apptx.txtype = 'D' THEN -tr.namt
                                  ELSE tr.namt
                               END
                            ELSE
                               0
                         END)
                         se_trade_move_amt,          -- Phat sinh CK giao dich
                      SUM (
                         CASE
                            WHEN field = 'MORTAGE'
                            THEN
                               CASE
                                  WHEN apptx.txtype = 'D' THEN -tr.namt
                                  ELSE tr.namt
                               END
                            ELSE
                               0
                         END)
                         se_MORTAGE_move_amt, -- Phat sinh CK Phong toa gom ca STANDING
                      SUM (
                         CASE
                            WHEN field = 'BLOCKED'
                            THEN
                               (CASE
                                   WHEN apptx.txtype = 'D' THEN -tr.namt
                                   ELSE tr.namt
                                END)
                            ELSE
                               0
                         END)
                         se_BLOCKED_move_amt,          -- Phat sinh CK tam giu
                      SUM (
                         CASE
                            WHEN field = 'NETTING'
                            THEN
                               (CASE
                                   WHEN apptx.txtype = 'D' THEN -tr.namt
                                   ELSE tr.namt
                                END)
                            ELSE
                               0
                         END)
                         se_NETTING_move_amt,         -- Phat sinh CK cho giao
                      SUM (
                         CASE
                            WHEN field = 'STANDING'
                            THEN
                               (CASE
                                   WHEN apptx.txtype = 'D' THEN -tr.namt
                                   ELSE tr.namt
                                END)
                            ELSE
                               0
                         END)
                         se_STANDING_move_amt, -- Phat sinh CK cam co len TT Luu ky
                      SUM (
                         CASE
                            WHEN field = 'RECEIVING'
                            THEN
                               (CASE
                                   WHEN apptx.txtype = 'D' THEN -tr.namt
                                   ELSE tr.namt
                                END)
                            ELSE
                               0
                         END)
                         se_RECEIVING_move_amt,    -- Phat sinh CK cho nhan ve
                      SUM (
                         CASE
                            WHEN field = 'WITHDRAW'
                            THEN
                               (CASE
                                   WHEN apptx.txtype = 'D' THEN -tr.namt
                                   ELSE tr.namt
                                END)
                            ELSE
                               0
                         END)
                         se_WITHDRAW_move_amt      -- Phat sinh CK cho nhan ve
                 FROM semast se,
                      vw_tllog_setran_all tr,
                      apptx,
                      sbsecurities sb
                WHERE     se.acctno = tr.acctno
                      AND tr.txcd = apptx.txcd
                      AND sb.codeid = se.codeid
                      AND tr.busdate >
                             (SELECT TO_DATE (varvalue, 'DD/MM/RRRR')
                                FROM sysvar
                               WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
                      AND se.afacctno LIKE '%'
                      AND sb.symbol LIKE '%'
                      AND sb.sectype <> '004'
                      AND apptx.field IN ('TRADE',
                                          'MORTAGE',
                                          'BLOCKED',
                                          'NETTING',
                                          'STANDING',
                                          'RECEIVING',
                                          'WITHDRAW')
                      AND apptx.apptype = 'SE'
                      AND apptx.txtype IN ('D', 'C')
             GROUP BY se.afacctno, sb.symbol, se.acctno) se_field_move
               ON sebal.seacctno = se_field_move.seacctno
            LEFT JOIN          -- So du chung khoan chuyen nhuong co dieu kien
                     (  SELECT se.afacctno,
                               sb.symbol,
                               se.acctno seacctno,
                               SUM (se.blocked) curr_block_qtty
                          FROM semast se, sbsecurities sb
                         WHERE se.codeid = sb.codeid AND sb.sectype <> '004'
                      GROUP BY se.afacctno, sb.symbol, se.acctno) se_block
               ON sebal.seacctno = se_block.seacctno
            LEFT JOIN -- Phat sinh giao dich phong toa/giai toa CK chuyen nhuong co dieu kien
            (  SELECT se.afacctno,
                      sb.symbol,
                      se.acctno seacctno,
                      SUM (CASE WHEN fld.tltxcd = '2202' THEN fld.nvalue ELSE 0 END)
                         cr_block_amt,
                      SUM (CASE WHEN fld.tltxcd = '2203' THEN fld.nvalue ELSE 0 END)
                         dr_block_amt
                 FROM vw_tllog_setran_all tr,
                      semast se,
                      sbsecurities sb,
                      apptx,
                      (SELECT tl.txnum,
                              tl.txdate,
                              tl.busdate,
                              tl.tltxcd,
                              TO_NUMBER (nvalue) nvalue
                         FROM vw_tllogfld_all fld,
                              (SELECT n.txnum,
                                      n.txdate,
                                      n.busdate,
                                      n.tltxcd
                                 FROM vw_tllogfld_all m, vw_tllog_all n
                                WHERE     m.txdate = n.txdate
                                      AND m.txnum = n.txnum
                                      AND fldcd = '12'
                                      AND n.tltxcd IN ('2202', '2203')
                                      AND cvalue = '002'
                                      AND n.busdate >
                                             (SELECT TO_DATE (varvalue,
                                                              'DD/MM/RRRR')
                                                FROM sysvar
                                               WHERE     varname = 'CURRDATE'
                                                     AND grname = 'SYSTEM')) tl
                        WHERE     fld.txdate = tl.txdate
                              AND fld.txnum = tl.txnum
                              AND fld.fldcd = '10') fld
                WHERE     tr.txdate = fld.txdate
                      AND tr.txnum = fld.txnum
                      AND tr.acctno = se.acctno
                      AND se.codeid = sb.codeid
                      AND tr.txcd = apptx.txcd
                      AND apptx.field = 'BLOCKED'
                      AND apptx.apptype = 'SE'
                      AND sb.sectype <> '004'
             GROUP BY se.afacctno, sb.symbol, se.acctno) se_block_move
               ON sebal.seacctno = se_block_move.seacctno
      WHERE (  ABS (NVL (trade, 0) - NVL (se_trade_move_amt, 0))
             + ABS (NVL (blocked, 0) - NVL (se_blocked_move_amt, 0))
             + ABS (NVL (mortage, 0) - NVL (se_mortage_move_amt, 0))
             + ABS (NVL (netting, 0) - NVL (se_netting_move_amt, 0))
             + ABS (- (NVL (STANDING, 0) - NVL (se_STANDING_move_amt, 0)))
             + ABS (NVL (RECEIVING, 0) - NVL (se_RECEIVING_move_amt, 0))
             + ABS (NVL (WITHDRAW, 0) - NVL (se_WITHDRAW_move_amt, 0))
             + ABS (se_balance)) > 0
   ORDER BY sebal.custodycd, symbol
/
