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
    let realmManager = RealmManager()
    private let fileManager = FileManager.default
    private let backupDir:URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Realm", isDirectory: true)
    
    var labelDate:UILabel?
}

//MARK: - Func
extension CloudManager {
    func updateDate(_ label:UILabel) {
        labelDate = label
        label.text = fileDate()
    }
    //최신 백업날짜
    private func fileDate() -> String {
        guard let backupDir = backupDir else {
            //기본 백업폴더 없으면 만들기
            guard let url = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                return "iCloud 설정을 확인해주세요"
            }
            createDir(url.appendingPathComponent("Realm", isDirectory: true), { _ in
                return
            })
            return "백업된 데이터가 없습니다"
        }
        
        var list = loadFile(backupDir)
        list.sort(by: {$0 > $1})
        guard let recentlyDir = list.first else {
            return "백업된 데이터가 없습니다"
        }
        return "마지막 백업날짜: " + recentlyDir
    }
    //백업
    func backUpFile(_ vc:UIViewController) {
        guard let originRealm = realmManager.realmUrl else {
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
        guard let originRealm = realmManager.realmUrl, let backupDir = backupDir else {
            return
        }
        PopupManager.shared.openYesOrNo(vc, title: "백업파일 로드", msg: "가장 최신 파일로 로드하시겠습니까?\n(기존에 파일이 있던 경우 덮어쓰기 됩니다.)", completeYes: { _ in
            //가장 최근 백업 찾기
            var list = self.loadFile(backupDir)
            list.sort(by: {$0 > $1})
            self.copyToOriginDir(vc, sUrl: backupDir.appendingPathComponent(list.first!), dUrl: originRealm.deletingLastPathComponent())
        })
    }
    
    func deleteRealmFileAll() {
        guard let originRealm = realmManager.realmUrl, let backupDir = backupDir else {
            return
        }
        
        deleteDir(originRealm, nil)
        deleteDir(backupDir, nil)
    }
}

//MARK: - class 내부 메소드
extension CloudManager {
    //로컬 Realm -> iCloud Realm Backup Dir
    private func copyToRealmDir(_ vc:UIViewController, sUrl:URL, dUrl:URL) {
        let today = Date()
        let backupUrl = dUrl.appendingPathComponent("\(Utils.dateToString(today))")
        copyDir(sUrl, backupUrl, { error in
            print("copyToRealmDir Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "백업 실패", msg: "다시 시도해주세요")
        })
    }
    //iCloud Realm Backup Dir -> 로컬 Realm
    private func copyToOriginDir(_ vc:UIViewController, sUrl:URL, dUrl:URL) {
        //백업 폴더 임시 복사
        let tmpFoler = sUrl.deletingLastPathComponent().appendingPathComponent("tmp")
        copyDir(sUrl, tmpFoler, { error in
            print("copy To tmp Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
        })
        //replace
        let list = loadFile(sUrl)
        for file in list {
            let oldfile = dUrl.appendingPathComponent(file)
            let newfile = sUrl.appendingPathComponent(file)
            replaceFile(oldfile, newfile, {error in
                print("Replace Fail = \(error)")
                //replace 실패 시, 다시 폴더 돌려두기
                self.deleteDir(sUrl, {error in
                    print("Remove OriginDir Fail = \(error)")
                    self.moveFile(tmpFoler, sUrl, {error in
                        print("Rename Tmp Fail = \(error)")
                    })
                })
                PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
            })
        }
        //기존 폴더 없애고 tmp 폴더 이름 바꾸기
        deleteDir(sUrl, {error in
            print("Delete Origin Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
        })
        moveFile(tmpFoler, sUrl, {error in
            print("Rename Tmp Fail = \(error)")
            PopupManager.shared.openOkAlert(vc, title: "로드 실패", msg: "다시 시도해주세요")
        })
    }
    
    private func copyDir(_ sUrl:URL, _ dUrl:URL, _ handler:((Error)->Void)?) {
        do {
            try self.fileManager.copyItem(at: sUrl, to: dUrl)
        } catch {
            handler?(error)
        }
    }
    
    private func copyFile(_ sUrl:URL, _ dUrl:URL, _ handler:((Error)->Void)?) {
        do {
            try self.fileManager.copyItem(atPath: sUrl.path+"/", toPath: dUrl.path+"/")
        } catch {
            handler?(error)
        }
    }
    
    private func replaceFile(_ oldfile:URL, _ newfile:URL, _ handler:((Error)->Void)?) {
        do {
            let _ = try fileManager.replaceItemAt(oldfile, withItemAt: newfile, backupItemName: oldfile.lastPathComponent, options: .usingNewMetadataOnly)
        } catch {
            handler?(error)
        }
    }
    
    private func moveFile(_ sUrl:URL, _ dUrl:URL, _ handler:((Error)->Void)?) {
        do {
            try fileManager.moveItem(at: sUrl, to: dUrl)
        } catch {
            handler?(error)
        }
    }
    
    private func createDir(_ url:URL, _ handler:((Error)->Void)?) {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            print("만들어짐")
        } catch let error {
            handler?(error)
        }
    }
    
    private func deleteDir(_ url:URL, _ handler:((Error)->Void)?) {
        do {
            try fileManager.removeItem(at: url)
        } catch let error {
            handler?(error)
        }
    }
    
    private func loadFile(_ dir:URL) -> [String] {
        do {
            let list = try fileManager.contentsOfDirectory(atPath: dir.path)
            return list
        } catch let error {
            print("Load List Error = \(error)")
            return [String]()
        }
    }
    
    private func printDir(_ dir:URL, _ handler:((Error)->Void)?) {
        do {
            let list = try fileManager.contentsOfDirectory(atPath: dir.path)
            print(dir.path)
            for file in list {
                print(file)
            }
        } catch let error {
            handler?(error)
        }
    }
}
