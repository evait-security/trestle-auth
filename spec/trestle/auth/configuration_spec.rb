require "spec_helper"

describe Trestle::Auth::Configuration do
  subject(:config) { Trestle::Auth::Configuration.new }

  let(:model) { double }
  let(:user) { double(locale: "en-AU", time_zone: "Australia/Adelaide") }
  let(:params) { double }
  let(:block) { -> {} }

  let(:login_url) { "/admin/login" }

  it "has a user_class configuration option" do
    expect(config).to have_accessor(:user_class).with_default(::Administrator)
  end

  it "has a user_scope configuration option" do
    expect(config).to have_accessor(:user_scope).with_default(::Administrator)
  end

  it "has a user_admin configuration option" do
    expect(config).to have_accessor(:user_admin)
  end

  it "has an authenticate_with configuration option" do
    expect(config).to have_accessor(:authenticate_with).with_default(:email)
  end

  it "has an authenticate configuration block option" do
    expect(config).to have_accessor(:authenticate)

    config.authenticate = ->(params) {
      model.authenticate(params)
    }

    expect(model).to receive(:authenticate).with(params)
    config.authenticate(params)
  end

  it "has a find_user configuration block option" do
    expect(config).to have_accessor(:find_user)

    config.find_user = ->(id) {
      model.find_user(id)
    }

    expect(model).to receive(:find_user).with(123)
    config.find_user(123)
  end

  it "has an avatar configuration block option" do
    config.avatar = block
    expect(config.avatar).to eq(block)
  end

  it "has a format_user_name configuration block option" do
    config.format_user_name = block
    expect(config.format_user_name).to eq(block)
  end

  it "has a locale configuration block option" do
    config.locale = block
    expect(config.locale).to eq(block)
  end

  it "has a default locale block" do
    expect(config.locale.call(user)).to eq("en-AU")
  end

  it "has a time_zone configuration block option" do
    config.time_zone = block
    expect(config.time_zone).to eq(block)
  end

  it "has a default time_zone block" do
    expect(config.time_zone.call(user)).to eq("Australia/Adelaide")
  end

  it "has a redirect_on_login configuration block option" do
    config.redirect_on_login = block
    expect(config.redirect_on_login).to eq(block)
  end

  it "has a default redirect_on_login block" do
    expect(instance_exec(&config.redirect_on_login)).to eq("/admin")
  end

  it "has a redirect_on_logout configuration block option" do
    config.redirect_on_logout = block
    expect(config.redirect_on_logout).to eq(block)
  end

  it "has a default redirect_on_logout block" do
    expect(instance_exec(&config.redirect_on_logout)).to eq("/admin/login")
  end

  it "has a logo configuration option" do
    expect(config).to have_accessor(:logo)
  end

  it "has a configuration set for remember options" do
    expect(config.remember).to be_an_instance_of(Trestle::Auth::Configuration::Rememberable)
  end

  describe Trestle::Auth::Configuration::Rememberable do
    subject(:config) { Trestle::Auth::Configuration::Rememberable.new }

    let(:user) { double(remember_token: "token", remember_token_expires_at: 2.weeks.from_now) }

    it "has an enabled configuration option" do
      expect(config).to have_accessor(:enabled).with_default(true)
    end

    it "has a cookie duration (#for) configuration option" do
      expect(config).to have_accessor(:for).with_default(2.weeks)
    end

    it "has an authenticate configuration block option" do
      expect(config).to have_accessor(:authenticate)

      config.authenticate = ->(token) {
        model.authenticate_with_remember_token(token)
      }

      expect(model).to receive(:authenticate_with_remember_token).with("token")
      config.authenticate("token")
    end

    it "has a remember_me configuration block option" do
      expect(config).to have_accessor(:remember_me)

      config.remember_me = ->(user) {
        user.remember!
      }

      expect(user).to receive(:remember!)
      config.remember_me(user)
    end

    it "has a default remember_me block" do
      expect(user).to receive(:remember_me!)
      config.remember_me(user)
    end

    it "has a forget_me configuration block option" do
      expect(config).to have_accessor(:forget_me)

      config.forget_me = ->(user) {
        user.forget!
      }

      expect(user).to receive(:forget!)
      config.forget_me(user)
    end

    it "has a default forget_me block" do
      expect(user).to receive(:forget_me!)
      config.forget_me(user)
    end

    it "has a cookie configuration block option" do
      expect(config).to have_accessor(:cookie)
      expect(config.cookie(user)).to eq({ value: user.remember_token, expires: user.remember_token_expires_at })
    end
  end
end
