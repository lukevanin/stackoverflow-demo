//
//  ImageLoader.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit
import Combine


final class URLImageView: UIView {
    
    var url: URL? {
        didSet {
            guard url != oldValue else {
                return
            }
            invalidateImage()
        }
    }
    
    override var contentMode: UIView.ContentMode {
        get {
            imageView.contentMode
        }
        set {
            imageView.contentMode = newValue
        }
    }
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    private var dataCancellable: AnyCancellable?
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
        super.init(frame: .zero)
        imageView.frame = bounds
        autoresizesSubviews = true
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func invalidateImage() {
        cancelLoading()
        imageView.image = nil
        loadImage()
    }
    
    private func cancelLoading() {
        dataCancellable?.cancel()
        dataCancellable = nil
    }
    
    private func loadImage() {
        guard let url = self.url else {
            return
        }
        dataCancellable = session
            .dataTaskPublisher(for: url)
            .map { data, response -> Data? in
                data
            }
            .catch { error in
                Just(nil)
            }
            .map { data -> UIImage? in
                data.flatMap { data in
                    UIImage(data: data)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else {
                    return
                }
                UIView.transition(
                    with: self,
                    duration: 0.2,
                    options: [.transitionCrossDissolve],
                    animations: {
                        self.imageView.image = image
                    },
                    completion: nil
                )
            }
    }
}
