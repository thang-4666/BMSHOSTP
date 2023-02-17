SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0087 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE                   IN       VARCHAR2,
   DATE_T                   IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   CIACCTNO                 IN       VARCHAR2,
   SYMBOL                   IN       VARCHAR2,
   TLID            IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_STREXECTYPE    VARCHAR2 (5);
   V_STRSYMBOL      VARCHAR2 (20);
   V_STRTRADEPLACE  VARCHAR2 (3);

   V_STRAFACCTNO       VARCHAR2 (20);
   V_CUSTODYCD       VARCHAR2 (20);

   V_NUMBUY         NUMBER (20,2);

   V_TRADELOG   CHAR(2);
   V_AUTOID     NUMBER;
   V_CUR_DATE   DATE ;
   TRAN_DATE    DATE;
   V_F_DATE     DATE;

   V_NUM_TT     number;
   V_NUM_CC     number;
   V_VAT        number;
   V_WHTAX      number;
   V_STRTLID           VARCHAR2(6);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STRTLID:= TLID;
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
   --
   IF (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := SYMBOL;
   ELSE
      V_STRSYMBOL := '%%';
   END IF;

   --

   V_F_DATE := to_date(I_DATE,'dd/mm/rrrr');
   --ngoc.vu-Jira561
  -- TRAN_DATE :=  getduedate(V_F_DATE, 'B', '000', TO_NUMBER(DATE_T));
   TRAN_DATE :=  getduedate(V_F_DATE, 'B', '001', TO_NUMBER(DATE_T));



   V_STRAFACCTNO := case when upper(CIACCTNO) = 'ALL' then '%' else CIACCTNO end;
   V_CUSTODYCD:= upper(PV_CUSTODYCD);

   SELECT TO_DATE(VARVALUE ,'dd/mm/rrrr') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';
   select varvalue into V_VAT from sysvar where varname = 'ADVSELLDUTY' and grname = 'SYSTEM';
   select varvalue into V_WHTAX from sysvar where varname = 'WHTAX' and grname = 'SYSTEM';
   V_NUM_CC := 0;
   V_NUM_TT := 0;
BEGIN
   select sum(nvl(io.matchqtty*io.matchprice-
        (case when od.execamt > 0 and od.feeacr = 0 then
                  ROUND(floor(odt.deffeerate* od.execamt/100)*io.matchqtty * io.matchprice / od.execamt, 2)
             else
               (CASE WHEN (od.execamt * od.feeacr) = 0 THEN 0 ELSE
                   (CASE WHEN od.TXDATE = V_CUR_DATE
                    THEN ROUND(floor(odt.deffeerate* od.execamt/100)*io.matchqtty * io.matchprice / od.execamt, 2)
                    ELSE ROUND(od.feeacr*io.matchqtty * io.matchprice / od.execamt , 2) END)
               END)
             end) -
      --  (CASE WHEN aft.VAT = 'Y' THEN (V_VAT/100)*(IO.matchqtty * io.matchprice) else 0 end),0)) into V_NUM_CC
        case
            when IO.iodtaxsellamt>0 then IO.iodtaxsellamt
        else
          --  (CASE WHEN cf.VAT = 'Y' THEN (V_VAT/100)*(IO.matchqtty * io.matchprice) else 0 end)
         ( DECODE (CF.VAT,'Y',V_VAT,0)+DECODE (CF.WHTAX,'Y',V_WHTAX,0))/100 *(IO.matchqtty * io.matchprice)
        end
         ,0)) into V_NUM_CC
    from vw_odmast_all od , vw_iod_all io, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, aftype aft, afmast af, odtype odt
    where od.deltd <> 'Y'
        and cf.custid = af.custid
        and od.execamt <> 0
        and od.actype = odt.actype
        and od.orderid = io.orgorderid
        and od.exectype in ('MS')
        and af.actype = aft.actype
        AND AF.ACTYPE NOT IN ('0000')
        and od.afacctno = af.acctno
        and od.txdate = V_F_DATE
        and trim(cf.custodycd) = V_CUSTODYCD
        and od.afacctno like V_STRAFACCTNO
        and od.clearday = TO_NUMBER(DATE_T)
        and io.symbol like V_STRSYMBOL
        and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        ;
EXCEPTION WHEN OTHERS THEN
    V_NUM_CC := 0;
