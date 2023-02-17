SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BATCHORDERBACKUP" (indate IN VARCHAR2 , ERR_CODE out Varchar2)
  IS
  V_INDATE VARCHAR2(10);
BEGIN
    V_INDATE:=indate;
    --Sao luu vao odmasthist
    INSERT INTO ODMASTHIST SELECT * FROM ODMAST WHERE ORDERID IN
           (SELECT OD.ORDERID FROM
           (SELECT * FROM ODMAST
           WHERE (EXPDATE<=TO_DATE(V_INDATE,'DD/MM/YYYY') OR ORDERQTTY=EXECQTTY) AND ORSTATUS IN ('5','7')) OD LEFT JOIN
           (SELECT * FROM STSCHD WHERE STATUS='N') SCHD ON OD.ORDERID=SCHD.ORGORDERID
           GROUP BY OD.ORDERID HAVING COUNT(SCHD.ORGORDERID)=0);
    --Sao luu cac lich thanh toan da xoa
    INSERT INTO STSCHDHIST SELECT * FROM STSCHD WHERE DELTD='Y';
    --Sao luu cac lich thanh toan da thanh toan het
    INSERT INTO STSCHDHIST SELECT * FROM STSCHD WHERE ORGORDERID IN
           (SELECT OD.ORDERID FROM
           (SELECT * FROM ODMAST
           WHERE (EXPDATE<=TO_DATE(V_INDATE,'DD/MM/YYYY') OR ORDERQTTY=EXECQTTY) AND ORSTATUS IN ('5','7')) OD LEFT JOIN
           (SELECT * FROM STSCHD WHERE STATUS='N') SCHD ON OD.ORDERID=SCHD.ORGORDERID
           GROUP BY OD.ORDERID HAVING COUNT(SCHD.ORGORDERID)=0);
    --Xoa cac lich thanh toan da bi xoa
    DELETE FROM STSCHD WHERE DELTD='Y';
    --Xoa cac lich thanh toan da thanh toan xong
    DELETE FROM STSCHD WHERE ORGORDERID IN
           (SELECT OD.ORDERID FROM
           (SELECT * FROM ODMAST
           WHERE (EXPDATE<=TO_DATE(V_INDATE,'DD/MM/YYYY') OR ORDERQTTY=EXECQTTY) AND ORSTATUS IN ('5','7')) OD LEFT JOIN
           (SELECT * FROM STSCHD WHERE STATUS='N') SCHD ON OD.ORDERID=SCHD.ORGORDERID
           GROUP BY OD.ORDERID HAVING COUNT(SCHD.ORGORDERID)=0);
    --Xoa cac lenh da duoc backup
    DELETE FROM ODMAST WHERE ORDERID IN
           (SELECT OD.ORDERID FROM
           (SELECT * FROM ODMAST
           WHERE (EXPDATE<=TO_DATE(V_INDATE,'DD/MM/YYYY') OR ORDERQTTY=EXECQTTY) AND ORSTATUS IN ('5','7')) OD LEFT JOIN
           (SELECT * FROM STSCHD WHERE STATUS='N') SCHD ON OD.ORDERID=SCHD.ORGORDERID
           GROUP BY OD.ORDERID HAVING COUNT(SCHD.ORGORDERID)=0);
    --Dong bo thong tin khop lenh GTC tu ODMAST ve FOMAST
    for rec in
    (
        select fo.acctno, sum(od.EXECQTTY) EXECQTTY,sum(od.EXECAMT) EXECAMT
            from (select * from odmast union select * from odmasthist) od, fomast fo
            where od.foacctno = fo.acctno and od.deltd <> 'Y'
            group by fo.acctno

    )
    loop
        UPDATE FOMAST SET
            EXECQTTY=rec.EXECQTTY,
            EXECAMT=rec.EXECAMT
        WHERE acctno=rec.acctno;
    end loop;
    --Cap nhat trang thai cho lenh GTC truoc khi backup

    update fomast set
        status =(case when EXECAMT>0 then 'C'
                      else 'E' end)
    WHERE EXPDATE<TO_DATE(V_INDATE,'DD/MM/YYYY') OR DELTD='Y' OR REMAINQTTY=0;

    --'Back up FOMAST--> FOMASTHIST
    INSERT INTO FOMASTHIST SELECT * FROM FOMAST
        WHERE EXPDATE<TO_DATE(V_INDATE,'DD/MM/YYYY') OR DELTD='Y' OR REMAINQTTY=0;
    DELETE FROM FOMAST
        WHERE EXPDATE<TO_DATE(V_INDATE,'DD/MM/YYYY') OR DELTD='Y' OR REMAINQTTY=0;
    UPDATE FOMAST SET STATUS='P'
        WHERE REMAINQTTY>0 AND DELTD <>'Y';
    INSERT INTO FOMASTLOGALL
        SELECT * FROM FOMASTLOG;
    DELETE FROM FOMASTLOG;
	err_code:='0';
EXCEPTION
    WHEN others THEN
        err_code:='-1'; --System error
        return;
END;

 
 
 
 
/
