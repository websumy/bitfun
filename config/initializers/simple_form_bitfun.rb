# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bitfun, :tag => 'div', :class => 'control-group', :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :auth_form, :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input, :class => 'input-xxlarge'
  end

  config.wrappers :none, :tag => 'div' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input
    b.use :error, :wrap_with => { :tag => 'div', :class => 'error-block' }
  end

  config.wrappers :label, :tag => false do |b|
    b.use :input
    b.use :label
  end

  config.wrappers :append, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
    end
  end

  config.default_wrapper = :bitfun
end
