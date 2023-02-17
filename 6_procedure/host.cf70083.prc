SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf70083 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   IPADDRESS      IN       VARCHAR2)
IS
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRPV_CUSTODYCD  VARCHAR2(20);
   V_INBRID           VARCHAR2(4);
   V_STRBRID          VARCHAR2 (50);
   V_STRIPADDRESS     VARCHAR2 (50);
   v_fromdate         DATE;
   v_todate           DATE;
BEGIN
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

    v_fromdate := to_date(F_DATE,'DD/MM/RRRR');
    v_todate   := to_date(T_DATE,'DD/MM/RRRR');
    V_STRIPADDRESS := SUBSTR(IPADDRESS,1,6);

    OPEN PV_REFCURSOR FOR
    with CUSTLIST AS (
        SELECT CF.BRID, LOG.IPADDRESS IPADDRESS, CF.CUSTODYCD, SUM(OD.MATCHAMT) MATCHAMT
        FROM CFMAST CF, LOGPLACEORDER LOG, VW_ODMAST_ALL OD, AFMAST AF
        WHERE  OD.AFACCTNO = AF.ACCTNO
        AND AF.CUSTID = CF.CUSTID
        AND OD.foacctno = LOG.txnum
        and od.txdate between v_fromdate and v_todate
        GROUP BY CF.BRID, LOG.IPADDRESS, CF.CUSTODYCD
    )
    SELECT BR.brname, NVL(TIP.CUSTODYCD,'') CUSTODYCD_TIP, NVL(TIP.MATCHAMT,'') MATCHAMT_TIP,
        NVL(KIP.CUSTODYCD,'') CUSTODYCD_KIP, SUM(TIP.cnt) CNT_TIP, SUM(KIP.cnt) CNT_KIP, SUM(TIP.SUMMATCHAMT) SUMMATCHAMT_TIP
    FROM brgrp BR,
    (
        select BRID,
            LISTAGG(CUSTODYCD,chr(10)) WITHIN GROUP (ORDER BY MATCHAMT DESC) CUSTODYCD,
            LISTAGG(trim(to_char(MATCHAMT,'9,999,9999,999,999,9999,9999,999,999')),chr(10)) WITHIN GROUP (ORDER BY MATCHAMT DESC) MATCHAMT,
            SUM(MATCHAMT) SUMMATCHAMT,
            count(1) cnt
        from
        (
            select mt.BRID,mt.CUSTODYCD, mt.MATCHAMT, ROW_NUMBER () OVER(PARTITION BY BRID ORDER BY cnt desc, MATCHAMT DESC) row_num
            from (
                select c.BRID, c.custodycd, max(ip.IPADDRESS) MIPADDRESS, sum(ip.cnt) cnt, sum(c.MATCHAMT) MATCHAMT
                from CUSTLIST c,
                    (
                        SELECT *
                        FROM
                        (
                            SELECT IPADDRESS, COUNT(*) CNT
                            FROM CUSTLIST LS
                            WHERE SUBSTR(replace(LS.IPADDRESS,'.',''),1,6) like V_STRIPADDRESS
                            GROUP BY IPADDRESS
                        )
                        where CNT > 1
                    )ip
                where c.IPADDRESS = ip.IPADDRESS
                group by c.BRID, c.custodycd
            )mt
        )
        where row_num <= 30
        group by BRID
    ) TIP,
    (
        select BRID,
            LISTAGG(CUSTODYCD,chr(10)) WITHIN GROUP (ORDER BY MATCHAMT DESC) CUSTODYCD,
            LISTAGG(trim(to_char(MATCHAMT,'9,999,9999,999,999,9999,9999,999,999')),chr(10)) WITHIN GROUP (ORDER BY MATCHAMT DESC) MATCHAMT,
            SUM(MATCHAMT) SUMMATCHAMT,
            count(1) cnt
        from
        (
            select mt.BRID,mt.CUSTODYCD, mt.MATCHAMT, ROW_NUMBER () OVER(PARTITION BY BRID ORDER BY cnt desc, MATCHAMT DESC) row_num
            from (
                select c.BRID, c.custodycd, max(ip.IPADDRESS) MIPADDRESS, sum(ip.cnt) cnt, sum(c.MATCHAMT) MATCHAMT
                from CUSTLIST c,
                    (
                        SELECT *
                        FROM
                        (
                            SELECT IPADDRESS, COUNT(*) CNT
                            FROM CUSTLIST LS
                            WHERE SUBSTR(replace(LS.IPADDRESS,'.',''),1,6) NOT like V_STRIPADDRESS
                            GROUP BY IPADDRESS
                        )
                        where CNT > 1
                    )ip
                where c.IPADDRESS = ip.IPADDRESS
                group by c.BRID, c.custodycd
            )mt
        )
        where row_num <= 30
        group by BRID
    ) KIP
    WHERE BR.brid = TIP.BRID (+)
        AND BR.brid = KIP.BRID (+)
    group by BR.brname, TIP.CUSTODYCD, TIP.MATCHAMT, KIP.CUSTODYCD;

EXCEPTION
   WHEN OTHERS THEN
    PLOG.ERROR('CF70083.ERROR:'||SQLERRM || dbms_utility.format_error_backtrace);
   RETURN;
End;
/
