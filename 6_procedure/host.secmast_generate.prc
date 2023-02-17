SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE secmast_generate
    (
        PV_TXNUM        IN VARCHAR2, ---MA CHUNG TU CUA LENH
        PV_TXDATE       IN VARCHAR2, ---NGAY TAO GIAO DICH
        PV_BUSDATE      IN VARCHAR2, ---NGAY GIAO DICH CO HIEU LUC
        PV_AFACCTNO     IN VARCHAR2, ---SO TIEU KHOAN
        PV_SYMBOL       IN VARCHAR2, ---CHUNG KHOANG
        PV_SECTYPE      IN VARCHAR2, ---LOAI GIAO DICH (T:MUA/BAN ; D:LUU KY ; S:CHUYEN KHOAN ; C:QUYEN)
        PV_PTYPE        IN VARCHAR2, ---GIAO DICH NHAP XUAT (I:NHAP ; O:XUAT)
        PV_CAMASTID     IN VARCHAR2, ---MA SU KIEN(VOI SECTYPE = C. SECTYPE <> 'C' DE NULL)
        PV_ORDERID      IN VARCHAR2, ---MA LENH(VOI SECTYPE = T. SECTYPE <> 'T' DE NULL)
        PV_QTTY         IN NUMBER,   ---SO LUONG
        PV_COSTPRICE    IN NUMBER,   ---GIA VON (GIA CUA LAN NHAP/XUAT)
        PV_MAPAVL       IN VARCHAR2,  ---CO DUOC MAP LUON HAY KHONG.
        PV_AMT          IN NUMBER DEFAULT 0
    )
IS
-- Purpose:
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- DUNGNH      06/08/2013
-- ---------   ------  -------------------------------------------

    V_TXDATE        DATE;  ---NGAY TAO GIAO DICH
    V_BUSDATE       DATE; ---NGAY GIAO DICH CO HIEU LUC

    V_STRTXNUM      VARCHAR2(20); ---MA CHUNG TU CUA LENH
    V_STRAFACCTNO   VARCHAR2(20); ---SO TIEU KHOAN
    V_STRSYMBOL     VARCHAR2(20); ---CHUNG KHOANG
    V_STRSECTYPE    VARCHAR2(1); ---LOAI GIAO DICH (T:MUA/BAN ; D:LUU KY ; S:CHUYEN KHOAN ; C:QUYEN)
    V_STRPTYPE      VARCHAR2(1); ---GIAO DICH NHAP XUAT (I:NHAP ; O:XUAT)
    V_STRCAMASTID   VARCHAR2(20); ---MA SU KIEN(VOI SECTYPE = C. SECTYPE <> 'C' DE NULL)
    V_STRORDERID    VARCHAR2(20); ---MA LENH(VOI SECTYPE = T. SECTYPE <> 'T' DE NULL)
    V_NQTTY         NUMBER;   ---SO LUONG
    V_NCOSTPRICE    NUMBER;   ---GIA VON (GIA CUA LAN NHAP/XUAT)
    V_MAPAVL        VARCHAR2(1);  ---CO DUOC MAP LUON HAY KHONG.
    V_OUTID         number;
     V_RTCOSTPRICE         number;
     V_AMT number;
     v_wftcodeid VARCHAR2(10);
     l_count number;
     l_sectype VARCHAR2(10);
     l_custid VARCHAR2(20);
     l_codeid VARCHAR2(20);
     l_afacctno VARCHAR2(20);

