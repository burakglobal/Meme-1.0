//
//  MemeEditorViewController.swift
//  Meme1
//
//  Created by BURAK KEBAPCI on 2/19/17.
//  Copyright © 2017 BURAK KEBAPCI. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    
    var memes: [Meme]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    configureTextFields(textField: topText, defaultString: "TOP")
    configureTextFields(textField: bottomText, defaultString: "BOTTOM")
       
    shareButton.isEnabled = false
    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)

    }
     
            
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
         //MARK:cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
         subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
        view.frame.origin.y =  -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = image
            topText.isEnabled = true
            bottomText.isEnabled = true
            pickButton.isEnabled = false
            cameraButton.isEnabled  = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func topTextBeginEditing(_ sender: Any) {
        if topText.text=="TOP"{ topText.text = "" }
    }
    
    @IBAction func topTextEditingChanged(_ sender: Any) {
        topText.text = topText.text?.uppercased()
     
        if (topText.text?.characters.count)!>0 && (imagePickerView.image != nil)
        {
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
        }
        else{
            shareButton.isEnabled = false
            cancelButton.isEnabled = false
            
        }
    }
    
    @IBAction func bottomTextEditingChanged(_ sender: Any) {
        bottomText.text = bottomText.text?.uppercased()
        
        if (bottomText.text?.characters.count)!>0 && (imagePickerView.image != nil)
        {
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
        }
        else{
            shareButton.isEnabled = false
            cancelButton.isEnabled = false
            
        }
        
    }
    
    @IBAction func bottomTextBeginEditing(_ sender: Any) {
        if bottomText.text=="BOTTOM"{ bottomText.text = "" }
    }
    
    func pickImage(sourceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        pickImage(sourceType: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickImage(sourceType: UIImagePickerControllerSourceType.camera)
    }
    
    func generateMemedImage() -> UIImage {
        navBar.isHidden = true
        toolbar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        navBar.isHidden = false
        toolbar.isHidden = false
        return memedImage
    }

    func saveMeme(){
        _ = Meme(topText:topText.text!, bottomText:bottomText.text!, originalImage:imagePickerView.image!, memedImage:generateMemedImage())
    }
    
    func configureTextFields(textField: UITextField, defaultString: String) {
        //MARK: code to set-up the textField
        let memeTextAttributes:[String:Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
            NSStrokeWidthAttributeName: -3]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.isEnabled = false
        textField.text = defaultString
        
        view.bringSubview(toFront: textField)
    }
    
    @IBAction func navShareButton(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // setting up dismissal of the activity view once the meme is successfully shared:
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            if (success) {
                self.dismiss(animated: true, completion: nil)
                self.reset()
            }
        }
        present(activityViewController, animated: true, completion: saveMeme)
    }
    
    @IBAction func navCancelButton(_ sender: Any) {
       reset()
    }
    
    func reset(){
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePickerView.image = nil
        topText.isEnabled = false
        bottomText.isEnabled = false
        pickButton.isEnabled = true
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        view.bringSubview(toFront: topText)
        view.bringSubview(toFront: bottomText)
    }
}

