SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_dealers AS
    PROCEDURE pr_log_alert(notes IN varchar2, acctno IN varchar2, symbol IN varchar2,side IN varchar2,
        qtty IN varchar2, price IN varchar2, tellerid IN varchar2);
    FUNCTION fn_alertproptradeorder(f_language IN varchar2, f_acctno IN varchar2, f_side IN varchar2, f_symbol IN varchar2,
                f_quantity IN varchar2, f_price IN varchar2, f_traderid IN varchar2) RETURN  varchar;
    FUNCTION fn_checkproptradeorder(f_language IN varchar2, f_acctno IN varchar2, f_side IN varchar2, f_symbol IN varchar2,
                f_quantity IN varchar2, f_price IN varchar2, f_traderid IN varchar2) RETURN  varchar;
    FUNCTION fn_get_errdesc(f_language IN varchar2, f_errcode IN varchar2) RETURN  varchar;

END CSPKS_DEALERS;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_dealers AS
  PROCEDURE pr_log_alert(notes IN varchar2, acctno IN varchar2, symbol IN varchar2,side IN varchar2,
        qtty IN varchar2, price IN varchar2, tellerid IN varchar2) is
  BEGIN
    pr_error('cspks_dealers.pr_log_alert','Vao roi');
    INSERT INTO CFAFTRDALERTLOG (AUTOID, TXDATE, SYMBOL, TRADERID, NOTES,
      SIDE, QTTY, PRICE, AFACCTNO, SYSTIME)
    SELECT SEQ_CFAFTRDALERTLOG.NEXTVAL, TO_DATE(VARVALUE, 'DD/MM/RRRR'), symbol, tellerid,
      notes, side, qtty, price, acctno, SYSTIMESTAMP
    FROM SYSVAR WHERE VARNAME='CURRDATE';
    pr_error('cspks_dealers.pr_log_alert','Ra roi');
    return;
  EXCEPTION
    WHEN OTHERS THEN
      pr_error('cspks_dealers.pr_log_alert',SQLERRM || 'Dong:' || dbms_utility.format_error_backtrace);

  END;

  --Get error message
  FUNCTION fn_get_errdesc (f_language IN varchar2, f_errcode IN varchar2) RETURN varchar
  AS
    ret VARCHAR(500);
  BEGIN
    IF (f_language!='EN') THEN
    BEGIN
      case f_errcode
        when 'msgDEALER_SYMBOL_BUYAMT' then ret := UTF8NUMS.c_SYMBOL_BUYAMT;
        when 'msgDEALER_ADMIN_NOTPLO' then ret := UTF8NUMS.c_ADMIN_NOTPLO;
        when 'msgDEALER_CHECK_FAILED' then ret := UTF8NUMS.c_CHECK_FAILED;
        when 'msgDEALER_COMPANY_MAXNAV' then ret := UTF8NUMS.c_COMPANY_MAXNAV;
        when 'msgDEALER_COMPANY_MAXQTTYORDER' then ret := UTF8NUMS.c_COMPANY_MAXQTTYORDER;
        when 'msgDEALER_GROUP_MAXNAV' then ret := UTF8NUMS.c_GROUP_MAXNAV;
        when 'msgDEALER_LEADER_NOTPLO' then ret := UTF8NUMS.c_LEADER_NOTPLO;
        when 'msgDEALER_OVER_DELTA_BUYING_PRICE' then ret := UTF8NUMS.c_OVER_DELTA_BUYING_PRICE;
        when 'msgDEALER_OVER_DELTA_SELLING_PRICE' then ret := UTF8NUMS.c_OVER_DELTA_SELLING_PRICE;
        when 'msgDEALER_OVER_MAX_BUYING_PRICE' then ret := UTF8NUMS.c_OVER_MAX_BUYING_PRICE;
        when 'msgDEALER_OVER_MIN_SELLING_PRICE' then ret := UTF8NUMS.c_OVER_MIN_SELLING_PRICE;
        when 'msgDEALER_OVER_SYS_CURRENT_NAV_ALL' then ret := UTF8NUMS.c_OVER_SYS_CURRENT_NAV_ALL;
        when 'msgDEALER_OVER_SYS_MAX_QTTY_PER_ORDER' then ret := UTF8NUMS.c_OVER_SYS_MAX_QTTY_PER_ORDER;
        when 'msgDEALER_OVER_TOTAL_QTTY' then ret := UTF8NUMS.c_OVER_TOTAL_QTTY;
        when 'msgDEALER_SYMBOL_BUYPRICE' then ret := UTF8NUMS.c_SYMBOL_BUYPRICE;
        when 'msgDEALER_SYMBOL_CANNOT_TRADE' then ret := UTF8NUMS.c_SYMBOL_CANNOT_TRADE;
        when 'msgDEALER_SYMBOL_MAXAVL' then ret := UTF8NUMS.c_SYMBOL_MAXAVL;
        when 'msgDEALER_SYMBOL_MINAVL' then ret := UTF8NUMS.c_SYMBOL_MINAVL;
        when 'msgDEALER_SYMBOL_SELLAMT' then ret := UTF8NUMS.c_SYMBOL_SELLAMT;
        when 'msgDEALER_SYMBOL_SELLPRICE' then ret := UTF8NUMS.c_SYMBOL_SELLPRICE;
        when 'msgDEALER_TRADER_CANNOT_PLACE_ORDER' then ret := UTF8NUMS.c_TRADER_CANNOT_PLACE_ORDER;
        when 'msgDEALER_TRADER_MAXNAV' then ret := UTF8NUMS.c_TRADER_MAXNAV;
        when 'msgDEALER_TRADER_MAXALLSELL' then ret := UTF8NUMS.c_TRADER_MAXALLSELL;
        when 'msgDEALER_TRADER_MAXALLBUY' then ret := UTF8NUMS.c_TRADER_MAXALLBUY;
        when 'ALERT_OVER_TRD_G_LISTEDQTTY' then ret := UTF8NUMS.c_ALERT_OVER_TRD_G_LISTEDQTTY;
        ---when 'ALERT_OVER_TRD_L_LISTEDQTTY' then ret := UTF8NUMS.c_ALERT_OVER_TRD_L_LISTEDQTTY;
        when 'ALERT_MKT_G_AVGQTTY' then ret := UTF8NUMS.c_ALERT_MKT_G_AVGQTTY;
        when 'ALERT_OVER_TRD_L_LISTEDQTTY' then ret := UTF8NUMS.c_ALERT_OVER_TRD_L_LISTEDQTTY;
        when 'ALERT_OVER_BAL_G_LISTEDQTTY' then ret := UTF8NUMS.c_ALERT_OVER_BAL_G_LISTEDQTTY;
        when 'ALERT_OVER_TOTAL_QTTY' then ret := UTF8NUMS.c_ALERT_OVER_TOTAL_QTTY;
        when 'ALERT_OVER_MIN_QTTY_PRICE' then ret := UTF8NUMS.c_ALERT_OVER_MIN_QTTY_PRICE;
        else ret := f_errcode;
      end case;
    END;
    ELSE
    BEGIN
      ret := f_errcode;
    END;
    END IF;
    RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
      ret := SQLERRM;  --M??i c?a ORACLE

  END;

  --Check policy for traders
  FUNCTION fn_alertproptradeorder (f_language IN varchar2, f_acctno IN  varchar2, f_side IN  varchar2, f_symbol in varchar2,
      f_quantity in varchar2, f_price in varchar2, f_traderid in varchar2) RETURN varchar
  AS
    l_codeid VARCHAR(50);
    alertcd VARCHAR(50);
    operatorcd VARCHAR(50);
    trgval float;
    marketval float;
    currentval float;
    notes VARCHAR(500);
    srcreffield VARCHAR(200);
    ret VARCHAR(500);
    l_number float;

    V_CURRDATE  DATE;
    V_TOTALQTTY NUMBER;


    CURSOR C_DEPT IS
      SELECT MST.ALERTCD, MST.OPERATORCD, MST.TRGVAL, MST.NOTES, MST.SRCREFFIELD
      FROM CFAFTRDALERT MST, SBSECURITIES RF
      WHERE MST.CODEID=RF.CODEID AND MST.STATUS='A' AND SYMBOL=f_symbol;
  BEGIN

    ret := '';
    return ret;

    OPEN C_DEPT;
    FETCH C_DEPT INTO alertcd, operatorcd, trgval, notes, srcreffield;
    WHILE C_DEPT%FOUND
    LOOP
      BEGIN
        /*
        MKT_G_AVGQTTY     Giao d?ch vu?t x% KL b? qu?giao d?ch
        TRD_G_LISTEDQTTY  Giao d?ch vu?t x% KL luu h?

        TRD_L_LISTEDQTTY  Giao d?ch gi?m x% kh?i lu?ng luu h?
        BAL_G_LISTEDQTTY  N?m gi? vu?t x% KL luu h?
        */

    SELECT MAX(TO_DATE(VARVALUE,'DD/MM/RRRR')) INTO V_CURRDATE
    FROM SYSVAR WHERE VARNAME = 'CURRDATE' AND GRNAME = 'SYSTEM';

