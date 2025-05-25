Midterm project
===============
- build a payment system

# requirements

## todo:

## wip:

## done:
-[x] tests must be written for any otp or graphql parts
  -[x] app code
    -[x] currencies
      -[x] read
      -[x] convert
      -[x] find_exchange_rate
    -[x] accounts
    -[x] wallet
      -[x] cannot delete default wallet
      -[x] cannot have two default wallets
      -[x] find total worth
      -[x] send money
  -[.] absinthe graphql
    -[x] queries
      -[x] user
      -[x] wallet
        -[x] find total worth
    -[x] mutation
      -[x] user
      -[x] wallet
        -[x] send money
    -[x] subscription
      -[x] totalWorthChange
      -[x] exchangeRateUpdated
      -[x] exchangeRatesUpdated
-[x] has a database of users with wallets
-[x] wallets have currencies with values
  -[x] currencies supported should be set in `config/` folder
-[x] user can have multiple wallets
  -[x] one of those wallets must be a default wallet
  -[x] cannot have two default wallets
  -[x] cannot delete default wallet
-[x] can send/receive money
-[x] has an exchange rate monitor
  -[x] must be process based monitoring
    -[x] must be able to fetch rates in interval
    -[x] interval specified in config
  -[x] can specify how often it updates
  -[x] rates will be USD base (!IMPORTANT!)
-[x] subscription for exchange rate
  -[x] per currency
  -[x] all currencies
-[x] subscription for current total worth in chosen currency
  -[x] updates when there are changes via send money
-[x] everything should be done over queries, mutations, and subscriptions

# PaymentServer design

## domains
- users
- wallets
- currencies

### domains relationship
- users 1-M wallets
- wallets 1-1 currencies

### domains attributes

#### currency list
this is a list in config folder
- id
- name
- code

#### user
- id
- name
- email
- default walet (total worth will be show in this currency)

#### wallet
- id
- user id
- default
- name
- currency (from currencies list in config)

## api interaction design

AlphaVantage <-> otp process <-> paymentserver

otp process detail
- fetch exchange rate of specific currency against default currency
- fetch the rate at an interval
- the interval must be configurable
- for all currencies, spin up other processes
