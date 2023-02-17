SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1035 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   CFRVID                   IN       VARCHAR2,
   pv_CUSTODYCD             IN       VARCHAR2,
   CFTYPE                   IN       VARCHAR2,
   pr_brid                  IN       VARCHAR2,
   CFTYPENEW                IN       VARCHAR2
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

   V_CFRVID  varchar2(30);
   V_CUSTODYCD VARCHAR2(20);
   V_CFTYPE VARCHAR2(20);
   V_CFTYPENEW VARCHAR2(20);
BEGIN
    -- GET REPORT'S PARAMETERS
    IF (CFRVID <> 'ALL' ) THEN
       V_CFRVID := CFRVID;
    ELSE
       V_CFRVID  := '%';
    END IF;

     IF (pv_CUSTODYCD <> 'ALL' ) THEN
       V_CUSTODYCD := pv_CUSTODYCD;
    ELSE
       V_CUSTODYCD  := '%';
    END IF;

     IF (CFTYPE <> 'ALL' ) THEN
       V_CFTYPE := CFTYPE;
    ELSE
       V_CFTYPE  := '%';
    END IF;

    IF (CFTYPENEW <> 'ALL' ) THEN
       V_CFTYPENEW := CFTYPENEW;
    ELSE
       V_CFTYPENEW  := '%';
    END IF;

       IF (pr_brid <> 'ALL' ) THEN
       V_STRBRID := pr_brid;
    ELSE
       V_STRBRID  := '%';
    END IF;


OPEN PV_REFCURSOR
FOR
/*SELECT cfv.* FROM CFREVIEWRESULT cfv,
(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
  WHERE  cfrvid LIKE  V_CFRVID  AND cftypecurr LIKE V_CFTYPE AND cfv.custodycd LIKE V_CUSTODYCD
  AND cfv.custodycd = cf.custodycd
  ;*/

 SELECT cfv.AUTOID,cfv.CFRVID,cfv.CUSTODYCD,cfv.FULLNAME,cftcur.typename CFTYPECURR,cftnew.typename CFTYPENEW,cfv.ISPASS,substr(cfv.recust,1,10) RECUST,cfv.NAV,cfv.NAVCURR
,cfv.FEEAMT,cfv.ISKEEPCF,cfv.REASONKEEP,cfv.STATUS, cfr.frdate, cfr.todate, br.brname, nvl( cfre.fullname,'') refullname
FROM CFREVIEWRESULT cfv,cfreview cfr, brgrp br,cfmast cfre,cftype cftcur, cftype cftnew,
(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
  WHERE  cfrvid LIKE V_CFRVID  AND cftypecurr LIKE V_CFTYPE  AND cfv.custodycd LIKE V_CUSTODYCD
  AND cfv.cftypenew LIKE V_CFTYPENEW
  AND cfv.custodycd = cf.custodycd
  AND cfv.cfrvid = cfr.autoid
  AND cf.brid = br.brid
  AND cf.brid LIKE  V_STRBRID
  AND cfv.cftypecurr = cftcur.actype
  AND cfv.cftypenew = cftnew.actype
  AND substr(cfv.recust,1,10) = cfre.custid (+)
  ORDER BY cfv.CFRVID,cfv.CUSTODYCD
  ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
