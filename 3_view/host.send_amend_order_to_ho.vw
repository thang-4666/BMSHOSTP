SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_AMEND_ORDER_TO_HO
(ORDERID, ORGORDERID, ORIGCLORDID, HANDLINST, MAXFLOOR, 
 SYMBOL, SIDE, ORDERQTY, ORDTYPE, PRICE, 
 TIMEINFORCE, TEXT, DELIVERTOCOMPID, TRADELOT, TRADEPLACE, 
 BOARDID, ISINCODE)
BEQUEATH DEFINER
AS 
SELECT order_number   orderId, --SHL goc cua so
       orderid      orgorderid, --SHL sua
       CTCI_ORDER     origClOrdId,
       '1'            handlInst,
       ''             maxFloor, -- not used
       SYMBOL         symbol,
       decode(execType,'AB','1','AS','2','5') side,
       orderqty,
       CASE WHEN priceType IN ('LO','PLO')                         THEN '2' --limit
            WHEN priceType IN ('ATC','ATO','MTL','MAK','MOK') THEN '1' --market
            WHEN priceType IN ('SO>','SO<')                  THEN '3' --stop
            WHEN priceType IN ('SBO','OBO')                  THEN '4' --Stop limit
            WHEN priceType IN ('BO')                         THEN 'X' --Sameside best
            WHEN priceType IN ('')                           THEN 'Y' --Contraryside best
       END OrdType,
       QUOTEPRICE price,
       '0' timeInForce,
       'Order Replace Request' Text, DeliverToCompID, tradelot, tradeplace, boardId,isincode
FROM
(
    SELECT ODM.CTCI_ORDER,
           A.ORGORDERID ORDERID,
           A.SYMBOL,
           E.QUOTEPRICE QUOTEPRICE,
           L.TRADELOT,
           C.STOPPRICE,
           C.LIMITPRICE,
           --C.ORDERQTTY - C.EXECQTTY orderqty,--check lai khoi luong
           E.ORDERQTTY + C.CUMQTY orderqty,
           A.PRICE OODPRICE,
           A.QTTY OODQTTY,
           A.OODSTATUS,
           C.AFACCTNO,
           L.TRADEUNIT,
           E.REFORDERID,
           C.MATCHTYPE,
           C.NORK,
           E.PRICETYPE,
           C.CLEARDAY,
           C.ORSTATUS,
           C.EXECQTTY,
           ODM.order_number,
           E.QUOTEQTTY OrderQty2,
           E.Limitprice StopPx,
           A.sendnum,
           e.exectype, h.brd_code DeliverToCompID, odm.orgorderid, b.tradeplace,
           c.boardId,b.isincode
    FROM OOD A, SBSECURITIES B, ODMAST C,ODMAST E, SECURITIES_INFO L, ORDERMAP ODM, ho_sec_info h, ho_brd brd
    WHERE A.CODEID = B.CODEID AND A.ORGORDERID = E.ORDERID AND E.REFORDERID = C.ORDERID
      AND E.REFORDERID = ODM.ORGORDERID
      AND B.CODEID = L.CODEID AND L.symbol= H.code
      AND h.brd_code = brd.brd_code
      AND C.ORSTATUS NOT IN ('3','0','6','8') AND C.MATCHTYPE ='N' AND C.REMAINQTTY >0 AND c.pricetype = 'LO'
      AND E.ORSTATUS NOT IN ('0')
      AND ODM.order_number is not null
      AND OODSTATUS IN ('N')
      AND C.DELTD <> 'Y'
      AND e.EXECTYPE IN ('AB','AS')
      and NVL(H.SUSPENSION,'1') <>'S'
      And NVL(H.delist,'1') <>'D'
      --check phien chi sua voi phien gioi han
      AND ((c.boardid = 'G1' AND brd.board_g1 IN ('BB1'))
            OR (c.boardid = 'G4' AND brd.board_g4 IN ('BB1'))
          )
      AND NVL(brd.tradsesstatus,'x') NOT IN ('GW8') AND h.statuscode NOT IN ('CTR') -- CK Kiem Soat Khong Cho Sua
      AND c.isbuyin = 'N' -- Lenh BuyIn Khong Duoc Sua
      --check CK han che GD
      --AND NOT EXISTS (SELECT 1 FROM hotrscopemap WHERE trscope = b.trscope AND side = substr(c.exectype,2,1) AND accounttype = decode(substr(a.custodycd,4,1), 'P', '3', '1'))
      ORDER BY e.ordertime
)
WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSESENDSIZE')
/
