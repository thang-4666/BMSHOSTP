SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_HOLIDAY_ALL
(SBDATE, HOLIDAY)
BEQUEATH DEFINER
AS 
(
    select SBDATE, HOLIDAY 
    from sbcldr 
    where cldrtype = '000'
        and holiday = 'Y'
)
/
