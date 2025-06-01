module io {
  import basicSpells.* from "../lib/basicSpells"
  import cw_types.* from "../lib/cw_types"
  import cw_utils.* from "../lib/cw_utils"
  import testing_utils.* from "../testing_utils"
  import neutron_chain_manager.* from "../model_generated"

  pure val examples = [
    // sender 1 removes sender 2's strategy
    {
      given: execute_remove_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: []
        },
        "sender2"
      ),
      expect: (Ok({ attributes: [{ key: "action", value: FromStr("execute_remove_strategy") }, { key: "address", value: FromStr("sender2") }], data: None, events: [], messages: [] }), { strategies: Map("sender1" -> Strategy_AllowAll) })
    },

    // sender 1 attempts to remove its own strategy
    {
      given: execute_remove_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
          )
        },
        {
          sender: "sender1",
          funds: []
        },
        "sender1"
      ),
      expect: (Err("Cannot remove last administrator"), { strategies: Map("sender1" -> Strategy_AllowAll, "sender2" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])) })
    },

    // sender 1 removes its own strategy
    {
      given: execute_remove_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowAll,
            "sender2" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: []
        },
        "sender1"
      ),
      expect: (Ok({ attributes: [{ key: "action", value: FromStr("execute_remove_strategy") }, { key: "address", value: FromStr("sender1") }], data: None, events: [], messages: [] }), { strategies: Map("sender2" -> Strategy_AllowAll) })
    },

    // sender 1 attempts to remove its own strategy
    {
      given: execute_remove_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })]),
            "sender2" -> Strategy_AllowAll
          )
        },
        {
          sender: "sender1",
          funds: []
        },
        "sender1"
      ),
      expect: (Err("Unauthorized"), { strategies: Map("sender1" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })]), "sender2" -> Strategy_AllowAll) })
    },

    // unknown sender attempts to remove its own strategy
    {
      given: execute_remove_strategy(
        { 
          strategies: Map(
            "sender1" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })]),
            "sender2" -> Strategy_AllowAll
          )
        },
        {
          sender: "<unknown sender>",
          funds: []
        },
        "<unknown sender>"
      ),
      expect: (Err("Unauthorized"), { strategies: Map("sender1" -> Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })]), "sender2" -> Strategy_AllowAll) })
    },
  ]
}
