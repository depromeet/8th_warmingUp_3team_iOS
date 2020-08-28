//
//  WriteViewModel.swift
//  warmingUpProject_3
//
//  Created by 이규현 on 2020/08/18.
//  Copyright © 2020 team3. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class WriteViewModel: BaseViewModel {
    
    var selColor = "NAVY"
    
    var model = PostModel(title: "", colorType: "NAVY", lat: 0, log: 0, phrase: "", reason: "", time: "", author: "", description: "", thumbnail: "", pubDate: "", publisher: "", tags: [], userID: 1)
    
    
    let success = Observable.of(["NAVY","GRAY", "MINT", "PINK", "LEMON","BLUE","ORANGE","BROWN","GREEN","IVORY","PURPLE","RED","PEACH","BLACK"])
    
    let suggest = Observable.of(["촉촉한 새벽","새로운 아침", "나른한 낯 시간", "빛나는 오후", "별 헤는 밤"])
    
    let tag = Observable.of(["#따뜻한","#유쾌한", "#가벼운", "#무거운", "#묘한", "#몽환적인", "#쓸쓸한", "#강렬한", "#사랑스러운", "#희망적인", "#철학적인", "#여운", "#사색", "#재해석", "#명작"])
    
    let adderData = PublishSubject<[Address]>()
    
    func actionLocationView() {
        let writeViewModel = WriteViewModel(scenCoordinator: self.scenCoordinator)
        let searchVC = Scene.search(writeViewModel)
        self.scenCoordinator.transition(to: searchVC, using: .push, animated: true)
    }
    
    
    func actionSave(completion: @escaping () -> Void) {
        provider.rx.request(.writeBook(model: model))
            .subscribe(onSuccess: { (res) in
                print(self.model)
                print(res)
                
                completion()
                
            }) { (err) in
                
                
                print(err)
        }
        .disposed(by: rx.disposeBag)
        
    }
}
