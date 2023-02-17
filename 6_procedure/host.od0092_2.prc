SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0092_2(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     I_DATE       IN VARCHAR2,
                                     PV_CUSTODYCD IN VARCHAR2,
                                     NOIIN        IN VARCHAR2) IS

  -- ---------   ------  -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_INBRID    VARCHAR2(4);

  V_STRCUSTODYCD VARCHAR2(20);
  V_STRNOIIN     VARCHAR2(40);
  V_CUR_DATE     DATE;
  v_taxrate      number;

BEGIN
  V_STROPTION := upper(OPT);
  V_INBRID    := pv_BRID;
  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSE
    if (V_STROPTION = 'B') then
      select brgrp.brid
        into V_STRBRID
        from brgrp
       where brgrp.brid = V_INBRID;
    else
      V_STRBRID := V_INBRID;
    end if;
  END IF;
  V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
  V_STRNOIIN     := UPPER(NOIIN);

  SELECT TO_DATE(VARVALUE, 'dd/mm/rrrr')
    INTO V_CUR_DATE
    FROM SYSVAR
   WHERE VARNAME = 'CURRDATE';
  select to_number(varvalue)
    into v_taxrate
    from sysvar
   where varname = 'ADVSELLDUTY';

  OPEN PV_REFCURSOR FOR select V_STRNOIIN    NOIIN, OD.custodycd,
           OD.fullname,
           OD.CUSTATCOM,
           OD.address,
           od.exectype,
           od.txdate,
           OD.cleardate,
           od.afacctno,

           OD.symbol,

           SUM(OD.matchqtty) matchqtty,
           OD.matchprice,
           '0'||trim(to_char(OD.TAX_RATE,'99,999.99'))||'%' TAX_RATE,
           '0'||trim(to_char(OD.FEE_RATE,'99,999.99'))||'%' FEE_RATE,
           SUM(od.feeamt) feeamt,
           od.taxsellamt
             from (
    SELECT
           cf.custodycd,
           cf.fullname,
           CF.CUSTATCOM,
           cf.address,
           od.exectype,
           od.txdate,
           sts.cleardate,
           od.afacctno,
           od.orderid,
           io.symbol,
           od.ORDERQTTY,
           od.QUOTEPRICE,
           io.matchqtty  matchqtty,
           io.matchprice matchprice,

           (case
             when OD.execamt > 0 and OD.feeacr = 0 AND
                  OD.TXDATE = V_CUR_DATE THEN
              ODT.deffeerate
             when OD.execamt > 0 and OD.feeacr = 0 AND
                  OD.TXDATE <> V_CUR_DATE THEN
              0
             else
              (CASE
                WHEN (OD.execamt * OD.feeacr) = 0 THEN
                 0
                ELSE
                 (CASE
                   WHEN OD.TXDATE = V_CUR_DATE THEN
                    round(100 * OD.feeacr / (OD.execamt), 2)
                   ELSE
                    ROUND((io.matchqtty * io.matchprice / OD.execamt * OD.feeacr) * 100 /
                          (IO.MATCHPRICE * IO.MATCHQTTY),
                          2)
                 END)
              END)
           end) FEE_RATE,
          /* v_taxrate+TO_NUMBER(MR1.varvalue)*/
                 (DECODE(CF.VAT, 'Y', TO_NUMBER(MR.varvalue), 'N', 0) +
                        DECODE(CF.WHTAX, 'Y', TO_NUMBER(MR1.varvalue), 'N', 0)) TAX_RATE,

           (CASE
             WHEN OD.execamt = 0 THEN
              0
             ELSE
              (CASE
                WHEN io.iodfeeacr = 0 and OD.Txdate = V_CUR_DATE THEN
                 ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                ELSE
                 io.iodfeeacr
              END)
           END) feeamt,

           (CASE
             WHEN od.EXECTYPE IN ('NS', 'SS', 'MS')  AND (CF.VAT = 'Y' or CF.WHTAX='Y') /*AND CF.VAT = 'Y'*/ THEN
              (CASE
                WHEN IO.iodtaxsellamt <> 0 THEN
                 IO.iodtaxsellamt
                ELSE
                 (ROUND((IO.MATCHQTTY * IO.MATCHPRICE *
                        (DECODE(CF.VAT, 'Y', TO_NUMBER(MR.varvalue), 'N', 0) +
                        DECODE(CF.WHTAX, 'Y', TO_NUMBER(MR1.varvalue), 'N', 0))) / 100,
                        0) + NVL(sts.ARIGHT, 0))
              END)
             ELSE
              0
           END) taxsellamt

      from vw_odmast_all od,
           vw_iod_all io,
           vw_stschd_all sts,
           (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           odtype odt,
           afmast af,
           sysvar MR,
           sysvar mr1
     where od.deltd <> 'Y'
       and od.execamt <> 0
       and od.actype = odt.actype
       and od.orderid = io.orgorderid
       and od.ORDERID = sts.ORGORDERID
       and od.exectype in ('NB', 'BC')
       AND AF.ACTYPE NOT IN ('0000')
       and io.custodycd = cf.custodycd
       and sts.DUETYPE = 'RS'
       AND od.AFACCTNO = af.acctno
       AND MR.varname = 'ADVSELLDUTY'
       AND MR1.varname = 'WHTAX'
       AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
       AND OD.TXDATE = TO_DATE(I_DATE, 'DD/MM/YYYY')

     ORDER BY OD.TXTIME ) OD
      group by OD.custodycd,
           OD.fullname,
           OD.CUSTATCOM,
           OD.address,
           od.exectype,
           od.txdate,
           OD.cleardate,
           od.afacctno,

           OD.symbol,
           OD.matchprice,
           od.FEE_RATE,
           od.TAX_RATE,
           od.taxsellamt

     ;

EXCEPTION
  WHEN OTHERS THEN

    RETURN;
End;
 
 
 
 
/
