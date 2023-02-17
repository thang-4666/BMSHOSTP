SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SBS_SALES_RESULT
(TIEUKHOAN, NVMOIGIOI, NGAYGD, SOHIEULENH, LOAI, 
 KLDAT, KLKHOP, GIAKHOP, GTKHOP)
BEQUEATH DEFINER
AS 
SELECT afacctno,
    userid nvmoigioi,
    txdate ngaygd,
    orderid sohieulenh,
    exectype loai,
    orderqtty kldat,
    execqtty klkhop,
    exprice giakhop,
    execamt gtkhop
  FROM
    (SELECT
      CASE
        WHEN od.via = 'W'
        THEN 'ETS(DMSTe)'
        WHEN (od.via    = 'O'
        OR FO.username IS NULL)
        THEN 'ONLINE'
        WHEN od.via = 'B'
        THEN FO.username
        WHEN od.txdate <'31-May-2010'
        THEN 'CONVERT'
        ELSE tx.tlid
      END USERID ,
      od.*
    FROM
      (SELECT * FROM odmast
      UNION ALL
      SELECT * FROM odmasthist
      ) od,
      (SELECT * FROM fomast
      UNION ALL
      SELECT * FROM fomasthist
      ) fo,
      (SELECT * FROM tllog
      UNION ALL
      SELECT * FROM tllogall
      ) tx
    WHERE tx.txnum(+)   = od.txnum
    AND tx.txdate(+)    = od.txdate
    AND fo.orgacctno(+) = od.orderid
    AND od.execqtty     > 0
    )
  WHERE 0=0
/
