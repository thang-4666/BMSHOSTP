SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SIMPLEORDERFEECALCULATE" (indate IN VARCHAR2, ERR_CODE out Varchar2)
IS
BEGIN

--Cap nhat feeacr
   UPDATE odmast
      SET feeacr =
               feeacr
             +   (execamt - examt)
               / 100
               * NVL
                    ((SELECT iccfrate
                        FROM (SELECT od.orderid,
                                     od.execamt - od.examt iccfamt,
                                     iccf.rate iccfrate
                                FROM odmast od,
                                     (SELECT typedef.actype,
                                               typedef.icrate
                                             + NVL (tier.delta, 0) rate,
                                             NVL (framt, -1) framt,
                                             (CASE
                                                 WHEN NVL (toamt, -1) = -1
                                                    THEN 10000000000000
                                                 ELSE NVL (toamt, -1)
                                              END
                                             ) toamt
                                        FROM (SELECT    modcode
                                                     || actype
                                                     || eventcode iccfcode,
                                                     actype, icrate, deltd,
                                                     ruletype,modcode
                                                FROM iccftypedef) typedef,
                                             (SELECT    modcode
                                                     || actype
                                                     || eventcode iccfcode,
                                                     delta, framt, toamt
                                                FROM iccftier) tier
                                       WHERE typedef.iccfcode = tier.iccfcode(+)
                                         AND typedef.deltd <> 'Y'
                                         AND typedef.ruletype = 'T'
                                         and typedef.modcode ='OD'
                                      UNION
                                      SELECT typedef.actype,
                                             typedef.icrate rate, -1 framt,
                                             10000000000000 toamt
                                        FROM iccftypedef typedef
                                       WHERE typedef.deltd <> 'Y'
                                         AND typedef.ruletype = 'F'
                                         and typedef.modcode ='OD') iccf
                               WHERE od.actype = iccf.actype
                                 AND od.execamt - od.examt > 0
                                 AND od.deltd <> 'Y'
                                 AND od.txdate = to_date(indate,'DD/MM/YYYY')
                                 AND iccf.framt < (od.execamt - od.examt)
                                 AND iccf.toamt >= (od.execamt - od.examt)) ic
                       WHERE ic.orderid = odmast.orderid),
                     0
                    );

--Cap nhat examt
   UPDATE odmast
      SET examt =
               examt
             + NVL
                  ((SELECT iccfamt
                      FROM (SELECT od.orderid, od.execamt - od.examt iccfamt,
                                   iccf.rate iccfrate
                              FROM odmast od,
                                   (SELECT typedef.actype,
                                             typedef.icrate
                                           + NVL (tier.delta, 0) rate,
                                           NVL (framt, -1) framt,
                                           (CASE
                                               WHEN NVL (toamt, -1) = -1
                                                  THEN 10000000000000
                                               ELSE NVL (toamt, -1)
                                            END
                                           ) toamt
                                      FROM (SELECT    modcode
                                                   || actype
                                                   || eventcode iccfcode,
                                                   actype, icrate, deltd,
                                                   ruletype,modcode
                                              FROM iccftypedef) typedef,
                                           (SELECT    modcode
                                                   || actype
                                                   || eventcode iccfcode,
                                                   delta, framt, toamt
                                              FROM iccftier) tier
                                     WHERE typedef.iccfcode = tier.iccfcode(+)
                                       AND typedef.deltd <> 'Y'
                                       AND typedef.ruletype = 'T'
                                       and typedef.modcode ='OD'
                                    UNION
                                    SELECT typedef.actype,
                                           typedef.icrate rate, -1 framt,
                                           10000000000000 toamt
                                      FROM iccftypedef typedef
                                     WHERE typedef.deltd <> 'Y'
                                       AND typedef.ruletype = 'F'
                                       and typedef.modcode ='OD') iccf
                             WHERE od.actype = iccf.actype
                               AND od.execamt - od.examt > 0
                               AND od.deltd <> 'Y'
                               AND od.txdate = to_date(indate,'DD/MM/YYYY')
                               AND iccf.framt < (od.execamt - od.examt)
                               AND iccf.toamt >= (od.execamt - od.examt)) ic
                     WHERE ic.orderid = odmast.orderid),
                   0
                  );
    err_code:='0';
EXCEPTION
   WHEN OTHERS
   THEN
   	  err_code:='-1';
      RETURN;
END;

 
 
 
 
/
