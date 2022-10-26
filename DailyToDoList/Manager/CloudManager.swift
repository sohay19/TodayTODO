//
//  CloudManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/16.
//

import Foundation
import CloudKit
import UIKit
import SwiftUI

class CloudManager {
    private let fileManager = FileManager.default
    private let defaultDir:URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)
    private var backupDir:URL? {
        guard let defaultDir = defaultDir else {
            return nil
        }
        return defaultDir.appendingPathComponent("Realm", isDirectory: true)
    }
    var realmUrl:URL? {
        return RealmManager.shared.realmUrl
    }
    var labelDate:UILabel?
}

//MARK: - Display
extension CloudManager {
    //
    func updateDate(_ label:UILabel) {
        labelDate = label
        label.text = fileDate()
    }
    //최신 백업날짜
    private func fileDate() -> String {
        guard let defaultDir = defaultDir else {
            //기본 백업폴더 없으면 만들기
            return "iCloud Drive를 사용해주세요"
        }
        guard let backupDir = backupDir else {
            return "다시 시도 해주세요"
        }
        if !fileManager.fileExists(atPath: backupDir.path) {
            fileManager.createDir(defaultDir.appendingPathComponent("Realm", isDirectory: true), { error in
                print("Create Error = \(error)")
            })
        }
        var list = fileManager.loadFile(backupDir)
        list.sort(by: {$0 > $1})
        guard let recentlyDir = list.first else {
            return "백업된 데이터가 없습니다"
        }
        return "마지막 백업날짜: " + recentlyDir
    }
}

//MARK: - Backup, Load
extension CloudManager {
    //백업
    func backUpFile(_ vc:UIViewController) {
        guard let originRealm = realmUrl else {
            print("림 url 없음")
            return
        }
        guard let backupDir = backupDir else {
            PopupManager.shared.openOkAlert(vc, title: "알림", msg: "iCloud 설정을 확인해주세요")
            return
        }
        //copy
        copyToRealmDir(vc, sUrl: originRealm.deletingLastPathComponent(), dUrl: backupDir)
        //백업 날짜 업데이트
        guard let label = labelDate else {
            return
        }
        updateDate(label)
    }
    //최신파일 로드
    func loadBackupFile(_ vc:UIViewController) {
        guard let originRealm = realmUrl, let backupDir = backupDir else {
            return
        }
        PopupManager.shared.openYesOrNo(vc, title: "백업파일 로드", msg: "가장 최신 파일로 로드하시겠습니까?\n(기존에 파일이 있던 경우 덮어쓰기 됩니다.)", completeYes: { _ in
            //가장 최근 백업 찾기
            var list = self.fileManager.loadFile(backupDir)
            list.sort(by: {$0 > $1})
            self.copyToOriginDir(vc, sUrl: backupDir.appendingPathComponent(list.first!), dUrl: originRealm.deletingLastPathComponent())
        })
    }
    //백업 파일 삭제
    func deleteBackupFile() {
        guard let backupDir = backupDir else {
            return
        }
        fileManager.deleteDir(backupDir, nil)
    }
}

//MARK: - class 내부 메소드
extension CloudManager {
    //로컬 Realm -> iCloud Realm Backup Dir
    private func copyToRealmDir(_ vc:UIViewController, sUrl:URL, dUrl:URL) {
        let today = Date()
        let backupUrl = dUrl.appendingPathComponent("\(Utils.dateToString(today))")
        fileManager.copyDir(sUrl, backupUrl, { error in
            print("copyToRealmDir Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "백업 실패", msg: "다시 시도해주세요")
        })
    }
    //iCloud Realm Backup Dir -> 로컬 Realm
    private func copyToOriginDir(_ vc:UIViewController, sUrl:URL, dUrl:URL) {
        //백업 폴더 임시 복사
        let tmpFoler = sUrl.deletingLastPathComponent().appendingPathComponent("tmp")
        fileManager.copyDir(sUrl, tmpFoler, { error in
            print("copy To tmp Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
        })
        //replace
        let list = fileManager.loadFile(sUrl)
        for file in list {
            let oldfile = dUrl.appendingPathComponent(file)
            let newfile = sUrl.appendingPathComponent(file)
            fileManager.replaceFile(oldfile, newfile, {error in
                print("Replace Fail = \(error)")
                //replace 실패 시, 다시 폴더 돌려두기
                self.fileManager.deleteDir(sUrl, {error in
                    print("Remove OriginDir Fail = \(error)")
                    self.fileManager.moveFile(tmpFoler, sUrl, {error in
                        print("Rename Tmp Fail = \(error)")
                    })
                })
                PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
            })
        }
        //기존 폴더 없애고 tmp 폴더 이름 바꾸기
        fileManager.deleteDir(sUrl, {error in
            print("Delete Origin Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
        })
        fileManager.moveFile(tmpFoler, sUrl, {error in
            print("Rename Tmp Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
        })
    }
}
