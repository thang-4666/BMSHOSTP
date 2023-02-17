SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE prc_update_sec_edit_traplace (
           pl_CODEID IN VARCHAR2,
           pl_SYMBOL IN VARCHAR2,
           pv_TRADEPLACE IN VARCHAR2,
           pv_SECTYPE   IN VARCHAR2,
           pv_PARVALUE  IN NUMBER,
           pv_INTRATE   IN NUMBER,
           pv_STATUS    IN VARCHAR2,
           pv_CAREBY    IN VARCHAR2,
           pv_EXPDATE   IN VARCHAR2,
           pv_DEPOSITORY   IN VARCHAR2,
           pv_CHKRATE      IN NUMBER,
           pv_INTPERIOD    IN NUMBER,
           pv_ISSUEDATE    IN VARCHAR2,
           pv_ISSUERID     IN VARCHAR2,
           pv_FOREIGNRATE  IN NUMBER,
           pv_ISSEDEPOFEE  IN VARCHAR2,
           pv_TLID         IN VARCHAR2

       )
IS
    l_CODEID           VARCHAR2(10);
    l_SYMBOL           VARCHAR2(80);
    l_TRADEPLACE       VARCHAR2(3);
    l_old_tradeplace   VARCHAR2(3);
    l_strCurrdate         VARCHAR2(50);
    V_TRADENAME           VARCHAR2(10);
    v_strISSEDEPOFEE      VARCHAR2(1);
    l_tradelot         NUMBER;
    l_topiceTPDN  number;
    l_tradelotTPDN number; --thangpv TPDN
BEGIN

          l_CODEID           := pl_CODEID;
          l_SYMBOL           := pl_SYMBOL;
          l_TRADEPLACE       := pv_TRADEPLACE;
          l_tradelot         := fn_get_tradelot(l_TRADEPLACE);
          SELECT varvalue INTO l_strCurrdate
          FROM sysvar WHERE varname='CURRDATE' ;

          --thangpv TPDN
          begin
              select TO_NUMBER(varvalue) into l_tradelotTPDN
              from sysvar
              where varname = 'TRADELOT_TPDN_HNX' and grname='SYSTEM';
          EXCEPTION WHEN OTHERS THEN
              l_tradelotTPDN:= 1;
          END;


         /* TRADEPLACE  000 T?t c?
          TRADEPLACE    002 HNX
          TRADEPLACE    003 OTC
          TRADEPLACE    005 UPCOM
          TRADEPLACE    006 WFT
          TRADEPLACE    001 HOSE*/
          DELETE FROM securities_ticksize WHERE codeid=l_CODEID;

          --Ngay 12/04/2021 NamTv them toprice cho trai phieu doanh nghiep TPDN
          select TO_NUMBER(varvalue) into l_topiceTPDN
          from sysvar
          where varname = 'TPDNCEIL' and grname='SYSTEM';


          SELECT A.CDCONTENT
          INTO V_TRADENAME
          FROM ALLCODE A
          WHERE        A.CDTYPE = 'SE'
          AND          CDNAME   = 'TRADEPLACE'
          AND          CDVAL    = pv_TRADEPLACE;

           IF (V_TRADENAME = 'HOSE') THEN
               --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
             if(pv_SECTYPE IN ('001','008')) THEN-- CP thuong, chung chi quy
             ---- INSERT SECURITIES_TICKSIZE (BUOC GIA)
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 10, 0, 9999, 'Y');

                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 50, 10000, 49999, 'Y');

                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 100, 50000, 100000000, 'Y');

                 UPDATE securities_info SET tradelot=l_tradelot WHERE  codeid=l_CODEID;

             ELSIF  (pv_SECTYPE IN ('011')) THEN --  --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 10, 0, 100000000, 'Y');

                 UPDATE securities_info SET tradelot=l_tradelot WHERE  codeid=l_CODEID;
              ELSIF  (pv_SECTYPE IN ('003','006')) THEN -- trai phieu, trai phieu chuyen doi
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 1, 0, 100000000, 'Y');
                 UPDATE securities_info SET tradelot=1 WHERE  codeid=l_CODEID;

             ELSE

                UPDATE securities_info SET tradelot=0 WHERE  codeid=l_CODEID;
             END IF;

           ELSIF (V_TRADENAME IN ( 'HNX','UPCOM') )THEN
               --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
               if(pv_SECTYPE IN ('001','008','011')) THEN-- CP thuong, chung chi quy
                  ---- INSERT SECURITIES_TICKSIZE (BUOC GIA)
                   INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 100, 0, 10000000, 'Y');
                   UPDATE securities_info SET tradelot=l_tradelot WHERE  codeid=l_CODEID;
               ELSIF (pv_SECTYPE IN ('003','006')) THEN -- trai phieu, trai phieu chuyen doi
                   ---- INSERT SECURITIES_TICKSIZE (BUOC GIA)
                   INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 1, 0, 10000000, 'Y');
                   UPDATE securities_info SET tradelot=1 WHERE  codeid=l_CODEID;
               ELSIF (pv_SECTYPE IN ('012')) THEN -- TPDN
                   ---- INSERT SECURITIES_TICKSIZE (BUOC GIA)
                   --thanpv TPDN
                   l_tradelot := 1;
                   /*INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 1, 0, l_topiceTPDN, 'Y');
                   UPDATE securities_info SET tradelot=1 WHERE  codeid=l_CODEID; */

                   INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                   VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, l_SYMBOL, 1, 0, l_topiceTPDN, 'Y');
                   UPDATE securities_info SET tradelot=l_tradelotTPDN WHERE  codeid=l_CODEID;

               ELSE
                         ---- INSERT SECURITIES_INFO (TT CHI TIET MA CK)
                   UPDATE securities_info SET tradelot=0 WHERE  codeid=l_CODEID;

               END IF;
            ELSE
                    UPDATE securities_info SET tradelot=0 WHERE  codeid=l_CODEID;

           END IF;

          -- log thong tin chuyen san
          SELECT tradeplace,ISSEDEPOFEE
          INTO l_old_tradeplace,v_strISSEDEPOFEE
          FROM sbsecurities WHERE codeid=l_CODEID;
          if(l_old_tradeplace <> l_TRADEPLACE) THEN
             INSERT INTO SETRADEPLACE (AUTOID,TXDATE,CODEID,CTYPE,FRTRADEPLACE,TOTRADEPLACE)
             VALUES (SEQ_SETRADEPLACE.NEXTVAL,TO_DATE (l_strCurrdate, 'DD/MM/RRRR'),l_CODEID,'MA',l_old_tradeplace,l_TRADEPLACE);

          END IF;
          if(v_strISSEDEPOFEE <> pv_ISSEDEPOFEE) THEN
             INSERT INTO SEDEPOFEELOG (AUTOID,TXDATE,TLID,CODEID,ISSEDEPOFEE)
             VALUES (SEQ_SEDEPOFEELOG.NEXTVAL,TO_DATE (l_strCurrdate, 'DD/MM/RRRR'),pv_tlid,l_CODEID,pv_ISSEDEPOFEE);

          END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      plog.error ('prc_update_sec_edit_traplace: ' || SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
END;
/
