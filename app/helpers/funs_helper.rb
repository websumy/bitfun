module FunsHelper

  def render_fun_partial(fun, partial)
    render "funs/#{fun.content_type.downcase.pluralize}/#{partial}", fun: fun
  end

end