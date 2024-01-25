//
//  NewCommentViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 20. 12. 2023..
//

import Foundation

import UIKit
import SwiftUI
import AlertKit

class NewCommentViewController: UIViewController {
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    private let article: Article
    private let replyToComment: Comment?
    
    var onNewComment: ((Comment) -> Void)?
    
    // MARK: - Lifecycle
    
    init(article: Article, replyToComment: Comment? = nil) {
        self.article = article
        self.replyToComment = replyToComment
        super.init(nibName: nil, bundle: nil)
        
        UITextView.appearance().textContainerInset =
                 UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Novi komentar"
        addCloseButton()
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .systemBackground
        
        var newCommentView = NewCommentView(replyToComment: replyToComment)
        
        newCommentView.onPostComment = { [unowned self] commentText in
            guard !commentText.isEmpty, commentText.count <= 1000 else { return }
            Task {
                do {
                    let comment = try await httpClient.post(comment: commentText, article: article, replyToComment: replyToComment)
                    await MainActor.run {
                        onNewComment?(comment)
                        
                        dismiss(animated: true) {
                            AlertKitAPI.present(
                                title: "Komentar objavljen",
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                    }
                } catch TuzlanskiHttpClientError.messageError(let message) {
                    present(UIAlertController.make(title: nil, message: message), animated: true)
                } catch {
                    print("Error while adding new comment:", error)
                    present(UIAlertController.make(title: nil, message: "Dogodila se greška prilikom objave komentara. Provjerite vaše podatke pa pokušajte ponovo."), animated: true)
                }
            }
        }
        
        addSwiftUIView(newCommentView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct NewCommentView: View {
    
    enum Field: Hashable {
        case comment
    }
    
    private var replyToComment: Comment?
    
    @State private var commentText: String = ""
    @FocusState private var focusedField: Field?
    
    var onPostComment: ((String) -> ())?
    
    init (replyToComment: Comment?) {
        self.replyToComment = replyToComment
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("**NAPOMENA:** Molimo korisnike da se suzdrže od vrijeđanja, psovanja i vulgarnog izražavanja. Komentari predstavljaju stavove isključivo njihovih autora, koji zbog govora mržnje mogu biti i krivično gonjeni. Kao čitatelj prihvatate mogućnost da među komentarima možete pronaći sadržaj koji može biti u suprotnosti sa vašim vjerskim, moralnim i drugim načelima i uvjerenjima. Svaki korisnik prije pisanja komentara mora se upoznati sa [uslovima korištenja](https://tuzlanski.ba).")
                    .font(Font(UIFont.Montserrat(.semibold, size: 12)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                
                if let replyToComment {
                    Text("Odgovarate na komentar".uppercased())
                        .font(Font(UIFont.Montserrat(.bold, size: 12)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    EmbeddedCommentView(comment: replyToComment)
                        .padding(.top, 8)
                }
                
                Text("Vaš komentar".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                
                TextEditor(text: $commentText)
                    .focused($focusedField, equals: .comment)
                    .lineLimit(4)
                    .tint(Color(UIColor.tintColor))
                    .font(Font(UIFont.Montserrat(.semibold, size: 15)))
                    .frame(minHeight: 90, maxHeight: 140)
                    .cornerRadius(12)
                    .shadow(radius: 1)
                    .padding(.top, 6)
                
                Text("\(commentText.count)/1000")
                    .font(Font(UIFont.Montserrat(.bold, size: 12)))
                    .foregroundStyle(commentText.count > 1000 ? Color.red : Color.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 6)
                
                Button(action: { onPostComment?(commentText.cleaned()) }) {
                    Text("POŠALJI KOMENTAR")
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
    }
}
