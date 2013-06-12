class ContactsController < ApplicationController

  # POST /contacts.json
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save
        format.html { redirect_to root_path, notice: t('user.contact_us.success') }
      else
        format.html { redirect_to static_path('contact'), notice: t('user.contact_us.filure') }
      end
    end
  end

end
