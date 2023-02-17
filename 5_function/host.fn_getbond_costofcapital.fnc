SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getbond_costofcapital(PV_SFEERSV NUMBER, PV_SPVALDATE VARCHAR2, PV_SVALDATE VARCHAR2, PV_STOTALBUY NUMBER)
  RETURN  NUMBER
-- Lua chon Ma trai phieu, Load ra LISTINGQTTY

  IS
    v_COSTOFCAPITAL NUMBER(20,4);
   -- Declare program variables as shown above
BEGIN
    --SFEERSV|//|@100**|((SPVALDATE|--|SVALDATE))|**|STOTALBUY|//|@360))
    v_COSTOFCAPITAL := ROUND((PV_SFEERSV/100)*TO_NUMBER(TO_DATE(PV_SPVALDATE,'DD/MM/RRRR')-TO_DATE(PV_SVALDATE,'DD/MM/RRRR'))*PV_STOTALBUY/360,4);
    RETURN round(v_COSTOFCAPITAL,0);

EXCEPTION
   WHEN others THEN
    RETURN 0;
END;

 
 
 
 
/
