SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('BONDCLEARINGSTARTTIME','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('SYSTEM', 'BONDCLEARINGSTARTTIME', '08:31:00', 'Thời gian bắt đầu thực hiện thanh toán bù trừ TP T+1.5 (HH24:MI:SS)', 'Start Time to make payment Bond T+1.5 (HH24:MI:SS)', 'Y', 'A', 'APAPAPAP');COMMIT;