SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE check_send_order (p_foacctno IN VARCHAR2)
IS
    v_Order_Number varchar2(10);
    l_DeliverToSubID VARCHAR2(10);
    v_tradeDate   VARCHAR2(10) := TO_CHAR(getcurrdate,'RRRRMMDD');
    l_connection_state   ordersys.sysvalue%TYPE;

    CURSOR rec IS
    SELECT a.orgorderid orderid, 'New Single Order' Text,a.custodycd Account,
           CASE WHEN  SUBSTR(a.custodycd,4,1) = 'P' THEN '3' --House
                ELSE  '1' --Customer
           END AccountType,
           CASE WHEN c.pricetype IN ('ATO','ATC','MTL','MOK','MAK') THEN ''
           ELSE TO_CHAR(c.quoteprice)
           END Price,
           c.orderqtty OrderQty,a.symbol,
           decode(a.bors,'B','1','S','2','5') Side, -- 5 = Sell short (cache)
           CASE WHEN c.pricetype IN ('LO')                         THEN '2' --limit
                WHEN c.pricetype IN ('ATC','ATO','MP','MAK','MOK') THEN '1' --market
                WHEN c.pricetype IN ('SO>','SO<')                  THEN '3' --stop
                WHEN c.pricetype IN ('SBO','OBO')                  THEN '4' --Stop limit
                WHEN c.pricetype IN ('BO')                         THEN 'X' --Sameside best
                WHEN c.pricetype IN ('')                           THEN 'Y' --Contraryside best
            END OrdType,
            CASE WHEN c.pricetype IN ('LO')                        THEN '0' --day
                 WHEN c.pricetype IN ('ATO')                       THEN '2' --At the Opening (OPG)
                 WHEN c.pricetype IN ('ATC')                       THEN '7' --At the Close
                 WHEN c.pricetype IN ('MAK')                       THEN '3' --Fill and Kill
                 WHEN c.pricetype IN ('MOK')                       THEN '4' --Fill or Kill
                 WHEN c.pricetype IN ('MTL')                       THEN '9' --Market to Limit
                 WHEN c.pricetype IN ('')                          THEN '1' --Good Till Cancel (GTC)
                 ELSE '0'
            END TimeInForce,
            CASE WHEN SUBSTR(a.custodycd,4,1) = 'F' THEN '10' ELSE '00' END forninvesttypecode,
            a.codeid,a.BORS,
            c.limitprice StopPx,
            a.SENDNUM, 
            h.brd_code DeliverToCompID, 
            l.tradelot, 
            b.isincode,
            b.tradeplace, 
            h.tradsesstatus,
            '704' country
    FROM ood a, sbsecurities b, odmast c, securities_info l, ordersys s, ho_sec_info h
    WHERE a.codeid = B.codeid
          AND b.codeid = l.codeid
          AND  a.orgorderid = c.orderid
          AND c.quoteprice <= l.ceilingprice
          AND c.quoteprice >= l.floorprice
          AND a.oodstatus = 'N'
          AND A.deltd <> 'Y'
          AND c.orstatus = '8'
          AND c.matchtype = 'N'
          AND c.EXECTYPE in ( 'NB','NS','MS')
          AND s.sysname = 'FIRM'
          AND L.symbol= H.code
          AND NVL(H.SUSPENSION,'1') <>'S'
          AND NVL(H.delist,'1') <>'D'
          --And NVL(H.halt_resume_flag,'1') not in ('H','A')
          AND ((h.tradsesstatus IN ('AA1') AND c.pricetype IN ('ATO','LO'))
               OR (h.tradsesstatus IN ('BB1','AW9') AND c.pricetype IN ('LO','MTL','MOK','MAK'))
               OR (h.tradsesstatus IN ('BC1') AND c.pricetype IN ('ATC','LO'))
          )
          AND h.tradsesstatus IN ('AA1','BB1','AW9','BC1')
          --check CK han che GD
          AND NOT EXISTS (SELECT 1 FROM hotrscopemap WHERE trscope = b.trscope AND side = substr(c.exectype,2,1)
                          AND accounttype = decode(substr(a.custodycd,4,1), 'P', '3', '1'))
          --Check room
          AND CASE WHEN (a.bors='B' and substr(a.custodycd,4,1) ='F'
          AND nvl(h.CURRENT_ROOM,0) < c.orderqtty) THEN 0 ELSE 1 END > 0
          AND b.tradeplace IN ('001','002','005')
          AND c.foacctno = p_foacctno
          ;
