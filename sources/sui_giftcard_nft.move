/*
/// Module: sui_giftcard_nft
module sui_giftcard_nft::sui_giftcard_nft {

}
*/



module sui_giftcard_nft::nft {
    use std::string::String;
    use sui::dynamic_object_field as ofield;
    use sui::bag::{Bag, Self};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::table::{Table, Self};

     /// For when amount paid does not match the expected.
    const EAmountIncorrect: u64 = 0;
    /// For when someone tries to delist without ownership.
    const NotOwner: u64 = 1;



    public struct GIFTCARD has key, store {
        id: UID,
        name: String,
        price: u64,         
        description: String,
        company: String,
        value: u64,
        owner: address,
    }

    public struct Marketplace has key, store {
        id: UID,
        giftcards: Bag,
        payments: Table<address, Coin<SUI>>
    }

      /// Create a new shared Marketplace.
    public fun create_marketplace(ctx: &mut TxContext) {
        let id = object::new(ctx);
        let giftcards = bag::new(ctx);
        let payments = table::new<address, Coin<SUI>>(ctx);
        
        transfer::share_object(Marketplace { 
            id, 
            giftcards,
            payments,
        })
    }

    public entry fun mint_and_list_gift_card<T: key + store>(
        marketplace: &mut Marketplace,
        item: T,
        name: String, 
        price: u64,
        description: String, 
        company: String, 
        value: u64, 
        ctx: &mut TxContext
        
        ){
        // create the new nft
         let item_id = object::id(&item);
        let nft = GIFTCARD {
            id : object::new(ctx),
            name,
            price,
            description,
            company,
            value,
            owner: ctx.sender(),
        };

        transfer::public_transfer(nft, ctx.sender());

        ofield::add(&mut nft.id, true, item);
        bag::add(&mut marketplace.giftcards, item_id, nft);

    }

    fun unlist_giftcard<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        ctx: &TxContext
        ): T {
            let GIFTCARD {
                id,
                name,
                price,
                description,
                company,
                value,
                owner,

            } = bag::remove(&mut marketplace.giftcards, item_id);

            assert!(ctx.sender() == owner, NotOwner);

            let nft = ofield::remove(&mut id, true);
            object::delete(id);
            nft
            
        }


         public fun unlist_and_retrieve<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        ctx: &mut TxContext
    ) {
        let nft = unlist_giftcard<T>(marketplace, item_id, ctx);
        transfer::public_transfer(nft, ctx.sender());
    }

     fun buy_giftcard<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        paid: Coin<SUI>,
    ): T {
        let GIFTCARD {
                id,
                name,
                price,
                description,
                company,
                value,
                owner,

            } = bag::remove(&mut marketplace.giftcards, item_id);

        assert!(price == coin::value(&paid), EAmountIncorrect);

        // Check if there's already a Coin hanging and merge `paid` with it.
        // Otherwise attach `paid` to the `Marketplace` under owner's `address`.
        if (table::contains<address, Coin<SUI>>(&marketplace.payments, owner)) {
            coin::join(
                table::borrow_mut<address, Coin<SUI>>(&mut marketplace.payments, owner),
                paid
            )
        } else {
            table::add(&mut marketplace.payments, owner, paid)
        };

        let nft = ofield::remove(&mut id, true);
        object::delete(id);
        nft
    }

     public fun buy_and_retrive<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        paid: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(
            buy_giftcard<T>(marketplace, item_id, paid),
            tx_context::sender(ctx)
        )
    }

    fun withdraw_profits(
        marketplace: &mut Marketplace,
        ctx: &TxContext
    ): Coin<SUI> {
        table::remove<address, Coin<SUI>>(&mut marketplace.payments, tx_context::sender(ctx))
    }

    #[lint_allow(self_transfer)]
    /// Call [`take_profits`] and transfer Coin object to the sender.
    public fun take_profits_and_keep(
        marketplace: &mut Marketplace,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(
            withdraw_profits(marketplace, ctx),
            ctx.sender()
        )
    }

}
