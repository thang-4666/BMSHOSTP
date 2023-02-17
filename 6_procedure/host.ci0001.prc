SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci0001 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTTYPE    IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   --PV_CLASS IN       VARCHAR2,
   TLID            IN       VARCHAR2,
   PV_CUSTATCOM    IN       VARCHAR2,
   PV_ISDEALING     IN      varchar2,
   PV_ISOTC     IN      varchar2
       )
IS
--
-- BAO CAO: TONG HOP TIEU KHOAN TIEN GUI CUA KHACH HANG
-- MODIFICATION HISTORY
-- PERSON           DATE                    COMMENTS
-- -----------      -----------------       ---------------------------
-- TUNH             15-05-2010              CREATED
-- THENN            14-06-2012              MODIFIED    THAY DOI CACH TINH SDDK
-----------------------------------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2  (16);
    v_brid              VARCHAR2(4);

    v_FromDate     date;
    v_ToDate       date;

    v_CustodyCD    varchar2(100);
    v_AFAcctno     varchar2(100);
    v_country      VARCHAR2(5);
    v_custtype     VARCHAR(10);
    V_STRTLID           VARCHAR2(6);
    --v_strCLASS  VARCHAR2(6);
    V_STRCUSTATCOM VARCHAR2(10);
BEGIN
    -- GET REPORT'S PARAMETERS
   V_STROPTION := OPT;
      v_brid := pv_brid;
  V_STRTLID:= TLID;

 IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.BRID into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STROPTION := v_brid;

END IF;

   IF PV_CUSTATCOM = 'Y' THEN
      V_STRCUSTATCOM := '%';
   ELSE
      V_STRCUSTATCOM := 'Y';
   END IF;

    v_FromDate := TO_DATE(F_DATE, 'DD/MM/YYYY');
    v_ToDate := TO_DATE(T_DATE, 'DD/MM/YYYY');

    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL) THEN
       v_CustodyCD := PV_CUSTODYCD;
    ELSE
       v_CustodyCD := '%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '' OR PV_AFACCTNO <> NULL) THEN
       v_AFAcctno := PV_AFACCTNO;
    ELSE
       v_AFAcctno  := '%';
    END IF;
    --I: ca nhan
    --B: TO chuc
    if  PV_CUSTTYPE ='000' THEN
      v_custtype:='%';
    ELSIF PV_CUSTTYPE ='001' THEN--Ca nhan trong nuoc
      v_custtype:='I';
    ELSIF PV_CUSTTYPE ='002' THEN --To chuc trong nuoc
      v_custtype:='B';
    ELSIF PV_CUSTTYPE ='003'  THEN--Ca nhan nuoc ngoai
      v_custtype:='I';
    ELSIF PV_CUSTTYPE ='004'  THEN--To chuc nuoc ngoai
      v_custtype:='B';
    END IF;

    /*IF (pv_CLASS = 'ALL')
    THEN
         v_strCLASS := '%';
    ELSE
         v_strCLASS := CASE WHEN PV_CLASS='Y' THEN '000' ELSE '001' END  ;
    END IF;*/

