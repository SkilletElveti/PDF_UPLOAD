//
//  ViewController.swift
//  PDF_Upload
//
//  Created by Shubham Vinod Kamdi on 18/07/20.
//  Copyright © 2020 Persausive Tech. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MobileCoreServices

class ViewController: UIViewController {

    let token = "YOUR_SERVER_ACCESS_TOKEN"
    
    let strUrl = "YOUR_SERVER_URL"
    
    @IBOutlet weak var docText: UITextField!
    @IBOutlet weak var browse: UIImageView!
    
    let VC_loader = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoaderViewController") as! LoaderViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        browse.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upload)))
        browse.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }

    @objc func upload(){
        
       let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
       importMenu.delegate = self
       importMenu.modalPresentationStyle = .formSheet
       self.present(importMenu, animated: true, completion: nil)
        
    }
    
    func Doc(url: String, docData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil, fileName: String, token : String!){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33){
            
            self.present(self.VC_loader, animated: false)
        }
         let headers: HTTPHeaders = [
             "Content-type": "multipart/form-data",
             "Token": "Bearer " + token
         ]
         
         print("Headers => \(headers)")
         
         print("Server Url => \(url)")
         
    //  Alamofire.upload(multipartFormData: <#T##(MultipartFormData) -> Void#>, to: <#T##URLConvertible#>, encodingCompletion: <#T##((SessionManager.MultipartFormDataEncodingResult) -> Void)?##((SessionManager.MultipartFormDataEncodingResult) -> Void)?##(SessionManager.MultipartFormDataEncodingResult) -> Void#>)
      
         Alamofire.upload(multipartFormData: { (multipartFormData) in
             if let data = docData{
                 multipartFormData.append(data, withName: "club_file", fileName: fileName, mimeType: "application/pdf")
             }
             
             for (key, value) in parameters {
                 multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
              print("PARAMS => \(multipartFormData)")
             }
             
         }, to: url, method: .post, headers: headers) { (result) in
             switch result{
             case .success(let upload, _, _):
                 upload.responseJSON { response in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.33){
                        self.VC_loader.dismiss(animated: false, completion: nil)
                    }
                    
                     print("Succesfully uploaded")
                     if let err = response.error{
                         onError?(err)
                         return
                     }
                     print(JSON(response.result.value as Any))
                     onCompletion?(JSON(response.result.value as Any))
                 }
             case .failure(let error):
                 print("Error in upload: \(error.localizedDescription)")
                 onError?(error)
             }
         }
     }

}



@IBDesignable
class CardView: UIView {
    
    @IBInspectable var CornerRadiusCard: CGFloat = 5
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.9
    
    override func layoutSubviews() {
        layer.cornerRadius = CornerRadiusCard
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CornerRadiusCard)
        layer.masksToBounds = false
        //layer.borderColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0).cgColor
        //layer.borderWidth = 1
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    func RoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    
}


extension ViewController: UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        let data = NSData(contentsOf: myURL)
        do{
           
            
            
            self.Doc(url: strUrl, docData: try Data(contentsOf: myURL), parameters: ["club_file": "file" as AnyObject], fileName: myURL.lastPathComponent, token: token)
            self.docText.text = myURL.lastPathComponent
            
            //uploadActionDocument(documentURLs: myURL, pdfName: myURL.lastPathComponent)
        }catch{
            print(error)
        }
        
        
        
    }


    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        
        
       // dismiss(animated: true, completion: nil)
        
    }
}
