SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW HO_SEND_ORDER
(BORS, ORDERID, CODEID, SYMBOL, QUOTEPRICE, 
 ORDERQTTY, CUSTODYCD, PRICETYPE, VIA, SENDNUM, 
 LIMITPRICE, DELIVERTOCOMPID, TRADELOT, ISINCODE, TRADEPLACE, 
 COUNTRY, ISBUYIN)
BEQUEATH DEFINER
AS 
SELECT a.bors, a.orgorderid orderid, a.codeid, a.symbol,
       CASE WHEN c.pricetype IN ('ATO','ATC','MTL','MOK','MAK','PLO') THEN ''
            ELSE TO_CHAR(c.quoteprice)
       END  QUOTEPRICE,
       c.orderqtty,
       a.custodycd,
       c.pricetype,
       c.via, --c.ordertime
       a.SENDNUM,
       c.limitprice, h.brd_code DeliverToCompID, l.tradelot, b.isincode,b.tradeplace,
       '704' country, -- VN
       c.isbuyin --TuanND lay them gia tri the hien lenh buyin
FROM ood a,
     sbsecurities b,
     odmast c,
     securities_info l,
     ho_sec_info h,
     ho_brd brd
WHERE a.codeid = B.codeid AND a.codeid = l.codeid AND a.orgorderid = c.orderid
AND c.quoteprice <= l.ceilingprice AND c.quoteprice >= l.floorprice
AND L.symbol= H.code AND h.brd_code = brd.brd_code
--AND b.tradeplace = '001'
AND a.oodstatus = 'N' AND A.deltd <> 'Y'
AND c.orstatus = '8' AND c.matchtype = 'N' AND c.EXECTYPE in ( 'NB','NS','MS')
and NVL(H.SUSPENSION,'1') <>'S' And NVL(H.delist,'1') <>'D' and trim(H.stock_type)in ('1','3','4')
--And NVL(H.halt_resume_flag,'1') not in ('H','A')
AND ((c.isbuyin = 'Y' AND brd.board_g7 = 'AB1') -- BuyIn Thi Bang G7 Phai Dang Open
     OR (h.statuscode = 'CTR' AND h.tradsesstatus IN ('CD1', 'CD3')) -- CK Kiem Soat Thi Phai Trong Phien Kiem Soat
     OR (brd.board_g3 IN ('AD1','AB1') AND c.pricetype = 'PLO')-- Lenh PLO
     OR ( -- Co Phien Theo Bang G1
           c.quoteqtty >= l.tradelot AND (
                                             (brd.board_g1 IN ('AA1') AND c.pricetype IN ('ATO','LO'))
                                          OR (brd.board_g1 IN ('BB1') AND c.pricetype IN ('LO','MTL','MOK','MAK'))
                                          OR (brd.board_g1 IN ('BC1') AND c.pricetype IN ('ATC','LO'))
                                         )
                                     AND c.isbuyin = 'N'
        )
     OR ( -- Co Phien Theo Bang G4
           c.quoteqtty < l.tradelot AND (
                                             (brd.board_g4 IN ('AA1') AND c.pricetype IN ('ATO','LO'))
                                          OR (brd.board_g4 IN ('BB1') AND c.pricetype IN ('LO','MTL','MOK','MAK'))
                                          OR (brd.board_g4 IN ('BC1') AND c.pricetype IN ('ATC','LO'))
                                         )
                                     AND c.isbuyin = 'N'
        )
    )
AND NVL(brd.tradsesstatus,'x') <> 'AW8' -- Khong Trong Phien Nghi Trua
--check CK han che GD
AND NOT EXISTS (SELECT 1 FROM hotrscopemap WHERE trscope = b.trscope AND side = substr(c.exectype,2,1) AND accounttype = decode(substr(a.custodycd,4,1), 'P', '3', '1'))
ORDER BY  C.LAST_CHANGE
/
