import { Component, OnInit } from '@angular/core';
import { Product, tags } from '../../model/product';
import { FormGroup, FormArray, FormBuilder, Validators } from '@angular/forms';
import { faTruck, faBoxes} from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-product-form',
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss']
})
export class ProductFormComponent implements OnInit {

  public newProduct = new Product(1,"", "" ,0,false,0,'Azonnal szállítható','',[''],[''],'',false);
  tagsList = tags;

  faTruck = faTruck;
  faBoxes = faBoxes;

  submitted = false;

  productForm = this.fb.group({
    name: [this.newProduct.name, Validators.required],
    price: [this.newProduct.price],
    id: [this.newProduct.price],
    discountAvailable: [this.newProduct.discountAvailable],
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

  constructor( private fb: FormBuilder) { }

  ngOnInit(): void {
  }

}
