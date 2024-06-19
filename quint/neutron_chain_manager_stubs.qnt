module neutron_chain_manager {
  
  import basicSpells.* from "./lib/basicSpells"
  import cw_types.* from "./lib/cw_types"
  import cw_utils.* from "./lib/cw_utils"
  import messaging.* from "./lib/messaging"
  import bank from "./lib/bank"

  
  var contract_state: ContractState
  var result: Result
  var bank: bank::Bank
  var time: int

  
  pure val CONTRACT_ADDRESS = "contract0"

  
  pure val ADDRESSES = Set("sender1", "sender2", "sender3", CONTRACT_ADDRESS)
  pure val DENOMS = Set("d1", "uawesome")
  pure val MAX_AMOUNT = 200

  // add here all possible strategies that should be included
  pure val ALL_POSSIBLE_STRATEGIES = Set()

  // add here all possible cosmos messages for which we want to test
  pure val ALL_COSMOS_MESSAGES = Set()

  // setting the strings that were not generated to be strings for now, 
  // later we may refine it as necessary
  type NeutronMsg = str
  type AdminProposal = str
  type ProposalExecuteMessage = str


  type InstantiateMsg = { initial_strategy_address: Addr, initial_strategy: Strategy }
  type MigrateMsg = {  }
  type ParamChangePermission = { params: List[ParamPermission] }
  type ParamPermission = { subspace: str, key: str }
  type CronUpdateParamsPermission = { security_address: bool, limit: bool }
  type CronPermission = { add_schedule: bool, remove_schedule: bool }
  type ProposalExecuteMessageJSON = { type_field: str }
  type MsgUpdateParamsCron = { params: ParamsCron }
  type ParamsCron = { security_address: str, limit: int }
  
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
  pure def instantiate(state: ContractState, _env: Env, _info: MessageInfo, msg: InstantiateMsg): (Result[Response, ContractError], ContractState) = {
    // TODO: Update body
    (Ok(Response_new), state)
  }

  pure def execute(state: ContractState, _env: Env, info: MessageInfo, msg: ExecuteMsg): (Result[Response, ContractError], ContractState) = match msg {
    | ExecuteMsg_AddStrategy(__r) => execute_add_strategy(state, info, __r.address, __r.strategy)
    | ExecuteMsg_RemoveStrategy(__r) => execute_remove_strategy(state, info, __r.address)
    | ExecuteMsg_ExecuteMessages(__r) => execute_execute_messages(state, info, __r.messages)
  }

  pure def execute_add_strategy(
    state: ContractState, 
    info: MessageInfo, 
    address: Addr, 
    strategy: Strategy): (Result[Response, ContractError], ContractState) = {
    // TODO: Update body
    (Ok(Response_new), state)
  }
                            
  action execute_add_strategy_action = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT
    nondet message_address: Addr = Set("s1", "s2", "s3").oneOf()
    // TODO: add a set of strategies to choose from
    nondet message_strategy: Strategy = ALL_POSSIBLE_STRATEGIES.oneOf()
    pure val message: ExecuteMsg = ExecuteMsg_AddStrategy({ address: message_address, strategy: message_strategy })
    execute_message(message, max_funds)
  }

  pure def execute_remove_strategy(
    state: ContractState, 
    info: MessageInfo, 
    address: Addr
    ): (Result[Response, ContractError], ContractState) = {
    // TODO: Update body
    (Ok(Response_new), state)
  }
                            
  action execute_remove_strategy_action = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT
    nondet message_address: Addr = Set("s1", "s2", "s3").oneOf()
    pure val message: ExecuteMsg = ExecuteMsg_RemoveStrategy({ address: message_address })
    execute_message(message, max_funds)
  }

  pure def execute_execute_messages(
    state: ContractState, 
    info: MessageInfo, 
    messages: List[CosmosMsg]): (Result[Response, ContractError], ContractState) = {
    // TODO: Update body
    (Ok(Response_new), state)
  }
                            
  action execute_execute_messages_action = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT

    // TODO: Change this line to include messages you want to test with
    nondet message_messages: List[CosmosMsg] = ALL_COSMOS_MESSAGES.allListsUpTo(2).oneOf()
    pure val message: ExecuteMsg = ExecuteMsg_ExecuteMessages({ messages: message_messages })
    execute_message(message, max_funds)
  }


  pure def is_authorized(state: ContractState, address: Addr): Result[Response, ContractError] = 
    // TODO: stub, fill in based on the code
    Ok(Response_new)

  pure def no_admins_left(state: ContractState): Result[bool, ContractError] = 
    // TODO: stub, fill in based on the code
    Ok(true)

  pure def check_allow_only_permissions(
    state: ContractState, 
    strategy: Strategy, 
    messages: List[CosmosMsg]): Result[(), ContractError] = 

    // TODO: stub, fill in based on the code
    Ok(())


  pure def check_neutron_msg(state: ContractState, strategy: Strategy, neutron_msg: NeutronMsg): Result[(), ContractError] = 
    // TODO: stub, fill in based on the code
    Ok(())

  pure def check_submit_admin_proposal_message(
    state: ContractState, 
    strategy: Strategy, 
    proposal: AdminProposal): Result[(), ContractError] = 
    // TODO: stub, fill in based on the code
    Ok(())

  pure def check_proposal_execute_message(
    state: ContractState, 
    strategy: Strategy, 
    proposal: ProposalExecuteMessage): Result[(), ContractError] = 
    // TODO: stub, fill in based on the code
    Ok(())

  pure def check_cron_update_msg_params(
    state: ContractState, 
    strategy: Strategy, 
    proposal: ProposalExecuteMessage): Result[(), ContractError] = 
    // TODO: stub, fill in based on the code
    Ok(())

  
                            
  // this is likely not needed, but leaving it for now
  pure val CONTRACT_NAME = "crates.io:neutron-chain-manager"
  pure val CONTRACT_VERSION = "0.3.0"
  pure val PARAMS_QUERY_PATH_CRON = "/neutron.cron.Query/Params"
  pure val MSG_TYPE_UPDATE_PARAMS_CRON = "/neutron.cron.MsgUpdateParams"

  type ContractState = {
    strategies: Addr -> Strategy
  }

  pure val init_contract_state: ContractState = {
    strategies: Map()
  }

  action execute_step = all {
    any {
      execute_add_strategy_action,
      execute_remove_strategy_action,
      execute_execute_messages_action      
    },
    advance_time,
  }

  pure def reply(state: ContractState, _env: Env, _reply: Reply): (Result, ContractState) = (Ok(Response_new), state)


  pure val init_bank_state = ADDRESSES.mapBy(_ => DENOMS.mapBy(_ => MAX_AMOUNT))

  val env_val = { block: { time: time, height: 1 } } // TODO: Add a height var if you need it

  action init = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = 0

    nondet sender = Set("admin").oneOf()
    nondet denom = DENOMS.oneOf()
    nondet amount = 0.to(max_funds).oneOf()
    val funds = [{ denom: denom, amount: amount }]
    val info = { sender: sender, funds: funds }

    pure val message: InstantiateMsg = { initial_strategy_address: "s1", initial_strategy: Strategy_AllowAll }
    pure val r = instantiate(init_contract_state, { block: { time: 0, height: 1 } }, info, message)

    all {
      contract_state' = r._2,
      bank' = init_bank_state,
      result' = r._1,
      time' = 0,
    }
  }


  action execute_message(message, max_funds) = {
    nondet sender = ADDRESSES.oneOf()
    nondet denom = DENOMS.oneOf()
    nondet amount = 0.to(max_funds).oneOf()
    val funds = [{ denom: denom, amount: amount }]
    val info = { sender: sender, funds: funds }

    val r = execute(contract_state, env_val, info, message)
    all {
      bank.get(sender).get(denom) >= amount,
      match r._1 {
        | Ok(_) => bank' = bank.setBy(sender, balances => balances.setBy(denom, balance => balance - amount))
                               .setBy(CONTRACT_ADDRESS, balances => balances.setBy(denom, balance => balance + amount))
        | Err(_) => bank' = bank
      },
      result' = r._1,
      contract_state' = r._2,
    }
  }

  action advance_time = time' = time + 1

  action step = {
    val message_getting = get_message(result)
    val new_result = message_getting._1
    val opt_message = message_getting._2
    match opt_message {
      | Some(submsg) => {
          val current_state = { bank: bank, result: new_result, contract_state: contract_state }
          val new_state = process_message(current_state, env_val, CONTRACT_ADDRESS, submsg, reply)
          all {
            bank' = new_state.bank,
            result' = new_state.result,
            contract_state' = new_state.contract_state,
            advance_time,
          }
      }
      | None => execute_step
    }
  }

}
