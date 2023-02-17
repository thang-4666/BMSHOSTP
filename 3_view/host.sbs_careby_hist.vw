SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SBS_CAREBY_HIST
(CUSTODYCD, FULLNAME, MAKER, MAKER_DT, APPROVER, 
 APPROVE_DT, ACTION_FLAG, FROM_VALUE, TO_VALUE)
BEQUEATH DEFINER
AS 
Select Cf.Custodycd,Cf.Fullname,Nl.Maker_Id || '-' || Tl.Tlname Maker,Nl.Maker_Dt,Nl.Approve_Id || '-' || Tl1.Tlname Approver,Nl.Approve_Dt,Nl.Action_Flag,Nl.From_Value || '-' || Gr1.Grpname From_Value,Nl.To_Value || '-' || Gr.Grpname To_Value
From Cfmast Cf,tlgroups gr,tlprofiles tl,tlprofiles tl1,tlgroups gr1,
      ( select distinct cf.custodycd,mt.maker_id,mt.maker_dt,mt.approve_id,mt.approve_dt,Action_Flag,from_value,to_value
        from maintain_log mt,cfmast cf,afmast af    
        where cf.custid = af.custid
            And Substr(Mt.Record_Key, 11, 10) = Af.Acctno  
            and column_name like '%CAREBY%'
            and mt.action_flag = 'ADD'
            and mt.mod_num =0
       ) Nl
Where  Cf.Custodycd = Nl.Custodycd 
      And Gr.Grpid = Nl.To_Value
      and gr1.grpid(+) = nl.from_value
      And Tl.Tlid = Nl.Maker_Id
      and tl1.tlid = nl.approve_id       

Union 

Select Cf.Custodycd,Cf.Fullname,Nl.Maker_Id || '-' || Tl.Tlname Maker,Nl.Maker_Dt,Nl.Approve_Id || '-' || Tl1.Tlname Approver,Nl.Approve_Dt,Nl.Action_Flag,Nl.From_Value || '-' || Gr1.Grpname From_Value,Nl.To_Value || '-' || Gr.Grpname To_Value
From Cfmast Cf,tlgroups gr,tlprofiles tl,tlprofiles tl1,tlgroups gr1,
      ( Select Distinct Cf.Custodycd,Mt.Maker_Id,Mt.Maker_Dt,Mt.Approve_Id,Mt.Approve_Dt,Action_Flag,from_value,to_value
        from maintain_log mt,cfmast cf,afmast af    
        where cf.custid = af.custid
            And Substr(Mt.Record_Key, 11, 10) = Af.Acctno  
            and column_name like '%CAREBY%'
            And Mt.Action_Flag = 'EDIT'
            and mt.mod_num = 1
       ) Nl
Where  Cf.Custodycd = Nl.Custodycd   
      And Gr.Grpid = Nl.To_Value
      and gr1.grpid(+) = nl.from_value
      And Tl.Tlid = Nl.Maker_Id
      And Tl1.Tlid = Nl.Approve_Id
/
