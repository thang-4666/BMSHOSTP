SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('QTTYTYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('SE','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '000', 'CK giao dịch lô lẻ', 0, 'Y', 'CK giao dịch lô lẻ', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '001', 'CK chuyển nhượng tự do', 1, 'Y', 'CK chuyển nhượng tự do', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '002', 'CK hạn chế chuyển nhượng', 2, 'Y', 'CK hạn chế chuyển nhượng', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '003', 'CK ưu đãi biểu quyết', 3, 'Y', 'CK ưu đãi biểu quyết', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '004', 'CK ưu đãi cổ tức', 4, 'Y', 'CK ưu đãi cổ tức', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '005', 'CK ưu đãi hoàn lại', 5, 'Y', 'CK ưu đãi hoàn lại', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '006', 'CK có đk khác', 6, 'Y', 'CK có đk khác', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SE', 'QTTYTYPE', '007', 'Chứng khoán phong tỏa', 7, 'Y', 'Chứng khoán phong tỏa', 'C');COMMIT;