require 'spec_helper'

describe "UserPages" do
  subject { page }
  
  describe "signup" do
   before { visit signup_path }
   
   describe "error messages" do
    before { click_button "Sign up" }

    let(:error) { 'error prohibited this user from being saved' }

    it { should have_selector('title', text: 'Sign up') }
    it { should have_content(error) }
   end

    describe "with valid information" do
      
      describe "after saving the user" do
        before { click_button "Sign up" }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.flash.success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
    end   
  end
end
