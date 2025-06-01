module io {
  import basicSpells.* from "../lib/basicSpells"
  import cw_types.* from "../lib/cw_types"
  import cw_utils.* from "../lib/cw_utils"
  import testing_utils.* from "../testing_utils"
  import neutron_chain_manager.* from "../model_generated"

  pure val examples = [
    // sender 1 instantiates the contract with sender1 as an initial strategy address and an AllowAll strategy
    {
      given: instantiate(
        { 
          strategies: Map()
        },
        {
          block: {
            time: 0,
            height: 1
          }
        },
        {
          sender: "sender1",
          funds: [],
        },
        {
          initial_strategy_address: "sender1",
          initial_strategy: Strategy_AllowAll
        }
      ),
      expect: (
        Ok({ attributes: [{ key: "action", value: FromStr("instantiate") }, { key: "init_allow_all_address", value: FromStr("sender1") }], data: None, events: [], messages: [] }),
        { strategies: Map("sender1" -> Strategy_AllowAll) }
      )
    },

    // sender 1 instantiates the contract with sender1 as an initial strategy address and an AllowOnly strategy
    {
      given: instantiate(
        { 
          strategies: Map()
        },
        {
          block: {
            time: 0,
            height: 1
          }
        },
        {
          sender: "sender1",
          funds: [],
        },
        {
          initial_strategy_address: "sender1",
          initial_strategy: Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
        }
      ),
      expect: (Err("InvalidInitialStrategy"), { strategies: Map() })
    },

    // sender 1 instantiates the contract with sender2 as an initial strategy address and an AllowAll strategy
    {
      given: instantiate(
        { 
          strategies: Map()
        },
        {
          block: {
            time: 0,
            height: 1
          }
        },
        {
          sender: "sender1",
          funds: [],
        },
        {
          initial_strategy_address: "sender2",
          initial_strategy: Strategy_AllowAll
        }
      ),
      expect: (
        Ok({ attributes: [{ key: "action", value: FromStr("instantiate") }, { key: "init_allow_all_address", value: FromStr("sender2") }], data: None, events: [], messages: [] }),
        { strategies: Map("sender2" -> Strategy_AllowAll) }
      )
    },

    // sender 1 instantiates the contract with sender2 as an initial strategy address and an AllowOnly strategy
    {
      given: instantiate(
        { 
          strategies: Map()
        },
        {
          block: {
            time: 0,
            height: 1
          }
        },
        {
          sender: "sender1",
          funds: [],
        },
        {
          initial_strategy_address: "sender2",
          initial_strategy: Strategy_AllowOnly([Permission_CronPermission({ add_schedule: true, remove_schedule: false })])
        }
      ),
      expect: (Err("InvalidInitialStrategy"), { strategies: Map() })
    },
  ]
}
