SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE gl0002 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   PV_TLTXCD                IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_GLACCTNO              IN       VARCHAR2,
   PV_CFBRID                  IN       VARCHAR2
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

   V_TLTXCD VARCHAR2(10);
   V_CUSTODYCD VARCHAR2(20);
   V_GLACCTNO VARCHAR2(20);
   V_BRID VARCHAR2(20);

BEGIN
    -- GET REPORT'S PARAMETERS
    IF (PV_TLTXCD <> 'ALL' ) THEN
       V_TLTXCD := PV_TLTXCD;
    ELSE
       V_TLTXCD  := '%';
    END IF;

 IF (PV_CUSTODYCD <> 'ALL' ) THEN
       V_CUSTODYCD := PV_CUSTODYCD;
    ELSE
       V_CUSTODYCD  := '%';
    END IF;

     IF (PV_GLACCTNO <> 'ALL' ) THEN
       V_GLACCTNO := PV_GLACCTNO;
    ELSE
       V_GLACCTNO  := '%';
    END IF;

     IF (PV_CFBRID <> 'ALL' ) THEN
       V_BRID := PV_CFBRID;
    ELSE
       V_BRID  := '%';
    END IF;


OPEN PV_REFCURSOR
FOR
SELECT gl.REF,gl.TXDATE,gl.TXNUM,gl.BUSDATE,gl.CUSTID,gl.AFACCTNO,gl.CUSTODYCD,gl.TLTXCD,gl.POSTING_CODE,nvl(gl.BANKID,'') BANKID
 ,gl.BRID,gl.GLGRP,round(nvl(gl.AMOUNT,0),4) AMOUNT,gl.BRDEBITACCT
,gl.BRCREDITACCT,gl.BRNOTES,gl.GRPTYPE,gl.HODEBITACCT,gl.HOCREDITACCT,gl.HONOTES,gl.HOGRPTYPE,gl.REFCUSTOMER,gl.DELTD
,gl.CREATEDT,gl.SYMBOL, gl.BRIDGL, gl.CFBRID,
cf.fullname
FROM gljournal gl , cfmast cf
WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
and gl.custid = cf.custid
AND TLTXCD LIKE V_TLTXCD
AND gl.BRID LIKE V_BRID
AND cf.CUSTODYCD LIKE V_CUSTODYCD
AND  INSTR( brdebitacct ||brcreditacct||hodebitacct||hocreditacct, CASE WHEN PV_GLACCTNO='ALL' THEN brdebitacct ELSE PV_GLACCTNO END   )>0
ORDER BY GL.TXDATE,GL.TXNUM
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
