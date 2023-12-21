//
//  CommentReportViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 21. 12. 2023..
//

import UIKit
import SwiftUI
import AlertKit

class CommentReportViewController: UIViewController {
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    private let comment: Comment
    
    // MARK: - Lifecycle
    
    init(comment: Comment) {
        self.comment = comment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Prijava komentara"
        addCloseButton()
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .systemBackground
        
        var reportCommentView = ReportCommentView(comment: comment)
        
        reportCommentView.onSubmit = { [unowned self] reportType in
            Task {
                do {
                    _ = try await httpClient.report(comment: comment, reason: reportType)
                    await MainActor.run {
                        dismiss(animated: true) {
                            AlertKitAPI.present(
                                title: "Komentar prijavljen",
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                    }
                } catch {
                    print("Error while reporting a comment:", error)
                    present(UIAlertController.make(title: nil, message: "Dogodila se greška prilikom prijave komentara. Molimo pokušajte ponovo."), animated: true)
                }
            }
        }
        
        addSwiftUIView(reportCommentView)
    }
}

struct ReportCommentView: View {
    
    private var comment: Comment
    
    var onSubmit: ((CommentReportType) -> ())?
    
    @State private var reportType = CommentReportType.insult
    
    init (comment: Comment) {
        self.comment = comment
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Prijavljujete komentar".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 12)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                EmbeddedCommentView(comment: comment)
                    .padding(.top, 8)
                
                Text("Razlog".uppercased())
                    .font(Font(UIFont.Montserrat(.bold, size: 14)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                
                ForEach(CommentReportType.allCases, id: \.self) { type in
                    radioButtonItem(type: type)
                }
                
                Button(action: { onSubmit?(reportType) }) {
                    Text("PRIJAVI KOMENTAR")
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
    
    private func radioButtonItem(type: CommentReportType) -> some View {
            HStack {
                SelectionIndicator(isSelected: reportType == type)
                Text(type.name)
                    .font(Font(UIFont.Montserrat(.semibold, size: 14)))
                Spacer()
            }
            .padding(.top, 8)
            .onTapGesture {
                withAnimation { reportType = type }
            }
        }
}

