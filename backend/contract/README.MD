## Env setup

Check out the guide from [Aptos Learn](https://learn.aptoslabs.com/example/aptogotchi-beginner/env-setup).

## Play with testnet deployments on explorer

Go to testnet explorer [here](https://explorer.aptoslabs.com/?network=testnet) and search for the contract address.

You can find the contract address in each contract directory's `contract_address.txt`.

On explorer, you can read the contract code, call entry functions (need to connect wallet), and call view functions.

## Development

In each contract's `move` directory, you can run below commands.

Run unit test

```sh
./sh_scripts/test.sh
```

Deploy to testnet

```sh
./sh_scripts/deploy.sh
```

Upgrade deployed contract

```sh
./sh_scripts/upgrade.sh
```

Generate ABI TS types

```sh
./sh_scripts/get_abi.sh
```
