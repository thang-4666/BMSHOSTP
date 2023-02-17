SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0032" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_CIACCTNO    IN       VARCHAR2,
   PV_DEBT        IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO TINH PHI LUU KY TONG HOP CHO TUNG TIEU KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUYETKD   13-05-2011  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2  (5);

   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRCUSTODYCD      VARCHAR2 (20);
   STR_CIACCTNO        VARCHAR2(20);
   V_DEBT              VARCHAR2(10);

BEGIN
  /* V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;


   -- GET REPORT'S PARAMETERS
  IF (CUSTODYCD <> 'ALL' or CUSTODYCD <> '')
   THEN
      V_STRCUSTODYCD :=  CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   IF (PV_CIACCTNO <> 'ALL' or PV_CIACCTNO <> '')
   THEN
      STR_CIACCTNO :=  PV_CIACCTNO;
   ELSE
      STR_CIACCTNO := '%%';
   END IF;

   IF (PV_DEBT <> 'ALL' or PV_DEBT <> '')
   THEN
      V_DEBT :=  PV_DEBT;
   ELSE
      V_DEBT := '%%';
   END IF;

   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR

          Select
          cf.custodycd ,
          cf.fullname ,
          af.acctno afacctno,
          no_tai_t_date,
          no_ps_tk,
          no_datra_tk,
          (no_tai_t_date + no_datra_tk - no_ps_tk) no_ky_truoc,
          NO_PS_TRAIPHIEU
          from
          afmast af ,
          (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf ,
          (
          Select
          ci.afacctno ,
          cidepofeeacr No_hientai,
          (nvl(cidepofeeacr,0) + nvl(NHT.NO_DATRA,0) - nvl(NHT.NO_PS,0)) no_tai_T_DATE ,

          nvl(NTK.NO_PS,0) NO_PS_TK ,
          nvl(NTK.NO_DATRA,0)  NO_DATRA_TK,
          nvl(NO_TP.NO_PS,0) NO_PS_TRAIPHIEU

          from cimast ci,
          (
          Select afacctno , sum(nvl(NO_DATRA,0)) NO_DATRA , sum(nvl(NO_PS,0)) NO_PS
          FROM
          (
          Select msgacct  afacctno , msgamt NO_DATRA  ,  0 NO_PS  from
          (
          --tra no
          Select msgacct , msgamt  from tllog where tltxcd in ('1180','1182','1189') and deltd <>'Y'
          and txdate > to_date(T_DATE,'dd/MM/yyyy')
          union all
          Select  msgacct , msgamt  from tllogALL where tltxcd in ('1180','1182','1189')  and deltd <>'Y'
          and txdate > to_date(T_DATE,'dd/MM/yyyy')
          union all
          SELECT  acctno  msgacct , namt msgamt FROM VW_CITRAN_GEN
          WHERE FIELD IN ('CIDEPOFEEACR','DEPOFEEAMT') AND TLTXCD IN ('0088')  AND TXTYPE='D'
          and txdate > to_date(T_DATE,'dd/MM/yyyy')
           )tl
          union all
          -- phat sinh no
          Select afacctno , 0 NO_DATRA , cidepofeeacr NO_PS
          from cidepofeetran
          where 0=0
           and todate > to_date(T_DATE,'dd/MM/yyyy')
          )PSN
          group by afacctno
          ) NHT , -- NHT
          (
          Select afacctno , sum(nvl(NO_DATRA,0)) NO_DATRA , sum(nvl(NO_PS,0)) NO_PS
          FROM
          (
          Select msgacct  afacctno , msgamt NO_DATRA  ,  0 NO_PS  from
          (
          --tra no
          Select  msgacct ,  msgamt from tllog where tltxcd in ('1180','1182','1189') and deltd <>'Y'
           and txdate <= to_date(T_DATE,'dd/MM/yyyy')
           and txdate >= to_date(F_DATE,'dd/MM/yyyy')
          union all
          Select  msgacct ,  msgamt from tllogALL where tltxcd in ('1180','1182','1189')  and deltd <>'Y'
           and txdate <= to_date(T_DATE,'dd/MM/yyyy')
           and txdate >= to_date(F_DATE,'dd/MM/yyyy')
           union all
          SELECT  acctno msgacct , namt  msgamt FROM VW_CITRAN_GEN
          WHERE FIELD IN ('CIDEPOFEEACR','DEPOFEEAMT') AND TLTXCD IN ('0088')  AND TXTYPE='D'
           and txdate <= to_date(T_DATE,'dd/MM/yyyy')
           and txdate >= to_date(F_DATE,'dd/MM/yyyy')
          )tl
          union all
          -- phat sinh no
          Select afacctno , 0 NO_DATRA , cidepofeeacr NO_PS
          from cidepofeetran
          where 0=0
            and todate <= to_date(T_DATE,'dd/MM/yyyy')
            and todate >= to_date(F_DATE,'dd/MM/yyyy')
          )PSN
          group by afacctno

          )NTK,
          (
          Select afacctno , 0 NO_DATRA , Sum(cidepofeeacr) NO_PS
          from cidepofeetran
          where 0=0
            and depotype ='T'
            and todate <= to_date(T_DATE,'dd/MM/yyyy')
            and todate >= to_date(F_DATE,'dd/MM/yyyy')
            group by afacctno
          )NO_TP -- tinh phat sinh no cho trai phieu
          where ci.afacctno = NHT.afacctno(+)
          and  ci.afacctno = NTK.afacctno(+)
          and ci.afacctno = NO_TP.afacctno(+)
          )FRE
          where FRE.afacctno=af.acctno
          and  af.custid= cf.custid
          and (no_tai_t_date <>0 or no_ps_tk<> 0 or no_datra_tk<>0 )
          and Cf.Custodycd Like V_STRCUSTODYCD
          and af.acctno like STR_CIACCTNO
          and DECODE(no_tai_t_date, 0, 'N', 'Y') LIKE V_DEBT
          AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

          ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
