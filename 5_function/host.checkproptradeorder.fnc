SET DEFINE OFF;
CREATE OR REPLACE FUNCTION CHECKPROPTRADEORDER (
        f_acctno IN  varchar,
		f_side IN  varchar,
		f_symbol in varchar,
        f_quantity in varchar,
        f_price in varchar,        
		f_traderid in varchar
) RETURN varchar
AS
	codeid VARCHAR(50); 
	idtrader VARCHAR(50); 
	groupid VARCHAR(50); 
	ret VARCHAR(50); 
	cnt int;
	
	sys_max_qtty_per_order int;
	sys_max_nav_all float;
	sys_current_nav_all float;
	group_max_nav_all float;
	group_current_nav_all float;
	
	trader_mavavlbal int; 
	trader_minavlbal int;
	trader_maxallbuy int;
	trader_maxallsell int;
	trader_totalqtty int;
	trader_avlqtty int;
	trader_mktvalue int; 
	trader_maxnav int;
	trader_maxbprice int;
	trader_minsprice int;
	trader_deltabprc int;
	trader_deltasprc int;
	trader_rfprice int;
	
	trader_buy_order_qtty int;
	trader_sell_order_qtty int;
	trader_buy_order_value int;
	trader_sell_order_value int;
BEGIN

	ret := '';
	cnt := 0;
	
	trader_buy_order_qtty := 0;
	trader_sell_order_qtty := 0;
	trader_buy_order_value := 0;
	trader_sell_order_value := 0;
	
	SELECT CODEID INTO codeid FROM SBSECURITIES WHERE SYMBOL=f_symbol;
	
	--Lấy tham số mức hệ thống
	SELECT COUNT(MST.AUTOID) INTO cnt FROM CFTRDPOLICY MST WHERE MST.LEVELCD='S';
	IF cnt=0 THEN
		BEGIN
			sys_max_qtty_per_order := 999999999999;	--UNLIMITED
			sys_max_nav_all :=999999999999;			--UNLIMITED
		END;
	ELSE
		SELECT NVL(MAXNAV,0), NVL(MAXQTTYODR,0) INTO sys_max_nav_all, sys_max_qtty_per_order 
		FROM CFTRDPOLICY MST WHERE MST.LEVELCD='S';
	END IF;
	
	--Khối lượng lệnh phải nằm trong qui định
	IF (f_quantity>sys_max_qtty_per_order AND sys_max_qtty_per_order>0) THEN
		BEGIN
			ret := 'msgDEALER_OVER_SYS_MAX_QTTY_PER_ORDER';
			RETURN ret;
		END;
	END IF;
	
	--traderid: người đặt lệnh phải là user quản lý hoặc leader có quyền đặt lệnh
	SELECT COUNT(AUTOID) INTO cnt
	FROM CFAFTRDLNK WHERE AFACCTNO=f_acctno AND TRADERID=f_traderid AND STATUS='A';
	IF cnt=0 THEN
		BEGIN
			SELECT COUNT(AUTOID) INTO cnt
			FROM CFAFTRDLNK WHERE AFACCTNO=f_acctno AND LEADERID=f_traderid AND STATUS='A' AND LEADERCD='PLO';
			IF cnt=0 THEN
				ret := 'msgDEALER_TRADER_CANNOT_PLACE_ORDER';
				RETURN ret;
			END IF;
		END;
	END IF;
	
	
	--Lấy mã của cán bộ quản lý tài khoản trực tiếp
	SELECT MAX(TRADERID), MAX(NVL(GROUPID,'')) INTO idtrader, groupid 
	FROM CFAFTRDLNK WHERE AFACCTNO=f_acctno AND STATUS='A';
	
	--Kiểm tra qui định của CÁN BỘ TỰ DOANH
	--Giá MUA/BÁN phải nằm trong qui định của đối với tài khoản
	--Nếu là lệnh MUA thì khối lượng mua thêm ko được vượt quá qui định cho phép của môi giới
	SELECT COUNT(*) INTO cnt
	FROM VW_DEALER_POLICY WHERE SYMBOL=f_symbol AND TRADERID=idtrader;
	IF cnt>0 THEN
		BEGIN
			SELECT MAXAVLBAL, MINAVLBAL, MAXALLBUY, MAXALLSELL, RFPRICE,
				TOTALQTTY, AVLQTTY, AVLQTTY*RFPRICE, MAXNAV, MAXBPRICE, MINSPRICE, DELTABPRC, DELTASPRC
			INTO trader_mavavlbal, trader_minavlbal, trader_maxallbuy, trader_maxallsell, trader_rfprice,
				trader_totalqtty, trader_avlqtty, trader_mktvalue, trader_maxnav, 
				trader_maxbprice, trader_minsprice, trader_deltabprc, trader_deltasprc
			FROM VW_DEALER_POLICY WHERE SYMBOL=f_symbol AND TRADERID=idtrader;		
		
			IF (f_side='NB') THEN
				--MUA
				BEGIN
					--Giá mua theo qui định
					IF f_price>trader_maxbprice THEN
					BEGIN
						ret := 'msgDEALER_OVER_MAX_BUYING_PRICE';
						RETURN ret;
					END;
					END IF;
					
					--Biên độ giá mua
					IF trader_deltabprc>0 THEN
						IF f_price>trader_rfprice*(1+trader_deltabprc/1000) THEN
							BEGIN
								ret := 'msgDEALER_OVER_DELTA_BUYING_PRICE';
								RETURN ret;
							END;					
						END IF;
					END IF;
					
					
					--Lấy thông tin về lệnh giao dịch trong ngày
					SELECT SUM(DECODE(EXECTYPE,'NB',REMAINQTTY*QUOTEPRICE+EXECAMT,0)) BUY_VALUE, 
						SUM(DECODE(EXECTYPE,'NS',EXECAMT,0)) SELL_VALUE
					INTO trader_buy_order_value, trader_sell_order_value				
					FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader
					GROUP BY AF.TRADERID;
					
					SELECT SUM(DECODE(EXECTYPE,'NB',REMAINQTTY+EXQTTY,0)) BUY_QTTY, 
						SUM(DECODE(EXECTYPE,'NS',EXQTTY,0)) SELL_QTTY
					INTO trader_buy_order_qtty, trader_sell_order_qtty
					FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.TRADERID=idtrader AND OD.CODEID=codeid
					GROUP BY AF.TRADERID;

					--Khối lượng tối đa
					IF f_quantity>trader_totalqtty-trader_avlqtty-trader_buy_order_qtty+trader_sell_order_qtty THEN
					BEGIN
						ret := 'msgDEALER_OVER_TOTAL_QTTY';
						RETURN ret;
					END;	
					END IF;					
					
					--Giá trị tối đa
					IF f_quantity*f_price>trader_mktvalue-trader_buy_order_value+trader_sell_order_value THEN
					BEGIN
						ret := 'msgDEALER_OVER_TOTAL_QTTY';
						RETURN ret;
					END;	
					END IF;
				END;
			ELSE
				--BÁN
				BEGIN
					--Giá bán
					IF f_price<trader_minsprice THEN
					BEGIN
						ret := 'msgDEALER_OVER_MIN_SELLING_PRICE';
						RETURN ret;
					END;
					END IF;
					
					--Biên độ giá bán
					IF trader_deltasprc>0 THEN
						IF f_price<trader_rfprice*(1-trader_deltasprc/1000) THEN
							BEGIN
								ret := 'msgDEALER_OVER_DELTA_SELLING_PRICE';
								RETURN ret;
							END;					
						END IF;
					END IF;
				END;				
			END IF;
		END;
	ELSE
		BEGIN
			ret := 'msgDEALER_SYMBOL_CANNOT_TRADE';
			RETURN ret;
		END;
	END IF;
		
		
	--KIỂM TRA MỨC NHÓM: GIÁ TRỊ DANH MỤC
	IF (f_side='NB') THEN
	BEGIN
		SELECT COUNT(AUTOID) INTO cnt FROM CFTRDPOLICY WHERE LEVELCD='G' AND STATUS='A' AND REFID=groupid;
		IF cnt>0 THEN
			BEGIN
				SELECT COUNT(MAXNAV) INTO group_max_nav_all 
				FROM CFTRDPOLICY WHERE LEVELCD='G' AND STATUS='A' AND REFID=groupid;
				
				SELECT SUM(AVLQTTY*RFPRICE) INTO group_current_nav_all FROM VW_DEALER_POLICY WHERE GROUPID=groupid;
				
				SELECT SUM(DECODE(EXECTYPE,'NB',REMAINQTTY*QUOTEPRICE+EXECAMT,0)) BUY_VALUE, 
					SUM(DECODE(EXECTYPE,'NS',EXECAMT,0)) SELL_VALUE
				INTO trader_buy_order_value, trader_sell_order_value				
				FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO AND AF.GROUPID=groupid; 
				
				IF (group_current_nav_all+f_quantity*f_price+trader_buy_order_value-trader_sell_order_value>group_max_nav_all) THEN
					BEGIN
						ret := 'msgDEALER_OVER_SYS_CURRENT_NAV_ALL';
						RETURN ret;
					END;
				END IF;
			END;
		END IF;
	END;
	END IF;
	
	--KIỂM TRA MỨC CÔNG TY: GIÁ TRỊ DANH MỤC
	IF (f_side='NB' and sys_max_nav_all>0) THEN
		BEGIN
			SELECT SUM(AVLQTTY*RFPRICE) INTO sys_current_nav_all FROM VW_DEALER_POLICY;
			
			SELECT SUM(DECODE(EXECTYPE,'NB',REMAINQTTY*QUOTEPRICE+EXECAMT,0)) BUY_VALUE, 
				SUM(DECODE(EXECTYPE,'NS',EXECAMT,0)) SELL_VALUE
			INTO trader_buy_order_value, trader_sell_order_value				
			FROM ODMAST OD, CFAFTRDLNK AF WHERE OD.AFACCTNO=AF.AFACCTNO; 
			
			IF (sys_current_nav_all+f_quantity*f_price+trader_buy_order_value-trader_sell_order_value>sys_current_nav_all) THEN
				BEGIN
					ret := 'msgDEALER_OVER_SYS_CURRENT_NAV_ALL';
					RETURN ret;
				END;
			END IF;
		END;
	END IF;
	
	RETURN ret;
EXCEPTION
	WHEN OTHERS THEN
		ret := SQLERRM;	--Mã lỗi của ORACLE
END;
 
 
 
 
 
 
 
 
 
 
 
/
