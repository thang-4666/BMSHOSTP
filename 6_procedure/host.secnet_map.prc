SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE secnet_map (pv_strAfAcctno IN VARCHAR2, pv_symbol in varchar2, PV_OUTID in number)
IS
-- Purpose:
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- DUNGNH      06/08/2013
-- ---------   ------  -------------------------------------------
    v_strCurAcctno  Varchar2(10);
    v_bCheck        Boolean;
    v_nO_REFID int;
    v_nO_QTTY       number(30,0);
    v_nO_AMT        number(30,2);
    v_nO_COSTPRICE  number(20,4);
    v_dO_TxDate     DATE;
    v_nI_REFID      int;
    v_nI_QTTY       number(30,0);
    v_nI_AMT        number(20,2);
    v_nI_COSTPRICE  number(20,4);
    v_dI_TxDate     DATE;

    v_nNETQTTY      number(10,0);
    v_dNETDATE      DATE;

    v_strSymbol     Varchar2(30);

    CURSOR curSECIN IS
        SELECT AUTOID, qtty-mapqtty REMAIN_QTTY, BUSDATE, costprice costprice
        FROM secmast WHERE ACCTNO = pv_strAfAcctno AND codeid = v_strSymbol
            AND PTYPE = 'I' AND mapavl = 'Y' AND deltd = 'N' AND qtty > 0 and qtty-mapqtty <> 0
        ORDER BY BUSDATE, AUTOID, TXNUM;

    CURSOR curSECOUT IS
        SELECT AUTOID, qtty-mapqtty REMAIN_QTTY, BUSDATE, costprice costprice
        FROM secmast WHERE ACCTNO = pv_strAfAcctno AND codeid = v_strSymbol
            AND PTYPE = 'O' AND mapavl = 'Y' AND deltd = 'N' AND qtty > 0 and qtty-mapqtty <> 0
            and autoid = PV_OUTID
        ORDER BY BUSDATE,AUTOID, TXNUM;
BEGIN
    v_strSymbol := pv_symbol;
        --XU LY GHEP
        OPEN curSECOUT;
        OPEN curSECIN;
        v_bCheck := false;
        v_nI_QTTY := 0;
        LOOP
            FETCH curSECOUT INTO v_nO_REFID, v_nO_QTTY, v_dO_TxDate, v_nO_COSTPRICE;
            EXIT WHEN curSECOUT%NOTFOUND OR v_bCheck;   --Het ben OUT

            WHILE v_nO_QTTY > 0 and v_bCheck = false
            LOOP
                if v_nI_QTTY = 0 then
                    --Lay tung dong in
                    FETCH curSECIN INTO v_nI_REFID, v_nI_QTTY, v_dI_TxDate, v_nI_COSTPRICE;
                    if curSECIN%NOTFOUND then
                        v_bCheck := true;   --Het ben in
                    end if;
                end if;
                --map trang thai.
                if v_bCheck = false then
                    begin
                        IF v_dO_TxDate > v_dI_TxDate THEN
                           v_dNETDATE := v_dO_TxDate;
                        ELSE
                           v_dNETDATE := v_dI_TxDate;
                        END IF;
                        IF v_nO_QTTY > v_nI_QTTY THEN
                           v_nNETQTTY := v_nI_QTTY;
                        ELSE
                           v_nNETQTTY := v_nO_QTTY;
                        END IF;
                        v_nI_QTTY := v_nI_QTTY - v_nNETQTTY;
                        v_nO_QTTY := v_nO_QTTY - v_nNETQTTY;

                        ---moi lan map voi mot lan IN se tao 1 dong trong secnet.
                        INSERT INTO secnet (AUTOID,INID,OUTID,NETDATE,ACCTNO,CODEID,NETQTTY,INAMT,OUTAMT,DELTD)
                        values (secnet_seq.NEXTVAL,v_nI_REFID,v_nO_REFID,v_dNETDATE, pv_strAfAcctno,v_strSymbol,v_nNETQTTY, v_nI_COSTPRICE*v_nNETQTTY, v_nO_COSTPRICE*v_nNETQTTY,'N');
                        --- end insert secnet.

                        update secmast set mapqtty = mapqtty + v_nNETQTTY where autoid = v_nI_REFID;
                        update secmast set mapqtty = mapqtty + v_nNETQTTY where autoid = v_nO_REFID;

                        ---cap nhat trang thai khi da net het(co the de trong batch).
                        update secmast set status = (case when qtty-mapqtty = 0 then 'C' else status end)
                        where autoid = v_nI_REFID;
                        update secmast set status = (case when qtty-mapqtty = 0 then 'C' else status end)
                        where autoid = v_nO_REFID;
                        ---end cap nhat trang thai
                    end;
                end if;
            END LOOP;
        END LOOP;
        CLOSE curSECIN;
        CLOSE curSECOUT;
EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            raise;
            return;
        END;
END;

 
 
 
 
/
