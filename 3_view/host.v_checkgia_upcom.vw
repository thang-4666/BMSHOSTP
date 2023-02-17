SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW "V_checkgia_upcom"
("symbol", "basicprice", "ceilingprice", "floorprice")
BEQUEATH DEFINER
AS 
SELECT DISTINCT i.symbol,i.basicprice,i.ceilingprice,i.floorprice 
  FROM securities_info i inner join all_dayprice a 
       on i.symbol = a.symbol 
  where a.trans_date =trunc(sysdate)
        and a.status = 1
  ORDER BY i.symbol ASC
/