OPEN PV_REFCURSOR
FOR
    select cf.custid, cf.custodycd, /*af.description*/ A0.CDCONTENT  afacctno, cf.fullname,
        round(nvl(ci_debit,0),0) ci_debit, round(nvl(ci_credit,0),0) ci_credit,
        (balance + bamt + mblock + emkamt) - round(nvl(ci_move_from_cur,0),0) + NVL(DF.BE_DFAMT,0) ci_begin_bal
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, V_BRID, TLGOUPS)=0 AND CUSTATCOM LIKE V_STRCUSTATCOM) cf, afmast af, cimast ci,aftype aft, allcode a0,


    (   -- Tinh phat sinh tu FromDate den hom nay
        select custid, custodycd, AFAcctno,
                sum (ci_move_from_cur) ci_move_from_cur
        from
        (
            select tr.custid, tr.custodycd, tr.acctno AFAcctno,
                sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) ci_move_from_cur
            from vw_citran_gen tr
            where txtype in ('D','C')
                and field in ('BAMT','BALANCE','MBLOCK','EMKAMT')
                --and tr.tltxcd not in ('9100','6600','6690','2635','2651','2653','2656')
                and tr.tltxcd not in ('9100','6600','6690','2635','2651','2653','2656','2646','2648','2636','2665',
                                            '1144','1145','6601','6602')
                and tr.busdate >= v_FromDate
                and tr.custodycd like v_CustodyCD
                and tr.acctno like v_AFAcctno
                and substr(tr.custid,1,4) like '%'
            group by tr.custid, tr.custodycd, tr.acctno
            having sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) <> 0
            union all
            select cf.custid, cf.custodycd, af.acctno AFAcctno,
                sum (tl.msgamt) ci_move_from_cur
            FROM VW_TLLOG_ALL TL, cfmast cf, afmast af
            where cf.custid = af.custid
                and TL.MSGacct = af.acctno
                and tl.deltd <> 'Y'
                AND TL.TLTXCD = '6668'
                and tl.busdate >= v_FromDate
                and cf.custodycd like v_CustodyCD
                and af.acctno like v_AFAcctno
            group by cf.custid, cf.custodycd, af.acctno
        )
        group by custid, custodycd, AFAcctno
    )  tr_from_cur,
    (
         SELECT DF.AFACCTNO, SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) BE_DFAMT
         FROM
             (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df
             LEFT JOIN
             (
                 select tr.acctno,
                         sum (case when atx.txtype = 'D' then - tr.namt else tr.namt end) dfamt
                     from vw_dftran_all tr, apptx atx
                     where tr.txcd = atx.txcd AND atx.apptype = 'DF'
                         AND atx.txtype in ('D','C')
                         and atx.field IN ('DFBLOCKAMT','DFAMT')
                         and tr.TXDATE >= v_FromDate
                     group by tr.acctno
             ) TR
             ON TR.ACCTNO = DF.GROUPID
         GROUP BY DF.AFACCTNO
         HAVING SUM(DF.DFBLOCKAMT + DF.DFAMT - NVL(TR.DFAMT,0)) <>0
     ) DF,

    (   -- Tinh phat sinh tu FromDate den ToDate
        SELECT tr.custid, tr.custodycd, tr.afacctno, sum(ci_debit) ci_debit, sum(ci_credit) ci_credit
        FROM
        (
            select tr.custid, tr.custodycd, tr.acctno AFAcctno,
                sum (case when tr.txtype = 'D' then tr.namt else 0 end) ci_debit,
                sum (case when tr.txtype = 'C' then tr.namt else 0 end) ci_credit
            from vw_citran_gen tr
            where tr.txtype in ('D','C')
                and tr.field in ('BAMT','BALANCE','MBLOCK','EMKAMT')
                and tr.tltxcd not in ('9100','6600','6690','2635','2651','2653','2656','2646','2648','2636','2665',
                                        '1144','1145','6601','6602')
                and tr.busdate between v_FromDate and v_ToDate
                and tr.custodycd like v_CustodyCD
                and tr.acctno like v_AFAcctno
                and substr(tr.custid,1,4) like '%'
            group by tr.custid, tr.custodycd, tr.acctno

            union all

            select cf.custid, cf.custodycd, af.acctno AFAcctno, 0 ci_debit,
                sum (tl.msgamt) ci_credit
            FROM VW_TLLOG_ALL TL, cfmast cf, afmast af
            where cf.custid = af.custid
                and TL.MSGacct = af.acctno
                and tl.deltd <> 'Y'
                AND TL.TLTXCD = '6668'
                and tl.busdate between v_FromDate and v_ToDate
                and cf.custodycd like v_CustodyCD
                and af.acctno like v_AFAcctno
            group by cf.custid, cf.custodycd, af.acctno

            --having sum (case when tr.txtype = 'D' then - tr.namt else tr.namt end) <> 0
            UNION ALL
            -- GD VAY DF
            SELECT cf.custid, cf.custodycd, ci.acctno AFAcctno,
                sum(CASE WHEN ci.txtype = 'D' THEN ci.namt ELSE 0 end) ci_debit,
                sum(CASE WHEN ci.txtype = 'C' THEN ci.namt ELSE 0 end) ci_credit
             FROM
                 (
                 SELECT LN.trfacctno ACCTNO, LNT.TLTXCD, LNT.TXDATE, LNT.TXNUM, LNT.TXCD,
                     LNT.NAMT, APT.field FIELD, 'D' TXTYPE, LN.custbank
                 FROM (SELECT * FROM vw_lntran_all WHERE TXDATE >= v_FromDate AND txdate <= v_ToDate) lnt,
                    vw_lnmast_all LN, APPTX APT
                 WHERE LNT.TLTXCD IN ('2646','2648','2636','2665') AND lnt.TXCD IN ('0014','0024','0090') AND lnt.namt > 0
                     AND LN.prinnml+LN.prinovd+LN.prinpaid > 0 AND LN.FTYPE = 'DF'
                     AND LNT.txcd = APT.txcd AND APT.apptype = 'LN'
                     AND LNT.acctno = LN.acctno
                 ) CI, CFMAST CF, afmast af
             WHERE cf.custid = af.custid AND af.acctno = ci.acctno
             GROUP BY cf.custid, cf.custodycd, ci.acctno
        ) tr
        GROUP BY tr.custid, tr.custodycd, tr.afacctno
    )  tr_from_Todate

    where cf.custid = af.custid and af.acctno = ci.acctno and aft.actype=af.actype
        AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
        --and cf.class like v_strCLASS
        and ci.acctno = tr_from_cur.afacctno (+)
        and ci.acctno = tr_from_Todate.afacctno (+)
        AND ci.acctno = df.afacctno (+)
        and cf.custodycd like v_CustodyCD
        and af.acctno like v_AFAcctno
        and
        (
        abs(round(nvl(ci_debit,0),0))
        + abs(round(nvl(ci_credit,0),0) )
        + abs((balance + bamt + mblock + emkamt) - round(nvl(ci_move_from_cur,0),0) + NVL(DF.BE_DFAMT,0))
        ) >=1
        and cf.custodycd not like systemnums.C_DEALINGCD||'%'
--PhucPP comment
--        and substr(cf.custid,1,4) like '%'
          AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
         /* and cf.custatcom='Y'*/
          AND AF.COREBANK='N'
          --PhuongHT them tham so loai KH
          AND cf.custtype LIKE v_custtype
          AND ((pv_custtype IN ('001','002') AND SUBSTR(cf.custodycd,4,1) IN ('A','B','C','P')) -- trong nuoc
               OR (pv_custtype IN ('003','004') AND SUBSTR(cf.custodycd,4,1) IN ('E','F')) -- nuoc ngoai
               OR pv_custtype IN ('000')  ) -- all
         -- and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
         AND (CASE WHEN PV_ISDEALING = 'N' AND substr(cf.custodycd ,1, 4) = systemnums.C_DEALINGCD THEN 0 ELSE 1 END) = 1
         AND (CASE WHEN PV_ISOTC = 'N' AND substr(cf.custodycd ,1, 3) = 'OTC' THEN 0 ELSE 1 END) = 1
    order by cf.custodycd
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
/
