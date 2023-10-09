//
//  ImageFilterViewController.swift
//  ImageFilter
//
//  Includes events of 5 basic filters whose underlying content is hide by CoreImage, takePhoto function, custom filters which is realized by applying filter  chains and all the other events on the filter page.
//

import UIKit
import Photos
import OpenGLES
import MBProgressHUD

class ImageFilterViewController: UIViewController {
    
    private var originalImage : UIImage?
    private var pickerView : UIPickerView = UIPickerView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 100))
    private var dataSource : [String] = ["Auto","Mono","Transfer","Tonal","Noir","Instant"]
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var originImageView: UIImageView!
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    var filter: CIFilter!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.shadowOpacity = 0.8
        self.imageView.layer.shadowColor = UIColor.black.cgColor
        self.imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        buildPickerView()
        showAllBuiltinFilterAttributes()
    }
    private func buildPickerView(){
        pickerView.dataSource = self
        pickerView.selectRow(0,inComponent:0,animated:true)
        pickerView.delegate = self
        view.addSubview(pickerView)
    }
    private func showPickerView(){
        UIView.animate(withDuration: 1) {
            var minY : CGFloat = 0.0
            if self.pickerView.frame.minY == UIScreen.main.bounds.size.height{
                minY = UIScreen.main.bounds.size.height - 100
            }else{
                minY = UIScreen.main.bounds.size.height
            }
            self.pickerView.frame = CGRect(x: 0, y: minY, width: UIScreen.main.bounds.size.width, height: 100)
        }
    }
    @IBAction func savePhotoAction(_ sender: Any){
        guard let filterimage = self.imageView.image else{
            MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "There is no filter image.", animated: true)
            return
        }
        UIImageWriteToSavedPhotosAlbum(filterimage, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc private func saveImage(image : UIImage, didFinishSavingWithError error : NSError?,contextInfo:AnyObject){
        if error == nil{
            MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Saved Success", animated: true)
            print("Success")
        }
    }
    @IBAction func takePhotoAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            AVCaptureDevice.requestAccess(for: .video) { result in
                DispatchQueue.main.async {
                    if result == true {
                        self.presentCameraPickerController()
                    }else {
                        let alert = UIAlertController(title: "No access to take photo", message: "The permission of photo has been denied.", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Go to setting", style: .default, handler: { (goSettingAction) in
                            DispatchQueue.main.async {
                                let url = URL(string: UIApplication.openSettingsURLString)!
                                UIApplication.shared.open(url, options: [:])
                            }
                        })
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                        alert.addAction(confirmAction)
                        alert.addAction(cancelAction)
                    }
                }
                
            }
        }
    }
    //By adding multiple layers of filters to the image, a complete filter is obtained
    @IBAction func customImageFilter(_ sender: Any) {
        guard let originalImage = originalImage else {
            return
        }
        guard let inputImage = CIImage(image: originalImage) else{
            return
        }
        if let sepiaFilter = CIFilter(name: "CISepiaTone"),let whiteFilter = CIFilter(name: "CIColorMatrix"),let randomGeneratorImage = CIFilter(name: "CIRandomGenerator")?.outputImage?.cropped(to: inputImage.extent),let sourceOverImageFilter = CIFilter(name: "CISourceOverCompositing"),let affineTransformFilter = CIFilter(name: "CIAffineTransform"),let colorMatrix = CIFilter(name: "CIColorMatrix"),let minimumFilter = CIFilter(name: "CIMinimumComponent"),let multiplyFilter = CIFilter(name: "CIMultiplyCompositing"){
            sepiaFilter.setValue(inputImage, forKey: kCIInputImageKey)
            sepiaFilter.setValue(1, forKey: kCIInputIntensityKey)
            whiteFilter.setValue(randomGeneratorImage, forKey: kCIInputImageKey)
            whiteFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
            whiteFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
            whiteFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
            whiteFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
            sourceOverImageFilter.setValue(whiteFilter.outputImage, forKey: kCIInputBackgroundImageKey)
            sourceOverImageFilter.setValue(sepiaFilter.outputImage, forKey: kCIInputImageKey)
            affineTransformFilter.setValue(randomGeneratorImage, forKey: kCIInputImageKey)
            affineTransformFilter.setValue(NSValue(cgAffineTransform: CGAffineTransform(scaleX: 1.5, y: 25)), forKey: kCIInputTransformKey)
            colorMatrix.setValue(affineTransformFilter.outputImage, forKey: kCIInputImageKey)
            colorMatrix.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
            colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
            colorMatrix.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
            minimumFilter.setValue(colorMatrix.outputImage, forKey: kCIInputImageKey)
            multiplyFilter.setValue(minimumFilter.outputImage, forKey: kCIInputBackgroundImageKey)
            multiplyFilter.setValue(sourceOverImageFilter.outputImage, forKey: kCIInputImageKey)
            guard let outputImage = multiplyFilter.outputImage,let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {return}
            imageView.image = UIImage(cgImage: cgImage)
        }


    }
    @IBAction func selectImageAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.presentPhotoPickerController()
                    }
                case .notDetermined:
                    if status == PHAuthorizationStatus.authorized {
                        DispatchQueue.main.async {
                            self.presentPhotoPickerController()
                        }
                    }
                case .denied:
                    let alert = UIAlertController(title: "No access to get photo", message: "The permission of album has been denied.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Go to setting", style: .default, handler: { (goSettingAction) in
                        DispatchQueue.main.async {
                            let url = URL(string: UIApplication.openSettingsURLString)!
                            UIApplication.shared.open(url, options: [:])
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                case .restricted:
                    let alert = UIAlertController(title: "Permission restricted.", message: "The permission of album has been restricted.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                default: break
                }
            }
        }
    }
    @IBAction func clickAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goMoreComplexCustomImageFilterClick(_ sender: Any) {
        let vc = MoreComplexFilterController.init()
        vc.originalImage = originalImage
        self.present(vc, animated: true)
    }
}

