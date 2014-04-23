require 'spec_helper'

describe NewOrganization, fixtures: false do

  let(:threadable){ Threadable.new(host: 'example.com') }

  let(:organization_name)      { 'CERN' }
  let(:email_address_username) { 'cern' }
  let(:your_name)              { 'Lawrence Krauss' }
  let(:your_email_address)     { 'l.krauss@gmail.com' }
  let(:password)               { 'hardoncollider' }
  let(:password_confirmation)  { 'hardoncollider' }
  let(:members)                { [] }

  let :controller do
    double(:controller,
      threadable: threadable,
      signed_in?: threadable.current_user_id.present?,
      current_user: threadable.current_user,
    )
  end

  def attributes
    {
      organization_name:      organization_name,
      email_address_username: email_address_username,
      your_name:              your_name,
      your_email_address:     your_email_address,
      password:               password,
      password_confirmation:  password_confirmation,
      members:                members,
    }
  end

  let(:new_organization){ described_class.new(controller, attributes) }
  subject{ new_organization }

  let :errors do
    subject.valid?
    subject.errors.to_a.to_set
  end

  it { expect(errors).to be_blank }

  context 'when organization_name is blank' do
    let(:organization_name){ '' }
    it { expect(errors).to include "Organization name can't be blank" }
  end

  context 'when email_address_username is blank' do
    let(:email_address_username){ '' }
    it { expect(errors).to include "Email address username can't be blank" }
  end

  context 'when email_address_username is invalid' do
    let(:email_address_username){ '-' }
    it { expect(errors).to include "Email address username is invalid" }
  end

  context 'when email_address_username is taken' do
    before{ Organization.create!(name: 'Robot Panda', email_address_username: 'robot-panda') }
    let(:email_address_username){ 'robot-panda' }
    it { expect(errors).to include "Email address username is taken" }
  end


  context 'when not signed in' do
    context 'when your_name is blank' do
      let(:your_name){ '' }
      it { expect(errors).to include "Your name can't be blank" }
    end
  end

  context 'when signed in' do
    before{ threadable.current_user_id = Factories.create(:user).id }
    context 'when your_name is blank' do
      let(:your_name){ '' }
      it { expect(errors).to be_blank }
    end
  end

  context 'when given empty members' do
    let(:members) do
      [
        {name: 'Alf Almerado', email_address: 'alf.almerado@example.com'},
        {name: '', email_address: ''},
        {name: 'Bob Boodock',  email_address: 'bob.boodock@example.com'},
      ]
    end
    it 'removes the empty members' do
      members = subject.members.map do |member|
        {name: member.name, email_address: member.email_address}
      end
      expect(members).to eq [
        {name: 'Alf Almerado', email_address: 'alf.almerado@example.com'},
        {name: 'Bob Boodock',  email_address: 'bob.boodock@example.com'},
      ]
    end
  end

  context 'when given invalid members' do
    let(:members) do
      [
        {name: '', email_address: 'alf.almerado@example.com'},
        {name: 'Bob Boodock',  email_address: 'bob.boodock@example'},
      ]
    end
    it 'is invalid' do
      expect(errors).to include "some members are invalid"
      expect(subject.members.first.errors.to_a).to include "Name can't be blank"
      expect(subject.members.last.errors.to_a).to include "Email address is invalid"
    end
  end

  context 'when the passwords do not match' do
    let(:password_confirmation){ 'asdsdsadasda' }
    it { expect(errors).to include "Password confirmation does not match password" }
  end

  context 'when the password is too short' do
    let(:password)               { 'h' }
    let(:password_confirmation)  { 'h' }
    it { expect(errors).to include "Password is too short (minimum is 6 characters)" }
  end

  describe '#create' do

    let(:members) do
      [
        {name: 'Alf Almerado', email_address: 'alf.almerado@example.com'},
        {name: 'Bob Boodock',  email_address: 'bob.boodock@example.com'},
      ]
    end

    context 'when not signed in' do
      let(:new_user){ double :new_user }
      it 'creates the user, then the org, then adds the members' do

        expect(controller).to receive(:sign_in!).
          with{ threadable.users.find_by_email_address!(your_email_address) }.
          and_return{|user| threadable.current_user = user; true }

        expect{
          expect{
            expect(subject.create).to be_true
          }.to change{ threadable.organizations.count }.by(1)
        }.to change{ threadable.users.count }.by(3)

        expect(subject.organization.members.count).to eq 3
      end

      context 'when the email has Upper Case characters' do
        let(:your_email_address) { 'ILoveUpperCase@gmail.com' }
        it 'finds the user using the lowercase email address' do
          expect(controller).to receive(:sign_in!).
            with{ threadable.users.find_by_email_address!('iloveuppercase@gmail.com') }.
            and_return{|user| threadable.current_user = user; true }

          expect(subject.create).to be_true

        end
      end
    end

    context 'when signed in' do
      before{ threadable.current_user_id = Factories.create(:user).id }
      it 'creates the org, then adds the members' do
        expect{
          expect{
            expect(subject.create).to be_true
          }.to change{ threadable.organizations.count }.by(1)
        }.to change{ threadable.users.count }.by(2)

        expect(subject.organization.members).to include threadable.current_user
        expect(subject.organization.members.count).to eq 3
      end
    end

    context 'when invalid' do
      let(:organization_name){ '' }
      it 'does nothing and returns false' do
        expect{
          expect(subject.create).to be_false
        }.to_not change{ threadable.organizations.count }
      end
    end

  end

end
