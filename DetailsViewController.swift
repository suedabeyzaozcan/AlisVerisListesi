//
//  DetailsViewController.swift
//  AlisverisListesi
//
//  Created by Sueda Beyza Özcan on 25.07.2024.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var kaydetButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var isimTextField: UITextField!
    
    @IBOutlet weak var fiyatTextField: UITextField!
    
    @IBOutlet weak var bedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if secilenUrunIsmi != ""{
            kaydetButton.isHidden = true
            if let uuidString = secilenUrunUUID?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do {
                                let sonuclar = try context.fetch(fetchRequest)
                                if sonuclar.count > 0 {
                                    for sonuc in sonuclar as! [NSManagedObject] {
                                        if let isim = sonuc.value(forKey: "isim") as? String {
                                            isimTextField.text = isim
                                        }
                                        if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                            fiyatTextField.text = String(fiyat)
                                        }
                                        if let beden = sonuc.value(forKey: "beden") as? String {
                                            bedenTextField.text = beden
                                        }
                                        if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                            let image = UIImage(data: gorselData)
                                            imageView.image = image
                                        }
                                    }
                                }catch {
                                    print("Bir hata oluştu")
                    }
                }
            }
        }
            else {
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = true
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
        }
    //1.klavye kapatma kodu ////////////////////////////////////////////////////
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    //buttona baısınca ne olucak
    @objc func gorselSec() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary// galeri açılıyor
        picker.allowsEditing = true // edit yapılablir
        present(picker, animated: true,completion: nil)// completion bu işlem bitince napacaksın,'nil' hiç bir şey
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        imageView.image = info[.editedImage] as? UIImage //opsiyonel casting
        kaydetButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)//view controllerden açılan yeni pickercontroller'ı kapatıyor ve image view'e geri dön
    }
    //2.klavye kapatma kodu ////////////////////////////////////////////////////
    @objc func klavyeyiKapat(){
        view.endEditing(true)
    }
    @IBAction func kaydetButtonTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context =  appDelegate.persistentContainer.viewContext //
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)//core data ya ulaşmamızı sağlıyor
        alisveris.setValue(isimTextField.text!, forKey: "isim")
        
        alisveris.setValue(bedenTextField, forKey: "beden")
        
        if let fiyat = Int(fiyatTextField.text!){
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        //kaydet tanımlandı
        alisveris.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        //görsel seçilmeden kaydet buttonu etkin olması
        alisveris.setValue(data, forKey: "gorsel")
        do{
            try context.save()
            print("kayıt edildi")
        }catch{
            print("hata var")
        }
        // veri girildi mesajı verme
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Veri Girildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

