require 'spec_helper'

describe Api::UsersController do

  let(:alice){ covered.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:bob)  { covered.users.find_by_email_address!('bob@ucsd.example.com') }

   when_not_signed_in do

    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end

  end

  when_signed_in_as 'bob@ucsd.example.com' do
    describe 'show' do
      context "when given bob's id" do
        it 'renders the current user as json' do
          xhr :get, :show, format: :json, id: bob.id
          expect(response.status).to eq 200
          expect(response.body).to eq Api::UsersSerializer[current_user].to_json
        end
      end
      context "when given alice's id" do
        it 'renders unauthorized' do
          xhr :get, :show, format: :json, id: alice.id
          expect(response.status).to eq 401
          expect(response.body).to be_blank
        end
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do
    describe 'show' do
      context "when given alice's id" do
        it 'renders the current user as json' do
          xhr :get, :show, format: :json, id: alice.id
          expect(response.status).to eq 200
          expect(response.body).to eq Api::UsersSerializer[current_user].to_json
        end
      end
      context "when given bob's id" do
        it 'renders unauthorized' do
          xhr :get, :show, format: :json, id: bob.id
          expect(response.status).to eq 401
          expect(response.body).to be_blank
        end
      end
    end
  end

end
