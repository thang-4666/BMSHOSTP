SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('BONDCLEARINGENDTIME','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'BONDCLEARINGENDTIME', '18:31:00', 'Thời gian kết thúc thực hiện thanh toán bù trừ TP T+1.5 (HH24:MI:SS)', 'Stop Time to make payment Bond T+1.5 (HH24:MI:SS)', 'Y', 'A', 'AP');COMMIT;