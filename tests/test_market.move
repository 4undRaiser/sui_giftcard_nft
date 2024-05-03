#[test_only]
module sui_giftcard_nft::test_market {
    use sui::test_scenario::{Self as ts, next_tx, Scenario, ctx};
    use sui::coin::{Self, Coin, mint_for_testing};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::test_utils::{assert_eq};
    use sui::clock::{Self, Clock};
    use sui::transfer::{Self};

    use std::string::{Self, String};

    use sui_giftcard_nft::main::{Self, GiftCard, Marketplace, MarketplaceCap, Listing};
    use sui_giftcard_nft::helpers::{Self, init_test_helper};

    const ADMIN: address = @0xA;
    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;


    #[test]
    public fun test_list_delist() {

        let mut scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = main::create(ts::ctx(scenario));
            transfer::public_transfer(cap, ADMIN);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let name = string::utf8(b"asd");
            let name1 = string::utf8(b"asd");
            let name2 = string::utf8(b"asd");
            let price: u64 = 1;
            let price2: u64 = 2;

            let nft = main::mint(
                name,
                price,
                name1,
                name2,
                price2,
                ts::ctx(scenario)
            );
            transfer::public_transfer(nft, TEST_ADDRESS1);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let mut market = ts::take_shared<Marketplace>(scenario);
            let item = ts::take_from_sender<GiftCard>(scenario);

            main::list(&mut market, item, 1000, ts::ctx(scenario));

            ts::return_shared(market);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let mut market = ts::take_shared<Marketplace>(scenario);
            let item_id = main::get_gift_id(&market);

            main::delist_and_take<GiftCard>(&mut market, item_id, ts::ctx(scenario));

            ts::return_shared(market);
        };
    
         ts::end(scenario_test);
    }

    #[test]
    public fun test_list_purchase_withdraw() {

        let mut scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = main::create(ts::ctx(scenario));
            transfer::public_transfer(cap, TEST_ADDRESS1);  
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let name = string::utf8(b"asd");
            let name1 = string::utf8(b"asd");
            let name2 = string::utf8(b"asd");
            let price: u64 = 1;
            let price2: u64 = 2;

            let nft = main::mint(
                name,
                price,
                name1,
                name2,
                price2,
                ts::ctx(scenario)
            );
            transfer::public_transfer(nft, TEST_ADDRESS1);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let mut market = ts::take_shared<Marketplace>(scenario);
            let item = ts::take_from_sender<GiftCard>(scenario);

            main::list(&mut market, item, 1000, ts::ctx(scenario));

            ts::return_shared(market);
        };

        next_tx(scenario, TEST_ADDRESS2);
        {
            let mut market = ts::take_shared<Marketplace>(scenario);
            let item_id = main::get_gift_id(&market);
            let coin_ = mint_for_testing<SUI>(1000, ts::ctx(scenario));

            main::buy_and_take<GiftCard>(&mut market, item_id, coin_, ts::ctx(scenario));

            ts::return_shared(market);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let mut market = ts::take_shared<Marketplace>(scenario);
            let cap = ts::take_from_sender<MarketplaceCap>(scenario);
            let coin = main::take_profits(&cap, &mut market, ts::ctx(scenario));

            transfer::public_transfer(coin, TEST_ADDRESS1);

            ts::return_shared(market);
            ts::return_to_sender(scenario, cap);
        };
    
         ts::end(scenario_test);
    }

}