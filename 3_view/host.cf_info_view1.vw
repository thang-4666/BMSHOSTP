SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CF_INFO_VIEW1
(PHONE, CLASS, TEXT)
BEQUEATH DEFINER
AS 
select distinct phone,class,text from 
(select cf.mobilesms phone
        ,a.cdcontent class
        , af.acctno||' '||cf.fullname ||' '||cf.pin    text
From cfmast cf, afmast af,allcode a
where cf.custid=af.custid
and a.cdtype='CF'
and a.cdname='CLASS'
and a.cdval=cf.class
union all
select cf.mobilesms phone
        ,a.cdcontent class
        , af.acctno||' '||cf.fullname ||' '||cf.pin    text
From cfmast cf, afmast af,allcode a
where cf.custid=af.custid
and a.cdtype='CF'
and a.cdname='CLASS'
and a.cdval=cf.class)
where phone is not null
order by phone
/
