//
//  PopUpValues.swift
//  Haart App
//
//  Created by Stone on 12/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import PopupDialog
import FirebaseAuth
import FirebaseFirestore
import Alamofire


class InterestPopUpValues: AbstractControl, InterestsPopUpViewControllerDelegate, SearchPopUpViewControllerDelegate {
   // var userDocument:QueryDocumentSnapshot?
    var shouldUpdateTxtFieldsAndRangeFromServer = true
    let kIntrestedInKey = "intrestedIn"
    let kEyeColorsKey = "eyeColors"
    let kProfessionKey = "profession"
    let kReligionKey = "religion"
    let kEthnicityKey = "ethnicitys"
    let kBodyTypeKey = "bodyFigure"
    let kHairColorsKey = "hairColors"
    let kGenderKey = "gender"
    let kReleationshipKey = "relationships"
    let kCurrentReleationshipKey = "currentRelationship"
    let kStarSignKey = "starSign"
    let kEducationLevelKey = "educationLevel"
    let kIncomeKey = "income"
    let kKids = "kids"
    let kDietryPreferences = "dietryPreferences"
    let kAlchohal = "alchohal"
    let kHobbies =  "hobbies"
    let kMovies =  "movies"
    let kBooks =  "books"
    let kTvShows = "tvShows"
    let kCollege = "college"
    let kSmoking = "smoking"
    let kWorkout = "workout"
    var collegeData = [Universities?]()
    var collegeArray = [String]()
    var income = Array<String>()
    var popUp:PopupDialog!
    var viewController:InterestsPopUpViewController!
    var viewController2 : SearchPopUp!
    var professionVC:ProfessionsVC!
    var currentSelectedList:SelectedIntrestsCollectionViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUniversities()
        
    }
    
    func showInterestsPopUp(sender: UIButton, values:Array<String>,arrKey:String) {
        if(arrKey == "movies" || arrKey == "books" || arrKey == "tvShows" || arrKey == "fmovies" || arrKey == "fbooks" || arrKey == "ftvShows"){
            
            shouldUpdateTxtFieldsAndRangeFromServer = false

                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        viewController = mainStoryboard.instantiateViewController(withIdentifier: "InterestsPopUpViewController") as? InterestsPopUpViewController
            viewController.searchBit = true
    
                        viewController.currentSelectedList = currentSelectedList
                        viewController.delegate = self
                        viewController.userDocument = userDocument
                        popUp = PopupDialog.init(viewController: viewController, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                        viewController.initializeWith(items: values, sender: sender,arrKey:arrKey)
                        self.present(popUp, animated: true, completion: nil)
            
        }else{
        shouldUpdateTxtFieldsAndRangeFromServer = false
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = mainStoryboard.instantiateViewController(withIdentifier: "InterestsPopUpViewController") as? InterestsPopUpViewController
        viewController.currentSelectedList = currentSelectedList
        viewController.delegate = self
        viewController.userDocument = userDocument
        popUp = PopupDialog.init(viewController: viewController, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        viewController.initializeWith(items: values, sender: sender,arrKey:arrKey)
        self.present(popUp, animated: true, completion: nil)
    }
    }
    func didChangeValueForIntrests(){
        
    }
    
    func showProfessionInterestsPopUp(sender: UIButton, values:Array<String>,arrKey:String) {
        shouldUpdateTxtFieldsAndRangeFromServer = false
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        professionVC = mainStoryboard.instantiateViewController(withIdentifier: "ProfessionsVC") as? ProfessionsVC
        professionVC.currentSelectedList = currentSelectedList
        professionVC.userDocument = userDocument
        popUp = PopupDialog.init(viewController: professionVC, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 440, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        professionVC.initializeWith(items: values, sender: sender,arrKey:arrKey)
        self.present(popUp, animated: true, completion: nil)
    }
    
    var bioRelationship:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: relationship)
            return arr
            
        }
    }
    var filterRelationship:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: relationship)
            return arr
        }
    }
    let relationship = [
        "Short term relationship",
        "Long term relationship",
        "Start a family",
        "Looking for a friend",
        "Fling",
        "No talk / Just sex"
    ]
    
    var bioCurrentRelationship:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: currentRelationship)
            return arr
            
        }
    }
    var filterCurrentRelationship:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: currentRelationship)
            return arr
        }
    }

    
    let currentRelationship = [
        "Single & Ready",
        "In A Relationship",
        "Engaged",
        "Married",
        "Recently Broke Up",
        "Waiting For The Right Person",
        "Divorced With 1-2 kids",
        "Divorced With Multiple Kids",
        "Open Relationship",
        "Friends With Benefits",
        "Broken Hearted",
        "Confused",
        "Divorced",
        "Divorced With 1-2 kids",
        "Divorced With Multiple Kids",
        "Widowed",
        "Widowed With 1-2 kids",
       " Widowed With Multiple Kids"
        ]
    
    
    var bioEyeColors:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: eyeColors)
            arr.append("Others")
            return arr
            
        }
    }
    var filterEyeColors:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: eyeColors)
            return arr
        }
    }
    
    let eyeColors = [ 
        "Brown Eyes",
        "Gray Eyes",
        "Green Eyes",
        "Hazel Eyes",
        "Blue Eyes",
        "Amber Eyes",
        "Heterochromia Eyes"]
    
    
    var bioDietryPreferences:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: dietryPreferences)
            arr.append("Others")
            return arr
        }
    }
    var filterDietryPreferences:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: dietryPreferences)
            return arr
        }
    }
    
    let dietryPreferences = ["Standard",
                             "Pescatarian",
                             "Vegetarian",
                             "Lacto-vegetarian",
                             "Ovo-vegetarian",
                             "Vegan",
                             "Buddhist Diet",
                             "Hindu/Jainism",
                             "Halal",
                             "Kosher",
                             "Intermittent Fasting",
                             "Pollotarian",
                             "Pollo-pescetarian",
                             "Keto diet",
                             "Paleo diet"]
    
    var bioHairColors:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: hairColors)
            arr.append("Others")
            return arr
        }
        
    }
    var filterHairColors:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: hairColors)
            return arr
        }
    }
    
    
    let hairColors = [
        "Bald",
        "Blond",
        "Black",
        "Light Brunette",
        "Dark Brunette",
        "Gray",
        "Auburn",
        "Red Heads/Hair"]
    
    
    var bioHairStyles:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: hairStyles)
            arr.append("Others")
            return arr
        }
    }
    var filterHairStyles:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: hairStyles)
            return arr
        }
        
    }
    
    
    let hairStyles = [
        "Afro",
        "Afro Fade",
        "Asymmetrical Lob",
        "Bangs",
        "Blunt Cut",
        "Braids",
        "Buzz Cut",
        "Comb Over",
        "Crew Cut",
        "Deep Side Part",
        "Fade and Taper",
        "Fishtail Braids",
        "French Braids",
        "Fringe",
        "Lob",
        "Long Curly Hair",
        "Long Think Hair",
        "Low Bun",
        "Man Bun",
        "Pixie Cut",
        "Pompadour Fade",
        "Quiff",
        "Short Curly Hair",
        "Short Thick Hair",
        "Short Thin Hair",
        "Short Wavy Bob",
        "Short and Straight",
        "Side Part",
        "Slicked Back",
        "Spiky",
        "Straight Long Hair",
        "Top Knot",
        "Twists",
        "Undercut",
        "Vintage Curls",
        "Waterfall Braids"]
    
    var bioBodyFigure:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: bodyFigure)
            arr.append("Others")
            return arr
        }
        
    }
    
     func fetchColleges(completion: @escaping ([Universities?], Error?)->()){
             let url = "https://parseapi.back4app.com/classes/Usuniversitieslist_University"
       let data : Parameters = [
                  "limit" : "1000"
              ]
        let header :  HTTPHeaders  = [ "X-Parse-Application-Id" : "THaI31we1B4FuU5pFjAlCRHiFUYLAymksdIXkmCq",
                              "X-Parse-REST-API-Key" : "v3hMWA2YlEVlUiD1Sf3W34QHKiL58sQDnNGbCxe0"
         ]
        AF.request(url, method: .get , parameters: data, headers: header).responseJSON{(response) in
           print(response)
                      do{   let decoder = JSONDecoder()
                       let data = try decoder.decode(Universities.self, from: response.data!)
                       self.collegeData.insert(data, at: 0)
                       completion(self.collegeData,nil)
                       }
                       catch{
                           completion([nil], error)
                           print ("ERROR to decode \(error)")
                       }
                                
                 }
                     
             
         }
    func setUniversities(){
      collegeArray.removeAll()
            fetchColleges{(testResponse,err) in
                                  if let err = err {
                                               print("Failed to fetch tests:", err)
                                               return
                                           }
                      self.collegeData.insert(contentsOf: testResponse, at: 0)
                if((self.collegeData[0]?.results.count)! > 0){
                          for i in 0...(self.collegeData[0]?.results.count)! - 1 {
                              self.collegeArray.append((self.collegeData[0]?.results[i].name)!)
                     }
                     }
                  
                     print(self.collegeArray)
                     }
    }
    
    
    var filterBodyFigure:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: bodyFigure)
            return arr
        }
        
    }
   
    
    let bodyFigure = [
        "Petite",
        "Slim",
        "Fit / Average",
        "Athletic",
        "Big / Muscular",
        "Curvy",
        "Chubby",
        "Big & Beautiful"]
    
    var bioSkinTone:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: skinTone)
            arr.append("Others")
            return arr
        }
        
    }
    var filterSkinTone:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: skinTone)
            return arr
        }
        
    }
    
    let skinTone = [
        "Pale White",
        "Fair Skin",
        "Slightly Fair",
        "Olive/Tan",
        "Brown",
        "Dark brown",
        "Black"]
    
    var bioLanguages:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: languages)
            arr.append("Others")
            return arr
        }
        
    }
    var filterLanguages:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: languages)
            return arr
        }
        
    }
    
    let languages = [
        "English",
        "Hindi",
        "Urdu",
        "Arabic",
        "Chinese",
        "French",
        "Spanish",
        "Afrikaans",
        "Albanian",
        "Amharic",
        "Aramaic",
        "Armenian",
        "Assamese",
        "Aymara",
        "Azerbaijani",
        "Balochi",
        "Bamanankan",
        "Bashkort",
        "Basque",
        "Belarusan",
        "Bengali",
        "Bhojpuri",
        "Bislama",
        "Bosnian",
        "Brahui",
        "Bulgarian",
        "Burmese",
        "Cantonese",
        "Catalan",
        "Cebuano",
        "Chechen",
        "Cherokee",
        "Croatian",
        "Czech",
        "Dakota",
        "Danish",
        "Dari",
        "Dholuo",
        "Dutch",
        "Esperanto",
        "Estonian",
        "Éwé",
        "Finnish",
        "Georgian",
        "German",
        "Gikuyu",
        "Greek",
        "Guarani",
        "Gujarati",
        "Haitian Creole",
        "Hausa",
        "Hawaiian",
        "Hawaiian Creole",
        "Hebrew",
        "Hiligaynon",
        "Hungarian",
        "Icelandic",
        "Igbo",
        "Ilocano",
        "Indonesian",
        "Inuit/Inupiaq",
        "Irish Gaelic",
        "Italian",
        "Japanese",
        "Jarai",
        "Javanese",
        "K’iche’",
        "Kabyle",
        "Kannada",
        "Kashmiri",
        "Kazakh",
        "Khmer",
        "Khoekhoe",
        "Korean",
        "Kurdish",
        "Kyrgyz",
        "Lao",
        "Latin",
        "Latvian",
        "Lingala",
        "Lithuanian",
        "Macedonian",
        "Maithili",
        "Malagasy",
        "Malay",
        "Malayalam",
        "Mandarin",
        "Marathi",
        "Mende",
        "Mongolian",
        "Nahuatl",
        "Navajo",
        "Nepali",
        "Norwegian",
        "Ojibwa",
        "Oriya",
        "Oromo",
        "Pashto",
        "Persian",
        "Polish",
        "Portuguese",
        "Punjabi",
        "Quechua",
        "Romani",
        "Romanian",
        "Russian",
        "Rwanda",
        "Samoan",
        "Sanskrit",
        "Serbian",
        "Shona",
        "Sindhi",
        "Sinhala",
        "Slovak",
        "Slovene",
        "Somali",
        "Swahili",
        "Swedish",
        "Tachelhit",
        "Tagalog",
        "Tajiki",
        "Tamil",
        "Tatar",
        "Telugu",
        "Thai",
        "Tibetic languages",
        "Tigrigna",
        "Tok Pisin",
        "Turkish",
        "Turkmen",
        "Ukrainian",
        "Uyghur",
        "Uzbek",
        "Vietnamese",
        "Warlpiri",
        "Welsh",
        "Wolof",
        "Xhosa",
        "Yakut",
        "Yiddish",
        "Yoruba",
        "Yucatec",
        "Zapotec",
        "Zulu"]
    
    
    var bioGender:[String]{
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: gender)
            arr.append("Others")
            return arr
        }
        
    }
    var filterGender:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: gender)
            return arr
        }
        
    }
    
    let gender = [
        "Male",
        "Female",
        "Trans Male",
        "Trans Female",
        "Bisexual Male",
        "Bisexual Female",
        "Gay",
        "Lesbian"]
    
    
    var bioReligion:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: religion)
            arr.append("Others")
            return arr
        }
        
    }
    var filterReligion:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: religion)
            return arr
        }
        
    }
    
    
    let religion = [
        "Christianity",
        "Catholicism",
        "Anglicanism",
        "Hindu",
        "Shaivism",
        "Vaishnavism",
        "Jainism",
        "Sikhism",
        "Islam",
        "Shi'a Islam",
        "Sunni Islam",
        "Judaism/Jewish",
        "Conservative Judaism",
        "Orthodox Judaism",
        "Buddhism",
        "Theravada Buddhism",
        "Mahayana Buddhism",
        "Atheist",
        "Ahmadiyya",
        "Aladura",
        "Amish",
        "Anglicanism",
        "Asatru",
        "Assemblies of God",
        "Baha'i Faith",
        "Baptists",
        "Bon",
        "Candomble",
        "Cao Dai",
        "Cathari",
        "Charismatic movement",
        "Chinese Religion",
        "Christadelphians",
        "Christian Science",
        "Church of God",
        "Church of God in Christ",
        "Church of Satan",
        "Confucianism",
        "Deism",
        "Donatism",
        "Dragon Rouge",
        "Druze",
        "Eastern Orthodox Church",
        "Eckankar",
        "ELCA",
        "Epicureanism",
        "Evangelicalism",
        "Falun Gong",
        "Foursquare Church",
        "Gnosticism",
        "Greek Religion",
        "Hasidism",
        "Hellenic Reconstructionism",
        "Illuminati",
        "Intelligent Design",
        "Jehovah's Witnesses",
        "Kabbalah",
        "Kemetic Reconstructionism",
        "Lutheranism",
        "Mayan Religion",
        "Methodism",
        "Mithraism",
        "Mormonism",
        "Neopaganism",
        "New Age",
        "New Thought",
        "Nichiren",
        "Norse Religion",
        "Olmec Religion",
        "Oneness Pentecostalism",
        "Pentecostalism",
        "Presbyterianism",
        "Priory of Sion",
        "Protestantism",
        "Pure Land Buddhism",
        "Quakers",
        "Rastafarianism",
        "Reform Judaism",
        "Rinzai Zen Buddhism",
        "Roman Religion",
        "Satanism",
        "Scientology",
        "Seventh-Day Adventism",
        "Shinto",
        "Soto Zen Buddhism",
        "Spiritualism",
        "Stoicism",
        "Sufism",
        "Taoism",
        "Tendai Buddhism",
        "Tibetan Buddhism",
        "Typhonian Order",
        "Umbanda",
        "Unification Church",
        "Unitarian Universalism",
        "Vajrayana Buddhism",
        "Vedanta",
        "Vineyard Churches",
        "Voodoo",
        "Westboro Baptist Church",
        "Wicca",
        "Worldwide Church of God",
        "Yezidi",
        "Zen",
        "Zionism",
        "Zoroastrianism"]
    
    
    var bioEthnicitys:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: ethnicitys)
            arr.append("Others")
            return arr
        }
    }
    
    
    var filterEthnicitys:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: ethnicitys)
            return arr
        }
        
    }
    
    
    let ethnicitys = [
        "White/Caucasian",
        "African Americans",
        "Hispanic/Latin",
        "Native American",
        "British",
        "Indian",
        "Pakistani",
        "Asian",
        "Black",
        "American",
        "Arab",
        "Armenian",
        "Asian",
        "Canadian",
        "Chinese",
        "Cubans",
        "Dutch",
        "Europeans",
        "French",
        "German",
        "Hispanic",
        "Irish",
        "Italian",
        "Japanese",
        "Jewish",
        "Korean",
        "Latino",
        "Mexican",
        "Pacific Islander",
        "Polish",
        "Puerto Rican",
        "Romani",
        "Russian",
        "Scottish",
        "Spanish" ]
    
    
    var bioStarSign:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: starSign)
            return arr
        }
        
    }
    var filterStarSign:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: starSign)
            return arr
        }
        
    }
    
    
    let starSign = [
        "Aries",
        "Cancer",
        "Libra",
        "Capricorn",
        "Taurus",
        "Leo",
        "Scorpio",
        "Pisces",
        "Gemini",
        "Virgo",
        "Sagittarius",
        "Aquarius"]
    
    
    var bioKids:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: kids)
            arr.append("Others")
            return arr
        }
        
    }
    var filterKids:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: kids)
            return arr
        }
    }
    
    
    let kids = [
        "Yes",
        "No",
        "1 kid",
        "2 kids",
        "3 kids",
        "4 kids",
        "5+ kids"]
    
    var bioWorkout:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: workout)
            arr.append("Others")
            return arr
        }
    }
    var filterWorkout:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: workout)
            return arr
        }
    }
    
    
    let workout = [
        "EveryDay",
        "Every Other Day",
        "Weekdays Only",
        "Weekends Only",
        "Once A Week"]
    
    
    var bioSmoking:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: smoking)
            arr.append("Others")
            return arr
            
        }
    }
    var filterSmoking:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: smoking)
            return arr
        }
    }
    
    
    let smoking = [
        "Never",
        "Rarely",
        "Occasionally",
        "Often"]
    
    
    var bioAlchohal:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: alchohal)
            arr.append("Others")
            return arr
        }
    }
    
    var bioHobbies:[String] {
          
          get {
              var arr = Array<String>()
              arr.append(contentsOf: hobbies)
              arr.append("Others")
              return arr
          }
      }
    var filterHobbies:[String] {
            
            get {
                var arr = Array<String>()
                arr.append(contentsOf: hobbies)
                arr.append("Others")
                return arr
            }
        }
    var bioMovies:[String] {
            
            get {
                var arr = Array<String>()
                arr.append(contentsOf: movies)
                arr.append("Others")
                return arr
            }
        }
    var filterMovies:[String] {
              get {
                  var arr = Array<String>()
                  arr.append(contentsOf: movies)
                  arr.append("Others")
                  return arr
              }
          }
    
    var bioBooks:[String] {
            
            get {
                var arr = Array<String>()
                arr.append(contentsOf: books)
                arr.append("Others")
                return arr
            }
        }
    
    var filterBooks:[String] {
              
              get {
                  var arr = Array<String>()
                  arr.append(contentsOf: books)
                  arr.append("Others")
                  return arr
              }
          }
    var bioTvShows:[String] {
              
              get {
                  var arr = Array<String>()
                  arr.append(contentsOf: tvShows)
                  arr.append("Others")
                  return arr
              }
          }
    
    var filterTvShows:[String] {
               
               get {
                   var arr = Array<String>()
                   arr.append(contentsOf: tvShows)
                   arr.append("Others")
                   return arr
               }
           }
    var bioCollege:[String] {
                    
                    get {
                        var arr = Array<String>()
                        arr.append(contentsOf: collegeArray)
                        arr.append("Others")
                        return arr
                    }
                }
    var filterCollege:[String] {
                    
                    get {
                        var arr = Array<String>()
                        arr.append(contentsOf: collegeArray)
                        arr.append("Others")
                        return arr
                    }
                }
    

    var filterAlchohal:[String] {
        
        get {
            var arr = Array<String>()
            arr.append("All")
            arr.append(contentsOf: alchohal)
            return arr
        }
    }
    
    
    let alchohal = [
        "Never",
        "Rarely",
        "Occasionally",
        "Often"]
    var movies = [String]()
    
   var books = [String]()
    
    var tvShows = [String]()
    
    let hobbies = [
          "3D printing","Acting","Adventure racing","Aerobatics","Aero Modeling","Aggressive inline skating","Aid climbing","Air hockey","Air racing","Air sports","Airbrushing","Airsoft","Alpine skiing","Amateur Astronomy","Amateur Radio","Amateur astronomy","Amateur geology","Amateur radio","Amateur wrestling","American flag rugby","American football","American handball","American Snooker","Ancient games","Angling","Animal Fancy","Animals/pets/dogs","Antiquing","Antiquities","Aquarium","Aquathlon","Archery","Arena football","Arm wrestling","Art collecting","Artistic billiards","Artistic cycling","Artistic gymnastics","Artistic pool","Artistic roller skating","Arts","Association football","Astrology","Astronomy","Atlatl","Australian football","Australian handball","Australian rules football","Auto Race","Auto racing","Autocross","Autograss","Aviation","Axe throwing","BASE jumping","BMX","Ba game","Backgammon","Backpacking","Backstroke","Badminton","Balkline and straight rail","Ball","Ball badminton","Ball hockey","Bando","Bandy","Banger racing","Bank pool","Banzai skydiving","Bar billiards","Barrel racing","Bartitsu","Base Jumping","Baseball","Baseball pocket billiards","Basketball","Basque pelota","Bat-and-ball games","Baton Twirling","Battle gaming","Beach Volleyball","Beach handball","Beach rugby","Beach soccer","Beach volleyball","Beach/Sun tanning","Beadwork","Beatboxing","Beekeeping","Beer Pong","Bell Ringing","Belly Dancing","Biathlon","Bicycle Polo","Bicycling","Big-game fishing","Bird watching","Birding","Birdwatching","Blackball","Blacksmithing","Blogging","Board games","Board sports","Board track racing","BoardGames","Boardercross","Boating","Boccia","Body Building","Book collecting","Book restoration","Bookbinding","Boomerangs","Bottle pool","Bouldering","Boules","Bowling","Bowls","Box lacrosse","Boxing","Brazilian Jiu-Jitsu","Breakdancing","Breaststroke","Brewing Beer","Bridge Building","Bringing Food To The Disabled","British Bulldogs","British baseball","Building Dollhouses","Bumper pool","Bungee jumping","Butterfly Watching","Button Collecting","Butts Up","Buzkashi","Cabaret","Caid","Cake Decorating","Calligraphy","Calva","Calvinball","Camping","Canadian football","Candle Making","Canoe polo","Canoeing","Canyoning","Capoeira","Capture the flag","Car Racing","Card collecting","Carom billiards","Cartooning","Casino Gambling","Casting","Cave Diving","Ceramics","Chariot racing","Checkers","Cheerleading","Chess","Chess boxing","Chess960","Chester-le-Street","Chicago","Chilean rodeo","Chinese checkers","Chinese handball","Chinese martial arts","Choi Kwang-Do","Church/church activities","Cigar Smoking","Cirit","Clay pigeon shooting","Climbing","Cloud Watching","Cluster ballooning","Coastal and ocean rowing","Coasteering","Coin Collecting","Collecting","Collecting Antiques","Collecting Artwork","Collecting Hats","Collecting Music Albums","Collecting RPM Records","Collecting Sports Cards","Collecting Swords","Color guard","Colouring","Combat robot","Comic book collecting","Compose Music","Composite rules shinty-hurling","Computer activities","Computer programming","Cooking","Cornish hurling","Cosplay","Cosplaying","Couponing","Cowboy","Cowboy polo","Crafts","Creative writing","Cribbage","Cricket","Crochet","Crocheting","Croquet","Cross country running","Cross-Stitch","Cross-country equestrianism","Cross-country mountain biking","Cross-country rally","Cross-country running","Cross-country skiing","Crossword Puzzles","Crossword puzzles","Cryptography","Cue sports","Curling","Cushion caroms","Cutthroat","Cutting","Cycle polo","Cycle speedway","Cycling","Czech handball","Daitō-ryū Aiki-jūjutsu","Dance","Dancing","Danish longball","Darts","Debate","Decathlon","Deep-water soloing","Deer hunting","Deltiology","Desert racing","Dice stacking","Die-cast toy","Digital Photography","Digital art","Dinghy sailing","Diplomacy","Dirt jumping","Dirt track racing","Disc dog","Disc golf","Discus throw","Diving","Do it yourself","Dodge disc","Dodgeball","Dog sport","Dolls","Dominoes","Double disc court","Downhill mountain biking","Dowsing","Drag boat racing","Drag racing","Dragon boat","Drama","Draughts","Drawing","Dressage","Drifting","Driving","Drum and bugle corps","Duathlon","Dumpster Diving","Eating out","Educational Courses","Egg and spoon race","Egyptian stick fencing","Eight-ball","Eight-man football","Electronics","Element collecting","Elephant polo","Embroidery","Endurance","Endurance racing","Endurance riding","Enduro","English billiards","English pleasure","Entertaining","Equestrian vaulting","Equestrianism","Equitatio","Eton College","Eton Fives","Eton field game","Eton wall game","Eventing","Exercise","Exhibition drill","Extreme ironing","F1 Powerboat World Championship","Falconry","Fashion","Fast cars","Fast-pitch softball","Fastnet","Felting","Fencing","Field archery","Field handball","Field hockey","Fire Poi","Fire baton twirling","Fishing","Fistball","Five-a-side football","Five-pins","Fives","Flag Football","Flag football","Flight archery","Floor","Floorball","Floral Arrangements","Flower arranging","Flutterguts","Fly Tying","Fly fishing","Flying disc","Flying disc freestyle","Flying disc games","Flying trapeze","Folk wrestling","Folkrace","Football","Football tennis","Footvolley","Foraging","Formula Libre","Formula Student","Formula racing","Fossil hunting","Four Wheeling","Four square","Four-ball billiards","Fox hunting","Free running","Freeboard","Freediving","Freestyle BMX","Freestyle Motocross","Freestyle football","Freestyle scootering","Freestyle skiing","Freestyle slalom skating","Freestyle snowboarding","Freestyle swimming","Freestyle wrestling","Freshwater Aquariums","Cricket","Futsal","Ga-ga","Gaelic football","Gaelic handball","Gambling","Games","Gardening","Gateball","Gatka","Genealogy","Geo caching","Geocaching","Ghost Hunting","Ghost hunting","Gig racing","Glassblowing","Gliding","Glima","Go","Go Kart Racing","Go-Moku","Goalball","Going to movies","Golf","Graffiti","Grand Prix motorcycle racing","Greco-Roman wrestling","Greek wrestling","Gridiron football","Grip Strength","Guitar","Gun Collecting","Gungdo","Gunsmithing","Guts","Gymkhana","Gymnastics","Gyotaku","Haggis hurling","Hala","Half marathon","Hammer throw","Hana Ichi Monme","Handball","Handwriting Analysis","Hang gliding","Hapkido","Hapsagai","Hardcourt Bike Polo","Hare coursing","Harness racing","Harpastum","Harrow football","Haxey Hood","Headis","Heptathlon","Herping","Hide and seek","High jump","High power rifle","Highland games","Hiking","Hillclimbing","Historic motorsport","Hockey","Home roasting coffee","Homebrewing","Hoop","Hooping","Hooverball","Hopper balloon","Horizontal bar","Hornussen","Horse polo","Horse racing","Horse riding","Horseback riding","Horseball","Horseshoe","Horseshoes","Hot Air Balloon Racing","Hot air ballooning","Hot box","House of cards","Hula Hooping","Human powered aircraft","Human swimming","Hunter","Hunter-jumpers","Hunting","Hurdles","Hurling","Hwa Rang Do","Hybrid carom–pocket games","Hybrid codes","Hydroplane racing","ITHF table hockey","Iaidō","Iaijutsu","Ice climbing","Ice dancing","Ice fishing","Ice hockey","Ice racing","Ice skating","Ice sledge hockey","Ice speedway","Ice yachting","Iceskating","Illusion","Impersonations","Indoor American football","Indoor archery","Indoor cricket","Indoor enduro","Indoor field hockey","Indoor netball","Indoor percussion ensemble","Indoor soccer","Inline hockey","Inline skating","Inline speed skating","Insect collecting","International fronton","International rules football","Jacquet","Javelin throw","Jeet Kune Do","Jet Engines","Jet sprint boat racing","Jeu de paume","Jeu provençal","Jewelry Making","Jigsaw Puzzles","Jogging","Jogo do pau","Jorkyball","Jousting","Judo","Jugger","Juggling","Juggling club","Jujutsu","Jump Roping","Jump rope","Jumping","Jōdō","Jūkendō","Kabaddi","Kajukenbo","Kalarippayattu","Karate","Kart racing","Kayaking","Keep A Journal","Keep away","Keepie uppie","Kelly pool","Kemari","Kendo","Kenjutsu","Kenpō","Kho kho","Ki-o-rahi","Kick the can","Kickball","Kickboxing","Kilikiti","Killer","Kin-Ball","Kinomichi","Kitchen Chemistry","Kite","Kite Boarding","Kite buggy","Kite fighting","Kite flying","Kite landboarding","Kites","Kitesurfing","Knapping","Knattleikr","Kneeboarding","Knife making","Knife throwing","Knitting","Knotting","Kombucha","Korfball","Krabi-krabong","Krav Maga","Kronum","Kubb","Kuk Sool Won","Kumdo","Kurash","Kyūdō","Kyūjutsu","LARPing","La soule","Lace","Lacrosse","Ladies' Gaelic football","Lancashire wrestling","Land sailing","Land speed records","Land windsurfing","Lapidary club","Lapta","Laser tag","Lasers","Lawn Darts","Learn to Play Poker","Learning","Learning A Foreign Language","Learning An Instrument","Leather crafting","Letterboxing","Limited overs cricket","List of types of games","Listening to music","Locksport","Logrolling","Long jump","Longboarding","Losing chess","Luge","Lumberjack","MCMAP","Machining","Macrame","Macramé","Magic","Mahjong","Making Model Cars","Malla-yuddha","Mancala","Marathon","Marbles","Marching band","Marksmanship","Marn Grook","Martial Arts","Martial arts","Masters Football","Masters Rugby League","Matball","Match play","Matchstick Modeling","Medieval football","Meditation","Medley swimming","Megaminx","Mesoamerican ballgame","Metal Detecting","Metal detecting","Metal detector","Metallic silhouette","Metallic silhouette shooting","Metalworking","Meteorology","Metro footy","Microscopy","Midget car racing","Mineral collecting","Mini footy","Mini rugby","Miniature golf","Mixed climbing","Mixed martial arts","Mob football","Mod league","Model Railroading","Model Rockets","Model aircraft","Model building","Model yachting","Modeling Ships","Modern pentathlon","Mongolian wrestling","Monster truck","Motocross","Motor sports","Motorcycle drag racing","Motorcycle speedway","Motorcycles","Mountain Biking","Mountain Climbing","Mountain biking","Mountain unicycling","Mountainboarding","Mountaineering","Movies","Mud bogging","Mushroom hunting","Music","Nail Art","Netball","Newcomb ball","Nguni stick-fighting","Nine-a-side footy","Nine-ball","Nine-man football","Ninjutsu","Noodling","Nordic combined","Nordic skating","Nordic skiing","Object spinning","Obstacle variations","Off-road racing","Off-roading","Offshore powerboat racing","Old cat","Olympic weightlifting","One Day International","One-pocket","Orienteering","Origami","Other","Outrigger canoeing","Over-the-line","Paintball","Painting","Palant","Pall mall","Palla","Pankration","Papi fut","Parachuting","Paragliding","Paragliding or Power Paragliding","Parallel bars","Paralympic association football","Paralympic volleyball","Paramotoring","Parasailing","Parkour","Pato","Pehlwani","Pencak Silat","Pentathlon","People Watching","People watching","Personal water craft","Pesäpallo","Pet","Peteca","Photography","Piano","Pickup truck racing","Pigeon racing","Pinochle","Pipe Smoking","Pitch and putt","Planking","Plate spinning","Platform tennis","Playing music","Playing team sports","Pocket Cube","Pocket billiards","Poi","Poker","Pole Dancing","Pole climbing","Pole vault","Polo","Polocrosse","Pommel horse","Pond hockey","Popinjay","Potentially other sports are listed here.","Pottery","Power hockey","Powered hang glider","Powered paragliding","Powerlifting","Pressed flower craft","Production car racing","Professional wrestling","Protesting","Punchball","Puppetry","Puzzle","Pyrotechnics","Pétanque","Quidditch","Quilting","Quizzing","R/C Boats","R/C Cars","R/C Helicopters","R/C Planes","Racing Pigeons","Racquetball","Radio control","Radio-controlled aerobatics","Radio-controlled car","Rafting","Railfans","Rally raid","Rallycross","Rallying","Rappelling","Rapping","Reading","Reading To The Elderly","Record collecting","Red rover","Reduced variants","Regularity rally","Reining","Relaxing","Renaissance Faire","Renting movies","Requiring little or no physical exertion or agility mind sports are often not considered true sports. Some mind sports are recognised by sporting federations.","Rescuing Abused Or Abandoned Animals","Reversi","Rhythmic gymnastics","Ribbon","Ringball","Ringette","Ringo","Rings","Rink bandy","Rink hockey","Rinkball","Risk","Riverboarding","Road bicycle racing","Road racing","Road running","Robot combat","Robotics","Rock Balancing","Rock Collecting","Rock balancing","Rock climbing","Rock fishing","Rockets","Rocking AIDS Babies","Rodeo","Roleplaying","Roller derby","Roller hockey","Roller skating","Rope","Rope climbing","Rossall Hockey","Rotation","Rounders","Rowing","Royal Shrovetide Football","Rubik's Clock","Rubik's Cube","Rubik's Cube One Handed","Rubik's Cube blindfolded","Rubik's Cube with Feet","Rubik's Revenge","Rugby Fives","Rugby football","Rugby league","Rugby league nines","Rugby league sevens","Rugby sevens","Rugby tens","Rugby union","Rundown","Running","Russian pyramid","Sack race","Sailing","Saltwater Aquariums","Sambo","Samoa rules","San shou","Sand Castles","Sand art and play","Savate","Schwingen","Scouting","Scrabble","Scrapbooking","Scrub baseball","Scuba Diving","Scuba diving","Sculling","Sculpting","Sea glass","Sea kayaking","Seashell","Second-language acquisition","Segway polo","Self Defense","Sepak takraw","Seven-ball","Sewing","Shaolin kung fu","Shark Fishing","Shidōkan Karate","Shinty","Shogi","Shooting","Shooting sport","Shooting sports","Shopping","Shorinji Kempo","Short track motor racing","Short track speed skating","Shortwave listening","Shot put","Shotgun start","Show jumping","Shuffleboard","Silat","Singing","Singing In Choir","Single scull","Sinuca brasileira","Sipa","Six-man football","Six-red snooker","Skateboarding","Skater hockey","Skeet Shooting","Skeet shooting","Skeleton","Sketch","Sketching","Ski jumping","Ski touring","Ski boarding","Skiing","Sky Diving","Skydiving","Skysurfing","Slack Lining","Slamball","Sleeping","Slingshots","Slot Car Racing","Slot car racing","Snail racing","Snooker","Snooker plus","Snorkeling","Snorkelling","Snow kiting","Snow rugby","Snowboarding","Snowkiting","Snowmobile","Snowshoeing","Soap Making","Soap shoes","Soapmaking","Soccer","Softball","Sogo","Spearfishing","Speed Cubing","Speed golf","Speed pool","Speed skating","Speed skiing","Speedball","Spending time with family/kids","Sport climbing","Sport diving","Sport fishing","Sport kite","Sport stacking","Sporting clays","Sports acrobatics","Sports aerobics","Sports car racing","Sprint","Sprint car racing","Sprint football","Square","Squash","Squash tennis","Stamp Collecting","Stamp collecting","Stand up paddle boarding","Stand-up comedy","Static trapeze","Steeplechase","Stock car racing","Stone collecting","Stone skipping","Stool ball","Storm Chasing","Storytelling","Straight pool","Stratego","Street football","Street hockey","Street racing","Streetball","Streetluge","Strength athletics","String Figures","Stroke play","Strongman","Sudoku","Suicide","Sumo","Super sport","Superbike racing","Supercross","Supermoto","Superside","Surf Fishing","Surf fishing","Surf kayaking","Surfboat","Surfing","Survival","Swamp football","Swimming","Sword fighting","Systema","Sōjutsu","TV watching","Table football","Table tennis","Taekwondo","Tag","Tag rugby","Tai chi","Tang Soo Do","Target archery","Target shooting","Tatting","Tea Tasting","Team penning","Team play","Team sport","Tee-ball","Telemark skiing","Ten-ball","","","Tennis","Tennis polo","Tent pegging","Tesla Coils","Test cricket","Tetherball","Tetris","Textiles","Texting","Three sided football","Three-ball","Three-cushion","Three-legged race","Throwball","Throwing","Thumb wrestling","Time attack","Toboggan","Toe wrestling","Tombstone Rubbing","Tool Collecting","Topiary","Torball","Toss juggling","Touch football","Touch rugby","Tour skating","Touring car racing","Tower running","Town ball","Toy Collecting","Track cycling","Track racing","Tractor pulling","Traditional climbing","Train Collecting","Train Spotting","Trainspotting","Trampolining","Trap shooting","Trapeze","Traveling","Treasure Hunting","Trekkie","Trial","Triathlon","Trick shot","Triple jump","Trophy hunting","Truck racing","Tug-o-war","Tumbling","Tutoring Children","Twenty20","Ultimate","Ultimate Disc ","Ultimate Frisbee","Ultralight aviation","Ultramarathon","Underwater cycling","Underwater football","Underwater hockey","Underwater ice hockey","Underwater orienteering","Underwater photography","Underwater rugby","Underwater target shooting","Uneven bars","Unicycle basketball","Unicycle hockey","Unicycle trials","Urban Exploration","Urban exploration","Vault","Vehicle restoration","Video Games","Video game","Video game collecting","Video gaming","Videophile","Vigoro","Vintage cars","Violin","Volata","Volleyball","Volunteer","Wakeboarding","Wakesurfing","Walking","Warhammer","Watching sporting events","Water basketball","Water polo","Water sports","Water volleyball","Weather Watcher","Web surfing","Weight training","Weightlifting","Western pleasure","Whale Watching","Wheelchair basketball","Wheelchair racing","Wheelchair rugby league","Wheelstand competition","Whitewater kayaking","Whittling","Windsurfing","Wine Making","Wing Chun","Wolf hunting","Women's lacrosse","Wood carving","Wood chopping","Wood splitting","Woodball","Woodsman","Woodworking","Working In A Food Pantry","Working on cars","World Record Breaking","Wrestling","Writing","Writing Music","Writing Songs","Wushu","Xiangqi","Yak polo","Yağlı Güreş","Yo-yoing","Yoga","Zumba"]
      
    
    
    var bioEducationLevel:[String] {
        
        get {
            var arr = Array<String>()
            arr.append(contentsOf: educationLevel)
            arr.append("Others")
            return arr
        }
    }
    var filterEducationLevel:[String] {
        
        get {
            var arr = Array<String>()
            arr.append( "All")
            arr.append(contentsOf: educationLevel)
            return arr
        }
    }
    
    
    let educationLevel = [
        "Professional Degree",
        "Doctorate Degree",
        "Master’s’ Degree",
        "Bachelor’s Degree",
        "Associate Degree",
        "Some College / No Degree",
        "High School Diploma or GED",
        "Some High School",
        "No High School",
        "Professional Certificate",
        "Trade or Craft Certificate"]
    
    
//    var income:[String] {
//
//        get {
//            return ["$0k","100k","200k","300k","400k","500k","600k","700k","800"]
//        }
//    }
    
}
