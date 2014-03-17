class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :manage, User, id: user.id

    can :edit, Testimonial do |t|
      t.user_id == user.id || t.lock == false
    end
  end
end
