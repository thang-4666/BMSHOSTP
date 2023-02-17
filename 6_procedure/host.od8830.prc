SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od8830 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION          VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);

   V_CURRDATE       DATE;
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_STRCUSTODYCD   VARCHAR2(20);
   V_STRAFACCTNO    VARCHAR2(20);

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

    V_STRCUSTODYCD := upper(PV_CUSTODYCD);
    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';
    V_FROMDATE  := TO_DATE(F_DATE,'DD/MM/RRRR');
    V_TODATE   := TO_DATE(T_DATE,'DD/MM/RRRR');

    IF UPPER(PV_AFACCTNO) = 'ALL' OR PV_AFACCTNO IS NULL THEN
        V_STRAFACCTNO := '%';
    ELSE
        V_STRAFACCTNO := PV_AFACCTNO;
    END IF;
   --- TINH GT KHOP MG



OPEN PV_REFCURSOR FOR
     select custodycd, fullname, acctno, namt, txdate, txnum,
        voucherid, txdesc, voucheramt, tltxcd, aftypename, PV_AFACCTNO PVAFACCTNO
    from
    (
        select cf.custodycd, cf.fullname, tr.acctno,  tr.namt, odt.txdate, odt.txnum,
            odt.acctno voucherid, tr.txdesc, vc.voucheramt, tr.tltxcd, a1.cdcontent aftypename
        from vw_citran_gen tr, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, voucherodfee vc,
            (select * from odtran where deltd <> 'Y' union all select * from odtrana where deltd <> 'Y') odt,
            afmast af, aftype aft, allcode a1
        where tr.tltxcd = '8831' and tr.field = 'BALANCE'
            and tr.custid = cf.custid and tr.txnum = odt.txnum and tr.txdate = odt.txdate
            and odt.acctno = vc.autoid and vc.vouchertype = '01'
            and tr.acctno = af.acctno and af.actype = aft.actype
            and a1.CDNAME = 'PRODUCTTYPE' and a1.cdtype = 'CF' and aft.producttype = a1.cdval
            and cf.custodycd = V_STRCUSTODYCD
            and tr.txdate >= V_FROMDATE and tr.txdate <= V_TODATE
            and tr.acctno like V_STRAFACCTNO
        union all
        select cf.custodycd, cf.fullname, cf.custodycd acctno,  odt.namt, odt.txdate, odt.txnum,
            odt.acctno voucherid, 'Tat toan voucher' txdesc, vc.voucheramt, odt.tltxcd, cf.custodycd aftypename
        from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, voucherodfee vc,
            (select * from odtran where deltd <> 'Y' and txdate >= V_FROMDATE and txdate <= V_TODATE
            union all select * from odtrana where deltd <> 'Y' and txdate >= V_FROMDATE and txdate <= V_TODATE
            ) odt
        where odt.tltxcd = '8832' and odt.txcd = '0045'
            and odt.acctno = vc.autoid and vc.vouchertype = '01'
            and cf.custodycd = V_STRCUSTODYCD
            and vc.custid = cf.custid
    )
    order by voucherid, txdate, txnum asc
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
