SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0003 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION   VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID     VARCHAR2 (4);               -- USED WHEN V_NUMOPTION > 0
   V_STREXECTYPE      VARCHAR2 (5);

   V_STRSYMBOL          VARCHAR2 (20);
   V_IN_DATE            DATE;
   V_STRCUSTODYCD       VARCHAR2(20);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
   V_IN_DATE := to_date(I_DATE, 'DD/MM/RRRR');
   if(upper(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD is null) then
        V_STRCUSTODYCD := '%';
   else
        V_STRCUSTODYCD := upper(PV_CUSTODYCD);
   end if;

   if(upper(PV_SYMBOL) = 'ALL' or PV_SYMBOL is null) then
        V_STRSYMBOL := '%';
   else
        V_STRSYMBOL := upper(PV_SYMBOL);
   end if;
   --

-- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR
        select 2 or_by, mst.custodycd, mst.fullname, mst.symbol, mst.sebalance sebalance,
            (mst.sebalance) sebalance_be, nvl(od.orderqtty,0) orderqtty, nvl(od.execqtty,0) execqtty,
            0 cibalance, 0 cibalance_be, 0 credit_amt, 0 execamt, I_DATE indate
        from
        (--- so du chung khoan hien tai
                select mst.acctno seacctno, cf.custodycd, cf.fullname, sb.symbol, mst.namt sebalance
                from
                (
                    select acctno, namt
                    from setran tr
                    where tr.tltxcd = '2287'
                        and tr.txdate = V_IN_DATE
                        and tr.txnum = (select max(txnum) from setran
                                        where txdate = V_IN_DATE
                                            and acctno = tr.acctno
                                        )
                    union all
                    select acctno, namt
                    from setrana tr
                    where  tr.tltxcd = '2287'
                        and tr.txdate = V_IN_DATE
                        and tr.txnum = (select max(txnum) from setrana
                                        where txdate = V_IN_DATE
                                            and acctno = tr.acctno
                                        )
                ) MST, semast SE, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, sbsecurities SB
                WHERE MST.acctno = SE.acctno AND SE.afacctno = AF.acctno
                    AND CF.custid = AF.custid AND SE.codeid = SB.codeid
                    AND AF.ACTYPE NOT IN ('0000')
                    and cf.custodycd like V_STRCUSTODYCD
                    and sb.symbol like V_STRSYMBOL
        ) mst
        left join
        (--- cac phat sinh lenh ban trong ngay.
            select seacctno, sum(orderqtty) orderqtty, sum(execqtty) execqtty
            from
            (
                select * from odmast
                where txdate = V_IN_DATE
                    and exectype like '%S'
                    and deltd <> 'Y'
                union all
                select * from odmasthist
                where txdate = V_IN_DATE
                    and exectype like '%S'
                    and deltd <> 'Y'
            )
            group by seacctno
        ) od
        on mst.seacctno = od.seacctno
        where mst.custodycd not like systemnums.C_COMPANYCD||'%' and mst.sebalance <> 0 or (mst.sebalance) <> 0 or
        nvl(od.orderqtty,0) <> 0 or nvl(od.execqtty,0) <> 0
        union all
        select 1 or_by, mst.custodycd, mst.fullname, null symbol, 0 sebalance,
            0 sebalance_be, 0 orderqtty, 0 execqtty, sum(mst.cibalance) cibalance,
            sum(mst.cibalance_be) cibalance_be, sum(mst.credit_amt) credit_amt,
            sum(mst.execamt) execamt, I_DATE indate
        from
        (
            select mst.custodycd, mst.fullname, mst.cibalance,
                nvl(tr.amt,0) cibalance_be, nvl(tr_in_date.amt,0) credit_amt,
                nvl(od.execamt,0) execamt
            from
            (--- so du tien tai thoi diem hien tai
                select af.acctno afacctno, mst.acctno ciacctno, cf.custodycd, cf.fullname, mst.balance cibalance
                from cimast mst, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                where mst.afacctno = af.acctno
                    and af.custid = cf.custid
                    and cf.custodycd like V_STRCUSTODYCD
                    AND AF.ACTYPE NOT IN ('0000')
                    and cf.custodycd not like systemnums.C_COMPANYCD||'%'
            ) mst
            left join
            (--- so tien cap dau ngay.
                select txnum, msgacct, msgamt amt
                from
                (
                    select tl.txnum, tl.msgacct, tl.msgamt
                    from tllog tl
                    where tltxcd = '1187' and txdate = V_IN_DATE
                        and tl.txnum = (select min(txnum) from tllog where msgacct = tl.msgacct and txdate = V_IN_DATE and tltxcd = '1187')
                    union all
                    select tl.txnum, tl.msgacct, tl.msgamt
                    from tllogall tl
                    where tltxcd = '1187' and txdate = V_IN_DATE
                        and tl.txnum = (select min(txnum) from tllogall where msgacct = tl.msgacct and txdate = V_IN_DATE and tltxcd = '1187')
                    order by txnum
                )
                order by txnum
            ) tr
            on mst.afacctno = tr.msgacct
            left join
            (--- So tien cap lan cuoi trong ngay.
                select txnum, msgacct, msgamt amt
                from
                (

                    select tl.txnum, tl.msgacct, tl.msgamt
                    from tllog tl
                    where tl.tltxcd = '1187' and tl.txdate = V_IN_DATE
                        and (select count(1) from tllog where msgacct = tl.msgacct and txdate = V_IN_DATE and tltxcd = '1187' ) > 1
                        and tl.txnum = (select max(txnum) from tllog where msgacct = tl.msgacct and txdate = V_IN_DATE and tltxcd = '1187')
                    union all
                    select tl.txnum, tl.msgacct, tl.msgamt
                    from tllogall tl
                    where tl.tltxcd = '1187' and tl.txdate = V_IN_DATE
                        and (select count(1) from tllogall where msgacct = tl.msgacct and txdate = V_IN_DATE and tltxcd = '1187') > 1
                        and tl.txnum = (select max(txnum) from tllogall where msgacct = tl.msgacct and txdate = V_IN_DATE and tltxcd = '1187')
                    order by txnum desc
                )
                order by txnum desc
            ) tr_in_date
            on mst.afacctno = tr_in_date.msgacct
            left join
            (--- gia tri mua trong ngay in_date.
                select AFACCTNO ciacctno, sum(exeamt) execamt
                from
                (
                    SELECT OD.AFACCTNO, OD.TXDATE, OD.ORDERID,
                        round(OD.EXECAMT +
                            (case when od.feeacr > 0 then od.feeacr
                                else (ROUND(ODT.DEFFEERATE,5)*od.EXECAMT)/100 end )+
                                ((od.orderqtty-od.execqtty)*quoteprice*(od.bratio/100))
                                ) exeamt
                    FROM VW_ODMAST_ALL OD, VW_STSCHD_ALL STS, ODTYPE ODT
                    WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
                        AND STS.DELTD = 'N' AND OD.DELTD = 'N'
                        AND ODT.ACTYPE = OD.ACTYPE
                        AND INSTR(OD.EXECTYPE,'B') > 0
                        AND OD.TXDATE = V_IN_DATE
                )
                group by AFACCTNO
            ) od
            on mst.ciacctno = od.ciacctno
        ) mst
        where mst.custodycd like V_STRCUSTODYCD
            and mst.custodycd not like systemnums.C_COMPANYCD||'%'
        group by mst.custodycd, mst.fullname
        having sum(mst.cibalance) <> 0 or
            sum(mst.cibalance_be) <> 0 or
            sum(mst.credit_amt) <> 0 or
            sum(mst.execamt) <> 0
          ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
