SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1029" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   pv_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2,
   PV_CUSTODYCD           IN       VARCHAR2,
   RECUSTID               IN       VARCHAR2,
   CAREBY                 IN       VARCHAR2
  )
IS
--

-- BAO CAO SAO KE TIEN CUA TAI KHOAN KHACH HANG
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------

   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
   v_FromDate     date;
   v_ToDate       date;
   v_CurrDate     date;
   V_CUSTODYCD    varchar2(20);
   v_AFAcctno     varchar2(20);
   v_TLID         varchar2(4);
   V_TRADELOG CHAR(2);
   V_AUTOID NUMBER;
   V_RECUSTID         varchar2(20);
   V_CAREBY         varchar2(20);

BEGIN



   V_STROPTION := OPT;

   IF V_STROPTION = 'A' then
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(pv_BRID,1,2) || '__' ;
   else
    V_STRBRID:=pv_BRID;
   END IF;

   v_FromDate  :=     TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   v_ToDate    :=     TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);



   if (PV_CUSTODYCD = 'ALL' or PV_CUSTODYCD is null) then
      V_CUSTODYCD := '%';
   else
      V_CUSTODYCD := PV_CUSTODYCD;
   end if;


   if (RECUSTID = 'ALL' or RECUSTID is null) then
      V_RECUSTID := '%';
   else
      V_RECUSTID := CAREBY;
   end if;


   if (CAREBY = 'ALL' or CAREBY is null) then
      V_CAREBY := '%';
   else
      V_CAREBY := RECUSTID;
   end if;

select TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) into v_CurrDate from SYSVAR where grname='SYSTEM' and varname='CURRDATE';


OPEN PV_REFCURSOR FOR

SELECT cf.fullname,cf.custodycd,m.approve_dt,al.cdcontent, nvl(tl.grpname,'') rgrp , nvl(re.reuser,'')reuser
FROM maintain_log m,cfmast cf, allcode al,tlgroups tl ,
   (SELECT re.afacctno , max(regrp.fullname) rgrp, max( cfre.fullname) reuser
 /*      re.frdate re_frdate, nvl(re.clstxdate-1, re.todate) re_todate ,
       REGl.frdate REGl_frdate, nvl(REGl.clstxdate-1, REGl.todate) REGl_todate,cftn.fullname truongnhom*/
    FROM reaflnk re, regrplnk REGl,retype,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,regrp , cfmast cfre
    WHERE re.reacctno = REGl.reacctno(+)
    AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
    AND retype.rerole ='RM'
    AND re.afacctno = cf.custid
    AND REGl.refrecflnkid = regrp.autoid(+)
    AND substr(re.reacctno,1,10)= cfre.custid
    AND RE.STATUS ='A'
    AND REGl.STATUS ='A'
    AND CFRE.CUSTID LIKE V_RECUSTID
    group by re.afacctno
)re
where m.column_name  ='CLASS'
and substr( m.record_key,instr( m.record_key,'''')+1,10) =cf.custid
and al.cdname='CLASS'
AND AL.CDTYPE='CF'
AND TL.GRPID LIKE V_CAREBY
AND AL.cdval=m.to_value
and cf.careby = tl.grpid
and cf.custid = re.afacctno(+)
and cf.custodycd like V_CUSTODYCD
and  m.approve_dt BETWEEN v_FromDate and v_ToDate;

EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;

 
 
 
 
/
