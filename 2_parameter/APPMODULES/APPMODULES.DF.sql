SET DEFINE OFF;DELETE FROM APPMODULES WHERE 1 = 1 AND NVL(MODCODE,'NULL') = NVL('DF','NULL');Insert into APPMODULES   (TXCODE, MODCODE, MODNAME, CLASSNAME) Values   ('26', 'DF', 'Vay theo deal', 'DF');COMMIT;