extension ImageFilterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func presentCameraPickerController(){
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.delegate = self
        vc.sourceType = .camera
        self.present(vc, animated: true, completion: nil)
    }
    func presentPhotoPickerController() {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.delegate = self
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = image
            self.originImageView.image = image
            originalImage = image
            imageFilterAuto()
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            self.originImageView.image = image
            originalImage = image
            imageFilterAuto()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension ImageFilterViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let _ = originalImage else {
            return
        }
        switch row {
        case 0:
            imageFilterAuto()
        case 1:
            imageFilterMono()
        case 2:
            imageFilterTransfer()
        case 3:
            imageFilterTonal()
        case 4:
            imageFilterNoir()
        case 5:
            imageFilterInstant()
        default:
            print("other filter")
        }
    }
}
//Built-in image filter
extension ImageFilterViewController{
    func showAllBuiltinFilterAttributes() {
        let filters = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        for f in filters {
            let filter = CIFilter(name: f as String)
            if let attributes = filter?.attributes{
                print(attributes)
            }
        }
    }
    private func imageFilterAuto(){
        var inputImage = CIImage(image: originalImage!)!
        let filters = inputImage.autoAdjustmentFilters()
        for filter: CIFilter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage = filter.outputImage!
        }
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            self.imageView.image = UIImage(cgImage: cgImage)
        }
    }
    private func imageFilterMono(){
        filter = CIFilter(name: "CIPhotoEffectMono")
        outputAfterFilterImage()
    }
    private func imageFilterTransfer(){
        filter = CIFilter(name: "CIPhotoEffectTransfer")
        outputAfterFilterImage()
    }
    private func imageFilterTonal(){
        filter = CIFilter(name: "CIPhotoEffectTonal")
        outputAfterFilterImage()
    }
    private func imageFilterNoir(){
        filter = CIFilter(name: "CIPhotoEffectNoir")
        outputAfterFilterImage()
    }
    private func imageFilterInstant(){
        filter = CIFilter(name: "CIPhotoEffectInstant")
        outputAfterFilterImage()
    }
    func outputAfterFilterImage() {
        guard let originalImage = originalImage else {
            return
        }
        let inputImage = CIImage(image: originalImage)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        if let outputImage = filter.outputImage{
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                self.imageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
