# View test helpers
module ViewHelpers
  def have_form(action, method = :post)
    have_css("form[action='#{action}'][method='#{method.to_s.upcase}']")
  end

  def have_field(name, options = {})
    selector = "input[name='#{name}']"
    selector = "textarea[name='#{name}']" if options[:type] == 'textarea'
    selector = "select[name='#{name}']" if options[:type] == 'select'
    
    if options[:type]
      selector += "[type='#{options[:type]}']"
    end
    
    if options[:with]
      selector += "[value='#{options[:with]}']"
    end
    
    if options[:selected]
      selector += " option[selected='selected'][value='#{options[:selected]}']"
    end
    
    have_css(selector)
  end

  def have_select(name, options = {})
    selector = "select[name='#{name}']"
    
    if options[:with_options]
      options[:with_options].each do |option|
        selector += " option[value='#{option}']"
      end
    end
    
    if options[:selected]
      selector += " option[selected='selected'][value='#{options[:selected]}']"
    end
    
    have_css(selector)
  end

  def have_button(text)
    have_css("input[type='submit'][value='#{text}']") || have_css("button[type='submit']", text: text)
  end

  def have_link(text, options = {})
    if options[:href]
      have_css("a[href='#{options[:href]}']", text: text)
    else
      have_css("a", text: text)
    end
  end
end

RSpec.configure do |config|
  config.include ViewHelpers, type: :view
  
  # Add current_user and logged_in? helpers for view tests
  config.before(:each, type: :view) do
    view.extend(Module.new do
      def current_user
        @current_user
      end
      
      def logged_in?
        !@current_user.nil?
      end
    end)
  end
end
