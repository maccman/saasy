module BillingHelper  
  def card_types           
    types = [
      ['Visa', 'visa'], 
      ['Mastercard', 'master'], 
      ['American Express', 'american_express']
    ]
    types << ['Bogus', 'bogus'] if SubConfig.test
    types
  end
  
  def plans
    SubConfig.plans.collect {|plan|
      plan = plan.with_indifferent_access
      if block_given?
        yield(plan[:name], plan)
      else
        nice_name = plan[:humanized] || plan[:name].humanize
        ["#{nice_name} - #{humanize_plan(plan)}", plan[:name]]
      end
    }
  end
  
  # todo - Needs refactoring
  def month_names
    Date::MONTHNAMES[1..12].collect {|name| 
      index = Date::MONTHNAMES.index(name)
      if block_given?
        yield(name, index)
      else
        [name, index]
      end
    }
  end
  
  # todo - Needs refactoring
  def next_fifteen_years
    cy = Time.now.year
    (cy..(cy + 15)).collect {|year| 
      if block_given?
        yield(year)
      else
        [year, year]
      end
    }
  end
end
