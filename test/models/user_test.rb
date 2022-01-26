require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: 'Test', email: 'test@gmail.com', password: 'foobar', password_confirmation: 'foobar')
  end

  test "should be valid" do 
    assert  @user.valid?
  end

  test "name should be present" do 
    @user.name = "      "
    assert_not  @user.valid?

  end

  test "email should be present" do 
    @user.email = "   "
    assert_not  @user.valid?
  end

  test "name should not be too long" do 
    @user.name = "a" * 51
    assert_not  @user.valid?
  end

  test "email should not be too long" do 
    @user.email = "a" * 256
    assert_not  @user.valid?
  end

  test "email should be valid form" do 
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
    first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email address should be unique" do 
    @user.save
    @dup_user = User.new(name: 'Test2', email:@user.email)
    assert_not  @dup_user.valid?
  end

  test "password should have a minimum length" do 
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
