SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_RE01
(THANG, IDCODE, FULLNAME, DOANHTHU, HOAHONG, 
 LUONGCOBAN, LOAI, BRID)
BEQUEATH DEFINER
AS 
SELECT a.commdate  THANG,CF.IDCODE , cf.fullname,round(SUM(a.revenue)) DOANHTHU,round(SUM(a.commision)) HOAHONG, ROUND( SUM(A.SALARY))
 LUONGCOBAN,a1.cdcontent  LOAI, substr(cf.custid,1,4) BRID

/* a.retype,a1.cdcontent DESC_RETYPE,  a.custid, cf.fullname, 
      A.mindrevamt,
       a.minirevamt, a.minincome, a.minratesal, a.saltype,
        a.directacr, a.directfeeacr,
       a.indirectacr, a.indirectfeeacr,
         a.revenue, a.commision, a.autoid, A.SALARY,
        a.commision + A.SALARY totalsal,
        a.tax, a.isdg*/
  FROM resalary a, cfmast cf , allcode a1, recflnk rf
  where a.custid=cf.custid
  and a1.cdtype='RE' and a1.cdname='RETYPE'
  and a.retype=a1.cdval
  and a.custid=rf.custid 
  GROUP BY a.commdate,CF.IDCODE,a1.cdcontent,cf.fullname, substr(cf.custid,1,4)
/
