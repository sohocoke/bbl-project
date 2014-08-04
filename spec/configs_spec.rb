require 'configs'

describe "delta_applied" do
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