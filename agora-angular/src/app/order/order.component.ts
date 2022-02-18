import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { Address, AddressService } from '../services/address.service';
import { Auth } from '../services/auth';

@Component({
  selector: 'app-order',
  templateUrl: './order.component.html',
  styleUrls: ['./order.component.scss']
})
export class OrderComponent implements OnInit {

  currentUser:Auth = Auth.currentUser;

  constructor(
    private fb: FormBuilder,
    private addressService:AddressService
  ) { }

  ngOnInit(): void {
  }

  addressForm = this.fb.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    email: ['', Validators.required],
    phone: [null],
    addressName: [''],
    country: ['', Validators.required],
    postalCode: [null, Validators.required],
    region: ['', Validators.required],
    city: ['', Validators.required],
    streetAddress: ['', Validators.required],
  });

  onSubmit() {
    let form = this.addressForm.value;
    let shippingAddress: Address = {
      addressId: 0,
      userId: this.currentUser.userId,
      userFirstName: form.firstName,
      userLastName: form.lastName,
      phone: form.phone,
      email: form.email,
      addressname: '',
      country: form.country,
      postalCode: form.postalCode,
      region: form.region,
      city: form.city,
      streetAddress: form.streetAddress
    };
    this.addressService.postAddress(shippingAddress).subscribe();
  }

}
