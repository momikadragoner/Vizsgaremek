import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { Address, AddressService } from '../services/address.service';
import { User, UserService } from '../services/user.service';
import { Auth } from '../services/auth';
import { faChevronLeft, faChevronRight, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { Router } from '@angular/router';
import { pairwise, startWith } from 'rxjs';

@Component({
  selector: 'app-order',
  templateUrl: './order.component.html',
  styleUrls: ['./order.component.scss']
})
export class OrderComponent implements OnInit {

  currentUser: Auth = Auth.currentUser;
  userInfo: User = new User();
  addresses?: Address[];
  emptyAddress: Address = new Address();
  selectedProfil?: Address;
  modalOpen: boolean = false;

  faChevronLeft = faChevronLeft;
  faChevronRight = faChevronRight;
  faSpinner = faSpinner;

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private addressService: AddressService,
    private userService: UserService
  ) {
    userService.getUser().subscribe({
      next: data => {
        this.userInfo = { ...data };
        if (this.userInfo != new User()) {
          let update = this.addressForm.value;
          update.firstName = this.userInfo.firstName;
          update.lastName = this.userInfo.lastName;
          update.email = this.userInfo.email;
          update.phone = this.userInfo.phone ? this.userInfo.phone : '';
          this.addressForm.setValue(update);
        }
      }
    });
    addressService.getAddress().subscribe({
      next: data => {
        if (data[0]) {
          this.addresses = [...data];
        }
      }
    });
  }

  ngOnInit(): void {
    // this.addressForm.valueChanges
    //   // .subscribe(()=>{
    //   //   if (!this.addresses) return;
    //   //   if (this.selectedProfil != undefined) {
    //   //     this.selectedProfil = new Address();
    //   //     console.log(this.selectedProfil);
    //   //   }
    //   // });
    //   .pipe(startWith(null), pairwise())
    //   .subscribe(([prev, next]: [any, any]) => {
    //     if (!this.addresses) return;
    //     if (!this.selectedProfil) return;
    //     if (next == this.addresses[0]) return;
    //     console.log('PREV', prev);
    //     console.log('NEXT', next);
    //   });
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
    this.modalOpen = true;
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
    let selectAdd: Address = this.selectedProfil ? this.selectedProfil : new Address();
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

  selectProfil() {
    if (!this.addresses) return;
    let profil: Address = this.selectedProfil ? this.selectedProfil : new Address();
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
}
