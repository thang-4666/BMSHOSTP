SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1022 (
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
   PV_TLTXCD        IN       VARCHAR2,
    I_BRIDGD       IN       VARCHAR2
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
    V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);

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
      V_BRNAME   :=  ' To?c?ty ';
   END IF;

    OPEN PV_REFCURSOR
       FOR
SELECT * FROM(
    SELECT DISTINCT nvl(TL.CUSTODYCD,CF.CUSTODYCD) CUSTODYCD, TL.MSGACCT ACCTNO, CF.BRID BRID, NVL(A0.CDCONTENT,'')PRODUC,
        TL.TLTXCD, tl.txdesc TXDESC, TL.TXDATE, TL.BUSDATE, TL.TLNAME TLNAME,
        TL.TXNUM, nvl(setr.symbol,'') symbol,
        CASE WHEN TL.TLTXCD IN ('1115','1121','1133','1134','1136','1185','1126','1127') THEN TL.MSGAMT ELSE nvl(CITR.AMT,0) END ciamt,
        nvl(seTR.AMT,0) seamt,
        TL.TXTIME, TL.OTLNAME, NVL(setr.status,'') STATUS
    FROM
    (
        SELECT AF.acctno, CF.custodycd, nvl(cf.BRID,'000') BRID
        FROM AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE AF.custid = CF.custid
    ) CF,
    (
        SELECT (case when TL.tltxcd LIKE '22%'
                THEN SUBSTR(REPLACE(tl.MSGACCT,'.',''),1,10) ELSE REPLACE(tl.MSGACCT,'.','') END) AFACCTNO,
            T.TLTXCD,NVL(Tl.txdesc,T.TXDESC) TXDESC, TL.TXDATE, TL.TXNUM, TLP.tlname TLNAME, TLP2.tlname OTLNAME,
            NVL(CF.CUSTODYCD,TL.cfcustodycd) CUSTODYCD, NVL(TL.MSGAMT,0) MSGAMT, TL.MSGACCT, TL.BUSDATE, TL.TXTIME
        FROM TLLOG TL, TLTX T, tlprofiles TLP, tlprofiles TLP2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE TL.TLTXCD = T.TLTXCD AND TL.tlid = TLP.tlid(+) AND TL.offid = TLP2.tlid(+)
            AND(case when TL.tltxcd in ('0017','0018','0012','0090','0010','0059','0033','0067')
                THEN REPLACE(tL.MSGACCT,'.','') ELSE 'DDDD' END) = CF.custid(+)
            AND TL.TXDATE >= V_FROMDATE  AND TL.TXDATE <= V_TODATE
             AND TL.TLTXCD LIKE V_STRTLTXCD
            and tlp.tlgroup like V_STRTLGROUP
             AND TL.TLTXCD NOT  IN ('0067','0059')
            and tlp.tlname <> 'RootUser'
            and tlp.tlname <> 'USERONLINE'
        UNION ALL

        SELECT (case when TL.tltxcd LIKE '22%'
                THEN SUBSTR(REPLACE(tl.MSGACCT,'.',''),1,10) ELSE REPLACE(tl.MSGACCT,'.','') END) AFACCTNO,
            T.TLTXCD,NVL(Tl.txdesc,T.TXDESC) TXDESC, TL.TXDATE, TL.TXNUM, TLP.tlname TLNAME, TLP2.tlname OTLNAME,
            NVL(CF.CUSTODYCD,TL.cfcustodycd) CUSTODYCD, NVL(TL.MSGAMT,0) MSGAMT, TL.MSGACCT, TL.BUSDATE, TL.TXTIME
        FROM TLLOGALL TL, TLTX T, tlprofiles TLP, tlprofiles TLP2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE TL.TLTXCD = T.TLTXCD AND TL.tlid = TLP.tlid(+) AND TL.offid = TLP2.tlid(+)
            AND(case when TL.tltxcd in ('0017','0018','0012','0090','0010','0059','0033','0067')
                THEN REPLACE(tL.MSGACCT,'.','') ELSE 'DDDD' END) = CF.custid(+)
            AND TL.TXDATE >= V_FROMDATE  AND TL.TXDATE <= V_TODATE
             AND TL.TLTXCD LIKE V_STRTLTXCD
            and tlp.tlgroup like V_STRTLGROUP
             AND TL.TLTXCD NOT  IN ('0067','0059')
            and tlp.tlname <> 'RootUser'
            and tlp.tlname <> 'USERONLINE'
      UNION ALL

        SELECT (case when TL.tltxcd LIKE '22%'
                THEN SUBSTR(REPLACE(tl.MSGACCT,'.',''),1,10) ELSE REPLACE(tl.MSGACCT,'.','') END) AFACCTNO,
            T.TLTXCD, NVL(Tl.txdesc,T.TXDESC) TXDESC, TL.TXDATE, TL.TXNUM, TLP.tlname TLNAME, TLP2.tlname OTLNAME,
            NVL(CF.CUSTODYCD,TL.cfcustodycd) CUSTODYCD, NVL(TL.MSGAMT,0) MSGAMT, TL.MSGACCT, TL.BUSDATE, TL.TXTIME
        FROM VW_TLLOG_ALL TL, TLTX T, tlprofiles TLP, tlprofiles TLP2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, VW_TLLOGFLD_ALL FLD
        WHERE TL.TLTXCD = T.TLTXCD AND TL.tlid = TLP.tlid(+) AND TL.offid = TLP2.tlid(+)
            AND(case when TL.tltxcd in ('0059','0067')
                THEN REPLACE(tL.MSGACCT,'.','') ELSE 'DDDD' END) = CF.custid(+)
            AND TL.TXNUM=FLD.TXNUM
            AND TL.TXDATE=FLD.TXDATE
            AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
            AND TL.TXDATE >= V_FROMDATE  AND TL.TXDATE <= V_TODATE
            AND TL.TLTXCD IN ('0067','0059')
             AND TL.TLTXCD LIKE V_STRTLTXCD
            and tlp.tlgroup like V_STRTLGROUP
            and tlp.tlname <> 'RootUser'
            and tlp.tlname <> 'USERONLINE'
    ) TL,
    (
         select tr.custodycd, tr.custid, tr.txnum, tr.txdate, tr.acctno, sum(tr.namt) amt
         from vw_citran_gen tr, afmast af
            where tr.TXDATE >= V_FROMDATE  AND tr.TXDATE <= V_TODATE
            and tr.FIELD= 'BALANCE'
            AND CASE
                WHEN tr.TLTXCD IN ('1153') AND tr.TXDESC LIKE '%Tele%' THEN 0
                WHEN tr.TLTXCD IN ('1111','1130') THEN 0
                 WHEN tr.tltxcd = '1153' AND tr.TXCD <> '0012' THEN 0
                WHEN tr.TLTXCD = '1120' AND tr.TXCD <> '0012' THEN 0
           ELSE 1 END > 0
           and tr.acctno = af.acctno and af.actype <> '0000'
         group by  tr.custodycd, tr.custid, tr.txnum, tr.txdate, tr.acctno
    ) CITR,
    (
         select 'TRADE' status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'TRADE'
         group by  custodycd, custid, txnum, txdate, acctno, symbol
         UNION ALL
         SELECT 'TRADE' status, TL.custodycd, TL.custid, TL.txnum, TL.txdate, TL.acctno, TL.symbol, sum(TR.depotrade) amt
         FROM sedeposit TR, vw_SETran_gen TL
         WHERE TR.txdate >= V_FROMDATE AND TR.TXDATE <= V_TODATE
            AND TR.TXNUM = TL.TXNUM AND TR.TXDATE = TL.TXDATE
            AND TR.depotrade <> 0 -- 2240
         GROUP BY TL.custodycd, TL.custid, TL.txnum, TL.txdate, TL.acctno, TL.symbol
        UNION ALL
        SELECT 'BLOCKED' status, TL.custodycd, TL.custid, TL.txnum, TL.txdate, TL.acctno, TL.symbol, sum(TR.depoblock) amt
         FROM sedeposit TR, vw_SETran_gen TL
         WHERE TR.txdate >= V_FROMDATE AND TR.TXDATE <= V_TODATE
            AND TR.TXNUM = TL.TXNUM AND TR.TXDATE = TL.TXDATE
            AND TR.depoblock <> 0 -- 2240
         GROUP BY TL.custodycd, TL.custid, TL.txnum, TL.txdate, TL.acctno, TL.symbol
         UNION ALL
         select null status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'DEPOSIT'
                  AND tltxcd = '2230'
         group by  custodycd, custid, txnum, txdate, acctno, symbol
         UNION ALL
          select 'BLOCKED' status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD= 'BLOCKED'
                  AND tltxcd = '2244'
         group by  custodycd, custid, txnum, txdate, acctno, symbol
         union all
         select distinct null status, cf.custodycd, cf.custid, tl.txnum, tl.txdate,se.acctno, sb.symbol, se.qtty amt
            from semortage se, vw_tllog_all tl, semast  sem, cfmast cf, sbsecurities sb, afmast af
            where tl.TXDATE >= V_FROMDATE  AND tl.TXDATE <= V_TODATE
                and se.txdate = tl.txdate and se.txnum = tl.txnum
                and se.acctno = sem.acctno and sem.codeid = sb.codeid
                and se.afacctno = af.acctno and af.custid = cf.custid
                 AND se.tltxcd = '2233'
         union all
         select 'BLOCKED' status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'BLOCKWITHDRAW'
                  AND tltxcd in ('2266','2201')
         group by  custodycd, custid, txnum, txdate, acctno, symbol
         union all
         select 'TRADE' status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'WITHDRAW'
                  AND tltxcd in ('2266','2201')
         group by  custodycd, custid, txnum, txdate, acctno, symbol
         union all
         select null status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'MORTAGE'
                  AND tltxcd = '2251'
         group by  custodycd, custid, txnum, txdate, acctno, symbol
         union all
         select 'TRADE' status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'DTOCLOSE'
                  AND tltxcd = '2248'
         group by custodycd, custid, txnum, txdate, acctno, symbol
         union all
         select 'BLOCKED' status, custodycd, custid, txnum, txdate, acctno, symbol, sum(namt) amt from vw_SETran_gen
            where TXDATE >= V_FROMDATE  AND TXDATE <= V_TODATE
                    and FIELD = 'BLOCKDTOCLOSE'
                  AND tltxcd = '2248'
         group by  custodycd, custid, txnum, txdate, acctno, symbol
    ) SETR, vw_odmast_all OD, AFMAST AF, AFTYPE AFT, ALLCODE A0
    WHERE TL.AFACCTNO = CF.acctno(+)
    AND TL.TXDATE = CITR.TXDATE(+) AND TL.TXNUM = CITR.TXNUM(+)
    AND TL.TXDATE = SETR.TXDATE(+) AND TL.TXNUM = SETR.TXNUM(+)
    AND TL.TXDATE = OD.TXDATE (+) AND TL.TXNUM = OD.txnum (+)
    AND NVL(OD.VIA,'O') NOT LIKE '%T%'
 --   and nvl(CF.custodycd,'DDD') LIKE V_STRCUSTODYCD
   -- AND  nvl(TL.CUSTODYCD,CF.CUSTODYCD) LIKE V_STRCUSTODYCD
    AND AF.ACTYPE=AFT.ACTYPE AND AF.ACCTNO=TL.AFACCTNO
    AND cf.BRID like V_I_BRIDGD
    AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
    and nvl(CF.acctno,'DDD') LIKE V_STRCIACCTNO
/*    and CASE WHEN TL.TLTXCD IN ('1115','1121','1133','1134','1136') THEN TL.MSGAMT ELSE
        nvl(CITR.AMT,0) END + nvl(seTR.AMT,0) > 0*/
    AND TL.TLTXCD NOT IN ('6690','6691','2268','3394'/*,'0049'*/)

    ) WHERE NVL(CUSTODYCD,'AAA') LIKE V_STRCUSTODYCD
    order by txdate, txnum
        ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
