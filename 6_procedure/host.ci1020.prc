SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci1020 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   pv_symbol      IN       VARCHAR2,
   CACODE         IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (16);        -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTOCYCD     VARCHAR2 (20);
   V_STRAFACCTNO       VARCHAR2 (30);
   V_STRCACODE         VARCHAR2 (30);
   V_BRID VARCHAR2 (30);
   v_currdate  date ;
   v_strsymbol       varchar(200);
   V_STROPT       varchar(20);
   v_taxrate        NUMBER;
   v_whtax              NUMBER;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
  v_brid := pv_brid;

select to_number(varvalue) into v_taxrate  from sysvar  where varname ='ADVSELLDUTY'  ;
select to_DATE(varvalue,'DD/MM/YYYY') into v_currdate   from sysvar  where varname ='CURRDATE'  ;

/*  IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STROPTION := v_brid;
END IF;*/

 V_STROPT := upper(OPT);
--    V_INBRID := BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            --select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
            V_STRBRID := substr(pv_BRID,1,2) || '__' ;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTOCYCD := upper(PV_CUSTODYCD);
   ELSE
      V_STRCUSTOCYCD := '%%';
   END IF;

   IF (pv_AFACCTNO <> 'ALL')
   THEN
      V_STRAFACCTNO := pv_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%%';
   END IF;

 IF (CACODE <> 'ALL')
   THEN
      V_STRCACODE := CACODE;
   ELSE
      V_STRCACODE := '%%';
   END IF;

 IF (pv_symbol <> 'ALL')
   THEN
      v_strsymbol := pv_symbol;
   ELSE
      v_strsymbol := '%%';
   END IF;


OPEN PV_REFCURSOR
  FOR
select  sep.txdate,sep.txnum,cf.custodycd,af.acctno,cf.fullname,io.symbol, max( decode ( SE.catype,'021', SE.qtty,0)) cpt_qtty,
        sum(sep.qtty) SEQTTY ,IO.matchprice, sum(sep.qtty*IO.matchprice ) MATCHAMT
        , max(decode ( SE.catype,'011', SE.qtty,0)) CT_qtty,
        (case when (CF.VAT='Y' or CF.WHTAX='Y') then  ROUND( sum( aright)) else 0 end)  aright ,
         ROUND(sum( sep.qtty*IO.matchprice*
        ( case when io.txdate = v_currdate THEN NVL((decode (CF.VAT,'Y',v_taxrate,'N',0) + decode (CF.WHTAX,'Y',v_whtax,'N',0))/100,0) else od.taxrate/100 end ))) tax,sep.sepitlog_id
        from sepitallocate sep , vw_iod_all  io,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,afmast af,sepitlog SE, --PHUC ADD 27/01/2021
        vw_odmast_all od,sbsecurities sb,
        aftype
        where sep.orgorderid = io.orgorderid
        and io.orgorderid =od.orderid
        and af.actype = aftype.actype
        and sb.codeid = io.codeid
        and  SE.autoid = sep.sepitlog_id --PHUC ADD 27/01/2021
        and io.txnum = sep.txnum
        and io.txdate = sep.txdate
        and sep.afacctno= af.acctno
        and af.custid = cf.custid
        and io.deltd <>'Y'
        and SE.deltd <>'Y'
        and io.symbol like v_strsymbol
      --  and se.camastid  like  V_STRCACODE
        and af.acctno  like  V_STRAFACCTNO
        and cf.custodycd  like  V_STRCUSTOCYCD
        and io.txdate BETWEEN to_date (F_DATE,'dd/mm/yyyy') and to_date (T_DATE,'dd/mm/yyyy')
        and substr(af.acctno,1,4) like V_STRBRID
        group by  sep.txdate,sep.txnum,cf.custodycd,af.acctno,cf.fullname,io.symbol,IO.matchprice, CF.VAT, CF.WHTAX, od.taxrate,sep.sepitlog_id

        union all


        select  sep.txdate,sep.txnum,cf.custodycd,af.acctno,cf.fullname,SB.SYmbol, max( decode ( SE.catype,'021', SE.qtty,0)) cpt_qtty,
        sum(sep.qtty) SEQTTY  ,ser.price matchprice, sum(sep.qtty*ser.PRICE ) MATCHAMT
        , max(decode ( SE.catype,'011', SE.qtty,0)) CT_qtty,(case when (CF.VAT='Y' or CF.WHTAX='Y') then  ROUND( sum(aright)) else 0 end)  aright ,
        --ROUND(sum(ser.taxamt)) tax
        ROUND(sum(ser.taxamt)/100) tax,sep.sepitlog_id
        from sepitallocate sep ,cfmast cf,afmast af,sepitlog SE,
        sbsecurities sb, seretail ser
        where   SE.autoid = sep.sepitlog_id
        and sep.afacctno= af.acctno
        and af.custid = cf.custid
        and sep.codeid =sb.codeid
        and SE.deltd <>'Y'
        and  TO_DATE( SUBSTR(sep.orgorderid,1,10),'DD/MM/YYYY')= ser.txdate
        and SUBSTR(sep.orgorderid,-10,10)=ser.txnum
        and LENGTH(sep.orgorderid)=20
        and sb.symbol like v_strsymbol
     --   and se.camastid  like  V_STRCACODE
        and af.acctno  like  V_STRAFACCTNO
        and cf.custodycd  like  V_STRCUSTOCYCD
        and sep.txdate BETWEEN to_date (F_DATE,'dd/mm/yyyy') and to_date (T_DATE,'dd/mm/yyyy')
        and substr(af.acctno,1,4) like V_STRBRID
        group by  sep.txdate,sep.txnum,cf.custodycd,af.acctno,cf.fullname,SB.symbol,ser.PRICE, CF.VAT, CF.WHTAX,sep.sepitlog_id
        order by txdate,custodycd,acctno;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
-- End of DDL Script for Procedure HOST.CA1018
 
/
