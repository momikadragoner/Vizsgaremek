import { Component, OnInit } from '@angular/core';
import { Product, tags, toProductShort, ProductShort, categories } from '../../services/product.service';
import { FormGroup, FormArray, FormBuilder, Validators, ValidatorFn, AbstractControl, ValidationErrors } from '@angular/forms';
import { faTruck, faBoxes, IconPrefix, faTree, faHandPaper, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faTrash, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt} from '@fortawesome/free-solid-svg-icons';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { asapScheduler } from 'rxjs';
import { JsonPipe } from '@angular/common';

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
  toProductShort = toProductShort;

  faTruck = faTruck;
  faBoxes = faBoxes;
  faTrash = faTrash;

  discountAvailable = false;
  submitted = false;
  
  productForm = this.fb.group({
    name: ['', Validators.required],
    price: [-1, [Validators.required, Validators.min(0)]],
    discount: [null, [Validators.max(99), Validators.min(1)]],
    inventory: [0],
    delivery: ['', Validators.required],
    category: ['', Validators.required],
    picrureUrl: [''],
    tags: this.fb.array([
    ]),
    materials: this.fb.array([
    ])
  });

  newProduct = new ProductShort (0, this.productForm.value.name, this.productForm.value.name, this.productForm.value.name, 
    this.productForm.value.price, this.productForm.value.imgUrl, undefined, this.productForm.value.discount 
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
    this.newProduct = new ProductShort (0, this.productForm.value.name, this.productForm.value.name, this.productForm.value.name, 
      this.productForm.value.price, this.productForm.value.imgUrl, undefined, this.productForm.value.discount 
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

  onSubmit() {
    this.submitted = true;
    console.log(JSON.stringify(this.productForm.value))
  }

  constructor( private fb: FormBuilder, library:FaIconLibrary) {
    library.addIcons(faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faCarrot, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt );
  }

  ngOnInit(): void {
  }

}
