//
//  apiCaller.swift
//  SNEWS
//
//  Created by Sarthak Agrawal on 19/02/23.
//

import Foundation

final class apiCaller{
    static let shared = apiCaller()
    
    struct Constants{
        static let topHeadLineURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=fc287225aa6149e9b9a0b6cd6793f665")
                static let searchUrlString = "https://newsapi.org/v2/everything?sortBy=popularity&apiKey=fc287225aa6149e9b9a0b6cd6793f665&q="
        
    }
    private init(){}
    
    public func getTopStories(completion : @escaping (Result<[Article], Error>) -> Void){
        guard let url = Constants.topHeadLineURL else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){ data, _,error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data{
                do{
                    let result = try JSONDecoder().decode(apiResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch{
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func search(with query: String, completion : @escaping (Result<[Article], Error>) -> Void){
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        
        let urlString = Constants.searchUrlString + query
        guard let url = URL(string: urlString) else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){ data, _,error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data{
                do{
                    let result = try JSONDecoder().decode(apiResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch{
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

//models

struct apiResponse: Codable{
    let articles: [Article]
}

struct Article: Codable{
    let source:Source
    let title:String
    let description:String?
    let url:String?
    let urlToImage:String?
    let publishedAt: String
}


struct Source:Codable{
    let name:String
}
