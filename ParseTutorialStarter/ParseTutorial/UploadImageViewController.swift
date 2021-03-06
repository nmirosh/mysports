/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

final class UploadImageViewController: UIViewController {
  
  // MARK: - Properties
  var username: String?
  
  // MARK: - IBOutlets
  @IBOutlet weak var imageToUpload: UIImageView!
  @IBOutlet weak var commentTextField: UITextField!
  @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
}

// MARK: - IBActions
extension UploadImageViewController {
  
  @IBAction func selectPicturePressed(_ sender: AnyObject) {
    // Open a UIImagePickerController to select the picture
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .photoLibrary
    present(imagePicker, animated: true)
  }
  
  @IBAction func sendPressed(_ sender: AnyObject) {
    commentTextField.resignFirstResponder()
    
    // Disable the send button until we are ready
    navigationItem.rightBarButtonItem?.isEnabled = false
    
    loadingSpinner.startAnimating()
    
    guard let uploadImage = imageToUpload.image,
      let pictureData = UIImagePNGRepresentation(uploadImage),
      let file = PFFile(name: "image", data: pictureData) else {
        return
    }
    
    file.saveInBackground({ [unowned self] succeeded, error in
      guard succeeded == true else {
        self.showErrorView(error)
        return
      }
      self.saveWallPost(file)
      }, progressBlock: { percent in
        print("Uploaded: \(percent)%")
    })
  }
}

// MARK: - Private
private extension UploadImageViewController {
  
  func saveWallPost(_ file: PFFile) {
    guard let currentUser = PFUser.current() else {
      return
    }
    
    let wallPost = WallPost(image: file, user: currentUser, comment: commentTextField.text)
    wallPost.saveInBackground { [unowned self] succeeded, error in
      if succeeded {
        _ = self.navigationController?.popViewController(animated: true)
      } else if let error = error {
        self.showErrorView(error)
      }
    }
  }
}

// MARK: - UINavigationControllerDelegate
extension UploadImageViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension UploadImageViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
    // Place the image in the imageview
    imageToUpload.image = image
    picker.dismiss(animated: true, completion: nil)
  }
}
