SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_USERLOGINOLCV
(USERNAME, PASSWORD, USERLOGIN)
BEQUEATH DEFINER
AS 
select username, nvl( loginpwd,' ') password, nvl(tradingpwd,' ') userlogin from userlogin 
order by username
/
