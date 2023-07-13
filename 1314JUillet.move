address 0x2 {
    module Coin {
        struct Coin has drop {
            value: u64,
        }

        public fun mint(value: u64): Coin {
            Coin { value }
        }
        
        public fun value(coin: &Coin): u64 {
            coin.value
        }

        public fun burn(coin: Coin): u64 {
            let Coin { value } = coin;
            value
        }
    }
}
module 0x62::fra{
    use std::vector;
    use std::signer;
    use aptos_std::simple_map::{Self, SimpleMap};
    //use std::string::{Self, String};
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::aptos_coin::{AptosCoin};
    use aptos_framework::coin;
    use aptos_framework::timestamp;

    struct Trade has key, store {
        id: u64,
        amount: u64,
        time: u64,
        trader: address,
        state: u8, // 0 for Validated, 1 for Pending, 2 for Refused
        votesFor: u64,
        votesAgainst: u64,
        votingStartTime: u64,
        votingEndTime: u64,
    }

    struct Trader has key, store {
        id: u64,
        trader: address,
        amountEtherTraded: u64,
        amountFiatTraded: u64,
        trades: u64,
    }

      struct Vote has key, store {
        tradeId: u64,
        voter: address,
        inSupport: bool,
        amountFor:u64,
        amountAgainst:u64,
    }

    struct VotingList has key {
        voters: SimpleMap<u64, u64>
    }


    struct Token has key, store, copy, drop {
        amount: u64
    }

    struct Balance has key, store, copy, drop {
        coin: Token
    }


    struct AllTokenHolders has key, store, copy, drop {
        howmuch: vector<Token>,
        address_user: address,
    }

    struct TokenHolder has key, store, copy, drop {
        address_user: address,
        tokenAmount: u64,
    }


    // Structure de donnees pour les offres
    struct TradeOffer has key, store{
        id:ID,
        creator:address,
        etherAmount: u64,
        cashAmount: u64,
        isAccepted: bool,
        isCompleted: bool
    }

    // Structure de donnees pour les echanges
    struct TradeExchange has key,store {
        offers: vector<TradeOffer>
    }

    struct ID has key,store{
        id:u64
    }

    //struct ResourceInfo has key {
    //    resource_map: SimpleMap<String,address>,
    //}

    struct Vault<phantom CoinType> has key{
        coin_store: coin::Coin<CoinType>,
    }

    public fun init_venue(venue_owner: &signer) {
	    let id = 0;
	    move_to<ID>(venue_owner, ID {id})
	}

    // Create an offer
    public fun create_offer(maker_offer: &signer, 
        creator:address,
        etherAmount: u64, 
        cashAmount: u64) acquires TradeExchange {

		let maker_offer_addr:address = signer::address_of(maker_offer);
        let venue = borrow_global_mut<TradeExchange>(maker_offer_addr);

        let tmp = vector::length<TradeOffer>(&venue.offers);
        let isAccepted = false;
        let isCompleted = false;
        let id:ID = ID{id : tmp};

		vector::push_back(&mut venue.offers, TradeOffer {id, creator, etherAmount, cashAmount, isAccepted, isCompleted});
    }

    // Buy an offer
public entry fun accept_offer(user: &signer, offer_id: u128) acquires TradeExchange, TradeOffer {
    let user_addr = signer::address_of(user);

    let trade_exchange = borrow_global_mut<TradeExchange>(0x62::fra::TRADE_EXCHANGE_ADDR);
    let offer = vector::get_mut(&mut trade_exchange.offers, offer_id);

    assert_offer_exists(offer);
    assert_offer_not_accepted(offer);
    assert_dispute_not_opened(offer);

    offer.counterparty = option::Some(user_addr);

    let resource_account = account::create_signer_with_capability(borrow_global<0x62::fra::CAPABILITY_RESOURCE>());
    let resource_acc_addr = signer::address_of(&resource_account);

    if (!offer.sell_apt) {
        assert_user_has_enough_funds<AptosCoin>(user_addr, offer.apt_amount);
        coin::transfer<AptosCoin>(user, resource_acc_addr, offer.apt_amount);
    };

    let accept_offer_event = broker_it_yourself_events::new_accept_offer_event(
        offer_id, 
        user_addr,
        timestamp::now_seconds()
    );
    event::emit_event<AcceptOfferEvent>(
        borrow_global_mut<0x62::fra::ACCEPT_OFFER_EVENTS>(),
        accept_offer_event
    );
}

public entry fun complete_transaction(user: &signer, offer_id: u128) acquires TradeExchange, TradeOffer {
    let user_addr = signer::address_of(user);

    let trade_exchange = borrow_global_mut<TradeExchange>(0x62::fra::TRADE_EXCHANGE_ADDR);
    let offer = vector::get_mut(&mut trade_exchange.offers, offer_id);

    assert_offer_exists(offer);
    assert_offer_accepted(offer);
    assert_user_participates_in_transaction(user_addr, offer);
    assert_user_has_not_marked_completed_yet(user_addr, offer);
    assert_dispute_not_opened(offer);

    if (user_addr == offer.creator) {
        offer.completion.creator = true;
    } else {
        offer.completion.counterparty = true;
    };

    let resource_account = account::create_signer_with_capability(borrow_global<0x62::fra::CAPABILITY_RESOURCE>());

    let complete_event = broker_it_yourself_events::new_complete_transaction_event(
        offer_id, 
        user_addr,            
        timestamp::now_seconds()
    );
    event::emit_event<CompleteTransactionEvent>(
        borrow_global_mut<0x62::fra::COMPLETE_TRANSACTION_EVENTS>(),
        complete_event
    );

    if (offer.completion.creator && offer.completion.counterparty) {
        remove_offer_from_creator_offers(
            borrow_global_mut<0x62::fra::CREATORS_OFFERS>(),
            &offer.creator,
            &offer_id
        );

        if (offer.sell_apt) {
            let counterparty = option::borrow(&offer.counterparty);
            coin::transfer<AptosCoin>(&resource_account, *counterparty, offer.apt_amount);
        } else {
            coin::transfer<AptosCoin>(&resource_account, offer.creator, offer.apt_amount);
        };

        vector::remove(&mut trade_exchange.offers, offer_id);

        let release_funds_event = broker_it_yourself_events::new_release_funds_event(
            offer_id, 
            user_addr,
            timestamp::now_seconds()
        );
        event::emit_event<ReleaseFundsEvent>(
            borrow_global_mut<0x62::fra::RELEASE_FUNDS_EVENTS>(),
            release_funds_event
        );
    }
}

// Cancel an offer
public entry fun cancel_offer(creator: &signer, offer_id: u128) acquires TradeExchange, TradeOffer {
    let creator_addr = signer::address_of(creator);

    let trade_exchange = borrow_global_mut<TradeExchange>(0x62::fra::TRADE_EXCHANGE_ADDR);
    let offer = vector::get(&trade_exchange.offers, offer_id);

    assert_offer_exists(offer);
    assert_signer_is_creator(creator, offer);
    assert_offer_not_accepted(offer);
    assert_dispute_not_opened(offer);

    remove_offer_from_creator_offers(
        borrow_global_mut<0x62::fra::CREATORS_OFFERS>(),
        &offer.creator,
        &offer_id
    );

    let resource_account = account::create_signer_with_capability(borrow_global<0x62::fra::CAPABILITY_RESOURCE>());

    if (offer.sell_apt) {
        coin::transfer<AptosCoin>(&resource_account, creator_addr, offer.apt_amount);
    };

    vector::remove(&mut trade_exchange.offers, offer_id);

    let cancel_offer_event = broker_it_yourself_events::new_cancel_offer_event(
        offer_id, 
        timestamp::now_seconds()
    );
    
}
    //mint token

    public fun mint(amounts: u64, recipient: address) acquires AllTokenHolders, Balance{

        if(exists<AllTokenHolders>(recipient)){
            let currentamount = balance_of(recipient);
		    let venue = borrow_global_mut<AllTokenHolders>(recipient);
            let amount = currentamount + amounts;
            vector::push_back(&mut venue.howmuch, Token {amount});
            deposit(recipient, Token { amount: amounts });
        }
        else{
            deposit(recipient, Token { amount: amounts });

        }
       
    }

    //public fun amount_compte(owner_addr: address): u64 acquires Venue {
	//	let venue = borrow_global<AllTokenHolders>(owner_addr);
    //    return &venue.howmuch.amount
	//}

    // Returns the balance of `owner`.
    public fun balance_of(owner: address): u64 acquires Balance {
        borrow_global<Balance>(owner).coin.amount
    }

    // Deposit `amount` number of tokens to the balance under `addr`.
    fun deposit(addr: address, check: Token) acquires Balance {
        let balance = balance_of(addr);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.amount;
        let Token { amount } = check;
        *balance_ref = balance + amount;
    }

    // withdraw token

    public fun withdraw_burn(addr: address, amounts: u64) : Token acquires Balance {
        let balance = balance_of(addr);
        // balance must be greater than the withdraw/burn amount
        assert!(balance >= amounts, 0);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.amount;
        *balance_ref = balance - amounts;
        Token { amount: amounts }
    }


    // Vote


    public entry fun vote(acc: &signer, tradeId:u64,
      inSupport: bool,
      amountFor:u64,
      amountAgainst:u64,
      c_addr: address, 
      store_addr: address) acquires Vote, VotingList{
    
    let addr = signer::address_of(acc);
    
    
    let c_store = borrow_global_mut<Vote>(addr);
    let v_store = borrow_global_mut<VotingList>(store_addr);

    let balance = balance_of(addr);
    assert!(balance > 0, 0);

    let votes = &mut c_store.amountFor;
    *votes = *votes + 1;
    simple_map::add(&mut v_store.voters, tradeId, amountFor);
}

    // Vote to arbitrarie



    //
}
