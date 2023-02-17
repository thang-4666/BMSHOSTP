SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0086 (
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
   --TRAN_DATE :=  getduedate(V_F_DATE, 'B', '000', TO_NUMBER(DATE_T));
   TRAN_DATE :=  getduedate(V_F_DATE, 'B', '001', TO_NUMBER(DATE_T));



   V_STRAFACCTNO := case when upper(CIACCTNO) = 'ALL' then '%' else CIACCTNO end;
   V_CUSTODYCD:= upper(PV_CUSTODYCD);

   SELECT TO_DATE(VARVALUE ,'dd/mm/rrrr') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR
    select cf.fullname, cf.custodycd, cf.address,
        DATE_T DATE_T, TRAN_DATE tr_date,
        max(od.orderid) orderid, io.symbol, sum(io.matchqtty) matchqtty, io.matchprice matchprice,
        sum(case when od.execamt > 0 and od.feeacr = 0 then
                  ROUND(io.matchqtty * io.matchprice * odt.deffeerate / 100, 2)
             else
               (CASE WHEN (od.execamt * od.feeacr) = 0 THEN 0 ELSE
                   (CASE WHEN od.TXDATE = V_CUR_DATE and od.feeacr=0
                    THEN ROUND(io.matchqtty * io.matchprice * odt.deffeerate / 100, 2)
                    ELSE ROUND(od.feeacr*io.matchqtty * io.matchprice / od.execamt , 2) END)
                END)
        end)  feeamt, od.txdate, od.codeid, od.afacctno, max(od.matchtype) matchtype
    from vw_odmast_all od , vw_iod_all io, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, odtype odt, afmast af
    where od.deltd <> 'Y'
        and od.execamt <> 0
        and od.actype = odt.actype
        and od.orderid = io.orgorderid
        and od.exectype =  'NB'
        AND AF.ACTYPE NOT IN ('0000')
        and io.custodycd = cf.custodycd
        and od.txdate = V_F_DATE
        and trim(cf.custodycd) = V_CUSTODYCD
        and od.afacctno like V_STRAFACCTNO
        and od.clearday = TO_NUMBER(DATE_T)
        AND od.AFACCTNO=af.acctno

        and io.symbol like V_STRSYMBOL
    group by cf.fullname, cf.custodycd, cf.address, io.symbol,od.txdate, od.codeid, od.afacctno, io.matchprice
        ;

EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
/
