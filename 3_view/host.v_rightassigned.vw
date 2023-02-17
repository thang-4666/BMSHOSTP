SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_RIGHTASSIGNED
(AUTHTYPEVL, AUTHTYPE, TLID, TLNAME, CMDCODE, 
 CMDNAME, CMDTYPE, RIGHTTYPE, CMDALLOW, MVIEW, 
 MADD, MEDIT, MDEL, MAPR, RPTPRT, 
 RPTADD, RPTAREA, RPTAREADESC, TELLERLIMIT, CASHIERLIMIT, 
 OFFICERLIMIT, CHECKERLIMIT)
BEQUEATH DEFINER
AS 
SELECT c.authtype authtypevl, a1.cdcontent authtype, c.tlid, c.tlname, c.cmdcode, c.cmdname, c.cmdtype, a2.cdcontent righttype,
    c.cmdallow, c.mview,c.madd,c.medit,c.mdel,c.mapr, c.rptprt,c.rptadd,c.rptarea,
    CASE WHEN c.rptarea IS NULL THEN '' ELSE a3.cdcontent END rptareadesc,
    c.tellerlimit, c.cashierlimit, c.Officerlimit, c.Checkerlimit
FROM allcode a1, allcode a2, allcode a3,
(
SELECT cmd.authtype, cmd.tlid, cmd.tlname, cmd.cmdcode, cmd.cmdname, cmd.cmdtype, cmd.cmdallow, substr(cmd.strauth,1,1) mview,
    substr(cmd.strauth,2,1) madd,substr(cmd.strauth,3,1) medit,substr(cmd.strauth,4,1) mdel,
    substr(cmd.strauth,5,1) mapr, '' rptprt,'' rptadd,'' rptarea,
    0 tellerlimit, 0 cashierlimit, 0 Officerlimit, 0 Checkerlimit
from
    (SELECT cma.authtype, tl.tlid, tl.tlname, cma.cmdcode, cm.modcode || ' - ' || cm.cmdname cmdname, cma.cmdtype, cma.cmdallow, CASE WHEN cm.last = 'Y' AND cm.menutype = 'M' then cma.strauth ELSE '' END strauth
    FROM tlprofiles tl, cmdauth cma, cmdmenu cm
    WHERE tl.tlid = cma.AUTHID AND cma.cmdcode = cm.cmdid
        AND cma.authtype = 'U' AND cma.cmdtype = 'M' AND cm.menutype <> 'P') cmd

UNION ALL
-- Bao cao
SELECT cma.authtype, tl.tlid, tl.tlname, cma.cmdcode, rpt.description cmdname, cma.cmdtype, cma.cmdallow, '' mview,
    '' madd,'' medit,'' mdel,'' mapr, substr(cma.strauth,1,1) rptprt,substr(cma.strauth,2,1) rptadd,substr(cma.strauth,3,1) rptarea,
    0 tellerlimit, 0 cashierlimit, 0 Officerlimit, 0 Checkerlimit
FROM tlprofiles tl, cmdauth cma, rptmaster rpt
WHERE tl.tlid = cma.AUTHID AND cma.cmdcode = rpt.rptid
    AND cma.authtype = 'U' AND cma.cmdtype = 'R'

UNION ALL
-- GD
SELECT cma.authtype, tl.tlid, tl.tlname, cma.cmdcode, tx.txdesc cmdname, cma.cmdtype, cma.cmdallow, '' mview,
    '' madd,'' medit,'' mdel,'' mapr, '' rptprt,'' rptadd,'' rptarea,
    tla.tellerlimit, tla.cashierlimit, tla.Officerlimit, tla.Checkerlimit
FROM tlprofiles tl, cmdauth cma, tltx tx,
    (SELECT tla.AUTHID, tla.tltxcd, sum(decode(tla.tltype,'T',tla.tllimit,0)) tellerlimit,
        sum(decode(tla.tltype,'C',tla.tllimit,0)) cashierlimit,
        sum(decode(tla.tltype,'A',tla.tllimit,0)) Officerlimit,
        sum(decode(tla.tltype,'R',tla.tllimit,0)) Checkerlimit
    FROM tlauth tla
    WHERE tla.authtype = 'U'
    GROUP BY tla.AUTHID, tla.tltxcd) tla
WHERE tl.tlid = cma.AUTHID AND cma.cmdcode = tx.tltxcd
    AND cma.authtype = 'U' AND cma.cmdtype = 'T'
    AND tl.tlid = tla.AUTHID AND cma.cmdcode = tla.tltxcd

-- quyen nhom
UNION all
SELECT cmd.authtype, cmd.tlid, cmd.tlname, cmd.cmdcode, cmd.cmdname, cmd.cmdtype, cmd.cmdallow, substr(cmd.strauth,1,1) mview,
    substr(cmd.strauth,2,1) madd,substr(cmd.strauth,3,1) medit,substr(cmd.strauth,4,1) mdel,
    substr(cmd.strauth,5,1) mapr, '' rptprt,'' rptadd,'' rptarea,
    0 tellerlimit, 0 cashierlimit, 0 Officerlimit, 0 Checkerlimit
from
    (SELECT cma.authtype, tl.grpid tlid, tl.grpname tlname, cma.cmdcode, cm.modcode || ' - ' || cm.cmdname cmdname, cma.cmdtype, cma.cmdallow, CASE WHEN cm.last = 'Y' AND cm.menutype = 'M' then cma.strauth ELSE '' END strauth
    FROM tlgroups tl, cmdauth cma, cmdmenu cm
    WHERE tl.grpid = cma.AUTHID AND cma.cmdcode = cm.cmdid
        AND cma.authtype = 'G' AND cma.cmdtype = 'M' AND cm.menutype <> 'P') cmd

UNION ALL
-- Bao cao
SELECT cma.authtype, tl.grpid tlid, tl.grpname tlname, cma.cmdcode, rpt.description cmdname, cma.cmdtype, cma.cmdallow, '' mview,
    '' madd,'' medit,'' mdel,'' mapr, substr(cma.strauth,1,1) rptprt,substr(cma.strauth,2,1) rptadd,substr(cma.strauth,3,1) rptarea,
    0 tellerlimit, 0 cashierlimit, 0 Officerlimit, 0 Checkerlimit
FROM tlgroups tl, cmdauth cma, rptmaster rpt
WHERE tl.grpid = cma.AUTHID AND cma.cmdcode = rpt.rptid
    AND cma.authtype = 'G' AND cma.cmdtype = 'R'

UNION ALL
-- GD
SELECT cma.authtype, tl.grpid tlid, tl.grpname tlname, cma.cmdcode, tx.txdesc cmdname, cma.cmdtype, cma.cmdallow, '' mview,
    '' madd,'' medit,'' mdel,'' mapr, '' rptprt,'' rptadd,'' rptarea,
    tla.tellerlimit, tla.cashierlimit, tla.Officerlimit, tla.Checkerlimit
FROM tlgroups tl, cmdauth cma, tltx tx,
    (SELECT tla.AUTHID, tla.tltxcd, sum(decode(tla.tltype,'T',tla.tllimit,0)) tellerlimit,
        sum(decode(tla.tltype,'C',tla.tllimit,0)) cashierlimit,
        sum(decode(tla.tltype,'A',tla.tllimit,0)) Officerlimit,
        sum(decode(tla.tltype,'R',tla.tllimit,0)) Checkerlimit
    FROM tlauth tla
    WHERE tla.authtype = 'G'
    GROUP BY tla.AUTHID, tla.tltxcd) tla
WHERE tl.grpid = cma.AUTHID AND cma.cmdcode = tx.tltxcd
    AND cma.authtype = 'G' AND cma.cmdtype = 'T'
    AND tl.grpid = tla.AUTHID AND cma.cmdcode = tla.tltxcd
) c
WHERE a1.cdtype = 'SY' AND a1.cdname = 'TLTYPE' AND a1.cdval = c.authtype
    AND a2.cdtype = 'SY' AND a2.cdname = 'RIGHTTYPE' AND a2.cdval = c.cmdtype
    AND a3.cdtype = 'SY' AND a3.cdname = 'AREA' AND a3.cdval = case when c.rptarea IS NULL THEN 'A' ELSE c.rptarea end
/
