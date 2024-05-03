#[test_only]
module sui_giftcard_nft::sui_giftcard_nft_tests {
    use sui::test_scenario;
    use sui_giftcard_nft::nft::{Self, Marketplace, GIFTCARD};

    const ENotImplemented: u64 = 0;

    struct MockGiftCard has key, store {
        id: UID,
    }

    #[test]
    fun test_create_marketplace() {
        let scenario = test_scenario::begin(&mut test_scenario::Context::new());
        let ctx = &mut scenario;

        // Create a new marketplace
        let marketplace = nft::create_marketplace(ctx);

        test_scenario::next_tx(ctx, &mut scenario);

        // Verify that the marketplace was created correctly
        let marketplace = test_scenario::take_shared<Marketplace>(ctx);
        assert!(marketplace.id != 0, 0);
        assert!(bag::length(&marketplace.giftcards) == 0, 1);
        assert!(table::length(&marketplace.payments) == 0, 2);

        test_scenario::return_shared(marketplace);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_and_list_gift_card() {
        let scenario = test_scenario::begin(&mut test_scenario::Context::new());
        let ctx = &mut scenario;

        // Create a new marketplace
        let marketplace = nft::create_marketplace(ctx);
        test_scenario::next_tx(ctx, &mut scenario);

        // Mint and list a new gift card
        let mock_gift_card = MockGiftCard { id: object::new(ctx) };
        nft::mint_and_list_gift_card<MockGiftCard>(
            &mut test_scenario::take_shared<Marketplace>(ctx),
            mock_gift_card,
            "Gift Card".to_string(),
            100,
            "A mock gift card".to_string(),
            "Mock Company".to_string(),
            50,
            ctx
        );

        test_scenario::next_tx(ctx, &mut scenario);

        // Verify that the gift card was listed correctly
        let marketplace = test_scenario::take_shared<Marketplace>(ctx);
        assert!(bag::length(&marketplace.giftcards) == 1, 0);

        test_scenario::return_shared(marketplace);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft::NotOwner)]
    fun test_unlist_giftcard_not_owner() {
        let scenario = test_scenario::begin(&mut test_scenario::Context::new());
        let ctx = &mut scenario;

        // Create a new marketplace and list a gift card
        test_create_marketplace(ctx);
        test_mint_and_list_gift_card(ctx);

        test_scenario::next_tx(ctx, &mut scenario);

        // Attempt to unlist the gift card as a different owner
        let marketplace = test_scenario::take_shared<Marketplace>(ctx);
        let giftcard_id = object::uid_to_inner(&bag::borrow(&marketplace.giftcards, 0).id);
        nft::unlist_and_retrieve<MockGiftCard>(
            &mut marketplace,
            giftcard_id,
            ctx
        );

        test_scenario::return_shared(marketplace);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft::EAmountIncorrect)]
    fun test_buy_giftcard_incorrect_amount() {
        let scenario = test_scenario::begin(&mut test_scenario::Context::new());
        let ctx = &mut scenario;

        // Create a new marketplace and list a gift card
        test_create_marketplace(ctx);
        test_mint_and_list_gift_card(ctx);

        test_scenario::next_tx(ctx, &mut scenario);

        // Attempt to buy the gift card with an incorrect amount
        let marketplace = test_scenario::take_shared<Marketplace>(ctx);
        let giftcard_id = object::uid_to_inner(&bag::borrow(&marketplace.giftcards, 0).id);
        nft::buy_and_retrieve<MockGiftCard>(
            &mut marketplace,
            giftcard_id,
            coin::mint_for_testing<SUI>(50, ctx),
            ctx
        );

        test_scenario::return_shared(marketplace);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_buy_and_retrieve_giftcard() {
        let scenario = test_scenario::begin(&mut test_scenario::Context::new());
        let ctx = &mut scenario;

        // Create a new marketplace and list a gift card
        test_create_marketplace(ctx);
        test_mint_and_list_gift_card(ctx);

        test_scenario::next_tx(ctx, &mut scenario);

        // Buy the gift card
        let marketplace = test_scenario::take_shared<Marketplace>(ctx);
        let giftcard_id = object::uid_to_inner(&bag::borrow(&marketplace.giftcards, 0).id);
        nft::buy_and_retrieve<MockGiftCard>(
            &mut marketplace,
            giftcard_id,
            coin::mint_for_testing<SUI>(100, ctx),
            ctx
        );

        test_scenario::next_tx(ctx, &mut scenario);

        // Verify that the gift card was bought and transferred
        let marketplace = test_scenario::take_shared<Marketplace>(ctx);
        assert!(bag::length(&marketplace.giftcards) == 0, 0);
        assert!(table::length(&marketplace.payments) == 1, 1);

        test_scenario::return_shared(marketplace);
        test_scenario::end(scenario);
    }

    #[test, expected_failure(abort_code = sui_giftcard_nft::sui_giftcard_nft_tests::ENotImplemented)]
    fun test_sui_giftcard_nft_fail() {
        abort ENotImplemented
    }
}