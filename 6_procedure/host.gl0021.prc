SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GL0021" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TYPE_DATE      IN       VARCHAR2,
   TLID           IN       VARCHAR2,
   TLTXCD         IN       VARCHAR2
 )
IS
-- BAO CAO DANH SACH GIAO DICH GL
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   03-MAY-08  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);          -- USED WHEN V_NUMOPTION > 0
   V_STRTLID          VARCHAR2 (6);
   V_STRTYPEBA        VARCHAR2 (10);
   V_STRTLTXCD        VARCHAR2(100);
   V_DMAX             DATE;
   V_DMIN             DATE;


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS


   IF (TLTXCD <> 'ALL') THEN
        V_STRTLTXCD := TLTXCD ;
   ELSE
         V_STRTLTXCD := '9999 9900 9902';
   END IF;

  IF  (TLID <> 'ALL')
   THEN
      V_STRTLID := TLID;
   ELSE
      V_STRTLID := '%%';
   END IF;
   -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA

IF UPPER(TYPE_DATE) <> 'ALL'THEN

 OPEN PV_REFCURSOR
       FOR

SELECT tl.tltxcd , tl.txdate,tl.busdate ,tlpr.TLNAME TLID,tlpr1.TLNAME OFFID ,tlpr2.TLNAME CHKID ,tl.txnum ,gl.subtxno ,tl.txdesc,mi.custid ,cf.idcode ,
(CASE WHEN GL.dorc ='D' THEN gl.acctno else '' end ) acctno_dr ,(CASE WHEN GL.dorc ='C' THEN gl.acctno else '' end )acctno_cr
, gl.amt  , mi.taskcd , mi.deptcd ,mi.micd ,gl.dorc , TL.deltd, ( case when gl.dorc = 'D' then 1 else 2 end) drcr
FROM gltran gl ,tllog tl , mitran mi,tlprofiles tlpr , cfmast cf,tlprofiles tlpr1,tlprofiles tlpr2
WHERE gl.txdate =tl.txdate and gl.txnum =tl.txnum and tl.tlid  =tlpr.tlid
and gl.txdate = mi.txdate(+) and gl.txnum =mi.txnum (+)and gl.acctno = mi.acctno (+)
and gl.dorc =mi.dorc (+) and gl.subtxno =mi.subtxno (+)
and mi.custid = cf.custid (+)and tl.OFFID  =tlpr1.tlid (+) and  tl.CHKID  = tlpr2.tlid (+)
and (case when TYPE_DATE = '001' then  TL.txdate  when TYPE_DATE = '002' then tl.busdate else TL.txdate end) <= to_date (T_DATE,'DD/MM/YYYY')
and (case when TYPE_DATE = '001' then  TL.txdate  when TYPE_DATE = '002' then tl.busdate else TL.busdate end) >= to_date (F_DATE,'DD/MM/YYYY')
AND INSTR(V_STRTLTXCD, TL.TLTXCD)>0
and substr(TL.txnum,1,4) like V_STRBRID
and tlpr.tlid like V_STRTLID
union all
SELECT tl.tltxcd , tl.txdate,tl.busdate ,tlpr.TLNAME TLID,tlpr1.TLNAME OFFID ,tlpr2.TLNAME CHKID ,tl.txnum ,gl.subtxno ,tl.txdesc,mi.custid ,cf.idcode ,
(CASE WHEN GL.dorc ='D' THEN gl.acctno else '' end ) acctno_dr ,
(CASE WHEN GL.dorc ='C' THEN gl.acctno else '' end )acctno_cr
, gl.amt  , mi.taskcd , mi.deptcd ,mi.micd ,gl.dorc , TL.deltd, ( case when gl.dorc = 'D' then 1 else 2 end) drcr
FROM gltrana gl ,tllogall tl , mitran mi,tlprofiles tlpr , cfmast cf,tlprofiles tlpr1,tlprofiles tlpr2
WHERE gl.txdate =tl.txdate and gl.txnum =tl.txnum and tl.tlid  =tlpr.tlid
and gl.txdate = mi.txdate(+) and gl.txnum =mi.txnum (+)and gl.acctno = mi.acctno (+)
and gl.dorc =mi.dorc (+) and gl.subtxno =mi.subtxno (+)
and mi.custid = cf.custid (+)and tl.OFFID  =tlpr1.tlid (+) and  tl.CHKID  = tlpr2.tlid (+)
and (case when TYPE_DATE = '001' then  TL.txdate  when TYPE_DATE = '002' then tl.busdate end) <= to_date (T_DATE,'DD/MM/YYYY')
and (case when TYPE_DATE = '001' then  TL.txdate  when TYPE_DATE = '002' then tl.busdate end) >= to_date (F_DATE,'DD/MM/YYYY')
AND INSTR(V_STRTLTXCD, TL.TLTXCD)>0
and substr(TL.txnum,1,4) like V_STRBRID
and tlpr.tlid like V_STRTLID
Order by tltxcd , txdate , TLID ,txnum,subtxno  , drcr   ;

