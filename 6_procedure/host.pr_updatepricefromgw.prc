SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_updatepricefromgw(p_symbol        in varchar2,
                                p_basic_price   in number,
                                p_floor_price   in number,
                                p_ceiling_price in number,
                                p_update_mode   in varchar2,
                                p_err_code      out varchar2,
                                p_err_message   out varchar2,
                                p_flag_run IN VARCHAR2 DEFAULT 'N') is
    l_code_id     varchar2(6);
    l_update_mode varchar2(12);
    l_tradeplace varchar2(12);
    l_basic_price number(20,4);
    v_ticksize number(10);
    l_sectype VARCHAR2(20);--TPDN tran san: 10tr 1k
    v_ceiling_price number;
    v_floor_price   number;
    pkgctx plog.log_ctx;
Begin
    plog.setbeginsection (pkgctx, 'Pr_Updatepricefromgw');
-- p_update_mode DN : Dau ngay
-- p_update_mode CN : Cuoi ngay
    l_update_mode := p_update_mode;
    Select codeid,tradeplace, sectype into l_code_id,l_tradeplace, l_sectype--TPDN tran san: 10tr 1k
    From sbsecurities
    Where SYMBOL = p_symbol;
    l_basic_price:=p_basic_price;
    BEGIN
        SELECT   ticksize
        INTO   v_ticksize
        FROM   securities_ticksize
        WHERE       symbol = p_symbol
        AND (p_ceiling_price + p_floor_price) / 2 >= fromprice
        AND (p_ceiling_price + p_floor_price) / 2 <= toprice;
    EXCEPTION    WHEN OTHERS    THEN
        v_ticksize  := 1;
    END;

    --Neu chech lech 2 lan ticksize la thuc hien quyen -> lay trung binh tran va san
    -- Check lai voi The de lam trong theo ticksize
    IF l_sectype <> '012' and ABS((p_ceiling_price + p_floor_price)/2 - p_basic_price) > 2* v_ticksize THEN--TPDN tran san: 10tr 1k
        l_basic_price:= Round(
                               ((p_ceiling_price + p_floor_price)/2)
                               /v_ticksize
                             )
                             * v_ticksize ;
    END IF;
  --Check neu tran=san=tham chieu
  --Tran = tran  +  1 buoc gia
  --San = san - 1 buoc gia
  --1.0.9.0: ko tinh lai  voi TPDN
   v_floor_price:=p_floor_price;
   v_ceiling_price:= p_ceiling_price;
  IF l_sectype <> '012' and p_ceiling_price=p_floor_price THEN
    v_ceiling_price:=p_ceiling_price + v_ticksize;
    v_floor_price:=p_floor_price - v_ticksize;
    IF v_floor_price=0 THEN
      v_floor_price:=v_floor_price+v_ticksize;
      END IF;
  END IF;
    CASE
    When l_update_mode = 'DN' then
    -- DN : Dau ngay
        Update securities_info
        Set --FLOORPRICE         = p_floor_price, --TPDN
            --CEILINGPRICE       = p_ceiling_price,--TPDN
            BASICPRICE         = p_basic_price,
            avgprice       = l_basic_price,
            dfrlsprice         = l_basic_price,
            dfrefprice         = l_basic_price,
             marginprice        = l_basic_price,
             margincallprice    = l_basic_price,
             marginrefprice     = l_basic_price,
             marginrefcallprice = l_basic_price
        Where (CODEID = l_code_id or
                CODEID in (Select CODEID
                           From SBSECURITIES
                           Where REFCODEID = l_code_id)
                 OR codeid IN (SELECT sb.codeid
                                    FROM securities_info se, sbsecurities sb
                                    WHERE se.codeid = sb.codeid AND sb.sectype ='004' AND substr( sb.symbol,1,instr(sb.symbol,'_')-1) = p_SYMBOL));
         --1.0.9.0 TPDN: cap nhat tran/san
         update securities_info
         set FLOORPRICE         = p_floor_price,
             CEILINGPRICE       = p_ceiling_price
         where p_floor_price >0 and p_ceiling_price >0 and
           (CODEID = l_code_id or
                CODEID in (Select CODEID
                           From SBSECURITIES
                           Where REFCODEID = l_code_id)
                 OR codeid IN (SELECT sb.codeid
                                    FROM securities_info se, sbsecurities sb
                                    WHERE se.codeid = sb.codeid AND sb.sectype ='004' AND substr( sb.symbol,1,instr(sb.symbol,'_')-1) = p_SYMBOL));
    When l_update_mode = 'CN' then
        If l_tradeplace ='001' then
        -- CN : Cuoi ngay
            --San HOSE thi cap nhat tran san theo so tra ve , gia tham chieu da dieu chinh
            Update securities_info
            Set newprice       = '1',
                avgprice       = l_basic_price,
                newbasicprice = p_basic_price,
                newceilingprice = v_ceiling_price,
                newfloorprice   =  v_floor_price
            Where ( newprice       = '0' OR p_flag_run = 'Y')
                and CODEID in (Select CODEID
                               From SBSECURITIES
                               Where  CODEID = l_code_id or REFCODEID = l_code_id
                                   OR codeid IN (SELECT sb.codeid
                                    FROM securities_info se, sbsecurities sb
                                    WHERE se.codeid = sb.codeid AND sb.sectype ='004' AND substr( sb.symbol,1,instr(sb.symbol,'_')-1) = p_SYMBOL)
                               );
        Else
            --San HNX thi cap nhat tran,san theo gai dong cua cua so p_basic_price
            v_floor_price := fn_get_price_nextdate(l_code_id, nvl(p_basic_price,0), 'F');
            v_ceiling_price := fn_get_price_nextdate(l_code_id, nvl(p_basic_price,0), 'C');
      --1.0.10.1
      -- XLY truong hop gia tham chieu tra ve <1000

      IF l_sectype <> '012' and v_floor_price = v_ceiling_price  THEN
          v_ceiling_price:= v_ceiling_price + v_ticksize;
          v_floor_price:= v_floor_price - v_ticksize;
          IF v_floor_price=0 THEN
            v_floor_price:=v_floor_price+v_ticksize;
            END IF;
      END IF;

            Update securities_info
            Set newprice       = '1',
                avgprice       = p_basic_price,
                newbasicprice = p_basic_price,
                newceilingprice = v_ceiling_price,
                newfloorprice   =  v_floor_price
            Where  ( newprice       = '0' OR p_flag_run = 'Y')
                and CODEID in (Select CODEID
                               From SBSECURITIES
                               Where  CODEID = l_code_id or REFCODEID = l_code_id
                                OR codeid IN (SELECT sb.codeid
                                    FROM securities_info se, sbsecurities sb
                                    WHERE se.codeid = sb.codeid AND sb.sectype ='004' AND substr( sb.symbol,1,instr(sb.symbol,'_')-1) = p_SYMBOL)
                               );
        End if;
    End case;
    Commit;
    p_err_code    := '0';
    p_err_message := 'Cap nhat gia thanh cong';
    plog.setendsection (pkgctx, 'Pr_Updatepricefromgw');
Exception
    When NO_DATA_FOUND then
        p_err_code    := '-100010';
        p_err_message := 'Khong tim thay ma chung khoan';
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.error(pkgctx,'Pr_Updatepricefromgw p_symbol = ' || p_symbol||' - p_update_mode ='||p_update_mode);
        plog.setendsection (pkgctx, 'Pr_Updatepricefromgw');
        rollback;
    When others then
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.error(pkgctx,'Pr_Updatepricefromgw p_symbol = ' || p_symbol||' - p_update_mode ='||p_update_mode);
        plog.setendsection (pkgctx, 'Pr_Updatepricefromgw');
        rollback;
End;
/
