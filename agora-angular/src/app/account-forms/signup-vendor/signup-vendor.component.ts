import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-signup-vendor',
  templateUrl: './signup-vendor.component.html',
  styleUrls: ['./signup-vendor.component.scss']
})
export class SignupVendorComponent implements OnInit {

  profileForm = new FormGroup({
    firstName: new FormControl('', Validators.required),
    lastName: new FormControl('', Validators.required),
    email: new FormControl('', Validators.email),
    password: new FormControl('', [Validators.required, Validators.minLength(8)])
  });

  onSubmit(){

  }

  constructor() { }

  ngOnInit(): void {
  }

}
