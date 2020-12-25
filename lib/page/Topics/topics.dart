//import 'package:flutter/material.dart';

class Topics{
  List<List<int>> isEnabled;

  Map topics = {
    "Arts & Culture" : {
      "Animation": [],
      "Arts": {},
      "Astrology": [],
      "Comics": {},
      "Horoscope": {},
      "Sci-Fi & Fantasy": [],
      "Writing": []
    },
    "Business & Finance":{
      "Business & Finance":[],
      "Business & Finance News": [],
      "Business Personalities":[],
      "Business Profession":[],
      "Crypyocurrencies":[],
      "FinTech":[],
      "Investing":[],
      "Nonprofits":[],
      "Small Business":[],
      "Startup":[],
      "Venture capital":[]
    },
    "Career":{
      "Accounting":[],
      "Advertising":[],
      "Education":[],
      "Field of Study":[],
      "Marketing":[],
      "Entertainment":[],
      "Celebrities":[],
    },
    "Entertainment":{
      "Entertainment":[],
      "Celebrities":[],
      "Comedy":[],
      "Digital Creators":[],
      "Entertainment Brands":[],
      "Popular Franchises":[],
      "Theater":[]
    },
    "Fashion & Beauty":{
      "Beauty":[],
      "Fashion":[],
    },
    "Food": {
      "Food":[],
      "Chef":[],
      "Cooking":[],
      "Cuisines":[],
      "Vegan":[]
    },
    "Gaming":{
      "Gaming":[],
      "Esports":[],
      "Game developeres & publishers":[],
      "Gaming News":[],
      "Gaming Personalities & esports players":[],
      "Tabeltop Gaming":[],
      "Video Game platforms & hardware":[],
      "Video Games":[],
    },
    "Hobbies & Interests":{
      "Animals":[],
      "Anime":[],
      "At Home":[],
      "Collectables":[],
      "Family":[],
      "Fitness":[],
      "Podcast":[],
      "Transportation":[],
      "Unexplained Phenomiania":{}
    }
  };

//  getLength() {
//    var k = topics.keys.length;
//    for (int i=0; i<k ; i++){
//      Map<String, Object> tt= topics.values.elementAt(i);
//      List<int> temp = [];
//      for(int j=0; j<tt.values.length; j++){
//        temp.add(0);
//      }
//      isEnabled.add(temp);
//    }
//  }

}