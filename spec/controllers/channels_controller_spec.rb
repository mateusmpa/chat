require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'

    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = create(:user)
    sign_in @current_user
  end

  describe 'POST #create' do
    # Sem isto não renderiza as views
    render_views

    context 'user is team member' do
      before(:each) do
        @team = create(:team)
        @team.users << @current_user
        @channel_attributes = attributes_for(:channel, user: @current_user)
        post :create, params: { channel: @channel_attributes.merge(team_id: @team.id) }
      end

      it 'return http success' do
        expect(response).to have_http_status(:success)
      end

      it 'channel is created with right params' do
        expect(Channel.last.slug).to eq(@channel_attributes[:slug])
        expect(Channel.last.user).to eq(@current_user)
        expect(Channel.last.team).to eq(@team)
      end

      it 'return right values to channel' do
        response_hash = JSON.parse(response.body)

        expect(response_hash['slug']).to eq(@channel_attributes[:slug])
        expect(response_hash['user_id']).to eq(@current_user.id)
        expect(response_hash['team_id']).to eq(@team.id)
      end
    end

    context 'user is not team member' do
      before(:each) do
        @team = create(:team)
        @channel_attributes = attributes_for(:channel, team: @team)
        post :create, params: { channel: @channel_attributes.merge(team_id: @team.id) }
      end

      it 'return http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #show' do
    # Sem isto não renderiza as views
    render_views

    context 'user is team member' do
      before(:each) do
        team = create(:team)
        team.users << @current_user
        @channel = create(:channel, team: team)

        @message1 = build(:message)
        @message2 = build(:message)
        @channel.messages << [@message1, @message2]

        get :show, params: { id: @channel.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns right channel values' do
        response_hash = JSON.parse(response.body)

        expect(response_hash['messages'][0]['body']).to eq(@message1.body)
        expect(response_hash['messages'][0]['user_id']).to eq(@message1.user.id)
        expect(response_hash['messages'][1]['body']).to eq(@message2.body)
        expect(response_hash['messages'][1]['user_id']).to eq(@message2.user.id)
      end
    end

    context 'user is not team member' do
      it 'returns http forbidden' do
        channel = create(:channel)
        get :show, params: { id: channel.id }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'user is team member' do
      context 'user is the channel owner' do
        it 'returns http success' do
          team = create(:team)
          team.users << @current_user
          channel = create(:channel, team: team, user: @current_user)

          delete :destroy, params: { id: channel.id }

          expect(response).to have_http_status(:success)
        end
      end

      context 'user is the team owner' do
        it 'returns http success' do
          team = create(:team, user: @current_user)
          channel_owner = create(:user)
          channel = create(:channel, team: team, user: channel_owner)

          delete :destroy, params: { id: channel.id }

          expect(response).to have_http_status(:success)
        end
      end

      context 'user is not the team or channel owner' do
        it 'returns http forbidden' do
          team = create(:team)
          team.users << @current_user
          channel = create(:channel, team: team)

          delete :destroy, params: { id: channel.id }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'user is not team member' do
      it 'returns http forbidden' do
        channel = create(:channel)
        delete :destroy, params: { id: channel.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
