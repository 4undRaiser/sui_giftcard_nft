# sui_giftcard_nft
A marketplace where users can buy and sell giftcards. This project uses the sui kiosk module to implement the market place.

**Functions**

* Mint giftcard nfts
* create kioks
* place giftcards in kiosks
* list giftcard for sell
* buy giftcards
* earn royalties from sales
* withdraw from kiosk

### Usage 

publish the contract 
```bash
 sui client publish --gas-budget 50000000
```
Save the package id of our marketplace for easy reference when calling functions.
```bash
export KIOSK_PACKAGE_ID="Package ID of marketplace smart contract"
```
![image](https://github.com/4undRaiser/sui_giftcard_nft/assets/87926451/df91781a-cca4-4230-8033-7f362d1614b1)


Next create a new kiosk
```bash
sui client call --package $KIOSK_PACKAGE_ID --module giftcard_nft --function new_kiosk --gas-budget 50000000
```

export the newly created Kiosk and its KioskOwnerCap for later use.
```bash
export KIOSK="Object id of newly created Kiosk"
export KIOSK_OWNER_CAP="Object id of newly created KioskOwnerCap"
```
![image](https://github.com/4undRaiser/sui_giftcard_nft/assets/87926451/ebe1794e-120b-45c1-aa58-7b10242bfad8)

