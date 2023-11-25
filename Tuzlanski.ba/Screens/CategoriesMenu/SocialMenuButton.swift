//
//  SocialMenuButton.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 11. 2023..
//

import SwiftUI

enum SocialNetwork {
    case facebook
    case instagram
    case youtube
    case x
    
    var image: String {
        switch self {
        case .facebook:
            return "facebook"
        case .instagram:
            return "instagram"
        case .youtube:
            return "youtube"
        case .x:
            return "x"
        }
    }
    
    var url: URL {
        switch self {
        case .facebook:
            return URL(string: "https://www.facebook.com/Tuzlanski.ba")!
        case .instagram:
            return URL(string: "https://www.instagram.com/tuzlanski.ba")!
        case .youtube:
            return URL(string: "https://www.youtube.com/@TuzlaGradTuzlanski")!
        case .x:
            return URL(string: "https://x.com/tuzlanski")!
        }
    }
}

struct SocialMenuButton: View {
    
    var socialNetwork: SocialNetwork
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(socialNetwork.url)
        }, label: {
            Image(socialNetwork.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .tint(.white.opacity(0.8))
        })
    }
}
