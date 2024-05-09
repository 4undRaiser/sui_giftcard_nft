/*
/// Module: sui_giftcard_nft
module sui_giftcard_nft::sui_giftcard_nft {

}
*/



module sui_giftcard_nft::giftcard_nft {
    use std::string::String;
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::coin::{Coin};
    use sui::sui::{SUI};
    use sui::transfer_policy::{Self, TransferRequest, TransferPolicy};
    use sui::package::{Self, Publisher};

     /// For when amount paid does not match the expected.
    ///const EAmountIncorrect: u64 = 0;
    /// For when someone tries to delist without ownership.
    ///const NotOwner: u64 = 1;



    public struct GIFTCARD has key, store {
        id: UID,
        name: String,        
        description: String,
        company: String,
        value: u64,
        owner: address,
    }

    public struct GIFTCARD_NFT has drop {}

   fun init (otw: GIFTCARD_NFT, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        transfer::public_transfer(publisher, ctx.sender());
    }

    public fun mint_giftcard(
        name: String, 
        description: String, 
        company: String, 
        value: u64, 
        ctx: &mut TxContext,

        ): GIFTCARD {
        GIFTCARD {
            id: object::new(ctx),
            name,
            description,
            company,
            value,
            owner: ctx.sender(),
            
        }
    }

    #[allow(lint(share_owned, self_transfer))]
    /// Create new kiosk
    public fun new_kiosk(ctx: &mut TxContext) {
        let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
        transfer::public_share_object(kiosk);
        transfer::public_transfer(kiosk_owner_cap, ctx.sender());
    }

     /// Place item inside Kiosk
    public fun place(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item: GIFTCARD) {
        kiosk::place(kiosk, cap, item)
    }

     /// Withdraw item from Kiosk
    public fun withdraw(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID): GIFTCARD {
        kiosk::take(kiosk, cap, item_id)
    }

      /// List item for sale
    public fun list(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID, price: u64) {
        kiosk::list<GIFTCARD>(kiosk, cap, item_id, price)
    }

    public fun buy(kiosk: &mut Kiosk, item_id: object::ID, payment: Coin<SUI>): (GIFTCARD, TransferRequest<GIFTCARD>){
        kiosk::purchase(kiosk, item_id, payment)
    }

     public fun confirm_request(policy: &TransferPolicy<GIFTCARD>, req: TransferRequest<GIFTCARD>) {
        transfer_policy::confirm_request(policy, req);
    }

      #[allow(lint(share_owned, self_transfer))]
    /// Create new policy for type `T`
    public fun new_policy(publisher: &Publisher, ctx: &mut TxContext) {
        let (policy, policy_cap) = transfer_policy::new<GIFTCARD>(publisher, ctx);
        transfer::public_share_object(policy);
        transfer::public_transfer(policy_cap, ctx.sender());
    }

     #[test_only]
    // call the init function
    public fun test_init(ctx: &mut TxContext) {
        init(GIFTCARD_NFT {}, ctx);
    }


}
