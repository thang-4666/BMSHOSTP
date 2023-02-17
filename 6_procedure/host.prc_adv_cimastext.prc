SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE PRC_ADV_CIMASTEXT (pv_afacctno varchar2, pv_isreceving varchar2)
IS
   pkgctx   plog.log_ctx;
   v_afacctno varchar2(20);
   v_indate date;
   v_advancedays number;

BEGIN
    plog.setbeginsection(pkgctx, 'PRC_ADV_CIMASTEXT');
   if(pv_afacctno is null or pv_afacctno ='ALL') then
      v_afacctno :='%';
   else
      v_afacctno := pv_afacctno;
   end if;
      v_indate := getcurrdate;
      v_advancedays:= 360;
   if (nvl(pv_isreceving,'N') <> 'Y') then
         MERGE INTO cimastext ci
         USING (select MT.AFACCTNO ,
                       round(sum(case when MT.DAYS = 0 then  MT.ADVAMT else 0 end ) )advamtbuyin,
                       round(sum(case when MT.DAYS = 0 then  0 else 0 end ),4) advfeebuyin ,

                       round(sum(case when MT.DAYS = 1 then  MT.ADVAMT else 0 end )) advamtt0,
                       round(sum(case when MT.DAYS = 1 then  MT.ADVAMT * MT.DAYS * (AD.ADVRATE + AD.ADVBANKRATE)/100/(v_advancedays + MT.DAYS * (AD.ADVRATE+AD.ADVBANKRATE)/100) else 0 end ),4) advfeet0,

                       round(sum(case when MT.DAYS >1 and ( (MT.TXDATE = v_indate and MT.CLEARDAY =1   ) or (MT.TXDATE < v_indate and MT.CLEARDAY = 2 ))  then  MT.ADVAMT else 0 end )) advamtt1,
                       round(sum(case when MT.DAYS >1 and ( (MT.TXDATE = v_indate and MT.CLEARDAY =1   ) or (MT.TXDATE < v_indate and MT.CLEARDAY = 2 )) then  MT.ADVAMT * MT.DAYS * (AD.ADVRATE + AD.ADVBANKRATE)/100/(v_advancedays + MT.DAYS * (AD.ADVRATE+AD.ADVBANKRATE)/100) else 0 end ),4) advfeet1,

                       round(sum(case when MT.DAYS >1 and ( (MT.TXDATE = v_indate and MT.CLEARDAY =2   ) or (MT.TXDATE < v_indate and MT.CLEARDAY >2 )) then  MT.ADVAMT else 0 end )) advamtt2,
                       round(sum(case when MT.DAYS >1 and ( (MT.TXDATE = v_indate and MT.CLEARDAY =2   ) or (MT.TXDATE < v_indate and MT.CLEARDAY >2 )) then  MT.ADVAMT * MT.DAYS * (AD.ADVRATE + AD.ADVBANKRATE)/100/(v_advancedays+ MT.DAYS * (AD.ADVRATE+AD.ADVBANKRATE)/100) else 0 end ),4)  advfeet2
                  from  ( SELECT STS.AFACCTNO, af.actype,MST.CLEARDAY , MST.txdate,
                         (CASE WHEN STS.CLEARDATE - v_indate = 0 THEN  decode (sts.clearday,0,0,1) ELSE STS.CLEARDATE - v_indate END) DAYS,
                          SUM(STS.AMT - (NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY ) - (mst.netexecamt + mst.cfnetexecamt)
                                     - (STS.AAMT - NVL(ODM.AAMT,0)) -STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT
                                     - (STS.ARIGHT - DECODE(MST.NETEXECAMT+MST.CFNETEXECAMT, MST.EXECAMT, STS.ARIGHT, CEIL((MST.NETEXECAMT+MST.CFNETEXECAMT)*STS.ARIGHT/MST.EXECAMT)) )
                                     - (MST.Feeacr - mst.feeamt)
                                     - (MST.TAXSELLAMT - DECODE(MST.NETEXECAMT + MST.CFNETEXECAMT, MST.EXECAMT, MST.TAXSELLAMT, CEIL((MST.NETEXECAMT + MST.CFNETEXECAMT)* MST.TAXSELLAMT/MST.EXECAMT)))) ADVAMT-- tien ung con lai
                         FROM STSCHD STS,ODMAST MST,  sbsecurities SB,cfmast cf, afmast af,
                          (SELECT ORDERID,SUM(EXECQTTY) EXECQTTY, SUM(AAMT) AAMT FROM ODMAPEXT
                           WHERE ISVSD='Y' AND DELTD <> 'Y' GROUP BY ORDERID) ODM
                         WHERE STS.orgorderid=MST.orderid
                           AND STS.CODEID=SB.CODEID
                           AND CF.custid = af.custid
                           and STS.Afacctno = af.acctno
                           AND STS.orgorderid = ODM.ORDERID (+)
                           AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                           AND mst.grporder<>'Y'
                           AND MST.ERROD = 'N'
                           AND CF.CUSTATCOM='Y'
                           AND MST.Afacctno like v_afacctno
                           AND MST.Txdate <= v_indate
                         GROUP BY STS.AFACCTNO,af.actype, MST.CLEARDAY , MST.txdate,
                               (CASE WHEN STS.CLEARDATE - v_indate = 0 THEN  decode (sts.clearday,0,0,1) ELSE STS.CLEARDATE - v_indate END)
                      ) MT, aftype aft, adtype ad--, SYSVAR SYS
                where MT.actype = aft.actype and aft.adtype = ad.actype
                  -- AND SYS.grname = 'SYSTEM' AND SYS.varname = 'ADVANCEDAYS'
                group by MT.afacctno ) adv
            ON (ci.afacctno = adv.AFACCTNO )
       WHEN MATCHED THEN
          UPDATE SET ci.advamtbuyin = adv.advamtbuyin, ci.advfeebuyin = adv.advfeebuyin,
                     ci.advamtt0 = adv.advamtt0, ci.advfeet0 = adv.advfeet0,
                     ci.advamtt1 = adv.advamtt1, ci.advfeet1 = adv.advfeet1,
                     ci.advamtt2 = adv.advamtt2, ci.advfeet2 = adv.advfeet2
       WHEN NOT MATCHED THEN
         INSERT (afacctno,advamtbuyin, advfeebuyin,  advamtt0,advfeet0,advamtt1,advfeet1,advamtt2,advfeet2)
         VALUES (adv.afacctno,adv.advamtbuyin, adv.advfeebuyin, adv.advamtt0 ,adv.advfeet0,adv.advamtt1 ,adv.advfeet1 ,adv.advamtt2 ,adv.advfeet2);
   else
     -- update ve 0 phuc vu truong hop khong con tien UTTB sau giao dich call
         UPDATE cimastext ci 
         SET ci.advamtt0 =0, ci.advfeet0 = 0,
             ci.advamtt1 = 0, ci.advfeet1 = 0,
             ci.advamtt2 = 0, ci.advfeet2 = 0
          where afacctno like  v_afacctno;
          MERGE INTO cimastext ci
         USING (select MT.AFACCTNO ,
               round(sum(case when MT.DAYS = 1 then  MT.ADVAMT else 0 end )) advamtt0,
                       round(sum(case when MT.DAYS = 1 then  MT.ADVAMT * MT.DAYS * (AD.ADVRATE + AD.ADVBANKRATE)/100/(v_advancedays + MT.DAYS * (AD.ADVRATE+AD.ADVBANKRATE)/100) else 0 end ),4) advfeet0,

                       round(sum(case when MT.DAYS >1 and ((MT.TXDATE = v_indate and MT.CLEARDAY =1) or (MT.TXDATE < v_indate and MT.CLEARDAY = 2))  then  MT.ADVAMT else 0 end )) advamtt1,
                       round(sum(case when MT.DAYS >1 and ((MT.TXDATE = v_indate and MT.CLEARDAY =1) or (MT.TXDATE < v_indate and MT.CLEARDAY = 2)) then  MT.ADVAMT * MT.DAYS * (AD.ADVRATE + AD.ADVBANKRATE)/100/(v_advancedays + MT.DAYS * (AD.ADVRATE+AD.ADVBANKRATE)/100) else 0 end ),4) advfeet1,

                       round(sum(case when MT.DAYS >1 and ((MT.TXDATE = v_indate and MT.CLEARDAY =2) or (MT.TXDATE < v_indate and MT.CLEARDAY >2)) then  MT.ADVAMT else 0 end )) advamtt2,
                       round(sum(case when MT.DAYS >1 and ((MT.TXDATE = v_indate and MT.CLEARDAY =2) or (MT.TXDATE < v_indate and MT.CLEARDAY >2)) then  MT.ADVAMT * MT.DAYS * (AD.ADVRATE + AD.ADVBANKRATE)/100/(v_advancedays + MT.DAYS * (AD.ADVRATE+AD.ADVBANKRATE)/100) else 0 end ),4)  advfeet2
               from  ( SELECT STS.AFACCTNO, af.actype,mst.txdate , mst.clearday,
                        (CASE WHEN STS.CLEARDATE - v_indate = 0 THEN 1 ELSE STS.CLEARDATE - v_indate END) DAYS,
                          SUM(STS.AMT - (NVL(ODM.EXECQTTY,0) * STS.AMT/STS.QTTY ) - (mst.netexecamt + mst.cfnetexecamt)
                                     - (STS.AAMT - NVL(ODM.AAMT,0)) -STS.FAMT+STS.PAIDAMT+STS.PAIDFEEAMT
                                     - (STS.ARIGHT - DECODE(MST.NETEXECAMT+MST.CFNETEXECAMT, MST.EXECAMT, STS.ARIGHT, CEIL((MST.NETEXECAMT+MST.CFNETEXECAMT)*STS.ARIGHT/MST.EXECAMT)) )
                                     - (case when mst.txdate = v_indate and MST.Feeacr =0  then mst.bratio-100/100 * (case when NVL(ODM.EXECQTTY,0) > 0 then ODM.EXECQTTY else STS.QTTY end *(STS.AMT/STS.QTTY )) else MST.Feeacr - mst.feeamt end)
                                     -  case when mst.txdate = v_indate and MST.TAXSELLAMT =0 then 
                                             (decode (CF.VAT,'Y',sys.varvalue/100, 'N',0) + decode (CF.WHTAX,'Y',sys1.varvalue/100, 'N',0)) * (case when NVL(ODM.EXECQTTY,0) > 0 then ODM.EXECQTTY else STS.QTTY end *(STS.AMT/STS.QTTY ))
                                              else MST.TAXSELLAMT - DECODE(MST.NETEXECAMT + MST.CFNETEXECAMT, MST.EXECAMT, MST.TAXSELLAMT, CEIL((MST.NETEXECAMT + MST.CFNETEXECAMT)* MST.TAXSELLAMT/MST.EXECAMT)) end
                                  ) ADVAMT-- tien ung con lai
                      FROM STSCHD STS,ODMAST MST,  sbsecurities SB,cfmast cf, afmast af,
                           (SELECT ORDERID,SUM(EXECQTTY) EXECQTTY, SUM(AAMT) AAMT FROM ODMAPEXT
                            WHERE ISVSD='Y' AND DELTD <> 'Y' GROUP BY ORDERID) ODM, sysvar sys, sysvar sys1
                      WHERE STS.orgorderid=MST.orderid
                        AND STS.CODEID=SB.CODEID
                        AND CF.custid = af.custid
                        and STS.Afacctno = af.acctno
                        AND STS.orgorderid = ODM.ORDERID (+)
                        AND sys.grname = 'SYSTEM' AND sys.varname = 'ADVSELLDUTY'
                        AND sys1.grname = 'SYSTEM' AND sys1.varname = 'WHTAX'
                        AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
                        and sts.clearday > 0
                        AND mst.grporder<>'Y'
                        AND MST.ERROD = 'N'
                        AND CF.CUSTATCOM='Y'
                        AND MST.Afacctno like v_afacctno
                        AND   MST.Txdate <= v_indate
                        AND ((MST.txdate = v_indate and   MST.CLEARDAY  in (1,2)) or (MST.txdate < v_indate ) )
                     GROUP BY STS.AFACCTNO,af.actype,mst.txdate , mst.clearday,
                         (CASE WHEN STS.CLEARDATE - v_indate = 0 THEN 1 ELSE STS.CLEARDATE - v_indate END)
                     ) MT, aftype aft, adtype ad--, SYSVAR SYS
          where MT.actype = aft.actype and aft.adtype = ad.actype
            --AND SYS.grname = 'SYSTEM' AND SYS.varname = 'ADVANCEDAYS'
          group by MT.afacctno ) adv
            ON (ci.afacctno = adv.AFACCTNO )
       WHEN MATCHED THEN
          UPDATE SET ci.advamtt0 = adv.advamtt0, ci.advfeet0 = adv.advfeet0,
                     ci.advamtt1 = adv.advamtt1, ci.advfeet1 = adv.advfeet1,
                     ci.advamtt2 = adv.advamtt2, ci.advfeet2 = adv.advfeet2
       WHEN NOT MATCHED THEN
         INSERT (afacctno,advamtbuyin, advfeebuyin,  advamtt0,advfeet0,advamtt1,advfeet1,advamtt2,advfeet2)
         VALUES (adv.afacctno,0, 0, adv.advamtt0 ,adv.advfeet0,adv.advamtt1 ,adv.advfeet1 ,adv.advamtt2 ,adv.advfeet2);
      end if;

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'PRC_ADV_CIMASTEXT');
END PRC_ADV_CIMASTEXT;
/
