#[test_only]
module sui_giftcard_nft::helpers {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use std::string::{Self};
    use std::vector;

    const ADMIN: address = @0xA;

    public fun init_test_helper() : Scenario {
       let owner: address = @0xA;
       let mut scenario_val = ts::begin(owner);
       let scenario = &mut scenario_val;

       scenario_val
    }

}