BEGIN
    
    FOR I IN rec
    LOOP
      BEGIN
        SAVEPOINT sp#2;
        IF i.tradeplace = '001' THEN
          SELECT sysvalue INTO l_connection_state FROM ordersys WHERE sysname = 'HOSEGWSTATUS';
        ELSE
          SELECT sysvalue INTO l_connection_state FROM ordersys_ha WHERE sysname = 'HOSEGWSTATUS';
        END IF;
        IF l_connection_state <> '1' THEN
          plog.error('check_send_order Connection_state not connect[' || l_connection_state || ']'); 
          RETURN;
        END IF;
        --Kiem tra lo le
        IF i.orderqty < i.tradelot THEN
          l_DeliverToSubID := 'G4';
        ELSE
          l_DeliverToSubID := 'G1';
        END IF;

        SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
        IF i.tradeplace IN ('001','002','005') THEN
          IF i.tradeplace = '001' THEN
            INSERT INTO ho_d (clordid, account, accounttype, handlinst, maxfloor, symbol, side, cashmargin,
                             orderqty, ordtype, price, stoppx, timeinforce, tradedate, country, investcode,
                             forninvesttypecode, custodianid, openclosecode, text, orderid, status,DeliverToCompID, DeliverToSubID)
            VALUES (v_Order_Number, i.account, i.accounttype, '1', '', i.symbol, i.side, '1',
                   i.orderqty, i.ordtype, i.price, i.stoppx, i.timeinforce, v_tradeDate, i.country, '',
                   i.forninvesttypecode, '', '0', i.text, i.orderid, 'N',i.Delivertocompid,l_DeliverToSubID);
          ELSE
            INSERT INTO ha_d (clordid, account, accounttype, handlinst, maxfloor, symbol, side, cashmargin,
                             orderqty, ordtype, price, stoppx, timeinforce, tradedate, country, investcode,
                             forninvesttypecode, custodianid, openclosecode, text, orderid, status,DeliverToCompID, DeliverToSubID)
            VALUES (v_Order_Number, i.account, i.accounttype, '1', '', i.symbol, i.side, '1',
                   i.orderqty, i.ordtype, i.price, i.stoppx, i.timeinforce, v_tradeDate, i.country, '',
                   i.forninvesttypecode, '', '0', i.text, i.orderid, 'N',i.Delivertocompid,l_DeliverToSubID);
          END IF;
        --XU LY LENH
        --1.1DAY VAO ORDERMAP.
        INSERT INTO ORDERMAP(ctci_order,orgorderid,Msgtype) VALUES (v_Order_Number,I.orderid,'D');
        --1.2 CAP NHAT OOD.
        UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
        UPDATE ODMAST SET hosesession= i.tradsesstatus WHERE ORDERID=I.orderid;
        --1.3 DAY LENH VAO ODQUEUE
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
       END IF;
      EXCEPTION 
        WHEN OTHERS THEN
          plog.error('check_send_order. (foacctno=' || p_foacctno || ')' || SQLERRM || '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO SAVEPOINT sp#2;
          RETURN;
      END;
    END LOOP;

EXCEPTION 
  WHEN OTHERS THEN
    plog.error('check_send_order. (foacctno=' || p_foacctno || ')' || SQLERRM || '--' || dbms_utility.format_error_backtrace);
END;
/
