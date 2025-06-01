module io {
  import basicSpells.* from "../lib/basicSpells"
  import cw_types.* from "../lib/cw_types"
  import cw_utils.* from "../lib/cw_utils"
  import testing_utils.* from "../testing_utils"
  import neutron_chain_manager.* from "../model_generated"

  pure val test_contract_state =         { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll
          )
        }

  pure val remaining_admins = test_contract_state.strategies.keys().filter(addr => match test_contract_state.strategies.get(addr) {
                | Strategy_AllowAll => true
                | _ => false
              })

  pure val examples = [
    // sender 1 adds an AllowAll strategy for sender2
    {
      given: execute_add_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: [],
        },
        "sender2",
        Strategy_AllowAll
      ),
      expect: (Ok({ attributes: [{ key: "action", value: FromStr("execute_add_strategy") }, { key: "address", value: FromStr("sender2") }], data: None, events: [], messages: [] }), { strategies: Map("sender1" -> Strategy_AllowAll, "sender2" -> Strategy_AllowAll) })
    },

    // sender 1 attempts to demote themselves
    {
      given: execute_add_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
          )
        },
        {
          sender: "sender1",
          funds: [],
        },
        "sender1",
        Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
      ),
      expect: (Err("Cannot remove last administrator"), { strategies: Map("sender1" -> Strategy_AllowAll, "sender2" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])) })
    },

    // sender 1 adds an AllowOnly strategy with permissions for sender2
    {
      given: execute_add_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: [],
        },
        "sender2",
        Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
      ),
      expect: (
        Ok({ attributes: [{ key: "action", value: FromStr("execute_add_strategy") }, { key: "address", value: FromStr("sender2") }], data: None, events: [], messages: [] }),
        { strategies: Map("sender1" -> Strategy_AllowAll, "sender2" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])) }
      )
    },

    // sender 1 demotes themselves
    {
      given: execute_add_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: [],
        },
        "sender1",
        Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
      ),
      expect: (
        Ok({ attributes: [{ key: "action", value: FromStr("execute_add_strategy") }, { key: "address", value: FromStr("sender1") }], data: None, events: [], messages: [] }),
        { strategies: Map("sender1" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })]), "sender2" -> Strategy_AllowAll) }
      )
    },

    // sender 2 adds an AllowAll strategy for sender 1
    {
      given: execute_add_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender2",
          funds: [],
        },
        "sender1",
        Strategy_AllowAll
      ),
      expect: (Err("Unauthorized"), { strategies: Map("sender1" -> Strategy_AllowAll) })
    },
  ]
}
