SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   REMISER        IN       VARCHAR2,
   CAREBY         IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO CHI PHAN BO NGUON MARGIN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   19-NOV-09  CREATED
-- ---------   ------  -------------------------------------------
    V_STROPTION          VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID            VARCHAR2 (4);

    V_STRREMISER     VARCHAR2 (10);
    V_STRCAREBY      VARCHAR2 (4);

    V_ALLOCATELIMIT  number(20,2);
    V_USEDLIMIT  number(20,2);
    V_REMISER  VARCHAR2 (50);
CURSOR A
is
select nvl(ALLOCATELIMMIT,0), nvl(USEDLIMMIT,0) from Userlimit where userlimit.tliduser like V_STRCAREBY
;

BEGIN
   V_STROPTION := OPT;
   V_STRCAREBY := CAREBY;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%';
   END IF;

   IF(REMISER <> 'ALL')
   THEN
        V_STRREMISER := REMISER;
   ELSE
        V_STRREMISER := '%';
   END IF;
OPEN A;
    FETCH A INTO V_ALLOCATELIMIT, V_USEDLIMIT ;
    IF A%notfound then
     V_ALLOCATELIMIT := 0;
     V_USEDLIMIT := 0;
END if;
CLOSE A;
    if REMISER <> 'ALL' then
        select nvl(cfmast.fullname,'NULL') into V_REMISER from cfmast where cfmast.custid like V_STRREMISER;
    end if;

