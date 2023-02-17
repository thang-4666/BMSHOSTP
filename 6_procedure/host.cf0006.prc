SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0006" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD       IN       VARCHAR2,
   AFACCTNO       IN       VARCHAR2,
   TLID            IN       VARCHAR2
  )
IS
--
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
--   Diennt       27/07/2011          Create
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   v_FromDate date;
   v_ToDate date;
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);
BEGIN


/*V_STROPTION := OPT;
IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(BRID,1,2) || '__' ;
else
    V_STRBRID:=BRID;
END IF;*/
 V_STRTLID:= TLID;
 V_STROPTION := upper(OPT);
 V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
v_ToDate:= to_date(T_DATE,'DD/MM/RRRR');
v_CustodyCD:= upper(replace(custodycd,'.',''));
v_AFAcctno:= upper(replace(AFACCTNO,'.',''));

if v_CustodyCD = 'ALL' or v_CustodyCD is null then
    v_CustodyCD := '%';
else
    v_CustodyCD := v_CustodyCD;
end if;

if v_AFAcctno = 'ALL' or v_AFAcctno is null then
    v_AFAcctno := '%';
else
    v_AFAcctno := v_AFAcctno;
end if;


OPEN PV_REFCURSOR FOR

    select cf.custodycd,af.acctno, cf.fullname,
           (case when ci.txcd='0039' then ci.namt else 0 end) Phong_toa,
           (case when ci.txcd='0038' then ci.namt else 0 end) Giai_toa,
           (case when ci.txcd='0039' then 'Phong toa tien' else 'Giai toa tien' end) Ghi_chu
    from
        vw_citran_all ci, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, V_INBRID, TLGOUPS)=0) cf, afmast af
    where
        ci.acctno=af.acctno
    and af.custid=cf.custid
    and ci.txcd in('0038','0039')
    and  ci.tltxcd in('1144','1145')
    and af.acctno like v_AFAcctno
    and cf.custodycd like v_CustodyCD
    and ci.bkdate>=v_FromDate and ci.bkdate<=v_ToDate
    order by cf.custodycd,af.acctno,ci.txdate,ci.txnum;

EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;
 
 
 
 
/
