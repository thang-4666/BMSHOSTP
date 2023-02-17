SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0035 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   KHOP           IN       VARCHAR2,
   PV_CUSTODYCD   IN      VARCHAR2,
   VIA            IN       VARCHAR2
 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRMAKER           VARCHAR2 (20);
   V_STRCUSTODYCD        VARCHAR2(40);
   V_STRVIA              VARCHAR2(100);
    V_STRKHOP           VARCHAR2(100);
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
      V_STRKHOP:=UPPER(KHOP);

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

       SELECT CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE,SB.SYMBOL,SB.TRADEPLACE,OD2.ORDERID,OD2.TXDATE, OD2.TXTIME,OD.EXECTYPE,
              OD.PRICETYPE, (CASE WHEN OD.MATCHTYPE='N' THEN 'N' ELSE 'P' END) MATCHTYPE,
              CASE WHEN AF2.CUSTID = OD2.CUSTID then 'N' else 'Y' end ORSTATUS,
              /*OD.QUOTEPRICE,*/  /*Thu - 12/07/2018 - them cau lenh case when lay du lieu theo dieu kien*/ 
              CASE WHEN OD.PRICETYPE='LO' THEN  TO_CHAR(OD.QUOTEPRICE/1000)  ELSE OD.PRICETYPE END QUOTEPRICE,
               /*OD.ORDERQTTY,
               (CASE WHEN OD1.CANCELQTTY>0 AND OD1.CANCELQTTY=OD.ORDERQTTY  THEN OD1.CANCELQTTY
               ELSE OD.ORDERQTTY-OD1.EXECQTTY END) ORDERQTTY, */
               OD.ORDERQTTY,
               OD2.QUOTEPRICE/1000 QUOTEPRICERJ, OD2.ORDERQTTY ORDERQTTYRJ,
               OD.EXECQTTY,round((OD.EXECAMT/(case when OD.EXECQTTY = 0 then 1 else OD.EXECQTTY end))/1000,3) EXPRICE,
               OD.LIMITPRICE,TL.TLNAME MAKER,
               OD.FEEACR, MR.MRTYPE,
               CASE WHEN AF2.CUSTID = OD2.CUSTID then '' else AU.LICENSENO end LICENSENO,
               CASE WHEN AF2.CUSTID = OD2.CUSTID then '' else AU.FULLNAME end AUFULLNAME,
               V_CURRDATE CURRDATE,
               (case when SUBSTR(CF.CUSTODYCD,1,3) = SUBSTR(OD.CLIENTID,1,3) then OD.CLIENTID
                    else '' end) CLIENTID,
               case when SB.TRADEPLACE = '001' then 1 else 0 end TRHOSE,
               case when SB.TRADEPLACE = '002' then 1 else 0 end TRHNX,
               case when SB.TRADEPLACE = '005' then 1 else 0 end TRUPCOM,
               case when OD.MATCHTYPE = 'N' then 1 else 0 end KLENH,
               case when OD.MATCHTYPE = 'P' then 1 else 0 end TTHUAN,
               CASE WHEN AF2.CUSTID = OD2.CUSTID then 0 else 1 end uyquyen
       FROM VW_ODMAST_ALL OD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
       AFMAST AF, SBSECURITIES SB, TLPROFILES TL, AFTYPE AFT, MRTYPE MR,CONFIRMODRSTS CON, VW_ODMAST_ALL OD2, AFMAST AF2,
       (select * from CFAUTH where DELTD<>'Y') AU
       WHERE OD.AFACCTNO=AF.ACCTNO
             AND OD2.AFACCTNO=AF2.ACCTNO
             AND CF.CUSTID=AF.CUSTID
            -- AND OD.VIA IN ('F','T')
             AND OD.CODEID=SB.CODEID
             AND OD.ORDERID=CON.ORDERID(+)
             AND NVL(CON.CONFIRMED,'N')='N'
             AND OD.TLID=TL.TLID(+)
             --AND CF.CUSTTYPE='I'
             --AND OD.DELTD<>'Y'
             AND OD.ORDERID=OD2.REFORDERID
             AND OD.EXECTYPE IN ('NB','NS','BC','MS','SS')
             AND OD2.EXECTYPE IN ('AB','AS')
             AND AF.ACTYPE=AFT.ACTYPE
             AND AFT.MRTYPE=MR.ACTYPE
             AND AF2.CUSTID=AU.CFCUSTID(+)
             AND OD.VIA LIKE V_STRVIA
             AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
             AND OD.TLID LIKE V_STRMAKER
             AND MR.MRTYPE LIKE V_STRKHOP
             AND OD.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
             ORDER BY CF.custodycd,SB.SYMBOL,OD.TXTIME
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
/
