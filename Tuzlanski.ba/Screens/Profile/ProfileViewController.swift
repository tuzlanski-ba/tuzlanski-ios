//
//  ProfileViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SwiftUI
import KeychainSwift
import AlertKit

class ObservableProfile: ObservableObject {
    @Published var user: User?
    @Published var authError: String?
    @Published var loading: Bool = false
}

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private var observableProfile: ObservableProfile?
    private let httpClient = TuzlanskiHttpClient()
    private let keychain = KeychainSwift()
    private let socialAuthenticator = SocialAuthenticator()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Profil"
        
        NotificationCenter.default.addObserver(forName: AppNotifications.userChangedNotification, object: nil, queue: .main) { [weak self] _ in
            self?.observableProfile?.user = AppStorage.user
        }
    }
    
    override func loadView() {
        view = UIView.screen()
        
        let observableProfile = ObservableProfile()
        observableProfile.user = AppStorage.user
        self.observableProfile = observableProfile
        
        var profileView = ProfileView(observableProfile: observableProfile)
        
        profileView.onLogin = { [unowned self] email, password in
            guard !email.isEmpty, !password.isEmpty else { return }
            Task {
                do {
                    observableProfile.loading = true
                    observableProfile.authError = nil
                    
                    let loginResponse = try await httpClient.login(email: email, password: password)
                    observableProfile.user = loginResponse.user
                    
                    AppStorage.user = loginResponse.user
                    keychain.set(loginResponse.token, forKey: "user_token", withAccess: .accessibleWhenUnlocked)
                } catch TuzlanskiHttpClientError.messageError(let message) {
                    print("Auth error:", message)
                    observableProfile.authError = message
                } catch {
                    print("Login failed:", error)
                }
                observableProfile.loading = false
            }
        }
        
        profileView.onLogout = { [unowned self] in
            let alert = UIAlertController(title: "Odjava", message: "Jeste li sigurni da se želite odjaviti?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Da", style: .destructive, handler: { _ in
                Task {
                    do {
                        observableProfile.loading = true
                        try await self.httpClient.logout()
                        AppStorage.user = nil
                        self.observableProfile?.user = nil
                        self.keychain.delete("user_token")
                    } catch {
                        print("Error while logging out:", error)
                    }
                    observableProfile.loading = false
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Zatvori", style: .cancel))
            
            self.present(alert, animated: true)
        }
        
        profileView.onPasswordForget = { [unowned self] in
            let passwordForgotViewController = PasswordForgotViewController().embeddedInNavigation()
            present(passwordForgotViewController, animated: true)
        }
        
        profileView.onRegister = { [unowned self] in
            let registerViewController = RegisterViewController().embeddedInNavigation()
            present(registerViewController, animated: true)
        }
        
        profileView.onEmailResend = { [unowned self] in
            Task {
                do {
                    try await httpClient.resendVerificationEmail()
                    await MainActor.run {
                        AlertKitAPI.present(
                            title: "Email poslan",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                    }
                } catch {
                    let alert = UIAlertController.make(title: nil, message: "Došlo je do greške prilikom ponovnog slanja. Molimo pokušajte ponovo.")
                    self.present(alert, animated: true)
                }
            }
        }
        
        profileView.onMyCommentsPress = { [unowned self] in
            guard let user = observableProfile.user else { return }
            if !user.has_verified_email {
                present(UIAlertController.make(title: nil, message: "Morate verifikovati email kako bi otključali ovu funkcionalnost."), animated: true)
            }
            
            navigationController?.pushViewController(UserCommentsViewController(), animated: true)
        }
        
        profileView.onPasswordChangePress = { [unowned self] in
            guard let user = observableProfile.user else { return }
            if !user.has_verified_email {
                present(UIAlertController.make(title: nil, message: "Morate verifikovati email kako bi otključali ovu funkcionalnost."), animated: true)
            }
            let passwordChangeViewController = PasswordChangeViewController().embeddedInNavigation()
            present(passwordChangeViewController , animated: true)
        }
        
        profileView.onBookmarksPress = { [unowned self] in
            navigationController?.pushViewController(BookmarksViewController(), animated: true)
        }
        
        profileView.onSocialAuth = { [unowned self] type in
            Task {
                do {
                    let loginResponse = try await socialAuthenticator.authenticate(type: type)
                    observableProfile.user = loginResponse.user
                    
                    AppStorage.user = loginResponse.user
                    keychain.set(loginResponse.token, forKey: "user_token", withAccess: .accessibleWhenUnlocked)
                } catch {
                    await MainActor.run {
                        AlertKitAPI.present(
                            title: "Došlo je do greške prilikom prijave.",
                            icon: .error,
                            style: .iOS17AppleMusic,
                            haptic: .error
                        )
                    }
                }
            }
        }
        
        profileView.onAccountRemove = { [unowned self] in
            let alert = UIAlertController(title: nil, message: "Jeste li sigurni da želite obrisati svoj profil? Obrisani profil nije moguće vratiti.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Da", style: .destructive, handler: { _ in
                Task {
                    do {
                        observableProfile.loading = true
                        let message = try await self.httpClient.requestAccountDeletion().message
                        AppStorage.user = nil
                        self.observableProfile?.user = nil
                        self.keychain.delete("user_token")
                        await MainActor.run {
                            AlertKitAPI.present(
                                title: message,
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                    } catch {
                        print("Error while logging out:", error)
                        await MainActor.run {
                            AlertKitAPI.present(
                                title: "Došlo je do greške prilikom brisanja profila.",
                                icon: .error,
                                style: .iOS17AppleMusic,
                                haptic: .error
                            )
                        }
                    }
                    observableProfile.loading = false
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Zatvori", style: .cancel))
            
            self.present(alert, animated: true)
        }
        
        addSwiftUIView(profileView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct ProfileView: View {
    
    enum Field: Hashable {
        case email
        case password
    }
    
    @ObservedObject var observableProfile: ObservableProfile
    
    @State private var emailInputText: String = ""
    @State private var passwordInputText: String = ""
    
    @FocusState private var focusedField: Field?
    
    var onLogin: ((String, String) -> ())?
    var onLogout: (() -> ())?
    var onPasswordForget: (() -> ())?
    var onRegister: (() -> ())?
    var onEmailResend: (() -> ())?
    var onMyCommentsPress: (() -> ())?
    var onPasswordChangePress: (() -> ())?
    var onBookmarksPress: (() -> ())?
    var onSocialAuth: ((SocialAuthType) -> ())?
    var onAccountRemove: (() -> ())?
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                
                if let user = observableProfile.user {
                    
                    VStack(spacing: 0) {
                        
                        Text("\(user.name.initials)")
                            .font(Font(UIFont.Montserrat(.bold, size: 15)))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Circle().foregroundColor(Color(UIColor.color(for: user.name))).frame(width: 64, height: 64))
                            .padding(.bottom, 20)
                            .padding(.top, 16)
                        
                        Text("\(user.name)")
                            .font(Font(UIFont.Montserrat(.bold, size: 14)))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 6)
                            .padding(.top, 12)
                        
                        Text("Korisnik od \(Date.formatToDate(apiDate: user.created_at))")
                            .font(Font(UIFont.Montserrat(.semibold, size: 14)))
                            .foregroundStyle(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 12)
                            .padding(.top, 6)
                        
                        if !user.has_verified_email {
                            VStack(spacing: 8) {
                                Text("Da biste otključali sve mogućnosti aplikacije potrebno je da verifikujete vaš email.")
                                    .font(Font(UIFont.Montserrat(.semibold, size: 14)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.orange)
                                HStack {
                                    Button(action: { onEmailResend?() }) {
                                        Text("Pošalji email za verifikaciju ponovo")
                                            .font(Font(UIFont.Montserrat(.bold, size: 12)))
                                            .foregroundColor(Color.orange)
                                            .padding(8)
                                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(Color.orange.opacity(0.2)))
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.orange.opacity(0.1)))
                            .padding(.bottom, 12)
                            .padding(.top, 12)
                        }
                       
                        
                        SettingsItem(text: "Moji komentari", imageName: "comments") {
                            onMyCommentsPress?()
                        }
                        Divider()
                        SettingsItem(text: "Promijeni šifru", imageName: "key") {
                            onPasswordChangePress?()
                        }
                        Divider()
                        SettingsItem(text: "Sačuvane vijesti", imageName: "bookmark") {
                            onBookmarksPress?()
                        }
                        Divider()
                        SettingsItem(text: "Odjavi se", imageName: "logout", destructive: true) {
                            onLogout?()
                        }
                        Divider()
                        SettingsItem(text: "Ukloni profil", imageName: "account-remove", destructive: true) {
                            onAccountRemove?()
                        }
                        
                        Spacer()
                        
                        Text("Verzija 0.1 (1)")
                            .foregroundStyle(Color.gray.opacity(0.6))
                            .font(Font(UIFont.Montserrat(.semibold, size: 12)))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .frame(minHeight: geo.size.height)
                    .onAppear {
                        emailInputText = ""
                        passwordInputText = ""
                    }
                    
                } else {
                    
                    guestView(geo: geo)
                    
                }
            }
            .overlay(observableProfile.loading ? SpinnerView() : nil)
            
        }
    }
    
    private func guestView(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            
            SettingsItem(text: "Sačuvane vijesti", imageName: "bookmark") {
                onBookmarksPress?()
            }
            
            Divider()
                .padding(.top, 16)
                .padding(.bottom, 16)
            
            Text("Prijavite se koristeći vaše pristupne podatke kako bi otključali mogućnost ostavljanja komentara.")
                .font(Font(UIFont.Montserrat(.bold, size: 12)))
                .foregroundStyle(Color.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
            Text("E-mail Adresa".uppercased())
                .font(Font(UIFont.Montserrat(.bold, size: 14)))
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $emailInputText, prompt: Text(verbatim: "primjer@primjer.com"))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(ThemedTextFieldStyle())
                .padding(.top, 6)
                .focused($focusedField, equals: .email)
            Text("Šifra".uppercased())
                .font(Font(UIFont.Montserrat(.bold, size: 14)))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
            SecureField("", text: $passwordInputText, prompt: Text("xxxxxxxxxx"))
                .textInputAutocapitalization(.never)
                .textFieldStyle(ThemedTextFieldStyle())
                .padding(.top, 6)
                .focused($focusedField, equals: .password)
            if let authError = observableProfile.authError {
                Text(authError)
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .foregroundStyle(Color(UIColor.systemRed))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
            }
            Button(action: { onLogin?(emailInputText.cleaned(), passwordInputText.cleaned()) }) {
                Text("PRIJAVI SE")
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .tint(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 40)
            .background(Color(UIColor.tintColor))
            .cornerRadius(6)
            .padding(.top, 16)
            Button(action: { onPasswordForget?() }) {
                Text("Zaboravljena šifra?")
                    .foregroundStyle(Color(UIColor.tintColor))
                    .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 16)
            Button(action: { onRegister?() }) {
                Text("Nemaš račun? Registruj se")
                    .foregroundStyle(Color(UIColor.label))
                    .font(Font(UIFont.Montserrat(.semibold, size: 13)))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 16)
            
            Divider()
                .padding(.vertical, 10)
            
            Text("BRZA PRIJAVA")
                .foregroundStyle(Color(UIColor.label))
                .font(Font(UIFont.Montserrat(.bold, size: 12)))
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(alignment: .center, spacing: 16) {
                ForEach(SocialAuthType.allCases, id: \.self) { type in
                    Button(action: { onSocialAuth?(type) }, label: {
                        ZStack {
                            Circle()
                                .strokeBorder(Color(UIColor.systemGray4),lineWidth: 1)
                                .background(Circle().fill(Color(UIColor.screenBackground)))
                                .frame(width: 36, height: 36)
                            Image(type.name)
                                .resizable()
                                .foregroundColor(Color(UIColor.label))
                                .frame(width: 22, height: 22)
                        }
                        .frame(width: 36, height: 36)
                    })
                }
            }
            .padding(.vertical, 16)
            
            Spacer()
            
            Text("Verzija 0.1 (1)")
                .foregroundStyle(Color.gray.opacity(0.6))
                .font(Font(UIFont.Montserrat(.semibold, size: 12)))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .frame(minHeight: geo.size.height)
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
}

// MARK: - Helper views

public struct ThemedTextFieldStyle : TextFieldStyle {
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Font(UIFont.Montserrat(.bold, size: 14)))
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray, lineWidth: 1))
            .tint(Color(UIColor.tintColor))
    }
}

struct SettingsItem: View {
    
    var text: String
    var imageName: String
    var supplementaryText: String? = nil
    var destructive: Bool = false
    var onTouchUp: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTouchUp?() }, label: {
            HStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18, alignment: .center)
                    .tint(destructive ? Color.red : Color.primary)
                Text(text)
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .foregroundStyle(destructive ? Color.red : Color.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.gray)
            }
            .frame(minHeight: 46)
        })
    }
}