BEGIN
    V_TXDATE    := TO_DATE(PV_TXDATE,'DD/MM/RRRR');
    V_BUSDATE   := TO_DATE(PV_BUSDATE,'DD/MM/RRRR');

    V_STRTXNUM      := PV_TXNUM;
    V_STRAFACCTNO   := PV_AFACCTNO;
    V_STRSYMBOL     := PV_SYMBOL;
    V_STRSECTYPE    := PV_SECTYPE;
    V_STRPTYPE      := PV_PTYPE;
    V_STRCAMASTID   := PV_CAMASTID;
    V_STRORDERID    := PV_ORDERID;
    V_NQTTY         := PV_QTTY;
    V_NCOSTPRICE    := PV_COSTPRICE;
    V_MAPAVL        := PV_MAPAVL;
    V_AMT           :=PV_AMT;



      V_RTCOSTPRICE := 0;





     if V_STRPTYPE='O' and V_STRORDERID IS NOT NULL then

               begin
                SELECT
                    CASE WHEN (MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) = 0 THEN 0 ELSE
                    CEIL(
                    (MAX(SE.PREVQTTY*SE.COSTPRICE)
                     +SUM((NVL(SEC.INAMT,0))
                        - (NVL(SEC.ODOUTAMT,0))
                        -(NVL(SEC.OUTAMT,0))
                        +((NVL(OT.DEFFEERATE,0)/100)*(CASE WHEN OD.EXECTYPE LIKE '%S' THEN 0 ELSE NVL(OD.EXECAMT,0)END)))
                        -sum(nvl(AMT,0)) --co tuc bang tien hay cac giao dich lien quan tien anh huong gia von
                     )/(MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0)))
                     )
                    END
                    AVGCOSTPRICE
                INTO V_RTCOSTPRICE
                FROM (SELECT s.ACCTNO, nvl(b.REFCODEID,b.CODEID)CODEID,s.ORDERID,
                         SUM(CASE WHEN s.PTYPE ='I' THEN s.QTTY ELSE 0 END) INQTTY,
                         SUM(CASE WHEN s.PTYPE ='O' AND s.ORDERID IS NOT NULL THEN s.QTTY ELSE 0 END) ODOUTQTTY,
                         SUM(CASE WHEN s.PTYPE ='O' AND s.ORDERID IS NULL THEN s.QTTY ELSE 0 END) OUTQTTY,
                         SUM(CASE WHEN s.PTYPE ='I' THEN s.QTTY*s.COSTPRICE ELSE 0 END) INAMT,
                         SUM(CASE WHEN s.PTYPE ='O' AND s.ORDERID IS NOT NULL THEN s.QTTY*s.RTCOSTPRICE ELSE 0 END) ODOUTAMT,
                         SUM(CASE WHEN s.PTYPE ='O' AND s.ORDERID IS NULL THEN s.QTTY*s.COSTPRICE ELSE 0 END) OUTAMT,
                         SUM(s.AMT) AMT
                      FROM SECMAST s, sbsecurities b
                      WHERE TXDATE = V_TXDATE
                            and s.codeid = b.codeid
                            AND s.DELTD <> 'Y'
                      GROUP BY s.ACCTNO, nvl(b.REFCODEID,b.CODEID),s.ORDERID
                      )SEC, ODMAST OD, ODTYPE OT, VW_SEMAST_CUSTODYCD SE
                WHERE SEC.ORDERID = OD.ORDERID(+)
                    AND OD.ACTYPE = OT.ACTYPE(+)
                    AND SE.AFACCTNO = SEC.ACCTNO(+)
                    AND SE.CODEID = SEC.CODEID(+)
                    AND SE.AFACCTNO = V_STRAFACCTNO
                    AND SE.CODEID = V_STRSYMBOL
                    --AND ((SE.PREVQTTY)+(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) > 0
                GROUP BY SE.AFACCTNO, SE.CODEID, SE.CUSTODYCD;
                --having SUM(nvl(SEC.INQTTY,0)-nvl(SEC.OUTQTTY,0)-nvl(SEC.ODOUTQTTY,0)  +SE.PREVQTTY) > 0;
            EXCEPTION
                WHEN others THEN -- caution handles all exceptions
                V_RTCOSTPRICE := 0;
            END;

     else
       begin
        SELECT
            CASE WHEN (MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) = 0 THEN 0 ELSE
            ROUND(
            (MAX(SE.PREVQTTY*SE.COSTPRICE)
             +SUM((NVL(SEC.INAMT,0))
                - (NVL(SEC.ODOUTAMT,0))
                -(NVL(SEC.OUTAMT,0))
                +((NVL(OT.DEFFEERATE,0)/100)*(CASE WHEN OD.EXECTYPE LIKE '%S' THEN 0 ELSE NVL(OD.EXECAMT,0)END)))
                -sum(nvl(AMT,0)) --co tuc bang tien hay cac giao dich lien quan tien anh huong gia von
             )/(MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))),4
             )
            END
            AVGCOSTPRICE
        INTO V_RTCOSTPRICE
        FROM (SELECT ACCTNO, CODEID, ORDERID,
                 SUM(CASE WHEN PTYPE ='I' THEN QTTY ELSE 0 END) INQTTY,
                 SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NOT NULL THEN QTTY ELSE 0 END) ODOUTQTTY,
                 SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NULL THEN QTTY ELSE 0 END) OUTQTTY,
                 SUM(CASE WHEN PTYPE ='I' THEN QTTY*COSTPRICE ELSE 0 END) INAMT,
                 SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NOT NULL THEN QTTY*RTCOSTPRICE ELSE 0 END) ODOUTAMT,
                 SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NULL THEN QTTY*COSTPRICE ELSE 0 END) OUTAMT,
                 SUM(AMT) AMT
              FROM SECMAST
              WHERE TXDATE = V_TXDATE
                    AND DELTD <> 'Y'
              GROUP BY ACCTNO, CODEID, ORDERID
              )SEC, ODMAST OD, ODTYPE OT, VW_SEMAST_CUSTODYCD SE
        WHERE SEC.ORDERID = OD.ORDERID(+)
            AND OD.ACTYPE = OT.ACTYPE(+)
            AND SE.AFACCTNO = SEC.ACCTNO(+)
            AND SE.CODEID = SEC.CODEID(+)
            AND SE.AFACCTNO = V_STRAFACCTNO
            AND SE.CODEID = V_STRSYMBOL
            --AND ((SE.PREVQTTY)+(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) > 0
        GROUP BY SE.AFACCTNO, SE.CODEID, SE.CUSTODYCD;
        --having SUM(nvl(SEC.INQTTY,0)-nvl(SEC.OUTQTTY,0)-nvl(SEC.ODOUTQTTY,0)  +SE.PREVQTTY) > 0;
    EXCEPTION
        WHEN others THEN -- caution handles all exceptions
        V_RTCOSTPRICE := 0;
    END;

  end if;


    select secmast_seq.NEXTVAL into V_OUTID from dual;
    INSERT INTO secmast (AUTOID,TXNUM,TXDATE,ACCTNO,CODEID,TRTYPE,PTYPE,CAMASTID,ORDERID,QTTY,COSTPRICE,MAPQTTY,STATUS,MAPAVL,BUSDATE,DELTD,RTCOSTPRICE,AMT)
    VALUES (V_OUTID,V_STRTXNUM,V_TXDATE,V_STRAFACCTNO,V_STRSYMBOL,V_STRSECTYPE,V_STRPTYPE,V_STRCAMASTID,V_STRORDERID,V_NQTTY,V_NCOSTPRICE,0,'P',V_MAPAVL,V_BUSDATE,'N',V_RTCOSTPRICE,V_AMT);

    IF(PV_PTYPE = 'O')THEN
        secnet_map(V_STRAFACCTNO, V_STRSYMBOL, V_OUTID);
    END IF;
    -- goi dong bo lai bang buff
    jbpks_auto.pr_trg_account_log(V_STRAFACCTNO||V_STRSYMBOL,'SE');

EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            raise;
            return;
        END;
END;
 
/
