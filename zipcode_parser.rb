require 'sinatra'
require 'json'
require 'pry'
require 'net/http'

@buffer = nil
@state_name = nil

def zipcode_dump
  @zipcode_dump ||= fetch_and_parse_zipcode_dump
  # For faster testing, we can use previously downloaded data:
  # @zipcode_dump ||= JSON.parse(File.read("zips.json"))
end

def fetch_and_parse_zipcode_dump
  @buffer ||= fetch_data("http://media.mongodb.org/zips.json")
  parse_data(@buffer)
end

def fetch_data(url)
  response = Net::HTTP.get_response(URI.parse(url))
  @buffer = response.body
end

# Each line of the response is it's own JSON object, so we will parse line by line into a ruby hash
def parse_data(buffer)
  @zipcode_dump = []
  buffer.each_line do |row|
    @zipcode_dump << JSON.parse(row)
  end
  @zipcode_dump
end

# Return instructions when the user makes a get request to '/'
get '/' do
  "Zip Code Population Retriever (ZCPR):
    1. Return states with populations above 10 Million
    ex: localhost:4567/state-populations-above-ten-million
    2. Return average city population by state
    ex: localhost:4567/average-city-population/NY
    3. Return largest and smallest cities by state
    ex. localhost:4567/min-and-max-city-populations/NY"
end

get '/state-populations-above-ten-million' do
  state_populations_above_ten_million
end

# We're passing a method to state_name_validator by using a proc, to consolidate code
get '/average-city-population/:state_name' do
  @state_name = params[:state_name]
  state_name_validator(proc { average_city_population })
end

get '/min-and-max-city-populations/:state_name' do
  @state_name = params[:state_name]
  state_name_validator(proc { min_and_max_city_populations })
end

# Checks state name parameter against a list of state names
def state_name_validator(function)
  if state_names_list.include?(@state_name)
    new_string = function.call
    "{'_id'=>" + "'#{@state_name}'" + ", 'avgCityPop'=>" + new_string.to_s + "}"
  else
    'Sorry, your input was invalid. Please enter the abbreviated name of a state like NY\n'
  end
end

def state_names_list
  %w[MA RI NH ME VT CT NY NJ PA DE DC MD VA WV NC SC GA FL AL TN MS KY OH IN MI IA WI MN SD ND MT IL MO KS NE LA AR OK TX CO WY ID UT AZ NM NV CA HI OR WA AK]
end

# Filters the zipcode dump to a ruby hash containing the cities and populations of one state
def cities_and_populations
  state_zipcode_populations = zipcode_dump.group_by { |zipcode| zipcode["state"] }[@state_name]
  {
    @state_name => state_zipcode_populations.group_by { |state| state["city"] }.map do |city, city_populations|
      {
        "city" => city,
        "population" => city_populations.map { |zipcode| zipcode["pop"] }.reduce(:+)
      }
    end
  }
end

def state_populations_above_ten_million
  # Filters the zipcode dump to a ruby hash of states and their total populations
  states_and_populations = zipcode_dump.group_by { |zipcode| zipcode["state"] }.map do |state_name, zipcodes|
    {
      "_id" => state_name,
      "totalPop" => zipcodes.map { |zipcode| zipcode["pop"] }.reduce(:+)
    }
  end
  # Filters the list of states and populations to those with a population over ten million
  states_and_populations.select { |state| state["totalPop"] > 10000000 }.to_s
end

def min_and_max_city_populations
  # Takes the list of a state's cities and populations and finds the cities with smallest and largest populations
  biggest_city = cities_and_populations[@state_name].max_by { |city| city["population"] }
  smallest_city = cities_and_populations[@state_name].min_by { |city| city["population"] }

  {
    "state" => @state_name,
    "biggestCity" => {
      "name"=> biggest_city["city"],
      "pop"=> biggest_city["population"]
    },
    "smallestCity" => {
      "name"=> smallest_city["city"],
      "pop"=> smallest_city["population"]
    }
  }
end

# Takes a sum of a state's city's populations using reduce, and divides by the number of cities in that state
def average_city_population
  cities_and_populations[@state_name].map { |city| city['population'] }.reduce(:+) / cities_and_populations[@state_name].size
end
