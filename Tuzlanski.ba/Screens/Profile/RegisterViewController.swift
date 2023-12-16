//
//  RegisterViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 14. 12. 2023..
//

import Foundation

import UIKit
import SwiftUI
import KeychainSwift

class ObservableRegisterData: ObservableObject {
    @Published var errors: [String: [String]] = [:]
    @Published var generalError: String?
    @Published var loading: Bool = false
}

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    private var observableRegisterData = ObservableRegisterData()
    private let httpClient = TuzlanskiHttpClient()
    private let keychain = KeychainSwift()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Registracija"
        addCloseButton()
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .systemBackground
        
        var registerView = RegisterView(observableRegisterData: observableRegisterData)
        
        registerView.onRegister = { [unowned self] username, email, password, passwordConfirm in
            guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !passwordConfirm.isEmpty else { return }
            observableRegisterData.generalError = nil
            observableRegisterData.errors = [:]
            observableRegisterData.loading = true
            Task {
                do {
                    let registerResult = try await httpClient.register(username: username, email: email, password: password, passwordConfirm: passwordConfirm)
                    switch registerResult {
                    case .success(let loginResponse):
                        AppStorage.user = loginResponse.user
                        keychain.set(loginResponse.token, forKey: "user_token", withAccess: .accessibleWhenUnlocked)
                        NotificationCenter.default.post(name: AppNotifications.userChangedNotification, object: nil)
                        dismiss(animated: true)
                    case .failure(let errorLoginResponse):
                        observableRegisterData.errors = errorLoginResponse.errors
                    }
                } catch {
                    print("Registration general error:", error)
                    observableRegisterData.generalError = "Došlo je do greške prilikom registracije. Molimo provjerite vaše podatke i konekciju pa pokušajte ponovo."
                }
                observableRegisterData.loading = false
            }
        }
        
        addSwiftUIView(registerView)
    }
}

struct RegisterView: View {
    
    enum Field: Hashable {
        case username
        case email
        case password
        case passwordConfirm
    }
    
    @ObservedObject var observableRegisterData: ObservableRegisterData
    
    @State private var usernameInputText: String = ""
    @State private var emailInputText: String = ""
    @State private var passwordInputText: String = ""
    @State private var passwordConfirmInputText: String = ""
    
    @FocusState private var focusedField: Field?
    
    var onRegister: ((String, String, String, String) -> ())?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Nadimak".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                TextField("", text: $usernameInputText, prompt: Text(verbatim: "Nadimak"))
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(ThemedTextFieldStyle())
                    .padding(.top, 6)
                    .focused($focusedField, equals: .username)
                
                if let errors = observableRegisterData.errors["name"] {
                    ForEach(errors, id: \.self) { error in
                        errorText(error)
                    }
                }
                
                Text("E-mail Adresa".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                TextField("", text: $emailInputText, prompt: Text(verbatim: "primjer@primjer.com"))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(ThemedTextFieldStyle())
                    .padding(.top, 6)
                    .focused($focusedField, equals: .email)
                
                if let errors = observableRegisterData.errors["email"] {
                    ForEach(errors, id: \.self) { error in
                        errorText(error)
                    }
                }
                
                Text("Šifra".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                SecureField("", text: $passwordInputText, prompt: Text(verbatim: "xxxxxxxx"))
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(ThemedTextFieldStyle())
                    .padding(.top, 6)
                    .focused($focusedField, equals: .password)
                
                if let errors = observableRegisterData.errors["password"] {
                    ForEach(errors, id: \.self) { error in
                        errorText(error)
                    }
                }
                
                Text("Ponovi šifru".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                SecureField("", text: $passwordConfirmInputText, prompt: Text(verbatim: "xxxxxxxx"))
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(ThemedTextFieldStyle())
                    .padding(.top, 6)
                    .focused($focusedField, equals: .passwordConfirm)
                
                if let errors = observableRegisterData.errors["password_confirmation"] {
                    ForEach(errors, id: \.self) { error in
                        errorText(error)
                    }
                }
                
                Button(action: { onRegister?(usernameInputText.cleaned(), emailInputText.cleaned(), passwordInputText.cleaned(), passwordConfirmInputText.cleaned()) }) {
                    Text("REGISTRUJ SE")
                        .font(Font(UIFont.Montserrat(.bold, size: 14)))
                        .tint(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 40)
                .background(Color(UIColor.tintColor))
                .cornerRadius(6)
                .padding(.top, 16)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Zatvori") {
                        focusedField = nil
                    }
                    .foregroundStyle(Color(UIColor.tintColor))
                    .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .overlay(observableRegisterData.loading ? SpinnerView() : nil)
    }
    
    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(Font(UIFont.Montserrat(.semibold, size: 14)))
            .foregroundStyle(Color.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            .padding(.bottom, 6)
    }
    
}
