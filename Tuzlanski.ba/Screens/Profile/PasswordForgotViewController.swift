//
//  PasswordForgotViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 14. 12. 2023..
//

import UIKit
import SwiftUI

class PasswordForgotViewController: UIViewController {
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Zaboravljena šifra"
        addCloseButton()
    }
    
    override func loadView() {
        view = UIView.screen()
        
        var passwordForgotView = PasswordForgotView()
        
        passwordForgotView.onPasswordReset = { [unowned self] email in
            guard !email.isEmpty else { return }
            Task {
                do {
                    try await httpClient.resetPassword(email: email)
                    await MainActor.run {
                        dismiss(animated: true) {
                            self.presentingViewController?.present(UIAlertController.make(title: nil, message: "Molimo provjerite vaš email za instrukcije o resetovanju šifre."), animated: true)
                        }
                    }
                } catch TuzlanskiHttpClientError.messageError(let message) {
                    present(UIAlertController.make(title: nil, message: message), animated: true)
                } catch {
                    present(UIAlertController.make(title: nil, message: "Dogodila se greška prilikom resetovanja šifre. Provjerite vaše podatke pa pokušajte ponovo."), animated: true)
                }
            }
        }
        
        addSwiftUIView(passwordForgotView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct PasswordForgotView: View {
    
    @State private var emailInputText: String = ""
    
    var onPasswordReset: ((String) -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Unesite email adresu povezanu sa vašim računom kako biste resetovali šifru.")
                .font(Font(UIFont.Montserrat(.semibold, size: 14)))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
            
            Text("E-mail Adresa".uppercased())
                .font(Font(UIFont.Montserrat(.bold, size: 14)))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
            TextField("", text: $emailInputText, prompt: Text(verbatim: "primjer@primjer.com"))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(ThemedTextFieldStyle())
                .padding(.top, 6)
            
            Button(action: { onPasswordReset?(emailInputText) }) {
                Text("RESETUJ ŠIFRU")
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
    }
    
}
