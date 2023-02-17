SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0012" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         in       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   I_STATUS       in       VARCHAR2,
   I_DUESTS       in       VARCHAR2,
   p_RESTYPE      in       VARCHAR2,
   p_FR_RLSDATE       in       VARCHAR2,
   p_TO_RLSDATE       in       VARCHAR2,
   p_FR_OVERDUEDATE       in       VARCHAR2,
   p_TO_OVERDUEDATE       in       VARCHAR2,
   PV_AFTYPE       IN       VARCHAR2,
   TLID            IN       VARCHAR2

   )
IS

--

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THANHNM   12-APR-2012  CREATE
-- ---------   ------  -------------------------------------------
  -- PV_A            PKG_REPORT.REF_CURSOR;
   V_STROPTION      VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRI_BRID      VARCHAR2 (50);
   V_STRI_TYPE      VARCHAR2 (50);
   V_STRCIACCTNO    VARCHAR2 (200);
   V_AFTYPE        VARCHAR2(10);

   V_STRACCTNO      VARCHAR2 (200);

   V_STRFULLNAME    VARCHAR2 (1000);
   V_STRCUSTODYCD   VARCHAR2 (200);

   V_STRCUSTODYCD1  VARCHAR2 (200);
   V_CURRDATE       DATE;

   V_APMT           NUMBER(20,0);
   V_T0_APMT        NUMBER(20,0);
   V_T1_APMT        NUMBER(20,0);
   V_T2_APMT        NUMBER(20,0);
   V_BALANCE        NUMBER(20,0);
   V_DFDEBTAMT      NUMBER(20,0);
   V_ADVANCELINE    NUMBER(20,0);
   V_PAIDAMT        NUMBER(20,0);
   V_BALDEFOVD      NUMBER(20,0);
   V_MBLOCK         NUMBER(20,0);
   V_AAMT           NUMBER(20,0);
   V_SECUREAMT      NUMBER(20,0);
   V_T0ODAMT        NUMBER(20,0);
   V_MARGINAMT   NUMBER(20,0);
   V_T0AMT  NUMBER(20,0);
   V_DUEAMT   NUMBER(20,0);
   V_IDATE       date;
   V_STRSTATUS   varchar2(30);
   --V_ADDVND   NUMBER(20,0);
   V_SETOTALCALLASS  number (20,0);

   V_INBRID        VARCHAR2(40);
   V_STRBRID      VARCHAR2 (500);
   V_STRTLID           VARCHAR2(60);
   l_companyshortname varchar2(1000);
   CUR            PKG_REPORT.REF_CURSOR;

   BEGIN
/*   V_STROPTION := OPT;

   IF V_STROPTION = 'A' THEN     -- TOAN HE THONG
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' THEN
      V_STRBRID := SUBSTR(BRID,1,2) || '__' ;
   ELSE
      V_STRBRID := BRID;
   END IF;*/
    V_STRTLID:= TLID;
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   V_IDATE := to_date (I_DATE,'DD/MM/RRRR');
   V_STRSTATUS:= I_STATUS;
