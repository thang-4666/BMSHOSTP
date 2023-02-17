SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0054" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BBRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   O_DATE         IN       VARCHAR2,
   D_DATE         IN       VARCHAR2,
   PV_NUM      IN          VARCHAR2
   )
IS
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRI_TYPE      VARCHAR2 (5);
   V_I_DATE       DATE;
   V_F_DATE       DATE;
   V_T_DATE       DATE;
   v_CUSTODYCD    varchar2(100);
   v_AFAcctno     varchar2(100);
   V_STRNUM       VARCHAR2(20);
   l_BRID_FILTER        VARCHAR2(50);

   BEGIN

   V_STROPTION := OPT;

    IF (V_STROPTION = 'A') THEN
      l_BRID_FILTER := '%';
    ELSif (V_STROPTION = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = BBRID;
    else
        l_BRID_FILTER := BBRID;
    END IF;


    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL) THEN
        v_CUSTODYCD := PV_CUSTODYCD;
    ELSE
        v_CUSTODYCD  := '%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '' OR PV_AFACCTNO <> NULL) THEN
        v_AFAcctno := PV_AFACCTNO;
    ELSE
        v_AFAcctno  := '%';
    END IF;

   IF (PV_NUM ='ALL') THEN
      V_STRNUM :='%';
   ELSE
      V_STRNUM := PV_NUM;
   END IF;

    V_I_DATE := TO_DATE (I_DATE,'DD/MM/RRRR');

    if(O_DATE is null) then
        V_F_DATE := TO_DATE (I_DATE,'DD/MM/RRRR');
    else
        V_F_DATE := TO_DATE (O_DATE,'DD/MM/RRRR');
    end if;

    if(D_DATE is null) then
        V_T_DATE := TO_DATE (I_DATE,'DD/MM/RRRR');
    else
        V_T_DATE := TO_DATE (D_DATE,'DD/MM/RRRR');
    end if;
/*V_F_DATE := TO_DATE (F_DATE,'DD/MM/RRRR');
V_T_DATE := TO_DATE (T_DATE,'DD/MM/RRRR');*/

OPEN PV_REFCURSOR
FOR

SELECT case when a.rrtype = 'C' then 'BSC' else cf.shortname end RRNAME, a.* FROM (

    SELECT LNM.RRTYPE,LNM.CUSTBANK,CF.CUSTODYCD, AF.ACCTNO AFACCTNO, LNM.OPNDATE, df.DUEDATE , to_char(df.AUTOID) LNACCTNO
    , SB.SYMBOL, DF.DFQTTY + NVL(ODM.OTHERQTTY,0) - NVL(ODM.SELLQTTY,0) TRADE  ,
    cf.fullname
    FROM DFTYPE DFT, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0) CF, vw_lnmast_all LNM, SBSECURITIES SB,
    (

    SELECT LNACCTNO, ACTYPE, AFACCTNO,LNS.OVERDUEDATE DUEDATE, LNS.AUTOID, CODEID, SUM(DFQTTY) DFQTTY FROM DFMAST df, vw_lnschd_all LNS
        where df.lnacctno = lns.acctno and lns.reftype = 'P'
    GROUP BY LNACCTNO,ACTYPE, AFACCTNO,OVERDUEDATE,lns.autoid, CODEID

    ) DF,

    (
        SELECT afacctno,autoid,codeid,  SUM(OTHERQTTY) OTHERQTTY, SUM(sellqtty) sellqtty FROM
            (


                select df.groupid,df.afacctno,lnm.autoid, df.codeid, sum(case when ap.txtype = 'D' then namt else -namt end ) OTHERQTTY, 0 SELLQTTY
                    from vw_dftran_all tran, apptx ap, vw_dfmast_all df, vw_lnschd_all lnm
                    where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
                    and ap.field in ('DFQTTY') and ap.txtype in ('C','D')
                    and df.acctno = tran.acctno and df.lnacctno = lnm.acctno
                    and lnm.REFTYPE = 'P'
                    and tran.txdate > V_I_DATE
                group by df.groupid,df.afacctno,lnm.autoid, df.codeid

                UNION ALL

                SELECT ACCTREF GROUPID, V.AFACCTNO, lns.autoid, CODEID, -SUM(NAMT) OTHERQTTY,0 SELLQTTY   FROM vw_setran_gen V, DFGROUP DF, vw_lnschd_all lns
                    WHERE TLTXCD = '2673' AND TXCD = '0065'
                    and v.txdate>V_I_DATE
                    and df.lnacctno = lns.acctno and lns.reftype = 'P'
                    AND V.ACCTREF = DF.GROUPID
                GROUP BY ACCTREF , V.AFACCTNO, lns.autoid, V.CODEID

                  UNION ALL

                 SELECT v.groupid, v.afacctno,lns.autoid, v.codeid, 0 OTHERQTTY, sum(od.execqtty) sellqtty FROM vw_dfmast_all V, (
                       select odm.txdate ,od.orderid, od.refid, od.type, od.ordernum, od.qtty, od.deltd, od.status, -od.execqtty execqtty from odmapext od, odmast odm where od.deltd <>'Y' and od.execqtty >0 and od.orderid=odm.orderid
                            and odm.txdate = V_I_DATE
                       ) OD, vw_lnschd_all lns
                   WHERE v.acctno = od.refid
                   and v.lnacctno = lns.acctno and lns.reftype = 'P'
                   group by v.groupid, v.afacctno,lns.autoid, v.codeid

            )  GROUP BY afACCTNO,autoid,codeid
    ) ODM
    WHERE DF.ACTYPE=DFT.ACTYPE AND DF.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
    and DF.LNACCTNO = LNM.ACCTNO
    AND DF.CODEID = SB.CODEID
    AND DFT.ISVSD='Y'
    and DF.afACCTNO = ODM.afACCTNO (+)
    and df.codeid = odm.codeid (+)
    and df.autoid = odm.autoid (+)
    AND (case when O_DATE is null then V_F_DATE else LNM.OPNDATE end ) >= V_F_DATE
    AND (case when D_DATE is null then V_T_DATE else df.DUEDATE end ) <= V_T_DATE
    AND CF.CUSTODYCD LIKE v_CUSTODYCD
    AND AF.ACCTNO LIKE v_AFAcctno
    AND LNM.ACCTNO LIKE V_STRNUM
    AND case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(AF.ACCTNO,1,4)) end  <> 0

) a, cfmast cf
where
a.custbank = cf.custid(+)
and a.TRADE > 0
order by RRNAME, a.custodycd, a.afacctno, a.lnacctno
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
