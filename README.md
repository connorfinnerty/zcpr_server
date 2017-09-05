# Zip Code Population Retriever (ZCPR)

Simple API for retrieving information about population from US zipcode data.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

To get started you will need a machine with ruby and a gem manager installed.  Once that's done, navigate to the root directory of the repo in a terminal window, and install the necessary gems by running `bundle install`.  

To start the Sinatra web server, open a terminal window and execute the following command: `ruby zipcode_parser.rb`
This will start a server on the default local port, 4567.


## Using the API

The following examples illustrate how to interact with the ZCPR API using curl on the command line:

```
curl http://localhost:4567/

Zip Code Population Retriever (ZCPR):
    1. Return states with populations above 10 Million
    ex: localhost:4567/state-populations-above-ten-million
    2. Return average city population by state
    ex: localhost:4567/average-city-population/NY
    3. Return largest and smallest cities by state
    ex. localhost:4567/min-and-max-city-populations/NY
```

### 1. Return states with populations above 10 Million
```
curl http://localhost:4567/state-populations-above-ten-million

should return:

[{"_id"=>"NY", "totalPop"=>17990402}, {"_id"=>"PA", "totalPop"=>11881643}, {"_id"=>"FL", "totalPop"=>12686644}, {"_id"=>"OH", "totalPop"=>10846517}, {"_id"=>"IL", "totalPop"=>11427576}, {"_id"=>"TX", "totalPop"=>16984601}, {"_id"=>"CA", "totalPop"=>29754890}]
```

### 2. Return average city population by state
```
curl http://localhost:4567/average-city-population/NY

should return:

{'_id'=>'NY', 'avgCityPop'=>13131}
```

### 3. Return largest and smallest cities by state
```
curl localhost:4567/min-and-max-city-populations/NY

should return:

{'_id'=>'NY', 'avgCityPop'=>{"state"=>"NY", "biggestCity"=>{"name"=>"BROOKLYN", "pop"=>2300504}, "smallestCity"=>{"name"=>"CHILDWOLD", "pop"=>0}}}
```

## Testing with RSpec

Running `rake` from the root directory will run the test suite, located in `zipcode_parser_spec.rb`

## Linter: Rubocop

Execute the command: `rake rubocop` from the root directory and the linter, Rubocop, will run through the code.  To make changes to the style rules, refer to the documentation at https://rubocop.readthedocs.io/en/latest/ and edit the config file: `.rubocop.yml`
