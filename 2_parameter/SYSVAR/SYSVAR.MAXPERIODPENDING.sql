SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('MAXPERIODPENDING','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('MARGIN', 'MAXPERIODPENDING', '3', 'Số ngày tối đa chờ trước khi xử lý trên hệ thống', 'Max pending days before liquiding', 'N', 'A', 'P');COMMIT;