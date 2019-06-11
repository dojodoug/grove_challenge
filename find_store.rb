require "docopt"
require "csv"
require "geocoder"
require "json"


@doc = <<DOCOPT
  Find Store.

  Usage:
    #{__FILE__} --address="<address>"
    #{__FILE__} --address="<address>" [--units=(mi|km)] [--output=text|json]
    #{__FILE__} --zip="<zip>"
    #{__FILE__} --zip="<zip>" [--units=(mi|km)] [--output=text|json]
  Options:
    --zip=<zip>               Find nearest store to this zip code. If there are multiple best-matches, return the first.
    --address=<address>       Find nearest store to this address. If there are multiple best-matches, return the first.
    --units=(mi|km)           Display units in miles or kilometers [default: mi]
    --output=(text|json)      Output in human-readable text, or in JSON (e.g. machine-readable) [default: text]
    -h, --help                Show this help message and exit

DOCOPT

EARTH_RADIUS = 6371 #km
@nearest_store = {}
@nearest_distance = EARTH_RADIUS

begin
  def get_args
    @args = Docopt.docopt(@doc)
    @address = @args['--address']
    @zip = @args['--zip']
    @units = @args['--units']
    @output = @args['--output']
  end

  def convert_location_to_coords
    if @address
      @user_coords = Geocoder.coordinates(@address)
    elsif @zip
      # the geocoder gem unfortunately does not directly convert zipcodes into coordinates so the zipcode coordinates
      # are pieced together by pulling the latitude and longitude from the Geocoder::Result object that is returned
      zip_info = Geocoder.search(@zip[0])
      zip_latitude = zip_info[0].latitude
      zip_longitude = zip_info[0].longitude
      @user_coords = zip_latitude, zip_longitude
    end
  end

  def find_nearest_store(user_coords)
    CSV.foreach './store-locations.csv', {headers: true, encoding: 'ISO-8859-1'} do |row|
      store = row.to_h
      store_coords = [ store['Latitude'].to_f, store['Longitude'].to_f ]
      distance_to_store = haversine_distance(user_coords, store_coords)
      if distance_to_store < @nearest_distance
        @nearest_distance = distance_to_store
        @nearest_store = store
      end
    end
  end

  def haversine_distance(user_coords, store_coords)
    # Get latitude and longitude
    lat1, lon1 = user_coords
    lat2, lon2 = store_coords

    # Calculate radial arcs for latitude and longitude
    dLat = (lat2 - lat1) * Math::PI / 180
    dLon = (lon2 - lon1) * Math::PI / 180

    a = Math.sin(dLat / 2) * 
        Math.sin(dLat / 2) +
        Math.cos(lat1 * Math::PI / 180) * 
        Math.cos(lat2 * Math::PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2)
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    c * EARTH_RADIUS
  end

  def set_units
    if @units[0] == 'km'
      @nearest_distance = "#{@nearest_distance.round(2)} km"
    else
      @nearest_distance = "#{(@nearest_distance / 1.609344).round(2)} mi"
    end
  end

  def set_output
    if @output[0] == 'json'
      @nearest_store[:"Distance to Store"] = @nearest_distance
      puts JSON.pretty_generate @nearest_store
    else
      if @address
        @search_type = "address: #{@address}"
      elsif @zip
        @search_type = "zip code: #{@zip[0]}"
      end
      @store_name = @nearest_store['Store Name']
      @store_address = "#{@nearest_store['Address']}, #{@nearest_store['City']}, #{@nearest_store['State']}, #{@nearest_store['Zip Code']}"
      puts "\n"
      puts "Search results for the store nearest to #{@search_type}"
      puts "\nNearest Store: #{@store_name}"
      puts "Store Address: #{@store_address}"
      puts "Distance to Store: #{@nearest_distance}"
      puts "\n"
    end
  end

  get_args
  convert_location_to_coords
  find_nearest_store(@user_coords)
  set_units
  set_output
rescue Docopt::Exit => e
  puts e.message
end