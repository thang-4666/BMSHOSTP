SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0064" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
	 T_DATE         IN      VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
)
IS

--

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

   V_IDATE           DATE;
   V_CUDATE        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);
   v_BRID        VARCHAR2(20);

	 VF_DATE  DATE;
	 VT_DATE DATE;
   V_AFTYPE      VARCHAR2(10);


BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS

    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
        v_BRID := '%%';
    else
        v_BRID := UPPER(I_BRID);
    end if ;

    IF(PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) ='ALL')
    THEN V_AFTYPE := '%';
    ELSE V_AFTYPE := PV_AFTYPE;
    END IF;

    VF_DATE:=TO_DATE(F_DATE,'DD/MM/RRRR');
	  VT_DATE:=TO_DATE(T_DATE,'DD/MM/RRRR');

    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
SELECT * FROM (
 SELECT    INDATE,BRNAME,CUSTID,CUSTODYCD,LN.FULLNAME,LN.ACCTNO,OPNDATE,MRTYPE,MARGINRATE,MRIRATE,MRMRATE,
            MRLRATE,MRCRATE,MRWRATE,ADD_TO_MRIRATE, SE_TO_MRIRATEUB, SE_TO_MRIRATE, ADVLIMIT,MRCRLIMITMAX,BALANCE,
             AMT,  ORDER_AMT,PP ,MAX_ADVAMT,TDAMT,EXECBUYAMT
 FROM ( SELECT V_CUDATE INDATE,MAIN.BRNAME, MAIN.CUSTID,MAIN.CUSTODYCD, MAIN.FULLNAME, MAIN.ACCTNO, MAIN.OPNDATE,MAIN.MRTYPE,MAIN.MARGINRATE,MAIN.MRIRATE,MAIN.MRMRATE,
            MAIN.MRLRATE,MAIN.MRCRATE,MAIN.MRWRATE,MAIN.ADD_TO_MRIRATE, greatest(MAIN.SE_TO_MRIRATEUB  ,0)      SE_TO_MRIRATEUB,
            greatest(case when MAIN.SE_TO_MRIRATE <0 then 0 else MAIN.SE_TO_MRIRATE end,0) SE_TO_MRIRATE,
            (MAIN.ADVLIMIT- main.DFODAMT - nvl(lai.nml,0) -fn_get_margin_execbuyamt_sec( main.ACCTNO) ) ADVLIMIT,MAIN.MRCRLIMITMAX,MAIN.BALANCE, NVL(LAI.AMT,0) AMT,  NVL(QTTY.AMT,0) ORDER_AMT, main.pp,
            main.MAX_ADVAMT,MAIN.TDAMT,MAIN.EXECBUYAMT
            FROM(
                         SELECT BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO, AF.OPNDATE,MR.MRTYPE,
                             NVL(CI.MARGINRATE,0) MARGINRATE,AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,
                                         (case when aft.mnemonic<>'T3' then
                                         round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRIRATE) end),0)
                                         else 0  end) ADD_TO_MRIRATE, --So tien can bo sung ve Rat
                                         af.mrirate/100 * round(-ci.se_outstanding) - ci.seass SE_TO_MRIRATE, -- se can bo sung dat Rat
                                            round((-af.mrirate/100 * ci.se_outstanding - ci.seass) / (af.mrirate/100 - 0.5),4) SE_TO_MRIRATEUB,
                                             ci.PP ,NVL(AF.mrcrlimitmax,0) ADVLIMIT,--HAN MUC CON LAI
                                             AF.MRCRLIMITMAX,--HAN MUC CAP TRONG NGAY
                                             NVL(CIMAST.BALANCE,0)/*+NVL(CI.rcvamt,0)*/ BALANCE,
                                              nvl(ci.avladvance,0) MAX_ADVAMT,
                                NVL(TD.BALANCE,0)  TDAMT, NVL(CI.BAMT,0) EXECBUYAMT, ci.DFODAMT
                            FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT,MRTYPE MR , CIMAST,
                               (select AFACCTNO,SUM(CASE WHEN NVL(BUYINGPOWER,'')='Y' THEN NVL(BALANCE,0) ELSE 0 END)BALANCE from TDMAST
                                WHERE STATUS<>'C' AND DELTD<>'Y' GROUP BY AFACCTNO ) TD
                            WHERE AF.CUSTID=CF.CUSTID
                                        AND CF.BRID=BR.BRID(+)
                                        AND CI.AFACCTNO=AF.ACCTNO
                                        AND AF.ACTYPE=AFT.ACTYPE
                                        AND AFT.MRTYPE=MR.ACTYPE
                                        AND AFT.PRODUCTTYPE LIKE V_AFTYPE
                                        AND MR.MRTYPE='T'
                                        AND AF.ACCTNO=CIMAST.ACCTNO(+)
                                        AND AF.ACCTNO=TD.AFACCTNO(+)
                                        AND CF.BRID  LIKE v_BRID
                                      ) MAIN
    LEFT JOIN
            (select trfacctno ACCTNO ,nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+
            feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) AMT, ROUND(SUM(PRINNML+PRINOVD)) NML
            from lnmast group by trfacctno) LAI ON MAIN.ACCTNO=LAI.ACCTNO
    LEFT JOIN

           ( SELECT MAIN.ACCTNO,SUM(main.qtty * nvl(ris.mrratiorate,0)/100 * least(main.MARGINCALLPRICE,nvl(ris.mrpricerate,0))) amt
              FROM (select af.acctno, af.actype,se.codeid ,sb.MARGINCALLPRICE,
               se.trade + nvl(sts.receiving,0)+ nvl(BUYQTTY,0)- nvl(od.EXECQTTY,0) qtty
            from semast se inner join afmast af on se.afacctno =af.acctno
            inner join securities_info sb on se.codeid=sb.codeid

            left join
            (select sum(BUYQTTY) BUYQTTY, sum(BUYINGQTTY) BUYINGQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                    from (
                        SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                               (case when od.exectype IN ('NB','BC') then REMAINQTTY else 0 end) BUYINGQTTY,
                               (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                        FROM odmast od, afmast af,
                            (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                           where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                           and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                           AND od.deltd <> 'Y'
                           and not(od.grporder='Y' and od.matchtype='P')
                           AND od.exectype IN ('NS', 'MS','NB','BC')
                        )
             group by AFACCTNO, CODEID
             ) OD
            on OD.afacctno =se.afacctno and OD.codeid =se.codeid
            left join
            (SELECT STS.CODEID,STS.AFACCTNO,
                    SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                FROM STSCHD STS, ODMAST OD, ODTYPE TYP,
                sysvar sy
                WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                    and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                    AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                    GROUP BY STS.AFACCTNO,STS.CODEID
             ) sts
            on sts.afacctno =se.afacctno and sts.codeid=se.codeid) MAIN LEFT JOIN AFSERISK RIS ON MAIN.CODEID=RIS.CODEID AND MAIN.ACTYPE=RIS.ACTYPE
              group by  MAIN.ACCTNO) QTTY ON MAIN.ACCTNO=QTTY.ACCTNO
     )LN
/*    LEFT JOIN
               (--moi gioi chinh-tu van dau tu vip
                SELECT CFRE.FULLNAME REFULLNAME, LNK.AFACCTNO ACCTNO, CFRE.BRID
                FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS')
                AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                ) RE    ON RE.ACCTNO=LN.CUSTID

    LEFT JOIN
                 (--moi gioi phu-cham soc ho
                SELECT  CFRE.FULLNAME REFULLNAME, LNK.AFACCTNO ACCTNO, CFRE.BRID
                FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('DG')
                AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                ) REFT   ON REFT.ACCTNO=LN.CUSTID*/

       UNION ALL SELECT  LN.INDATE,LN.BRNAME,LN.CUSTID,LN.CUSTODYCD,LN.FULLNAME,LN.ACCTNO,LN.OPNDATE,LN.MRTYPE,
       LN.MARGINRATE,LN.MRIRATE,LN.MRMRATE,LN.MRLRATE,LN.MRCRATE,LN.MRWRATE,LN.ADD_TO_MRIRATE, LN.SE_TO_MRIRATEUB,
        LN.SE_TO_MRIRATE, LN.ADVLIMIT,LN.MRCRLIMITMAX,LN.BALANCE,
             LN.AMT,  LN.ORDER_AMT,LN.PP ,LN.MAX_ADVAMT,LN.TDAMT,LN.EXECBUYAMT FROM LOG_MR0064 LN, BRGRP BR,afmast af,aftype aft
       WHERE LN.BRNAME=BR.BRNAME AND BR.BRID  LIKE v_BRID
             AND ln.custid = af.custid
             AND af.actype = aft.actype
             AND aft.actype LIKE V_AFTYPE
       )
       WHERE INDATE BETWEEN VF_DATE AND VT_DATE
       ORDER BY CUSTODYCD, INDATE;


 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
