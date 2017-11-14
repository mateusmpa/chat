require 'rails_helper'

RSpec.describe TeamUsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'

    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = create(:user)
    sign_in @current_user
  end

  describe 'POST #create' do
    #Sem isto os testes não renderizam o json
    render_views

    context 'team owner' do
      before(:each) do
        @team = create(:team, user: @current_user)
        @guest_user = create(:user)

        post :create, params: { team_user: { email: @guest_user.email, team_id: @team.id } }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'return the right params' do
        response_hash = JSON.parse(response.body)

        expect(response_hash['team_id']).to eq(@team.id)
        expect(response_hash['user']['name']).to eq(@guest_user.name)
        expect(response_hash['user']['email']).to eq(@guest_user.email)
      end
    end

    context 'team not owner' do
      before(:each) do
        @team = create(:team)
        @guest_user = create(:user)
      end

      it 'returns http forbidden' do
        post :create, params: { team_user: { email: @guest_user.email, team_id: @team.id } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'team owner' do
      before(:each) do
        @team = create(:team, user: @current_user)
        @guest_user = create(:user)
        @team.users << @guest_user
      end

      it 'returns http success' do
        delete :destroy, params: { team_id: @team.id, id: @guest_user.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'team not owner' do
      before(:each) do
        @team = create(:team)
        @guest_user = create(:user)
      end

      it 'returns http forbdden' do
        delete :destroy, params: { team_id: @team.id, id: @guest_user.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
