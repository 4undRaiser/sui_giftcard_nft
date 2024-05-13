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

save the publisher
```bash
export MARKETPLACE_PUBLISHER="Publisher object ID"
```
![image](https://github.com/4undRaiser/sui_giftcard_nft/assets/87926451/5b4c5f44-7305-421f-a623-926399a90ff2)



Save the package id of our marketplace for easy reference when calling functions.
```bash
export MARKETPLACE_PACKAGE_ID="Package ID of marketplace smart contract"
```
![image](https://github.com/4undRaiser/sui_giftcard_nft/assets/87926451/726a5fab-ed9c-431d-a11d-bc1beeb4f0c9)



Next create a new kiosk
```bash
sui client call --package $KIOSK_PACKAGE_ID --module giftcard_nft --function new_kiosk --gas-budget 50000000
```

export the newly created Kiosk and its KioskOwnerCap for later use.
```bash
export KIOSK="Object id of newly created Kiosk"
export KIOSK_OWNER_CAP="Object id of newly created KioskOwnerCap"
```
![image](https://github.com/4undRaiser/sui_giftcard_nft/assets/87926451/bb5b96f3-785a-406a-97aa-55d78d93c827)


Mint a giftcard nft.
```bash
sui client call --package $MARKETPLACE_PAC
KAGE_ID --module giftcard_nft --function mint_giftcard --args "Prime" "Amazon prime giftcard" "Amazon" "233132344234" --gas-budget 50000000
```


```bash
sui client call --package $MARKETPLACE_PACKAGE_ID --module giftcard_nft --function new_policy --args $MARKETPLACE_PUBLISHER --gas-budget 10000000
```


```bash
export KIOSK_TRANSFER_POLICY=<TransferPolicy object ID>
export KIOSK_TRANSFER_POLICY_CAP=<TransferPolicyCap object ID>
```


```bash
sui client call --package $MARKETPLACE_PACKAGE_ID --module giftcard_royalty_rule --function add --args $KIOSK_TRANSFER_POLICY $KIOSK_TRANSFER_POLICY_CAP 10 100 --type-args $MARKETPLACE_PACKAGE_ID::giftcard_nft::GIFTCARD --gas-budget 10000000
```

export KIOSK_GIFTCARD=<Object ID of the listed >

```bash
sui client call --package $MARKETPLACE_PACKAGE_ID --module giftcard_nft --function place --args $KIOSK $KIOSK_OWNER_CAP $GIFTCARD --gas-budget 10000000
```

```bash
sui client call --package $MARKETPLACE_PACKAGE_ID --module giftcard_nft --function list --args $KIOSK $KIOSK_OWNER_CAP $GIFTCARD 10000 --gas-budget 10000000
```



