module ForecastsHelper

  def rbm_options
    ["Libby Bishop", "Juliet Depina", "Brian McMurray"]
  end

  def account_exec_options
    ["Nicole Tilton", "Kevin Gordon"]
  end

  def stage_options
    %w(   Prospecting Qualification Needs\ Analysis Selected Committed/Order\ Pending Closed/Won Closed/Lost   )
  end

  def product_options
    [ 
            "60 Day Migration License",
            "Annual Day Migration License",
            "SB15",
            "SB100",
            "Standard",
            "Professional",
            "Enterprise"
    ]
  end
end