# OpengraphTransporter

opengraph_transporter is a Ruby console app that exports Facebook OpenGraph translations between Developer Apps. 
Alpha version software release. 

## Installation

Add this line to your application's Gemfile:

    gem 'opengraph_transporter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opengraph_transporter
    
    
## Requirements

### Functional
* Ruby 1.9.3 or higher
* Firefox 22.0.0 or higher

### Facebook 
* Admin Role on Facebook Developer Applications used in translations export process.
* Translation process is dependent on English(US) primary language selection (this will be configurable in future releases).

## Usage

1. Run opengraph_transporter
2. Enter Source Facebook Developer App ID and App Secret
3. Enter Destination Facebook Developer App ID and App Secret
4. Enter App translations locale.
5. Follow the prompts.


```
$ Please Enter Destination Application Secret
  29ae3b7d426106eae639754eb6855ef1
  
$ Please Enter App Locale
  pt_BR
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
