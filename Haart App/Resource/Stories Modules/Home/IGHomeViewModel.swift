//
//  IGHomeViewModel.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

struct IGHomeViewModel {
    
    //MARK: - iVars
    //Keep it Immutable! don't get Dirty :P
//    private let stories: IGStories? = {
//        do {
//            return try IGMockLoader.loadMockFile(named: "stories.json", bundle: .main)
//        }catch let e as MockLoaderError {
//            debugPrint(e.description)
//        }catch{
//            debugPrint("could not read Mock json file :(")
//        }
//        return nil
//    }()
    
    var stories: IGStories?
    
    
    //MARK: - Public functions
    public func getStories() -> IGStories? {
        return stories
    }
    public func numberOfItemsInSection(_ section:Int) -> Int {
        if let count = stories?.count {
//            if(count > 1) {
//                 return count  // Add Story cell
//            }
           return count + 1
        }
        return 1
    }
    
    public func cellForItemAt(indexPath:IndexPath) -> IGStory? {
        return stories?.stories[indexPath.row-1]
    }
    public func cellForItemAtActual(indexPath:IndexPath) -> IGStory? {
        return stories?.stories[indexPath.row]
    }
    public func numberOfActualItemsInSection(_ section:Int) -> Int {
        if let count = stories?.count {
          
            return count
        }
        return 0
    }
}
