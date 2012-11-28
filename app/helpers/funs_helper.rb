module FunsHelper

  def show_fields fun
    type = fun.content_type.downcase
    render "funs/#{type.pluralize}/show", type.to_sym => fun.content
  end

end