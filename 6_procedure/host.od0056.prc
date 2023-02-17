SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0056" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_TLID        IN       VARCHAR2,
   GRCAREBY       IN       VARCHAR2,
   CAREBY         IN       VARCHAR2,
   PV_NGT         IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- BAO CAO GDCK THEO TK KIEM CHI PHI MOI GIOI PS
-- PERSON   DATE  COMMENTS
-- huynq 22-APR-09  CREATED
-- quyetKD 17-03-2011 modify
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (40);
   V_INBRID         VARCHAR2 (4);

   v_CurrDate       DATE;
   CurrDate         VARCHAR2 (20);
   V_Nguoidatlenh         VARCHAR2 (20);
   V_CAREBY VARCHAR2 (20);
   V_N_dat_L VARCHAR2 (20);
   V_NGT VARCHAR2 (20);
   V_NGT_SHOW VARCHAR2 (20);
BEGIN

    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;


      IF (CAREBY <> 'ALL')
  THEN
     V_Nguoidatlenh := CAREBY;
     V_N_dat_L := CAREBY;
  ELSE
      V_Nguoidatlenh := '%%';
      V_N_dat_L :='ALL';
   END IF;


   IF (GRCAREBY <> 'ALL')
  THEN
     V_CAREBY := GRCAREBY;
  ELSE
      V_CAREBY := 'ALL';
   END IF;


     IF (PV_NGT <> 'ALL')
  THEN
     V_NGT := PV_NGT;
     V_NGT_SHOW := PV_NGT;
  ELSE
      V_NGT := '%%';
      V_NGT_SHOW := 'ALL';
   END IF;




  -- select c.sbdate into v_CurrDate  from sbcldr c where c.sbbusday = 'Y';
 select varvalue into CurrDate  from sysvar  where varname='CURRDATE';
 v_CurrDate := to_date(CurrDate,'DD/MM/RRRR');


  IF (GRCAREBY <> 'ALL')  THEN
    OPEN PV_REFCURSOR
       FOR
          SELECT  T.ACCTNO,
          T.CUSTODYCD,
          T.SYMBOL,
          T.ORDERID,
          T.contraorderid,
          T.TXDATE ,
          T.PUTTYPE,
          T.EXECTYPE,
          T.fullname,
          T.idcode,
          T.iddate,
          T.idplace,
          T.address,
          T.careby,

              (CASE  WHEN T.EXECTYPE IN('NB','BC')  THEN   NVL(IO.MATCHQTTY,0)  END)MATCHQTTYB,
              (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.MATCHQTTY,0) END)MATCHQTTYS,
              (CASE  WHEN T.EXECTYPE IN('NB','BC')  THEN   NVL(IO.MATCHPRICE,0)  END)MATCHPRICEB,
              (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.MATCHPRICE,0) END)MATCHPRICES,
              NVL(IO.MATCHQTTY,0)* NVL(IO.MATCHPRICE,0) EXECAMT,

             case when t.execamt = 0 then 0
               when t.txdate = v_CurrDate then io.matchqtty * io.matchprice * t.deffeerate/100
                else  round( io.matchqtty * io.matchprice/t.execamt * t.feeamt,2)
             end feeamt_detail,

              case when t.execamt = 0 then 0 when (IO.MATCHPRICE*IO.MATCHQTTY) = 0 then 0
                   when t.txdate = v_CurrDate  and T.EXECTYPE IN('NS','SS','MS')

                        then round( (io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)

                        when  T.EXECTYPE IN('NS','SS','MS') then

                              round ((io.matchqtty * io.matchprice/t.execamt * t.feeamt)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)

                              when t.txdate = v_CurrDate  and T.EXECTYPE IN('NB','BC')
                                   then  round ((io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)
                                   when  T.EXECTYPE IN('NB','BC') then

                                         round((io.matchqtty * io.matchprice/t.execamt * t.feeamt)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)
             end fee_bs ,V_N_dat_L V_N_dat_L ,V_CAREBY V_CAREBY , V_NGT_SHOW V_NGT_SHOW

         FROM
             (

                     SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,CF.fullname,cf.idcode,cf.iddate,cf.idplace,
                     cf.address,
                     af.careby ,
                     OD.EXECTYPE, A1.CDCONTENT PUTTYPE, SB.SYMBOL, ODTYPE.DEFFEERATE , OD.feeamt,  od.execamt,

                     (CASE  WHEN OD.PRICETYPE IN ('ATO','ATC')AND OD.EXECTYPE IN('NB','BC')  THEN  OD.PRICETYPE
                           WHEN OD.EXECTYPE IN('NB','BC') THEN to_char( OD.QUOTEPRICE) END )QUOTEPRICEB,

                     (CASE  WHEN OD.PRICETYPE IN ('ATO','ATC')AND OD.EXECTYPE IN('NS','SS')  THEN  OD.PRICETYPE
                           WHEN OD.EXECTYPE IN('NS','SS','MS') THEN to_char( OD.QUOTEPRICE) END )QUOTEPRICES,

                     (CASE  WHEN OD.EXECTYPE IN('NB','BC')  THEN   OD.ORDERQTTY END)ORDERQTTYB,
                     (CASE  WHEN OD.EXECTYPE IN('NS','SS','MS')  THEN   OD.ORDERQTTY END)ORDERQTTYS,
                     OD.TLID
                 FROM vw_odmast_all OD,
                      SBSECURITIES SB,
                      AFMAST AF,
                      (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                      ODTYPE,
                      ALLCODE A1
              WHERE  OD.CODEID = SB.CODEID
                   AND od.DELTD <> 'Y'
                   AND od.EXECQTTY <> 0
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND OD.EXECTYPE IN ('NB','NS','SS','BC','MS')
                   AND AF.CUSTID = CF.CUSTID
                   AND AF.ACTYPE NOT IN ('0000')
                    AND ODTYPE.ACTYPE = OD.ACTYPE
                   AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = OD.PUTTYPE AND A1.CDTYPE = 'OD'
                   AND OD.TXDATE >= to_date(F_DATE, 'DD/MM/YYYY')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                   AND OD.TLID LIKE V_Nguoidatlenh
                   AND nvl(CF.REFNAME,'null') like V_NGT
                   and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
                   and af.careby = V_CAREBY
                   --AND OD.CIACCTNO IN (SELECT vw.value CIACCTNO FROM vw_custodycd_subaccount vw                    )
            ) T INNER JOIN
              (
              SELECT * FROM vw_iod_all WHERE DELTD <> 'Y'
              ) IO  ON IO.ORGORDERID = T.ORDERID
            ORDER BY T.TXDATE, T.Symbol, T.ACCTNO ;


  ELSE
     OPEN PV_REFCURSOR
       FOR
          SELECT  T.ACCTNO,T.CUSTODYCD,T.SYMBOL,T.ORDERID,T.contraorderid, T.TXDATE ,T.PUTTYPE, T.EXECTYPE,
          T.fullname,T.idcode,T.iddate,T.idplace,T.address,  T.careby,
              (CASE  WHEN T.EXECTYPE IN('NB','BC')  THEN   NVL(IO.MATCHQTTY,0)  END)MATCHQTTYB,
              (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.MATCHQTTY,0) END)MATCHQTTYS,
              (CASE  WHEN T.EXECTYPE IN('NB','BC')  THEN   NVL(IO.MATCHPRICE,0)  END)MATCHPRICEB,
              (CASE  WHEN T.EXECTYPE IN('NS','SS','MS')  THEN   NVL(IO.MATCHPRICE,0) END)MATCHPRICES,
              NVL(IO.MATCHQTTY,0)* NVL(IO.MATCHPRICE,0) EXECAMT,
             case when t.execamt = 0 then 0
               when t.txdate = v_CurrDate then io.matchqtty * io.matchprice * t.deffeerate/100
                else  round( io.matchqtty * io.matchprice/t.execamt * t.feeamt,2)
             end feeamt_detail,

              case when t.execamt = 0 then 0 when (IO.MATCHPRICE*IO.MATCHQTTY) = 0 then 0
                   when t.txdate = v_CurrDate  and T.EXECTYPE IN('NS','SS','MS')

                        then round( (io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)

                        when  T.EXECTYPE IN('NS','SS','MS') then

                              round ((io.matchqtty * io.matchprice/t.execamt * t.feeamt)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)

                              when t.txdate = v_CurrDate  and T.EXECTYPE IN('NB','BC')
                                   then  round ((io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)
                                   when  T.EXECTYPE IN('NB','BC') then

                                         round((io.matchqtty * io.matchprice/t.execamt * t.feeamt)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)
             end fee_bs ,V_N_dat_L V_N_dat_L ,V_CAREBY V_CAREBY , V_NGT_SHOW V_NGT_SHOW

         FROM
             (SELECT AF.ACCTNO,CF.CUSTODYCD,OD.TXDATE,OD.ORDERID, OD.contraorderid,CF.fullname,cf.idcode,cf.iddate,cf.idplace,cf.address,
                     OD.EXECTYPE, A1.CDCONTENT PUTTYPE, SB.SYMBOL, ODTYPE.DEFFEERATE , OD.feeamt,  od.execamt,af.careby,

                     (CASE  WHEN OD.PRICETYPE IN ('ATO','ATC')AND OD.EXECTYPE IN('NB','BC')  THEN  OD.PRICETYPE
                           WHEN OD.EXECTYPE IN('NB','BC') THEN to_char( OD.QUOTEPRICE) END )QUOTEPRICEB,

                     (CASE  WHEN OD.PRICETYPE IN ('ATO','ATC')AND OD.EXECTYPE IN('NS','SS')  THEN  OD.PRICETYPE
                           WHEN OD.EXECTYPE IN('NS','SS','MS') THEN to_char( OD.QUOTEPRICE) END )QUOTEPRICES,

                     (CASE  WHEN OD.EXECTYPE IN('NB','BC')  THEN   OD.ORDERQTTY END)ORDERQTTYB,
                     (CASE  WHEN OD.EXECTYPE IN('NS','SS','MS')  THEN   OD.ORDERQTTY END)ORDERQTTYS,
                     OD.TLID
                 FROM vw_odmast_all OD,
                      SBSECURITIES SB,
                      AFMAST AF,
                      (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                      ODTYPE,
                      ALLCODE A1
              WHERE  OD.CODEID = SB.CODEID
                   AND od.DELTD <> 'Y'
                   AND od.EXECQTTY <> 0
                   AND OD.CIACCTNO = AF.ACCTNO
                   AND OD.EXECTYPE IN ('NB','NS','SS','BC','MS')
                   AND AF.CUSTID = CF.CUSTID
                   AND AF.ACTYPE NOT IN ('0000')
                    AND ODTYPE.ACTYPE = OD.ACTYPE
                   AND A1.CDNAME = 'PUTTYPE' AND A1.CDVAL = OD.PUTTYPE AND A1.CDTYPE = 'OD'
                   and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
                   AND OD.TXDATE >= to_date(F_DATE, 'DD/MM/YYYY')
                   AND OD.TXDATE <= to_date(T_DATE , 'DD/MM/YYYY')
                   and af.careby in    (
                       Select TLG.grpid from tlgrpusers TL ,
                      (
                       Select * from tlgroups where grptype = 2 and active='Y'
                      )  TLG
                       where tl.grpid = TLG.grpid
                       and tl.tlid = PV_TLID
                      )
                   AND OD.TLID LIKE V_Nguoidatlenh
                   AND nvl(CF.REFNAME,'null') like V_NGT

            ) T INNER JOIN
              (
              SELECT * FROM vw_iod_all WHERE DELTD <> 'Y'
              ) IO  ON IO.ORGORDERID = T.ORDERID
            ORDER BY T.TXDATE, T.Symbol, T.ACCTNO ;
   END IF;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