-----------------------
    if(UPPER(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD IS NULL ) THEN
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := PV_CUSTODYCD;
    end if;
-----------------------
   --V_STRCUSTODYCD:=PV_CUSTODYCD;

      IF PV_AFACCTNO ='ALL' THEN
   V_STRCIACCTNO:='%%';
   ELSE
   V_STRCIACCTNO  := PV_AFACCTNO;
   END IF;
   V_T0_APMT:=0;      V_T1_APMT:=0;         V_T2_APMT:=0;         V_APMT:=0;
        V_AAMT:=0; V_MBLOCK:=0; V_APMT:=0; V_BALANCE:=0; V_DFDEBTAMT:=0; V_ADVANCELINE:=0;V_SECUREAMT:=0;V_T0ODAMT:=0; V_PAIDAMT:=0;
         V_MARGINAMT:=0; V_T0AMT:=0; V_DUEAMT:=0;  V_BALDEFOVD:=0;
        --V_ADDVND   :=0;
        V_SETOTALCALLASS :=0;
l_companyshortname:=cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME');

IF(PV_AFTYPE = 'ALL')
THEN V_AFTYPE := '%%';
   ELSE V_AFTYPE := PV_AFTYPE;
   END IF;


OPEN CUR
 FOR
select fullname, CUSTODYCD   from cfmast where CUSTODYCD LIKE V_STRCUSTODYCD;
LOOP
  FETCH CUR
  into V_STRFULLNAME,V_STRCUSTODYCD1;
    EXIT WHEN CUR%NOTFOUND;
  END LOOP;
CLOSE CUR;


/*begin
    select fullname, CUSTODYCD into V_STRFULLNAME,V_STRCUSTODYCD  from cfmast where CUSTODYCD = V_STRCUSTODYCD;
exception when others then
    V_STRFULLNAME:='';
end;*/
SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO V_CURRDATE FROM SYSVAR WHERE VARNAME LIKE 'CURRDATE' AND GRNAME = 'SYSTEM';
begin
    SELECT MAXAVLAMT INTO V_APMT FROM ( SELECT nvl(SUM(MAXAVLAMT),0)  MAXAVLAMT FROM
    (
    SELECT CF.CUSTODYCD, CLEARDATE,TXDATE,
        RF.EXECAMT-RF.AAMT-RF.BRKFEEAMT-RF.RIGHTTAX-RF.INCOMETAXAMT MAXAVLAMT,
        RF.EXECAMT
    FROM AFMAST AF, CIMAST CI, CFMAST CF, SYSVAR SY1,
    (SELECT STS.AFACCTNO, STS.CLEARDATE, STS.TXDATE,
        SUM(STS.AMT) EXECAMT, SUM(STS.AMT-STS.AAMT-STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT) AMT,
        SUM(STS.FAMT) FAMT, SUM(STS.AAMT) AAMT, SUM(STS.PAIDAMT) PAIDAMT, SUM(STS.PAIDFEEAMT) PAIDFEEAMT,
        SUM(CASE WHEN MST.FEEACR<=0 THEN ODT.DEFFEERATE*STS.AMT/100 ELSE MST.FEEACR END) BRKFEEAMT,
        SUM(STS.ARIGHT) RIGHTTAX,
        SUM(round(TO_NUMBER(SY0.VARVALUE)*STS.AMT/100)) INCOMETAXAMT
    FROM STSCHD STS, ODMAST MST, SYSVAR SY0, ODTYPE ODT, SBSECURITIES SB
    WHERE STS.ORGORDERID=MST.ORDERID AND STS.CODEID=SB.CODEID AND MST.ACTYPE = ODT.ACTYPE
        AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
        AND SY0.VARNAME = 'ADVSELLDUTY' AND SY0.GRNAME = 'SYSTEM'

    GROUP BY STS.AFACCTNO, STS.CLEARDATE, STS.TXDATE) RF
    WHERE RF.AFACCTNO=AF.ACCTNO AND CI.AFACCTNO=AF.ACCTNO
    AND AF.CUSTID=CF.CUSTID AND CF.CUSTATCOM='Y'
        AND CI.COREBANK <> 'Y'
        AND SY1.VARNAME='CURRDATE' AND SY1.GRNAME='SYSTEM'
        AND CLEARDATE>=V_IDATE AND  RF.TXDATE <= V_IDATE
        AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
        AND AF.ACCTNO LIKE V_STRCIACCTNO

        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 ))) ;
exception when others then
    V_APMT:=0;
end;


--Lay balance
begin
    select sum(ci.balance) into V_BALANCE from cfmast cf, afmast af, cimast ci
    where cf.custid = af.custid and af.acctno = ci.afacctno
    and cf.custodycd like V_STRCUSTODYCD  and af.acctno like V_STRCIACCTNO
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 );
exception when others then
    V_BALANCE:=0;
end;
--Lay thong tin So Tien Nop Them
/*if V_IDATE  = V_CURRDATE then
select sum(V.ADDVND)  into V_ADDVND
from  cfmast cf,vw_mr0003 v, afmast af
where cf.custodycd =V_STRCUSTODYCD
AND v.acctno=af.acctno
and cf.custodycd = v.custodycd (+)
AND af.acctno LIKE V_STRCIACCTNO
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID );
else
V_ADDVND :=-1;
end if;*/

-- lay  Tai san
if V_IDATE  = V_CURRDATE then
    begin
        select sum(nvl(v.navaccount,0))  into V_SETOTALCALLASS from v_getsecmarginratio v, cfmast cf, afmast af
        where
        cf.custid = af.custid
        and af.acctno = v.afacctno (+)
        and cf.custodycd LIKE V_STRCUSTODYCD
        and af.acctno like V_STRCIACCTNO
        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 );

    exception when others then
        V_SETOTALCALLASS:=0;
    end;
else
V_SETOTALCALLASS:=-1;
end if;

