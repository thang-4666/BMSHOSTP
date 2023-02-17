SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_secostpricecalculatedtl ( p_seacctno IN VARCHAR2 ) RETURN NUMBER
  is
   pkgctx   plog.log_ctx;

   Cursor c_SETran  is
    /*  SELECT SE.AFACCTNO|| NVL( SB.refcodeid,SB.CODEID) ACCTNO, NVL(SE.PREVQTTY,0) PREVQTTY, NVL(SE.COSTPRICE,0) COSTPRICE,
            SUM(CASE WHEN AP.FIELD = 'DCRQTTY' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DCRQTTY,
            SUM(CASE WHEN AP.FIELD = 'DCRAMT' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DCRAMT,
            SUM(CASE WHEN AP.FIELD = 'DDROUTQTTY' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DDROUTQTTY,
            SUM(CASE WHEN AP.FIELD = 'DDROUTAMT' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DDROUTAMT
        FROM    SETRAN TR, APPTX AP, SEMAST SE, sbsecurities SB
        WHERE   TR.TXCD = AP.TXCD
        AND     AP.APPTYPE = 'SE'
        AND     substr( TR.ACCTNO,11) =SB.CODEID
        AND     AP.TXTYPE IN ('C','D')
        AND     AP.FIELD IN ('DCRQTTY', 'DCRAMT', 'DDROUTQTTY', 'DDROUTAMT')
        AND     TR.BKDATE = TR.TXDATE
        AND     SE.ACCTNO = substr( TR.ACCTNO,1,10)||NVL( SB.refcodeid,SB.CODEID)
        AND     SE.STATUS <> 'C'
        AND     TR.DELTD <> 'Y'
        AND     TR.NAMT <> 0
        AND     tr.tltxcd NOT IN ('2222')
        GROUP BY  SE.AFACCTNO|| NVL( SB.refcodeid,SB.CODEID), SE.PREVQTTY, SE.COSTPRICE;*/

      SELECT tr.acctno ACCTNO, NVL(SE.PREVQTTY,0) PREVQTTY, NVL(SE.COSTPRICE,0) COSTPRICE,
            SUM(CASE WHEN AP.FIELD = 'DCRQTTY' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DCRQTTY,
            SUM(CASE WHEN AP.FIELD = 'DCRAMT' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DCRAMT,
            SUM(CASE WHEN AP.FIELD = 'DDROUTQTTY' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DDROUTQTTY,
            SUM(CASE WHEN AP.FIELD = 'DDROUTAMT' THEN NVL(TR.NAMT,0) * DECODE(AP.TXTYPE, 'C', 1, -1)
            ELSE 0 END) DDROUTAMT
        FROM  (SELECT substr(TR.ACCTNO,1,10) AFACCTNO, substr( TR.ACCTNO,1,10)|| NVL( SB.refcodeid,SB.CODEID)  acctno ,tr.txcd,tr.txdate,tr.bkdate,tr.namt,tltxcd ,deltd,tr.txnum
                  FROM  SETRAN TR, sbsecurities SB WHERE substr( TR.ACCTNO,11) = sb.codeid
                       ) tr ,APPTX AP, SEMAST SE, afmast af, cfmast cf,tllog tl
        WHERE   TR.TXCD = AP.TXCD AND     AP.APPTYPE = 'SE'
        AND     AP.TXTYPE IN ('C','D')
        AND     AP.FIELD IN ('DCRQTTY', 'DCRAMT', 'DDROUTQTTY', 'DDROUTAMT')
        AND    nvl( TR.BKDATE, TR.TXDATE ) = TR.TXDATE AND     tr.acctno = se.acctno (+)
        AND      nvl( SE.STATUS,'A') <> 'C'
        AND     TR.DELTD <> 'Y' AND     TR.NAMT <> 0
        and tr.AFACCTNO = AF.acctno and af.custid = cf.custid
        and substr(CUSTODYCD,1,4) <> systemnums.C_DEALINGCD
        AND    nvl( tr.tltxcd,'-') NOT IN ('2222')
        AND tr.txnum = tl.txnum
        AND TR.ACCTNO = p_seacctno
        GROUP BY   tr.acctno, SE.PREVQTTY, SE.COSTPRICE,tl.offtime
        order by  tl.offtime;



    v_currdate VARCHAR2(10);
    v_nextdate VARCHAR2(10);
    v_Prev_CostPrice    number;
    v_Prev_Qtty         number;
    v_Count             NUMBER;
    v_SE_PrevQtty       NUMBER;
    v_CurrCostPrice     NUMBER;
    l_sectype   VARCHAR2(50);
    l_custid     VARCHAR2(50);
    l_afacctno VARCHAR2(50);
    l_codeid   VARCHAR2(50);
    l_PREVQTTY_temp  NUMBER;
    L_COSTPRICE_TEMP  NUMBER;

  BEGIN
    plog.setendsection(pkgctx, 'pr_SECostPriceCalculate_New');
    v_nextdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'NEXTDATE');
    v_currdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'CURRDATE');

     select PREVQTTY,COSTPRICE into l_PREVQTTY_temp, L_COSTPRICE_TEMP  from semast where acctno =p_seacctno;

    For v_SETran in c_SETran LOOP


        -- Neu so luong chung khoan khac 0 thi cap nhat gia von theo quy dinh
        If v_SETran.DCRQTTY + l_PREVQTTY_temp - v_SETran.DDROUTQTTY <> 0 then

         L_COSTPRICE_TEMP := GREATEST(CASE WHEN v_SETran.DCRQTTY + l_PREVQTTY_temp > 0 THEN
                            ROUND((l_PREVQTTY_temp*L_COSTPRICE_TEMP + v_SETran.DCRAMT /*- v_SETran.DDROUTAMT*/)/
                            (v_SETran.DCRQTTY + l_PREVQTTY_temp /*- v_SETran.DDROUTQTTY*/),4)
                            ELSE round(L_COSTPRICE_TEMP,4) END,0);
         l_PREVQTTY_temp    :=   v_SETran.DCRQTTY + l_PREVQTTY_temp - v_SETran.DDROUTQTTY;


        Else  -- truong hop tong so luong chung khoan = 0 thi cap nhat lai gia von = 0

        l_PREVQTTY_temp    :=  0;
        L_COSTPRICE_TEMP := 0;

          END IF;

            -- Cap nhat gia von trong SEMAST


    End Loop;

 RETURN L_COSTPRICE_TEMP;




  EXCEPTION
      WHEN OTHERS THEN

        plog.error (pkgctx, SQLERRM);
        plog.setendsection (pkgctx, 'pr_SECostPriceCalculateDtl');

        RAISE errnums.E_SYSTEM_ERROR;


 SELECT costprice INTO v_Prev_CostPrice   FROM   semast WHERE acctno =p_seacctno ;
 RETURN v_Prev_CostPrice;
  END fn_secostpricecalculatedtl;
 
 
 
 
/