select sum((SE.TRADE+se.BLOCKED+se.EMKQTTY+se.MORTAGE+nvl(SE.RECEIVING,0)+
    nvl(order_buy_today.receiving_qtty,0))-
    (nvl(khop_qtty.execqtty,0) + (se.WITHDRAW+se.DTOCLOSE+se.BLOCKWITHDRAW+se.BLOCKDTOCLOSE)))
    INTO V_TOTALQTTY
FROM (SELECT DISTINCT AFACCTNO FROM cfaftrdlnk) cfaf,
    (
        SELECT SB.CODEID,  SB.SYMBOL
        FROM SBSECURITIES SB
        WHERE sb.sectype <> '004'
            AND SB.SYMBOL = f_symbol
        UNION ALL
        SELECT SB.CODEID,  SB.SYMBOL
        FROM SBSECURITIES SB
        WHERE sb.sectype <> '004'
            AND SB.SYMBOL = f_symbol || '_WFT'
    ) SB , SEMAST SE
    left join
    (   -- Phat sinh mua chung khoan trong ngay
        SELECT seacctno acctno,
            sum(case when exectype = 'NB' THEN (orderqtty-cancelqtty) ELSE -(orderqtty-cancelqtty) END) receiving_qtty
        FROM ODMAST
        WHERE DELTD = 'N' AND exectype IN ('NB','MS','NS')
            AND TXDATE = getcurrdate
        GROUP BY seacctno

    ) order_buy_today on se.acctno = order_buy_today.acctno
    left join
    (--- so luong chung khoan ban cho giao
        select seacctno, sum(execqtty) execqtty
        from
        (
            select codeid, afacctno, seacctno, execqtty, txdate
            from odmast
            where execqtty > 0
                and exectype in ('MS','NS')
                and txdate < getcurrdate
                and deltd <> 'Y'
        )
        group by seacctno
    ) khop_qtty on se.acctno = khop_qtty.seacctno
    WHERE SE.CODEID = SB.CODEID
    and se.afacctno = cfaf.afacctno;
