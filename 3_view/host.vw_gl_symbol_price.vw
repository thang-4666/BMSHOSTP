SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GL_SYMBOL_PRICE
(SYMBOL, BASICPRICE, TXDATE)
BEQUEATH DEFINER
AS 
select symbol, basicprice, to_char(txdate,'YYYY-MM-DD') txdate
    from
    (
        select symbol, basicprice, txdate
            from securities_info
            where --symbol not like '%_WFT' and
                basicprice <> 0
                and txdate in
                    (
                        select sbdate
                            from sbcldr
                            where holiday = 'N' and cldrtype='000' and sbdate <= getcurrdate
                    )
        group by symbol, basicprice, txdate
        /*union all
        select symbol, avgprice, histdate
            from securities_info_hist
            where --symbol not like '%_WFT' and
                avgprice <> 0
                and histdate in
                    (
                        select sbdate
                            from sbcldr
                            where holiday = 'N' and cldrtype='000' and sbdate <= getcurrdate
                    )
        group by symbol, avgprice, histdate*/
    )
    group by symbol, basicprice, txdate
/
