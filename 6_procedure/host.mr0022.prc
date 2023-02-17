SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0022" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   PV_TLTXTYPE    IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

   V_IDATE           DATE; --ngay lam viec gan ngay indate nhat
   v_CurrDate        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);

   v_strcustodycd   VARCHAR2(20);
   v_BRID           VARCHAR2(20);
   v_strAFTYPE      VARCHAR2(20);
   V_FROM_DATE      DATE;
   V_TO_DATE        DATE;
   V_STRTLTXTYPE    VARCHAR2(20);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS


    if(upper(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD is null) then
        v_strcustodycd := '%';
    else
        v_strcustodycd := UPPER(PV_CUSTODYCD);
    end if ;
    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
        v_BRID := '%';
    else
        v_BRID := UPPER(I_BRID);
    end if ;
    if(upper(PV_AFTYPE) = 'ALL') then
        v_strAFTYPE := '%';
    else
        v_strAFTYPE := PV_AFTYPE;
    end if ;
    if (PV_TLTXTYPE is null or upper(PV_TLTXTYPE) = 'ALL') then
        V_STRTLTXTYPE := '%';
    else
        V_STRTLTXTYPE := PV_TLTXTYPE;
    end if;

    V_FROM_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');
    V_TO_DATE   := TO_DATE(T_DATE,'DD/MM/RRRR');
---    SELECT max(sbdate) V_IDATE V_FDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(F_DATE,'DD/MM/RRRR');
---   SELECT max(sbdate) INTO v_TDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(T_DATE,'DD/MM/RRRR');
----   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
---     SELECT PV_AFTYPE FROM DUAL
---    ;

    select (CASE WHEN upper(PV_AFTYPE) = 'ALL' THEN 'ALL' else PV_AFTYPE end)  INAFTYPE, mst.brname,
        mst.custodycd, mst.fullname, mst.typename, mst.grpname, (mst.MRCRLIMITMAX) MRCRLIMITMAX,
        tr.TXDATE, tr.tlname, MST.mrtype, TR.namt
    from
    (
        select br.brname, CF.custodycd, CF.fullname, AFT.typename, gr.grpname, af.MRCRLIMITMAX, af.acctno, mrt.mrtype
        from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, aftype aft, brgrp br, tlgroups gr, MRTYPE MRT
        where cf.custid = af.custid and af.actype = aft.actype
            and cf.brid = br.brid and af.careby = gr.grpid
            and aft.mrtype = MRT.actype  and mrt.mrtype in ('S', 'T')
            AND cf.brid LIKE v_BRID AND CF.custodycd LIKE v_strcustodycd
            AND aft.mnemonic like v_strAFTYPE /* ((v_strAFTYPE = 'T3' AND AFT.istrfbuy = 'Y')
                or (upper(v_strAFTYPE) = 'MARGIN' AND AFT.istrfbuy = 'N')
                OR upper(PV_AFTYPE) = 'ALL' )*/
    ) mst ,
    (
        SELECT TR.tlid tlid, TR.TXDATE TXDATE, TR.namt namt, tr.tlname tlname, TR.acctno
        FROM
        (
            SELECT TL.TXNUM, TL.tlid, TL.TXDATE, TR.namt, TR.acctno, tlp.tlname, tl.tltxcd
            FROM aftran TR, TLLOG TL, appmap AP, apptx TX, tlprofiles tlp
            WHERE AP.APPTYPE = TX.APPTYPE AND AP.APPTXCD = TX.TXCD
                AND TX.FIELD in ('MRCRLIMITMAX','ADVANCELINE') AND ap.APPTYPE = 'CF'
                AND TX.txtype = 'C' AND TL.TLTXCD = AP.tltxcd
                AND TR.TXNUM = TL.TXNUM AND TR.TXDATE = TL.TXDATE
                and TR.namt <> 0 and tl.deltd <> 'Y' and tl.tlid = tlp.tlid
                AND TR.TXDATE >= V_FROM_DATE AND TR.TXDATE <= V_TO_DATE
            UNION ALL
            SELECT TL.TXNUM, TL.tlid, TL.TXDATE, TR.namt, TR.acctno, tlp.tlname, tl.tltxcd
            FROM aftranA TR, TLLOGALL TL , appmap AP, apptx TX, tlprofiles tlp
            WHERE AP.APPTYPE = TX.APPTYPE AND AP.APPTXCD = TX.TXCD
                AND TX.FIELD in ('MRCRLIMITMAX','ADVANCELINE') AND TX.APPTYPE = 'CF'
                AND TX.txtype = 'C' AND TL.TLTXCD = AP.tltxcd
                AND TR.TXNUM = TL.TXNUM AND TR.TXDATE = TL.TXDATE
                and TR.namt <> 0 and tl.deltd <> 'Y' and tl.tlid = tlp.tlid
                AND TR.TXDATE >= V_FROM_DATE AND TR.TXDATE <= V_TO_DATE
            UNION ALL
            SELECT '9999999999' TXNUM, mst.MAKER_ID TLID, mst.maker_dt TXDATE, TO_NUMBER(mst.to_value) AMT,
                SUBSTR(mst.child_record_key,11,10) ACCTNO, tlp.tlname,
                (case when mst.column_name = 'MRCRLIMITMAX' then '1813' else '1810' end) tltxcd
            FROM maintain_log mst, tlprofiles tlp
            WHERE mst.column_name in('MRCRLIMITMAX','ADVANCELINE') AND mst.child_table_name = 'AFMAST'
                AND mst.to_value <> 0  and mst.MAKER_ID = tlp.tlid
                AND mst.maker_dt >= V_FROM_DATE AND mst.maker_dt <= V_TO_DATE
        ) TR
        where TR.tltxcd like V_STRTLTXTYPE
    ) TR
    where mst.acctno = tr.acctno
    ;
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
