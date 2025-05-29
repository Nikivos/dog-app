import SwiftUI
import PhotosUI

struct AddDogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataController: DataController
    
    @State private var name = ""
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var weight = ""
    @State private var healthNotes = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImageSizeAlert = false
    @State private var showingWeightAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("add.dog.photo")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                if data.count > 5 * 1024 * 1024 { // 5MB limit
                                    showingImageSizeAlert = true
                                    selectedImageData = nil
                                } else {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("add.dog.basic.info")) {
                    TextField("add.dog.name", text: $name)
                    TextField("add.dog.breed", text: $breed)
                    DatePicker("add.dog.birth.date", selection: $birthDate, displayedComponents: .date)
                    TextField("add.dog.weight", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("add.dog.health.notes")) {
                    TextEditor(text: $healthNotes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("add.dog.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveDog()
                    }
                    .disabled(name.isEmpty || breed.isEmpty || weight.isEmpty)
                }
            }
            .alert("error", isPresented: $showingImageSizeAlert) {
                Button("ok", role: .cancel) { }
            } message: {
                Text("add.dog.error.image.size")
            }
            .alert("error", isPresented: $showingWeightAlert) {
                Button("ok", role: .cancel) { }
            } message: {
                Text("add.dog.error.weight")
            }
        }
    }
    
    private func saveDog() {
        guard let weightValue = Double(weight), weightValue > 0, weightValue <= 200 else {
            showingWeightAlert = true
            return
        }
        
        dataController.addDog(
            name: name,
            breed: breed,
            birthDate: birthDate,
            weight: weightValue,
            healthNotes: healthNotes,
            image: selectedImageData
        )
        
        dismiss()
    }
}

struct EditDogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let dog: Dog
    
    @State private var name: String
    @State private var breed: String
    @State private var birthDate: Date
    @State private var weight: String
    @State private var healthNotes: String
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImageSizeAlert = false
    @State private var showingWeightAlert = false
    
    init(dog: Dog) {
        self.dog = dog
        _name = State(initialValue: dog.name ?? "")
        _breed = State(initialValue: dog.breed ?? "")
        _birthDate = State(initialValue: dog.birthDate ?? Date())
        _weight = State(initialValue: String(dog.weight))
        _healthNotes = State(initialValue: dog.healthNotes ?? "")
        _selectedImageData = State(initialValue: dog.image)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("add.dog.photo")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let imageData = selectedImageData ?? dog.image,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                if data.count > 5 * 1024 * 1024 { // 5MB limit
                                    showingImageSizeAlert = true
                                    selectedImageData = nil
                                } else {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("add.dog.basic.info")) {
                    TextField("add.dog.name", text: $name)
                    TextField("add.dog.breed", text: $breed)
                    DatePicker("add.dog.birth.date", selection: $birthDate, displayedComponents: .date)
                    TextField("add.dog.weight", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("add.dog.health.notes")) {
                    TextEditor(text: $healthNotes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit \(dog.name ?? "Dog")")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        updateDog()
                    }
                    .disabled(name.isEmpty || breed.isEmpty || weight.isEmpty)
                }
            }
            .alert("error", isPresented: $showingImageSizeAlert) {
                Button("ok", role: .cancel) { }
            } message: {
                Text("add.dog.error.image.size")
            }
            .alert("error", isPresented: $showingWeightAlert) {
                Button("ok", role: .cancel) { }
            } message: {
                Text("add.dog.error.weight")
            }
        }
    }
    
    private func updateDog() {
        guard let weightValue = Double(weight), weightValue > 0, weightValue <= 200 else {
            showingWeightAlert = true
            return
        }
        
        dog.name = name
        dog.breed = breed
        dog.birthDate = birthDate
        dog.weight = weightValue
        dog.healthNotes = healthNotes
        if let newImageData = selectedImageData {
            dog.image = newImageData
        }
        
        try? viewContext.save()
        dismiss()
    }
} 