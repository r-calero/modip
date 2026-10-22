# "Forgot your password?": sends a signed link that is valid for one hour and
# only until the password changes (it carries a fingerprint of the current hash).
class PasswordResetsController < ApplicationController
  include FormProtection
  skip_before_filter :authorize

  TOKEN_TTL = 3600 # seconds

  # GET /password/forgot
  def new
  end

  # POST /password/forgot
  def create
    unless human_form_submission?
      flash.now[:notice] = "Please complete the verification and try again"
      return render(:action => "new")
    end
    user = User.where(:email => params[:email].to_s.strip).first
    if user && user.name != User::DefaultUser
      token = SignedToken.generate('password-reset', { 'user_id' => user.id, 'fingerprint' => user.password_fingerprint }, TOKEN_TTL)
      begin
        Notifier.password_reset(user.email, user.name, edit_password_reset_url(:token => token)).deliver
      rescue StandardError, Timeout::Error => e
        logger.error("[password reset] could not send the e-mail to user #{user.id}: #{e.class}: #{e.message}")
      end
    end
    # Same answer whether the address exists or not.
    redirect_to login_url, :notice => "If that e-mail belongs to an account, we sent it a link to choose a new password."
  end

  # GET /password/reset?token=...
  def edit
    @token = params[:token]
    redirect_to(new_password_reset_url, :notice => "The link is invalid or has expired") unless reset_user(@token)
  end

  # POST /password/reset
  def update
    @token = params[:token]
    user = reset_user(@token)
    return redirect_to(new_password_reset_url, :notice => "The link is invalid or has expired") unless user
    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    if params[:password].present? && user.save
      reset_session
      redirect_to login_url, :notice => "Your password was changed. Please log in."
    else
      @errors = params[:password].present? ? user.errors.full_messages : ["Please enter a new password"]
      render :action => "edit"
    end
  end

  private

  def reset_user(token)
    data = SignedToken.verify('password-reset', token)
    return nil unless data
    user = User.find_by_id(data['user_id'])
    user if user && user.password_fingerprint == data['fingerprint']
  end
end
