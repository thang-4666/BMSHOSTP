SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_symbol_tradeplace( pv_codeid IN VARCHAR2,pv_txdate IN VARCHAR2)
    RETURN VARCHAR2 IS
   v_tradeplace_CRR varchar2(10);
   v_frtradeplace varchar2(10);
   min_autoid number ;
BEGIN
    select tradeplace into  v_tradeplace_CRR from sbsecurities where codeid = pv_codeid    ;


/*    select MIN(AUTOID) into min_autoid  from setradeplace where codeid =pv_codeid
    and txdate in (  select min (txdate) from  setradeplace where codeid =pv_codeid )

    ;
EXCEPTION
WHEN OTHERS
   THEN
  min_autoid:=0;
END ;


for rec in (
 SELECT frtradeplace  FROM setradeplace WHERE AUTOID =min_autoid)
 loop
 v_frtradeplace:=rec.frtradeplace;
 end loop  ;*/


for rec in (
/* SELECT frtradeplace  FROM setradeplace
 WHERE AUTOID IN(
            select  MIN(AUTOID) from setradeplace
            where codeid =pv_codeid and TXDATE
            IN (SELECT min (txdate) from setradeplace where  txdate >  to_date (pv_txdate,'DD/MM/YYYY'))
                )
*/
SELECT frtradeplace  FROM setradeplace
 WHERE AUTOID =(select min(AUTOID) from setradeplace
                where codeid =pv_codeid and TXDATE=
                (SELECT min (txdate) from setradeplace where  txdate >  to_date (pv_txdate,'DD/MM/RRRR') and codeid=pv_codeid))

 )
 loop
 v_frtradeplace:=rec.frtradeplace;
 end loop  ;

 v_frtradeplace:= NVL(v_frtradeplace,v_tradeplace_CRR);

RETURN v_frtradeplace;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
/
