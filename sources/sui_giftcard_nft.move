module sui_giftcard_nft::nft {
    use std::string::String;
    use sui::dynamic_object_field as ofield;
    use sui::bag::{Bag, Self};
    use sui::coin::{Self, Coin};
    use sui::table::{Table, Self};
    use sui::transfer;
    use sui::tx_context::{TxContext, Self};

    /// For when amount paid does not match the expected.
    const EAmountIncorrect: u64 = 0;
    /// For when someone tries to delist without ownership.
    const NotOwner: u64 = 1;

    /// Struct representing a gift card NFT.
    public struct GIFTCARD has key, store {
        id: UID,
        name: String,
        price: u64,
        description: String,
        company: String,
        value: u64,
        owner: address,
    }

    /// Struct representing the marketplace for gift card NFTs.
    public struct Marketplace has key, store {
        id: UID,
        giftcards: Bag,
        payments: Table<address, Coin<SUI>>,
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

    /// Mint a new gift card and list it on the marketplace.
    public entry fun mint_and_list_gift_card<T: key + store>(
        marketplace: &mut Marketplace,
        item: T,
        name: String,
        price: u64,
        description: String,
        company: String,
        value: u64,
        ctx: &mut TxContext
    ) {
        // Create the new NFT
        let item_id = object::id(&item);
        let nft = GIFTCARD {
            id: object::new(ctx),
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

    /// Unlist a gift card from the marketplace.
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

    /// Unlist a gift card from the marketplace and transfer it to the owner.
    public fun unlist_and_retrieve<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        ctx: &mut TxContext
    ) {
        let nft = unlist_giftcard<T>(marketplace, item_id, ctx);
        transfer::public_transfer(nft, ctx.sender());
    }

    /// Buy a gift card from the marketplace.
    fun buy_giftcard<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        paid: Coin<SUI>,
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

        assert!(price == coin::value(&paid), EAmountIncorrect);

        // Check if there's already a Coin hanging and merge `paid` with it.
        // Otherwise, attach `paid` to the `Marketplace` under the owner's `address`.
        if (table::contains(&marketplace.payments, owner)) {
            coin::join(
                table::borrow_mut(&mut marketplace.payments, owner),
                paid
            )
        } else {
            table::add(&mut marketplace.payments, owner, paid)
        };

        let nft = ofield::remove(&mut id, true);
        object::delete(id);
        nft
    }

    /// Buy a gift card from the marketplace and transfer it to the buyer.
    public fun buy_and_retrieve<T: key + store>(
        marketplace: &mut Marketplace,
        item_id: ID,
        paid: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(
            buy_giftcard<T>(marketplace, item_id, paid, ctx),
            tx_context::sender(ctx)
        )
    }

    /// Withdraw profits from the marketplace.
    fun withdraw_profits(
        marketplace: &mut Marketplace,
        ctx: &TxContext
    ): Coin<SUI> {
        table::remove(&mut marketplace.payments, tx_context::sender(ctx))
    }

    /// Withdraw profits from the marketplace and transfer the coins to the sender.
    public fun take_profits_and_keep(
        marketplace: &mut Marketplace,
        ctx: &mut TxContext
    ) {
        if let Some(profits) = withdraw_profits(marketplace, ctx) {
            transfer::public_transfer(profits, ctx.sender())
        }
    }

    /// Check if a given address owns a gift card in the marketplace.
    public fun owns_giftcard(
        marketplace: &Marketplace,
        owner: address
    ): bool {
        bag::iter(&marketplace.giftcards, |_, giftcard| {
            if (giftcard.owner == owner) {
                return true
            }
        });
        false
    }

    /// Get the total value of all gift cards owned by a given address.
    public fun get_total_value_owned(
        marketplace: &Marketplace,
        owner: address
    ): u64 {
        let total_value = 0;
        bag::iter(&marketplace.giftcards, |_, giftcard| {
            if (giftcard.owner == owner) {
                total_value = total_value + giftcard.value;
            }
        });
        total_value
    }
}