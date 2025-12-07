require "ostruct"
require "uri"

class MessagesController < ApplicationController
  def new
    @corpse_flower = CorpseFlower.find_by(id: params[:corpse_flower_id])
    @message = OpenStruct.new(
      email:  current_user&.email,
      subject: "",
      body:    ""
    )
    @errors = []
  end

  def create
    @corpse_flower = CorpseFlower.find_by(id: params[:corpse_flower_id])

    @message = OpenStruct.new(message_params.to_h)
    @errors  = validate_message(@message)

    if @errors.any?
      flash.now[:alert] = "Please fix the errors below."
      render :new, status: :unprocessable_entity
    else
      AdminMailer.contact_email(
        @message.email,
        @message.subject,
        @message.body,
        @corpse_flower
      ).deliver_now

      flash[:notice] = "Your message has been sent to the admin."
      redirect_to(@corpse_flower || root_path)
    end
  end

  private

  def message_params
    params.require(:message).permit(:email, :subject, :body)
  end

  def validate_message(message)
    errors = []

    email = message.email.to_s.strip
    subject = message.subject.to_s.strip
    body = message.body.to_s.strip

    if email.empty?
      errors << "Email can't be blank"
    else
      begin
        unless email.match?(URI::MailTo::EMAIL_REGEXP)
          errors << "Email must be a valid email address"
        end
      rescue
        # In case URI::MailTo::EMAIL_REGEXP is not available, do a simple check
        errors << "Email must be a valid email address" unless email.include?("@")
      end
    end

    errors << "Subject can't be blank" if subject.empty?
    errors << "Message can't be blank" if body.empty?

    errors
  end
end
