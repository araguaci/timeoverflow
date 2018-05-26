require 'spec_helper'

describe OrganizationsController do
  let!(:organization) { Fabricate(:organization) }
  let(:member) { Fabricate(:member, organization: organization) }

  describe 'GET #show' do
    context 'with a logged user (organization member)' do
      it 'links to new_transfer_path' do
        login(member.user)

        get 'show', id: organization.id
        expect(response.body).to include(
          "<a href=\"/transfers/new?destination_account_id=#{organization.account.id}&amp;id=#{organization.id}\">"
        )
      end
    end
  end

  describe 'GET #index' do
    it 'populates and array of organizations' do
      get :index

      expect(assigns(:organizations)).to eq([organization])
    end
  end

  describe 'POST #create' do
    it 'only superdamins are authorized create to new organizations' do
      login(member.user)

      expect {
        post :create, organization: { name: 'New cool organization' }
      }.not_to change { Organization.count }
    end
  end

  describe 'POST #update' do
    context 'with a logged user (admins organization)' do
      let(:member) { Fabricate(:member, organization: organization, manager: true) }

      it 'allows to update organization' do
        login(member.user)

        post :update, id: organization.id, organization: { name: 'New org name' }

        organization.reload
        expect(organization.name).to eq('New org name')
      end
    end

    context 'without a logged user' do
      it 'does not allow to update organization' do
        post :update, id: organization.id, organization: { name: 'New org name' }

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq('You are not authorized to perform this action.')
      end
    end
  end
end
