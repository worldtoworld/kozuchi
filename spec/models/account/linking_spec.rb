# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Account with Account::Linking" do
  fixtures :users, :friend_permissions, :friend_requests, :accounts
  set_fixture_class :accounts => 'Account::Base'

  before do
    @taro = users(:taro)
    @hanako = users(:hanako)
    @home = users(:home)
  end
  
  describe "set_link" do
    it "太郎の花子から花子の太郎へ双方向にリンクできる" do
      @taro_hanako = accounts(:taro_hanako)
      @hanako_taro = accounts(:hanako_taro)

      @taro_hanako.set_link(@hanako, @hanako_taro, true)
      @taro_hanako.link.should_not be_nil
      @taro_hanako.link.target_ex_account_id.should == :hanako_taro.to_id
      @taro_hanako.link.target_user_id.should == :hanako.to_id

      @hanako_taro.link.should_not be_nil
      @hanako_taro.link.target_ex_account_id.should == :taro_hanako.to_id
      @hanako_taro.link.target_user_id.should == :taro.to_id
    end
    describe "太郎のtestと家計のtestが双方向連携しているとき" do
      before do
        @taro_test = @taro.expenses.build(:name => 'test')
        @taro_test.save!
        @home_test = @home.incomes.build(:name => 'test')
        @home_test.save!
        @hanako_test = @hanako.expenses.build(:name => 'test')
        @hanako_test.save!
        @taro_test.set_link(@home, @home_test, true)
      end
      it "花子から双方向連携しようとしても、家計側からのリンクを変えられない" do
        lambda{@hanako_test.set_link(@home, @home_test, true)}.should raise_error(User::AccountLinking::AccountHasDifferentLinkError)
        @home_test.reload
        # リンクは変わっていない
        @home_test.link.target_account.should == @taro_test
        # link request は増えている
        @home_test.link_requests.find_by_sender_id_and_sender_ex_account_id(@hanako.id, @hanako_test.id).should_not be_nil
        # 花子からのリンクはできている
        @hanako_test.link.target_account.should == @home_test
      end
      it "太郎から再度双方向連携を指定してもうまくいく" do
        lambda{@taro_test.set_link(@home, @home_test, true)}.should_not raise_error
        @taro_test.reload
        @home_test.reload
        @taro_test.link.target_account.should == @home_test
        @home_test.link.target_account.should == @taro_test
      end
      it "太郎から別の勘定に双方向連携をはったらはりなおせて、太郎から家計への連携は削除されるが、家計から太郎へのリンクは削除されない" do
        @home_test2 = @home.incomes.build(:name => 'test2')
        @home_test2.save!
        lambda{@taro_test.set_link(@home, @home_test2, true)}.should_not raise_error
        @taro_test.reload
        @home_test.reload
        @home_test2.reload
        @taro_test.link.target_account.should == @home_test2
        @home_test2.link.target_account.should == @taro_test
        @home_test.link.target_account.should == @taro_test
        @taro_test.link_requests.find_by_sender_id_and_sender_ex_account_id(@home.id, @home_test.id).should_not be_nil
        @home_test.link_requests.find_by_sender_id_and_sender_ex_account_id(@taro.id, @taro_test.id).should be_nil
      end
    end
  end
end
