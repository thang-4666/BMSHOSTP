SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_calculatorSE_Rate(PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
                                                pv_afacctno     IN VARCHAR2,
                                                pv_totalamt          IN NUMBER,
                                                pv_type         IN  VARCHAR2,
                                                pv_editsymbol   IN VARCHAR2,
                                                pv_editquantity IN NUMBER,
                                                pv_editprice    IN number
                                                )
IS
    v_totalamt              NUMBER;
    v_quantity              NUMBER;
    v_oldquantity           NUMBER;
    v_oldprice              NUMBER;
BEGIN
    v_totalamt := pv_totalamt;
    IF pv_type = 'A' THEN
        DELETE FROM calculatorse_temp;
        INSERT INTO calculatorse_temp(afacctno, symbol, codeid, quantity, price, amt)
         SELECT se.afacctno, si.symbol, si.codeid, 0, least(si.MARGINCALLPRICE,nvl(rsk1.mrpricerate,0)), 0
         FROM
         securities_info si, afserisk rsk1,
         (SELECT se.afacctno, af.actype, se.codeid, se.trade FROM semast se, afmast af WHERE se.afacctno = af.acctno) se
            WHERE se.codeid = si.codeid
            AND se.actype = rsk1.actype(+)
            AND se.codeid = rsk1.codeid(+)
            AND se.afacctno = pv_afacctno
            AND se.trade > 0
            ORDER BY trade DESC;
        FOR rec in(
            SELECT se.afacctno, si.symbol, si.codeid, 0, least(si.MARGINCALLPRICE,nvl(rsk1.mrpricerate,0)) margincallprice, se.trade
             FROM
             securities_info si, afserisk rsk1,
             (SELECT se.afacctno, af.actype, se.codeid, se.trade FROM semast se, afmast af WHERE se.afacctno = af.acctno) se
                WHERE se.codeid = si.codeid
                AND se.actype = rsk1.actype(+)
                AND se.codeid = rsk1.codeid(+)
                AND se.afacctno = pv_afacctno
                AND se.trade > 0
                ORDER BY trade DESC)
        LOOP
            IF rec.trade * rec.margincallprice >= v_totalamt THEN
                v_quantity := ceil(v_totalamt/rec.margincallprice);
                UPDATE calculatorse_temp SET
                    quantity = v_quantity,
                    price = rec.margincallprice,
                    amt = v_quantity * rec.margincallprice
                WHERE codeid = rec.codeid;
                EXIT;
            ELSE
                v_totalamt := v_totalamt - rec.trade* rec.margincallprice;
                UPDATE calculatorse_temp SET
                    quantity = rec.trade,
                    price = rec.margincallprice,
                    amt = rec.trade * rec.margincallprice
                WHERE codeid = rec.codeid;
            END IF;
        END LOOP;

     ELSIF pv_type = 'E' THEN
        --Tinh cho truong hop thay doi SL CK
        FOR rec IN (SELECT se.afacctno, si.symbol, si.codeid, 0, least(si.MARGINCALLPRICE,nvl(rsk1.mrpricerate,0)) marginprice, se.trade, c.price, c.quantity
                    FROM securities_info si, afserisk rsk1, calculatorse_temp c,
                     (SELECT se.afacctno, af.actype, se.codeid, se.trade FROM semast se, afmast af WHERE se.afacctno = af.acctno) se
                        WHERE se.codeid = si.codeid
                        AND se.actype = rsk1.actype(+)
                        AND se.codeid = rsk1.codeid(+)
                        AND se.afacctno = pv_afacctno
                        AND se.codeid = c.codeid
                        AND se.trade > 0
                        ORDER BY trade DESC)
        LOOP
            IF rec.symbol = pv_editsymbol THEN
                v_totalamt := v_totalamt - pv_editquantity * pv_editprice;
                UPDATE calculatorse_temp SET
                    quantity = pv_editquantity,
                    price = pv_editprice,
                    amt = pv_editquantity * pv_editprice
                WHERE codeid = rec.codeid;
            ELSE
                --Neu SL = 0, lay SL trong semast, neu khong, lay SL trong bang tam
                IF rec.quantity = 0 THEN
                    v_oldquantity := rec.trade;
                ELSE
                    v_oldquantity := rec.quantity;
                END IF;
                --Neu gia khong thay doi, lay gia trong semast, neu thay doi, lay trong bang tam
                IF rec.marginprice <> rec.price THEN 
                    v_oldprice := rec.price;
                ELSE 
                    v_oldprice := rec.marginprice;
                END IF;
                
                IF v_oldquantity * v_oldprice >= v_totalamt THEN
                    v_quantity := ceil(v_totalamt/v_oldprice);
                    UPDATE calculatorse_temp SET
                        quantity = v_quantity,
                        price = v_oldprice,
                        amt = v_quantity * v_oldprice
                    WHERE codeid = rec.codeid;
                    EXIT;
                ELSE
                    v_totalamt := v_totalamt - v_oldquantity * v_oldprice;
                    UPDATE calculatorse_temp SET
                        quantity = rec.quantity,
                        price = v_oldprice,
                        amt = rec.quantity * v_oldprice
                    WHERE codeid = rec.codeid;
                END IF;
            END IF;
        END LOOP;
    END IF;

    OPEN PV_REFCURSOR for
        SELECT ROWNUM ordernumber, afacctno, symbol, codeid, quantity, price, amt FROM calculatorse_temp;
END;
 
 
 
 
/
