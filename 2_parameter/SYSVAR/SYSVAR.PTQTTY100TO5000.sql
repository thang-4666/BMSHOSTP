SET DEFINE OFF;DELETE FROM SYSVAR WHERE 1 = 1 AND NVL(VARNAME,'NULL') = NVL('PTQTTY100TO5000','NULL');Insert into SYSVAR   (GRNAME, VARNAME, VARVALUE, VARDESC, EN_VARDESC, EDITALLOW, STATUS, PSTATUS) Values   ('OD', 'PTQTTY100TO5000', '444,003,006,222,333,012', 'Các loại CK(SECTYPE) được phép đặt lệnh thỏa thuận có SL: 100<=SL<5000', 'cac loai CK(SECTYPE) dc phep dat lenh thoa thuan co SL: 100<=SL<5000', 'N', 'A', '');COMMIT;