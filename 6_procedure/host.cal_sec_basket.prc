SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CAL_SEC_BASKET"
IS
BEGIN
	--backup old secbasket
	insert into secbaskethist
	(basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, description, backupdt,importdt)
    select basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, description, to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') backupdt,importdt
	from secbasket where basketid  in (select basketid from secbaskettemp);
	delete from secbasket where basketid in (select basketid from secbaskettemp);
	insert into secbasket
	(basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, description,importdt)
    select basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, description, to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') importdt
	from secbaskettemp;
RETURN;
END;

 
 
 
 
/
