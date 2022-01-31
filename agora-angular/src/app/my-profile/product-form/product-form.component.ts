import { Component, OnInit } from '@angular/core';
import { Product, tags, ProductShort, categories, ProductService } from '../../services/product.service';
import { FormGroup, FormArray, FormBuilder, Validators, ValidatorFn, AbstractControl, ValidationErrors } from '@angular/forms';
import { faTruck, faBoxes, IconPrefix, faTree, faHandPaper, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faTrash, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt, faInfoCircle} from '@fortawesome/free-solid-svg-icons';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { asapScheduler, fromEventPattern } from 'rxjs';
import { JsonPipe } from '@angular/common';
import { ThrowStmt } from '@angular/compiler';
import { Auth } from 'src/app/services/auth';

@Component({
  selector: 'app-product-form',
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss']
})
export class ProductFormComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  //newProduct: Product = {productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1};
  tagsList = tags;
  categories = categories;
  currentUser = Auth.currentUser;

  faTruck = faTruck;
  faBoxes = faBoxes;
  faTrash = faTrash;
  faInfoCircle = faInfoCircle;

  discountAvailable = false;
  submitted = false;
  toolTipOpen:boolean[] = [];
  products:Product[] = [];

  constructor( 
    private fb: FormBuilder, 
    private productService: ProductService, 
    library:FaIconLibrary, 
  ) 
  {
    library.addIcons(faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faCarrot, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt );
  }
  
  productForm = this.fb.group({
    name: ['', Validators.required],
    price: [null, [Validators.required, Validators.min(0)]],
    discount: [null, [Validators.max(99), Validators.min(1)]],
    inventory: [null],
    delivery: ['', Validators.required],
    category: ['', Validators.required],
    pictureUrl: [''],
    tags: this.fb.array([
    ]),
    materials: this.fb.array([
    ]),
    description: ['']
  });

  newProduct = new ProductShort (0, this.productForm.value.name, '', '', 
    this.productForm.value.price, this.productForm.value.imgUrl, undefined, undefined, this.productForm.value.discount 
  );
    
  addTag() {
    this.tags.push(this.fb.control(''));
  }
  
  removeTag(id:any, $event:any){
    $event.preventDefault();
    this.tags.removeAt(id);
  }
  
  addMaterial() {
    this.materials.push(this.fb.control(''));
  }

  removeMaterial(id:any, $event:any){
    $event.preventDefault();
    this.materials.removeAt(id);
  }

  get tags() {
    return this.productForm.get('tags') as FormArray;
  }

  get materials() {
    return this.productForm.get('materials') as FormArray;
  }

  inputChange(){
    this.newProduct = new ProductShort (0, this.productForm.value.name, this.currentUser.firstName, this.currentUser.lastName, 
      this.productForm.value.price, this.productForm.value.imgUrl, undefined, undefined,  this.productForm.value.discount 
    );
  }

  getMaterials(){
    let materialLabel:string = "";
    this.productForm.value.materials.forEach((material: string) => {
      materialLabel += material;
      if(this.productForm.value.materials[this.productForm.value.materials.length - 1] != material) materialLabel += ", ";
    });
    return materialLabel;
  }

  discountChange(){
    this.discountAvailable = !this.discountAvailable;
    let update = this.productForm.value;
    update.discount = null;
    this.productForm.setValue(update);
  }

  tagOptions:string[] = [
    "Környezetbarát",
    "Kézzel készült",
    "Etikusan beszerzett alapanyagok",
    "Fenntartható",
    "Csomagolás mentes",
    "Vegetáriánus",
    "Vegán",
    "Bio"
  ];

  tagsShown:string[] = [];

  searchTag(id:number){
    if(this.productForm.value.tags[id] == "") this.tagsShown = [...this.tagOptions];
    let result: string[] = [];
    this.tagOptions.forEach((option)=>{
      let regex = new RegExp(this.productForm.value.tags[id].trim(), "i");
      // let regex = new RegExp(/this.productForm.value.tags[id]/);
      if (option.match(regex)) {
        result.push(option);
      }
    })
    //console.log(result);
    this.tagsShown = result;
  }

  autoFillTag(id:number, option:number){
    let update = this.productForm.value;
    update.tags[id] = this.tagsShown[option];
    this.productForm.setValue(update);
    this.onTagFocusChange(id);
  }

  tagOpen:boolean[] = [];

  onTagFocusChange(id:number){
    this.tagOpen[id] = !this.tagOpen[id];
  }

  deliveryChange(){
    if (this.productForm.value.delivery == "Megrendelésre készül") {
      let update = this.productForm.value;
      update.inventory = null;
      this.productForm.setValue(update);
    }
  }

  postProduct(isPublic:boolean){
    let form = this.productForm.value;
    let newProduct:Product = 
    { 
      productId: 0, 
      name: form.name, 
      price: form.price, 
      inventory: form.inventory, 
      delivery: form.delivery, 
      category: form.category,
      sellerFirstName: this.currentUser.firstName,
      sellerLastName: this.currentUser.lastName,
      sellerId: this.currentUser.userId,
      materials: form.materials,
      tags: form.tags,
      imgUrl: form.pictureUrl,
      description: form.description,
      isPublic: isPublic
    }
    this.productService
      .addProduct(newProduct)
      .subscribe(product => this.products.push(product));
    console.log(newProduct);
  }

  onSubmit() {
    this.submitted = true;
    this.postProduct(true);
    //console.log(JSON.stringify(this.productForm.value))
  }

  ngOnInit(): void {
  }

}
