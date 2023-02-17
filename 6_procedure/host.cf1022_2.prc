SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1022_2" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_CIACCTNO      IN       VARCHAR2,
   PV_TLID          IN       VARCHAR2,
   PV_TLGROUP       IN       VARCHAR2,
   PV_TLTXCD        IN       VARCHAR2
)
IS
    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_BRID              VARCHAR2(4);

    V_FROMDATE          DATE;
    V_TODATE            DATE;
    V_STRCUSTODYCD      VARCHAR2(40);
    V_STRCIACCTNO       VARCHAR2(40);
    V_STRTLID           VARCHAR2(40);
    V_STRTLGROUP        VARCHAR2(40);
    V_STRTLTXCD         VARCHAR2(40);

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    V_BRID := pv_BRID;

    V_FROMDATE  := to_date(F_DATE,'dd/mm/rrrr');
    V_TODATE    := to_date(T_DATE,'dd/mm/rrrr');

    if(PV_CUSTODYCD is null or PV_CUSTODYCD = 'ALL')then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := upper(PV_CUSTODYCD);
    end if;

    if(PV_CIACCTNO is null or PV_CIACCTNO = 'ALL')then
        V_STRCIACCTNO := '%';
    else
        V_STRCIACCTNO := PV_CIACCTNO;
    end if;

    if(PV_TLID is null or PV_TLID = 'ALL')then
        V_STRTLID := '%';
    else
        V_STRTLID := PV_TLID;
    end if;

    if(PV_TLGROUP is null or PV_TLGROUP = 'ALL')then
        V_STRTLGROUP := '%';
    else
        V_STRTLGROUP := PV_TLGROUP;
    end if;

    if(PV_TLTXCD is null or UPPER(PV_TLTXCD) = 'ALL')then
        V_STRTLTXCD := '%';
    else
        V_STRTLTXCD := PV_TLTXCD;
    end if;


    OPEN PV_REFCURSOR FOR
    SELECT DISTINCT nvl(TL.CUSTODYCD,'') CUSTODYCD, TL.MSGACCT ACCTNO,
        TL.TLTXCD, tl.txdesc TXDESC, TL.TXDATE, TL.BUSDATE, TL.TLNAME TLNAME,
        TL.TXNUM, nvl(setr.symbol,'') symbol,
        CASE WHEN TL.TLTXCD IN ('1115','1121','1133','1134','1136','2676') THEN TL.MSGAMT ELSE nvl(CITR.AMT,0) END ciamt,
        CASE WHEN TL.TLTXCD IN ('8876','8877') THEN TL.MSGAMT ELSE  nvl(seTR.AMT,0) end seamt, TL.TXTIME, TL.OTLNAME
    FROM
    (
    SELECT AF.acctno, CF.custodycd
    FROM AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
    WHERE AF.custid = CF.custid
    ) CF,
    (
    SELECT (case when TL.tltxcd LIKE '22%'
            THEN SUBSTR(REPLACE(tl.MSGACCT,'.',''),1,10) ELSE REPLACE(tl.MSGACCT,'.','') END) AFACCTNO,
        T.TLTXCD, Tl.txdesc, TL.TXDATE, TL.TXNUM, TLP.tlname TLNAME, TLP2.tlname OTLNAME,
        NVL(CF.CUSTODYCD,TL.cfcustodycd) CUSTODYCD,NVL(TL.MSGAMT,0) MSGAMT, TL.MSGACCT, TL.BUSDATE, TL.TXTIME
    FROM TLLOG TL, TLTX T, tlprofiles TLP, tlprofiles TLP2, CFMAST CF
    WHERE TL.TLTXCD = T.TLTXCD AND TL.tlid = TLP.tlid(+) AND TL.offid = TLP2.tlid(+)
        AND(case when TL.tltxcd in ('0017','0018','0012','0090','0010','0059','0033','0067')
            THEN REPLACE(tL.MSGACCT,'.','') ELSE 'DDDD' END) = CF.custid(+)
        AND TL.TLTXCD NOT  IN ('0067','0059')
        AND TL.TXDATE >= V_FROMDATE  AND TL.TXDATE <= V_TODATE
        AND TL.TLID LIKE V_STRTLID AND TL.TLTXCD LIKE V_STRTLTXCD
        and tlp.tlgroup like V_STRTLGROUP
        and tlp.tlname <> 'RootUser'
    UNION ALL
    SELECT (case when TL.tltxcd LIKE '22%'
            THEN SUBSTR(REPLACE(tl.MSGACCT,'.',''),1,10) ELSE REPLACE(tl.MSGACCT,'.','') END) AFACCTNO,
        T.TLTXCD, T.txdesc, TL.TXDATE, TL.TXNUM, TLP.tlname TLNAME, TLP2.tlname OTLNAME,
        NVL(CF.CUSTODYCD,TL.cfcustodycd) CUSTODYCD, NVL(TL.MSGAMT,0) MSGAMT, TL.MSGACCT, TL.BUSDATE, TL.TXTIME
    FROM TLLOGALL TL, TLTX T, tlprofiles TLP, tlprofiles TLP2, CFMAST CF
    WHERE TL.TLTXCD = T.TLTXCD AND TL.tlid = TLP.tlid(+) AND TL.offid = TLP2.tlid(+)
        AND(case when TL.tltxcd in ('0017','0018','0012','0090','0010','0059','0033','0067')
            THEN REPLACE(tL.MSGACCT,'.','') ELSE 'DDDD' END) = CF.custid(+)
                 AND TL.TLTXCD NOT  IN ('0067','0059')
        AND TL.TXDATE >= V_FROMDATE  AND TL.TXDATE <= V_TODATE
        AND TL.TLID LIKE V_STRTLID AND TL.TLTXCD LIKE V_STRTLTXCD
        and tlp.tlgroup like V_STRTLGROUP
        and tlp.tlname <> 'RootUser'

          UNION ALL

        SELECT (case when TL.tltxcd LIKE '22%'
                THEN SUBSTR(REPLACE(tl.MSGACCT,'.',''),1,10) ELSE REPLACE(tl.MSGACCT,'.','') END) AFACCTNO,
            T.TLTXCD, T.txdesc, TL.TXDATE, TL.TXNUM, TLP.tlname TLNAME, TLP2.tlname OTLNAME,
            NVL(CF.CUSTODYCD,TL.cfcustodycd) CUSTODYCD, NVL(TL.MSGAMT,0) MSGAMT, TL.MSGACCT, TL.BUSDATE, TL.TXTIME
        FROM VW_TLLOG_ALL TL, TLTX T, tlprofiles TLP, tlprofiles TLP2, CFMAST CF, VW_TLLOGFLD_ALL FLD
        WHERE TL.TLTXCD = T.TLTXCD AND TL.tlid = TLP.tlid(+) AND TL.offid = TLP2.tlid(+)
            AND(case when TL.tltxcd in ('0059','0067')
                THEN REPLACE(tL.MSGACCT,'.','') ELSE 'DDDD' END) = CF.custid(+)
            AND TL.TXNUM=FLD.TXNUM
            AND TL.TXDATE=FLD.TXDATE
            AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            AND TL.TXDATE >= V_FROMDATE  AND TL.TXDATE <= V_TODATE
            AND TL.TLTXCD IN ('0067','0059')
            AND TL.TLID LIKE V_STRTLID AND TL.TLTXCD LIKE V_STRTLTXCD
            and tlp.tlgroup like V_STRTLGROUP
            and tlp.tlname <> 'RootUser'
            and tlp.tlname <> 'USERONLINE'
    ) TL,
    /*(
     select custodycd, custid, txnum, txdate, acctno, sum(namt) amt from vw_citran_gen
        where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
        and FIELD= 'BALANCE'
     group by  custodycd, custid, txnum, txdate, acctno
    ) CITR,
    (
     select custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
        where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                and FIELD= 'TRADE'
     group by  custodycd, custid, txnum, txdate, acctno, symbol
    ) SETR*/
    (
     select custodycd, custid, txnum, txdate, acctno, sum(namt) amt from vw_citran_gen
        where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
        and FIELD= 'BALANCE'
       /* AND CASE WHEN TLTXCD IN ('1153') AND TXDESC LIKE '%Tele%' THEN 0
           WHEN TLTXCD IN ('1111','1130') THEN 0
           ELSE 1 END >0*/
        and CASE WHEN tltxcd = '1153' AND txtype = 'C' THEN 1 ELSE 0 END >0
     group by  custodycd, custid, txnum, txdate, acctno
    ) CITR,
    (
     select custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
        where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                and FIELD= 'TRADE'
     group by  custodycd, custid, txnum, txdate, acctno, symbol
     UNION ALL
      select custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
        where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                and FIELD= 'DEPOSIT'
              AND tltxcd in('2240')
     group by  custodycd, custid, txnum, txdate, acctno, symbol
     UNION ALL
      select custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
        where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                and FIELD= 'BLOCKED'
              AND tltxcd in('2244')
     group by  custodycd, custid, txnum, txdate, acctno, symbol


    ) SETR
    WHERE TL.AFACCTNO = CF.acctno(+)
    AND TL.TXDATE = CITR.TXDATE(+) AND TL.TXNUM = CITR.TXNUM(+)
    AND TL.TXDATE = SETR.TXDATE(+) AND TL.TXNUM = SETR.TXNUM(+)
    and nvl(CF.custodycd,'DDD') LIKE V_STRCUSTODYCD
    and nvl(CF.acctno,'DDD') LIKE V_STRCIACCTNO
    and tl.tltxcd not in ('1171')
--    and nvl(CITR.AMT,0) + nvl(seTR.AMT,0)>0
    order by tl.txdate, tl.txnum
        ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