--- group by se.acctno, SB.SYMBOL

        IF (alertcd='BAL_G_LISTEDQTTY' AND f_side='NB') THEN  --Giao d?ch vu?t x% KL luu h?
        BEGIN
          SELECT LISTINGQTTY INTO marketval FROM SECURITIES_INFO WHERE SYMBOL=f_symbol;
          IF V_TOTALQTTY+f_quantity >= (trgval/100)*marketval THEN
              ret := 'ALERT_OVER_TRD_G_LISTEDQTTY';
              l_number := trgval;
          END IF;
        END;
        END IF;

        IF (alertcd='TRD_L_LISTEDQTTY' AND f_side='NS') THEN  --Giao d?ch gi?m x% kh?i lu?ng luu h?
        BEGIN
          SELECT LISTINGQTTY INTO marketval FROM SECURITIES_INFO WHERE SYMBOL=f_symbol;
          IF V_TOTALQTTY-f_quantity < (trgval/100)*marketval THEN
              ret:='ALERT_OVER_TRD_L_LISTEDQTTY';
              l_number := trgval;
          END IF;
        END;
        END IF;

        /*IF (alertcd='BAL_G_LISTEDQTTY' AND f_side='NB') THEN  --N?m gi? vu?t x% KL luu h?
            BEGIN
              SELECT LISTINGQTTY INTO marketval FROM SECURITIES_INFO WHERE SYMBOL=f_symbol;

              SELECT AVLQTTY INTO currentval
              FROM VW_DEALER_POLICY WHERE SYMBOL=f_symbol AND TRADERID=f_traderid;
              IF f_quantity+currentval>(trgval/100)*marketval THEN
                  ret:='ALERT_OVER_BAL_G_LISTEDQTTY';
                  l_number := trgval;
              END IF;
            END;
        END IF;*/

        EXIT WHEN ret != '';
        FETCH C_DEPT INTO alertcd, operatorcd, trgval, notes, srcreffield;
      END;
    END LOOP;
    CLOSE C_DEPT;
    ---l_number
    RETURN REPLACE(fn_get_errdesc(f_language, ret),'xx',to_char(l_number));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLERRM;  --M??i c?a ORACLE
  END;

  --Check policy for traders
  FUNCTION fn_checkproptradeorder (f_language IN varchar2, f_acctno IN  varchar2, f_side IN  varchar2, f_symbol in varchar2,
      f_quantity in varchar2, f_price in varchar2, f_traderid in varchar2) RETURN varchar
  AS
    l_codeid VARCHAR(50);
    idtrader VARCHAR(50);
    l_groupid VARCHAR(50);
    ret VARCHAR(500);
    cnt int;

    sys_max_qtty_per_order int;
    sys_max_nav_all float;
    sys_current_nav_all float;
    group_max_nav_all float;
    group_current_nav_all float;

    unlimited_value float;

    trader_mavavlbal int;
    trader_minavlbal int;
    trader_maxallbuy int;
    trader_maxallsell int;
    trader_totalqtty int;
    trader_avlqtty int;
    trader_mktvalue int;
    trader_maxnav int;
    trader_maxbprice int;
    trader_minsprice int;
    trader_deltabprc int;
    trader_deltasprc int;
    trader_rfprice int;

    trader_wk_buy_order int;
    trader_wk_sell_order int;
    trader_buy_order_qtty int;
    trader_sell_order_qtty int;
    trader_buy_order_value int;
    trader_sell_order_value int;

    alertcd VARCHAR(50);
    operatorcd VARCHAR(50);
    trgval float;
    notes VARCHAR(500);
    srcreffield VARCHAR(200);
    l_currdate  date;
    l_fromdate  date;
    l_todate    date;
    L_NAVMG     FLOAT;

    CURSOR C_DEPT IS
      SELECT MST.ALERTCD, MST.OPERATORCD, MST.TRGVAL, MST.NOTES, MST.SRCREFFIELD
      FROM CFAFTRDALERT MST, SBSECURITIES RF
      WHERE MST.CODEID = RF.CODEID AND MST.STATUS='A' AND SYMBOL=f_symbol;

  BEGIN
    unlimited_value:=0;
    ret := '';
    return ret;
    cnt := 0;

    trader_buy_order_qtty := 0;
    trader_sell_order_qtty := 0;
    trader_buy_order_value := 0;
    trader_sell_order_value := 0;

    SELECT TO_DATE(varvalue,'DD/MM/RRRR') into l_currdate
    FROM SYSVAR WHERE VARNAME = 'CURRDATE' AND GRNAME = 'SYSTEM';

    SELECT CODEID INTO l_codeid FROM SBSECURITIES WHERE SYMBOL = f_symbol;

    --L?y tham s? m?c h? th?ng
    SELECT COUNT(MST.AUTOID) INTO cnt FROM CFTRDPOLICY MST WHERE MST.LEVELCD='S'
           and l_currdate >= mst.frdate and l_currdate <= mst.todate and mst.status = 'A';
    IF cnt=0 THEN
      BEGIN
        sys_max_qtty_per_order := unlimited_value;
        sys_max_nav_all :=unlimited_value;
      END;
    ELSE
      SELECT NVL(MAXNAV,0), NVL(MAXQTTYODR,0) INTO sys_max_nav_all, sys_max_qtty_per_order
      FROM CFTRDPOLICY MST WHERE MST.LEVELCD='S' and l_currdate >= mst.frdate and l_currdate <= mst.todate and mst.status = 'A';
    END IF;

    --Kh?i lu?ng l?nh ph?i n?m trong qui d?nh
    IF (f_quantity > sys_max_qtty_per_order) THEN
      BEGIN
        ret := 'msgDEALER_OVER_SYS_MAX_QTTY_PER_ORDER';
        RETURN fn_get_errdesc(f_language, ret);
      END;
    END IF;

    --traderid: ngu?i d?t l?nh ph?i l?ser qu?n l? ho?c leader c?y?n d?t l?nh
    SELECT COUNT(AUTOID) INTO cnt
    FROM CFAFTRDLNK WHERE AFACCTNO=f_acctno AND TRADERID=f_traderid AND STATUS='A';
    cnt := NVL(cnt,0);
    IF cnt = 0 THEN
      BEGIN
        SELECT COUNT(AUTOID) INTO cnt
        FROM CFAFTRDLNK WHERE AFACCTNO=f_acctno AND LEADERID=f_traderid AND STATUS='A' AND LEADERCD='PLO';
        cnt := NVL(cnt,0);
            IF cnt=0 THEN
                SELECT COUNT(AUTOID) INTO cnt
                FROM CFAFTRDLNK WHERE AFACCTNO=f_acctno AND ADMINID=f_traderid AND STATUS='A';
                cnt := NVL(cnt,0);
                    IF cnt = 0 THEN
                        ret := 'msgDEALER_TRADER_CANNOT_PLACE_ORDER';
                        RETURN fn_get_errdesc(f_language, ret);
                    else
                        SELECT MAX(TRADERID), MAX(NVL(GROUPID,'')) INTO idtrader, l_groupid
                        FROM CFAFTRDLNK WHERE AFACCTNO = f_acctno AND STATUS = 'A';
                    END IF;
            --            ret := 'msgDEALER_TRADER_CANNOT_PLACE_ORDER';
            --            RETURN fn_get_errdesc(f_language, ret);
            else
                SELECT MAX(TRADERID), MAX(NVL(GROUPID,'')) INTO idtrader, l_groupid
                FROM CFAFTRDLNK WHERE AFACCTNO = f_acctno AND STATUS = 'A';
            END IF;
      END;
    else
        SELECT MAX(NVL(GROUPID,'')) INTO l_groupid
        FROM CFAFTRDLNK WHERE AFACCTNO = f_acctno AND STATUS = 'A';
        idtrader := f_traderid;
    END IF;


    --L?y m??a c?b? qu?n l? t?kho?n tr?c ti?p
    /*SELECT MAX(TRADERID), MAX(NVL(GROUPID,'')) INTO idtrader, groupid
    FROM CFAFTRDLNK WHERE AFACCTNO = f_acctno AND STATUS = 'A';*/

    --Ki?m tra qui d?nh c?a C?N B? T? DOANH
    --Gi?UA/B?N ph?i n?m trong qui d?nh c?a d?i v?i t?kho?n
    --N?u l??nh MUA th?h?i lu?ng mua th?ko du?c vu?t qu?ui d?nh cho ph?c?a m?i?i
    SELECT COUNT(*) INTO cnt
    FROM VW_DEALER_POLICY WHERE symbol = f_symbol and TRADERID=idtrader
         and l_currdate >= frdate and l_currdate <= todate;
    cnt := NVL(cnt,0);
    IF cnt > 0 THEN
      BEGIN
        --L?y ch? s? tham s? c?a trader
        begin
        SELECT MAXAVLBAL, MINAVLBAL, MAXALLBUY, MAXALLSELL, RFPRICE,
          TOTALQTTY, AVLQTTY, AVLQTTY*secostprice, MAXNAV, MAXBPRICE, MINSPRICE, DELTABPRC, DELTASPRC,
          frdate, todate
        INTO trader_mavavlbal, trader_minavlbal, trader_maxallbuy, trader_maxallsell, trader_rfprice,
          trader_totalqtty, trader_avlqtty, trader_mktvalue, trader_maxnav,
          trader_maxbprice, trader_minsprice, trader_deltabprc, trader_deltasprc, l_fromdate, l_todate
        FROM VW_DEALER_POLICY WHERE TRADERID = idtrader AND symbol = f_symbol
             and l_currdate >= frdate and l_currdate <= todate;
        EXCEPTION WHEN OTHERS THEN
          trader_mavavlbal  := 0;
          trader_minavlbal  := 0;
          trader_maxallbuy  := 0;
          trader_maxallsell := 0;
          trader_rfprice    := 0;
          trader_totalqtty  := 0;
          trader_avlqtty    := 0;
          trader_mktvalue   := 0;
          trader_maxnav     := 0;
          trader_maxbprice  := 0;
          trader_minsprice  := 0;
          trader_deltabprc  := 0;
          trader_deltasprc  := 0;
          l_fromdate := l_currdate;
          l_todate   := l_currdate;
        end;
        --X?d?nh t?ng gi?r? MUA/B?N trong tu?n theo m?h?ng kho?c?a trader.
        begin
          SELECT SUM(BUYAMT), SUM(SELLAMT) INTO trader_wk_buy_order, trader_wk_sell_order
          FROM (SELECT 0 BUYAMT, 0 SELLAMT FROM DUAL
          UNION ALL
          SELECT DECODE(OD.EXECTYPE,'NB',
                 (OD.quoteprice*(OD.orderqtty-NVL(OD.cancelqtty,0))),0) BUYAMT,
                 DECODE(OD.EXECTYPE,'NS',(OD.quoteprice*(OD.orderqtty-NVL(OD.cancelqtty,0))),0) SELLAMT
          FROM ODMAST OD, CFAFTRDLNK AF
          WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader AND OD.CODEID=l_codeid
                AND OD.DELTD <> 'Y'
                AND OD.TXDATE >= l_fromdate and OD.TXDATE <= l_todate
          UNION ALL
          SELECT DECODE(OD.EXECTYPE,'NB',OD.EXECAMT,0) BUYAMT, DECODE(OD.EXECTYPE,'NS',OD.EXECAMT,0) SELLAMT
          FROM ODMASTHIST OD, CFAFTRDLNK AF, SYSVAR
          WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader AND OD.CODEID=l_codeid AND OD.EXECQTTY>0
          AND SYSVAR.VARNAME='CURRDATE' AND OD.TXDATE >= l_fromdate and OD.TXDATE <= l_todate
          ) ODWK;
        EXCEPTION WHEN OTHERS THEN
          trader_buy_order_value := 0;
          trader_sell_order_value := 0;
        end;


        SELECT COUNT(MST.AUTOID) INTO cnt FROM CFTRDPOLICY MST WHERE MST.LEVELCD='U'
           and l_currdate >= mst.frdate and l_currdate <= mst.todate and mst.status = 'A' AND MST.refid = idtrader ;
        CNT := NVL(CNT,0);
    IF cnt=0 THEN
      BEGIN
        trader_maxnav :=unlimited_value;
      END;
    ELSE
      SELECT NVL(MAXNAV,0) INTO trader_maxnav
      FROM CFTRDPOLICY MST WHERE MST.LEVELCD='U' and MST.refid = idtrader
      AND  l_currdate >= mst.frdate and l_currdate <= mst.todate and mst.status = 'A';
    END IF;

        IF trader_maxallbuy=0 THEN
          trader_maxallbuy := unlimited_value;
        END IF;
        IF trader_maxallsell=0 THEN
          trader_maxallsell := unlimited_value;
        END IF;

        IF (f_side='NB') THEN
          --MUA
          BEGIN
            --Gi?ua theo qui d?nh
            IF f_price>trader_maxbprice THEN
                BEGIN
                  ret := 'msgDEALER_OVER_MAX_BUYING_PRICE';
                  RETURN fn_get_errdesc(f_language, ret);
                END;
            END IF;

            --Bi?d? gi?ua
            IF trader_deltabprc>0 THEN
              IF f_price > trader_rfprice*(1+trader_deltabprc/100) THEN
                BEGIN
                  ret := 'msgDEALER_OVER_DELTA_BUYING_PRICE';
                  RETURN fn_get_errdesc(f_language, ret);
                END;
              END IF;
            END IF;


            --L?y th?tin v? l?nh giao d?ch trong ng?
            begin
            SELECT NVL(SUM(DECODE(EXECTYPE,'NB',(OD.orderqtty-NVL(OD.cancelqtty,0)-OD.EXECQTTY)*QUOTEPRICE+EXECAMT,0)),0) BUY_VALUE,
              NVL(SUM(DECODE(EXECTYPE,'NS',(OD.orderqtty-NVL(OD.cancelqtty,0)-OD.EXECQTTY)*QUOTEPRICE+EXECAMT,0)),0) SELL_VALUE
            INTO trader_buy_order_value, trader_sell_order_value
            FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader
                 AND OD.DELTD <> 'Y'
            GROUP BY AF.TRADERID;
            EXCEPTION WHEN OTHERS THEN
                      trader_buy_order_value := 0;
                      trader_sell_order_value := 0;
            end;
            begin
            SELECT NVL(SUM(DECODE(EXECTYPE,'NB',OD.orderqtty-NVL(OD.cancelqtty,0),0)),0) BUY_QTTY,
              NVL(SUM(DECODE(EXECTYPE,'NS',OD.orderqtty-NVL(OD.cancelqtty,0),0)),0) SELL_QTTY
            INTO trader_buy_order_qtty, trader_sell_order_qtty
            FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader AND OD.CODEID=l_codeid
                 AND OD.DELTD <> 'Y'
            GROUP BY AF.TRADERID;
            EXCEPTION WHEN OTHERS THEN
                      trader_buy_order_qtty := 0;
                      trader_sell_order_qtty := 0;
            end;

            --Kh?i lu?ng t?i da
