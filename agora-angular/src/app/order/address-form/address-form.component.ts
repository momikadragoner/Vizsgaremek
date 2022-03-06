import { Component, EventEmitter, Input, OnChanges, OnInit, Output, SimpleChanges } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { faChevronLeft, faChevronRight, faSave, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { Address, AddressService } from 'src/app/services/address.service';
import { Auth } from 'src/app/services/auth';
import { User } from 'src/app/services/user.service';

@Component({
  selector: 'address-form',
  templateUrl: './address-form.component.html',
  styleUrls: ['./address-form.component.scss']
})
export class AddressFormComponent implements OnChanges {

  currentUser: Auth = Auth.currentUser;
  isLoading = false;
  @Input() userInfo:User = new User();
  @Input() selectedProfile?:Address = new Address();
  @Input() modalOpen:boolean = false;
  @Input() modalVersion:boolean = false;
  @Output() modalOpenChange = new EventEmitter<boolean>();
  @Output() addressOpenChange = new EventEmitter<boolean>();
  @Output() selectedAddressChange = new EventEmitter<Address>();


  faChevronLeft = faChevronLeft;
  faChevronRight = faChevronRight;
  faSpinner = faSpinner;
  faSave = faSave;

  constructor(
    private fb: FormBuilder,
    private addressService: AddressService,
    private router: Router,
  ) { }

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

  ngOnChanges(changes: SimpleChanges): void {
    if (this.userInfo != new User()) {
      let update = this.addressForm.value;
      update.firstName = this.userInfo.firstName;
      update.lastName = this.userInfo.lastName;
      update.email = this.userInfo.email;
      update.phone = this.userInfo.phone ? this.userInfo.phone : '';
      this.addressForm.setValue(update);
    }
    if (this.selectedProfile != new Address()) {
      let profil: Address = this.selectedProfile ? this.selectedProfile : new Address();
      let form = this.addressForm.value;
      form.firstName = profil.userFirstName;
      form.lastName = profil.userLastName;
      form.email = profil.email;
      form.phone = profil.phone ? profil.phone : '';
      form.addressName = profil.addressName;
      form.country = profil.country;
      form.postalCode = profil.postalCode;
      form.region = profil.region;
      form.city = profil.city;
      form.streetAddress = profil.streetAddress;
      this.addressForm.setValue(form);
    }
  }

  onSubmit() {
    this.modalOpen = true;
    this.modalOpenChange.emit(true);
    let form = this.addressForm.value;
    let shippingAddress: Address = {
      addressId: 0,
      userId: this.currentUser.userId,
      userFirstName: form.firstName,
      userLastName: form.lastName,
      phone: form.phone,
      email: form.email,
      addressName: '',
      country: form.country,
      postalCode: form.postalCode,
      region: form.region,
      city: form.city,
      streetAddress: form.streetAddress
    };
    let selectAdd: Address = this.selectedProfile ? this.selectedProfile : new Address();
    if (
      shippingAddress.userId == selectAdd.userId &&
      shippingAddress.userFirstName == selectAdd.userFirstName &&
      shippingAddress.userLastName == selectAdd.userLastName &&
      shippingAddress.phone == selectAdd.phone &&
      shippingAddress.email == selectAdd.email &&
      shippingAddress.country == selectAdd.country &&
      shippingAddress.postalCode == selectAdd.postalCode &&
      shippingAddress.region == selectAdd.region &&
      shippingAddress.city == selectAdd.city &&
      shippingAddress.streetAddress == selectAdd.streetAddress
    ) {
      shippingAddress = selectAdd;
    }
    this.addressService.postAddressToCart(shippingAddress).subscribe({
      next: data => { this.router.navigate(['/checkout']) }
    });
  }

  autoFillAddress() {
    if (this.addressForm.value.postalCode < 999) return;
    this.addressService.getCityByPostalCode(this.addressForm.value.postalCode)
      .subscribe({
        next: data => {
          if (data) {
            let update = this.addressForm.value;
            update.region = data.region;
            update.city = data.city;
            this.addressForm.setValue(update);
          }
        }
      })
  }

  backAddress($event:any){
    this.addressOpenChange.emit(false);
  }

  saveAddress($event:any){
    if (!this.addressForm.valid) return;
    let form = this.addressForm.value;
    this.isLoading = true;
    let shippingAddress: Address = {
      addressId: this.selectedProfile?.addressId ? this.selectedProfile?.addressId : 0,
      userId: this.currentUser.userId,
      userFirstName: form.firstName,
      userLastName: form.lastName,
      phone: form.phone,
      email: form.email,
      addressName: form.addressName,
      country: form.country,
      postalCode: form.postalCode,
      region: form.region,
      city: form.city,
      streetAddress: form.streetAddress
    };
    if (shippingAddress.addressId == 0){
      this.addressService.postAddress(shippingAddress).subscribe({
        next: () => {
          this.isLoading = false;
          this.selectedAddressChange.emit(shippingAddress);
          this.addressOpenChange.emit(false);
        }
      })
    }
    else{
      this.addressService.updateAddress(shippingAddress).subscribe({
        next: () => {
          this.isLoading = false;
          this.selectedAddressChange.emit(shippingAddress);
          this.addressOpenChange.emit(false);
        }
      })
    }
  }

  regions = [
    "Bács-Kiskun",
    "Baranya",
    "Békés",
    "Borsod-Abaúj-Zemplén",
    "Csongrád-Csanád",
    "Fejér",
    "Győr-Moson-Sopron",
    "Hajdú-Bihar",
    "Heves",
    "Jász-Nagykun-Szolnok",
    "Komárom-Esztergom",
    "Nógrád",
    "Pest",
    "Somogy",
    "Szabolcs-Szatmár-Bereg",
    "Tolna",
    "Vas",
    "Veszprém",
    "Zala",
    "Budapest (főváros)"
  ]

  ngOnInit(): void {
  }

}
