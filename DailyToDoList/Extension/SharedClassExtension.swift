//
//  SharedClassExtension.swift
//  dailytimetable
//
//  Created by 소하 on 2022/08/19.
//


import Foundation

//MARK: - UserDefaults
extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = appGroupId
        return UserDefaults(suiteName: appGroupId)!
    }
}

//MARK: - FileAManger
extension FileManager {
    func copyFile(_ sUrl:URL, _ dUrl:URL, _ handler:((Error)->Void)?) {
        do {
            try copyItem(at: sUrl, to: dUrl)
        } catch {
            handler?(error)
        }
    }
    
    func copyDir(_ sUrl:URL, _ dUrl:URL, _ handler:((Error)->Void)?) {
        do {
            print("s = \(sUrl.path+"/")")
            print("d = \(dUrl.path+"/")")
            
            try copyItem(atPath: sUrl.path+"/", toPath: dUrl.path+"/")
        } catch {
            handler?(error)
        }
    }
    
    func replaceFile(_ oldfile:URL, _ newfile:URL, _ handler:((Error)->Void)?) {
        do {
            let _ = try replaceItemAt(oldfile, withItemAt: newfile, backupItemName: oldfile.lastPathComponent, options: .usingNewMetadataOnly)
        } catch {
            handler?(error)
        }
    }
    
    func moveFile(_ sUrl:URL, _ dUrl:URL, _ handler:((Error)->Void)?) {
        do {
            try moveItem(at: sUrl, to: dUrl)
        } catch {
            handler?(error)
        }
    }
    
    func createDir(_ url:URL, _ handler:((Error)->Void)?) {
        do {
            try createDirectory(at: url, withIntermediateDirectories: false)
        } catch let error {
            handler?(error)
        }
    }
    
    func deleteDir(_ url:URL, _ handler:((Error)->Void)?) {
        do {
            try removeItem(at: url)
        } catch let error {
            handler?(error)
        }
    }
    
    func loadFile(_ dir:URL) -> [String] {
        do {
            let list = try contentsOfDirectory(atPath: dir.path)
            return list
        } catch let error {
            print("Load List Error = \(error)")
            return [String]()
        }
    }
    
    func printDir(_ dir:URL, _ handler:((Error)->Void)?) {
        do {
            let list = try contentsOfDirectory(atPath: dir.path)
            print(dir.path)
            for file in list {
                print(file)
            }
        } catch let error {
            handler?(error)
        }
    }
}