SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_ALLOCATE_RIGHT_STOCK"
   IS
BEGIN


    for recSTSCHD in (
        SELECT * FROM STSCHD WHERE DUETYPE='RM' AND DELTD <> 'Y' AND STATUS='N' ORDER BY AFACCTNO,CODEID,ORGORDERID
    )
    LOOP

        for rec in (
            SELECT * FROM SEPITLOG WHERE AFACCTNO=recSTSCHD.afacctno AND CODEID=recSTSCHD.codeid AND QTTY-MAPQTTY>0
                AND STATUS <> 'C' AND DELTD <> 'Y' ORDER BY TXDATE, TXNUM
        )
        loop


            IF recSTSCHD.QTTY - recSTSCHD.RIGHTQTTY < rec.QTTY-rec.MAPQTTY then
                UPDATE STSCHD SET RIGHTQTTY= RIGHTQTTY + recSTSCHD.QTTY - recSTSCHD.RIGHTQTTY
                    WHERE DUETYPE='RM' AND ORGORDERID=recSTSCHD.orgorderid AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND
                    DELTD <> 'Y' AND STATUS='N';

                UPDATE SEPITLOG SET MAPQTTY= MAPQTTY + recSTSCHD.QTTY - recSTSCHD.RIGHTQTTY
                    WHERE AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum;

                EXIT;

            else --recSTSCHD.QTTY - recSTSCHD.RIGHTQTTY >= rec.QTTY-rec.MAPQTTY then

                UPDATE STSCHD SET RIGHTQTTY = RIGHTQTTY + rec.qtty - rec.mapqtty
                    WHERE DUETYPE='RM' AND ORGORDERID=recSTSCHD.orgorderid AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND
                    DELTD <> 'Y' AND STATUS='N';

                UPDATE SEPITLOG SET MAPQTTY = MAPQTTY + rec.qtty - rec.mapqtty, STATUS='C' WHERE
                    AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND TXDATE= rec.txdate AND TXNUM=rec.txnum;

            end if;


        End loop;


/*
    UPDATE STSCHD SET RIGHTQTTY= DECODE(SIGN(QTTY-rec.qtty-rec.mapqtty), 1, rec.qtty-rec.mapqtty,0,rec.qtty-rec.mapqtty,-, QTTY)
    WHERE DUETYPE='RM' AND AFACCTNO=rec.afacctno AND CODEID=rec.codeid AND DELTD <> 'Y' AND STATUS='N';
  */
   End loop;

   EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
END;

 
 
 
 
/
