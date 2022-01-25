import { Component, OnInit } from '@angular/core';
import { Product, tags, toProductShort, ProductShort } from '../../services/product.service';
import { FormGroup, FormArray, FormBuilder, Validators } from '@angular/forms';
import { faTruck, faBoxes, IconPrefix, faTree, faHandPaper, faBalanceScale} from '@fortawesome/free-solid-svg-icons';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { asapScheduler } from 'rxjs';

@Component({
  selector: 'app-product-form',
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss']
})
export class ProductFormComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  //newProduct: Product = {productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1};
  tagsList = tags;
  toProductShort = toProductShort;

  faTruck = faTruck;
  faBoxes = faBoxes;
  
  discountAvailable = false;
  submitted = false;
  
  productForm = this.fb.group({
    name: ['', Validators.required],
    price: [-1],
    discount: [null],
    id: [0],
    inventory: [-1],
    delivery: [''],
    category: [''],
    picrureUrl: [''],
    tags: this.fb.array([
    ]),
    materials: this.fb.array([
    ])
  });

  asd = new ProductShort(0, this.productForm.value.name, this.productForm.value.name, this.productForm.value.name, 
    this.productForm.value.price, this.productForm.value.imgUrl, undefined, this.productForm.value.discount );

  get tags() {
    return this.productForm.get('tags') as FormArray;
  }

  addTag() {
    this.tags.push(this.fb.control(''));
  }

  get materials() {
    return this.productForm.get('materials') as FormArray;
  }

  
  getMaterials(){
    let materialLabel:string = "";
    this.productForm.value.materials.value.forEach((material: string) => {
      materialLabel += material;
      materialLabel += ", ";
    });
    return materialLabel;
  }

  addMaterial() {
    this.materials.push(this.fb.control(''));
  }

  onSubmit() {
    this.submitted = true;
  }

  constructor( private fb: FormBuilder, library:FaIconLibrary) {
    library.addIcons(faHandPaper, faTree, faBalanceScale);
  }

  ngOnInit(): void {
  }

}
