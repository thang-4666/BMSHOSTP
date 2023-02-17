SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE getaccountinfo (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,AFACCTNO IN VARCHAR2,INDATE IN VARCHAR2)
  IS

  V_AFACCTNO VARCHAR2(10);
  V_INDATE VARCHAR2(20);
  v_margintype char(1);
  v_margindesc VARCHAR2(200);
  v_actype varchar2(4);
  v_groupleader varchar2(10);
  v_aamt number(20,0);
  v_pp number(20,0);
  v_avllimit number(20,0);
  v_total   number(20,0);
  v_isPPUsed    number(20,0);
  l_ISSTOPADV  varchar2(1);
BEGIN
      select varvalue INTO l_ISSTOPADV  from sysvar where varname like 'ISSTOPADV' AND grname ='SYSTEM';

    V_AFACCTNO:=AFACCTNO;
    V_INDATE:=INDATE;
    SELECT MR.MRTYPE,af.actype,mst.groupleader,MR.isppused into v_margintype,v_actype,v_groupleader,v_isPPUsed from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=V_AFACCTNO;
    SELECT CDCONTENT INTO v_margindesc FROM ALLCODE  WHERE  CDTYPE='SA' AND  CDNAME='MARGINTYPE' AND CDVAL=v_margintype;

    if v_margintype='N' or v_margintype='L' then
        --Tai khoan binh thuong khong Margin
        OPEN PV_REFCURSOR FOR
          SELECT v_margintype MRTYPE,v_isPPUsed ISPPUSED,ACCTNO,LICENSE,CUSTID,CUSTODYCD,FULLNAME,ADDRESS,v_margindesc TERM,COREBANK,ALTERNATEACCT,
          BALANCE- ODAMT-NVL(ADVAMT,0)-NVL(SECUREAMT,0) BALANCE,BRATIO,ACTYPE,nvl(adv.avladvance,0) AAMT,TOTAL-NVL(SECUREAMT,0) TOTAL,NVL(ADVAMT,0) ADVAMT,
          greatest(  decode (l_ISSTOPADV,'Y',0,'N',NVL(ADV.AVLADVANCE,0)) +nvl(A.mrcrlimit,0)+ A.ADVANCELINE + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT+CLAMTLIMIT,0) PP,
          NVL(ADV.AVLADVANCE,0) + A.ADVANCELINE + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (OVERAMT, 0)-NVL(SECUREAMT,0) - RAMT AVLLIMIT
        FROM
            (
                SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME, CF.ADDRESS,CI.COREBANK,AF.ALTERNATEACCT, CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt, AF.BRATIO,AF.ACTYPE, NVL(AP.AAMT,0) AAMT , CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,AF.MRCRLIMITMAX,AF.CLAMTLIMIT
                FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID
                INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
                LEFT JOIN (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y' AND AFACCTNO = V_AFACCTNO GROUP BY AFACCTNO) AP ON TRIM(AF.ACCTNO) = TRIM(AP.ACCTNO)
                WHERE AF.ACCTNO=V_AFACCTNO

             ) A
         left join
         (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) B
            on A.ACCTNO=B.AFACCTNO
         LEFT JOIN
         (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
            on se.afacctno=a.acctno
         LEFT JOIN
        (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = V_AFACCTNO group by afacctno) adv
           on adv.afacctno=a.acctno ;
    elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or v_groupleader is null) then
        --Tai khoan margin khong tham gia group
        OPEN PV_REFCURSOR FOR
          SELECT v_margintype MRTYPE,v_isPPUsed ISPPUSED,ACCTNO,LICENSE,CUSTID,CUSTODYCD,FULLNAME,ADDRESS,v_margindesc TERM,COREBANK,ALTERNATEACCT,
          BALANCE- ODAMT-NVL(ADVAMT,0)-NVL(SECUREAMT,0) BALANCE,BRATIO,ACTYPE,nvl(adv.avladvance,0) AAMT,TOTAL-NVL(SECUREAMT,0) TOTAL,NVL(ADVAMT,0) ADVAMT,
/*          GREATEST( LEAST((NVL(A.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                            NVL(SE.RECEIVINGAMT,0)) + nvl(se.trfamt,0)
                    ,NVL(ADV.AVLADVANCE,0) + greatest(NVL(A.MRCRLIMITMAX,0)-DFODAMT,0))
               + A.ADVANCELINE + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL(SECUREAMT,0) - RAMT,0) PP,*/
          -- nvl(a.balance - nvl(secureamt,0) + nvl(adv.avladvance,0) + a.advanceline + least(nvl(a.mrcrlimitmax,0),nvl(a.mrcrlimit,0) + nvl(se.seamt,0)+nvl(se.trfamt,0)) - nvl(a.odamt,0) - a.dfdebtamt - a.dfintdebtamt,0) pp,
          nvl(a.balance - nvl(secureamt,0) +  decode (l_ISSTOPADV,'Y',0,'N', nvl(adv.avladvance,0)) + a.advanceline + least(nvl(a.mrcrlimitmax,0)+nvl(a.mrcrlimit,0),nvl(a.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(a.odamt,0) - a.dfdebtamt - a.dfintdebtamt+CLAMTLIMIT,0) pp,
          NVL(ADV.AVLADVANCE,0) + A.ADVANCELINE + NVL(A.MRCRLIMITMAX,0)+nvl(a.mrcrlimit,0)- DFODAMT + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (OVERAMT, 0)-NVL(SECUREAMT,0) - RAMT AVLLIMIT
           FROM
        (SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,CF.ADDRESS,CI.COREBANK,AF.ALTERNATEACCT ,CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt, CI.DFODAMT, AF.BRATIO,AF.ACTYPE, NVL(AP.AAMT,0) AAMT , CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,AF.MRCRLIMITMAX,AF.CLAMTLIMIT
         FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID
         INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
         LEFT JOIN (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y' AND AFACCTNO = V_AFACCTNO GROUP BY AFACCTNO) AP ON TRIM(AF.ACCTNO) = TRIM(AP.ACCTNO)
         WHERE AF.ACCTNO=V_AFACCTNO) A
         left join
         (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) B
        on A.ACCTNO=B.AFACCTNO
        LEFT JOIN
        (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
        on se.afacctno=a.acctno
        LEFT JOIN
        (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = V_AFACCTNO group by afacctno) adv
           on adv.afacctno=a.acctno ;
    else
        --Tai khoan margin join theo group
        SELECT sum(nvl(adv.avladvance,0)) AAMT,sum(TOTAL-NVL(SECUREAMT,0)) TOTAL,
                  LEAST(SUM((NVL(A.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(adv.avladvance,0)))
                            ,sum(NVL(ADV.AVLADVANCE,0) + greatest(NVL(A.MRCRLIMITMAX,0)+NVL(A.MRCRLIMIT,0)-DFODAMT,0)))
                       + sum(BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) PP,
                  sum(NVL(ADV.AVLADVANCE,0) + NVL(A.MRCRLIMITMAX,0)+NVL(A.MRCRLIMIT,0)-DFODAMT + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (OVERAMT, 0)-NVL(SECUREAMT,0) - RAMT) AVLLIMIT
            into v_aamt, v_total, v_pp,v_AVLLIMIT
        FROM
            (SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME, CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt,CI.DFODAMT, AF.BRATIO,AF.ACTYPE,
             CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,AF.MRCRLIMITMAX
             FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID and af.groupleader=v_groupleader
             INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
             LEFT JOIN (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT
                            FROM STSCHD
                            WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y'
                            GROUP BY AFACCTNO) AP ON AF.ACCTNO = AP.ACCTNO
             ) A
             left join
             (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) B
            on A.ACCTNO=B.AFACCTNO
            LEFT JOIN
            (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
            on se.afacctno=a.acctno
            LEFT JOIN
           (select sum(aamt) aamt,sum(depoamt) avladvance,V_AFACCTNO afacctno from v_getAccountAvlAdvance b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader group by v_groupleader) adv
            on adv.afacctno=a.acctno ;

        OPEN PV_REFCURSOR FOR
        SELECT v_margintype MRTYPE,v_isPPUsed ISPPUSED,ACCTNO,LICENSE,CUSTID,CUSTODYCD,FULLNAME,ADDRESS,v_margindesc TERM,COREBANK,ALTERNATEACCT,
          BALANCE- ODAMT-NVL(ADVAMT,0)-NVL(SECUREAMT,0) BALANCE,BRATIO,ACTYPE,
          v_aamt aamt, v_total total, greatest(A.ADVANCELINE + v_pp,0) pp,A.ADVANCELINE +  v_AVLLIMIT AVLLIMIT
           FROM
        (SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,CF.ADDRESS,CI.COREBANK,AF.ALTERNATEACCT, CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt, AF.BRATIO,AF.ACTYPE, NVL(AP.AAMT,0) AAMT , CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,AF.MRCRLIMITMAX
         FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID
         INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
         LEFT JOIN (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y' AND AFACCTNO = V_AFACCTNO GROUP BY AFACCTNO) AP ON TRIM(AF.ACCTNO) = TRIM(AP.ACCTNO)
         WHERE AF.ACCTNO=V_AFACCTNO) A
         left join
         (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) B
        on A.ACCTNO=B.AFACCTNO

        LEFT JOIN
        (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
        on se.afacctno=a.acctno;
    end if;

EXCEPTION
    WHEN others THEN
        return;
END;
 
 
 
 
/
