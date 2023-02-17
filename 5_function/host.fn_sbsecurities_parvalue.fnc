SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_SBSECURITIES_PARVALUE (P_SECTYPE IN VARCHAR2, P_PARVALUE IN NUMBER) RETURN NUMBER
IS
    l_return NUMBER;
    V_SECTYPE VARCHAR2(10);

BEGIN
    V_SECTYPE := NVL(P_SECTYPE,'XXX');

    IF    V_SECTYPE <> 'XXX' then

         IF P_PARVALUE = 0 OR (P_PARVALUE = 10000 AND V_SECTYPE='003')
            OR (P_PARVALUE = 10000 AND V_SECTYPE='006')
            OR (P_PARVALUE = 100000 AND V_SECTYPE <> '003')
            OR (P_PARVALUE = 100000 AND V_SECTYPE <> '006') THEN

               IF V_SECTYPE='003' OR V_SECTYPE='006' THEN
                 l_return:=100000;
               ELSE
                 l_return:=10000;
               END IF;
         ELSE
             l_return:=P_PARVALUE;

         END IF;

    END IF;

    RETURN l_return;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
