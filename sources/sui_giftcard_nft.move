module sui_giftcard_nft::main {

   // Importing required modules

    use sui::dynamic_object_field as ofield;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID, UID};
    use sui::coin::{Self, Coin};
    use sui::bag::{Bag, Self};
    use sui::table::{Table, Self};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};

    use std::vector::{Self};
    use std::string::{Self, String};


    // Error constants

    const EAmountIncorrect: u64 = 0;
    const ENotOwner: u64 = 1;
    const EInvalidCap: u64 = 2;

    public struct GiftCard has key, store {
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
        payments: Balance<SUI>,
        gift_id: vector<ID> // For local test Delete me !! 
    }

    public struct MarketplaceCap has key, store {
        id: UID,
        cap_id: ID
    }
    
    public struct Listing has key, store {
        id: UID,
        ask: u64,
        owner: address
    }
    
    // create new houselist
    public fun create(ctx: &mut TxContext) : MarketplaceCap {
        let id = object::new(ctx);
        let inner_ = object::uid_to_inner(&id);
        let giftcards = bag::new(ctx);
        transfer::share_object(Marketplace { 
            id, 
            giftcards,
            payments: balance::zero(),
            gift_id: vector::empty()
        });
        let cap = MarketplaceCap {
            id: object::new(ctx),
            cap_id: inner_
        };
        cap
    }

    public fun mint(
        name: String, 
        price: u64,
        description: String, 
        company: String, 
        value: u64, 
        ctx: &mut TxContext
    ) : GiftCard {
    
        let nft = GiftCard {
            id : object::new(ctx),
            name,
            price,
            description,
            company,
            value,
            owner: ctx.sender(),
        };
        nft
    }

    public entry fun list<T: key + store>(
        market: &mut Marketplace,
        item: T,
        ask: u64,
        ctx: &mut TxContext
    ) {
        let item_id = object::id(&item);
        vector::push_back(&mut market.gift_id, item_id); // for access car id Delete me !! 
        let mut listing = Listing {
            id: object::new(ctx),
            ask: ask,
            owner: tx_context::sender(ctx),
        };
        ofield::add(&mut listing.id, true, item);
        bag::add(&mut market.giftcards, item_id, listing)
    }

    fun delist<T: key + store>(
        market: &mut Marketplace,
        item_id: ID,
        ctx: &mut TxContext
    ): T {
        let Listing { mut id, owner, ask: _ } = bag::remove(&mut market.giftcards, item_id);

        assert!(ctx.sender() == owner, ENotOwner);

        let item = ofield::remove(&mut id, true);
        object::delete(id);
        item
    }

    public entry fun delist_and_take<T: key + store>(
        market: &mut Marketplace,
        item_id: ID,
        ctx: &mut TxContext
    ) {
        let item = delist<T>(market, item_id, ctx);
        transfer::public_transfer(item, tx_context::sender(ctx));
    }

    fun buy<T: key + store>(
        market: &mut Marketplace,
        item_id: ID,
        paid: Coin<SUI>,
    ): T {
        let Listing { mut id, ask, owner } = bag::remove(&mut market.giftcards, item_id);
        assert!(ask == coin::value(&paid), EAmountIncorrect);
        coin::put(&mut market.payments, paid);


        let item = ofield::remove(&mut id, true);
        object::delete(id);
        item
    }

    public entry fun buy_and_take<T: key + store>(
        market: &mut Marketplace,
        item_id: ID,
        paid: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(
            buy<T>(market, item_id, paid),
            tx_context::sender(ctx)
        )
    }

    public fun  take_profits(
        cap: &MarketplaceCap,
        market: &mut Marketplace,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(object::id(market) == cap.cap_id, EInvalidCap);
        let balance_ = balance::withdraw_all(&mut market.payments);
        let coin_ = coin::from_balance(balance_, ctx);
        coin_
    }

    // For tests
    public fun get_gift_id(self: &Marketplace) : ID {
        let id_ = vector::borrow(&self.gift_id, 0);
        *id_
    }
}
