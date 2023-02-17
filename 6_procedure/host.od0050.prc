SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0050" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   EXECTYPE       IN       VARCHAR2,
   CAREBY         IN       VARCHAR2,
   BROKER         IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- BAO CAO GDCK THEO TK KIEM CHI PHI MOI GIOI PS
-- PERSON   DATE  COMMENTS
-- PHUONGNN 22-APR-09  CREATED
-- ---------   ------  -------------------------------------------
-- huynh.nd    29-SEP-2010    Chinh sua dong 50 chd.txdate -> chd.cleardate
-- anh.pt      29-SEP-2010    change ID 44
-- quyet.kieu  25/03/2011     Them tham so nguoi dat lenh
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (4);

   V_EXECTYPE       VARCHAR2 (20);
   v_CurrDate       DATE;
   V_CAREBY         VARCHAR2 (20);
   V_STRBROKER      VARCHAR2 (20);
   V_CAREBY_name         VARCHAR2 (20);
   V_STRBROKER_name      VARCHAR2 (20);
   V_EXECTYPE_NAME   VARCHAR2 (20);

BEGIN
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
   IF (V_STROPTION =  'A') THEN
     V_STRBRID := '%' ;
  ELSE if (V_STROPTION =  'B') THEN
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;

   END IF;

     IF (CAREBY <> 'ALL')  THEN
     Select grpname into V_CAREBY_name from tlgroups where grptype='2' and grpid =CAREBY;
     V_CAREBY := CAREBY;
  ELSE

      V_CAREBY := '%%';
      V_CAREBY_name:='%%';

   END IF;

        IF (BROKER <> 'ALL')

  THEN
  Select tlname  into V_STRBROKER_name from tlprofiles  where tlid=BROKER ;
     V_STRBROKER := BROKER;
  ELSE
      V_STRBROKER := '%%';
      V_STRBROKER_name:='%%';
  END IF;

   IF ( EXECTYPE   <> 'ALL')   THEN
       Select cdcontent into V_EXECTYPE_NAME from ALLCODE where cdname='EXECTYPE' and cdtype ='OD' and  cdval=EXECTYPE ;
     V_EXECTYPE :=  EXECTYPE  ;
   ELSE
     V_EXECTYPE := '%%';
     V_EXECTYPE_NAME :='%%';
   END IF;

    select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate  from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

 OPEN PV_REFCURSOR
      FOR
        select od.afacctno acctno, od.txdate busdate, iod.symbol, od.exectype,
               iod.matchqtty, iod.matchprice, od.txdesc,
               case when od.txdate = v_CurrDate
               then round(iod.matchqtty * iod.matchprice * odtype.deffeerate/100)
                    else
                    round(iod.matchqtty * iod.matchprice/od.execamt * od.feeacr) end feeamt_detail,
            chd.cleardate tratedate,
        --(CASE WHEN od.EXECTYPE IN('NS','SS','MS') AND aft.vat IN ('Y')  THEN (select to_number(varvalue) from sysvar where varname = 'ADVSELLDUTY' and grname = 'SYSTEM')
        --ELSE 0 END ) icrate ,
        CASE WHEN od.exectype IN ('NS','SS','MS') THEN od.taxrate ELSE 0 END icrate,
            a.cdcontent execname,od.tlfullname,cf.refname,cf.fullname,cf. custodycd,od.orderid ,
           V_CAREBY_name V_CAREBY , V_STRBROKER_name V_STRBROKER, V_EXECTYPE_NAME V_EXECTYPE , cf.careby
from odtype, allcode a,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, aftype aft,
(
    select orgorderid, codeid,symbol, bors, matchprice,sum(matchqtty) matchqtty from
    (
        select orgorderid, codeid,symbol, bors, matchprice, matchqtty
        from iodhist
        where deltd <> 'Y'
        union all
        select orgorderid, codeid,symbol, bors, matchprice,matchqtty
        from iod
        where deltd <> 'Y'
    ) i
    group by orgorderid, codeid,symbol, bors, matchprice
) iod,
(
   SELECT a.* , tlfs.tlfullname FROM
   (
    select actype,od.orderid, od.afacctno, od.txnum, od.txdate, od.execamt, od.feeacr,
     od.execqtty, tl.txdesc,od.exectype,OD.tlid, od.taxrate
    from tllogall tl,
    (
        -- tllogall
        select actype,orderid, afacctno, txnum, txdate, matchamt,execamt, feeacr, execqtty,exectype, tlid, taxrate
        from odmasthist
        where deltd <> 'Y'
        union all
        select actype,orderid, afacctno, txnum, txdate, matchamt,execamt, feeacr, execqtty,exectype, tlid, taxrate
        from odmast
        where deltd <> 'Y' and txdate <> v_CurrDate
    ) od
    where tl.txdate(+) = od.txdate and tl.txnum(+) = od.txnum) a
    LEFT JOIN tlprofiles tlfs
    ON tlfs.tlid = a.tlid

    union all       -- tllog
    SELECT b.*, tlfs.tlfullname FROM
    (
    select actype,od.orderid, od.afacctno, od.txnum, od.txdate, od.execamt, od.feeamt,
    od.execqtty, tl.txdesc,exectype,tl.tlid, od.taxrate
    from tllog tl, odmast od
    where
    tl.txdate(+) = od.txdate
    and tl.txnum(+) = od.txnum
    and tl.deltd <> 'Y'
    ) b
    LEFT JOIN  tlprofiles tlfs
    ON tlfs.tlid = b.tlid
) od,
( SELECT * FROM stschd UNION ALL SELECT * FROM stschdhist) chd
where od.orderid = iod.orgorderid and od.actype = odtype.actype
     AND od.exectype= a.cdval AND cdtype='OD' AND cdname='EXECTYPE'
     AND chd.orgorderid = iod.orgorderid AND chd.orgorderid= od.orderid
     AND chd.acctno = od.afacctno
     AND od.afacctno = af.acctno
     And od.tlid  like V_STRBROKER
     AND cf.custid = af.custid
     and af.actype = aft.actype
     and AF.ACTYPE NOT IN ('0000')

     and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
     and od.txdate >= to_date (F_DATE ,'DD/MM/RRRR')
    and od.txdate <= to_date (T_DATE ,'DD/MM/RRRR')
    AND od.exectype like V_EXECTYPE
    and cf.careby like V_CAREBY
Order by od.txdate, od.orderid;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
