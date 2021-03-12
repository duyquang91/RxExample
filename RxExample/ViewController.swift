//
//  ViewController.swift
//  RxExample
//
//  Created by Steve Dao on 12/03/2021.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet private var sw: UISwitch!
    @IBOutlet private var btn: UIButton!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var activity: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "OnSubscribed\n"
        binding()
    }
    
    private func binding() {
        
        btn.rx
            .tap
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                guard let self = self else { return Observable.empty() }
                if self.sw.isOn {
                    return Observable<Int>.error(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error from network"])).do(onError: { [weak self] error in
                        self?.show(error: error)
                    })
                        .catch { _ in return Observable.empty() }
                } else {
                    return Observable.just(Int.random(in: 0...999))
                        .delay(.seconds(1), scheduler: MainScheduler.instance).do { [weak self] value in
                            self?.activity.stopAnimating()
                        } onError: { [weak self] _ in
                            self?.activity.stopAnimating()
                        } onCompleted: { [weak self] in
                            self?.activity.stopAnimating()
                        } onSubscribed: { [weak self] in
                            self?.activity.startAnimating()
                        } onDispose: { [weak self] in
                            self?.activity.stopAnimating()
                        }
                }
            }
            .subscribe(onNext: { [weak self] number in
                self?.textView.text += "OnNext: \(number)\n"
            }, onError: { [weak self] error in
                self?.textView.text += "OnError: \(error.localizedDescription)\n"
            }, onCompleted: { [weak self] in
                self?.textView.text += "OnCompleted\n"
            }, onDisposed: { [weak self] in
                self?.textView.text += "OnDisposed\n"
            })
            .disposed(by: disposeBag)
    }
    
    private func show(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

