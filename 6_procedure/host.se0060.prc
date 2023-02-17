SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0060" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   SEARCHDATE      IN      VARCHAR2,
   FROMMONTH          IN      VARCHAR2,
   TOMONTH          IN      VARCHAR2,
   I_CUSTODYCD     IN      VARCHAR2,
   PLSENT          IN      VARCHAR2,
   COREBANK         IN       VARCHAR2,
   BANKNAME         IN       VARCHAR2,
   I_BRIDGD           IN       VARCHAR2,
   I_CUSTTYPE       IN       VARCHAR2

   )
IS


--Bao cao tong hop phi luu ky hang thang
--created by CHaunh at 11/05/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);            -- USED WHEN V_NUMOPTION > 0
   V_F_DATE    DATE;
   F_DATE    DATE;
   V_T_DATE    DATE;
   V_CURR_DATE DATE;
   V_STRCUSTODYCD varchar2(20);
   V_STRPLSENT       varchar2(20);
   V_SEARCHDATE DATE;
   V_STRCOREBANK          VARCHAR(20);
   V_STRBANKNAME       VARCHAR(20);
    V_I_BRIDGD          VARCHAR2(100);
       V_BRNAME            NVARCHAR2(400);
       V_STRCUSTTYPE     NVARCHAR2(400);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

/*   IF TO_NUMBER(SUBSTR(FROMMONTH,1,2)) <= 12 THEN
        V_F_DATE := TO_DATE('01/' || SUBSTR(FROMMONTH,1,2) || '/' || SUBSTR(FROMMONTH,4,4),'DD/MM/RRRR');
    ELSE
        V_F_DATE := TO_DATE('31/12/9999','DD/MM/RRRR');
    END IF;
*/
   /* IF TO_NUMBER(SUBSTR(TOMONTH,1,2)) <= 12 THEN
        F_DATE := TO_DATE('01/' || SUBSTR(TOMONTH,1,2) || '/' || SUBSTR(TOMONTH,4,4),'DD/MM/RRRR');
    ELSE
        F_DATE := TO_DATE('31/12/9999','DD/MM/RRRR');
    END IF;

    V_T_DATE := LAST_DAY(F_DATE);*/

    V_F_DATE:=TO_DATE(FROMMONTH,'DD/MM/RRRR');
    V_T_DATE:=TO_DATE(TOMONTH,'DD/MM/RRRR');

    V_SEARCHDATE:= to_date(SEARCHDATE,'DD/MM/RRRR');
    SELECT to_date(varvalue,'DD/MM/RRRR') INTO V_CURR_DATE FROM sysvar WHERE varname = 'CURRDATE';

   IF(I_CUSTODYCD = 'ALL' or I_CUSTODYCD is null )
   THEN
        V_STRCUSTODYCD := '%%';
   ELSE
        V_STRCUSTODYCD := I_CUSTODYCD;
   END IF;


    IF(PLSENT = 'ALL' OR PLSENT IS NULL)
    THEN
       V_STRPLSENT := -1; --tat ca
   ELSIF (PLSENT = '01') THEN
       V_STRPLSENT := 0; -- con no
   ELSIF (PLSENT = '03') THEN
       V_STRPLSENT := 2; -- phi da thu
   else
       V_STRPLSENT := 1; -- het no
   END IF;

   IF(COREBANK <> 'ALL')
   THEN
        V_STRCOREBANK  := COREBANK;
   ELSE
        V_STRCOREBANK  := '%%';
   END IF;
   IF(BANKNAME <> 'ALL')
   THEN
        V_STRBANKNAME  := BANKNAME;
   ELSE
        V_STRBANKNAME := '%%';
   END IF;

    IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  ' To�c�ty ';
   END IF;


   IF(I_CUSTTYPE <> 'ALL')
   THEN
        V_STRCUSTTYPE  := I_CUSTTYPE;
   ELSE
        V_STRCUSTTYPE  := '%%';
   END IF;


