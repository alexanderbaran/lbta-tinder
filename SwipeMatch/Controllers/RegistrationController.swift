//
//  RegistrationController.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 14/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Not sure if we need this but let's do it anyways to show that you can do things when cancelled.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
//        registrationViewModel.image = image
        registrationViewModel.bindableImage.value = image
//        self.selectPhotoButton.imageView?.image = image // Common mistake, need to call setImage.
//        self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
}

class RegistrationController: UIViewController {
    
    // UI Components
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    @objc private func handleSelectPhoto() {
        print("Select photo")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    let fullNameTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter full name"
        tf.backgroundColor = .white
        //        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    @objc private func handleTextChange(textField: UITextField) {
        if textField == fullNameTextField {
            //            print("Full name changing")
            registrationViewModel.fullName = textField.text
        } else if textField == emailTextField {
            //            print("Email changing")
            registrationViewModel.email = textField.text
        } else {
            //            print("Password changing")
            registrationViewModel.password = textField.text
        }
        //        print("TEXT CHANGING:", textField.text ?? "")
        //        let isFormValid = fullNameTextField.text?.isEmpty == false && emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        //        if isFormValid {
        //            registerButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        //            registerButton.isEnabled = true
        //        } else {
        //            registerButton.backgroundColor = .lightGray
        //            registerButton.isEnabled = false
        //        }
        
    }
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.darkGray, for: .disabled)
        button.isEnabled = false
        //        button.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let registeringHUD = JGProgressHUD(style: .dark)
    
    @objc private func handleRegister() {
        self.handleTapDismiss()
//        guard let email = emailTextField.text else { return }
//        guard let password = passwordTextField.text else { return }
        
//        registrationViewModel.bindableIsRegistering.value = true
        registrationViewModel.performRegistration { [weak self] (error: Error?) in
            if let error = error {
                self?.showHUDWithError(error: error)
                return
            }
            print("Finished registering our user")
        }
        
//        registeringHUD.textLabel.text = "Register"
//        registeringHUD.show(in: view)
//        Auth.auth().createUser(withEmail: email, password: password) { (result: AuthDataResult?, error: Error?) in
//            if error != nil {
//                print(error!)
//                self.showHUDWithError(error: error!)
//                return
//            }
//            print("Successfully registered user:", result?.user.uid ?? "")
//            // Only upload images to Firebase Storage once you are authorized.
//            let filename = UUID().uuidString
//            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
//            let imageData = self.registrationViewModel.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
//            ref.putData(imageData, metadata: nil, completion: { (_, err: Error?) in
//                if let err = err {
//                    self.showHUDWithError(error: err)
//                    print(err)
//                    return // Bail
//                }
//                print("Finished uploading image to storage")
//                ref.downloadURL(completion: { (url: URL?, err: Error?) in
//                    if let err = err {
//                        self.showHUDWithError(error: err)
//                        print(err)
//                        return
//                    }
////                    self.registeringHUD.dismiss()
//                    self.registrationViewModel.bindableIsRegistering.value = false
//                    print("Download url of our image is:", url?.absoluteString ?? "")
//                    // Store the download url into Firestore next lesson.
//                })
//            })
//        }
//        print("Register our User in Firebase Auth")
    }
    
    private func showHUDWithError(error: Error) {
        registeringHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        setupLayout()
        
        setupNotificationObservers()
        
        setupTapGesture()
        setupRegistrationViewModelObserver()
    }
    
    let registrationViewModel = RegistrationViewModel()
    
    private func setupRegistrationViewModelObserver() {
        registrationViewModel.bindableIsFormValid.bind { [unowned self] (isFormValid: Bool?) in
            guard let isFormValid = isFormValid else { return }
            self.registerButton.isEnabled = isFormValid
            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) : .lightGray
//            if isFormValid {
//                self.registerButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//                self.registerButton.isEnabled = true
//            } else {
//                self.registerButton.backgroundColor = .lightGray
//                self.registerButton.isEnabled = false
//            }
        }
//        registrationViewModel.isFormValidObserver = { [unowned self] (isFormValid: Bool) in
//            //            print("Form is changing, is it valid?", isFormValid ?? false)
//            if isFormValid {
//                self.registerButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//                self.registerButton.isEnabled = true
//            } else {
//                self.registerButton.backgroundColor = .lightGray
//                self.registerButton.isEnabled = false
//            }
//        }
        registrationViewModel.bindableImage.bind { [unowned self] (image: UIImage?) in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
//        registrationViewModel.imageObserver = { [unowned self] (image: UIImage?) in
//            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
        registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering: Bool?) in
            if isRegistering == true { // No need to unwrap when checking if true.
                self.registeringHUD.textLabel.text = "Register"
                self.registeringHUD.show(in: self.view)
            } else {
                self.registeringHUD.dismiss()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self) // You'll have a retain cycle.
        /* Get's called when imagePicker shows up, so keyboardhandling
        does not work anymore then if we removeObservers. */
//        print("viewWillDisappear")
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc private func handleTapDismiss() {
        self.view.endEditing(true)
        handleKeyboardHide()
    }
    
    @objc private func handleKeyboardShow(notification: Notification) {
        //        print("Keyboard will show")
        //        print(notification.userInfo)
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        //        print(keyboardFrame)
        
        // Let's try to figure out how tall the gap is from the register button to the bottom of the screen.
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    @objc private func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    let gradientLayer = CAGradientLayer()
    
    private func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
            ])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
        ])
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
        } else {
            overallStackView.axis = .vertical
        }
    }
    
    let goToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleGoToLogin() {
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    private func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(overallStackView)
        //        stackView.axis = .vertical
        overallStackView.axis = .vertical
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
        overallStackView.spacing = 8
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(goToLoginButton)
        goToLoginButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
    }
    
}
