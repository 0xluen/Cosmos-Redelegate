#!/bin/bash

while true; do
  output=$(tenetd query distribution rewards <WalletAddress> <Valoper Address> )

  amount=$(echo $output | grep -oP 'amount: "\K[^.]+' | sed 's/"//')

  result=$(echo "scale=2; $amount/1000000000000000000" | bc)

  if (( $(echo "$result > 2" |bc -l) )); then
    /usr/bin/expect <<EOD
    spawn tenetd tx distribution withdraw-rewards <ValoperAddress> --from=<WalletName>  --commission --chain-id=<ChainId>--gas-adjustment=1.5  --fees=44659140000000000atenet

    expect "Enter keyring passphrase:"
    send "<Password>\r"

    expect "confirm transaction before signing and broadcasting \[y/N\]:"
    send "y\r"
    send "\r"
    expect eof
EOD

    sleep 8

    /usr/bin/expect <<EOD
    spawn tenetd tx staking delegate <Valoper Address> 2000000000000000000atenet --from=<WalletName> --gas=auto --gas-adjustment=1.5
    expect "Enter keyring passphrase:"
    send "<Password>\r"

    expect "confirm transaction before signing and broadcasting \[y/N\]:"
    send "y\r"
    send "\r"

    expect eof
EOD
    echo $result
  else
    echo "Waiting..."
    sleep 3
  fi
done
