class PhotoRating < ActiveRecord::Base


  FEMALE_RATINGS = {
      :primary => [:haircut, :face, :breasts, :belly, :legs, :ass],
      :secondary => [:accessories]
  }
  MALE_RATINGS = {
      :primary => [:haircut, :face, :chest, :abs, :spine, :ass],
      :secondary => [:beard, :mustache, :accessories]
  }

end
