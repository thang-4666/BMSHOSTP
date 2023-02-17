SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_ORDER_TO_HA_STATUS
(BORS, ORDERID, CODEID, SYMBOL, PRICETYPE, 
 QUOTEPRICE, LIMITPRICE, ORDERQTTY, CUSTODYCD, QUOTEQTTY, 
 SENDNUM, ORDER_STATUS)
BEQUEATH DEFINER
AS 
SELECT
    a.bors,
    a.orgorderid orderid,
    a.codeid,
    a.symbol,
    C.pricetype,
    c.quoteprice quoteprice,
    c.limitprice,
    c.orderqtty,
    a.custodycd,
    c.QUOTEQTTY,
    A.SENDNUM,
    case when (c.quoteprice > l.ceilingprice or c.quoteprice < l.floorprice) then 'Sai gia tran san'
        when HR.SECURITYTRADINGSTATUS not in ('17','24','25','26','1','27','28') then 'Trang thai chung khoan khong hop le'
        when not (hb.TRADSESSTATUS ='1' or hr.TRADSESSTATUS ='1') then 'Trang thai thi truong khong dung'
        when  not (  (hb.TRADINGSESSIONID in ('CONT','CONTUP') and c.pricetype in ('LO','MTL','MAK','MOK'))
                          or
                          ( hb.TRADINGSESSIONID = 'CLOSE' and c.pricetype in ('ATC','LO'))
                          or
                          ( hb.TRADINGSESSIONID = 'CLOSE_BL' and c.pricetype in ('ATC','LO'))

                     ) then 'Phien giao dich khong hop le'
        when (select sysvalue from ordersys_ha where sysname ='HOSEGWSTATUS') <> 0 then 'GW chua ket noi'
        else 'Cho boc lenh'
        end order_status
FROM
    ood a,
    odmast c,
    sbsecurities b,
    securities_info l,
    ordersys_ha s,
    hasecurity_req hr,
     HA_BRD hb
WHERE
    a.codeid = b.codeid
    AND b.codeid = l.codeid
    AND a.orgorderid = c.orderid
    and b.tradeplace in ('002','005')
    AND a.oodstatus = 'N'
    AND A.deltd <> 'Y'
    AND c.orstatus ='8'
    AND c.matchtype = 'N'
    AND c.EXECTYPE in ( 'NB','NS','MS')
    AND hr.symbol =a.symbol
    and s.sysname ='FIRM'
    AND hb.BRD_CODE = hr.tradingsessionsubid
    AND hb.TRADINGSESSIONID= hr.TradingSessionID

ORDER BY c.last_change
/