---            trader_totalqtty, trader_avlqtty

            IF trader_mavavlbal < f_quantity + trader_buy_order_qtty - trader_sell_order_qtty THEN
                BEGIN
                  ret := 'msgDEALER_OVER_TOTAL_QTTY';
                  RETURN fn_get_errdesc(f_language, ret);
                END;
            END IF;

            --Gi?r? t?i da c?a danh m?c
            ---- DUNGNH L_NAVMG
            select SUM(SE.trade*SE.costprice) INTO L_NAVMG
            from CFAFTRDLNK CF, semast SE
            WHERE CF.traderid = idtrader AND CF.afacctno = SE.afacctno AND CF.status = 'A' ;
            L_NAVMG := NVL(L_NAVMG,0);
                IF f_quantity*f_price+trader_buy_order_value-trader_sell_order_value + L_NAVMG > trader_maxnav THEN
                    BEGIN
                      ret := 'msgDEALER_TRADER_MAXNAV';
                      RETURN fn_get_errdesc(f_language, ret);
                    END;
                END IF;

            --Gi?r? MUA t?i da c?a m?rong tu?n
            IF f_quantity*f_price>trader_maxallbuy-trader_wk_buy_order THEN
            BEGIN
              ret := 'msgDEALER_TRADER_MAXALLBUY';
              RETURN fn_get_errdesc(f_language, ret);
            END;
            END IF;

          END;
        ELSE
          --B?N
          BEGIN
            --Gi??
            IF f_price<trader_minsprice THEN
            BEGIN
              ret := 'msgDEALER_OVER_MIN_SELLING_PRICE';
              RETURN fn_get_errdesc(f_language, ret);
            END;
            END IF;

            --Bi?d? gi??
            IF trader_deltasprc>0 THEN
              IF f_price < trader_rfprice*(1-trader_deltasprc/100) THEN
                BEGIN
                  ret := 'msgDEALER_OVER_DELTA_SELLING_PRICE';
                  RETURN fn_get_errdesc(f_language, ret);
                END;
              END IF;
            END IF;

            --Gi?r? B?N t?i da c?a m?rong tu?n
            IF f_quantity*f_price > trader_maxallsell-trader_wk_sell_order THEN
                BEGIN
                  ret := 'msgDEALER_TRADER_MAXALLSELL';
                  RETURN fn_get_errdesc(f_language, ret);
                END;
            END IF;

            -- SO LUONG NAM GIU TOI THIEU.
            begin
            SELECT NVL(SUM(DECODE(EXECTYPE,'NB',OD.orderqtty-nvl(od.EXECQTTY,0)-NVL(OD.cancelqtty,0),0)),0) BUY_QTTY
            INTO trader_buy_order_qtty
            FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader AND OD.CODEID=l_codeid
                 AND OD.DELTD <> 'Y'
            GROUP BY AF.TRADERID;
            EXCEPTION WHEN OTHERS THEN
                      trader_buy_order_qtty := 0;
            end;
            IF trader_minavlbal > trader_avlqtty+trader_buy_order_qtty - f_quantity THEN
                BEGIN
                  ret := 'msgDEALER_OVER_TOTAL_QTTY';
                  RETURN fn_get_errdesc(f_language, ret);
                END;
            END IF;

          END;
        END IF;
      END;
    ELSE
      BEGIN
        ret := 'msgDEALER_SYMBOL_CANNOT_TRADE';
        RETURN fn_get_errdesc(f_language, ret);
      END;
    END IF;


    --KI?M TRA M?C NH?: GI? TR? DANH M?C
    IF (f_side='NB') THEN
    BEGIN
      SELECT COUNT(AUTOID) INTO cnt FROM CFTRDPOLICY WHERE LEVELCD='G' AND STATUS='A' AND REFID=l_groupid
             and l_currdate >= frdate and l_currdate <= todate;
      IF cnt>0 THEN
        BEGIN
            BEGIN
          SELECT MAXNAV INTO group_max_nav_all
          FROM CFTRDPOLICY WHERE LEVELCD='G' AND STATUS='A' AND REFID=l_groupid and l_currdate >= frdate and l_currdate <= todate;
            EXCEPTION WHEN OTHERS THEN
                      group_max_nav_all := 0;
            end;
          group_current_nav_all := 0;
          select SUM(NVL(SE.trade,0)*NVL(SE.costprice,0)) INTO group_current_nav_all
          from CFAFTRDLNK CF, semast SE
          WHERE CF.afacctno = SE.afacctno AND CF.status = 'A' AND CF.groupid = L_groupid;
          ---group_current_nav_all := NVL(group_current_nav_all,0);
