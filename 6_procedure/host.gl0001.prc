SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE gl0001 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_TLTXCD         IN       VARCHAR2
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
    v_brid              VARCHAR2(4);
    V_TLTXCD            VARCHAR2(6);

BEGIN
    -- GET REPORT'S PARAMETERS


    IF (PV_TLTXCD <> 'ALL' ) THEN
       V_TLTXCD := PV_TLTXCD;
    ELSE
       V_TLTXCD  := '%';
    END IF;


OPEN PV_REFCURSOR
FOR


select tltx.tltxcd, tltx.txdesc, txru.posting_code , txru.amtexp,gl.brid,brdebitacct
,brcreditacct, nvl(b.fullname,gl.bankid) bankid,bridgl,al.cdcontent class,hodebitacct,hocreditacct,amtexpcaption
from txmapglrules txru, tltx, glrules gl,fldamtexp fld,banknostro b,allcode al
where txru.tltxcd = tltx.tltxcd
    and txru.posting_code = gl.posting_code
    and fld.objname ='SA.TXMAPGLRULES'
    and fld.fldname =tltx.tltxcd
    and txru.amtexp = fld.amtexp
    and gl.bankid = b.shortname(+)
    and al.cdname ='CLASS'
    and al.cdtype= 'CF'
    and al.cdval = gl.class
    AND tltx.tltxcd like V_TLTXCD;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
