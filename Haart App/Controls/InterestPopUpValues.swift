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


class InterestPopUpValues: AbstractControl, InterestsPopUpViewControllerDelegate {
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
    let kSmoking = "smoking"
    let kWorkout = "workout"
    
    var income = Array<String>()
    var popUp:PopupDialog!
    var viewController:InterestsPopUpViewController!
    var professionVC:ProfessionsVC!
    var currentSelectedList:SelectedIntrestsCollectionViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func showInterestsPopUp(sender: UIButton, values:Array<String>,arrKey:String) {
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
    func didChangeValueForIntrests() {
        
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
