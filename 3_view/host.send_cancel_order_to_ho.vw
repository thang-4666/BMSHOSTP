SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_CANCEL_ORDER_TO_HO
(ORIGCLORDID, ORDERID, CTCI_ORDER, TEXT, SYMBOL, 
 SENDNUM, DELIVERTOCOMPID, TRADEPLACE, BOARDID, ISINCODE)
BEQUEATH DEFINER
AS 
SELECT
    ORDER_NUMBER OrigClOrdID,
    ORDERID,
    ctci_order,
    'Order Cancel Request' Text,
    Symbol,
    sendnum, DeliverToCompID, tradeplace, boardid,isincode
FROM
    (SELECT
        A.ORGORDERID ORDERID,
        A.SYMBOL ,
        ODM.ORDER_NUMBER,
        odm.ctci_order,
        a.sendnum, h.brd_code DeliverToCompID, b.tradeplace, c.boardid,b.isincode
    FROM
        OOD A,
        SBSECURITIES B,
        ODMAST C,-- LENH GOC
        ODMAST E, -- LENH HUY
        ordermap ODM,
        ho_sec_info h,
        ho_brd brd
    WHERE
        A.CODEID = B.CODEID
        AND A.ORGORDERID = E.ORDERID
        AND E.REFORDERID=C.ORDERID
        AND E.REFORDERID=ODM.ORGORDERID
        AND h.brd_code = brd.brd_code
        AND A.OODSTATUS = 'N'
        --AND B.TRADEPLACE IN('001','002','005')
        AND E.ORSTATUS NOT IN ('0')
        AND E.EXECTYPE IN ('CB','CS')
        AND C.ORSTATUS NOT IN ('3','0','6','8')
        AND C.MATCHTYPE ='N'
        AND C.REMAINQTTY >0
        AND C.DELTD <> 'Y'
        AND C.pricetype in ('LO')
        AND ODM.order_number is not NULL
        --
        AND b.symbol= h.code
        and NVL(H.SUSPENSION,'1') <>'S' And NVL(H.delist,'1') <>'D'
        --and trim(H.stock_type)in ('1','3','4')
        AND brd.board_g1 IN ('BB1')
        AND brd.tradsesstatus <> 'AW8' -- Khong Trong Phien Nghi Trua
        AND c.isbuyin = 'N' -- Lenh BuyIn Khong Duoc Huy
    )
WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSESENDSIZE')
/
