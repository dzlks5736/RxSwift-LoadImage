//
//  ViewController.swift
//  RxSwift_LoadImage
//
//  Created by SIU on 2021/03/15.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    var count: Int = 0
    let imageUrl = "https://picsum.photos/1280/720/?random"
    
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.count += 1
            self.countLabel.text = "\(self.count)"
        }
        
    }
    
    @IBAction func load(_ sender: Any) {
                
        imageView.image = nil
        
        _ = rxswiftLoadImage(from: imageUrl)
            .observe(on: MainScheduler.instance)
            .subscribe({ result in
                switch result {
                case let .next(image):
                    self.imageView.image = image
                    
                case let .error(err):
                    print(err.localizedDescription)
                    
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        disposeBag = DisposeBag()
    }
    
    func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> {
        
        return Observable.create { seal in
            asyncLoadImage(from: imageUrl) { image in
                seal.onNext(image)
                seal.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}

func syncLoadImage(from imageUrl: String) -> UIImage? {
    
    guard let url = URL(string: imageUrl) else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }
    
    let image = UIImage(data: data)
    return image
    
}

func asyncLoadImage(from imageUrl: String, completed: @escaping (UIImage?) -> Void) {
    
    DispatchQueue.global().async {
        let image = syncLoadImage(from: imageUrl)
        completed(image)
    }
    
}