if V_STRSTATUS ='001' then
    OPEN PV_REFCURSOR
    FOR
        select  PV_AFACCTNO AFACCTNO, V_STRFULLNAME FULLNAME, V_STRCUSTODYCD CUSTODYCD,V_STRCUSTODYCD1 CUSTO,
            V_APMT APMT, V_BALANCE BALANCE, V_DFDEBTAMT DFDEBTAMT, V_ADVANCELINE ADVANCELINE,
            V_PAIDAMT PAIDAMT, 0 TRFBUYAMT,V_MARGINAMT MARGINAMT,V_T0AMT T0AMT,V_DUEAMT DUEAMT,
            V_BALDEFOVD BALDEFOVD, V_AAMT AAMT, V_MBLOCK MBLOCK,V_SECUREAMT  SECUREAMT,
            NVL(V_T0_APMT,0) T0_APMT, NVL(V_T1_APMT,0) T1_APMT, NVL(V_T2_APMT,0) T2_APMT,
                LN.ACCTNO  acctno,LS.AUTOID, CF.CUSTODYCD CUST_KH,CF.FULLNAME CUST_NAME,
                case when ln.ftype ='DF' then 'DF' else
                   (case when ls.reftype ='GP' then 'BL' else 'CL' end) end  F_TYPE,
                   to_char(ls.rlsdate,'DD/MM/RRRR') rlsdate,
                   --ls.rlsdate,
                   TO_CHAR(ls.overduedate,'DD/MM/RRRR') overduedate,
                   ls.nml+ls.ovd+ls.paid F_GTGN,
                   ls.PAID - nvl(LNTR.PRIN_MOVE,0) F_GTTL,
                   ls.nml+ls.ovd  -  nvl(LNTR.PRIN_MOVE,0)  F_DNHT,
                   ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin +
                   ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd + ls.feeintdue -- +  ls.intpaid + ls.feeintpaid
                   - nvl(LNTR.PRFEE_MOVE,0) F_LAI_PHI,
                   '' F_LOAICB,  case when ln.ftype ='DF' then  to_char(ln.rate2) || ' - ' || to_char(ln.cfrate2)  else
                   --bao lanh
                   (case when ls.reftype ='GP' then to_char(ln.orate2) || ' - ' || to_char(ln.cfrate2) else
                   --margin
                   to_char(ln.rate2) || ' - ' || to_char(ln.cfrate2) end) end  F_TLLAI,
                   (case when V_IDATE  <> V_CURRDATE then 0
                   else   (  case when ln.ftype = 'DF' then 100 else round(sec.marginrate,2) end ) end) kRate,

                   --ban due chua tat toan ODCALLSELLMR
                   --(case when V_IDATE  <> V_CURRDATE then 0 else  NVL(V.VNDSELLDF,0) end) VNDSELLDF ,
                   (case when V_IDATE  <> V_CURRDATE then -1 else  NVL(V.ODCALLSELLMRATE,0) end) VNDSELLDF ,
                   (case when V_IDATE  <> V_CURRDATE then -1 else nvl(v.ODCALLDF,0) end) ODCALLDF,
                   I_DATE  IDATE ,I_STATUS  ISTATUS,
                   (case when V_IDATE  <> V_CURRDATE then -1 else
                    round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),greatest(ci.ovamt/*+depofeeamt*/ - balance - nvl(avladvance,0),0)),0)
                      end)   ADDVND,
                   (case when V_IDATE  <> V_CURRDATE then -1 else V_SETOTALCALLASS end) SETOTALCALLASS,
                   I_DUESTS DUESTS

        from (select * from lnmast union select * from lnmasthist) ln,
               (select * from lnschd union select * from lnschdhist) ls,
                (   select autoid,sum((case when nml > 0 then 0 else nml end )  +ovd) PRIN_MOVE,
                    sum(intnmlacr +intdue+intovd+intovdprin +
                    feeintnmlacr+ feeintdue+feeintovd+feeintovdprin) PRFEE_MOVE
                    from ( select * from lnschdlog union all select * from lnschdloghist ) lnslog
                    where nvl(deltd,'N') <>'Y' and txdate >V_IDATE
                    group by autoid) LNTR,
              (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, afmast af , cimast ci, v_getgrpdealformular v, v_getsecmarginratio sec,
                      AFTYPE AFT
        where ln.acctno = ls.acctno
            and ls.reftype in ('P','GP')
            and ln.rlsdate <= V_IDATE
            and ls.rlsdate <=  V_IDATE
            and ln.acctno = v.lnacctno(+)
            and ls.autoid = LNTR.autoid(+)
            and ls.rlsdate between to_date(p_FR_RLSDATE,'DD/MM/RRRR') and to_date(p_TO_RLSDATE,'DD/MM/RRRR')
            and ls.overduedate between to_date(p_FR_OVERDUEDATE,'DD/MM/RRRR') and to_date(p_TO_OVERDUEDATE,'DD/MM/RRRR')

            --Check trang thai Tat Toan
            and ls.nml+ls.ovd + LS.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin+ls.feeintnmlacr+ls.feeintovdacr+ls.feeintdue+ls.feeintnml+ls.feeintovd - nvl(LNTR.PRIN_MOVE,0) = 0
            --Check trang thai den han
            and  (case  when  I_DUESTS ='ALL' then 1
                        when  I_DUESTS ='001' then (case when V_IDATE < ls.overduedate  then 1 else 0 end)
                        when  I_DUESTS ='002' then (case when V_IDATE = ls.overduedate  then 1 else 0 end)
                        when  I_DUESTS ='003' then (case when V_IDATE > ls.overduedate  then 1 else 0 end)
                        else  0 end) > 0
            AND CF.CUSTID = AF.CUSTID
            AND LN.trfacctno = AF.ACCTNO
            AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
            AND AF.ACCTNO LIKE V_STRCIACCTNO
            and af.acctno = sec.afacctno
            and af.acctno = ci.acctno
            AND AFT.ACTYPE =AF.ACTYPE
            AND AFT.PRODUCTTYPE LIKE V_AFTYPE

 ORDER BY LS.RLSDATE, LN.TRFACCTNO,CF.CUSTODYCD


            ;
 else
    OPEN PV_REFCURSOR
    FOR

        select  PV_AFACCTNO AFACCTNO, V_STRFULLNAME FULLNAME, V_STRCUSTODYCD CUSTODYCD,V_STRCUSTODYCD1 CUSTO,
            V_APMT APMT, V_BALANCE BALANCE, V_DFDEBTAMT DFDEBTAMT, V_ADVANCELINE ADVANCELINE,
            V_PAIDAMT PAIDAMT, 0 TRFBUYAMT,V_MARGINAMT MARGINAMT,V_T0AMT T0AMT,V_DUEAMT DUEAMT,
            V_BALDEFOVD BALDEFOVD, V_AAMT AAMT, V_MBLOCK MBLOCK,V_SECUREAMT  SECUREAMT,
            NVL(V_T0_APMT,0) T0_APMT, NVL(V_T1_APMT,0) T1_APMT, NVL(V_T2_APMT,0) T2_APMT,
            LN.ACCTNO  acctno,LS.AUTOID, CF.CUSTODYCD CUST_KH,CF.FULLNAME CUST_NAME,
                case when ln.ftype ='DF' then 'DF' else
                   (case when ls.reftype ='GP' then 'BL' else 'CL' end) end  F_TYPE,
                   to_char(ls.rlsdate,'DD/MM/RRRR') rlsdate,
                   --ls.rlsdate,
                   TO_CHAR(ls.overduedate,'DD/MM/RRRR') overduedate,
                    ls.nml+ls.ovd+ls.paid F_GTGN,
                   ls.PAID - nvl(LNTR.PRIN_MOVE,0) F_GTTL,
                   ls.nml+ls.ovd  -  nvl(LNTR.PRIN_MOVE,0)  F_DNHT,
                   ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin +
                   ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd + ls.feeintdue -- +  ls.intpaid + ls.feeintpaid
                   - nvl(LNTR.PRFEE_MOVE,0) F_LAI_PHI,

                   '' F_LOAICB,  case when ln.ftype ='DF' then  to_char(ln.rate2) || ' - ' || to_char(ln.cfrate2)  else
                   --bao lanh
                   (case when ls.reftype ='GP' then to_char(ln.orate2) || ' - ' || to_char(ln.cfrate2) else
                   --margin
                   to_char(ln.rate2) || ' - ' || to_char(ln.cfrate2) end) end  F_TLLAI,
                   (case when V_IDATE  <> V_CURRDATE then 0 else
                   (case when ln.ftype = 'DF' then 100 else round(sec.marginrate,2) end) end) kRate,


                   --ban due chua tat toan ODCALLSELLMR
                   --(case when V_IDATE  <> V_CURRDATE then 0 else  NVL(V.VNDSELLDF,0) end) VNDSELLDF ,
                   (case when V_IDATE  <> V_CURRDATE then -1 else  NVL(V.ODCALLSELLMRATE,0) end) VNDSELLDF ,
                   (case when V_IDATE  <> V_CURRDATE then -1 else nvl(v.ODCALLDF,0) end) ODCALLDF,
                   I_DATE  IDATE ,I_STATUS  ISTATUS,
                   (case when V_IDATE  <> V_CURRDATE then -1 else
                        round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),greatest(ci.ovamt/*+depofeeamt*/ - balance - nvl(avladvance,0),0)),0)
                      end)   ADDVND,
                   (case when V_IDATE  <> V_CURRDATE then -1 else V_SETOTALCALLASS end) SETOTALCALLASS,
                   I_DUESTS DUESTS,
                   nvl(cfb.shortname,l_companyshortname) restype, --- NGAN HANG GIAI NGAN
                   LS.AUTOID
        from (select * from lnmast union select * from lnmasthist) ln,
              (select * from lnschd union select * from lnschdhist) ls,
               (   select autoid,sum((case when nml>0 then 0 else nml end) +ovd) PRIN_MOVE,
                    sum(intnmlacr +intdue+intovd+intovdprin +
                    feeintnmlacr+ feeintdue+feeintovd+feeintovdprin) PRFEE_MOVE
                    from ( select * from lnschdlog union all select * from lnschdloghist ) lnslog
                    where nvl(deltd,'N') <>'Y' and txdate > V_IDATE
                    group by autoid) LNTR,
              (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, afmast af , cimast ci, v_getgrpdealformular v, v_getsecmarginratio sec,cfmast cfb,
                      AFTYPE AFT
        where ln.acctno = ls.acctno
            and AFT.actype =af.actype
            and ls.reftype in ('P','GP')
            and ln.rlsdate <= V_IDATE
            and ls.rlsdate <=  V_IDATE
            and ln.acctno = v.lnacctno (+)
            and ls.autoid = LNTR.autoid(+)
            and ln.custbank = cfb.custid(+)
            and ls.rlsdate between to_date(p_FR_RLSDATE,'DD/MM/RRRR') and to_date(p_TO_RLSDATE,'DD/MM/RRRR')
            and ls.overduedate between to_date(p_FR_OVERDUEDATE,'DD/MM/RRRR') and to_date(p_TO_OVERDUEDATE,'DD/MM/RRRR')

            --check trang thai Tat Toan
            and decode(V_STRSTATUS,'ALL',1,ls.nml+ls.ovd+LS.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin+ls.feeintnmlacr+ls.feeintovdacr+ls.feeintdue+ls.feeintnml+ls.feeintovd - nvl(LNTR.PRIN_MOVE,0)) > 0
            --Check trang thai den han
            and  (case  when  I_DUESTS ='ALL' then 1
                        when  I_DUESTS ='001' then (case when V_IDATE < ls.overduedate  then 1 else 0 end)
                        when  I_DUESTS ='002' then (case when V_IDATE = ls.overduedate  then 1 else 0 end)
                        when  I_DUESTS ='003' then (case when V_IDATE > ls.overduedate  then 1 else 0 end)
                        else  0 end) > 0
            --CHEKC NGUON GIAI NGAN
            and case when p_RESTYPE = 'ALL' then 1
                                when ln.rrtype = 'C' and p_RESTYPE = l_companyshortname then 1
                                when ln.rrtype = 'B' and p_RESTYPE = nvl(cfb.shortname,l_companyshortname) then 1
                                else 0 end <> 0
            AND CF.CUSTID = AF.CUSTID
            AND LN.trfacctno = AF.ACCTNO
            AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
            AND AF.ACCTNO LIKE V_STRCIACCTNO
            and af.acctno = sec.afacctno
            and af.acctno = ci.acctno
            AND AF.PRODUCTTYPE LIKE V_AFTYPE


            /*and ls.nml+ls.ovd  -  nvl(LNTR.PRIN_MOVE,0)  + ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin +
                   ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd + ls.feeintdue - nvl(LNTR.PRFEE_MOVE,0) > 100*/
 ORDER BY LS.RLSDATE, LN.TRFACCTNO,CF.CUSTODYCD


        ;
 end if;



EXCEPTION
   WHEN OTHERS
   THEN
   --pr_error('mr0012','Loi:' || SQLERRM || ' -dong:' || dbms_utility.format_error_backtrace );
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
