SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0032 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   MAKER      IN       VARCHAR2,
   KHOP        IN      VARCHAR2,
   LOAI       IN       VARCHAR2,
   PV_CUSTODYCD   IN      VARCHAR2,
   VIA            IN       VARCHAR2

 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRMAKER           VARCHAR2 (20);
   V_STRKHOP              VARCHAR2(20);
   V_STRLOAI             VARCHAR2 (6);
   V_STRCUSTODYCD        VARCHAR2(40);
   V_STRVIA              VARCHAR2(100);
    V_CURRDATE      DATE;
BEGIN
    select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE
    from sysvar where varname = 'CURRDATE';
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.BRID into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   V_STRMAKER:=UPPER(MAKER);
   V_STRKHOP :=UPPER(KHOP);
   V_STRLOAI :=UPPER(LOAI);

IF (UPPER(PV_CUSTODYCD)='ALL' OR PV_CUSTODYCD IS NULL)
  THEN
    V_STRCUSTODYCD:='%%' ;
   ELSE
   V_STRCUSTODYCD:=UPPER(PV_CUSTODYCD);
END IF;

 IF (VIA <> 'ALL')
   THEN
      V_STRVIA := VIA;
   ELSE
      V_STRVIA := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR
       SELECT CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE,SB.SYMBOL,SB.TRADEPLACE,OD.ORDERID,OD.TXDATE, OD.TXTIME,OD.EXECTYPE,
              OD.PRICETYPE, (CASE WHEN OD.MATCHTYPE='N' THEN 'N' ELSE 'P' END) MATCHTYPE,
              CASE WHEN CF.CUSTID = OD.CUSTID then 'N' else 'Y' end ORSTATUS,
              --OD.ORSTATUS,
              /*OD.QUOTEPRICE,*/ 
              /*Thu - 12/07/2018 - them cau lenh case when lay du lieu theo dieu kien*/ 
              CASE WHEN OD.PRICETYPE='LO' THEN  TO_CHAR(OD.QUOTEPRICE/1000)  ELSE OD.PRICETYPE END QUOTEPRICE,
               /*OD.ORDERQTTY,
               (CASE WHEN OD1.CANCELQTTY>0 AND OD1.CANCELQTTY=OD.ORDERQTTY  THEN OD1.CANCELQTTY
               ELSE OD.ORDERQTTY-OD1.EXECQTTY END) ORDERQTTY, */
               OD.orderqtty, OD.CANCELQTTY, OD.EXECQTTY, OD.LIMITPRICE,TL.TLNAME MAKER,
               OD.FEEACR, MR.MRTYPE ,
               CASE WHEN CF.CUSTID = OD.CUSTID then '' else AU.LICENSENO end LICENSENO,
               CASE WHEN CF.CUSTID = OD.CUSTID then '' else AU.FULLNAME end AUFULLNAME,
               V_CURRDATE CURRDATE,
               case when SB.TRADEPLACE = '001' then 1 else 0 end TRHOSE,
               case when SB.TRADEPLACE = '002' then 1 else 0 end TRHNX,
               case when SB.TRADEPLACE = '005' then 1 else 0 end TRUPCOM,
               case when OD.MATCHTYPE = 'N' then 1 else 0 end KLENH,
               case when OD.MATCHTYPE = 'P' then 1 else 0 end TTHUAN,
               CASE WHEN CF.CUSTID = OD.CUSTID then 1 else 0 end uyquyen
       FROM VW_ODMAST_ALL OD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)
        CF, AFMAST AF, SBSECURITIES SB, /*VW_IOD_ALL IO,*/TLPROFILES TL, AFTYPE AFT, MRTYPE MR,CONFIRMODRSTS CON, --VW_ODMAST_ALL OD1,
        (select * from CFAUTH where DELTD<>'Y') AU
       WHERE OD.AFACCTNO=AF.ACCTNO
             AND CF.CUSTID=AF.CUSTID
           --  AND OD.VIA IN ('F','T')
             AND OD.CODEID=SB.CODEID
             AND OD.EXECTYPE IN ('NB','BC')
            -- AND OD.ORDERID=IO.ORGORDERID(+)
             AND OD.ORDERID=CON.ORDERID(+)
             AND NVL(CON.CONFIRMED,'N')='N'
             AND OD.TLID=TL.TLID(+)
             --AND CF.CUSTTYPE='I'
             --AND OD.DELTD<>'Y'
             AND AF.ACTYPE=AFT.ACTYPE
             AND AFT.MRTYPE=MR.ACTYPE
             AND CF.CUSTID=AU.CFCUSTID(+)
             --AND OD.ORDERID=OD1.REFORDERID(+)
             AND MR.MRTYPE LIKE V_STRKHOP
             AND OD.VIA LIKE V_STRVIA
             AND CF.CUSTODYCD  LIKE V_STRCUSTODYCD
             AND OD.MATCHTYPE LIKE V_STRLOAI
             AND OD.TLID LIKE V_STRMAKER
             AND OD.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
             ORDER BY CF.custodycd,SB.SYMBOL,OD.TXTIME
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
/
