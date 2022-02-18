//
//  MockInterprets.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/27.
//

import Foundation

let mockUsecases: [Usecase] = [
    Usecase(
        sentence:"Did you really get my point?",
        choices: [
            "本当に私が言ってること分かった？",
            "本当に私の点数を奪ったの...？",
            "本当に私に点数を取らせてくれたの？"
    ]),
    Usecase(
        sentence:"Get this man a shield!",
        choices: [
            "彼に盾を与えてくれ！",
            "彼の盾を奪え！",
            "彼の盾が欲しい！"
    ]),
    Usecase(
        sentence:"Storm got the tomatoes.",
        choices: [
            "嵐でトマトがダメになった。",
            "嵐がトマトを運んできた。",
            "嵐のような量のトマトが取れた。"
    ])
]
