SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_ACCOUNT_ADVT0
(TLID, TLNAME, CUSTODYCD, ACCTNO, FULLNAME, 
 ACCLIMIT, USRLIMIT, ADVANCELINE, T0AMT, T0ACCUSER, 
 ADVT0AMT, ADVAMTHIST, ACCUSERHIST)
BEQUEATH DEFINER
AS 
SELECT   tl.tlid,         tl.tlname,
         cf.custodycd,
         af.acctno,
         cf.fullname,
         u.acclimit,
         ul.t0 usrlimit,
         af.advanceline,
         af.t0amt,
         NVL (t0accuser, 0) t0accuser,
         NVL (
             ROUND (
                 GREATEST (least(af.advanceline, ROUND (fn_get_account_pp (u.acctno, 'U')/*+ ci.depofeeamt*/),NVL (t0s.t0accuser, 0) ),
                     0),
                 0),
             0)
             advt0amt,
         GREATEST (
             LEAST (ROUND (af.t0amt),
                    ROUND (u.acclimit - NVL (t0accuser, 0))),
             0)
             advamthist,                             -- BL USER CO THE THU HOI
         ROUND (u.acclimit - t0accuser) accuserhist -- BL USER CAP NGAY QUA KHU
  FROM   useraflimit u,
         afmast af,cimast ci,
         cfmast cf,
         tlprofiles tl,
         userlimit ul,
         aftype aft,
         mrtype mrt,
         (  SELECT   tlid,
                     acctno,
                     SUM (s.allocatedlimit - s.retrievedlimit) t0accuser
              FROM   t0limitschd s
          GROUP BY   tlid, acctno) t0s,
         v_getbuyorderinfo bor
 WHERE       af.custid = cf.custid and af.acctno = ci.acctno
         AND u.typereceive = 'T0'
         AND af.acctno = u.acctno
         AND tl.tlid = u.tliduser
         AND u.tliduser = ul.tliduser
         AND u.tliduser = t0s.tlid(+)
         AND u.acctno = t0s.acctno(+)
         AND aft.actype = af.actype
         AND mrt.actype = aft.mrtype(+)
         AND af.acctno = bor.afacctno(+)
/
