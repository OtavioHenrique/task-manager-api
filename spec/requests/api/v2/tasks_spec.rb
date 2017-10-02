require 'rails_helper'

RSpec.describe 'Task API' do
  before { host! 'api.task-manager.dev:80/v1' }

  let!(:user) { create(:user) }
  let(:headers) do
    {
      'Content-type' => Mime[:json].to_s,
      'Accept' => 'application/json',
      'Authorization' => user.auth_token
    }
  end

  describe 'GET /tasks' do
    before do
      create_list(:task, 5, user_id: user.id)
      get '/tasks', params: {}, headers: headers
    end

    it 'expect to receive 200 status' do
      expect(response).to have_http_status(200)
    end

    it 'returns 5 tasks from database' do
      expect(json_body["tasks"].count).to eq(5)
    end
  end

  describe 'GET /tasks/:id' do
    let(:task) { create(:task, user_id: user.id) }

    before { get "/tasks/#{task.id}", params: {}, headers: headers }

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns the json for task' do
      expect(json_body['title']).to eq(task.title)
    end
  end

  describe 'POST /tasks' do
    before do
      post '/tasks', params: { task: task_params }.to_json, headers: headers
    end
    
    context 'correct params' do
      let(:task_params) { attributes_for(:task) }
      
      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'saves the task in the database' do
        expect( Task.find_by(title: task_params[:title])).to_not be_nil
      end

      it 'returns correct json' do
        expect(json_body['title']).to eq(task_params[:title])
      end

      it 'assigns the created task to the user' do
        expect(json_body['user_id']).to eq(user.id)
      end
    end

    context 'wrong params' do
      let(:task_params) { attributes_for(:task, title: '') }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'dont save on database' do
        expect( Task.find_by(title: task_params[:title])).to be_nil
      end

      it 'returns json error' do
        expect(json_body['errors']).to have_key('title')
      end
    end
  end

  describe 'PUT /task/:id' do
    let!(:task) { create(:task, user_id: user.id) }
    
    before do
      put "/tasks/#{task.id}", params: { task: task_params }.to_json, headers: headers
    end

    context 'valid params' do
      let(:task_params) { { title: 'New Title For Test' } }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the json with updated task' do
        expect(json_body['title']).to eq(task_params[:title])
      end

      it 'updates the task in the database' do
        expect( Task.find_by(title: task_params[:title]).title).to eq(task_params[:title])
      end
    end

    context 'wrong params' do
      let(:task_params) { { title: '' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns json with error' do
        expect(json_body['errors']).to have_key('title')
      end

      it 'does not update task in database' do
        expect( Task.find_by(title: task_params[:title])).to be_nil
      end
    end
  end

  describe 'DELETE /task/:id' do
    let!(:task) { create(:task, user_id: user.id) }

    before do
       delete "/tasks/#{task.id}", params: {}, headers: headers
    end

    it 'returns status 204' do
      expect(response).to have_http_status(204)
    end

    it 'removes task from database' do
      expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound) 
    end
  end
end
