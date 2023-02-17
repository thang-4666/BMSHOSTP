SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BATCHORDERFINISH" (indate IN VARCHAR2 , ERR_CODE out Varchar2)
  IS
  V_INDATE VARCHAR2(10);
BEGIN
    V_INDATE:=indate;
    update odmast set orstatus=nvl(
    (select odstatus from
        (SELECT ORDERID,
            (CASE WHEN (REMAINQTTY = 0 AND (SELECT COUNT (ORGORDERID) FROM STSCHD WHERE STSCHD.ORGORDERID = ORDERID AND STSCHD.STATUS <> 'C' AND STSCHD.DELTD<>'Y') = 0
                                       AND (SELECT COUNT (ORGORDERID) FROM STSCHD WHERE STSCHD.ORGORDERID = ORDERID AND STSCHD.DELTD<>'Y') > 0)THEN '7'
                  WHEN ((EXECQTTY > 0 AND EXECQTTY <= ORDERQTTY)
                                       AND (SELECT COUNT (ORGORDERID) FROM STSCHD WHERE STSCHD.ORGORDERID = ORDERID) > 0)THEN '4'
                  ELSE '5' END) ODSTATUS
        FROM ODMAST
        WHERE ORSTATUS <> '5' AND ORSTATUS <> '7' AND (EXPDATE < TO_DATE(V_INDATE,'DD/MM/YYYY'))
             OR (REMAINQTTY = 0 AND (SELECT COUNT (ORGORDERID) FROM STSCHD WHERE STSCHD.ORGORDERID = ORDERID AND STSCHD.STATUS <> 'C' AND STSCHD.DELTD<>'Y') =0)
		) A
    where a.orderid=odmast.orderid),odmast.orstatus
	);
	err_code:='0';
EXCEPTION
    WHEN others THEN
        err_code:='-1'; --System error
        return;
END;

 
 
 
 
/
