#!/bin/sh

set -e

# Check if file or directory exists. Exit if it doesn't.
examine() {
    if [ ! -f $1 ] && [ ! -d $1 ]; then
        echo "\n-- ERROR -- $1 could not be found!\n"
        exit 1
    fi
}

# Lint a PHP file for syntax errors. Exit on error.
lint() {
    # echo "\n -- MISSING -- Lint file $1"
    RESULT=$(php -l $1)
    if [ ! $? -eq 0 ] ; then
        echo "$RESULT" && exit 1
    fi
}

if [ ! -f ".env" ]; then
    echo 'APP_KEY=' > .env
    php artisan key:generate
fi

#examine "app/Providers"
#examine "app/Providers/RouteServiceProvider.php"
#examine "resources"
#examine "resources/lang"
#examine "resources/views"
#examine "resources/views/welcome.blade.php"
#lint "resources/views/welcome.blade.php"
#examine "routes"
#examine "routes/api.php"
#examine "routes/web.php"
#lint "routes/api.php"
#lint "routes/web.php"
#examine "tests"

## --- Micro ---

# Controller
../lucid make:controller trade
examine "app/Http/Controllers/TradeController.php"
lint "app/Http/Controllers/TradeController.php"

# Feature
./vendor/bin/lucid make:feature trade
examine "app/Features/trade__feature.php"
lint "app/Features/trade__feature.php"
examine "tests/Feature/trade__feature__Test.php"
lint "tests/Feature/trade__feature__Test.php"

# Job
./vendor/bin/lucid make:job submitTradeRequest shipping
examine "app/Domains/Shipping/Jobs/submit__trade__request__job.php"
lint "app/Domains/Shipping/Jobs/submit__trade__request__job.php"
examine "tests/Unit/Domains/Shipping/Jobs/submit__trade__request__job__Test.php"
lint "tests/Unit/Domains/Shipping/Jobs/SubmitTradeRequestJobTest.php"

./vendor/bin/lucid make:job sail boat --queue
examine "app/Domains/Boat/Jobs/SailJob.php"
lint "app/Domains/Boat/Jobs/SailJob.php"
examine "tests/Unit/Domains/Boat/Jobs/SailJobTest.php"
lint "tests/Unit/Domains/Boat/Jobs/SailJobTest.php"

# Model
./vendor/bin/lucid make:model bridge
examine "app/Data/Bridge.php"
lint "app/Data/Bridge.php"

# Operation
./vendor/bin/lucid make:operation spin
examine "app/Operations/spin__operation.php"
lint "app/Operations/spin__operation.php"
examine "tests/Unit/Operations/spin__operation__Test.php"
lint "tests/Unit/Operations/spin__operation__Test.php"

./vendor/bin/lucid make:operation twist --queue
examine "app/Operations/TwistOperation.php"
lint "app/Operations/TwistOperation.php"
examine "tests/Unit/Operations/TwistOperationTest.php"
lint "tests/Unit/Operations/TwistOperationTest.php"

# Policy
./vendor/bin/lucid make:policy fly
examine "app/Policies/FlyPolicy.php"
lint "app/Policies/FlyPolicy.php"

# Ensure nothing is breaking
./vendor/bin/lucid list:features
./vendor/bin/lucid list:services

# Run PHPUnit tests
./vendor/bin/phpunit

echo "\nMicro tests PASSED!\n"

## --- Monolith ---

# Controller
./vendor/bin/lucid make:controller trade harbour
examine "app/Services/Harbour/Http/Controllers/TradeController.php"
lint "app/Services/Harbour/Http/Controllers/TradeController.php"

# Feature
./vendor/bin/lucid make:feature trade harbour
examine "app/Services/Harbour/Features/trade__feature.php"
lint "app/Services/Harbour/Features/trade__feature.php"
examine "tests/Feature/Services/Harbour/trade__feature__Test.php"
lint "tests/Feature/Services/Harbour/trade__feature__Test.php"

## Operation
./vendor/bin/lucid make:operation spin harbour
examine "app/Services/Harbour/Operations/spin__operation.php"
lint "app/Services/Harbour/Operations/spin__operation.php"
examine "tests/Unit/Services/Harbour/Operations/spin__operation__Test.php"
lint "tests/Unit/Services/Harbour/Operations/spin__operation__Test.php"

./vendor/bin/lucid make:operation twist harbour --queue
examine "app/Services/Harbour/Operations/twist__operation.php"
lint "app/Services/Harbour/Operations/twist__operation.php"
examine "tests/Unit/Services/Harbour/Operations/twist__operation__Test.php"
lint "tests/Unit/Services/Harbour/Operations/twist__operation__Test.php"

# Ensure nothing is breaking
./vendor/bin/lucid list:features
./vendor/bin/lucid list:services

./vendor/bin/phpunit

## --- TEARDOWN ---

./vendor/bin/lucid delete:feature trade
./vendor/bin/lucid delete:job submitTradeRequest shipping
./vendor/bin/lucid delete:job sail boat
./vendor/bin/lucid delete:model bridge
./vendor/bin/lucid delete:operation spin
./vendor/bin/lucid delete:operation twist
./vendor/bin/lucid delete:policy fly
rm app/Http/Controllers/TradeController.php

./vendor/bin/lucid delete:feature trade harbour
./vendor/bin/lucid delete:operation spin harbour
./vendor/bin/lucid delete:operation twist harbour
rm app/Services/Harbour/Http/Controllers/TradeController.php

echo "\nPASSED!\n"

exit 0
