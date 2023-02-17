SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getseamt_3375 (PV_codeid varchar2, pv_txdate varchar2) return number
is
    v_dblAVLBAL number;
    l_reftype varchar2(10);
    v_SEAMT     number;
begin
    v_SEAMT := 0;
    select NVL(SUM(NUM.AMT),0) into v_SEAMT
    FROM AFMAST AF,CFMAST CF,
    (
    SELECT SE.AFACCTNO afACCTNO,  NVL(SB.REFCODEID,SB.CODEID ) codeid,
    SUM(SE.TRADE + SE.BLOCKED + se.EMKQTTY + se.secured + SE.BLOCKWITHDRAW + SE.WITHDRAW + SE.MORTAGE +
        NVL(SE.netting,0) + NVL(SE.dtoclose,0)+ NVL(SE.blockdtoclose,0)   - NVL(NUM.AMT,0) + SE.WTRADE
        ) AMT
     FROM  SEMAST SE, SBSECURITIES SB,
    (
    SELECT NVL(SUM(AMT ),0) AMT, ACCTNO
      FROM
     ( SELECT   SUM ((CASE WHEN APP.TXTYPE = 'D'THEN -TR.NAMT WHEN
              APP.TXTYPE = 'C' THEN TR.NAMT ELSE 0  END )) AMT, TR.ACCTNO ACCTNO
              FROM APPTX APP, SETRAN TR, TLLOG TL
              WHERE TR.TXCD = APP.TXCD
                   AND TL.TXNUM =TR.TXNUM
                   AND APP.APPTYPE = 'SE'
                   AND APP.TXTYPE IN ('C', 'D')
                   AND TL.DELTD <>'Y'
                   AND  TR.NAMT<>0
                   AND TL.BUSDATE > to_date(pv_txdate,'DD/MM/YYYY')
                   AND APP.FIELD IN ('TRADE','BLOCKED','EMKQTTY','BLOCKWITHDRAW','WITHDRAW','MORTAGE','SECURED','NETTING','BLOCKDTOCLOSE','DTOCLOSE','WTRADE')
                   GROUP BY  TR.ACCTNO
      UNION ALL
             SELECT   SUM ((CASE WHEN APP.TXTYPE = 'D'THEN -TR.NAMT WHEN
             APP.TXTYPE = 'C' THEN TR.NAMT ELSE 0 END )) AMT, TR.ACCTNO ACCTNO
             FROM APPTX APP, SETRANA TR ,TLLOGALL TL
             WHERE TR.TXCD = APP.TXCD
                   AND TL.TXNUM =TR.TXNUM
                   AND TL.TXDATE =TR.TXDATE
                   AND APP.APPTYPE = 'SE'
                   AND APP.TXTYPE IN ('C', 'D')
                   AND TL.DELTD <>'Y'
                   AND  TR.NAMT<>0
                   AND TL.BUSDATE > to_date(pv_txdate,'DD/MM/YYYY')
                   AND APP.FIELD IN ('TRADE','BLOCKED','EMKQTTY','BLOCKWITHDRAW','WITHDRAW','MORTAGE','SECURED','NETTING','BLOCKDTOCLOSE','DTOCLOSE','WTRADE')
                   GROUP BY  TR.ACCTNO
                    )
                    GROUP BY ACCTNO
    )NUM
    WHERE SE.ACCTNO= NUM.ACCTNO (+)
    AND SE.CODEID =SB.CODEID
    AND NVL(SB.REFCODEID,SB.CODEID ) = PV_codeid
   -- AND (SE.TRADE + SE.BLOCKED + se.secured + SE.WITHDRAW + SE.MORTAGE +NVL(SE.netting,0) + NVL(SE.dtoclose,0) - NVL(NUM.AMT,0) + NVL(SE.WTRADE,0))<>0
    GROUP BY SE.AFACCTNO, NVL(SB.REFCODEID,SB.CODEID )
     ) NUM
    WHERE NUM.AFACCTNO = AF.ACCTNO
    AND AF.CUSTID = CF.CUSTID
    and cf.custatcom = 'Y';
    return v_SEAMT;

exception when others then
    return 0;
end;
 
 

 
 
 
 
/
