//
//  RegistrationViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 14/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableIsRegistering = Bindable<Bool>()
    
    var bindableImage = Bindable<UIImage>()
    
//    var image: UIImage? {
//        didSet {
//            imageObserver?(image)
//        }
//    }
//    var imageObserver: ((UIImage?) -> ())?
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    private func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false/* && bindableImage.value != nil*/
        bindableIsFormValid.value = isFormValid
//        isFormValidObserver?(isFormValid)
    }
    
    // Need to include @escaping syntax
    func performRegistration(completion: @escaping (Error?) -> ()) {
        bindableIsRegistering.value = true
        guard let email = email, let password = password else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (result: AuthDataResult?, error: Error?) in
            if error != nil {
//                print(error!)
//                self.showHUDWithError(error: error!)
                completion(error)
                return
            }
            print("Successfully registered user:", result?.user.uid ?? "")
            self.saveImageToFirebase(completion: completion)

        }
    }
    
    private func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        // Only upload images to Firebase Storage once you are authorized.
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        //            let imageData = self.registrationViewModel.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: { (_, error: Error?) in
            if let error = error {
                //                    self.showHUDWithError(error: err)
                //                    print(err)
                completion(error)
                return // Bail
            }
            print("Finished uploading image to storage")
            ref.downloadURL(completion: { (url: URL?, err: Error?) in
                if let error = error {
                    //                        self.showHUDWithError(error: err)
                    //                        print(err)
                    completion(error)
                    return
                }
                //                    self.registeringHUD.dismiss()
                //                    self.registrationViewModel.bindableIsRegistering.value = false
                self.bindableIsRegistering.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                // Store the download url into Firestore next lesson.
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
//                completion(nil) // Just to invoke the actual code in the completetion handler in handleRegister() in RegistrationController.
            })
        })
    }
    
    private func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any?] = [
            "fullName": fullName ?? "",
            "uid": uid,
            "imageUrl1": imageUrl,
            "imageUrl2": nil,
            "imageUrl3": nil,
            "age": 18,
            "minSeekingAge": SettingsController.defaultMinSeekingAge,
            "maxSeekingAge": SettingsController.defaultMaxSeekingAge
        ]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error: Error?) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    var bindableIsFormValid = Bindable<Bool>()
    
    // Reactive programming
//    var isFormValidObserver: ((Bool) -> ())?
    
}
