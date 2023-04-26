//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;
pragma abicoder v2 ;


library DexUtil {

    enum DexSelection {
        SUSHI,
        UNIV2,
        UNIV3
    }

    enum DexPath {
        UNIV3_UNIV2,                
        UNIV3_SUSHI,              
        UNIV2_UNIV3,             
        SUSHI_UNIV3,            
        UNIV2_SUSHI,           
        SUSHI_UNIV2
    }


    enum ActionType {
        Deposit,   // supply tokens
        Withdraw,  // borrow tokens
        Transfer,  // transfer balance between accounts
        Buy,       // buy an amount of some token (publicly)
        Sell,      // sell an amount of some token (publicly)
        Trade,     // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize,  // use excess tokens to zero-out a completely negative account
        Call       // send arbitrary data to an address
    }

  // struct ActionArgs {
  //   ActionType actionType;
  //   uint accountId;
  //   Types.AssetAmount amount;
  //   uint primaryMarketId;
  //   uint secondaryMarketId;
  //   address otherAddress;
  //   uint otherAccountId;
  //   bytes data;
  // }

}

