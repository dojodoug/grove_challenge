# Store Locator Coding Challenge

This challenge creates a command-line application that uses a tabular dataset for a major national retail chain to find the nearest store locations based on a given address or zip code.

# Requirements

This application is written in Ruby. Please refer to the [Ruby docs](https://www.ruby-lang.org/en/documentation/installation/) if you will need to install Ruby on your own machine. This application also utilizes several Ruby gems: [docopt](https://github.com/docopt/docopt.rb), [csv](https://github.com/ruby/csv), [geocoder](http://www.rubygeocoder.com), and [json](https://github.com/ruby/json). To install these gems you will need to run the following command in your terminal: 
`gem install docopt csv geocoder json`

# Execution

To execute this program open the terminal and navigate to the location where you have saved the find_store.rb file. Then run find_store.rb along with any of the options shown below. At a minimum an address or a zip code is required when running the file.\
Examples:\
`ruby find_store.rb --address='1770 Union St, San Francisco, CA 94123'`\
`ruby find_store.rb --zip=94115 --units=km`

```
Usage:
  find_store --address="<address>"
  find_store --address="<address>" [--units=(mi|km)] [--output=text|json]
  find_store --zip=<zip>
  find_store --zip=<zip> [--units=(mi|km)] [--output=text|json]

Options:
  --zip=<zip>            Find nearest store to this zip code. If there are multiple best-matches, return the first.
  --address="<address>"  Find nearest store to this address. If there are multiple best-matches, return the first.
  --units=(mi|km)        Display units in miles or kilometers [default: mi]
  --output=(text|json)   Output in human-readable text, or in JSON (e.g. machine-readable) [default: text]
```

# Details

This application converts the location information submitted by the user into the equivalent coordinates using the Geocoder Ruby gem. These coordinates are then used to determine the nearest store location by querying the dataset and comparing the distance to each store using the [haversine distance formula](https://gist.github.com/timols/5268103). The distance can be displayed in miles or kilometers based on the option selected by the user. The default unit of measurement is miles. The output can also be formatted in a text format or json, again based on the option selected by the user, with the default format being text.
