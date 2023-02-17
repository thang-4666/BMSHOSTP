SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SECNET_RE"
IS
-- Purpose:
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- DUNGNH      06/08/2013
-- ---------   ------  -------------------------------------------
V_qtty number(20);

BEGIN

FOR rec IN
 (
    select txnum, txdate, acctno, afacctno, symbol, codeid, sum(namt) namt
    from vw_setran_gen
    where tltxcd = '2262' and txdate = to_date('24/01/2014','dd/mm/rrrr')
        and txtype = 'C' and field not in ('DCRAMT','DCRQTTY','DDROUTQTTY','DDROUTAMT','NETTING') and namt <> 0
    group by txnum, txdate, acctno, afacctno, symbol, codeid
  )
LOOP
    INSERT INTO secmast (AUTOID,TXNUM,TXDATE,ACCTNO,CODEID,TRTYPE,PTYPE,CAMASTID,ORDERID,QTTY,COSTPRICE,
        MAPQTTY,STATUS,MAPAVL,BUSDATE,DELTD,TRQTTY)
    VALUES(secmast_seq.NEXTVAL, rec.txnum, rec.txdate, rec.afacctno, rec.codeid,'D','I',NULL,NULL, rec.namt,
        18700,0,'P','Y',rec.txdate,'N',0);
    UPDATE secmast SET MAPQTTY = 0, status = 'P' where acctno = rec.afacctno and codeid = rec.codeid;
    UPDATE SECNET SET DELTD = 'Y' where acctno = rec.afacctno and codeid = rec.codeid;

    FOR rec1 IN
     (
         select * from secmast where ptype = 'O' and acctno = rec.afacctno and codeid = rec.codeid
         ORDER BY autoid ASC
      )
    LOOP
        secnet_map(rec1.acctno,rec1.codeid, REC1.autoid);
    END LOOP;

END LOOP;


EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            return;
        END;
END;

 
 
 
 
/
