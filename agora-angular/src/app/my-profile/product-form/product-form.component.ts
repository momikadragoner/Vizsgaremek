import { Component, OnInit } from '@angular/core';
import {Product} from './product';
import { FormGroup, FormArray, FormBuilder, Validators } from '@angular/forms';

@Component({
  selector: 'app-product-form',
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss']
})
export class ProductFormComponent implements OnInit {

  public model = new Product(1,"Nyaklánc", "Marika" ,1500,false,10,'Azonnal szállítható','Ékszerek',['környezetbarát'],['arany'],'item1.png');

  submitted = false;

  productForm = this.fb.group({
    name: [this.model.name, Validators.required],
    price: [this.model.price],
    id: [this.model.price],
    discountAvailable: [this.model.discountAvailable],
    inventory: [this.model.inventory],
    delivery: [this.model.delivery],
    category: [this.model.category],
    picrureUrl: [this.model.picrureUrl],
    tags: this.fb.array([
      this.fb.control('')
    ]),
    materilas: this.fb.array([
      this.fb.control('')
    ])
  });

  onSubmit() {
    this.submitted = true;
  }

  constructor( private fb: FormBuilder) { }

  ngOnInit(): void {
  }

}
