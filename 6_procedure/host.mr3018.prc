SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3018" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE            IN       VARCHAR2

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
   l_AFACCTNO         VARCHAR2 (20);
   v_IDATE           DATE; --ngay lam viec gan ngay idate nhat
   v_CurrDate        DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION VARCHAR2(10);
   V_STRTLID           VARCHAR2(6);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN




--   V_STRTLID:= TLID;
   V_STROPTION := upper(pv_OPT);
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


 -- END OF GETTING REPORT'S PARAMETERS

   SELECT max(sbdate) INTO v_IDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(I_DATE,'DD/MM/RRRR');
   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';



  -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
        for
    SELECT '1' stt, '' custodycd,'' fullname,txdate ,
  sum( CASE WHEN BRID ='0001' AND TYPECF='BSC' then mramt else 0 end)amt_hs_bsc,
  sum( CASE WHEN BRID ='0001' AND TYPECF='DHT' then mramt else 0 end) amt_hs_dht,
  sum( CASE WHEN BRID ='0101' AND TYPECF='BSC' then mramt else 0 end) amt_cn_bsc,
  sum( CASE WHEN BRID ='0101' AND TYPECF='DHT' then mramt else 0 end) amt_cn_dht
       FROM (
        SELECT  * FROM (
            select v.custodycd,max(CF.FULLNAME) fullname ,txdate, max( mramt) mramt,af.brid,
            case when instr( tl.grpname,'DHT')>0 then 'DHT' else 'BSC' END  TYPECF
            from tbl_mr3007_log v, afmast af,CFMAST cf,tlgroups tl
            where txdate = TO_DATE(I_DATE,'DD/MM/YYYY')
                and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
                AND af.acctno = v.afacctno
                and af.custid = cf.custid
                and cf.careby = tl.grpid
                AND V.mramt >0
               -- AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
               -- and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                group by  v.custodycd,txdate,af.brid ,tl.grpname)
        order by mramt DESC )
group by txdate
  union all
  SELECT '2' stt, custodycd, fullname,txdate ,
   CASE WHEN BRID ='0001' AND TYPECF='BSC' then mramt else 0 end amt_hs_bsc,
   CASE WHEN BRID ='0001' AND TYPECF='DHT' then mramt else 0 end amt_hs_dht,
   CASE WHEN BRID ='0101' AND TYPECF='BSC' then mramt else 0 end amt_cn_bsc,
   CASE WHEN BRID ='0101' AND TYPECF='DHT' then mramt else 0 end amt_cn_dht
       FROM (
        SELECT  * FROM (
            select v.custodycd,max(CF.FULLNAME) fullname ,txdate, max( mramt) mramt,af.brid,
            case when instr( tl.grpname,'DHT')>0 then 'DHT' else 'BSC' END  TYPECF
            from tbl_mr3007_log v, afmast af,CFMAST cf,tlgroups tl
            where txdate = TO_DATE(I_DATE,'DD/MM/YYYY')
                and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
                AND af.acctno = v.afacctno
                and af.custid = cf.custid
                and cf.careby = tl.grpid
                AND V.mramt >0
               -- AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
               -- and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                group by  v.custodycd,txdate,af.brid ,tl.grpname)
        order by mramt DESC )
    WHERE ROWNUM <=10
    union all
   SELECT '3' stt, custodycd, fullname,txdate ,
   CASE WHEN BRID ='0001' AND TYPECF='BSC' then mramt else 0 end amt_hs_bsc,
   CASE WHEN BRID ='0001' AND TYPECF='DHT' then mramt else 0 end amt_hs_dht,
   CASE WHEN BRID ='0101' AND TYPECF='BSC' then mramt else 0 end amt_cn_bsc,
   CASE WHEN BRID ='0101' AND TYPECF='DHT' then mramt else 0 end amt_cn_dht
       FROM (
        SELECT  * FROM (
            select '' custodycd ,v.symbol fullname ,txdate, sum( mramt) mramt,af.brid,
            case when instr( tl.grpname,'DHT')>0 then 'DHT' else 'BSC' END  TYPECF
            from tbl_mr3007_log v, afmast af,CFMAST cf,tlgroups tl
            where txdate = TO_DATE(I_DATE,'DD/MM/YYYY')
                and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
                AND af.acctno = v.afacctno
                and af.custid = cf.custid
                and cf.careby = tl.grpid
                AND V.mramt >0
             --   AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
              --  and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
                group by  v.symbol,txdate,af.brid ,tl.grpname)
        order by mramt DESC )
    WHERE ROWNUM <=10;




 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
