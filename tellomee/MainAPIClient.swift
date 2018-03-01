//
//  MainAPIClient.swift
//  tellomee
//
//  Created by Michael Miller on 2/25/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import Alamofire
import Stripe

class MainAPIClient: NSObject {
    
    static let shared = MainAPIClient()
    
    var baseURLString = "http://localhost:5000/api"
    var baseURL: URL {
        return URL(string: baseURLString)!
    }
    
    enum ReservationError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func bookReservation(source: String, amount: Int, amountForCurator: Int, currency: String, reservation: Reservation, completion: @escaping (ReservationError?) -> Void) {
        print("in bookReservation")
        let url = self.baseURL.appendingPathComponent("book")
        
        // Important: For this demo, we're trusting the `amount` and `currency` coming from the client request.
        // A real application should absolutely have the `amount` and `currency` securely computed on the backend
        // to make sure the user can't change the payment amount from their web browser or client-side environment.
        let parameters: [String: Any] = [
            "source": source,
            "amount": amount,
            "amountForCurator": amountForCurator,
            "currency": currency,
            "customerId": (FirebaseManager.user?.stripeCustomerId)!,
            "curatorId": (reservation.experience.curator.stripeCuratorId)!,
            ]
                
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any] else {
                completion(.invalidResponse)
                return
            }
            
            completion(nil)
        }
    }
    
    func createCustomer(email:String, description:String, completion: @escaping (String?) -> Void) {
        print("at createCustomer")
        let url = self.baseURL.appendingPathComponent("create_customer")
        let parameters: [String: Any] = [
            "email": email,
            "description": description,
            ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            
//        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else {
                // TODO: Should not error out here. Should just call the completion without ever adding a stripeCustomerId. stripeCustomerId can be added once we try to create a charge.
                fatalError("Failure creating stripe customer. Check that the server is running at " + url.absoluteString)
                completion(nil)
            }
            
            // Send the returned customer id to the completion
            let customerId = json["customerId"] as! String
            completion(customerId)
        }
        
    }
    
    func redeemOnboardingAuthorizationCode(authCode:String, completion: @escaping (String?) -> Void) {
        // Call a new function in my api to do what used to happen in penguin
        
        print("at redeemOnboardingAuthorizationCode")
        
        
        let url = self.baseURL.appendingPathComponent("redeem_auth_code")
        let parameters: [String: Any] = [
            "auth_code": authCode
            ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in

            guard let json = response.result.value as? [String: Any] else {
                // TODO: Should not error out here. Should just call the completion without ever adding a stripeCustomerId. stripeCustomerId can be added once we try to create a charge.
                fatalError("Failure redeeming onboarding authorization code. Check that the server is running at " + url.absoluteString)
                completion(nil)
            }

            // Send the returned curator id to the completion
            let curatorId = json["curator_id"] as! String
            completion(curatorId)
        }
        
    }
}
    
// MARK: STPEphemeralKeyProvider
extension MainAPIClient : STPEphemeralKeyProvider {
    
    enum CustomerKeyError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("at createCustomerKey")
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            "customer_id": (FirebaseManager.user?.stripeCustomerId)!
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
            }
        }
    }
}