OPEN PV_REFCURSOR
FOR
  SELECT tomonth, tra_ngay, CUSTODYCD, FULLNAME,THANG,BRNAME,SUM(NMLAMT)NMLAMT,
  SUM(namt)namt,SUM(con_no)con_no
  FROM (
      SELECT V_SEARCHDATE tomonth, V_T_DATE tra_ngay,NML.CUSTODYCD,NML.FULLNAME,
      NML.THANG,NML.BRNAME, nml.CON_NO NMLAMT, --NML.NMLAMT,
      NVL(TRA.PAID,0)namt,/*NML.NMLAMT*/nml.CON_NO-NVL(TRA.PAID,0) con_no
      FROM(
      SELECT A.CUSTID,A.CUSTODYCD,A.NMLAMT,A.THANG,
      A.FULLNAME,A.BRNAME,  A.NMLAMT-NVL(B.PAID,0) CON_NO
      FROM ( SELECT  CF.CUSTID,CF.CUSTODYCD,SUM(NMLAMT) NMLAMT,TO_CHAR(TODATE,'MM/YYYY') THANG,
            CF.FULLNAME,BR.BRNAME
            FROM CIFEESCHD FEE,(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,AFMAST AF,BRGRP BR
            WHERE FEE.AFACCTNO=AF.ACCTNO
            AND AF.CUSTID=CF.CUSTID AND CF.BRID=BR.BRID
            AND FEE.TXDATE<=V_SEARCHDATE-- AND FEE.TODATE<=V_T_DATE AND FEE.TODATE>=V_F_DATE
            AND cf.custodycd  like V_STRCUSTODYCD
            and af.corebank like V_STRCOREBANK
            and af.bankname like V_STRBANKNAME
            AND CF.BRID LIKE V_I_BRIDGD
            AND CF.CUSTTYPE LIKE V_STRCUSTTYPE
           GROUP BY CF.FULLNAME,BR.BRNAME,CF.CUSTID,CF.CUSTODYCD,TO_CHAR(TODATE,'MM/YYYY'))A,
           (  SELECT to_char(SUBSTR(TRDESC,18))THANG,CUSTID,SUM(NAMT) PAID
            FROM VW_CITRAN_GEN WHERE TLTXCD IN ('1180','1182','1189')
            AND BUSDATE< V_F_DATE  AND FIELD='BALANCE'
            GROUP BY to_char(SUBSTR(TRDESC,18)),CUSTID)B
            WHERE A.CUSTID=B.CUSTID(+) AND A.THANG=B.THANG(+) AND  A.NMLAMT-NVL(B.PAID,0)<>0
            ) NML,
      (SELECT to_char(SUBSTR(TRDESC,18))THANG,TRDESC,CUSTID,CUSTODYCD,SUM(NAMT) PAID
      FROM VW_CITRAN_GEN WHERE TLTXCD IN ('1180','1182','1189')
      AND BUSDATE<=V_T_DATE AND BUSDATE>=V_F_DATE AND FIELD='BALANCE'
      GROUP BY to_char(SUBSTR(TRDESC,18)),TRDESC,CUSTID,CUSTODYCD) TRA
      WHERE NML.CUSTID=TRA.CUSTID(+) AND NML.THANG=TRA.THANG(+)

      UNION ALL
      SELECT  V_SEARCHDATE tomonth, V_T_DATE tra_ngay,cf.custodycd, cf.fullname,
       to_Char(tran.txdate,'MM/RRRR') thang, br.brname,(namt) nmlamt,
      (namt) namt, 0 con_no
      FROM vw_citran_gen tran, afmast af, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf , brgrp br
      WHERE tltxcd = '0088' AND CF.BRID=BR.BRID
      AND field IN ('CIDEPOFEEACR','DEPOFEEAMT') AND txtype = 'D'
      and tran.acctno = af.acctno and af.custid = cf.custid
      AND cf.custodycd  like V_STRCUSTODYCD
      and af.corebank like V_STRCOREBANK
      and af.bankname like V_STRBANKNAME
      AND CF.BRID LIKE V_I_BRIDGD
      AND CF.CUSTTYPE LIKE V_STRCUSTTYPE
      AND txdate <= V_SEARCHDATE AND txdate <= V_T_DATE AND txdate >= V_F_DATE

      )A GROUP BY tomonth, tra_ngay, CUSTODYCD, FULLNAME,THANG,BRNAME
      HAVING ROUND(SUM(A.NMLAMT) + SUM(A.namt)) <> 0
      AND case WHEN V_STRPLSENT = 0 AND sum(a.nmlamt - a.namt) > 0 THEN 1
           WHEN V_STRPLSENT = -1 THEN 1
           WHEN V_STRPLSENT = 1 AND sum(a.nmlamt - a.namt) = 0 THEN 1
               WHEN V_STRPLSENT = 2 AND sum (a.namt) > 0 THEN 1
           ELSE 0
      END = 1
ORDER BY A.custodycd, to_date(A.thang,'MM/RRRR')
;

/*SELECT V_T_DATE tomonth,\* V_F_DATE frommonth,*\ V_SEARCHDATE tra_ngay, a.custodycd, a.fullname, thang,BR.BRNAME,
        sum(a.nmlamt) nmlamt, sum(a.paid) namt, sum(a.nmlamt - a.paid) con_no
FROM
(
SELECT  cf.custodycd,CF.BRID, cf.fullname, nmlamt, to_char(fee.todate,'MM/RRRR') thang,
        CASE WHEN paidtxdate <= V_SEARCHDATE THEN paidamt ELSE 0 END paid
FROM cifeeschd fee, afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE fee.afacctno = af.acctno AND af.custid = cf.custid
AND AF.ACTYPE NOT IN ('0000')
AND cf.custodycd  like V_STRCUSTODYCD
AND (substr(cf.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cf.custid,1,4))<> 0)
AND  fee.todate <= V_T_DATE --AND fee.todate >= V_F_DATE
--Them dieu kien loc theo ngan hang
and af.corebank like V_STRCOREBANK
and af.bankname like V_STRBANKNAME
AND substr(cf.custid,1,4) LIKE V_I_BRIDGD
AND CF.CUSTTYPE LIKE V_STRCUSTTYPE
and af.corebank = 'N'
union

select fee.custodycd,FEE.BRID, fee.fullname, fee.nmlamt, fee.thang, least(fee.paid,nvl(trf.txamt,0)) paid  from (
SELECT  cf.custodycd,CF.BRID, cf.fullname, nmlamt, to_char(fee.todate,'MM/RRRR') thang,
        CASE WHEN paidtxdate <= V_SEARCHDATE THEN paidamt ELSE 0 END paid,
        fee.paidtxnum,fee.paidtxdate
FROM cifeeschd fee, afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE fee.afacctno = af.acctno AND af.custid = cf.custid
AND AF.ACTYPE NOT IN ('0000')
AND cf.custodycd  like V_STRCUSTODYCD
AND (substr(cf.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cf.custid,1,4))<> 0)
AND  fee.todate <= V_T_DATE --AND fee.todate >= V_F_DATE
--Them dieu kien loc theo ngan hang
and af.corebank like V_STRCOREBANK
and af.bankname like V_STRBANKNAME
 AND substr(CF.custid,1,4) LIKE V_I_BRIDGD
AND CF.CUSTTYPE LIKE V_STRCUSTTYPE
and af.corebank ='Y'
) fee,
(
select a.* from (select * from crbtxreq union select * from crbtxreqhist) a,
                (select * from crbtrflogdtl union select * from crbtrflogdtlhist) dtl ,vw_tllog_all b
    where a.trfcode ='TRFSEFEE'
    and a.refcode = b.txnum and a.txdate = b.txdate
    and DTL.REFREQID=a.REQID and dtl.status ='C'
) trf
where fee.paidtxnum = trf.refcode(+) and  fee.paidtxdate =trf.txdate(+)

UNION all
-- phat sinh phi trong thang hien tai
SELECT a.custodycd,A.BRID, a.fullname, a.nmlamt\* - nvl(b.paid,0)*\ nmlamt, to_char(V_CURR_DATE,'MM/RRRR') thang, 0 paid FROM

    (
    SELECT custodycd ,CF.BRID, fullname,
           SUM(CASE WHEN TO_CHAR(V_CURR_DATE,'MONTH') = TO_CHAR(SE.TXDATE, 'MONTH') THEN AMT ELSE 0 END) NMLAMT
           --sum(CASE WHEN to_char(V_CURR_DATE,'MONTH') = to_char(V_T_DATE,'MONTH') THEN  amt ELSE 0 END)  nmlamt
    FROM sedepobal se,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
    WHERE substr(se.acctno,1,10) = af.acctno AND af.custid = cf.custid
    AND cf.custodycd LIKE V_STRCUSTODYCD
   -- AND se.txdate >= V_F_DATE
    AND se.txdate <= V_T_DATE
    --Them dieu kien loc theo ngan hang
    and af.corebank like V_STRCOREBANK
    AND AF.ACTYPE NOT IN ('0000')
    and af.bankname like V_STRBANKNAME
    AND substr(CF.custid,1,4) LIKE V_I_BRIDGD
    AND CF.CUSTTYPE LIKE V_STRCUSTTYPE
    GROUP BY CF.custodycd , CF.fullname,CF.BRID
    ) a,
    (
    SELECT cf.custodycd, cf.fullname,
        sum(CASE WHEN to_char(V_CURR_DATE,'MONTH') = to_char(txdate,'MONTH') THEN  namt ELSE 0 END)  paid
    FROM vw_citran_gen tran,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf WHERE tltxcd = '0088'
    AND field IN ('CIDEPOFEEACR') AND txtype = 'D'
    AND tran.custid = cf.custid
    AND tran.custodycd  like V_STRCUSTODYCD
    AND (substr(tran.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(tran.custid,1,4))<> 0)
    AND txdate <= V_SEARCHDATE AND txdate <= V_T_DATE-- AND txdate >= V_F_DATE
    GROUP BY  cf.custodycd, cf.fullname
    ) b
    WHERE a.custodycd = b.custodycd(+)


union ALL
SELECT cf.custodycd,CF.BRID, cf.fullname, (namt) nmlamt, to_Char(tran.txdate,'MM/RRRR') thang,
     (namt) paid
FROM vw_citran_gen tran, afmast af,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf WHERE tltxcd = '0088'
AND field IN ('CIDEPOFEEACR') AND txtype = 'D'
--AND tran.custid = cf.custid
and tran.acctno = af.acctno and af.custid = cf.custid
AND AF.ACTYPE NOT IN ('0000')
AND tran.custodycd  like V_STRCUSTODYCD
--Them dieu kien loc theo ngan hang
and af.corebank like V_STRCOREBANK
and af.bankname like V_STRBANKNAME
 AND substr(CF.custid,1,4) LIKE V_I_BRIDGD
AND CF.CUSTTYPE LIKE V_STRCUSTTYPE
AND (substr(tran.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(tran.custid,1,4))<> 0)
AND txdate <= V_SEARCHDATE AND txdate <= V_T_DATE --AND txdate >= V_F_DATE

) a, BRGRP BR
WHERE A.BRID=BR.BRID
--AND sum(a.nmlamt) + sum(a.paid)>0
GROUP BY a.custodycd, a.fullname, a.thang, BR.BRNAME
having ROUND(sum(a.nmlamt) + sum(a.paid)) <> 0
AND case WHEN V_STRPLSENT = 0 AND sum(a.nmlamt - a.paid) > 0 THEN 1
           WHEN V_STRPLSENT = -1 THEN 1
           WHEN V_STRPLSENT = 1 AND sum(a.nmlamt - a.paid) = 0 THEN 1
               WHEN V_STRPLSENT = 2 AND sum (a.paid) > 0 THEN 1
           ELSE 0
      END = 1
ORDER BY A.custodycd, to_date(A.thang,'MM/RRRR')

;*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
/