---           return group_current_nav_all;
          SELECT NVL(SUM(DECODE(EXECTYPE,'NB',REMAINQTTY*QUOTEPRICE+EXECAMT,0)),0) BUY_VALUE,
            NVL(SUM(DECODE(EXECTYPE,'NS',EXECAMT,0)),0) SELL_VALUE
          INTO trader_buy_order_value, trader_sell_order_value
          FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.GROUPID=L_groupid;

          IF (group_current_nav_all+f_quantity*f_price+trader_buy_order_value-trader_sell_order_value>group_max_nav_all) THEN
            BEGIN
              ret := 'msgDEALER_GROUP_MAXNAV';
            RETURN fn_get_errdesc(f_language, ret);
---           return group_current_nav_all;
            END;
          END IF;
        END;
      END IF;
    END;
    END IF;

    --KI?M TRA M?C C?G TY: GI? TR? DANH M?C
    IF (f_side='NB') THEN
      BEGIN
        ---SELECT SUM(AVLQTTY*secostprice) INTO sys_current_nav_all
        ---FROM VW_DEALER_POLICY;
        select SUM(SE.trade*SE.costprice) INTO sys_current_nav_all
        from CFAFTRDLNK CF, semast SE
        WHERE CF.afacctno = SE.afacctno AND CF.status = 'A';
        sys_current_nav_all := NVL(sys_current_nav_all,0);

        SELECT NVL(SUM(DECODE(EXECTYPE,'NB',(OD.ORDERQTTY-OD.CANCELQTTY-OD.EXECQTTY)*QUOTEPRICE+EXECAMT,0)),0) BUY_VALUE,
          NVL(SUM(DECODE(EXECTYPE,'NS',(OD.ORDERQTTY-OD.CANCELQTTY-OD.EXECQTTY)*QUOTEPRICE+EXECAMT,0)),0) SELL_VALUE
        INTO trader_buy_order_value, trader_sell_order_value
        FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND OD.DELTD <> 'Y';

        IF (sys_current_nav_all+f_quantity*f_price+trader_buy_order_value-trader_sell_order_value>sys_max_nav_all) THEN
          BEGIN
            ret := 'msgDEALER_OVER_SYS_CURRENT_NAV_ALL';
            RETURN fn_get_errdesc(f_language, ret);
          END;
        END IF;
      END;
    END IF;

    OPEN C_DEPT;
    FETCH C_DEPT INTO alertcd, operatorcd, trgval, notes, srcreffield;
    WHILE C_DEPT%FOUND
    LOOP
      BEGIN
        /*
        MKT_L_MINQTTY  Giao d?ch nh? hon KL giao d?ch t?i thi?u
        MKT_G_MAXQTTY  Giao d?ch l?n hon KL giao d?ch t?i da
        */
        IF (alertcd='MKT_L_MINQTTY') THEN  ---Giao d?ch nh? hon KL giao d?ch t?i thi?u
          BEGIN
            IF f_quantity < trgval THEN
                ret:='ALERT_OVER_MIN_QTTY_PRICE';
                RETURN fn_get_errdesc(f_language, ret);
            END IF;
          END;
        END IF;
        IF (alertcd='MKT_G_MAXQTTY') THEN  ---- Giao d?ch l?n hon KL giao d?ch t?i da
          BEGIN
            IF f_quantity > trgval THEN
                ret:='ALERT_OVER_TOTAL_QTTY';
                RETURN fn_get_errdesc(f_language, ret);
            END IF;
          END;
        END IF;
        EXIT WHEN ret != '';
        FETCH C_DEPT INTO alertcd, operatorcd, trgval, notes, srcreffield;
      END;
    END LOOP;
    CLOSE C_DEPT;

    RETURN ret;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLERRM;  --M??i c?a ORACLE
  END;

  END CSPKS_DEALERS;

/