if REMISER <> 'ALL' then
OPEN PV_REFCURSOR FOR
select  distinct V_REMISER REMISER , V_ALLOCATELIMIT ALLOCATELIMIT, V_USEDLIMIT USEDLIMIT,
         cfmast.fullname, cfmast.custid,
		(CASE WHEN afmast.acctno not in (select afgroup.accmember from afgroup) THEN 'Individual' ELSE 'Group' END ) LoaiHD,
		afmast.aftype,
		(CASE WHEN afmast.acctno not in (select afgroup.accmember from afgroup) THEN 'Null' ELSE 'Leader' END ) VaiTro,
		afmast.custid custid_1, afmast.acctno,
		nvl(useraflimit.acclimit,0) Do_User_Cap,
		nvl(useraflimit2.acclimit,0) Do_UserKhac_Cap,
		(nvl(useraflimit.acclimit,0) + nvl(useraflimit2.acclimit,0)) TongCap,
		(CASE WHEN afmast.mrcrlimitmax >
			(afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast.mrcrlimitmax END ) ConLai,
			 (nvl(useraflimit.acclimit,0) + nvl(useraflimit2.acclimit,0))-
		(CASE WHEN afmast.mrcrlimitmax >
			(afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast.mrcrlimitmax END ) DaDung
		from afmast, aftype, mrtype, useraflimit , (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CFMAST,
		(select useraflimit.acctno, sum(useraflimit.acclimit) acclimit from useraflimit where V_STRCAREBY <> useraflimit.tliduser
			and 'MR'= useraflimit.typereceive
			group by acctno
		) useraflimit2, v_getbuyorderinfo, cimast
	where afmast.actype = aftype.actype
		and afmast.acctno = v_getbuyorderinfo.afacctno(+)
		and afmast.acctno in (select cflink.acctno from cflink where cflink.custid like V_STRREMISER)
		and afmast.acctno = cimast.acctno
		and afmast.acctno = useraflimit.acctno(+)
		and afmast.acctno = useraflimit2.acctno(+)
		and 'MR'= useraflimit.typereceive(+)
		and V_STRCAREBY = useraflimit.tliduser(+)
		and cfmast.custid = afmast.custid
		and aftype.mrtype = mrtype.actype
        and mrtype.mrtype <> 'N'
		and afmast.custid in (select cfmast.custid from cfmast
    where cfmast.careby in(select tlgrpusers.grpid from tlprofiles, tlgrpusers
                                            where tlprofiles.tlid like V_STRCAREBY
                                                and tlprofiles.brid = tlgrpusers.brid
                                                and tlprofiles.tlid = tlgrpusers.tlid
                            ))
    and (afmast.acctno not in (select afgroup.accmember from afgroup)
			or afmast.acctno in (select afgroup.accmember from afgroup where afgroup.mbtype = 'L')
		)
union all
select V_REMISER REMISER , V_ALLOCATELIMIT ALLOCATELIMIT, V_USEDLIMIT USEDLIMIT,
         cfmast.fullname, cfmast.custid, 'Group' LoaiHD, afmast2.aftype, 'Member' VaiTro, afmast2.custid custid_1, afmast2.acctno,
	nvl(useraflimit.acclimit,0) Do_User_Cap, nvl(useraflimit2.acclimit,0) Do_UserKhac_Cap,
	(nvl(useraflimit.acclimit,0)+nvl(useraflimit2.acclimit,0)) TongCap,
	(CASE WHEN afmast2.mrcrlimitmax >
			(afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast2.mrcrlimitmax END ) ConLai,
		(nvl(useraflimit.acclimit,0)+nvl(useraflimit2.acclimit,0))-
			(CASE WHEN afmast2.mrcrlimitmax >
			(afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast2.mrcrlimitmax END ) DaDung

	from afgroup, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)cfmast, afmast, afmast afmast2, useraflimit,
	(select useraflimit.acctno, sum(useraflimit.acclimit) acclimit from useraflimit where V_STRCAREBY <> useraflimit.tliduser
			and 'MR'= useraflimit.typereceive
			group by acctno
	)useraflimit2, v_getbuyorderinfo, cimast
	where afgroup.mbtype like 'M'
		and afgroup.accleader = afmast.acctno
		and cfmast.custid = afmast.custid
		and afgroup.accmember = afmast2.acctno
		and 'MR' = useraflimit.typereceive(+)
		and afmast2.acctno = useraflimit.acctno(+)
		and V_STRCAREBY = useraflimit.tliduser(+)
		and afmast2.acctno = useraflimit2.acctno(+)
		and afmast2.acctno = v_getbuyorderinfo.afacctno(+)
		and afmast2.acctno = cimast.acctno
		and afmast2.acctno in (select cflink.acctno from cflink where cflink.custid like V_STRREMISER)
		and cfmast.custid in (select cfmast.custid from cfmast
    where cfmast.careby in(select tlgrpusers.grpid from tlprofiles, tlgrpusers
                                            where tlprofiles.tlid like V_STRCAREBY
                                                and tlprofiles.brid = tlgrpusers.brid
                                                and tlprofiles.tlid = tlgrpusers.tlid
                            ))
;
else
OPEN PV_REFCURSOR FOR
select  distinct 'ALL' REMISER , V_ALLOCATELIMIT ALLOCATELIMIT, V_USEDLIMIT USEDLIMIT,
         cfmast.fullname, cfmast.custid,
		(CASE WHEN afmast.acctno not in (select afgroup.accmember from afgroup) THEN 'Individual' ELSE 'Group' END ) LoaiHD,
		afmast.aftype,
		(CASE WHEN afmast.acctno not in (select afgroup.accmember from afgroup) THEN 'Null' ELSE 'Leader' END ) VaiTro,
		afmast.custid custid_1, afmast.acctno,
		nvl(useraflimit.acclimit,0) Do_User_Cap,
		nvl(useraflimit2.acclimit,0) Do_UserKhac_Cap,
		(nvl(useraflimit.acclimit,0) + nvl(useraflimit2.acclimit,0)) TongCap,
		(CASE WHEN afmast.mrcrlimitmax >
			(afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast.mrcrlimitmax END ) ConLai,
			 (nvl(useraflimit.acclimit,0) + nvl(useraflimit2.acclimit,0))-
		(CASE WHEN afmast.mrcrlimitmax >
			(afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast.mrcrlimitmax END ) DaDung
		from afmast, aftype, mrtype, useraflimit , (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cfmast,
		(select useraflimit.acctno, sum(useraflimit.acclimit) acclimit from useraflimit where V_STRCAREBY <> useraflimit.tliduser
			and 'MR'= useraflimit.typereceive
			group by acctno
		) useraflimit2, v_getbuyorderinfo, cimast
	where afmast.actype = aftype.actype
		and afmast.acctno = v_getbuyorderinfo.afacctno(+)
		and afmast.acctno = cimast.acctno
		and afmast.acctno = useraflimit.acctno(+)
		and afmast.acctno = useraflimit2.acctno(+)
		and 'MR'= useraflimit.typereceive(+)
		and V_STRCAREBY = useraflimit.tliduser(+)
		and cfmast.custid = afmast.custid
		and aftype.mrtype = mrtype.actype
        and mrtype.mrtype <> 'N'
		and afmast.custid in (select cfmast.custid from cfmast
    where cfmast.careby in(select tlgrpusers.grpid from tlprofiles, tlgrpusers
                                            where tlprofiles.tlid like V_STRCAREBY
                                                and tlprofiles.brid = tlgrpusers.brid
                                                and tlprofiles.tlid = tlgrpusers.tlid
                            ))
    and (afmast.acctno not in (select afgroup.accmember from afgroup)
			or afmast.acctno in (select afgroup.accmember from afgroup where afgroup.mbtype = 'L')
		)
union all
select 'ALL' REMISER , V_ALLOCATELIMIT ALLOCATELIMIT, V_USEDLIMIT USEDLIMIT,
    cfmast.fullname, cfmast.custid, 'Group' LoaiHD, afmast2.aftype, 'Member' VaiTro, afmast2.custid custid_1, afmast2.acctno,
	nvl(useraflimit.acclimit,0) Do_User_Cap, nvl(useraflimit2.acclimit,0) Do_UserKhac_Cap,
	(nvl(useraflimit.acclimit,0)+nvl(useraflimit2.acclimit,0)) TongCap,
	(CASE WHEN afmast2.mrcrlimitmax >
			(afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast2.mrcrlimitmax END ) ConLai,
		(nvl(useraflimit.acclimit,0)+nvl(useraflimit2.acclimit,0))-
			(CASE WHEN afmast2.mrcrlimitmax >
			(afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
				THEN (afmast2.mrcrlimitmax +
			(cimast.balance - nvl(v_getbuyorderinfo.advamt,0) - nvl(v_getbuyorderinfo.SECUREAMT,0)) - cimast.odamt)
			 ELSE afmast2.mrcrlimitmax END ) DaDung
	from afgroup, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)cfmast, afmast, afmast afmast2, useraflimit,
	(select useraflimit.acctno, sum(useraflimit.acclimit) acclimit from useraflimit where V_STRCAREBY <> useraflimit.tliduser
			and 'MR'= useraflimit.typereceive
			group by acctno
	)useraflimit2, v_getbuyorderinfo, cimast
	where afgroup.mbtype like 'M'
		and afgroup.accleader = afmast.acctno
		and cfmast.custid = afmast.custid
		and afgroup.accmember = afmast2.acctno
		and 'MR' = useraflimit.typereceive(+)
		and afmast2.acctno = useraflimit.acctno(+)
		and V_STRCAREBY = useraflimit.tliduser(+)
		and afmast2.acctno = useraflimit2.acctno(+)
		and afmast2.acctno = v_getbuyorderinfo.afacctno(+)
		and afmast2.acctno = cimast.acctno
		and cfmast.custid in (select cfmast.custid from cfmast
    where cfmast.careby in(select tlgrpusers.grpid from tlprofiles, tlgrpusers
                                            where tlprofiles.tlid like V_STRCAREBY
                                                and tlprofiles.brid = tlgrpusers.brid
                                                and tlprofiles.tlid = tlgrpusers.tlid
                            ))
;
end if;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