END;
begin
    select sum(nvl(io.matchqtty*io.matchprice-
        (case when od.execamt > 0 and od.feeacr = 0 then
                  ROUND(floor(odt.deffeerate* od.execamt/100)*io.matchqtty * io.matchprice / od.execamt, 2)
             else
               (CASE WHEN (od.execamt * od.feeacr) = 0 THEN 0 ELSE
                   (CASE WHEN od.TXDATE = V_CUR_DATE
                    THEN ROUND(floor(odt.deffeerate* od.execamt/100)*io.matchqtty * io.matchprice / od.execamt, 2)
                    ELSE ROUND(od.feeacr*io.matchqtty * io.matchprice / od.execamt , 2) END)
               END)
             end) -
        --(CASE WHEN aft.VAT = 'Y' THEN (od.taxrate/100)*(IO.matchqtty * io.matchprice) else 0 end)
        case
            when IO.iodtaxsellamt>0 then IO.iodtaxsellamt
        else
          --  (CASE WHEN cf.VAT = 'Y' THEN (V_VAT/100)*(IO.matchqtty * io.matchprice) else 0 end)
           ( DECODE (CF.VAT,'Y',V_VAT,0)+DECODE (CF.WHTAX,'Y',V_WHTAX,0))/100 *(IO.matchqtty * io.matchprice)
        end
        ,0)) into V_NUM_TT
    from vw_odmast_all od , vw_iod_all io, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, aftype aft, afmast af, odtype odt
    where od.deltd <> 'Y'
        and cf.custid = af.custid
        and od.execamt <> 0
        and od.actype = odt.actype
        and od.orderid = io.orgorderid
        and od.exectype in ('NS')
        and af.actype = aft.actype
        AND AF.ACTYPE NOT IN ('0000')
        and od.afacctno = af.acctno
        and od.txdate = V_F_DATE
        and trim(cf.custodycd) = V_CUSTODYCD
        and od.afacctno like V_STRAFACCTNO
        and od.clearday = TO_NUMBER(DATE_T)
        and io.symbol like V_STRSYMBOL
        and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
        ;
EXCEPTION WHEN OTHERS THEN
    V_NUM_TT := 0;
END;
   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR
    select V_NUM_TT NUM_TT, V_NUM_CC NUM_CC,  cf.fullname, cf.custodycd, cf.address,
        DATE_T DATE_T, TRAN_DATE tr_date,
        max(od.orderid) orderid, io.symbol, sum(io.matchqtty) matchqtty, io.matchprice,
        sum(case when od.execamt > 0 and od.feeacr = 0 then
                  ROUND(floor(odt.deffeerate* od.execamt/100)*io.matchqtty * io.matchprice / od.execamt, 2)
             else
               (CASE WHEN (od.execamt * od.feeacr) = 0 THEN 0 ELSE
                   (CASE WHEN od.TXDATE = V_CUR_DATE
                    THEN ROUND(floor(odt.deffeerate* od.execamt/100)*io.matchqtty * io.matchprice / od.execamt, 2)
                    ELSE ROUND(od.feeacr*io.matchqtty * io.matchprice / od.execamt , 2) END)
               END)
             end)  feeamt,
        od.txdate, od.codeid, od.afacctno, od.exectype matchtype,
        --sum(CASE WHEN aft.VAT = 'Y' THEN (od.taxrate/100)*(IO.matchqtty * io.matchprice) else 0 end) taxsellamt
        sum(
            case
                when IO.iodtaxsellamt>0 then IO.iodtaxsellamt
            else
              --  (CASE WHEN cf.VAT = 'Y' THEN (V_VAT/100)*(IO.matchqtty * io.matchprice) else 0 end)
                 ( DECODE (CF.VAT,'Y',V_VAT,0)+DECODE (CF.WHTAX,'Y',V_WHTAX,0))/100 *(IO.matchqtty * io.matchprice)
            end
        ) taxsellamt
    from vw_odmast_all od , vw_iod_all io, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, aftype aft, afmast af, odtype odt
    where od.deltd <> 'Y'
        and cf.custid = af.custid
        and od.execamt <> 0
        and od.actype = odt.actype
        and od.orderid = io.orgorderid
        and od.exectype in ('MS','NS')
        and af.actype = aft.actype
        AND AF.ACTYPE NOT IN ('0000')
        and od.afacctno = af.acctno
        and od.txdate = V_F_DATE
        and trim(cf.custodycd) = V_CUSTODYCD
        and od.afacctno like V_STRAFACCTNO
        and od.clearday = TO_NUMBER(DATE_T)
        and io.symbol like V_STRSYMBOL
         group by  io.symbol, io.matchprice, od.txdate, od.codeid, od.afacctno, od.exectype,
          cf.fullname, cf.custodycd,cf.address;

EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
/
