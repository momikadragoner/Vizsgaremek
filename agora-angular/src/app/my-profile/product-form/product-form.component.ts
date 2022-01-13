import { Component, OnInit } from '@angular/core';
import { Product, tags, toProductShort } from '../../services/product.service';
import { FormGroup, FormArray, FormBuilder, Validators } from '@angular/forms';
import { faTruck, faBoxes, IconPrefix, faTree, faHandPaper, faBalanceScale} from '@fortawesome/free-solid-svg-icons';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-product-form',
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss']
})
export class ProductFormComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  public newProduct: Product = {productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1};
  tagsList = tags;
  toProductShort = toProductShort;

  faTruck = faTruck;
  faBoxes = faBoxes;

  submitted = false;

  productForm = this.fb.group({
    name: [this.newProduct.name, Validators.required],
    price: [this.newProduct.price],
    id: [this.newProduct.price],
    //discountAvailable: [this.newProduct.discountAvailable],
    inventory: [this.newProduct.inventory],
    delivery: [this.newProduct.delivery],
    category: [this.newProduct.category],
    picrureUrl: [this.newProduct.imgUrl],
    tags: this.fb.array([
    ]),
    materials: this.fb.array([
    ])
  });

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
    this.materials.value.forEach((material: string) => {
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
