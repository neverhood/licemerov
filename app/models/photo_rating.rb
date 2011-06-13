class PhotoRating < ActiveRecord::Base


  MALE_RATINGS = {
      :primary => [:face, :chest, :haircut, :eyes, :smile, :appearance, :ass, :musculature],
      :secondary => [:beard, :mustache, :accessories]
  }
  FEMALE_RATINGS = {
      :primary => [:face, :eyes, :smile, :appearance, :ass, :breasts, :legs, :haircut],
      :secondary => [:accessories, ]
  }




end
