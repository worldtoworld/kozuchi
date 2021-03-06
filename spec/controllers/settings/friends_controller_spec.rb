# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../controller_spec_helper')

describe Settings::FriendsController do
  fixtures :users, :friend_requests, :friend_permissions

  before do
    login_as :taro
  end

  describe "index" do
    it "成功する" do
      get :index
      response.should be_success
    end
  end

end
