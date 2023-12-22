//
//  PasswordChangeViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 22. 12. 2023..
//

import UIKit
import SwiftUI
import KeychainSwift
import AlertKit

class ObservablePasswordChangeData: ObservableObject {
    @Published var errors: [String: [String]] = [:]
    @Published var generalError: String?
    @Published var loading: Bool = false
}

class PasswordChangeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var observablePasswordChangeData = ObservablePasswordChangeData()
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
        
        var passwordChangeView = PasswordChangeView(observablePasswordChangeData: observablePasswordChangeData)
        
        passwordChangeView.onPasswordChange = { [unowned self] password, passwordConfirm in
            guard !password.isEmpty, !passwordConfirm.isEmpty else { return }
            observablePasswordChangeData.generalError = nil
            observablePasswordChangeData.errors = [:]
            observablePasswordChangeData.loading = true
            Task {
                do {
                    let passwordChangeResult = try await httpClient.changePassword(password: password, passwordConfirmation: passwordConfirm)
                    switch passwordChangeResult {
                    case .success:
                        dismiss(animated: true) {
                            AlertKitAPI.present(
                                title: "Šifra promijenjena",
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                    case .failure(let errorPasswordChange):
                        observablePasswordChangeData.errors = errorPasswordChange.errors
                    }
                } catch {
                    print("Password change general error:", error)
                    observablePasswordChangeData.generalError = "Došlo je do greške prilikom promjene šifre. Molimo provjerite vaše podatke i konekciju pa pokušajte ponovo."
                }
                observablePasswordChangeData.loading = false
            }
        }
        
        addSwiftUIView(passwordChangeView)
    }
}

struct PasswordChangeView: View {
    
    enum Field: Hashable {
        case password
        case passwordConfirm
    }
    
    @ObservedObject var observablePasswordChangeData: ObservablePasswordChangeData
    
    @State private var passwordInputText: String = ""
    @State private var passwordConfirmInputText: String = ""
    
    @FocusState private var focusedField: Field?
    
    var onPasswordChange: ((String, String) -> ())?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                Text("Šifra mora imati najmanje 8 znakova i mora biti kombinacija malih i velikih slova, brojeva i specijalnih znakova.")
                    .font(Font(UIFont.Montserrat(.semibold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 14)
                
                Text("Šifra".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                SecureField("", text: $passwordInputText, prompt: Text(verbatim: "xxxxxxxx"))
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(ThemedTextFieldStyle())
                    .padding(.top, 6)
                    .focused($focusedField, equals: .password)
                
                if let errors = observablePasswordChangeData.errors["password"] {
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
                
                if let errors = observablePasswordChangeData.errors["password_confirmation"] {
                    ForEach(errors, id: \.self) { error in
                        errorText(error)
                    }
                }
                
                Button(action: { onPasswordChange?(passwordInputText.cleaned(), passwordConfirmInputText.cleaned()) }) {
                    Text("SPASI IZMJENE")
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
        .overlay(observablePasswordChangeData.loading ? SpinnerView() : nil)
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
