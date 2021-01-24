//
//  ContentView.swift
//  WhatisThat?
//
//  Created by João Victor Ipirajá de Alencar on 18/01/21.
//

import SwiftUI
import CoreML
import Vision
import Social




struct ContentView: View {
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var result:String = ""
    
    var body: some View {
        
        VStack{
            
            ZStack{
                
             
                Circle().frame(minWidth: 200, maxWidth: 500, minHeight: 200, maxHeight: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                if let img = image{
                    img.resizable().frame(minWidth: 200, maxWidth: 500, minHeight: 200, maxHeight: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).clipShape(Circle())
                }else{
                    Image(systemName: "photo").resizable().frame(width: 50, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).foregroundColor(.white)
                }
              
          
            }.padding().onTapGesture {
                self.showingImagePicker = true
            }
            
            Text(result).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding()
            
        }.padding().sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        
        
    }
    
    
    func loadImage(){
        
        guard let inputImage = inputImage else {return}
        
        guard let ciImage = CIImage(image: inputImage) else {
            fatalError("couldn't convert uiimage to CIImage")
        }
        
        image = Image(uiImage: inputImage)
        
        recognizeImage(image: ciImage)
        
    }
    
    func recognizeImage(image: CIImage) {

        result = "I'm investigating..."

            if let model = try? VNCoreMLModel(for: Inceptionv3().model) {
                let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
                    if let results = vnrequest.results as? [VNClassificationObservation] {
                        let topResult = results.first
                        DispatchQueue.main.async {
                            let confidenceRate = (topResult?.confidence)! * 100
                            let rounded = Int (confidenceRate * 100) / 100
                
                            result = "It have a \(rounded)% chance of being a \(topResult?.identifier ?? "Anonymous")"
                        }
                    }
                })
                let handler = VNImageRequestHandler(ciImage: image)
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try handler.perform([request])
                    } catch {
                        print("Err :(")
                    }
                }
            }
        }
   
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
