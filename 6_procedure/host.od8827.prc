SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od8827 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   CUSTODYCD                IN       VARCHAR2,
   PV_RENAME                IN       VARCHAR2,
   PV_REGNAME               IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_CUSTODYCD       VARCHAR2 (20);
   v_STRRENAME       varchar2(50);
   v_STRREGNAME      varchar2(50);
   --V_TRADELOG CHAR(2);
   --V_AUTOID NUMBER;
   V_CUR_DATE DATE ;
   v_FROMDATE   DATE;
   v_TODATE     date;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   if (upper(CUSTODYCD) = 'ALL' or CUSTODYCD is null) then
        V_CUSTODYCD := '%';
   else
        V_CUSTODYCD := upper(CUSTODYCD);
   end if;


   if (upper(PV_RENAME) = 'ALL' or PV_RENAME is null) then
        v_STRRENAME := '%';
   else
        v_STRRENAME := PV_RENAME;
   end if;

   if (upper(PV_REGNAME) = 'ALL' or PV_REGNAME is null) then
        v_STRREGNAME := '%';
   else
        v_STRREGNAME := PV_REGNAME;
   end if;

    -- GET REPORT'S PARAMETERS
   SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';
   v_FROMDATE := to_date(F_DATE,'dd/mm/rrrr');
   v_TODATE  :=  to_date(T_DATE,'dd/mm/rrrr');
   -- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
    SELECT cf.fullname, cf.custodycd, mst.voucheramt, mst.prinpaid, mst.valdate, mst.expdate,
        RE.REMNAME, RE.REGNAME,
        tlp1.tlname maker, tlp2.tlname offer, mst.ciamt VOUCHERname
    FROM VOUCHERODFEE mst, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
        vw_tllog_all tl, tlprofiles tlp1, tlprofiles tlp2,
        (select re.afacctno, re.reacctno, cf.custid recustid ,  CF.fullname REMNAME, reg.fullname REGNAME, reg.refrecflnkid
        from reaflnk RE, RETYPE ret, CFMAST CF, REMAST RM, (
        SELECT reg.refrecflnkid, reg.reacctno , REGRP.fullname
        FROM REGRPLNK reg , REGRP
        where reg.status = 'A' and reg.deltd = 'N'
            ---and V_CUR_DATE BETWEEN reg.frdate and nvl(REG.clstxdate-1, REG.todate)
            AND REG.refrecflnkid = REGRP.autoid
        ) reg
        WHERE RE.reacctno = RM.acctno and rm.actype = RET.ACTYPE
            AND REROLE in ('RM','CS') and re.status ='A' and re.deltd = 'N'
            ---and V_CUR_DATE BETWEEN re.frdate AND nvl(RE.clstxdate-1, RE.todate)
            AND CF.custid = RM.custid and re.reacctno = reg.reacctno(+)
        ) re
    WHERE mst.custid = cf.custid
        and mst.txnum = tl.txnum and mst.txdate = tl.txdate
        and tl.tlid = tlp1.tlid and tl.offid = tlp2.tlid(+)
        AND MST.custid = RE.afacctno(+)
        and mst.txdate >= v_FROMDATE and mst.txdate <= v_TODATE
        and cf.custodycd like V_CUSTODYCD and mst.vouchertype = '01'
        and nvl(re.recustid,'xxx') like v_STRRENAME
        and nvl(re.refrecflnkid,'999999') like v_STRREGNAME
    order by mst.autoid;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE

 
 
 
 
/
