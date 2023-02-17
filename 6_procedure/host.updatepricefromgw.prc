SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE updatepricefromgw ( v_strTIME_UPDATE in varchar2, pv_BasicPrice IN number, pv_FloorPrice IN number , pv_CeilPrice IN number, pv_SYMBOL IN VARCHAR2)
is
    v_CODEID VARCHAR2(6);
    v_strUpdate_Time  VARCHAR2(12);
BEGIN
    -- Create : hai.letran
    -- Modify : quyet.kieu
    -- DN : Dau ngay
    -- CN : Cuoi ngay
    -- ELSE : Hien tai dang de bang DN , cho nay tuy cac bac xu ly
   v_strUpdate_Time :=v_strTIME_UPDATE;
   select codeid into v_CODEID from securities_info where SYMBOL = pv_SYMBOL;

   Case WHEN v_strUpdate_Time='DN' then
    -- DN : Dau ngay

             update securities_info set

                   FLOORPRICE =    pv_FloorPrice,
                   CEILINGPRICE=  pv_CeilPrice,
                   BASICPRICE=    pv_BasicPrice,
                   dfrlsprice = pv_BasicPrice,
                   dfrefprice  =pv_BasicPrice,
                   marginprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   margincallprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   marginrefcallprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   marginrefprice =fn_calmarginprice(symbol,pv_BasicPrice)--pv_BasicPrice
             where ( CODEID=v_CODEID
                     Or CODEID=(SELECT CODEID FROM SBSECURITIES WHERE REFCODEID=v_CODEID)
                   ) ;

   WHEN v_strUpdate_Time='CN' THEN
    -- CN : Cuoi ngay

            update securities_info set
                   dfrefprice  =pv_BasicPrice,
                   dfrlsprice  =pv_BasicPrice,
                   margincallprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   marginrefcallprice =fn_calmarginprice(symbol,pv_BasicPrice)--pv_BasicPrice
             where ( CODEID=v_CODEID
                     Or CODEID=(SELECT CODEID FROM SBSECURITIES WHERE REFCODEID=v_CODEID)
                   ) ;   -- Cap nhat cho CK va CK cho giao dich
/*
[6:09:31 PM] FSS Quynh Chi: 3 tru?ng n?em oi:
[6:09:40 PM] FSS Quynh Chi: 1. margincallprice
[6:09:48 PM] FSS Quynh Chi: 2. marginrefcallprice
[6:10:04 PM] FSS Quynh Chi: 3. dfrefprice
[6:10:17 PM] FSS Quynh Chi: trong gi? giao d?ch: l?y gi?h?p g?n nh?t d? update.
[6:10:33 PM] FSS Quynh Chi: ngay khi nh?n du?c SU: d? t? l?y gi?ham chi?u h?m sau d? update.
*/
   ELSE
   -- Goi khac
    -- DN : Dau ngay

             update securities_info set
                   FLOORPRICE =    pv_FloorPrice,
                   CEILINGPRICE=  pv_CeilPrice,
                   BASICPRICE=    pv_BasicPrice,
                   dfrlsprice = pv_BasicPrice,
                   dfrefprice  =pv_BasicPrice,
                   marginprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   margincallprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   marginrefcallprice =fn_calmarginprice(symbol,pv_BasicPrice),--pv_BasicPrice,
                   marginrefprice =fn_calmarginprice(symbol,pv_BasicPrice)--pv_BasicPrice
             where ( CODEID=v_CODEID
                     Or CODEID=(SELECT CODEID FROM SBSECURITIES WHERE REFCODEID=v_CODEID)
                   ) ;

   /*   thu tuc cu cua anh Hai.Letran
    select codeid into v_CODEID from securities_info where SYMBOL = pv_SYMBOL;
    update securities_info set CEILINGPRICE= pv_CeilPrice,
                FLOORPRICE= pv_FloorPrice,
                DFREFPRICE = pv_BasicPrice,
                DFRLSPRICE = pv_BasicPrice,
                BASICPRICE = pv_BasicPrice
    where CODEID=v_CODEID;
     UPDATE SECURITIES_INFO SET (CEILINGPRICE, FLOORPRICE, DFREFPRICE, DFRLSPRICE, BASICPRICE) =
     (SELECT CEILINGPRICE, FLOORPRICE, BASICPRICE, BASICPRICE, BASICPRICE FROM SECURITIES_INFO WHERE CODEID = v_CODEID
     )
    WHERE SECURITIES_INFO.CODEID=(SELECT CODEID FROM SBSECURITIES WHERE REFCODEID=v_CODEID);
    */

   end Case  ;
   commit;
EXCEPTION
   WHEN others
   THEN
   ROLLBACK;
END;

 
 
 
 
/
