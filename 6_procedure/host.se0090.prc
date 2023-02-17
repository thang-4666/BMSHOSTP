SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0090" (
       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
       OPT            IN       VARCHAR2,
       PV_BRID           IN       VARCHAR2,
       TLGOUPS        IN       VARCHAR2,
       TLSCOPE        IN       VARCHAR2,
       PV_CUSTODYCD   IN       VARCHAR2,
       PV_TXNUM       IN       VARCHAR2,
       I_DATE         IN       VARCHAR2

)
IS

-- PURPOSE:
-- BAO CAO DIEU CHINH THONG TIN CA NHAN TREN SO CO DONG
-- PERSON               DATE                COMMENTS
-- ---------------      ----------          ----------------------
-- QUYETKD             25/06/2012          SUA THEO YC BVS
-- ---------------      -------a--          ----------------------


    V_IN_DATE             DATE;

    V_INBRID        VARCHAR2(4);
    V_STRBRID      VARCHAR2 (50);
    V_STROPTION    VARCHAR2(5);

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

    V_IN_DATE := TO_DATE(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);


-- MAIN REPORT
OPEN PV_REFCURSOR FOR

 Select   sed.txnum , sed.txdate ,se.custodycd, Se.afacctno,cf.fullname,cf.IDDate, cf.idcode , cf.idplace ,cf.address,nvl(cf.phone,cf.mobile) CF_Phone,
  se.txdesc, se.symbol,'1' Loai ,(sed.depotrade + sed.depoblock) Khoi_luong , tl.tlname,V_IN_DATE Ngay_VSD
 from (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf ,afmast af,
 (Select custodycd,afacctno,txdesc,symbol,acctno,txdate,txnum,tlid,custid from setran_gen where tltxcd='2240'
  Union
  Select custodycd,Substr(msgacct,0,10) afacctno,txdesc,symbol,msgacct acctno,txdate,txnum,tl.tlid,cf.custid
  from tllog tl,afmast af , cfmast cf , sbsecurities sb
  where tltxcd='2240' and af.custid = cf.custid and Substr(msgacct,0,10) = af.acctno and sb.codeid=Substr(msgacct,11,6)
  ) se, tlprofiles tl,
 (SELECT *  FROM SEDEPOSIT
          WHERE STATUS = 'D'
            AND DELTD <> 'Y')SED
            WHERE se.acctno=sed.acctno
            and se.txdate= sed.txdate
             and se.txnum= sed.txnum
             and af.actype not in ('0000')
             and cf.custid = se.custid
             and se.tlid = tl.tlid
             and af.custid = cf.custid
            -- and sed.depotrade <>0
             and cf.custodycd= PV_CUSTODYCD
             and sed.txnum = PV_TXNUM
             AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

  /*
   UNION ALL
Select   sed.txnum , sed.txdate ,se.custodycd, Se.afacctno,cf.fullname,cf.IDDate,cf.idcode , cf.idplace,se.txdesc, se.symbol,'2' Loai ,sed.depoblock Khoi_luong , tl.tlname ,V_IN_DATE Ngay_VSD
 from cfmast cf ,afmast af,
 (Select custodycd,afacctno,txdesc,symbol,acctno,txdate,txnum,tlid,custid from setran_gen where tltxcd='2240'
  Union
  Select custodycd,Substr(msgacct,0,10) afacctno,txdesc,symbol,msgacct acctno,txdate,txnum,tl.tlid,cf.custid
  from tllog tl,afmast af , cfmast cf , sbsecurities sb
  where tltxcd='2240' and af.custid = cf.custid and Substr(msgacct,0,10) = af.acctno and sb.codeid=Substr(msgacct,11,6)
  ) se,tlprofiles tl,
 (SELECT *  FROM SEDEPOSIT
          WHERE STATUS = 'S'
            AND DELTD <> 'Y')SED
            WHERE se.acctno=sed.acctno
            and se.txdate= sed.txdate
             and se.txnum= sed.txnum
             and cf.custid = se.custid
             and se.tlid = tl.tlid
             and af.custid = cf.custid
             and sed.depoblock <>0
             and cf.custodycd= PV_CUSTODYCD
             and sed.txnum = PV_TXNUM*/

             ;

EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;


-- End of DDL Script for Procedure HOST3.SE0021

--- END
 
 
 
 
/
