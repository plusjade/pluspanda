module Seed
  
  def seed_testimonials
    self.testimonials.create(
      :name         => "Stephanie Lo",
      :company      => "World United",
      :c_position   => "Founder",
      :url          => "worldunited.com",
      :location     => "Berkeley, CA",
      :body         => 5,
      :body         => "The interface is simple and directed. I have a super busy schedule and did not want to waste any time learning yet another website. Pluspanda values my time. Thanks!",
      :publish      => 1
    ) 

    self.testimonials.create(
      :name         => "John Doe",
      :company      => "Super Company!",
      :c_position   => "President",
      :url          => "supercompany.com",
      :location     => "Atlanta, Georgia",
      :body         => 5,
      :body         => "The interface is simple and directed. I have a super busy schedule and did not want to waste any time learning yet another website. Pluspanda values my time. Thanks!",
      :publish      => 1
    )
    
    self.testimonials.create(
      :name         => "Jane Smith",
      :company      => "Widgets R Us",
      :c_position   => "Sales Manager",
      :url          => "widgetsrus.com",
      :location     => "Los Angeles, CA",
      :body         => 5,
      :body         => "Pluspanda makes our testimonials look great! Our widget sales our up 200% Thanks Pluspanda!",
      :publish      => 1
    )

  end
  
  
end