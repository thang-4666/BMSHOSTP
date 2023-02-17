SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CF1046 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   PV_FRDATE            IN       VARCHAR2,
                                   PV_TODATE            IN       VARCHAR2
                                   )
IS
--
-- BAO CAO DANH SACH KHACH HANG CHUYEN DIA BAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT   19-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
BEGIN
   V_STROPTION := OPT;
   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
    OPEN PV_REFCURSOR
    FOR
        SELECT tl.busdate, cf.fullname, cf.idcode, cf.address, cf.mobile,
            A1.cdcontent oldstatus, A2.cdcontent newstatus, af.trdesc note
            FROM vw_tllog_all tl, cfmasttemp cf, allcode A1, allcode A2,(select * from aftran union all select * from  aftrana) af
            WHERE tl.tltxcd = '0036'
            AND tl.msgacct = cf.idcode
            AND tl.txstatus = '1'
            AND af.ref = A1.cdval
            AND A1.cdtype = 'CF'
            AND A1.cdname = 'STSCFTMP'
            AND af.acctref = A2.cdval
            AND A2.cdtype = 'CF'
            AND A2.cdname = 'STSCFTMP'
            and af.txnum =tl.txnum
            and af.txdate =  tl.txdate
            and af.tltxcd = '0036'
            AND tl.busdate <= to_date(PV_TODATE, 'DD/MM/RRRR')
            AND tl.busdate >= to_date(PV_FRDATE, 'DD/MM/RRRR')
		order by tl.busdate, cf.idcode,tl.TXNUM;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
