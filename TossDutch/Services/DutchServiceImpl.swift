//
//  DutchServiceImpl.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RxSwift
import Alamofire
import SwiftyJSON
import Foundation

enum DutchServiceError: Error {
    case urlParsingFailed
    case makeURLRequestFailed
}

struct DutchServiceImpl: DutchService {
    func requestDutchData() -> Single<DutchData> {
        .create { observer in
            guard let url = URL(string: "https://ek7b8b8yq2.execute-api.us-east-2.amazonaws.com/default/toss_ios_homework_dutch_detail") else {
                observer(.failure(DutchServiceError.urlParsingFailed))
                return Disposables.create { }
            }
            guard let urlRequest = try? URLRequest(url: url, method: .get) else {
                observer(.failure(DutchServiceError.makeURLRequestFailed))
                return Disposables.create { }
            }
            let request = AF.request(urlRequest).validate().responseDecodable(of: DutchData.self) { response in
                switch response.result {
                case let .success(value):
                    observer(.success(value))
                case let .failure(error):
                    observer(.failure(error))
                }
            }
            return Disposables.create { request.cancel() }
//            AF.request(urlRequest).validate().responseJSON { response in
//                switch response.result {
//                case let .success(value):
//                    let json = JSON(value)
//                    observer(.success(<#T##PrimitiveSequence<SingleTrait, DutchData>.Element#>))
//                case let .failure(error):
//                    observer(.failure(error))
//                }
//            }
           
        }
    }
}
