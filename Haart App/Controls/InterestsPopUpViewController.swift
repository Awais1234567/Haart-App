//
//  InterestsPopUpViewController.swift
//  Haart App
//
//  Created by Stone on 15/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//
import SVProgressHUD
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import UIKit
import Alamofire
protocol InterestsPopUpViewControllerDelegate: class {
    func didChangeValueForIntrests() 
}

class InterestsPopUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HaartSearchBarDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        print("updating")
    }
    
    let db = Firestore.firestore()
    var userReference: CollectionReference {
        return db.collection("users")
    }
    weak var delegate: InterestsPopUpViewControllerDelegate?
    var userDocument:QueryDocumentSnapshot?
    @IBOutlet weak var searchTblView: UITableView!
    @IBOutlet weak var interestsSearchBar: HaartSearchbar!
    @IBOutlet weak var searchBarImgView: UIImageView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchMovies : Bool = false
    var searchBooks : Bool = false
    var searchBit : Bool = false
    var selectedItemsArr = NSMutableArray.init()
    var sender = UIButton.init()
    var currentSelectedList:SelectedIntrestsCollectionViewController!
    var resultSearchController = UISearchController()
    var itemsArr = Array<String>()
    var arrKey = String()
    var testData = [Movies?]()
    var movieData = [Movies?]()
    var moviesArray = [String]()
    var bookData = [Books?]()
    var booksArray = [String]()
    var showsData = [TVShows?]()
    var showsArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if(searchBit == true){
            interestsSearchBar.isHidden = true
            searchBarImgView.isHidden = true
            searchBar.isHidden = false
        }else{
            interestsSearchBar.isHidden = false
                      searchBarImgView.isHidden = false
                      searchBar.isHidden = true
        }
        searchBar.delegate = self
        interestsSearchBar.searchDelegate = self
        interestsSearchBar.searchImageView = searchBarImgView
        self.resultSearchController = ({

        let controller = UISearchController(searchResultsController: nil)

        controller.searchResultsUpdater = self
        controller.searchBar.placeholder = "search movie here"
        controller.dimsBackgroundDuringPresentation = false

        controller.searchBar.sizeToFit()


        return controller

        })()
        self.searchTblView.reloadData()
    }
    
    
    
    func initializeWith(items: Array<String>, sender:UIButton, arrKey:String) {
        self.sender = sender
        self.arrKey = arrKey
        itemsArr = items
        interestsSearchBar.items = items
        searchTblView.reloadData()
        selectedItemsArr = NSMutableArray.init(array: userDocument?.data()[arrKey] as? NSArray ?? NSArray())
        
    }
    
    
    func filteredArr(_ arr: Array<String>) {
        itemsArr = arr
        searchTblView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
            self.sender.setTitle(itemsArr[indexPath.row], for: .normal)
            UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
            return
        }
        
        let selectedItem = itemsArr[indexPath.row]
        
        if(selectedItemsArr.contains(selectedItem)) {
            selectedItemsArr.remove(selectedItem)
        }
        else {
            selectedItemsArr.add(selectedItem)
        }
        searchTblView.reloadData()
        delegate?.didChangeValueForIntrests()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell", for: indexPath) as! InterestsCell
        cell.textLbl.text = itemsArr[indexPath.row]
        let currentItem = itemsArr[indexPath.row]
        //let selectedArr1 = (UserDefaults.standard.object(forKey: arrKey) as? NSArray) ?? NSArray()
       // let selectedArr = NSMutableArray.init(array: selectedArr1)
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
           cell.heartImgView.isHidden = true
        }

        if(selectedItemsArr.contains(currentItem)) {
            cell.heartImgView.image = UIImage(named: "heartLike")
        }
        else {
            cell.heartImgView.image = UIImage(named: "heartUnlike")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    @IBAction func doneBtnPressed(_ sender: Any) {
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
            UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
            return
        }
        currentSelectedList.itemsArr = selectedItemsArr as! [String]
        
        
        
        if(self.userDocument == nil) {
            SVProgressHUD.show()
            self.userReference.addDocument(data: ["userId": Auth.auth().currentUser!.uid, arrKey:selectedItemsArr as! [String]]) { error in
                SVProgressHUD.dismiss()
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                    UIApplication.visibleViewController.dismiss(animated: true, completion: {
                        UIApplication.visibleViewController.viewWillAppear(false) //reload data
                    })
                }
            }
        }else {
            SVProgressHUD.show()
            userDocument?.reference.updateData([arrKey:selectedItemsArr as! [String]], completion: { (error) in
                SVProgressHUD.dismiss()
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                    UIApplication.visibleViewController.dismiss(animated: true, completion: {
                        UIApplication.visibleViewController.viewWillAppear(false) //reload data
                    })
                }
            })
        }
        
        if (currentSelectedList != nil) {
            currentSelectedList.collectionView.reloadData()
            //UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
       if(arrKey == "movies" || arrKey == "fmovies" ){ moviesArray.removeAll()
        if(searchText.count > 2){  fetchMovies(query: searchText){(testResponse,err) in
                     if let err = err {
                                  print("Failed to fetch tests:", err)
                                  return
                              }
         self.testData.insert(contentsOf: testResponse, at: 0)
        if((self.testData[0]?.results.count)! > 0){
            for i in 1...(self.testData[0]?.results.count)! - 1 {
                self.moviesArray.append((self.testData[0]?.results[i].title)!)
        }
        }
     
        print(self.moviesArray)
        self.itemsArr = self.moviesArray
        self.searchTblView.reloadData()
        }
            
        }
        
       }else if(arrKey == "books" || arrKey == "fbooks" ){
               booksArray.removeAll()
               if(searchText.count > 2){  fetchBooks(query: searchText){(testResponse,err) in
                            if let err = err {
                                         print("Failed to fetch tests:", err)
                                         return
                                     }
                self.bookData.insert(contentsOf: testResponse, at: 0)
                if((self.bookData[0]?.items?.count)! > 0){
                    for i in 0...(self.bookData[0]?.items?.count)! - 1 {
                        self.booksArray.append((self.bookData[0]?.items?[i].volumeInfo?.title)!)
               }
               }
            
               print(self.booksArray)
               self.itemsArr = self.booksArray
               self.searchTblView.reloadData()
               }}
        }else if(arrKey == "tvShows" || arrKey == "ftvShows"){
               showsArray.removeAll()
               if(searchText.count > 2){  fetchTVShows(query: searchText){(testResponse,err) in
                            if let err = err {
                                         print("Failed to fetch tests:", err)
                                         return
                                     }
                self.showsData.insert(contentsOf: testResponse, at: 0)
                if((self.showsData[0]?.tvShows.count)! > 0){
                    for i in 0...(self.showsData[0]?.tvShows.count)! - 1 {
                        self.showsArray.append((self.showsData[0]?.tvShows[i].name)!)
               }
               }
            
               print(self.showsArray)
               self.itemsArr = self.showsArray
               self.searchTblView.reloadData()
               }}
        }

    }
    
    
    
   func fetchMovies(query: String ,completion: @escaping ([Movies?], Error?)->()){

          let url = "https://api.themoviedb.org/3/search/movie"
    let data : Parameters = [
               "api_key" : "a692e28399cbdabc5e2f3f15a29f1b78",
               "language" : "en-US",
               "query" : "\(query)",
               "page" : "1",
               "include_adult" : "false",
           ]
    AF.request(url, method: .get , parameters: data).responseJSON{ (response) in
                   do{   let decoder = JSONDecoder()
                    let data = try decoder.decode(Movies.self, from: response.data!)
                    self.movieData.insert(data, at: 0)
                    completion(self.movieData,nil)
                    }
                    catch{
                        completion([nil], error)
                        print ("ERROR to decode \(error)")
                    }
                             
              }
                  
          
      }
    
    func fetchBooks(query: String ,completion: @escaping ([Books?], Error?)->()){

          let url = "https://www.googleapis.com/books/v1/volumes"
    let data : Parameters = [
               "q" : "\(query)"
           ]
    AF.request(url, method: .get , parameters: data).responseJSON{ (response) in
        print(response)
                   do{   let decoder = JSONDecoder()
                    let data = try decoder.decode(Books.self, from: response.data!)
                    self.bookData.insert(data, at: 0)
                    completion(self.bookData,nil)
                    }
                    catch{
                        completion([nil], error)
                        print ("ERROR to decode \(error)")
                    }
                             
              }
                  
          
      }
    
    func fetchTVShows(query: String ,completion: @escaping ([TVShows?], Error?)->()){
            let url = "https://www.episodate.com/api/search"
      let data : Parameters = [
                 "q" : "\(query)",
                 "page" : "1"
             ]
      AF.request(url, method: .get , parameters: data).responseJSON{ (response) in
          print(response)
                     do{   let decoder = JSONDecoder()
                      let data = try decoder.decode(TVShows.self, from: response.data!)
                      self.showsData.insert(data, at: 0)
                      completion(self.showsData,nil)
                      }
                      catch{
                          completion([nil], error)
                          print ("ERROR to decode \(error)")
                      }
                               
                }
                    
            
        }
    
  
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
    }
    
}
