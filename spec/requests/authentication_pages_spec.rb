require 'spec_helper'

describe "Authentication" do
  
  subject { page }

  describe "signin" do
   before { visit signin_path }

     describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('title', text:'Sign in') }
      it { should have_selector('div.flash.error', text:'Invalid') }
      
      describe "after visiting another page" do
       before { click_link "Home" }
       it { should_not have_selector('div.flash.error') }
      end
     end

     describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

         it { should have_selector('title', text: user.name) }
         
         it { should have_link('Users', href: users_path) }  
         it { should have_link('Profile',  href: user_path(user)) }
         it { should have_link('Settings', href: edit_user_path(user)) }
         it { should have_link('Sign out', href: signout_path) }

         it { should_not have_link('Sign in', href: signin_path) }

       fill_in "Email", with: user.email
       fill_in "Password", with: user.password
       click_button "Sign in"
       
        describe "followed by signout" do
          before { click_link "Sign out" }
          it { should have_link('Sign in') }
        end
       
        describe "authorization" do
          
          describe "for non-signed-in users" do
            let(:user) { FactoryGirl.create(:user) }

            describe "when attempting to visit a protected page" do
             before do
              visit edit_user_path(user)
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
             end

            describe "visiting user index" do
             before { visit users_path }
             it { should have_selector('title', text:'Sign in') }
            end

           describe "after signing in" do

              it "should render the desired protected page" do
                page.should have_selector('', text: 'Edit user')
           end

           describe "in the Microposts controller" do

          describe "submitting to the create action" do
            before { post microposts_path }
            specify { response.should redirect_to(signin_path) }
          end

          describe "submitting to the destroy action" do
            before do
              micropost = FactoryGirl.create(:micropost)
              delete micropost_path(micropost)
            end
            specify { response.should redirect_to(signin_path) }
          end
        end

      describe "" do
       let(:user) { FactoryGirl.create(:user) }
       let(:non_admin) { FactoryGirl.create(:user) }
 
       before { sign_in non_admin }
    
       describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end 
    end
  end
end
end