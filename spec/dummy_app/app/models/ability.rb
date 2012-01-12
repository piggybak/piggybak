class Ability
  include CanCan::Ability
  def initialize(user)
    if user && user.roles.include?(Role.find_by_name("admin"))
      can :access, :rails_admin
      can [:read, :export, :history], [Category,
                    Image,
                    Page,
                    Role,
                    User,
                    ::Piggybak::Variant,
                    ::Piggybak::ShippingMethod,
                    ::Piggybak::PaymentMethod,
                    ::Piggybak::TaxMethod,
                    ::Piggybak::State,
                    ::Piggybak::Country,
                    ::Piggybak::Order]
    end
  end
end
