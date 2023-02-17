SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE p_dahuy_ve_dagui
   ( in_vOrderId IN varchar2)
   IS
BEGIN
    UPDATE odmast
        SET remainqtty=remainqtty+cancelqtty,
            cancelqtty=0,
            orstatus=2,
            edstatus='N'
        WHERE orderid=in_vOrderId AND edstatus='W' AND orstatus=2 AND cancelqtty>0;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('LOI:'||SQLERRM);
        ROLLBACK;
        pr_error(SQLERRM, 'P_DAHUY_VE_DAGUI');
        COMMIT;
END; -- Procedure
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
