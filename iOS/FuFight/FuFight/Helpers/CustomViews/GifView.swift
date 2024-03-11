//
//  GifView.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/7/24.
//

import SwiftUI
import UIKit
import FLAnimatedImage

enum URLType {
    /// local file name of gif
    case name(String)
    ///remote url
    case url(URL)

    var url: URL? {
        switch self {
        case .name(let name):
            return Bundle.main.url(forResource: name, withExtension: "gif")
        case .url(let remoteURL):
            return remoteURL
        }
    }
}

struct GIFView: UIViewRepresentable {
    private var type: URLType

    init(type: URLType) {
        self.type = type
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(activityIndicator)
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        activityIndicator.startAnimating()
        guard let url = type.url else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                let image = FLAnimatedImage(animatedGIFData: data)
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    imageView.animatedImage = image
                }
            }
        }
    }

    private let imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // UNCOMMENT TO ADD ROUNDING TO YOUR VIEW
        //      imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemBlue
        return activityIndicator
    }()
}
