SET DEFINE OFF;DELETE FROM FILEMAP WHERE 1 = 1 AND NVL(FILECODE,'NULL') = NVL('C028','NULL');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('C028', 'MANHOM', 'MANHOM', 'C', 'Y', 500, 'U', 'N', 'Y', 'Y', 0, '', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('C028', 'TENNHOM', 'TENNHOM', 'C', 'Y', 500, 'U', 'N', 'Y', 'Y', 0, '', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('C028', 'NHOMCHA', 'NHOMCHA', 'C', 'Y', 500, 'U', 'N', 'Y', 'Y', 0, '', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('C028', 'LOAIHINHNHOM', 'LOAIHINHNHOM', 'C', 'Y', 500, 'U', 'N', 'Y', 'Y', 0, '', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('C028', 'KIEUNHOM', 'KIEUNHOM', 'C', 'Y', 500, 'U', 'N', 'Y', 'Y', 0, '', 'N');Insert into FILEMAP   (FILECODE, FILEROWNAME, TBLROWNAME, TBLROWTYPE, ACCTNOFLD, TBLROWMAXLENGTH, CHANGETYPE, DELTD, DISABLED, VISIBLE, LSTODR, FIELDDESC, SUMAMT) Values   ('C028', 'MATRUONGNHOM', 'MATRUONGNHOM', 'C', 'Y', 500, 'U', 'N', 'Y', 'Y', 0, '', 'N');COMMIT;