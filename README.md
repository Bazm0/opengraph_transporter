# OpengraphTransporter
[![Gem Version](https://badge.fury.io/rb/opengraph_transporter.png)](http://badge.fury.io/rb/opengraph_transporter)

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
* Translation process is dependent on correct selection of primary locale (locale translated from) and app locale (locale translated to), e.g. en_US to pt_BR.
* Consistent Destination App Open Graph story configuration.

## Usage

1. Run opengraph_transporter
2. Enter Source Facebook Developer App ID and App Secret
3. Enter Destination Facebook Developer App ID and App Secret
4. Enter Facebook translations Primary Locale (primary language locale - generally defaults to en_US).
5. Enter Facebook translations App locale.
6. Follow the prompts.


```
$ Please Enter Source Application Id
  619023458209241

$ Please Enter Source Application Secret
  2a1c3c1a878e8f52a8b7788dfe89g15b

$ Please Enter Destination Application Id
  639876543218648

$ Please Enter Destination Application Secret
  29ae3c3bd62106eae636132be8676eb2

$ Please Enter Primary Locale
  en_US

$ Please Enter App Locale
  pt_BR
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
