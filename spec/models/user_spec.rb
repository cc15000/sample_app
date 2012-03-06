# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe User do

 before do 
  @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it "should create a new instance given valid attributes" do
    User.create!(@user)
  end

  it "should require a name" do
    no_name_user = User.new(@user.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@user.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "f" * 51
    long_name_user = User.new(@user.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER3@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@user.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com THE_USER3_at_foo.org first.last@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@user.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@user)
    user_with_dup_email = User.new(@user)
    user_with_dup_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    User.create!(@user)
    upcase_email = @user[:email].upcase
    user_with_dup_email = User.new(@user.merge(:email => upcase_email))
    user_with_dup_email.should_not be_valid
  end

  it "should save email addresses in lowercase form" do
    user = User.create!(@user.merge(:email => @user[:email].upcase))
    user.email.should == @user[:email]
  end

  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }   
  it { should respond_to(:feed) }

  it { should be_valid }
  it { should_not be_admin }  
  
  describe "password validation" do
    it "should require a password" do
      User.new(@user.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@user.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @user.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @user.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do
    before :each do
      @user = User.create!(@user)
    end

    describe "has_password? method" do
     
     it "should be true if the passwords match" do
      @user.has_password?(@user[:password]).should be_true
     end
 
     it "should be false if the passwords don't match" do
      @user.has_password?("invalid").should be_false
     end
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to :encrypted_password
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "authenticate method" do

     it "should return nil on email/password mismatch" do
      wrong_password_user = User.authenticate(@user[:email], "wrongpass")
      wrong_password_user.should be_nil
     end
 
     it "should return nil for an email address with no user" do
      nonexistent_user = User.authenticate("bar@foo.com", @user[:password])
      nonexistent_user.should be_nil
     end

     it "should return the user on email/password match" do
      matching_user = User.authenticate(@user[:email], @user[:password])
      matching_user.should == @user     
     end
    end
 end

 describe "rememeber token" do
  before { @user.save }
  its(:remember_token) { should_not be_blank }
 end

 describe "with admin attribute set to 'true'" do
  before { @user.toggle!(:admin) }
  
  it { should be_admin }
 end
 
 describe "micropost associations" do
   
   before { @user.save }
   let!(:older_micropost) do
    FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
   end
   let!(:newer_micropost) do
    FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
   end

   it "should destroy associated microposts" do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |micropost|
       Micropost.find_by_id(micropost.id).should be_nil
      end
   end
  

   it "should have the right microposts in the right order" do
    @user.microposts.should == [newer_micropost, older_micropost]
   end

   describe "status" do
    let(:unfollowed_post) do
     FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
   end

   its(:feed) { should include(newer_micropost) }
   its(:feed) { should include(older_micropost) }
   its(:feed) { should_not include(unfollowed_post) }
  end
 end
end
