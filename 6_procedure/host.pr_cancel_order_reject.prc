SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_cancel_order_reject(p_orderid VARCHAR2) IS
BEGIN
    update odmast set cancelqtty = remainqtty, remainqtty = 0, edstatus = 'W', orstatus = 6 where orderid = p_orderid;
    update ood set deltd ='Y' where orgorderid = p_orderid;
    pr_error('pr_cancel_order_reject', 'p_orderid:' || p_orderid);
END;
 
/
