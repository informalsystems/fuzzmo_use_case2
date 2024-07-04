module neutron_chain_manager {
  
  import basicSpells.* from "./lib/basicSpells"
  import cw_types.* from "./lib/cw_types"
  import cw_utils.* from "./lib/cw_utils"
  import messaging.* from "./lib/messaging"
  import bank from "./lib/bank"
  import types.* from "./types"

  
  var contract_state: ContractState
  var result: Result
  var bank: bank::Bank
  var time: int
  var actionTakenType: str
  var chosenSender: str

  
  pure val CONTRACT_ADDRESS = "contract0"

  
  pure val ADDRESSES = Set("sender1", "sender2", "sender3", CONTRACT_ADDRESS)
  pure val DENOMS = Set("d1", "uawesome")
  pure val MAX_AMOUNT = 200

  // add here all possible strategies that should be included
  pure val ALL_POSSIBLE_STRATEGIES = 
    Set(
      Strategy_AllowAll, 
      Strategy_AllowOnly(
        [Permission_ParamChangePermission(
          {params: [{subspace: "subspace1", key: "key1"}]}
          // [{subspace: "subspace1", key: "key1"}]
          )]
      )
        
    )
      
      

  // add here all possible cosmos messages for which we want to test
  pure val ALL_COSMOS_MESSAGES = 
    Set(
      CosmosMsg_Custom(
        NeutronMsg_SubmitProposalExecuteMessage(
          ProposalExecuteMessage_Other("some other message")
        )
      )
    )

  // setting the strings that were not generated to be strings for now, 
  // later we may refine it as necessary
  
  pure def instantiate(state: ContractState, _env: Env, _info: MessageInfo, msg: InstantiateMsg): (Result[Response, ContractError], ContractState) = {
    match msg.initial_strategy {
      | Strategy_AllowAll => {
        val updated_state = { ...state, strategies: state.strategies.put(msg.initial_strategy_address, msg.initial_strategy) }
        (Ok(Response_new
          .add_attribute("action", FromStr("instantiate"))
          .add_attribute("init_allow_all_address", FromStr(msg.initial_strategy_address))),  updated_state)
      }
      | Strategy_AllowOnly(_) => (Err("InvalidInitialStrategy"), state)
    }
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

      // Check if sender is authorized
      match is_authorized(state, info.sender) {
        | Err(e) => (Err(e), state)
        | Ok(_) => {
          // Check if the strategy is 'AllowOnly' and there are still administrators left
          match strategy {
            | Strategy_AllowOnly(permissions) => {
              val new_state = { ...state, strategies: state.strategies.put(address, strategy) }
              val no_admins_left_res = no_admins_left(new_state)

              match no_admins_left_res {
                | Err(e) => (Err(e), state)
                | Ok(res) =>  if (res) {
                    (Err("Cannot remove last administrator"), state)
                  } else {
                    val response = Response_new
                      .add_attribute("action", FromStr("add_strategy"))
                      .add_attribute("address", FromStr(address))

                    (Ok(response), new_state)
                  }
              }
            }
            | _ => {
              val new_state = { ...state, strategies: state.strategies.put(address, strategy) }
              val response = Response_new
                .add_attribute("action", FromStr("execute_add_strategy"))
                .add_attribute("address", FromStr(address))

              (Ok(response), new_state)
            }
          }
        }
      }
    }
  
  action execute_add_strategy_action2 = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT
    pure val message_address: Addr = "sender2"
    // TODO: add a set of strategies to choose from
    val message_strategy: Strategy =       
      Strategy_AllowOnly([
        Permission_ParamChangePermission({params: [{subspace: "subspace1", key: "key1"}]})
    ])
    pure val message: ExecuteMsg = ExecuteMsg_AddStrategy({ address: message_address, strategy: message_strategy })
    execute_message(message, max_funds)
  }
                            
  action execute_add_strategy_action = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT
    nondet message_address: Addr = ADDRESSES.oneOf()
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
      // Check if sender is authorized
      match is_authorized(state, info.sender) {
        | Err(e) => (Err(e), state)
        | Ok(_) => {
          val new_state = { ...state, strategies: state.strategies.mapRemove(address) }
          val no_admins_left_res = no_admins_left(new_state)

          match no_admins_left_res {
            | Err(e) => (Err(e), state)
            | Ok(res) =>  if (res) {
                (Err("Cannot remove last administrator"), state)
              } else {
                val response = Response_new
                  .add_attribute("action", FromStr("execute_remove_strategy"))
                  .add_attribute("address", FromStr(address))

                (Ok(response), new_state)
              }
          }
        }
      }
    }
                            
  action execute_remove_strategy_action = {
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT
    nondet message_address: Addr = ADDRESSES.oneOf()
    pure val message: ExecuteMsg = ExecuteMsg_RemoveStrategy({ address: message_address })
    execute_message(message, max_funds)
  }

  pure def execute_execute_messages(
    state: ContractState, 
    info: MessageInfo, 
    messages: List[CosmosMsg]): (Result[Response, ContractError], ContractState) = {
    if (not(state.strategies.keys().contains(info.sender))) {
      (Err("Unauthorized"), state)
    } else {
      val strategy = state.strategies.get(info.sender)
      val response = Response_new
        .add_attribute("action", FromStr("execute_execute_messages"))
        .add_attribute("address", FromStr(info.sender))
      val response_with_messages = messages.foldl(response, (acc, msg) =>  acc.add_message(msg) )
      match strategy {
        | Strategy_AllowAll => (Ok(response_with_messages.add_attribute("strategy", FromStr("allow_all"))), state)
        | Strategy_AllowOnly(_) => {
          val check_res = check_allow_only_permissions(state, strategy, messages)
          match check_res {
            | Err(e) => (Err(e), state)
            | Ok(_) => (Ok(response_with_messages.add_attribute("strategy", FromStr("allow_only"))), state)
          }
        }
      }
    }
  }
                            
  action execute_execute_messages_action = {
    
    // TODO: Change next line according to fund expectations
    pure val max_funds = MAX_AMOUNT

    // TODO: Change this line to include messages you want to test with
    nondet message_messages: List[CosmosMsg] = ALL_COSMOS_MESSAGES.allListsUpTo(2).oneOf()
    pure val message: ExecuteMsg = ExecuteMsg_ExecuteMessages({ messages: message_messages })
    execute_message(message, max_funds)
  }


  pure def is_authorized(state: ContractState, address: Addr): Result[(), ContractError] = {
    if (not(state.strategies.keys().contains(address))) 
      Err("Unauthorized")
    else if (not(state.strategies.get(address) == Strategy_AllowAll))
      Err("Unauthorized")  
    else
      Ok(())    
  }

  pure def no_admins_left(state: ContractState): Result[bool, ContractError] = {
    val remaining_admins = state.strategies.keys().filter(addr => match state.strategies.get(addr) {
      | Strategy_AllowAll => true
      | _ => false
    })
    Ok(remaining_admins.size() == 0)
  }

  pure def check_allow_only_permissions(
    state: ContractState, 
    strategy: Strategy, 
    messages: List[CosmosMsg]): Result[(), ContractError] = 

    if (listForall(
      messages,
      m => match m {
          | CosmosMsg_Wasm(_) => true
          | CosmosMsg_Bank(_) => true
          | CosmosMsg_Custom(n) => 
          val c = check_neutron_msg(state, strategy, n)
          match c
          {
            | Err(e) => false
            | Ok(_) => true
          }      
      }
    ))   
             
      Ok(())
    else
      Err("Unauthorized")
    


  pure def check_neutron_msg(state: ContractState, strategy: Strategy, neutron_msg: NeutronMsg): Result[(), ContractError] = 
    match neutron_msg {
      | NeutronMsg_SubmitAdminProposal(p) => check_submit_admin_proposal_message(state, strategy, p)
      
      | NeutronMsg_SubmitProposalExecuteMessage(p) => check_proposal_execute_message(state, strategy, p)
      | NeutronMsg_CronUpdateParams(p) => check_cron_update_msg_params(state, strategy, p)
      // | _ => Ok(())
    }

  pure def has_param_change_permission(
    state: ContractState,
    strategy: Strategy,
    pc: ParamChange): bool = 
    match strategy {
      | Strategy_AllowAll => true
      | Strategy_AllowOnly(permissions) => 
        listExists(
          permissions,
          x => match x {
            | Permission_ParamChangePermission(p) => 
              listExists(
                p.params,
                y => y.subspace == pc.subspace and y.key == pc.key
              )
            | _ => false
          }
        )
    }
  

  pure def check_submit_admin_proposal_message(
    state: ContractState, 
    strategy: Strategy, 
    proposal: AdminProposal): Result[(), ContractError] = 
    // TODO: stub, fill in based on the code
    match proposal {
      | Proposal_ParamChangeProposal(p) => 
        val allow = listForall(
          p.param_changes,
          x => has_param_change_permission(state, strategy, x)
          )
        if (allow)
          Ok(())
        else
          Err("Unauthorized")
      | Proposal_ProposalExecuteMessage(p) => check_proposal_execute_message(state, strategy, p)
    }
    

  pure def check_proposal_execute_message(
    state: ContractState, 
    strategy: Strategy, 
    proposal: ProposalExecuteMessage): Result[(), ContractError] = 
    
    // this is the function with a bug! Here, some unpacking is takig place etc.
    match proposal {
      | ProposalExecuteMessage_CronEncoded(p) => check_cron_update_msg_params(state, strategy, p)
      | ProposalExecuteMessage_Other(_) => Ok(())
    }

    

  pure def check_cron_update_msg_params(
    state: ContractState, 
    strategy: Strategy, 
    proposal: MsgUpdateParamsCron): Result[(), ContractError] = 
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
    // TODO: continue here
    any {
      execute_add_strategy_action,
      // execute_remove_strategy_action,
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

    pure val message: InstantiateMsg = { initial_strategy_address: "sender1", initial_strategy: Strategy_AllowAll }
    pure val r = instantiate(init_contract_state, { block: { time: 0, height: 1 } }, info, message)

    all {
      contract_state' = r._2,
      bank' = init_bank_state,
      result' = r._1,
      time' = 0,
      actionTakenType' = "instantiate",
      chosenSender' = sender,
    }
  }


  action execute_message(message, max_funds) = {
    // nondet sender = ADDRESSES.oneOf()
    // val sender = "sender1"
    nondet sender = Set("sender1", "sender2").oneOf()
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
      actionTakenType' = match message {
        | ExecuteMsg_AddStrategy(_) => "add"
        | ExecuteMsg_RemoveStrategy(_) => "remove"
        | ExecuteMsg_ExecuteMessages(_) => "execute"
      },
      chosenSender' = sender,
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
            actionTakenType' = "processing submsg",
            advance_time,
            chosenSender' = "none",

          }
      }
      | None => execute_step
    }
  }

  // INVARIANTS
  def other_action_never_succeeds = 
    and {
      actionTakenType == "execute",
      contract_state.strategies.keys().contains(chosenSender),
      not(contract_state.strategies.get(chosenSender) == Strategy_AllowAll)
    } implies (result == Err("Unauthorized"))


}
