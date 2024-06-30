module io {
  import basicSpells.* from "../lib/basicSpells"
  import cw_types.* from "../lib/cw_types"
  import cw_utils.* from "../lib/cw_utils"
  import testing_utils.* from "../testing_utils"
  import neutron_chain_manager.* from "../model_generated"

  pure val examples = [
    // sender 1 executes one message
    {
      given: execute_execute_messages(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: [],
        },
        [CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "s1" }))]
      ),
      expect: (
        Ok({
          attributes: [{ key: "action", value: FromStr("execute_execute_messages") }, { key: "address", value: FromStr("sender1") }, { key: "strategy", value: FromStr("allow_all") }],
          data: None,
          events: [],
          messages: [{ gas_limit: None, id: 0, msg: CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "s1" })), reply_on: ReplyOn_Never }]
        }),
        { strategies: Map("sender1" -> Strategy_AllowAll) }
      )
    },

    // sender 2 attempts to execute a message
    {
      given: execute_execute_messages(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender2",
          funds: [],
        },
        [CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "s1" }))]
      ),
      expect: (Err("Unauthorized"), { strategies: Map("sender1" -> Strategy_AllowAll) })
    },

    // sender 2 executes two messages
    {
      given: execute_execute_messages(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender2",
          funds: [],
        },
        [CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender1" })), CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender2" }))]
      ),
      expect: (
        Ok({
          attributes: [{ key: "action", value: FromStr("execute_execute_messages") }, { key: "address", value: FromStr("sender2") }, { key: "strategy", value: FromStr("allow_all") }],
          data: None,
          events: [],
          messages:
            [
              { gas_limit: None, id: 0, msg: CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender1" })), reply_on: ReplyOn_Never },
              { gas_limit: None, id: 0, msg: CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender2" })), reply_on: ReplyOn_Never }
            ]
        }),
        { strategies: Map("sender1" -> Strategy_AllowAll, "sender2" -> Strategy_AllowAll) }
      )
    },

    // sender 1 attempts to execute two messages
    {
      given: execute_execute_messages(
        { 
          strategies: Map(
          )
        },
        {
          sender: "sender1",
          funds: [],
        },
        [CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender1" })), CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender2" }))]
      ),
      expect: (Err("Unauthorized"), { strategies: Map() })
    },

    // sender 3 attempts to execute two messages (he should be allowed because the permission check is hardcoded to always succeed)
    {
      given: execute_execute_messages(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowAll,
            "sender3" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
          )
        },
        {
          sender: "sender3",
          funds: [],
        },
        [CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender1" })), CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender2" }))]
      ),
      expect: (
        Ok({
          attributes: [{ key: "action", value: FromStr("execute_execute_messages") }, { key: "address", value: FromStr("sender3") }, { key: "strategy", value: FromStr("allow_only") }],
          data: None,
          events: [],
          messages:
            [
              { gas_limit: None, id: 0, msg: CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender1" })), reply_on: ReplyOn_Never },
              { gas_limit: None, id: 0, msg: CosmosMsg_Bank(BankMsg_Send({ amount: [{ amount: 200, denom: "uawesome" }], to_address: "sender2" })), reply_on: ReplyOn_Never }
            ]
        }),
        { strategies: Map("sender1" -> Strategy_AllowAll, "sender2" -> Strategy_AllowAll, "sender3" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])) }
      )
    },
  ]
}
