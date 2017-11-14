require 'rails_helper'

RSpec.describe TalksController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'

    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = create(:user)
    sign_in @current_user
  end

  describe 'GET #show' do
    # Sem isto os teste não renderizam o json
    render_views

    context 'is talk member' do
      before(:each) do
        @team = create(:team)
        @guest_user = create(:user)
        @team.users << [@current_user, @guest_user]
        @talk = create(:talk, user_one: @current_user, user_two: @guest_user, team: @team)

        @message1 = build(:message, user: @current_user)
        @message2 = build(:message, user: @guest_user)
        @talk.messages << [@message1, @message2]

        get :show, params: { team_id: @team.id, id: @guest_user.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'return the right params' do
        response_hash = JSON.parse(response.body)

        expect(response_hash['user_one_id']).to eq(@current_user.id)
        expect(response_hash['user_two_id']).to eq(@guest_user.id)
        expect(response_hash['team_id']).to eq(@team.id)
      end

      it 'return the right numbers of messages' do
        response_hash = JSON.parse(response.body)
        expect(response_hash['messages'].count).to eq(2)
      end

      it 'return the right messages' do
        response_hash = JSON.parse(response.body)

        expect(response_hash['messages'][0]['body']).to eq(@message1.body)
        expect(response_hash['messages'][0]['user_id']).to eq(@current_user.id)
        expect(response_hash['messages'][1]['body']).to eq(@message2.body)
        expect(response_hash['messages'][1]['user_id']).to eq(@guest_user.id)
      end
    end

    context 'is not talk member' do
      before(:each) do
        @team = create(:team)
        @guest_user = create(:user)
        @team.users << @guest_user
        @talk = create(:talk, user_two: @guest_user, team: @team)

        get :show, params: { team_id: @team.id, id: @guest_user.id }
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
