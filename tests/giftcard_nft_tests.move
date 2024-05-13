
#[test_only]
module sui_giftcard_nft::giftcard_nft_tests {
    //use sui_giftcard_nft::giftcard_nft;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_giftcard_nft() {
        // pass
    }

    #[test, expected_failure(abort_code = sui_giftcard_nft::giftcard_nft_tests::ENotImplemented)]
    fun test_sui_giftcard_nft_fail() {
        abort ENotImplemented
    }
}

