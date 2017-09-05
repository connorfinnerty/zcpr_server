require File.dirname(__FILE__) + '/zipcode_parser.rb'
require 'rack/test'

set :environment, :test

def app
  Sinatra::Application
end

describe 'Zipcode service' do
  include Rack::Test::Methods

  it 'should return instructions' do
    get '/'
    expect(last_response.body).to include
    "Zip Code Population Retriever (ZCPR):
    1. Return states with populations above 10 Million
    ex: localhost:4567/state-populations-above-ten-million
    2. Return average city population by state
    ex: localhost:4567/average-city-population/NY
    3. Return largest and smallest cities by state
    ex. localhost:4567/min-and-max-city-populations/NY"
    expect(last_response).to be_ok
  end

  it 'should validate the selected state name' do
    get '/avg-city-population/NYC'
    expect(last_response.body).to include
    'Sorry, your input was invalid. Please enter the abbreviated name of a state like NY'
  end

  it 'should return a list of states with population above ten million' do
    get '/state-populations-above-ten-million'
    new_york_population = '17990402'
    expect(last_response.body).to include new_york_population
    expect(last_response).to be_ok
  end

  it 'should return the average city population for a given state' do
    get '/average-city-population/MN'
    expect(last_response.body).to include "{'_id'=>'MN', 'avgCityPop'=>5372}"
    expect(last_response).to be_ok
  end

  it 'should return the smallest and largest cities for a given state' do
    get '/min-and-max-city-populations/MN'
    expect(last_response.body).to include
    "{'_id'=>'MN', 'avgCityPop'=>{\"state\"=>\"MN\", \"biggestCity\"=>{\"name\"=>\"MINNEAPOLIS\", \"pop\"=>344719}, \"smallestCity\"=>{\"name\"=>\"JOHNSON\", \"pop\"=>12}}}"
    expect(last_response).to be_ok
  end

  it 'should fail to load bad path' do
    get '/badpath'
    expect(last_response).to_not be_ok
  end
end