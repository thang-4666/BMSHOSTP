SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0044 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   PV_ACTYPE                IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2
            )
IS
--
-- BAO CAO: TONG HOP TIEU KHOAN TIEN GUI CUA KHACH HANG
-- MODIFICATION HISTORY
-- PERSON           DATE                    COMMENTS
-- -----------      -----------------       ---------------------------
-- TUNH             15-05-2010              CREATED
-- THENN            14-06-2012              MODIFIED    THAY DOI CACH TINH SDDK
-----------------------------------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2  (16);

    v_FromDate     date;
    v_ToDate       date;

   V_ACTYPE VARCHAR2(10);
   V_CUSTODYCD VARCHAR2(20);
    V_BRID VARCHAR2(20);

BEGIN
    -- GET REPORT'S PARAMETERS
    IF (PV_ACTYPE <> 'ALL' ) THEN
       V_ACTYPE := PV_ACTYPE;
    ELSE
       V_ACTYPE  := '%';
    END IF;

 IF (PV_CUSTODYCD <> 'ALL' ) THEN
       V_CUSTODYCD := PV_CUSTODYCD;
    ELSE
       V_CUSTODYCD  := '%';
    END IF;




OPEN PV_REFCURSOR
FOR
SELECT cf.custodycd, cf.fullname, cfr.lastdate, ciamt+seamt nav, feeamt,  logdays , ciamt + odamt ciamt ,seamt, odamt, cf.actype,
re.fullname refullname
FROM cfreviewlog cfr, cfmast cf , cfmast re
WHERE cfr.custid = cf.custid
AND substr( cfr.recust,1,10) = re.custid(+)
AND cfr.lastdate BETWEEN TO_DATE( F_DATE,'DD/MM/YYYY') AND TO_DATE( T_DATE,'DD/MM/YYYY')
AND cf.actype LIKE V_ACTYPE
AND cf.custodycd LIKE V_CUSTODYCD
 ORDER BY lastdate DESC
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
