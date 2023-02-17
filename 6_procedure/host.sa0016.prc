SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sa0016 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TLID           IN       VARCHAR2
 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (10);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (10);        -- USED WHEN V_NUMOPTION > 0
   V_STRTLID              VARCHAR2 (10);

   v_fromdate       date;
   v_todate         date;
BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF(TLID <> 'ALL')
   THEN
        V_STRTLID  := TLID;
   ELSE
        V_STRTLID  := '%%';
   END IF;

    v_fromdate := to_date(F_DATE,'dd/mm/rrrr');
    v_todate := to_date(T_DATE,'dd/mm/rrrr');

OPEN PV_REFCURSOR
  FOR

    select lg.begindate, lg.begintime, lg.enddate, lg.tlid, lg.rptid, lg.afacctno, nvl(cf.custodycd,' ') custodycd,
        lg.custid, lg.functionname, lg.tlname,lg.brid, lg.brname, nvl(cf.fullname,' ') fullname, nvl(cf.cfbrname,' ') cfbrname
    from
    (
    ---tra cuu tong hop.
    SELECT to_date(slog.begindate,'dd/mm/rrrr') begindate,
     to_char(slog.begindate,'HH24:MI:SS') begintime,
        to_date(slog.enddate,'dd/mm/rrrr') enddate,
        slog.tlid, slog.rptid, nvl(slog.afacctno,'x') afacctno, nvl(slog.custodycd,'x')  custodycd,
        nvl(slog.custid,'x') custid, cmd.cmdname functionname, tlp.tlname, tlp.brid, brg.description brname
    FROM searchlog slog, cmdmenu cmd, tlprofiles tlp, brgrp brg
    where slog.rptid in ('CFMAST','CFBRKINQ','MR9004')
        and nvl(slog.cmdmenuid,'x') = cmd.cmdid
        and slog.tlid = tlp.tlid and tlp.brid = brg.brid
        and to_date(slog.begindate,'dd/mm/rrrr') >= v_fromdate
        and to_date(slog.begindate,'dd/mm/rrrr') <= v_todate
        and slog.tlid like V_STRTLID
    union all
    --- bao cao.
    SELECT to_date(rlog.begindate,'dd/mm/rrrr') begindate,
     to_char(rlog.begindate,'HH24:MI:SS') begintime,
        to_date(rlog.enddate,'dd/mm/rrrr') enddate,
        rlog.tlid, rlog.rptid, nvl(rlog.acctno,'x') afacctno, nvl(rlog.custodycd,'x')  custodycd,
        nvl(rlog.custid,'x') custid , rpt.description functionname, tlp.tlname, tlp.brid, brg.description brname
    FROM reportlog rlog, tlprofiles tlp, brgrp brg, rptmaster rpt
    where rlog.tlid = tlp.tlid and tlp.brid = brg.brid
        and rpt.cmdtype = 'R' and rlog.rptid = rpt.rptid
        and rlog.rptid in ('CF0008','CF0013','CF1001','CF1007',
        'CF1009','CF1019','CF1020','CF2000','SE0008','SE0024',
        'SE1028','SE2006','SE1000','OD0001','OD0002','OD0004',
        'OD0005','OD0014','OD0040','OD0041','OD0049','OD0049_1',
        'OD0054','OD0056','OD0065','OD0066','OD0072','OD2006',
        'FO0010','FO0040','FO0049','FO0072','FO9001','FO9005',
        'MR0012','MR3007','MR3017')
        and to_date(rlog.begindate,'dd/mm/rrrr') >= v_fromdate
        and to_date(rlog.begindate,'dd/mm/rrrr') <= v_todate
        and rlog.tlid like V_STRTLID
    ) lg left join
    (
        select cf.custodycd, cf.custid, /*af.acctno,*/ cf.fullname, brg.description cfbrname
        from cfmast cf, /*afmast af,*/ brgrp brg
        where /*cf.custid = af.custid and*/ cf.brid = brg.brid
    ) cf
    on lg.custid = cf.custid or lg.custodycd = cf.custodycd /*or lg.afacctno = cf.acctno*/
;


 EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