ELSE

 OPEN PV_REFCURSOR
       FOR

SELECT tl.tltxcd , tl.txdate,tl.busdate ,tlpr.TLNAME TLID,tlpr1.TLNAME OFFID ,tlpr2.TLNAME CHKID ,tl.txnum ,gl.subtxno ,tl.txdesc,mi.custid ,cf.idcode ,
(CASE WHEN GL.dorc ='D' THEN gl.acctno else '' end ) acctno_dr ,(CASE WHEN GL.dorc ='C' THEN gl.acctno else '' end )acctno_cr
, gl.amt  , mi.taskcd , mi.deptcd ,mi.micd ,gl.dorc , TL.deltd, ( case when gl.dorc = 'D' then 1 else 2 end) drcr
FROM gltran gl ,tllog tl , mitran mi,tlprofiles tlpr , cfmast cf,tlprofiles tlpr1,tlprofiles tlpr2
WHERE gl.txdate =tl.txdate and gl.txnum =tl.txnum and tl.tlid  =tlpr.tlid
and gl.txdate = mi.txdate(+) and gl.txnum =mi.txnum (+)and gl.acctno = mi.acctno (+)
and gl.dorc =mi.dorc (+) and gl.subtxno =mi.subtxno (+)
and mi.custid = cf.custid (+)and tl.OFFID  =tlpr1.tlid (+) and  tl.CHKID  = tlpr2.tlid (+)
and  (TL.txdate  <= to_date (T_DATE,'DD/MM/YYYY') or TL.busdate  <= to_date (T_DATE,'DD/MM/YYYY'))
and  (TL.txdate  >= to_date (F_DATE,'DD/MM/YYYY') or TL.busdate  >= to_date (F_DATE,'DD/MM/YYYY'))
and (case when TYPE_DATE = '001' then  TL.txdate  when TYPE_DATE = '002' then tl.busdate else TL.busdate end) >= to_date (F_DATE,'DD/MM/YYYY')
AND INSTR(V_STRTLTXCD, TL.TLTXCD)>0
and substr(TL.txnum,1,4) like V_STRBRID
and tlpr.tlid like V_STRTLID
union all
SELECT tl.tltxcd , tl.txdate,tl.busdate ,tlpr.TLNAME TLID,tlpr1.TLNAME OFFID ,tlpr2.TLNAME CHKID ,tl.txnum ,gl.subtxno ,tl.txdesc,mi.custid ,cf.idcode ,
(CASE WHEN GL.dorc ='D' THEN gl.acctno else '' end ) acctno_dr ,
(CASE WHEN GL.dorc ='C' THEN gl.acctno else '' end )acctno_cr
, gl.amt  , mi.taskcd , mi.deptcd ,mi.micd ,gl.dorc , TL.deltd, ( case when gl.dorc = 'D' then 1 else 2 end) drcr
FROM gltrana gl ,tllogall tl , mitran mi,tlprofiles tlpr , cfmast cf,tlprofiles tlpr1,tlprofiles tlpr2
WHERE gl.txdate =tl.txdate and gl.txnum =tl.txnum and tl.tlid  =tlpr.tlid
and gl.txdate = mi.txdate(+) and gl.txnum =mi.txnum (+)and gl.acctno = mi.acctno (+)
and gl.dorc =mi.dorc (+) and gl.subtxno =mi.subtxno (+)
and mi.custid = cf.custid (+)and tl.OFFID  =tlpr1.tlid (+) and  tl.CHKID  = tlpr2.tlid (+)
and  (TL.txdate  <= to_date (T_DATE,'DD/MM/YYYY') or TL.busdate  <= to_date (T_DATE,'DD/MM/YYYY'))
and  (TL.txdate  >= to_date (F_DATE,'DD/MM/YYYY') or TL.busdate  >= to_date (F_DATE,'DD/MM/YYYY'))
AND INSTR(V_STRTLTXCD, TL.TLTXCD)>0
and substr(TL.txnum,1,4) like V_STRBRID
and tlpr.tlid like V_STRTLID
Order by tltxcd , txdate , TLID ,txnum,subtxno  , drcr   ;




END if ;




 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
