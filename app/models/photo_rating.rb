class PhotoRating < ActiveRecord::Base


  FEMALE_RATINGS = {
      :primary => [:haircut, :face, :breasts, :belly, :legs, :ass],
      :secondary => [:beard, :mustache, :accessories]
  }
  MALE_RATINGS = {
      :primary => [:haircut, :face, :chest, :abs, :spine, :ass],
      :secondary => [:accessories, ]
  }

end
