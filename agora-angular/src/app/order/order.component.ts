import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';

@Component({
  selector: 'app-order',
  templateUrl: './order.component.html',
  styleUrls: ['./order.component.scss']
})
export class OrderComponent implements OnInit {

  constructor(
    private fb: FormBuilder
  ) { }

  ngOnInit(): void {
  }

  addressForm = this.fb.group({
    name: [''],
    phone: [''],
    country: ['', Validators.required],
    postalCode:[null, Validators.required],
    region:['', Validators.required],
    city:['', Validators.required],
    streetAddress:['', Validators.required],
  });

  onSubmit() {

  }

}
