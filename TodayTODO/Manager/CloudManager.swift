//
//  CloudManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/16.
//

import Foundation
import CloudKit
import UIKit

class CloudManager {
    private let fileManager = FileManager.default
    private let defaultDir:URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)
    private var backupDir:URL? {
        guard let defaultDir = defaultDir else {
            return nil
        }
        return defaultDir.appendingPathComponent("Realm", isDirectory: true)
    }
    var realmUrl:URL?
    var labelDate:UILabel?
}

//MARK: - Display
extension CloudManager {
    //
    func getAllBackupFile() -> [(String, URL)] {
        guard let backupDir = backupDir else {
            return []
        }
        var fileList = fileManager.loadFile(backupDir)
        fileList.sort(by: { $0 > $1 })
        return fileList.map{($0, backupDir.appendingPathComponent($0))}
    }
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
        let dateList = recentlyDir.components(separatedBy: ["-", "_"])
        return "\(dateList[0])년 \(dateList[1])월 \(dateList[2])일 \(dateList[3])"
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
        let fileList = fileManager.loadFile(backupDir).sorted(by: {$0 < $1})
        if fileList.count >= 10 {
            deleteBackupFile(backupDir.appendingPathComponent(fileList.first!))
        }
        copyToRealmDir(vc, sUrl: originRealm.deletingLastPathComponent(), dUrl: backupDir)
        //백업 날짜 업데이트
        guard let label = labelDate else {
            return
        }
        updateDate(label)
        PopupManager.shared.openOkAlert(vc, title: "알림", msg: "백업이 완료되었습니다")
    }
    //파일 로드
    func loadBackupFile(_ vc:UIViewController, _ url:URL) {
        guard let originRealm = realmUrl else {
            return
        }
        copyToOriginDir(vc, sUrl: url, dUrl: originRealm.deletingLastPathComponent())
        SystemManager.shared.closeLoading()
        //
        PopupManager.shared.openOkAlert(vc, title: "알림", msg: "적용을 위해 앱을 재시작 해야합니다", complete: { _ in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                exit(0)
            }
        })
    }
    //백업 폴더 선택 삭제
    func deleteBackupFile(_ url:URL) {
        fileManager.deleteDir(url, nil)
    }
    //백업 파일 전부 삭제
    func deleteAllBackupFile() {
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
