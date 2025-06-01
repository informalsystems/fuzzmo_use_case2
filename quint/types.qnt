module types {
  
  
  import cw_types.* from "./lib/cw_types"
  


  type InstantiateMsg = { initial_strategy_address: Addr, initial_strategy: Strategy }
  type MigrateMsg = {  }
  type ParamChangePermission = { params: List[ParamPermission] }
  type ParamPermission = { subspace: str, key: str }
  type CronUpdateParamsPermission = { security_address: bool, limit: bool }
  type CronPermission = { add_schedule: bool, remove_schedule: bool }
  type ProposalExecuteMessageJSON = { type_field: str }
  
  
  type ParamsRequestCron = {  }
  type ParamsResponseCron = { params: ParamsCron }

  type ExecuteMsg =
    | ExecuteMsg_AddStrategy({ address: Addr, strategy: Strategy })
    | ExecuteMsg_RemoveStrategy({ address: Addr })
    | ExecuteMsg_ExecuteMessages({ messages: List[CosmosMsg] })
  type Strategy =
    | Strategy_AllowAll
    | Strategy_AllowOnly(List[Permission])
  type Permission =
    | Permission_ParamChangePermission(ParamChangePermission)
    | Permission_UpdateParamsPermission(UpdateParamsPermission)
    | Permission_CronPermission(CronPermission)
  type UpdateParamsPermission =
    | UpdateParamsPermission_CronUpdateParamsPermission(CronUpdateParamsPermission)
    }