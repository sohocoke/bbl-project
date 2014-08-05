require 'configs'

describe "#delta_applied" do
  it "replaces predicated entries" do
    config = {
      'a' => 1,
      'b' => [
        {
          'c' => '0',
          'd' => 0
        },
        {
          'c' => '1',
          'd' => 0
        },
      ]
    }

    delta = {
      'b' => {
        "d[c='0']" => 2
      }
    }

    expect( delta_applied config, delta ).to eq( {
          'a' => 1,
          'b' => [
            {
              'c' => '0',
              'd' => 2
            },
            {
              'c' => '1',
              'd' => 0
            },
          ]      
        })
  end

  it "handles nested hashes" do
    config = {
      'a' => 1,
      'b' => {
        'c' => [
          {
            'c' => '0',
            'd' => 0
          },
          {
            'c' => '1',
            'd' => 0
          },
        ]
      }
    }

    delta = {
      'b' => {
        'c' => {
          "d[c='0']" => 2
        }
      }
    }

    # k: b, sub_k: c, has_predicate: false, 
    

    expect( delta_applied config, delta ).to eq( {
          'a' => 1,
          'b' => {
            'c' => [
              {
                'c' => '0',
                'd' => 2
              },
              {
                'c' => '1',
                'd' => 0
              },
            ]      
          }
        })
  end
end

describe "#dereferenced" do
  vars = {
    'some-var' => 'some-val'
  }

  str = <<-eos
    {
      "json-root": {
        "some-elem": "{var:some-var}"
      }
    }
  eos

  it "dereferences variables" do

    expect( dereferenced str.gsub(' ',''), vars ).to eq <<-eos
      {
        "json-root": {
          "some-elem": "some-val"
        }
      }
    eos
    .gsub(' ', '')
  end

  it "raises when variable is undefined" do
    vars = {}

    expect { dereferenced str, vars }.to raise_error

  end
end