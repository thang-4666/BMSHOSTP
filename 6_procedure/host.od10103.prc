SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od10103 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_NUMBUY         NUMBER (20,2);

   --V_TRADELOG CHAR(2);
   --V_AUTOID NUMBER;
   V_FRDATE DATE ;
   V_TODATE DATE ;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;
   V_FRDATE := TO_DATE(F_DATE ,'DD/MM/YYYY');
   V_TODATE := TO_DATE(T_DATE ,'DD/MM/YYYY');

-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
select symbol, Buy_qtty/1000 Buy_qtty,  TRUNC(buy_amt/1000000,3) buy_amt, Sell_qtty/1000 Sell_qtty,
    TRUNC(Sell_amt/1000000,3) Sell_amt, qtty/1000 qtty, TRUNC(amt/1000000,3) amt
FROM
(
    select *
    from
    (
        select od.symbol,
            sum(case when OD.bors = 'B' then od.matchqtty else 0 end) Buy_qtty,
            sum(case when OD.bors = 'B' then od.matchqtty*od.matchprice else 0 end) buy_amt,
            sum(case when OD.bors = 'S' then od.matchqtty else 0 end) Sell_qtty,
            sum(case when OD.bors = 'S' then od.matchqtty*od.matchprice else 0 end) Sell_amt,
            sum(od.matchqtty) qtty,
            sum(od.matchqtty*od.matchprice) amt
        from vw_iod_all od, sbsecurities sb, CFMAST cf
        where od.txdate between V_FRDATE and V_TODATE and substr(OD.custodycd,4,1) <> 'P'
            and od.deltd <> 'Y' and od.codeid = sb.codeid and sb.sectype in ('002','001','008','011')--Ngay 23/03/2017 CW NamTv them sectype 011
             and od.custodycd = cf.custodycd
        group by od.symbol
    )
    order by amt desc
)
where rownum <= 15
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
/
