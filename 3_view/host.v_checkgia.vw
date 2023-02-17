SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW "V_checkgia"
("symbol", "basicprice")
BEQUEATH DEFINER
AS 
select distinct symbol,basicprice
  from securities_info
  order by symbol asc
/
