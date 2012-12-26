class DatePickerInput < SimpleForm::Inputs::StringInput
  def input
    output = @builder.text_field(attribute_name,input_html_options) << template.content_tag(:span, template.content_tag(:i, "", class: "icon-calendar"), class: "add-on")
    template.content_tag(:div, output, class: "input-append")
  end
end