SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('CATYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('CA','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '005', 'Tham dự đại hội cổ đông', 5, 'Y', 'Metting', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '006', 'Lấy ý kiến cổ đông', 6, 'Y', 'Voting', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '010', 'Chia cổ tức bằng tiền', 10, 'Y', 'Cash dividend', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '011', 'Chia cổ tức bằng cổ phiếu', 11, 'Y', 'Share dividend', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '014', 'Quyền mua', 14, 'Y', 'Rights issue', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '015', 'Trả lãi trái phiếu', 15, 'Y', 'Bond interest', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '016', 'Trả gốc và lãi trái phiếu', 16, 'Y', 'Bond interest and principal', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '017', 'Chuyển đổi trái phiếu thành cổ phiếu', 17, 'Y', 'Convert bond to share', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '019', 'Chuyển sàn', 19, 'Y', 'PGD Giảng Võ test', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '020', 'Chuyển đổi cổ phiếu thành cổ phiếu', 20, 'Y', 'Convert share to share', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '021', 'Cổ phiếu thưởng', 21, 'Y', 'Stock bonus', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '022', 'Quyền bỏ phiếu', 22, 'Y', 'Right to vote', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '023', 'Chuyển đổi Trái phiếu– Chọn nhận CP hoặc Tiền', 23, 'Y', 'Convert bond - Choose share or cash', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '026', 'Chuyển cổ phiếu chờ giao dịch thành giao dịch', 26, 'Y', 'Waiting for trade listed', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '027', 'Trả lãi trái phiếu OTC', 27, 'Y', 'Bond interest OTC', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('CA', 'CATYPE', '028', 'Chi trả lợi tức chứng quyền', 28, 'Y', 'Payout of the warrant certificate', 'C');COMMIT;